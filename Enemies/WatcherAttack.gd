extends EnemyState

class_name watcherattack

@export var point_spawn: Marker2D
var proj_scene: PackedScene = preload("res://Character/Projectiles/LightStickAttack.tscn")

signal spawn_note(note: Projectile)

func Enter():
	attack()
	await get_tree().create_timer(3).timeout
	state_transition.emit(self, "idle")
	
func Exit():
	pass

func Update(_delta: float):
	pass

func Physics_Update(_delta: float):
	pass

func attack():
	var proj = proj_scene.instantiate()
	proj.global_transform = point_spawn.global_transform
	var dir = (enemy.target.global_position - point_spawn.global_position).normalized()
	proj.set_direction(dir, point_spawn.global_position)
	proj.toggle_spin()
	proj.set_scale(Vector2(0.5, 0.5))
	proj.set_speed(2500)
	proj.is_lightstick()
	proj.is_enemy()
	proj.set_damage(70)
	#note.set_direction(player.get_look_direction(), self.global_position)
	spawn_note.emit(proj)
