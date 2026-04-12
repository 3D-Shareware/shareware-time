extends Control

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hide()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		visible = !visible
		if visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
