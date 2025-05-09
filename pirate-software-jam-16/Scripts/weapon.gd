extends Node2D

class_name Weapon

@onready var anim_player = $AnimationPlayer
@onready var animated_sprite = $AnimatedSprite2D
@onready var shadow = $Shadow
@onready var possess_particles = $AnimatedSprite2D/PossessParticles
@onready var weapon_smear = $AnimatedSprite2D/WeaponSmear
@onready var throwUI = $ThrowUI
@onready var hitbox: Area2D = $AnimatedSprite2D/Hitbox
@export var throwRatioVH = 0.6

@onready var confusion_box_scene: PackedScene = load("res://Scenes/ConfusionBox.tscn")

var possessed = false
var thrown : bool = false
var wielded : bool #Use "wielder != null" instead
var dropped : bool
var swing_cooldown: Timer
var swingAvailable: bool = false
var throw_cooldown: Timer
var throwAvailable: bool = false
var flash_and_grow_timer: Timer
var first_action_timer: Timer
var weapon_flash_and_grow: bool = false
var direction
@export var tug: Vector2
@export var wielder : Orc
@export var animated_sprite_rotation : float
@export var flip_left : bool = false

#Tweens
var sizeTween
var modulateTween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Weapons")
	
	SignalBus.possessed.connect(_possessed) #Emitted by player
	SignalBus.vacated.connect(_vacated) #Emitted by player
	
	swing_cooldown = Timer.new()
	swing_cooldown.wait_time = 0.4
	swing_cooldown.one_shot = true
	swing_cooldown.connect("timeout", _reset_swing)
	add_child(swing_cooldown)
	
	throw_cooldown = Timer.new()
	throw_cooldown.wait_time = 1.0
	throw_cooldown.one_shot = true
	throw_cooldown.connect("timeout", _reset_throw)
	add_child(throw_cooldown)
	
	flash_and_grow_timer = Timer.new()
	flash_and_grow_timer.wait_time = 1.0
	flash_and_grow_timer.one_shot = false
	flash_and_grow_timer.connect("timeout", _weapon_flash_and_grow)
	add_child(flash_and_grow_timer)
	
	first_action_timer = Timer.new()
	first_action_timer.wait_time = 1.0
	first_action_timer.one_shot = true
	first_action_timer.connect("timeout", _reset_swing)
	add_child(first_action_timer)
	
	if wielder != null:
		hitbox.wielder = wielder
		wielder.weapon = self
		wielder._weapon_drag(position + wielder._weapon_offsets())
	if flip_left == true: 
		animated_sprite.scale.x = -1
		shadow.scale.x = -1
	if animated_sprite_rotation != null:
		animated_sprite.rotation_degrees = animated_sprite_rotation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if possessed:
		##Throwing
		if Input.is_action_just_released("enter") and throwAvailable:
			_throw()
			swingAvailable = false
			swing_cooldown.start()
			throwAvailable = false
			throw_cooldown.start()
		##swinging
		if not Input.is_action_pressed("enter") and swingAvailable and throwAvailable:
			if Input.is_action_pressed("left"):
				_undo_spins()
				_swing_left()
				direction = Vector2(-1, 0)
			if Input.is_action_pressed("right"):
				_undo_spins()
				_swing_right()
				direction = Vector2(1, 0)
			if Input.is_action_pressed("up"):
				_undo_spins()
				_swing_up()
				direction = Vector2(0, -1)
			if Input.is_action_pressed("down"):
				_undo_spins()
				_swing_down()
				direction = Vector2(0, 1)
			##Weapon smear and stamina
			if (Input.is_action_just_released("left") or Input.is_action_just_released("right")
			or Input.is_action_just_released("down") or Input.is_action_just_released("up")):
				_activate_swing_hitbox()
				_create_confusion("default")
				swingAvailable = false
				throwAvailable = false
				swing_cooldown.start()
				if get_parent().handled_win == false:
					Global.stamina.value -= 500
				await get_tree().create_timer(0.1).timeout
				weapon_smear.visible = true
				await get_tree().create_timer(0.1).timeout
				weapon_smear.visible = false
		if Global.stamina.value <= 0:
			swingAvailable = false
			throwAvailable = false
		
		if Input.is_action_pressed("enter") and throwAvailable:
			_throwing()
		else:
			$ThrowUI.visible = false
		
		#Updates the wielder's location when a swing happens and the weapon has not been thrown yet
		if wielder != null and not thrown:
			wielder._weapon_drag(position + animated_sprite.position + wielder._weapon_offsets())
	
	#Updates weapon to stay in wielder's hand when not possessed
	if wielder != null and not possessed:
		global_position = wielder.global_position - wielder._weapon_offsets()
		if wielder.left_handed:
			match wielder.direction:
				##Left
				Vector2(-1, 0):
					z_index = 0
					animated_sprite.scale.x = -1
					animated_sprite.rotation_degrees = -90
					shadow.scale.x = -1
					shadow.rotation_degrees = -90
				##Right
				Vector2(1, 0):
					z_index = 0
					animated_sprite.scale.x = 1
					animated_sprite.rotation_degrees = 90
					shadow.scale.x = 1
				##Up
				Vector2(0, -1):
					z_index = -1
					animated_sprite.scale.x = 1
					animated_sprite.rotation_degrees = 90
					shadow.scale.x = 1
				##Down
				Vector2(0, 1):
					z_index = 0
					animated_sprite.scale.x = -1
					animated_sprite.rotation_degrees = -90
					shadow.scale.x = -1
					shadow.rotation_degrees = -90
		else:
			match wielder.direction:
				##Left
				Vector2(-1, 0):
					z_index = 0
					animated_sprite.scale.x = -1
					animated_sprite.rotation_degrees = -90
					shadow.scale.x = -1
					shadow.rotation_degrees = -90
				##Right
				Vector2(1, 0):
					z_index = 0
					animated_sprite.scale.x = 1
					animated_sprite.rotation_degrees = 90
					shadow.scale.x = 1
					shadow.rotation_degrees = 90
				##Up
				Vector2(0, -1):
					z_index = -1
					animated_sprite.scale.x = 1
					animated_sprite.rotation_degrees = -180
					shadow.scale.x = 1
					shadow.rotation_degrees = -180
				##Down
				Vector2(0, 1):
					z_index = 0
					animated_sprite.scale.x = 1
					animated_sprite.rotation_degrees = 90
					shadow.scale.x = 1
					shadow.rotation_degrees = 90
	
	#Keeps throw UI with weapon. 
	throwUI.global_position = animated_sprite.global_position + Vector2(6, -5)
	#Moves shadow with weapon
	shadow.global_position = animated_sprite.global_position + Vector2(6, 9)
	#Rotates shadow with weapon
	shadow.rotation = animated_sprite.rotation

