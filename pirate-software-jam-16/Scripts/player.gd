extends CharacterBody2D

var direction
const maxSpeed = 120.0
const acceleration = 10.0
const deceleration = 4.0
var looking_left = false
@onready var particles = $CPUParticles2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
	animation_tree.active = true


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
	
	# Capping speed in case of diagonal movement
	velocity = velocity.limit_length(maxSpeed)
	
	# Defining overall movement direction for animations
	var direction = velocity.normalized()
	
	# Player orientation (left v. right facing)
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
		
	update_animation_parameters()


func update_animation_parameters():
	animation_tree["parameters/conditions/idle"] = true if velocity == Vector2.ZERO else false
	animation_tree["parameters/conditions/is_walking"] = true if velocity != Vector2.ZERO else false
	
	if (direction != Vector2.ZERO):
		animation_tree["parameters/idle/blend_position"] = direction
		animation_tree["parameters/walk/blend_position"] = direction
	
	
	
	
	
	
	
	
