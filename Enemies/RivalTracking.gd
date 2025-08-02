extends EnemyState
class_name RivalTracking

func Enter():
	pass
	
func Exit():
	pass

func Update(_delta: float):
	pass

func Physics_Update(delta: float):
	enemy.target_position(enemy.target.position)
	
	var next_location = enemy.nav.get_next_path_position()
	var current_location = enemy.global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * enemy.speed
	enemy.velocity.x = new_velocity.x
	enemy.velocity.y = new_velocity.y

	enemy.move_and_slide()