func _swing_left():
	# Play audio
	$SwingSound.play()
	
	z_index = 0
	#Flip things left if pressed left
	animated_sprite.scale.x = -1
	shadow.scale.x = -1
	##swing left
	var tween = get_tree().create_tween()
	tween.tween_property(animated_sprite, "rotation_degrees", 100, 0.1)
	tween.tween_property(animated_sprite, "rotation_degrees", -120, 0.08)
	tween.tween_property(animated_sprite, "rotation_degrees", 0, 0.5)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(0,0)), 0.05)
	tween2.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(-10,0)), 0.08)
	tug = Vector2(-10,0)

func _swing_right():
	# Play audio
	$SwingSound.play()
	
	z_index = 0
	#Flip things right if pressed right
	animated_sprite.scale.x = 1
	shadow.scale.x = 1
	##swing right
	var tween = get_tree().create_tween()
	tween.tween_property(animated_sprite, "rotation_degrees", -100, 0.1)
	tween.tween_property(animated_sprite, "rotation_degrees", 120, 0.08)
	tween.tween_property(animated_sprite, "rotation_degrees", 0, 0.5)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(0,0)), 0.05)
	tween2.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(10,0)), 0.08)
	tug = Vector2(10,0)

func _swing_up():
	# Play audio
	$SwingSound.play()
	
	z_index = -1
	##Left handed up swing needs different behavior
	if wielder != null and wielder.left_handed:
		#Flip things right if pressed up
		animated_sprite.scale.x = -1
		shadow.scale.x = -1
		##swing up
		var tween = get_tree().create_tween()
		tween.tween_property(animated_sprite, "rotation_degrees", 190, 0.1)
		tween.tween_property(animated_sprite, "rotation_degrees", -50, 0.08)
		tween.tween_property(animated_sprite, "rotation_degrees", 90, 0.5)
		var tween2 = get_tree().create_tween()
		tween2.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(0,0)), 0.05)
		tween2.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(0,-10)), 0.08)
		tug = Vector2(0,-10)
	##Right handed up swing
	else:
		#Flip things right if pressed up
		animated_sprite.scale.x = 1
		shadow.scale.x = 1
		##swing up
		var tween = get_tree().create_tween()
		tween.tween_property(animated_sprite, "rotation_degrees", -190, 0.1)
		tween.tween_property(animated_sprite, "rotation_degrees", 30, 0.08)
		tween.tween_property(animated_sprite, "rotation_degrees", -90, 0.5)
		var tween2 = get_tree().create_tween()
		tween2.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(0,0)), 0.05)
		tween2.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(0,-10)), 0.08)
		tug = Vector2(0,-10)

