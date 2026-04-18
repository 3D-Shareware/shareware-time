extends Label3D
class_name MercLabel

var peer_id: int = 0

func _ready() -> void:
	# 1. Ensure the text always faces the camera
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	
	# Optional: Prevents the label from clipping into walls/ceilings
	no_depth_test = true 
	
	# 2. Listen to the global database for any changes
	if ServerDatabase.has_signal("players_updated"):
		ServerDatabase.players_updated.connect(_on_players_updated)

# The Merc script will call this right after instantiating the label
func setup(id: int) -> void:
	peer_id = id
	_on_players_updated() # Force an initial update immediately

func _on_players_updated() -> void:
	# Look up this specific peer's gamertag in the global database
	if ServerDatabase.Players.has(peer_id):
		text = ServerDatabase.Players[peer_id].get("gamertag", "Player " + str(peer_id))
	else:
		text = "Player " + str(peer_id)
