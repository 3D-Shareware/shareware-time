extends OneShotAbility
@onready var gas_emit = $AudioStreamPlayer3D

func _on_activate_just_pressed():
	gas_emit.play()
