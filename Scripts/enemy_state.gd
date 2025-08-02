extends State

class_name EnemyState

var state_machine 
var enemy : CharacterBody2D

func _ready() -> void:
	enemy = get_parent().character

func state_setup():
	state_machine = self.get_parent()

func can_transition_from(_state) -> bool:
	return true
