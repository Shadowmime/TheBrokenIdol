extends Node2D

@export var projectiles : Node2D
@export var enemy_node : Node2D
@export var player : Character
@export var anim_player : AnimationPlayer

func _on_player_projectile_spawn(note: Projectile) -> void:
	projectiles.add_child(note)

func _ready() -> void:
	for enemy in enemy_node.get_children():
		enemy.target = player
	player._skill_update()

func _on_watcher_spawn_note(note: Projectile) -> void:
	projectiles.add_child(note)

func _on_player_survived() -> void:
	$ColorRect.show()
	anim_player.play("ending1")
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://Character/SkillTree/SkillTree.tscn")

@export var enemy_scenes: Array[PackedScene]
@export var stage_rect := Rect2(Vector2.ZERO, Vector2(5760, 3240))
@export var spawn_margin := 200

func spawn_enemy_near_player():
	var viewport_size = Vector2(1920, 1080)
	var zoom = 0.75
	var visible_size = viewport_size / zoom
	var half_visible = visible_size / 2

	var center = player.global_position

	# Define the 4 spawn zones just *outside* the visible viewport
	var spawn_zones = {
		"top": Rect2(center.x - half_visible.x, center.y - half_visible.y - spawn_margin, visible_size.x, spawn_margin),
		"bottom": Rect2(center.x - half_visible.x, center.y + half_visible.y, visible_size.x, spawn_margin),
		"left": Rect2(center.x - half_visible.x - spawn_margin, center.y - half_visible.y, spawn_margin, visible_size.y),
		"right": Rect2(center.x + half_visible.x, center.y - half_visible.y, spawn_margin, visible_size.y)
	}

	var sides = ["top", "bottom", "left", "right"]
	var chosen_side = sides.pick_random()
	var spawn_zone = spawn_zones[chosen_side]

	var spawn_pos = Vector2(
		randf_range(spawn_zone.position.x, spawn_zone.position.x + spawn_zone.size.x),
		randf_range(spawn_zone.position.y, spawn_zone.position.y + spawn_zone.size.y)
	)

	# Clamp to stage
	spawn_pos.x = clamp(spawn_pos.x, stage_rect.position.x, stage_rect.end.x)
	spawn_pos.y = clamp(spawn_pos.y, stage_rect.position.y, stage_rect.end.y)
	
	var enemy = enemy_scenes[randi_range(0, enemy_scenes.size() - 1)].instantiate()
	if enemy.has_signal("spawn_note"):
		enemy.spawn_note.connect(_on_watcher_spawn_note)
	enemy.global_position = spawn_pos
	enemy.target = player
	enemy_node.add_child(enemy)

var spawn_timer := 0.0
var enemies_per_wave := 2
const SPAWN_INTERVAL := 10.0

func _process(delta):
	spawn_timer += delta
	if spawn_timer >= SPAWN_INTERVAL:
		spawn_timer = 0
		enemies_per_wave += 1
		spawn_wave(enemies_per_wave)

func spawn_wave(count: int):
	for i in count:
		spawn_enemy_near_player()
