extends Map
class_name DM

# Changed from const to var so child classes (like TD) can overwrite them in _init()
var leaderboard_scene = preload("res://MapsAndGamemodes/Gamemodes/PresetGamemodeWidgets/Leaderboard/LeaderBoard.tscn")
var dm_ui_scene = preload("res://MapsAndGamemodes/Gamemodes/PresetGamemodeWidgets/VersusUI/VSUI.tscn")
var char_select_scene = preload("res://MapsAndGamemodes/Gamemodes/PresetGamemodeWidgets/CharacterSelect/CharacterSelect.tscn")

var leaderboard 
var match_ui: VSUI
var char_select_ui 
var master_character_database: Dictionary = {} 

@export var spawn_points: Array[Node3D] = [] 
@export var respawn_delay: float = 5.0 
@export var gamemode_length = 10.0

var respawn_trackers: Dictionary[int, Dictionary] = {}
var match_started: bool = false 
var time_left: float = 0.0 

func _ready() -> void:
	leaderboard = leaderboard_scene.instantiate()
	add_child(leaderboard)
	
	match_ui = dm_ui_scene.instantiate()
	add_child(match_ui)
	
	char_select_ui = char_select_scene.instantiate()
	add_child(char_select_ui)
	
	char_select_ui.character_locked_in.connect(_on_local_character_locked_in)

func _process(delta: float) -> void:
	# Universal Timer
	if match_started:
		time_left -= delta
		update_score_ui() # <--- Extracted so TD can override just the score logic
		
	if !multiplayer.is_server() or !match_started: 
		return
		
	if time_left <= 0.0 and match_started:
		_finish_match()
		return
	
	process_respawns(delta) # <--- Extracted

# --- VIRTUAL FUNCTIONS FOR CHILD CLASSES TO OVERRIDE ---

func update_score_ui():
	var my_id = multiplayer.get_unique_id()
	var my_kills = 0
	var top_kills = 0
	
	if leaderboard and leaderboard.stats:
		if leaderboard.stats.has(my_id):
			my_kills = leaderboard.stats[my_id].get("kills", 0)
		for player_data in leaderboard.stats.values():
			var kills = player_data.get("kills", 0)
			if kills > top_kills:
				top_kills = kills
				
	if match_ui:
		match_ui.update_ui(my_kills, top_kills, max(time_left, 0.0))

func process_respawns(delta: float):
	for player_id in respawn_trackers.keys():
		var tracker = respawn_trackers[player_id]
		if tracker["is_dead"]:
			tracker["respawn_timer"] -= delta
			if tracker["respawn_timer"] <= 0.0:
				_respawn_player(player_id)

func _respawn_player(player_id: int):
	var chosen_merc = master_character_database.get(player_id, "")
	if chosen_merc == "": 
		return 
		
	respawn_trackers[player_id]["is_dead"] = false
	if leaderboard: leaderboard.set_player_alive(player_id)
	
	if not has_node(str(player_id)):
		var spawn_pos = Vector3.ZERO
		if spawn_points.size() > 0:
			var random_spawn = spawn_points.pick_random()
			if random_spawn:
				spawn_pos = random_spawn.position 
				
		player_spawner.spawn({
			"merc_type": chosen_merc, 
			"position": spawn_pos,
			"peer_id": player_id
		})

# --- UNIVERSAL GAMEMODE LOGIC ---

func player_died(merc: Merc, killer_id : int = 0):
	if !multiplayer.is_server(): return
	var player_id = merc.name.to_int()
	
	if respawn_trackers.has(player_id):
		respawn_trackers[player_id]["is_dead"] = true
		respawn_trackers[player_id]["respawn_timer"] = respawn_delay
	
	if leaderboard:
		leaderboard.record_death(player_id)
		if killer_id != 0 and killer_id != player_id:
			leaderboard.record_kill(killer_id) 
	merc.queue_free()

func _on_player_joined(player_id: int) -> void:
	if not multiplayer.is_server(): return
	respawn_trackers[player_id] = { "is_dead": true, "respawn_timer": 0.0 }
	if leaderboard: leaderboard.add_player(player_id)
	start_char_select.rpc_id(player_id)

func _on_player_left(player_id: int) -> void:
	if !multiplayer.is_server(): return
	respawn_trackers.erase(player_id)
	master_character_database.erase(player_id)
	if leaderboard: leaderboard.remove_player(player_id)
	var merc_node = get_node_or_null(str(player_id))
	if merc_node: merc_node.queue_free()

func start_gamemode():
	if !multiplayer.is_server(): return
	_sync_start_match.rpc(gamemode_length)

@rpc("authority", "call_local", "reliable")
func _sync_start_match(length: float) -> void:
	time_left = length
	match_started = true

func _finish_match():
	match_started = false 
	if leaderboard:
		var top_players = leaderboard.get_top_players(3)
		leaderboard.show_end_game_showcase.rpc(top_players)
	await get_tree().create_timer(10.0).timeout
	_game_ended()

# --- CLIENT LOGIC ---

func _on_local_character_locked_in(chosen_merc: String):
	char_select_ui.hide()
	submit_character_choice.rpc_id(1, chosen_merc)

@rpc("authority", "call_remote", "reliable")
func start_char_select():
	char_select_ui.show()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("change_character"):
		if char_select_ui: 
			char_select_ui.show()
		request_suicide_for_switch.rpc_id(1, "character")

# --- SERVER LOGIC ---

@rpc("any_peer", "call_remote", "reliable")
func submit_character_choice(merc_type: String):
	var sender_id = multiplayer.get_remote_sender_id()
	master_character_database[sender_id] = merc_type
	if respawn_trackers.has(sender_id) and respawn_trackers[sender_id]["is_dead"]:
		respawn_trackers[sender_id]["respawn_timer"] = 0.0

@rpc("any_peer", "call_remote", "reliable")
func request_suicide_for_switch(switch_type: String = "character"):
	var sender_id = multiplayer.get_remote_sender_id()
	
	if switch_type == "character":
		master_character_database[sender_id] = ""
		
	var merc_node = get_node_or_null(str(sender_id))
	if merc_node and not merc_node.dead:
		merc_node.health = 0
		merc_node.dead = true
		merc_node.death_effects.rpc()
		merc_node.emit_signal("died", merc_node)
