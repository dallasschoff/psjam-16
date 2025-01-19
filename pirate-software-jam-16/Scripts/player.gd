extends CharacterBody2D

# Possession variables
var possessCooldownTimer: Timer
var vacateCooldownTimer: Timer
@export var possessCooldown = 1
@export var vacateCooldown = 1.5
var isPossessing = false
var canPossess = true
var isFree = true
var canVacate = false

# Physics variables
var direction
@export var globalMaxSpeed = 120.0
var tempMaxSpeed = 120.0
@export var acceleration = 10.0
@export var deceleration = 4.0
@onready var particles = $CPUParticles2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	animation_tree.active = true
	
	# Setting stamina values
	var maxStamina = $StaminaBar.max_value
	$StaminaBar.value = maxStamina
	
	# Initializing possession timers
	possessCooldownTimer = Timer.new()
	possessCooldownTimer.wait_time = possessCooldown
	possessCooldownTimer.one_shot = true
	possessCooldownTimer.connect("timeout",onPossessCooldownTimeout)
	add_child(possessCooldownTimer)
	vacateCooldownTimer = Timer.new()
	vacateCooldownTimer.wait_time = vacateCooldown
	vacateCooldownTimer.one_shot = true
	vacateCooldownTimer.connect("timeout",onVacateCooldownTimeout)
	add_child(vacateCooldownTimer)


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# Horizontal movement
	var direction_lr := Input.get_axis("left", "right")
	if direction_lr:
		velocity.x = move_toward(velocity.x, direction_lr * tempMaxSpeed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)
	
	# Vertical movement
	var direction_ud := Input.get_axis("up", "down")
	if direction_ud:
		velocity.y = move_toward(velocity.y, direction_ud * tempMaxSpeed, acceleration)
	else:
		velocity.y = move_toward(velocity.y, 0, deceleration)
	
	# Capping speed in case of diagonal movement
	velocity = velocity.limit_length(tempMaxSpeed)
	
	# Defining overall movement direction for animations
	direction = Input.get_vector("left","right","up","down")
	
	move_and_slide()


func _process(delta):
	if Input.is_action_just_pressed("space"):
		particles.emitting = true
		
	if Input.is_action_just_pressed("space") and isFree and canPossess:
		possess()
	
	if Input.is_action_just_pressed("space") and isPossessing and canVacate:
		vacate()
	
	updatePlayerStamina()
	update_animation_parameters()
	

func updatePlayerStamina():
	direction = Input.get_vector("left","right","up","down")
	
	if direction != Vector2.ZERO and isFree:
		$StaminaBar.value -= 1
		

func possess():
	$StaminaBar.value -= 500
	create_tween().tween_property($AnimatedSprite2D, "modulate:a",0,0.5)
	tempMaxSpeed = 0
	isPossessing = true
	isFree = false
	canVacate = false
	vacateCooldownTimer.start()
	print('p')
	
func vacate():
	create_tween().tween_property($AnimatedSprite2D, "modulate:a",1,0.25)
	tempMaxSpeed = globalMaxSpeed
	isPossessing = false
	isFree = true
	canPossess = false
	possessCooldownTimer.start()
	print('v')

func onPossessCooldownTimeout():
	canPossess = true
	print('can p')

func onVacateCooldownTimeout():
	canVacate = true
	print('can v')

func update_animation_parameters():
	animation_tree["parameters/conditions/idle"] = true if velocity == Vector2.ZERO else false
	animation_tree["parameters/conditions/is_walking"] = true if velocity != Vector2.ZERO else false
	
	if (direction != Vector2.ZERO):
		animation_tree["parameters/idle/blend_position"] = direction
		animation_tree["parameters/walk/blend_position"] = direction
