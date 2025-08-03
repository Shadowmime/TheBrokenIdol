extends Enemy

func _ready() -> void:
	speed = 100
	ready()

signal spawn_note(note: Projectile)
func _on_attack_spawn_note(note: Projectile) -> void:
	spawn_note.emit(note)
