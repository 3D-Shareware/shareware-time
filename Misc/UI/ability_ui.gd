extends Control
class_name AbilitiesUI

@onready var panel: Panel = $Panel
@onready var v_box_container: VBoxContainer = $Panel/VBoxContainer

const ability_slot_scene = preload("res://Misc/UI/ability_slot_ui.tscn")

var is_menu_open: bool = false
var hidden_pos_x: float
var visible_pos_x: float


func _process(_delta: float) -> void:
	visible = Input.is_physical_key_pressed(KEY_TAB)

func generate_ui(merc: Merc) -> void:
	for child in v_box_container.get_children():
		child.queue_free()
		
	for ability in merc.abilities:
		if ability == null: continue
		
		var slot = ability_slot_scene.instantiate()
		var name_label: RichTextLabel = slot.get_node("Ability")
		var key_label: RichTextLabel = slot.get_node("Key")
		
		name_label.text = "[center]" + str(ability.name) + "[/center]"
		key_label.text = "[center]" + str(ability.trigger_key) + "[/center]"
		
		v_box_container.add_child(slot)
