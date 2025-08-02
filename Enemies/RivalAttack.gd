extends EnemyState

#@export var animation_player : AnimationPlayer
@export var attack : AnimatedSprite2D
@export var anim_player : AnimationPlayer

func Enter():
	if enemy.attack_cd > 0:
		state_transition.emit(self, "tracking")
	else:
		enemy.attack_cd = enemy.max_attack_cd
		
		# rival attack here
		attack.play()
		anim_player.play("attack")
	
func Exit():
	attack.pause()
	anim_player.play("idle")

func Update(_delta: float):
	await get_tree().create_timer(0.6666).timeout
	state_transition.emit(self, "tracking")

func Physics_Update(_delta: float):
	pass
