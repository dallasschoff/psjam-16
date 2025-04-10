extends Node2D

@onready var arrow = $Arrow
@onready var controller = $Controller
@onready var dot = $Dot

@export var scalingSpeed = 1.5
@export var radialSpeed = 10.0
@export var innerLimit = 10
@export var outerLimit = 40

@onready var main_menu = Global.MainMenu
@onready var previousDistanceFrom = controller.position.distance_to(dot.position)

var value1
var value2
var t = 0.0

var angle = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	arrow.look_at(controller.global_position)
	controller.look_at(global_position)
	#Gets arrow rotation less than 360, to be used for throw angle
	if arrow.rotation_degrees >= 0: 
		Global.throw_angle = (fmod(arrow.rotation_degrees, 360.0))
	else:
		Global.throw_angle = (fmod(arrow.rotation_degrees,-360.0))

func _physics_process(delta: float) -> void:
	if main_menu.mobileControls == true:
		_mobile_throw_ui(delta)
	else:
		_pc_throw_ui(delta)

func _pc_throw_ui(_delta:float) -> void:
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
	if Input.is_action_pressed("enter"):
		# Setting position
		controller.position.x += 1 * directionFrom.x * scalingSpeed
		controller.position.y += 1 * directionFrom.y * scalingSpeed

	# Clamping scaling 
	if controller.position.length() < innerLimit:
		controller.position = controller.position.normalized() * innerLimit
	controller.position = controller.position.limit_length(outerLimit)

	# Updating throwing strength
	#Global.throwStrength = (controller.position.length() - innerLimit)/(outerLimit-innerLimit)
	Global.throwStrength = controller.position.length() / outerLimit

	controller.move_and_slide()

	if Input.is_action_just_released("enter"):
		# Resetting position
		controller.position = controller.position.normalized() * innerLimit

func _mobile_throw_ui(delta:float) -> void:
	Global.throwStrength = controller.position.length() / outerLimit
	var direction = Vector2(0,0)
	direction.x = -Input.get_action_strength("left") + Input.get_action_strength("right")
	direction.y = +Input.get_action_strength("down") - Input.get_action_strength("up")
	#controller.position = direction * outerLimit ##Throw UI will immediately follow the ThrowJS
	var distanceFrom = controller.position.distance_to(dot.position)
	if distanceFrom < previousDistanceFrom:
		#Throw UI will be slightly behind, giving a pulling effect
		value1 = controller.position
		value2 = direction * outerLimit
		t = 40.0 * delta
		controller.position = value1.lerp(value2, t)
	else:
		#Throw UI will be slightly behind, giving a pulling effect
		value1 = controller.position
		value2 = direction * outerLimit
		t = 50.0 * delta
		controller.position = value1.lerp(value2, t)
