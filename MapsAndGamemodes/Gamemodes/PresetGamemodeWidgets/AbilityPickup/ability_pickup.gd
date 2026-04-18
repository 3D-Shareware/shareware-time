extends Area3D

@export var ability : Ability
@export var consumable := false
@onready var spin_point: Marker3D = $SpinPoint

# Variables to control the floating animation
@export var float_speed: float = 2.0
@export var float_height: float = 0.25
var start_y: float

func _ready() -> void:
	# Save the initial height of the ENTIRE ORB (the Area3D itself)
	start_y = position.y
	
	if ability:
		ability.reparent(spin_point)
		
		# Create a "dummy" copy of the visual hand to display on the pedestal
		if ability.visual_hand:
			var display_mesh = ability.visual_hand.duplicate()
			spin_point.add_child(display_mesh)
			
			# Make sure our copy is visible, even if the real one is hidden
			display_mesh.show()
			
			# Ensure it sits perfectly center on the spin point
			display_mesh.position = Vector3.ZERO 

func _process(_delta: float) -> void:
	# Smoothly float the entire Area3D up and down
	var time = Time.get_ticks_msec() / 1000.0
	position.y = start_y + sin(time * float_speed) * float_height

func _on_body_entered(body: Node3D) -> void:
	# ONLY the server is allowed to process pickups
	if not multiplayer.is_server(): return 
	
	if body is Merc:
		body.add_ability(ability)
		
		# If consumable, tell all players to delete this pickup orb
		if consumable:
			_sync_destroy.rpc()

# ==========================================
# NETWORKING
# ==========================================

@rpc("authority", "call_local", "reliable")
func _sync_destroy() -> void:
	# This deletes the Area3D pickup and the duplicate display mesh
	queue_free()
