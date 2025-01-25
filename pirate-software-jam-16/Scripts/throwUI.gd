extends Node2D

@onready var arrow = $Arrow
@onready var controller = $Controller
@onready var dot = $Dot
var angle_to : float

var direction
@export var globalMaxSpeed = 120.0
var tempMaxSpeed = 120.0
@export var acceleration = 10.0
@export var deceleration = 4.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	remove_child($StaticBody2D)
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	arrow.look_at(controller.global_position)
	controller.look_at(global_position)
	#Gets arrow rotation less than 360, to be used for throw angle
	if arrow.rotation_degrees >= 0: 
		Global.throw_angle = (fmod(arrow.rotation_degrees, 360.0))
		#print(fmod(arrow.rotation_degrees, 360.0))
	else:
		Global.throw_angle = (fmod(arrow.rotation_degrees,-360.0))
		#print(fmod(arrow.rotation_degrees, -360.0))
	
func _physics_process(delta: float) -> void:
	# Getting distance from center of body
	var distanceFrom = controller.position.distance_to(dot.position)
	var angleFrom = rad_to_deg(controller.position.angle_to_point(dot.position))
	#print(distanceFrom)
	#print(angleFrom)
	
	var directionFrom = controller.position - dot.position
	var angularMovementDirection = directionFrom.rotated(PI/2)
	print(angularMovementDirection)
	
	# Get the input direction and handle the movement/deceleration.
	# Horizontal movement
	var anglingX = 0
	var anglingY = 0
	var direction_lr := Input.get_axis("left", "right")
	if direction_lr:
		#controller.velocity.x = move_toward(controller.velocity.x, direction_lr * tempMaxSpeed, acceleration)
		anglingY = move_toward(controller.velocity.y, direction_lr*angularMovementDirection.normalized().y * tempMaxSpeed, acceleration)
		anglingX = move_toward(controller.velocity.x, direction_lr*angularMovementDirection.normalized().x * tempMaxSpeed, acceleration)
	else:
		#controller.velocity.x = move_toward(controller.velocity.x, 0, deceleration)
		#controller.velocity.x = move_toward(controller.velocity.x, 0, deceleration)
		#controller.velocity.y = move_toward(controller.velocity.y, 0, acceleration)
		pass
	
	# Vertical movement
	var scalingX = 0
	var scalingY = 0
	var direction_ud := Input.get_axis("up", "down")
	if direction_ud:
		#controller.velocity.y = move_toward(controller.velocity.y, direction_ud * tempMaxSpeed, acceleration)
		scalingX = move_toward(controller.velocity.x, -direction_ud*directionFrom.normalized().x * tempMaxSpeed, acceleration)
		scalingY = move_toward(controller.velocity.y, -direction_ud*directionFrom.normalized().y * tempMaxSpeed, acceleration)
		#controller.velocity.y = move_toward(controller.velocity.y, 0, acceleration)
	else:
		#controller.velocity.y = move_toward(controller.velocity.y, 0, deceleration)
		#controller.velocity.x = move_toward(controller.velocity.y, 0, deceleration)
		#controller.velocity.y = move_toward(controller.velocity.y, 0, deceleration)
		pass
	
	# Summing velocity vectors in case of both simultaneous rotation and scaling
	controller.velocity.x = anglingX + scalingX
	controller.velocity.y = anglingY + scalingY
	
	# Capping speed in case of diagonal movement
	controller.velocity = controller.velocity.limit_length(tempMaxSpeed)
	
	# Defining overall movement direction for animations
	direction = Input.get_vector("left","right","up","down")
	
	controller.move_and_slide()
