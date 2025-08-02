extends EnemyState

@export var animation_player : AnimationPlayer
@export var dash_speed : float = 2500.0
@export var charge_time : int = 3
@export var dash_duration : float = 0.5

var dash_direction: Vector2
var is_charging := false
var is_dashing := false
var target_position: Vector2
var dash_time_left: float = 0.0

func Enter():
	if enemy.attack_cd > 0:
		state_transition.emit(self, "tracking")
		return
	
	enemy.attack_cd = enemy.max_attack_cd
	
	# Step 2: Play charge-up animation or start spin
	is_charging = true
	if animation_player:
		animation_player.play("charge_spin")
	await get_tree().create_timer(charge_time).timeout
	
	# Step 1: Record player's current position
	target_position = enemy.target.global_position
	dash_direction = (target_position - enemy.global_position).normalized()
	
	# Step 3: Start dash
	dash_time_left = dash_duration
	is_charging = false
	is_dashing = true
	
func Update(delta):
	if is_dashing:
		enemy.global_position += dash_direction * dash_speed * delta
		dash_time_left -= delta
		
		if dash_time_left <= 0:
			is_dashing = false
			state_transition.emit(self, "tracking")

func Physics_Update(_delta):
	pass

func Exit():
	is_charging = false
	is_dashing = false
