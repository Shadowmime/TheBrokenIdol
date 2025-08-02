extends Area2D
class_name Projectile

var direction : Vector2 = Vector2.ZERO
var damage : float = 10
var speed = 1000.0
var max_distance = 3000
var distance = 0
var speed_mod = 1

# Sin wave motion
var wave_enabled = false
var wave_amplitude = 100.0
var wave_frequency = 2.0
var wave_time = 0.0
var perpendicular : Vector2 = Vector2.ZERO
var origin_position : Vector2
var spin_enabled = false

@export var homing_enabled = false
@export var homing_strength = 5.0
@export var homing_radius = 1000.0

var enemies

func _ready():
	origin_position = position

func _process(delta: float) -> void:
	if direction == Vector2.ZERO:
		return
	
	if homing_enabled:
		var target = get_nearest_target()
		if target:
			var to_target = (target.global_position - position).normalized()
			direction = direction.lerp(to_target, homing_strength * delta).normalized()
	
	var movement = direction.normalized() * speed * speed_mod * delta
	origin_position += movement
	distance += movement.length()
	
	if wave_enabled:
		wave_time += delta
		var offset = perpendicular * sin(wave_time * TAU * wave_frequency) * wave_amplitude
		position = origin_position + offset
	else:
		position = origin_position

	if spin_enabled:
		rotate(delta * 10)

	if distance > max_distance:
		queue_free()

func get_nearest_target() -> Node2D:
	var closest_target = null
	var closest_dist = homing_radius
	for body in enemies.get_children():
		var dist = position.distance_to(body.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_target = body
	return closest_target

func _on_body_entered(body: Node2D) -> void:
	if enemy && !body.is_in_group("player"):
		return
	if body.is_in_group("player") && enemy:
		body.take_damage(damage * attack_mod)
	elif body.is_in_group("player"):
		pass
	else:
		if body.has_method("take_damage"):
			body.take_damage(damage * attack_mod)
		if lightstick:
			return
		queue_free()

func set_damage(value):
	damage = value

#TODO Fix look at direction
func set_direction(dir, pos):
	direction = dir.normalized()
	rotation = dir.angle()
	perpendicular = Vector2(-direction.y, direction.x)
	
	#look_at_from_position(pos, dir * 100, Vector2.UP)

func toggle_wave(enable: bool = true):
	wave_enabled = enable

func toggle_spin(enable: bool = true):
	spin_enabled = enable

func set_speed(_speed):
	speed = _speed

var lightstick = false
func is_lightstick():
	lightstick = true

var enemy = false
func is_enemy():
	enemy = true

func set_speed_mod(_speed_mod):
	speed_mod = _speed_mod

func set_homing(strength):
	homing_enabled = true
	homing_strength = strength

var attack_mod = 1
func set_attack_mod(mod):
	attack_mod = mod