func _swing_down():
	# Play audio
	$SwingSound.play()
	
	z_index = 0
	##Left handed down swing needs different behavior
	if wielder != null and wielder.left_handed:
		#Flip things right if pressed down
		animated_sprite.scale.x = -1
		shadow.scale.x = -1
		##swing down
		var tween = get_tree().create_tween()
		tween.tween_property(animated_sprite, "rotation_degrees", 20, 0.1)
		tween.tween_property(animated_sprite, "rotation_degrees", -230, 0.08)
		tween.tween_property(animated_sprite, "rotation_degrees", 0, 0.5)
		var tween2 = get_tree().create_tween()
		tween2.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(0,0)), 0.05)
		tween2.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(0,10)), 0.08)
		tug = Vector2(0,10)
	else:
		#Flip things right if pressed down
		animated_sprite.scale.x = 1
		shadow.scale.x = 1
		##swing down
		var tween = get_tree().create_tween()
		tween.tween_property(animated_sprite, "rotation_degrees", -20, 0.1)
		tween.tween_property(animated_sprite, "rotation_degrees", 210, 0.08)
		tween.tween_property(animated_sprite, "rotation_degrees", 0, 0.5)
		var tween2 = get_tree().create_tween()
		tween2.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(0,0)), 0.05)
		tween2.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(0,10)), 0.08)
		tug = Vector2(0,10)

func _reset_swing():
	if Global.stamina.value > 0:
		swingAvailable = true
		throwAvailable = true
	
func _reset_throw():
	if Global.stamina.value > 0:
		throwAvailable = true
		swingAvailable = true

##Possession functions##
func _picked_up(new_wielder):
	wielder = new_wielder
	wielder.weapon = self
	wielder.dropped_weapon = null
	hitbox.wielder = wielder

func _unassign_wielder():
	wielder.dropped_weapon = self
	wielder.weapon = null
	wielder = null
	hitbox.wielder = null

func _can_be_possessed(): #Called by interactionArea.gd
	if possessed == false:
		#Make weapon flash and grow
		flash_and_grow_timer.start()
		_weapon_flash_and_grow()
		#anim_player.play("can_be_possessed")

func _cannot_be_possessed(): #Called by interactionArea.gd
	if possessed == false:
		#Stop weapon flash and grow
		flash_and_grow_timer.stop()
		_reset_weapon_flash_and_grow()
		#anim_player.play("stop_fx")
		if sizeTween:
			sizeTween.kill()
		if modulateTween:
			modulateTween.kill()

