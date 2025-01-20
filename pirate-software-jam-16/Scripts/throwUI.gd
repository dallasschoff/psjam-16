extends Node2D

@onready var arrow = $Arrow
@onready var controller = $Controller
var angle_to : float

var direction
@export var globalMaxSpeed = 120.0
var tempMaxSpeed = 120.0
@export var acceleration = 10.0
@export var deceleration = 4.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	arrow.look_at(controller.global_position)
	controller.look_at(global_position)
	#angle_to = arrow.get_angle_to(dot.global_position)
	#arrow.rotation = angle_to - 90
	#print(angle_to)

	
	
func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# Horizontal movement
	var direction_lr := Input.get_axis("left", "right")
	if direction_lr:
		controller.velocity.x = move_toward(controller.velocity.x, direction_lr * tempMaxSpeed, acceleration)
	else:
		controller.velocity.x = move_toward(controller.velocity.x, 0, deceleration)
	
	# Vertical movement
	var direction_ud := Input.get_axis("up", "down")
	if direction_ud:
		controller.velocity.y = move_toward(controller.velocity.y, direction_ud * tempMaxSpeed, acceleration)
	else:
		controller.velocity.y = move_toward(controller.velocity.y, 0, deceleration)
	
	# Capping speed in case of diagonal movement
	controller.velocity = controller.velocity.limit_length(tempMaxSpeed)
	
	# Defining overall movement direction for animations
	direction = Input.get_vector("left","right","up","down")
	
	controller.move_and_slide()
