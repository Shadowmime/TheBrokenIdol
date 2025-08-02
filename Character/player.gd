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

var max_time = 60
@export var timer : ProgressBar
signal survived

var hud_open := false

var stage_rect = Rect2(Vector2.ZERO, Vector2(5760, 3240))

func _skill_update():
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

var shield_scale = 0

func _ready():
	_current_speed = NORMAL_SPEED * speed_multiplier
	health_bar.max_value = max_health
	health_bar.value = max_health
	timer.max_value = max_time
	timer.value = max_time

func _process(delta: float) -> void:
	$AnimatedSprite2D.play("default")
	_flip_sprite_to_mouse()
	timer.value = clamp(timer.value - delta, 0, 60)
	if timer.value == 0:
		survived.emit()

func _physics_process(delta):
	if hud_open:
		freeze()
		return

	if dash_cooldown > 0:
		dash_cooldown -= delta
	if eattack_cooldown > 0:
		eattack_cooldown -= delta
	
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
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	is_running()
	if input_vector != Vector2.ZERO:
		velocity = input_vector.normalized() * _current_speed
	else:
		velocity = Vector2.ZERO

func set_speed_multiplier(multiplier: float = 5.0):
	speed_multiplier = multiplier

func is_running():
	_current_speed = NORMAL_SPEED * speed_multiplier

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


var dash_cooldown : float = 0.0
var DASH_COOLDOWN_TIME : float = 1.0

var eattack_cooldown : float = 0.0
var EATTACK_COOLDOWN_TIME : float = 2.0

var is_dash : bool = false


@export var health_bar : ProgressBar
var max_health = 500
var health = 500:
	set(value):
		health = clamp(value, 0, max_health)
		health_bar.value = health
		if health == 0:
			on_death()

func on_death():
	get_tree().change_scene_to_file("res://Menus/game_over.tscn")

func take_damage(damage, _damage_type = null):
	# multipliers go in here
	health = health - damage * shield_scale * damage_taken_mult

var damage_taken_mult = 1
func set_damage_taken_multiplier(_damage_mult = 1):
	damage_taken_mult = _damage_mult
