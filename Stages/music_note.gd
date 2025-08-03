extends Projectile

func set_sprite(is_single = true):
	if is_single:
		$Sprite2D.texture = load("res://Character/SkillTree/Icons/MusicNote_SingleBlue.png")
		set_damage(10)
	else:
		$Sprite2D.texture = load("res://Character/SkillTree/Icons/MusicNote_DoubleBlue.png")
		set_damage(20)
