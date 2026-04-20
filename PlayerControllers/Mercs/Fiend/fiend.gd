class_name Fiend extends Merc

@onready var animation_player: AnimationPlayer = $cat/AnimationPlayer

@onready var prev_location : Vector3 = self.global_position
var distance : float

func custom_process(_delta : float):
	# calculating delta to get my own jacked-up velocity val
	distance = prev_location.distance_to(self.global_position)
	
	# remapping values to scale anim speed
	animation_player.speed_scale = clamp(remap(distance, 0.1, 10, 0, 2), 0, 2)
	
	# setting prev location to set delta for next frame
	prev_location = self.global_position
	
	
	#if velocity.length() > .5:
		#animation_player.play()
	#else:
		#animation_player.pause()

func custom_ready():
	animation_player.play("walk")
