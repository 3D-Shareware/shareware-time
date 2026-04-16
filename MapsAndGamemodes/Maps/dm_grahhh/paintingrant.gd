extends Area3D

@onready var audio = $GrahhhPaintingrant


func _on_body_entered(body: Node3D) -> void:
	if get_overlapping_bodies().size() < 2 and !audio.playing:
		audio.play()

#func _on_body_exited(body: Node3D) -> void:
#	if !has_overlapping_bodies():
#		audio.stop()
#		
