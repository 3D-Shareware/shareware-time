extends Node3D


func _ready() -> void:
	visible = false
	if !is_multiplayer_authority(): return
	visible = true
