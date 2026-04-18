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
		
		# 1. Format the title (Bold)
		var title_text = "[b]" + str(ability.name) + "[/b]"
		
		# 2. Format the description (New line, smaller font, grey color)
		var desc_text = "\n[font_size=14][color=#a3a3a3]" + ability.AbilityDescription + "[/color][/font_size]"
		
		# 3. Combine them inside the center tags
		name_label.text = "[center]" + title_text + desc_text + "[/center]"
		
		# IMPORTANT: Tells the RichTextLabel to resize vertically so the description doesn't get cut off!
		name_label.fit_content = true
		
		key_label.text = "[center]" + str(ability.trigger_key) + "[/center]"
		
		v_box_container.add_child(slot)
