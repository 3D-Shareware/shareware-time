extends Control
class_name LeaderBoard

@onready var v_box_container: VBoxContainer = $Panel/VBoxContainer

# Tracks networking stats. Example: { 1: {"kills": 0, "deaths": 0, "is_dead": false} }
var stats: Dictionary = {}

func _ready() -> void:
	hide()

func _process(_delta: float) -> void:
	# Toggles visibility based on input (e.g., holding 'Tab')
	if stats.has(multiplayer.get_unique_id()):
		if Input.is_action_pressed("show_leaderboard"):
			show()
		else:
			hide()

# ==========================================
# SERVER API (Called by the Map Script)
# ==========================================

func add_player(player_id: int) -> void:
	if not multiplayer.is_server(): return
	# Players start dead until the map spawns them
	stats[player_id] = { "kills": 0, "deaths": 0, "is_dead": true }
	_sync_stats.rpc(stats)

func remove_player(player_id: int) -> void:
	if not multiplayer.is_server(): return
	stats.erase(player_id)
	_sync_stats.rpc(stats)

func record_death(player_id: int) -> void:
	if not multiplayer.is_server(): return
	if stats.has(player_id):
		stats[player_id]["deaths"] += 1
		stats[player_id]["is_dead"] = true
		_sync_stats.rpc(stats)

func record_kill(player_id: int) -> void:
	if not multiplayer.is_server(): return
	if stats.has(player_id):
		stats[player_id]["kills"] += 1
		_sync_stats.rpc(stats)

# The map must call this when a respawn timer finishes!
func set_player_alive(player_id: int) -> void:
	if not multiplayer.is_server(): return
	if stats.has(player_id):
		stats[player_id]["is_dead"] = false
		_sync_stats.rpc(stats)


# ==========================================
# NETWORKING & UI
# ==========================================

@rpc("authority", "call_local", "reliable")
func _sync_stats(new_stats: Dictionary) -> void:
	stats = new_stats
	update_ui()

func update_ui() -> void:
	# 1. Clear out the old list
	for child in v_box_container.get_children():
		child.queue_free()
		
	# 2. Build the new list
	for player_id in stats.keys():
		var player_data = stats[player_id]
		
		var kills = player_data["kills"]
		var deaths = player_data["deaths"]
		
		# Use .get() as a failsafe just in case "is_dead" isn't in the dictionary
		var status = "DEAD" if player_data.get("is_dead", true) else "ALIVE"
		
		# Create a simple text label for the leaderboard
		var label = Label.new()
		label.text = "Player %s | Kills: %d | Deaths: %d | %s" % [str(player_id), kills, deaths, status]
		
		# Add it to the VBoxContainer so it stacks neatly
		v_box_container.add_child(label)
