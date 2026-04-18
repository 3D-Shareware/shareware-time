extends OmniLight3D

var range = [-7, -10]
var target = -7.0
func _physics_process(delta: float) -> void:
	if randi_range(0, 300) == 1:
		target = randf_range(range[0], range[1])
	
	position.z = lerp(position.z, target, 0.02)