func _possessed():
	if dropped:
		_pickup_weapon()
	_raise_weapon()
	possessed = true
	_create_confusion("default")
	first_action_timer.start()
	#Stop weapon flash and grow
	flash_and_grow_timer.stop()
	_reset_weapon_flash_and_grow()
	#anim_player.play("stop_fx")
	#Wait, then emit possess particles
	await get_tree().create_timer(0.75).timeout
	possess_particles.emitting = true
	if wielder != null:
		direction = wielder.walking_raycast.target_position.normalized()

func _vacated():
	_drop_weapon()
	_create_confusion("default")
	possessed = false
	$ThrowUI.visible = false
	possess_particles.emitting = false
	#Wait, then make weapon flash and grow
	await get_tree().create_timer(0.5).timeout
	#flash_and_grow_timer.start()
	#_weapon_flash_and_grow()
	#anim_player.play("can_be_possessed")

##Throwing functions##

func _throwing():
	$ThrowUI.visible = true

func _throw():
	_active_throw_hitbox()
	_create_confusion(50)
	if get_parent().handled_win == false:
		Global.stamina.value -= 1000 * Global.throwStrength
	weapon_smear.visible = true
	shadow.visible = true
	thrown = true
	dropped = true
	if Global.throw_angle == null:
		pass
	else:
		# Play audio
		$ThrowSound.play()
		
		#Getting throw information
		var throwTweenValues = throwCalc(Global.throwStrength,Global.throw_angle)
		var horzTweens = throwTweenValues[0]
		var vertTweens = throwTweenValues[1]
		
		#Right facing throw
		var tween = get_tree().create_tween()
		tween.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(horzTweens[0], vertTweens[0])), 0.3)
		tween.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(horzTweens[1], vertTweens[1])), 0.1667)
		tween.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(horzTweens[2], vertTweens[2])), 0.067)
		tween.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(horzTweens[3], vertTweens[3])), 0.067)
		
		# Getting direction of throw in order to adjust spin direction
		var spinDirection = 1
		if horzTweens[0] < 0:
			spinDirection = -1
		
		# Inducing spin
		var tween2 = get_tree().create_tween()
		tween2.tween_property(animated_sprite, "rotation", (animated_sprite.rotation + 7.5*spinDirection), 0.6)
	
	await get_tree().create_timer(0.4).timeout
	weapon_smear.visible = false
	await get_tree().create_timer(0.6).timeout
	if wielder != null:
		_unassign_wielder()


func throwCalc(throwStrength,throwAngle) -> Array:
	# If fully throwing in the x-direction, we know exactly how far to throw
	# However, if we are throwing partially or fully in the y-direction, we need to scale this amount down to account for window height
	# We also want to make the calculation process abstracted, such that we can allow for variable throw strength
	
	# Defining default throw distances
	var initialT = [66,105,112,115]
	var arcAdjust = [-23,-5,5,5]
	
	# Splitting angle into horizontal and vertical components (magnitudes)
	var horzMag = cos(deg_to_rad(throwAngle))
	var vertMag = sin(deg_to_rad(throwAngle))
	
	# Getting if throw is going to the left or right
	var throwSide = 0
	if horzMag >= 0:
		throwSide = -1 # right
		animated_sprite.scale.x = -1
		shadow.scale.x = -1
	else:
		throwSide = 1 # left
		animated_sprite.scale.x = 1
		shadow.scale.x = 1
	
	# Scaling values appropriately given input direction
	var horzScaled = initialT.map(func(i): return i*horzMag)
	var vertScaled = initialT.map(func(i): return i*vertMag)
	
	# Calculating arc adjustment for throw
	var arcHorz = arcAdjust.map(func(i): return i*horzMag)
	#Not used, commented #var arcVert = arcAdjust.map(func(i): return i*vertMag)
	
	# Getting scaler value for shortening due to vertical component of throw
	var directionScalar = sqrt((horzMag**2) + ((throwRatioVH*vertMag)**2))
	
	# Adding arc to vertical component of throw, accounting for throw direction
	for i in 4:
		vertScaled[i] = vertScaled[i] + throwSide*arcHorz[i]
	
	# Applying scaler to throw tween values
	# Multiply by -1 to correct direction
	var horzTweens = horzScaled.map(func(x): return -x*directionScalar*throwStrength)
	var vertTweens = vertScaled.map(func(x): return -x*directionScalar*throwStrength)
	
	return [horzTweens,vertTweens]

