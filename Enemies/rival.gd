extends Enemy

func play_animations():
	sprite.play("default")
	animation_player.play("idle")

func deal_damage():
	if player:
		player.take_damage(40)

var player : Character = null
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
