extends EnemyState

#@export var animation_player : AnimationPlayer

func Enter():
	if enemy.attack_cd > 0:
		state_transition.emit(self, "tracking")
	else:
		enemy.attack_cd = enemy.max_attack_cd
		print("attacking")
		#animation_player.play("basic_attack")
	
func Exit():
	pass

func Update(_delta: float):
	await get_tree().create_timer(2).timeout
	state_transition.emit(self, "tracking")

func Physics_Update(_delta: float):
	pass
