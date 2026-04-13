extends Control

signal side_chosen(side : String)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

func _on_red_pressed() -> void:
	side_chosen.emit('red')
	hide()

func _on_blue_pressed() -> void:
	side_chosen.emit('blue')
	hide()
