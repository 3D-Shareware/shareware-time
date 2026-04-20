extends Node3D

@onready var duration_timer = $Timer
@onready var bleed_timer = $BleedTimer
var bleed_damage = 5

@onready var tracker
@onready var target_player = get_parent()

func _ready() -> void:
	$Sprite3D.visible = false
	if !tracker: return
	$Sprite3D.visible = true

func _on_bleed_timer_timeout() -> void:
	if target_player is Merc or target_player is DestructibleProp:
		target_player.take_damage.rpc_id(target_player.name.to_int(), bleed_damage) 


func _on_timer_timeout() -> void:
	queue_free()
