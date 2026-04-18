extends Node3D

@onready var anim = $AnimationPlayer
@onready var audio: AudioStreamPlayer3D = $rig_deform/Skeleton3D/BoneAttachment3D/AudioStreamPlayer3D

func _ready() -> void:
	anim.play("Active_005")

func activate():
	anim.play("Active_007")
	audio.play()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Active_005":
		anim.play("Active_005")
