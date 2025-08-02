extends EnemyState
class_name RivalIdle

func Enter():
	pass
	
func Exit():
	pass

func Update(_delta: float):
	if enemy.get_player_in_range():
		state_transition.emit(self, "tracking")

func Physics_Update(_delta: float):
	pass
