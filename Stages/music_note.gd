extends Projectile

func set_sprite(is_single = true):
	if is_single:
		$Sprite2D.texture = load("res://Character/Projectiles/Single_Note.png")
		set_damage(10)
	else:
		$Sprite2D.texture = load("res://Character/Projectiles/Double_Note.png")
		set_damage(20)
