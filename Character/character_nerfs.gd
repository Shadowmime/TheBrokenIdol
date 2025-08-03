extends Node

var first_tree = true
var loop = 0
var nerfs = []

func add_nerf(nerf):
	nerfs.append(nerf)

func has_nerf(nerf):
	if nerf in nerfs:
		return true
	else:
		return false

func func_loop():
	loop += 1
	return loop

func is_finished():
	if loop == points_needed.size() && campaign:
		return true
	return false

var points_needed = [0, 10, 20, 30, 40]
func get_points_needed():
	return points_needed[func_loop()]

# Campaign vs Freeplay mode
# Campaign theres 5 waves where you have to delete x amount of skills
# Freeplay its a high scoring mode
var campaign = true
var score = 0

var game_over = false
