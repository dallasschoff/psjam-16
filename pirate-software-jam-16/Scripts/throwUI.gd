extends Node2D

@onready var arrow = $Arrow
@onready var controller = $Controller
@onready var dot = $Dot

@export var scalingSpeed = 1.5
@export var radialSpeed = 10.0
@export var innerLimit = 10
@export var outerLimit = 40

var angle = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	arrow.look_at(controller.global_position)
	controller.look_at(global_position)
	#Gets arrow rotation less than 360, to be used for throw angle
	if arrow.rotation_degrees >= 0: 
		Global.throw_angle = (fmod(arrow.rotation_degrees, 360.0))
	else:
		Global.throw_angle = (fmod(arrow.rotation_degrees,-360.0))


func _physics_process(delta: float) -> void:
	# Getting parameters from relative positions of dot and controller
	var distanceFrom = controller.position.distance_to(dot.position)
	var directionFrom = (controller.position - dot.position).normalized()
	
	# Radial movement
	var direction_lr := Input.get_axis("left", "right")
	if direction_lr:
		# Calculating frame-adjusted velocity
		angle -= direction_lr * radialSpeed * get_process_delta_time()
		
		# Setting position
		controller.position.x = distanceFrom * cos(angle)
		controller.position.y = distanceFrom * sin(angle)
	
	# Scaling movement
	var direction_ud := Input.get_axis("up", "down")
	if direction_ud:
		# Setting position
		controller.position.x += direction_ud * directionFrom.x * scalingSpeed
		controller.position.y += direction_ud * directionFrom.y * scalingSpeed
	
	# Clamping scaling 
	if controller.position.length() < innerLimit:
		controller.position = controller.position.normalized() * innerLimit
	controller.position = controller.position.limit_length(outerLimit)
	
	# Updating throwing strength
	#Global.throwStrength = (controller.position.length() - innerLimit)/(outerLimit-innerLimit)
	Global.throwStrength = controller.position.length() / outerLimit
	
	controller.move_and_slide()
