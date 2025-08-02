extends CharacterBody2D
class_name Enemy

var speed = 500.0

@export var nav : NavigationAgent2D
@export var animation_player : AnimationPlayer

# Enemy Stats
signal health_changed(new_health)
signal dead(_name)

func _ready() -> void:
	play_animations()

@export var health_bar : ProgressBar
var max_health = 100
var health = 100:
	set(value):
		health = clamp(value, 0, max_health)
		health_bar.value = health
		health_changed.emit(health)
		if health == 0:
			on_death()

func take_damage(damage, _damage_type = null):
	# multipliers go in here
	health = health - damage

var attack_cd : float = 0
var max_attack_cd : float = 2

func _process(delta: float) -> void:
	if attack_cd > 0:
		attack_cd -= delta

func play_animations():
	pass

func setup(_camera):
	#camera = _camera
	pass

func _on_health_changed(new_health: Variant) -> void:
	health_bar.value = new_health


var target : Character
@export var sprite : AnimatedSprite2D

@export var attack : AnimatedSprite2D
func target_position(target):
	nav.target_position = target
	if target.x - position.x < 0:
		sprite.scale.x = -abs(sprite.scale.x)  # Face left
		if attack:
			attack.scale.x = -abs(attack.scale.x)
	else:
		sprite.scale.x = abs(sprite.scale.x)
		if attack:
			attack.scale.x = abs(attack.scale.x)

func get_player_in_range():
	var closest = null
	var min_dist = INF
	var players = get_tree().get_nodes_in_group("player")
	
	for player in players:
		var distance = global_transform.origin.distance_to(player.global_transform.origin)
		if distance < min_dist:
			min_dist = distance
			closest = player
		target = closest
		#target_position(closest.position)
		return true
	return false

@export var state_machine : StateMachine

func _on_navigation_agent_2d_target_reached() -> void:
	state_machine.force_change_state("attack")

func on_death():
	dead.emit(name)
	queue_free()
