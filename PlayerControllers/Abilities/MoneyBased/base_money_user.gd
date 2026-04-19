@abstract
extends Merc

const MoneyAbility := preload("res://PlayerControllers/Abilities/MoneyBased/base_money_ability.gd")

const GROUP_NAME = "CASH_USER"				## Group name. Access through `get_tree().get_nodes_in_group()` and similar group functions
@export var DEFAULT_CASH: float = 1000.0	## Starting cash
@export var MIN_CASH: float = 0				## Minimum possible cash
@export var MAX_CASH: float = 99999.0		## Maximum possible cash

signal cash_updated(old: float, new: float)	## Emitted any time the player's cash changes

## Player's cash. Relayed to money-based abilities via `cash_updated` signal
var cash: float = DEFAULT_CASH:
	set(m):
		m = clamp(m, MIN_CASH, MAX_CASH)
		if m != cash:
			var old := cash
			cash = old
			cash_updated.emit(old, cash)

## Overwritten from `Merc`, but still makes space for a custom ready via `money_custom_ready`
func custom_ready() -> void:
	add_to_group(GROUP_NAME)
	for ability in abilities:
		if ability.is_in_group(MoneyAbility.GROUP_NAME):
			ability.connect_player_cash(self)
			ability.fired.connect(func(cost: float) -> void: cash -= cost)

	money_custom_ready()
	return

## Overwrite in an extending class to implement merc specific ready behavior
@abstract func money_custom_ready() -> void
