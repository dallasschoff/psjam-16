extends Node
class_name StateMachine

@export var initial_state: State
@onready var alert_state_scene: PackedScene = load("res://Scenes/States/Alert.tscn")

var current_state: State
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_child_transition)
	if initial_state:
		initial_state.enter()
		current_state = initial_state
	
func _process(delta):
	if current_state:
		current_state.update(delta)
		
func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func on_child_transition(state, new_state_name):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
		
	if current_state:
		current_state.exit()
	print("Transitioning to " + new_state_name)
	new_state.enter()
	current_state = new_state

func _create_alert_state():
	var alert_state = alert_state_scene.instantiate()
	add_child(alert_state)
	states[alert_state.name.to_lower()] = alert_state
	alert_state.transitioned.connect(on_child_transition)
	alert_state.enter()
	current_state = alert_state