func _weapon_flash_and_grow():
	sizeTween = get_tree().create_tween()
	sizeTween.tween_property(animated_sprite, "scale", animated_sprite.scale * 1.1, 0.125)
	sizeTween.tween_property(animated_sprite, "scale", animated_sprite.scale / 1.1, 0.25)
	sizeTween.tween_property(animated_sprite, "scale", animated_sprite.scale * 1.1, 0.25)
	sizeTween.tween_property(animated_sprite, "scale", animated_sprite.scale / 1.1, 0.25)
	sizeTween.tween_property(animated_sprite, "scale", animated_sprite.scale * 1.0, 0.125)
	modulateTween = get_tree().create_tween()
	modulateTween.tween_property(animated_sprite, "modulate", Color.html("#6091ff"), 0.4)
	modulateTween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.6)

func _reset_weapon_flash_and_grow():
	if animated_sprite.scale.x < 0:
		animated_sprite.scale = Vector2(-1,1)
	if animated_sprite.scale.x > 0:
		animated_sprite.scale = Vector2(1,1)
	animated_sprite.modulate = Color.WHITE

func _drop_weapon():
	if wielder != null:
		_unassign_wielder()
	z_index = -1 #Allows orcs to walk over dropped weapons
	dropped = true
	var tween = get_tree().create_tween()
	tween.tween_property(animated_sprite, "position", animated_sprite.position + Vector2(0,10), 0.2)
	#Undo any spins. Without this, the rotation tween below will spin very fast to get rotation to 0
	_undo_spins()
	if animated_sprite.scale.x > 0:
		var tween2 = get_tree().create_tween()
		tween2.tween_property(animated_sprite, "rotation_degrees", 45, 0.2)
	if animated_sprite.scale.x < 0: 
		var tween2 = get_tree().create_tween()
		tween2.tween_property(animated_sprite, "rotation_degrees", -45, 0.2)
	var tween3 = get_tree().create_tween()
	tween3.tween_property(shadow, "modulate:a", 0, 0.15)

#This is used if a weapon is on the ground
func _pickup_weapon():
	z_index = 0 #Reset after the drop made it -1
	shadow.visible = true
	shadow.modulate = 70
	#Undo any spins. Without this, the rotation tween below will spin very fast to get rotation to 0
	_undo_spins()
	var tween = get_tree().create_tween()
	tween.tween_property(animated_sprite, "position", animated_sprite.position + Vector2(0,-15), 0.8)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(animated_sprite, "rotation_degrees", 0, 0.8)

#This is used if a weapon is wielded
func _raise_weapon():
	var tween = get_tree().create_tween()
	tween.tween_property(animated_sprite, "rotation_degrees", 0, 0.8)

#Undo any spins. Without this, rotation tweens will spin very fast to get rotation to 0
#Use this before rotation tweens
func _undo_spins():
	if animated_sprite.rotation_degrees >= 0: 
		animated_sprite.rotation_degrees = (fmod(animated_sprite.rotation_degrees, 360.0))
	else:
		animated_sprite.rotation_degrees = (fmod(animated_sprite.rotation_degrees,-360.0))

func _activate_swing_hitbox():
	await get_tree().create_timer(0.1).timeout
	hitbox.set_collision_mask_value(2, true)
	await get_tree().create_timer(0.2).timeout
	hitbox.set_collision_mask_value(2, false)

func _active_throw_hitbox():
	hitbox.set_collision_mask_value(2, true)
	await get_tree().create_timer(0.7).timeout
	hitbox.set_collision_mask_value(2, false)

func _create_confusion(final_radius):
	var confusion_box = confusion_box_scene.instantiate()
	get_parent().add_child(confusion_box)
	if final_radius is int:
		confusion_box.final_radius = final_radius
	confusion_box.global_position = global_position
