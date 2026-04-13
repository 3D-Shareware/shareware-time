extends Area3D

@export var ability : Ability
@export var consumable := false
@onready var spin_point: Marker3D = $SpinPoint

func _ready() -> void:
	if ability:
		ability.reparent(spin_point)
		for i in ability.get_children():
			if i is Node3D:
				i.hide()
		ability.visual_hand.show()

func _on_body_entered(body: Node3D) -> void:
	if not multiplayer.is_server(): return 
	
	if body is Merc:
		body.add_ability(ability)
