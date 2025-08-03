extends CharacterBody2D
class_name Character

@export var sprite: AnimatedSprite2D
@export var camera: Camera2D

const SPRITE_HALF_WIDTH = 128
const SPRITE_HALF_HEIGHT = 128

var _current_speed: float = 0.0
var NORMAL_SPEED: float = 250.0
var speed_multiplier: float = 5.0

@export var shield : MeshInstance2D

@export var max_time = 10
@export var timer : ProgressBar
signal survived

@export var mirror_health: ProgressBar
var hud_open := false

var stage_rect = Rect2(Vector2.ZERO, Vector2(5760, 3240))

func _skill_update():
	#SKills
	if CharacterNerfs.has_nerf("shield2"):
		shield.modulate.a = 0.05
		shield_scale = 0.5
	if CharacterNerfs.has_nerf("shield1"):
		shield.hide()
		shield_scale = 1
	if CharacterNerfs.has_nerf("dash3"):
		DASH_COOLDOWN_TIME = 5
	if CharacterNerfs.has_nerf("eattack4"):
		EATTACK_COOLDOWN_TIME = 7
	if CharacterNerfs.has_nerf("qattack2"):
		EATTACK_COOLDOWN_TIME = 6
	
	#Mults
	# speed
	if CharacterNerfs.has_nerf("smult1"):
		speed_multiplier = 2
	elif CharacterNerfs.has_nerf("smult2"):
		speed_multiplier = 3
	elif CharacterNerfs.has_nerf("smult3"):
		speed_multiplier = 4
	else:
		speed_multiplier = 6
	
	# health
	if CharacterNerfs.has_nerf("hmult1"):
		max_health = 50
	elif CharacterNerfs.has_nerf("hmult2"):
		max_health = 100
	elif CharacterNerfs.has_nerf("hmult3"):
		max_health = 200
	else:
		max_health = 500
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = max_health
	
	# attack
	if CharacterNerfs.has_nerf("amult1"):
		attack_mod = 1
	elif CharacterNerfs.has_nerf("amult2"):
		attack_mod = 1.5
	elif CharacterNerfs.has_nerf("amult3"):
		attack_mod = 2
	else:
		attack_mod = 3

var shield_scale = 0
var attack_mod = 1

@export var regen_timer : Timer

func _ready():
	_current_speed = NORMAL_SPEED * speed_multiplier
	timer.max_value = max_time
	timer.value = max_time
	regen_timer.timeout.connect(_on_regen_timer_timeout)
	regen_timer.start()

func _process(delta: float) -> void:
	$AnimatedSprite2D.play("default")
	_flip_sprite_to_mouse()
	timer.value = clamp(timer.value - delta, 0, 60)
	if timer.value == 0:
		boss_spawn()

var already_spawned = false
func boss_spawn():
	#TODO if you want to skip boss while testing
	#boss_defeated.emit()
	if already_spawned:
		return
	else:
		already_spawned = true
	survived.emit()
	timer.hide()
	mirror_health.show()

@export var ui_anim_player: AnimationPlayer
signal boss_defeated
func mirror_defeated():
	# it will display the image of aria on the mirror
	# and then it will play a fade out.
	var ran = randi_range(1, 2)
	ui_anim_player.play("fade_out" + str(ran))
	await get_tree().create_timer(4).timeout
	boss_defeated.emit()

func _physics_process(delta):
	if hud_open:
		freeze()
		return

	if dash_cooldown > 0:
		dash_cooldown -= delta
	if eattack_cooldown > 0:
		eattack_cooldown -= delta
	if qattack_cooldown > 0:
		qattack_cooldown -= delta
	
	_move()
	move_and_slide()
	# Clamp position to within the stage bounds
	global_position.x = clamp(
		global_position.x,
		stage_rect.position.x + SPRITE_HALF_WIDTH,
		stage_rect.end.x - SPRITE_HALF_WIDTH
	)
	global_position.y = clamp(
		global_position.y,
		stage_rect.position.y + SPRITE_HALF_HEIGHT,
		stage_rect.end.y - SPRITE_HALF_HEIGHT
	)

func freeze():
	velocity = Vector2.ZERO

func _move():
	var input_vector := Vector2.ZERO
	if not CharacterNerfs.has_nerf("left") and Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if not CharacterNerfs.has_nerf("right") and Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if not CharacterNerfs.has_nerf("up") and Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	if not CharacterNerfs.has_nerf("down") and Input.is_action_pressed("move_down"):
		input_vector.y += 1

	is_running()
	if input_vector != Vector2.ZERO:
		velocity = input_vector.normalized() * _current_speed
	else:
		velocity = Vector2.ZERO

var dash_multiplier = 1
func set_speed_multiplier(multiplier: float = 1):
	dash_multiplier = multiplier

func is_running():
	_current_speed = NORMAL_SPEED * speed_multiplier * dash_multiplier

func _flip_sprite_to_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_center = get_viewport_rect().size.x / 2

	if mouse_pos.x < screen_center:
		sprite.scale.x = -abs(sprite.scale.x)  # Face left
	else:
		sprite.scale.x = abs(sprite.scale.x)   # Face right


######################3
signal projectile_spawn(note: Projectile)

# attacks
func spawn_note(note):
	projectile_spawn.emit(note)

func is_attacking():
	return false

func _on_regen_timer_timeout():
	if CharacterNerfs.has_nerf("regen1"):
		return # No regen
	elif CharacterNerfs.has_nerf("regen2"):
		health += 10
	elif CharacterNerfs.has_nerf("regen3"):
		health += 20
	else:
		health += int(max_health * 0.1)

var dash_cooldown : float = 0.0
var DASH_COOLDOWN_TIME : float = 1.0

var eattack_cooldown : float = 0.0
var EATTACK_COOLDOWN_TIME : float = 2.0

var qattack_cooldown : float = 0.0
var QATTACK_COOLDOWN_TIME : float = 3.0

var is_dash : bool = false

@export var health_bar : ProgressBar
var max_health = 500
var health = 500:
	set(value):
		health = clamp(value, 0, max_health)
		health_bar.value = health
		if health == 0:
			on_death()

signal player_died
func on_death():
	player_died.emit()

func take_damage(damage, _damage_type = null):
	# multipliers go in here
	health = health - damage * shield_scale * damage_taken_mult

var damage_taken_mult = 1
func set_damage_taken_multiplier(_damage_mult = 1):
	damage_taken_mult = _damage_mult

signal spawn_bomb(bomb: Bomb)
func _on_aoe_attack_spawn_bomb(bomb: Bomb) -> void:
	spawn_bomb.emit(bomb)
