extends PlayerState

class_name Attack

@export var point_spawn: Marker2D
var note_scene: PackedScene = preload("res://Stages/music_note.tscn")

var combo_count := 0
var last_attack_time := 0.0
const COMBO_RESET_TIME := 3.0

signal spawn_note(note: Projectile)

func Enter():
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
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_attack_time > COMBO_RESET_TIME:
		combo_count = 0
	
	last_attack_time = current_time
	combo_count += 1
	
	if not player.is_attacking():
		var note = note_scene.instantiate()
		note.global_transform = point_spawn.global_transform
		var dir = (player.get_global_mouse_position() - point_spawn.global_position).normalized()
		note.set_direction(dir, point_spawn.global_position)
		note.toggle_wave()
		if dir.x < 0:
			note.scale = Vector2(-2, -2)
		else:
			note.scale = Vector2(2, 2)
		
		# Set sprite based on combo: double note on 3rd hit
		if combo_count == 3:
			note.set_sprite(false)  # double note
			combo_count = 0  # reset combo
		else:
			note.set_sprite(true)  # single note
		
		spawn_note.emit(note)

func connect_signals():
	spawn_note.connect(player.spawn_note)
