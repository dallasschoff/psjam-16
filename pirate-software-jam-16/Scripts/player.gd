extends CharacterBody2D
class_name Player

# Possession variables
var possessCooldownTimer: Timer
var vacateCooldownTimer: Timer
@export var possessCooldown = 1
@export var vacateCooldown = 1.5
var isPossessing = false
var possessAvailable = true
var isFree = true
var vacateAvailable = false
var canPossess: bool
var cannotPossess: bool

# Physics variables
var direction
@export var globalMaxSpeed = 120.0
var tempMaxSpeed = 120.0
@export var acceleration = 10.0
@export var deceleration = 4.0

# Node tree
@onready var particlesOut = $CPUParticles2D
@onready var particlesIn = $CPUParticles2D2
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var text_sprite = $Text
var interactionArea : Area2D

func _ready():
	SignalBus.can_possess.connect(_can_possess) #Emitted by interactionArea
	
	Global.player = self
	Global.stamina = $StaminaBar
	animation_tree.active = true
	text_sprite.modulate = Color(1,1,1,0)

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

func _process(delta):
	#Possessing
	if Input.is_action_just_pressed("space")\
	 and isFree and possessAvailable and canPossess:
		particlesIn.emitting = true
		possess()
	
	if Input.is_action_just_pressed("space")\
	 and isPossessing and vacateAvailable:
		particlesOut.emitting = true
		vacate()
	
	if interactionArea != null and isPossessing and vacateAvailable:
		global_position = interactionArea.global_position
		
	updatePlayerStamina()
	update_animation_parameters()

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
	
	if Global.stamina.value <= 0:
		velocity = Vector2.ZERO

func updatePlayerStamina():
	direction = Input.get_vector("left","right","up","down")
	
	if direction != Vector2.ZERO and isFree:
		$StaminaBar.value -= 1
		

func possess():
	# Play audio
	$PossessSound.play()
	
	interactionArea.root._possessed()
	#Disappear text
	create_tween().tween_property(text_sprite, "modulate:a",0,0.5)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", (interactionArea.global_position), 0.4)
	create_tween().tween_property($AnimatedSprite2D, "modulate:a",0,0.5)
	tempMaxSpeed = 0
	isPossessing = true
	isFree = false
	vacateAvailable = false
	vacateCooldownTimer.start()

func vacate():
	# Play audio
	$VacateSound.play()
	
	interactionArea.root._vacated()
	create_tween().tween_property($AnimatedSprite2D, "modulate:a",1,0.25)
	tempMaxSpeed = globalMaxSpeed
	isPossessing = false
	isFree = true
	possessAvailable = false
	canPossess = true
	possessCooldownTimer.start()
	#Moves the player up when vacating
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", (global_position+Vector2(-5,-5)), 0.4)

func onPossessCooldownTimeout():
	possessAvailable = true

func onVacateCooldownTimeout():
	vacateAvailable = true

func _can_possess(area):
	if !isPossessing:
		canPossess = true
		interactionArea = area
		#Appear text
		create_tween().tween_property(text_sprite, "modulate:a",1,0.25)

func _cannot_possess():
	#This needs changes, since it is called whenever you leave the interactionArea.
	#If you leave one while entering another, you'll lose the ability to possess either
	canPossess = false
	#Disappear text
	create_tween().tween_property(text_sprite, "modulate:a",0,0.5)


func update_animation_parameters():
	animation_tree["parameters/conditions/idle"] = true if velocity == Vector2.ZERO else false
	animation_tree["parameters/conditions/is_walking"] = true if velocity != Vector2.ZERO else false
	
	if (direction != Vector2.ZERO):
		animation_tree["parameters/idle/blend_position"] = direction
		animation_tree["parameters/walk/blend_position"] = direction
