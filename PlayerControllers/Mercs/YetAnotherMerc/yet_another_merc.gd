extends "res://PlayerControllers/Abilities/MoneyBased/base_money_user.gd"

const GoldShaderPreload := preload("res://PlayerControllers/Mercs/YetAnotherMerc/gold.gdshader")
var GoldMaterial = ShaderMaterial.new()

func money_custom_ready() -> void:
	# Hopefully this makes the mesh only invisible to me
	$MeshInstance3D.visible = !is_multiplayer_authority()
	GoldMaterial.shader = GoldShaderPreload
	
	var to_visit: Array[Variant] = self.abilities.duplicate()
	while to_visit.size() > 0:
		var cur: Variant = to_visit.pop_back()
		to_visit += cur.get_children()
		if cur is MeshInstance3D and cur != $MeshInstance3D:
			(cur as MeshInstance3D).set_surface_override_material(0, GoldMaterial)

	# I have no idea why this sets EVERY material to gold when it should only set the ability materials
	# lmao

	return
