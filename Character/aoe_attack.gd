extends PlayerState

class_name AOE_Attack

@export var point_spawn: Marker2D

@export var bomb_scene: PackedScene

signal spawn_bomb(bomb: Bomb)

func Enter():
	if player.qattack_cooldown <= 0:
		player.qattack_cooldown = player.QATTACK_COOLDOWN_TIME
	else:
		state_transition.emit(self, "idle")
		return
	attack()
	await get_tree().create_timer(0.5).timeout
	state_transition.emit(self, "idle")
	
func Exit():
	pass

func Update(_delta: float):
	pass

func Physics_Update(_delta: float):
	pass

func attack():
	if not player.is_attacking():
		var bomb = bomb_scene.instantiate()
		bomb.global_position = point_spawn.global_position
		spawn_bomb.emit(bomb)

func connect_signals():
	spawn_bomb.connect(player.spawn_bomb)
