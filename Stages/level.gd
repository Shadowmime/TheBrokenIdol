extends Node2D

@export var projectiles : Node2D
@export var enemy_node : Node2D
@export var player : Character
@export var anim_player : AnimationPlayer

func _on_player_projectile_spawn(note: Projectile) -> void:
	note.enemies = enemy_node
	projectiles.add_child(note)

func _ready() -> void:
	for enemy in enemy_node.get_children():
		enemy.target = player
	player._skill_update()

func _on_watcher_spawn_note(note: Projectile) -> void:
	projectiles.add_child(note)

func _on_player_survived() -> void:
	spawn_mirror()
	#$ColorRect.show()
	#anim_player.play("ending1")
	#await get_tree().create_timer(1.5).timeout
	#get_tree().change_scene_to_file("res://Character/SkillTree/SkillTree.tscn")

@export var enemy_scenes: Array[PackedScene]
@export var stage_rect := Rect2(Vector2.ZERO, Vector2(5760, 3240))
@export var spawn_margin := 200

@export var mirror_scene: PackedScene
var boss_spawned = false
func spawn_mirror():
	boss_spawned = true
	var center = player.global_position
	var pos = center + Vector2(0, 500)
	var mirror = mirror_scene.instantiate()
	mirror.spawn_note.connect(_on_watcher_spawn_note)
	mirror.global_position = pos
	mirror.target = player
	mirror.add_to_group("enemy")
	enemy_node.add_child(mirror)

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
	enemy.add_to_group("enemy")
	enemy_node.add_child(enemy)

func spawn_specific_enemy_at(pos: Vector2, type: String):
	var spawn_pos = pos.clamp(stage_rect.position, stage_rect.end)
	var scene: PackedScene

	match type:
		"watcher":
			scene = enemy_scenes[0]
		"rival":
			scene = enemy_scenes[1]
		"broken_light":
			scene = enemy_scenes[2]
		_:
			push_error("Unknown enemy type: " + type)
			return

	var enemy = scene.instantiate()
	if enemy.has_signal("spawn_note"):
		enemy.spawn_note.connect(_on_watcher_spawn_note)
	enemy.global_position = spawn_pos
	enemy.target = player
	enemy.toggle_boss_shading()
	enemy.add_to_group("boss_enemy")
	enemy_node.add_child(enemy)

var spawn_timer := 0.0
var enemies_per_wave := 2
const SPAWN_INTERVAL := 10.0

func _process(delta):
	scribble_timer += delta
	if scribble_timer >= scribble_interval:
		scribble_timer = 0
		if randi() % 2 == 0:
			spawn_scribble()
	if !boss_spawned:
		spawn_timer += delta
		if spawn_timer >= SPAWN_INTERVAL:
			spawn_timer = 0
			enemies_per_wave += 1
			spawn_wave(enemies_per_wave)

func spawn_wave(count: int):
	for i in count:
		spawn_enemy_near_player()

func _on_player_spawn_bomb(bomb: Bomb) -> void:
	projectiles.add_child(bomb)


func _on_player_boss_defeated() -> void:
	# check loop
	if CharacterNerfs.is_finished():
		get_tree().change_scene_to_file("res://Menus/good_ending.tscn")
	else:
		get_tree().change_scene_to_file("res://Character/SkillTree/SkillTree.tscn")


func _on_player_player_died() -> void:
	call_deferred("player_died_change")
	
func player_died_change():
	if CharacterNerfs.campaign:
		get_tree().change_scene_to_file("res://Menus/game_over.tscn")
	else:
		CharacterNerfs.game_over = true
		get_tree().change_scene_to_file("res://Character/SkillTree/SkillTree.tscn")

#################################################3
#scribbles
var screen_size = Vector2(5440, 3240)

@export var scribble_scene: PackedScene
var scribble_timer := 0.0
var scribble_interval := 5.0

# Singleton or Level.gd static var
var current_scale = 0.4

func spawn_scribble():
	var scribble = scribble_scene.instantiate()
	
	var from_edge = randi() % 4
	var from := Vector2.ZERO
	var to := Vector2.ZERO

	match from_edge:
		0:  # left to right
			from = Vector2(0, randf_range(0, screen_size.y))
			to = Vector2(screen_size.x, from.y)
		1:  # right to left
			from = Vector2(screen_size.x, randf_range(0, screen_size.y))
			to = Vector2(0, from.y)
		2:  # top to bottom
			from = Vector2(randf_range(0, screen_size.x), 0)
			to = Vector2(from.x, screen_size.y)
		3:  # bottom to top
			from = Vector2(randf_range(0, screen_size.x), screen_size.y)
			to = Vector2(from.x, 0)

	scribble.scale = Vector2.ONE * current_scale
	current_scale += 0.05

	scribble.set_direction(from, to)
	add_child(scribble)
