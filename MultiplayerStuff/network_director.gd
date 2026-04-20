extends Node

@onready var lobby_container: LobbyContainer = $LobbyContainer
@onready var join_screen: Control = $JoinScreen
@onready var btn_csdev: Button = $JoinScreen/Panel/Button
@onready var btn_local: Button = $JoinScreen/Panel/Button2
@onready var gamertag_edit: LineEdit = $JoinScreen/Panel/GamerTagEdit

const QUIRKY_PREFIXES = [
	"Lagging", "Sweaty", "Caffeinated", "Salty", "Chaotic", 
	"Clumsy", "Toasted", "Rogue", "Sneaky", "Buggy"
]

func _ready() -> void:
	if OS.has_feature("server") or "--server" in OS.get_cmdline_args():
		join_screen.hide() # Hide the UI on the server
		_setup_server()
	else:
		# We are a player. Connect the UI buttons!
		btn_csdev.pressed.connect(_on_join_csdev_pressed)
		btn_local.pressed.connect(_on_join_local_pressed)

func _get_or_generate_gamertag() -> String:
	var typed_name = gamertag_edit.text.strip_edges()
	
	# If they typed something, use it
	if typed_name != "":
		return typed_name
		
	# Otherwise, generate the quirky random name
	var random_quirk = QUIRKY_PREFIXES.pick_random()
	var random_digits = randi_range(10000000, 99999999)
	
	return "%s%d" % [random_quirk, random_digits]

func _on_join_csdev_pressed() -> void:
	var final_name = _get_or_generate_gamertag()
	join_screen.hide()
	_setup_client("csdev03.d.umn.edu", final_name)

func _on_join_local_pressed() -> void:
	var final_name = _get_or_generate_gamertag()
	join_screen.hide()
	_setup_client("127.0.0.1", final_name)

func _setup_server():
	get_window().position.x -= ceil(get_window().size.x / 2.0 + 8)
	var server_logic = ServerLogic.new()
	server_logic.lobby_container = lobby_container
	add_child(server_logic)

# Added 'gamertag' as a parameter
func _setup_client(ip: String, gamertag: String):
	randomize() # Good to call this before using randi_range to ensure true randomness
	get_window().position.x += ceil(get_window().size.x / 2.0 + 8)
	var client_logic = ClientLogic.new()
	client_logic.lobby_container = lobby_container
	
	# Pass both the IP and the Gamertag to the ClientLogic script
	client_logic.set_meta("target_ip", ip) 
	client_logic.set_meta("gamertag", gamertag) 
	
	add_child(client_logic)
