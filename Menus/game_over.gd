extends Node2D

func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/HomeScene.tscn")

func _on_retry_pressed() -> void:
	CharacterNerfs.retry()
	get_tree().change_scene_to_file("res://Character/SkillTree/SkillTree.tscn")
