extends Map
class_name DM
#deathmatch

const LEADER_BOARD = preload("res://MapsAndGamemodes/Gamemodes/PresetGamemodeWidgets/Leaderboard/LeaderBoard.tscn")
const DM_UI = preload("res://MapsAndGamemodes/Gamemodes/PresetGamemodeWidgets/VersusUI/VSUI.tscn")

var leaderboard: LeaderBoard 
var match_ui: VSUI

@export var spawn_points: Array[Node3D] = [] 
@export var respawn_delay: float = 5.0 
@export var gamemode_length = 10.0

var respawn_trackers: Dictionary[int, Dictionary] = {}
var match_started: bool = false 
var time_left: float = 0.0 # Track time for the UI

func _ready() -> void:
	leaderboard = LEADER_BOARD.instantiate()
	add_child(leaderboard)
	
	# Instantiate the UI on all clients
	match_ui = DM_UI.instantiate()
	add_child(match_ui)

func _process(delta: float) -> void:
	# --- UI & TIME LOGIC (Runs on Server AND Clients) ---
	if match_started:
		time_left -= delta
		
		# Calculate scores for the UI
		var my_id = multiplayer.get_unique_id()
		var my_kills = 0
		var top_kills = 0
		
		if leaderboard and leaderboard.stats:
			# Get local player's kills safely
			if leaderboard.stats.has(my_id):
				my_kills = leaderboard.stats[my_id].get("kills", 0)
			
			# Find the highest kills in the lobby
			for player_data in leaderboard.stats.values():
				var kills = player_data.get("kills", 0)
				if kills > top_kills:
					top_kills = kills
		
		# Feed the UI
		if match_ui:
			match_ui.update_ui(my_kills, top_kills, max(time_left, 0.0))

	# --- RESPAWN LOGIC (Server Only) ---
	if !multiplayer.is_server() or !match_started: 
		return
		
	# Check server game-end condition
	if time_left <= 0.0 and match_started:
		_finish_match()
		return
	
	for player_id in respawn_trackers.keys():
		var tracker = respawn_trackers[player_id]
		
		if tracker["is_dead"]:
			tracker["respawn_timer"] -= delta
			if tracker["respawn_timer"] <= 0.0:
				_respawn_player(player_id)

func player_died(merc: Merc):
	if !multiplayer.is_server(): return
	var player_id = merc.name.to_int()
	
	# Update Map logic (Respawns)
	if respawn_trackers.has(player_id):
		respawn_trackers[player_id]["is_dead"] = true
		respawn_trackers[player_id]["respawn_timer"] = respawn_delay
	
	# Update Leaderboard logic
	if leaderboard:
		leaderboard.record_death(player_id)
		
	merc.queue_free()

func _respawn_player(player_id: int):
	respawn_trackers[player_id]["is_dead"] = false
	
	if leaderboard:
		leaderboard.set_player_alive(player_id)
	
	if not has_node(str(player_id)):
		var spawn_pos = Vector3.ZERO
		if spawn_points.size() > 0:
			var random_spawn = spawn_points.pick_random()
			if random_spawn:
				spawn_pos = random_spawn.position 
				
		player_spawner.spawn({
			"merc_type": "default", 
			"position": spawn_pos,
			"peer_id": player_id
		})
		print("Player ", player_id, " respawned at ", spawn_pos)

func _on_player_joined(player_id: int) -> void:
	if not multiplayer.is_server(): return
	
	respawn_trackers[player_id] = { "is_dead": true, "respawn_timer": 0.0 }
	
	if leaderboard:
		leaderboard.add_player(player_id)

func _on_player_left(player_id: int) -> void:
	if !multiplayer.is_server(): return
	
	respawn_trackers.erase(player_id)
	if leaderboard:
		leaderboard.remove_player(player_id)
	
	var merc_node = get_node_or_null(str(player_id))
	if merc_node:
		merc_node.queue_free()

func start_gamemode():
	if !multiplayer.is_server(): return
	# Start the match on ALL clients simultaneously
	_sync_start_match.rpc(gamemode_length)

@rpc("authority", "call_local", "reliable")
func _sync_start_match(length: float) -> void:
	time_left = length
	match_started = true

func _finish_match():
	# Lock the game loop
	match_started = false 
	
	# Calculate winners and show them on all clients
	if leaderboard:
		var top_players = leaderboard.get_top_players(3)
		leaderboard.show_end_game_showcase.rpc(top_players)
		
	# Wait for 10 seconds so people can see the results
	await get_tree().create_timer(10.0).timeout
	
	# Finally, end the game entirely
	_game_ended()
