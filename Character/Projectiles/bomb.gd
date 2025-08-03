extends Node2D
class_name Bomb

@export var pulling_range: Area2D

var pull_strength = 1000

func _process(delta):
	if vortex:
		for body in enemies_pulling_range:
			var dir = (global_position - body.global_position).normalized()
			body.global_position += dir * pull_strength * delta
				# Apply a "slowed" status effect with a timer if needed

@export var damage_range: Area2D
@export var animation_player: AnimationPlayer
@export var damage_amount: int = 20
@export var duration: float = 3.0
@export var slow_duration: float = 3.0
var damage_mod = 1
var vortex = true

func _ready():
	if CharacterNerfs.has_nerf("qattack4"):
		animation_player.play("explode") # You create this animation (e.g., 3 key moments for damage)
		vortex = false
	else:
		animation_player.play("suck")
		vortex = true

	# Clean up after explosion duration
	await get_tree().create_timer(duration).timeout
	queue_free()

# Called by AnimationPlayer during frames
func _on_damage_tick():
	for body in enemies_damage_range:
		if body.has_method("take_damage"):
			body.take_damage(damage_amount * damage_mod)
		if body.has_method("set_speed_mult"):
			if !CharacterNerfs.has_nerf("qattack3"):
				body.set_speed_mult(0.5)


var enemies_damage_range = []
func _on_damagerange_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") or body.is_in_group("boss_enemy"):
		enemies_damage_range.append(body)

func _on_damagerange_body_exited(body: Node2D) -> void:
	if body in enemies_damage_range:
		enemies_damage_range.erase(body)

var enemies_pulling_range = []
func _on_pullingrange_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") or body.is_in_group("boss_enemy"):
		enemies_pulling_range.append(body)

func _on_pullingrange_body_exited(body: Node2D) -> void:
	if body in enemies_pulling_range:
		enemies_pulling_range.erase(body)
