extends Enemy

func _ready() -> void:
	ready()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(50)
