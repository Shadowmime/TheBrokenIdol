extends Node2D

@export var speed := 500.0
var velocity := Vector2.ZERO
var screen_bounds = Rect2(Vector2.ZERO, Vector2(5440, 3240)) # For bounds checking

func _ready() -> void:
	$AnimatedSprite2D.play("default")

func _process(delta):
	position += velocity * delta

	# Despawn if it goes far out of bounds
	if !screen_bounds.grow(200).has_point(position):
		queue_free()

func set_direction(from: Vector2, to: Vector2):
	position = from
	velocity = (to - from).normalized() * speed

func _on_area_entered(area):
	if area.name == "PlayerArea":  # assuming player has Area2D
		area.get_parent().take_damage(50)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(25)
