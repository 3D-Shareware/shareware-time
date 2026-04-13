extends Control
class_name VSUI

@onready var good_team: Label = $Panel/GoodTeam
@onready var bad_team: Label = $Panel/BadTeam
@onready var time_label: RichTextLabel = $Panel/Panel/Time

func _ready() -> void:
	# Hide by default so it doesn't flash on screen before the check happens
	hide()

# Added 'lobby_id' as the first parameter so we know which match to check
func update_ui(my_points: int, top_points: int, time_left: float) -> void:
	var lobby_id = get_parent().name
	# --- 1. SECURITY / VISIBILITY CHECK ---
	var my_id = multiplayer.get_unique_id()
	
	# If the lobby doesn't exist, OR the local player isn't in it, hide and abort!
	if not ServerDatabase.Lobbies.has(lobby_id) or not my_id in ServerDatabase.Lobbies[lobby_id]:
		hide()
		return
		
	# If they made it past the check, make sure the UI is visible
	show()
	# --------------------------------------

	# 2. Update Scores
	good_team.text = str(my_points)
	bad_team.text = str(top_points)
	
	# 3. Format the time to MM:SS
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	var time_str = "%02d:%02d" % [minutes, seconds]
	
	# 4. Apply the dynamic BBCode styling based on time left
	if time_left <= 15.0:
		# Red AND shaking!
		time_label.text = "[center][color=red][shake rate=20.0 level=10 connected=1]%s[/shake][/color][/center]" % time_str
	elif time_left <= 30.0:
		# Just Red
		time_label.text = "[center][color=red]%s[/color][/center]" % time_str
	else:
		# Normal
		time_label.text = "[center]%s[/center]" % time_str
