extends "res://PlayerControllers/Abilities/MoneyBased/base_money_user.gd"

func money_custom_ready() -> void:
	# Hopefully this makes the mesh only invisible to me
	$MeshInstance3D.visible = !is_multiplayer_authority()
	return
