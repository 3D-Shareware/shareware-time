extends ColorRect



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	if !is_multiplayer_authority(): return
	visible = true
