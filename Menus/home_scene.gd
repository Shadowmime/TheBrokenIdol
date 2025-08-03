extends Control

func _ready():
	CharacterNerfs.reset()

func _on_campaign_pressed() -> void:
	$Home.hide()
	$Controls.show()

func _on_continue_pressed() -> void:
	$Controls.hide()
	$enemies.show()

@export var enemies : Control
var enemy_index = 0
@export var current_enemy : Control
func _on_next_pressed() -> void:
	enemy_index += 1
	enemy_index = enemy_index % 4
	update_enemy_screen()

func _on_prev_pressed() -> void:
	enemy_index -= 1
	enemy_index = enemy_index % 4
	if enemy_index < 0:
		enemy_index += 4
	update_enemy_screen()

func update_enemy_screen():
	current_enemy.hide()
	current_enemy = enemies.get_child(enemy_index)
	current_enemy.show()
	

var start_pressed = false
func _on_start_pressed() -> void:
	if start_pressed:
		return
	start_pressed = true
	$enemies/AnimationPlayer.play("start_game")
	await get_tree().create_timer(4).timeout
	get_tree().change_scene_to_file("res://Stages/Level.tscn")

func _on_freeplay_pressed() -> void:
	CharacterNerfs.campaign = false
	CharacterNerfs.first_tree = false
	CharacterNerfs.add_nerf("shield2")
	get_tree().change_scene_to_file("res://Stages/Level.tscn")

func _input(event):
	if event.is_action_pressed("true_ending"):
		if $Controls.visible:
			trigger_true_ending()

func trigger_true_ending():
	get_tree().change_scene_to_file("res://Menus/true_ending.tscn")
