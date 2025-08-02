extends State

class_name PlayerState

var state_machine 
@export var player : CharacterBody2D

func _ready() -> void:
	player = get_parent().character

func state_setup():
	state_machine = self.get_parent()

func can_transition_from(_state) -> bool:
	return true
