extends OneShotAbility

@onready var sprite = $Sprite2D
@export var gun :Node3D
@export var camera :Camera3D

var showing :bool = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("right_click"):
		_on_activate_just_pressed()

func _on_activate_just_pressed():
	$AudioStreamPlayer3D.play()
	if !is_multiplayer_authority(): return
	print(camera)
	showing = !showing
	
	match showing:
		true:
			$Control.visible = true
			gun.visible = false
			camera.fov = 18
		false:
			$Control.visible = false
			gun.visible = true
			camera.fov = 90
