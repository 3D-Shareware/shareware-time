extends Control
class_name VSUI

@onready var good_team: Label = $Panel/GoodTeam
@onready var bad_team: Label = $Panel/BadTeam
@onready var time_label: RichTextLabel = $Panel/Panel/Time

func _ready() -> void:
	hide()

# Added 'my_team' as an optional parameter to handle TD colors
func update_ui(my_points: int, top_points: int, time_left: float, my_team: String = "") -> void:
	var lobby_id = get_parent().name
	var my_id = multiplayer.get_unique_id()
	
	if not ServerDatabase.Lobbies.has(lobby_id) or not my_id in ServerDatabase.Lobbies[lobby_id]:
		hide()
		return
		
	show()

	# Update Scores
	good_team.text = str(my_points)
	bad_team.text = str(top_points)
	
	# Update Colors based on team
	if my_team == "red":
		good_team.add_theme_color_override("font_color", Color.RED)
		bad_team.add_theme_color_override("font_color", Color.BLUE)
	elif my_team == "blue":
		good_team.add_theme_color_override("font_color", Color.BLUE)
		bad_team.add_theme_color_override("font_color", Color.RED)
	else:
		# Reset to default styling if no team is passed (e.g., standard Deathmatch)
		good_team.remove_theme_color_override("font_color")
		bad_team.remove_theme_color_override("font_color")
	
	# Format time
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	var time_str = "%02d:%02d" % [minutes, seconds]
	
	if time_left <= 15.0:
		time_label.text = "[center][color=red][shake rate=20.0 level=10 connected=1]%s[/shake][/color][/center]" % time_str
	elif time_left <= 30.0:
		time_label.text = "[center][color=red]%s[/color][/center]" % time_str
	else:
		time_label.text = "[center]%s[/center]" % time_str
