extends PlayerState

class_name Idle

func Enter():
	pass
	
func Exit():
	pass

func Update(_delta: float):
	if Input.is_action_just_pressed("attack") && !CharacterNerfs.has_nerf("attack1"):
		state_transition.emit(self, "attack")
	#elif Input.is_action_just_pressed("shield"):
		#state_transition.emit(self, "shield")
	elif Input.is_action_just_pressed("dash"):
		state_transition.emit(self, "dash")
	elif Input.is_action_just_pressed("fast_attack"):
		state_transition.emit(self, "fastattack")
	#elif Input.is_action_just_pressed("interact") and player.can_talk:
		#state_transition.emit(self, "npctalk")

func Physics_Update(_delta: float):
	pass
