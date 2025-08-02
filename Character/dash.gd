extends PlayerState

class_name Dash

const DASH_MULTIPLIER := 20

func Enter():
	if player.dash_cooldown <= 0:
		player.set_speed_multiplier(DASH_MULTIPLIER)
		player.dash_cooldown = player.DASH_COOLDOWN_TIME
	else:
		state_transition.emit(self, "idle")
	
func Exit():
	player.set_speed_multiplier()
	player.is_dash = false

func Update(_delta: float):
	await get_tree().create_timer(0.15).timeout
	state_transition.emit(self, "idle")

func Physics_Update(_delta: float):
	pass
