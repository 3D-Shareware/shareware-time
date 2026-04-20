extends Merc

func custom_ready():
	if is_multiplayer_authority():
		$AudioStreamPlayer3D.stop()

func twerk():
	$"Dancing Twerk/AnimationPlayer".play("mixamo_com")
