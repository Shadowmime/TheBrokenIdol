extends PlayerState

class_name FastAttack

@export var point_spawn: Marker2D
var proj_scene: PackedScene = preload("res://Character/Projectiles/LightStickAttack.tscn")

signal spawn_note(note: Projectile)

func Enter():
	if player.eattack_cooldown <= 0:
		player.eattack_cooldown = player.EATTACK_COOLDOWN_TIME
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
		var proj = proj_scene.instantiate()
		proj.global_transform = point_spawn.global_transform
		var dir = (player.get_global_mouse_position() - point_spawn.global_position).normalized()
		proj.set_direction(dir, point_spawn.global_position)
		proj.toggle_spin()
		proj.set_scale(Vector2(0.5, 0.5))
		proj.set_speed(2500)
		proj.set_damage(30)
		if !CharacterNerfs.has_nerf("eattack3"):
			proj.is_lightstick()
		#note.set_direction(player.get_look_direction(), self.global_position)
		spawn_note.emit(proj)

func connect_signals():
	spawn_note.connect(player.spawn_note)
