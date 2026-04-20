extends "res://PlayerControllers/Abilities/MoneyBased/base_money_gun.gd"

func _ready() -> void:
	super()
	cost_per_activation = 2
	reward_per_kill = 100
