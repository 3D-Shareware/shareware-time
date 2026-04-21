extends Ability
@onready var animation_player: AnimationPlayer = $"Dancing Twerk/AnimationPlayer"

func activate():
	animation_player.play("mixamo_com")
