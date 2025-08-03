extends Node2D

@export var text_box : Label
func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/HomeScene.tscn")

func _on_hint_pressed() -> void:
	text_box.text = "You should try touching grass irl"
