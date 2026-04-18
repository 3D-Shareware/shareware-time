extends DestructibleProp

@export var hand : Node3D

func _ready():
	$AudioStreamPlayer3D3.stream = load("res://MapsAndGamemodes/Maps/dm_grahhh/duhhhloop.tres")
	$AudioStreamPlayer3D3.volume_db = 3.0
	$AudioStreamPlayer3D3.play()

func hit_effect(damage):
	$AudioStreamPlayer3D.pitch_scale = randf_range(0.7, 1.2)
	$AudioStreamPlayer3D.play()

@rpc("any_peer", "call_remote", "reliable")
func destroy_effect():
	$AudioStreamPlayer3D2.play()
	$AudioStreamPlayer3D3.stream = load("res://MapsAndGamemodes/Maps/dm_grahhh/ghostwhispersloop.tres")
	$AudioStreamPlayer3D3.max_db = -3.5
	$AudioStreamPlayer3D3.play()
	$AnimationPlayer.play("screenshake")
	
	hand.activate()
