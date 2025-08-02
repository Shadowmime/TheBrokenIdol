extends PlayerState

class_name IdleM

func Enter():
	pass
	
func Exit():
	pass

func Update(_delta: float):
	if Input.is_action_just_pressed("dash") && !CharacterNerfs.has_nerf("dash1"):
		state_transition.emit(self, "dash")

func Physics_Update(_delta: float):
	pass
