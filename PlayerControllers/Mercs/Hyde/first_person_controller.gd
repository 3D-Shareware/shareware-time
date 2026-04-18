extends Merc

@onready var DEBUGUI = $DEBUGUI

#nothing here! other than some basic ui and text stuff!
func custom_process(delta : float): 
	return
	DEBUGUI.text = str(snapped((velocity.length()), 0.01))

func custom_ready():
	if is_multiplayer_authority():
		$AudioStreamPlayer3D.stop()

func twerk():
	$"Dancing Twerk/AnimationPlayer".play("mixamo_com")
