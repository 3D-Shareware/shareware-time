extends Control # Or whatever ClientUI extends

@onready var line_edit = $Panel2/LineEdit
@onready var button = $Panel2/Button

func _ready() -> void:
	# Connect the button press to our custom function
	button.pressed.connect(_on_change_name_pressed)

func _on_change_name_pressed() -> void:
	var new_name = line_edit.text.strip_edges()
	
	if new_name != "":
		# Send the requested name straight to the server (Peer ID 1)
		ServerDatabase.request_name_change.rpc_id(1, new_name)
		
		# Optional: Clear the text box or change placeholder text so the user knows it worked
		line_edit.clear()
		line_edit.placeholder_text = new_name
