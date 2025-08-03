extends Enemy

func _ready() -> void:
	speed = 150
	$AnimatedSprite2D.play("default")
	ready()

signal spawn_note(note: Projectile)
func _on_attack_spawn_note(note: Projectile) -> void:
	spawn_note.emit(note)
