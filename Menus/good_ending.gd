extends Node2D

@export var text_box : Label
@export var hint_button_label: Label

var hint_pressed: int = 1

func _ready() -> void:
	hint_pressed = 1
	hint_button_label.text = "Hint" + str(hint_pressed) + " for\ntrue ending"

func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/HomeScene.tscn")

func _on_hint_pressed() -> void:
	if hint_pressed == 1:
		text_box.text = "What do the question marks in the enemies description spell?"
	else:
		text_box.text = "Read the capital letters in the in-game monologue."
	hint_pressed += 1
	if hint_pressed > 2:
		hint_pressed = 1
	hint_button_label.text = "Hint" + str(hint_pressed) + " for\ntrue ending"
