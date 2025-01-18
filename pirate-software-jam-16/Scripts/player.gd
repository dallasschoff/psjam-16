extends CharacterBody2D


const maxSpeed = 100.0
const acceleration = 10.0
const deceleration = 4.0
var looking_left = false
@onready var particles = $CPUParticles2D

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# Horizontal movement
	var direction_lr := Input.get_axis("left", "right")
	if direction_lr:
		velocity.x = move_toward(velocity.x, direction_lr * maxSpeed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)
	
	# Vertical movement
	var direction_ud := Input.get_axis("up", "down")
	if direction_ud:
		velocity.y = move_toward(velocity.y, direction_ud * maxSpeed, acceleration)
	else:
		velocity.y = move_toward(velocity.y, 0, deceleration)
	
	# Player orientation (left v. right facing)
	#if direction_lr < 0 and looking_left == false:
		#scale.x = -1
		#looking_left = true
	#if direction_lr > 0 and looking_left == true:
		#scale.x = -1
		#looking_left = false
	if looking_left:
		if velocity.x < 0:
			scale.x = -1
	#else:
		#scale.x = -1

	move_and_slide()

func _process(delta):
	if Input.is_action_just_pressed("space"):
		particles.emitting = true
