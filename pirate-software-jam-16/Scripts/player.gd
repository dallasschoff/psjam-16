extends CharacterBody2D


const SPEED = 100.0
var looking_left = false
@onready var particles = $CPUParticles2D

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction_lr := Input.get_axis("left", "right")
	if direction_lr:
		velocity.x = direction_lr * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	var direction_ud := Input.get_axis("up", "down")
	if direction_ud:
		velocity.y = direction_ud * SPEED
	else:
		velocity.y = move_toward(velocity.x, 0, SPEED)
	# Get input direction and handle player flipping
	if direction_lr < 0 and looking_left == false:
		scale.x = -1
		looking_left = true
	if direction_lr > 0 and looking_left == true:
		scale.x = -1
		looking_left = false

	move_and_slide()

func _process(delta):
	if Input.is_action_just_pressed("space"):
		particles.emitting = true
