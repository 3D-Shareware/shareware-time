extends "res://PlayerControllers/Abilities/MoneyBased/base_money_gun.gd"

func _ready() -> void:
	super()
	reward_per_kill = 0 ## Not actually zero. See `base_money_gun`'s implementation of the `reward_per_kill` property
	cost_per_activation = 2
