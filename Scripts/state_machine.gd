extends Node2D
class_name StateMachine

@export var initial_state: State = null
var default_states : Array = []

var current_state: State
var states: Dictionary = {} 
var disabled = false
var owner_id

@export var character : CharacterBody2D

func get_state():
	return current_state.name.to_lower()

func add_state(state):
	states[state.name.to_lower()] = state

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_transition.connect(change_state)
	set_default_states()
		
	if initial_state:
		initial_state.Enter()
		current_state = initial_state

func _process(delta):
	if current_state:
		current_state.Update(delta)

func _physics_process(delta):
	if current_state:
		current_state.Physics_Update(delta)		

func set_default_states():
	for child in get_children():
		default_states.append(child.name.to_lower())

func remove_custom_states():
	if get_child_count() > default_states.size():
		for child in get_children():
			if child.name.to_lower() not in default_states:
				remove_child(child)

func change_state(state, new_state_name):
	var new_state = states.get(new_state_name.to_lower())
	if disabled && state != new_state:
		return
	if state != current_state:
		return
	
	if !new_state:
		return
	
	if current_state:
		current_state.Exit()
	
	current_state = new_state
	new_state.call_deferred("Enter")
	#new_state.Enter()

func force_change_state(new_state, caller = null, disable = false):
	if disabled:
		return
	
	var newState = states.get(new_state.to_lower())
	if !newState:
		return
	
	if current_state == newState:
		return
	
	if current_state:
		#var exit_callable = Callable(current_state, "Exit")
		#exit_callable.call_deferred()
		if !newState.can_transition_from(current_state.name.to_lower()):
			return
		
		current_state.Exit()
	
	#var enter_callable = Callable(newState, "Enter")
	#enter_callable.call_deferred()

	disabled = disable
	if caller:
		pass
#		Events.state_changed.emit(caller)
	
	current_state = newState
	newState.call_deferred("Enter")
	#newState.Enter()
