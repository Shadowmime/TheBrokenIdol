extends Node

var first_tree = true
var loop = -1
var nerfs = []

func add_nerf(nerf):
	nerfs.append(nerf)

func has_nerf(nerf):
	if nerf in nerfs:
		return true
	else:
		return false

func get_loop():
	loop += 1
	return loop

var points_needed = [0, 5]
func get_points_needed():
	return points_needed[loop]
