extends "res://PlayerControllers/Abilities/MoneyBased/base_money_ability.gd"

signal reduce_activations(mult: float)

func connect_player_cash(player: Merc) -> void:
	super(player)
	
	for ability in player.abilities:
		if !ability.is_in_group(GROUP_NAME): continue
		ability.activations_updated.connect(
			func(old: int, new: int) -> void:
				if new > old: activations += abs(new - old)
		)
		
		self.activations_updated.connect(
			func(_old: int, _new: int) -> void:
				ability.cost_multiplier = get_new_mult(ability.activations)
		)
		
		self.reduce_activations.connect(
			func(mult: float) -> void:
				ability.activations = floorf(ability.activations * mult)
		)

func get_new_mult(act: int) -> float:
	if activations == act: activations += 1
	return 1.0 / (1.0 - ((1.0 * act) / (1.0 * activations)))
	# Ignore the "1.0 *" bs, it's just so that godot stops complaining about int div

# Never ran because this is never explicitly activated
func activate() -> void: return

var passed: float = 0.0
func _physics_process(delta: float) -> void:
	if !connected: return
	passed += delta
	if passed >= 1:
		@warning_ignore("narrowing_conversion")
		activations = floorf(activations * 0.90)
		reduce_activations.emit(0.85)
		passed = 0
