extends Node2D

signal mirror_defeated

var target: Character

var phase = 1
# dir 0 is vertical, 1 is 60degrees, etc
var dir = 0:
	set(value):
		dir = value
		update_mirror_sprite()

###################################################
var health_bar: ProgressBar
var health = 750:
	set(value):
		health_bar.value = value
		health = clamp(value, 0, 750)

func take_damage(damage):
	if phase == 1:
		health = clamp(health - damage, 500, 750)
		if health == 500:
			phase = 2
	elif phase == 3:
		health = clamp(health - damage, 0, 250)
		if health == 0:
			die()

func _ready() -> void:
	_setup()
	await get_tree().create_timer(3).timeout
	choose_next_attack()

func _setup():
	health_bar = target.mirror_health

var t := 0.0
var do_infinity_move := false
var anchor_pos := Vector2.ZERO

func _process(delta):
	if orbit_mode:
		var radius = 500
		var angle = dir * PI / 3 - PI / 2
		var center = target.global_position
		var offset = Vector2(cos(angle), sin(angle)) * radius
		anchor_pos = center + offset
		position = anchor_pos

	if do_infinity_move:
		t += delta
		var x = sin(t * 2.0) * 80
		var y = sin(t * 4.0) * 40
		position = anchor_pos + Vector2(x, y)

##################################################
# Phase 1

func choose_next_attack():
	if phase == 1:
		if randi() % 2 == 0:
			perform_phase1_attack1()
		else:
			perform_phase1_attack2()
	elif phase == 2 and !spawning_phase2:
		spawning_phase2 = true
		spawn_phase2_enemies()
	elif phase == 3:
		if randi() % 2 == 0:
			perform_phase1_attack1()
		else:
			perform_phase1_attack2()

var orbit_mode = true

var proj_scene: PackedScene = preload("res://Character/Projectiles/LightStickAttack.tscn")
signal spawn_note(note: Projectile)

var shots_fired = 0

func perform_phase1_attack1():
	do_infinity_move = true
	orbit_mode = true
	shots_fired = 0
	_shoot_from_orbit()

var sprite1 = preload("res://Character/SkillTree/Icons/MusicNote_SemiRedv1.png")
var sprite2 = preload("res://Character/SkillTree/Icons/MusicNote_SemiRedv2.png")

func _shoot_from_orbit():
	if shots_fired >= 3:
		do_infinity_move = false
		await get_tree().create_timer(3).timeout
		_on_attack_1_finished()
		return

	dir = randi() % 6  # Choose a direction from 0–5

	for i in range(2):
		var proj = proj_scene.instantiate()
		proj.global_position = $PointSpawn.global_position
		var proj_dir = (target.global_position - proj.global_position).normalized()
		proj.set_direction(proj_dir, proj.global_position)
		if i == 0:
			proj._set_sprite(sprite1)
			proj.set_damage(50)
		elif i == 1:
			proj._set_sprite(sprite2)
			proj.set_damage(75)
		proj.set_speed(1500)
		proj.set_scale(Vector2(0.5, 0.5))
		proj.is_enemy()
		spawn_note.emit(proj)
		await get_tree().create_timer(1).timeout

	shots_fired += 1
	await get_tree().create_timer(1).timeout
	_shoot_from_orbit()

func _on_attack_1_finished():
	choose_next_attack()

func perform_phase1_attack2():
	_dash_at_player()
	await get_tree().create_timer(3).timeout
	choose_next_attack()

func _dash_at_player():
	orbit_mode = false
	do_infinity_move = false
	
	var dir_vec = (target.global_position - global_position).normalized()
	global_position -= dir_vec * 400
	
	await get_tree().create_timer(0.3).timeout
	
	var dash_distance = 1200
	var dash_time = 0.4
	var dash_speed = dash_distance / dash_time
	
	var travel_time := 0.0
	while travel_time < dash_time:
		var delta := get_process_delta_time()
		global_position += dir_vec * dash_speed * delta
		travel_time += delta
		await get_tree().process_frame

	# Teleport to new orbit position
	dir = randi() % 6
	orbit_mode = true

@export var mirror_sprite : AnimatedSprite2D
@export var glass_sprite : AnimatedSprite2D
func update_mirror_sprite():
	glass_sprite.visible = true
	match dir:
		0:
			mirror_sprite.frame = 0
			mirror_sprite.flip_h = false
			glass_sprite.frame = phase - 1  # 0,1,2
		1:
			mirror_sprite.frame = 2
			mirror_sprite.flip_h = true
			glass_sprite.frame = 3 + (phase - 1)
		2:
			mirror_sprite.frame = 4
			mirror_sprite.flip_h = true
			glass_sprite.visible = false
		3:
			mirror_sprite.frame = 5
			mirror_sprite.flip_h = false
			glass_sprite.visible = false
		4:
			mirror_sprite.frame = 4
			mirror_sprite.flip_h = false
			glass_sprite.visible = false
		5:
			mirror_sprite.frame = 2
			mirror_sprite.flip_h = false
			glass_sprite.frame = 3 + (phase - 1)

###################################################3
# Phase 2
var phase2_spawns = 0
var spawning_phase2 = false

const DIRECTION_ENEMIES = {
	0: "watcher",
	1: "rival",
	2: "broken_light",
	3: "watcher",
	4: "broken_light",
	5: "rival"
}

func spawn_phase2_enemies():
	target.movement_disabled = true
	target.set_invincible(true)
	phase2_spawns = 0
	_spawn_enemy_at_next_orbit()

func _spawn_enemy_at_next_orbit():
	if phase2_spawns >= 6:
		target.movement_disabled = false
		target.set_invincible(false)
		$AnimationPlayer.play("invis")
		await _wait_for_enemies_cleared()
		transition_to_phase_3()
		return
	
	dir = phase2_spawns
	var radius = 500
	var angle = dir * PI / 3 - PI / 2
	var offset = Vector2(cos(angle), sin(angle)) * radius
	var spawn_pos = target.global_position + offset
	
	var enemy_type = DIRECTION_ENEMIES.get(dir)
	get_tree().current_scene.spawn_specific_enemy_at(spawn_pos, enemy_type)
	
	phase2_spawns += 1
	await get_tree().create_timer(0.5).timeout
	_spawn_enemy_at_next_orbit()

func _wait_for_enemies_cleared() -> void:
	while true:
		var enemies = get_tree().get_nodes_in_group("boss_enemy")
		# Ignore the mirror itself
		if enemies.size() <= 0:
			break
		await get_tree().create_timer(0.5).timeout

func transition_to_phase_3():
	$AnimationPlayer.play("uninvis")
	phase = 3
	health = 250  # Set remaining health
	spawning_phase2 = false
	choose_next_attack()

func die():
	target.mirror_defeated()
	queue_free()
	#mirror_defeated.emit()
