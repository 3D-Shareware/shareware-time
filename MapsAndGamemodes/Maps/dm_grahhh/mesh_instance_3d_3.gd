extends MeshInstance3D

func _process(delta: float) -> void:
	material_override.uv1_offset.x +=1
	material_override.uv1_offset.y +=1
