extends Node2D

@onready var anim_player = $AnimationPlayer
@onready var animated_sprite = $AnimatedSprite2D
@onready var shadow = $Shadow
@onready var text_sprite = $Text
@onready var possess_particles = $AnimatedSprite2D/PossessParticles
@onready var sword_smear = $AnimatedSprite2D/SwordSmear
@onready var throwUI = $ThrowUI
@onready var text = $Text
@onready var hitbox: Area2D = $AnimatedSprite2D/Hitbox

@export var throwRatioVH = 0.6

var possessed = false
var thrown : bool = false
var wielded : bool #Use "wielder != null" instead
var dropped : bool
var chop_cooldown: Timer
var chopAvailable: bool = true
var throw_cooldown: Timer
var throwAvailable: bool = true
var flash_and_grow_timer: Timer
var sword_flash_and_grow: bool = false
@export var tug: Vector2
@export var wielder : Orc
@export var animated_sprite_rotation : float
@export var flip_left : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.possessed.connect(_possessed) #Emitted by player
	SignalBus.vacated.connect(_vacated) #Emitted by player
	text_sprite.modulate = Color(1,1,1,0)
	
	chop_cooldown = Timer.new()
	chop_cooldown.wait_time = 0.35
	chop_cooldown.one_shot = true
	chop_cooldown.connect("timeout", _reset_chop)
	add_child(chop_cooldown)
	
	throw_cooldown = Timer.new()
	throw_cooldown.wait_time = 1.0
	throw_cooldown.one_shot = true
	throw_cooldown.connect("timeout", _reset_throw)
	add_child(throw_cooldown)
	
	flash_and_grow_timer = Timer.new()
	flash_and_grow_timer.wait_time = 1.0
	flash_and_grow_timer.one_shot = false
	flash_and_grow_timer.connect("timeout", _test)
	add_child(flash_and_grow_timer)
	
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
func _process(delta: float) -> void:
	if possessed:
		##Chopping
		if not Input.is_action_pressed("enter") and chopAvailable and throwAvailable:
			if Input.is_action_pressed("left"):
				_undo_spins()
				_chop_left()
			if Input.is_action_pressed("right"):
				_undo_spins()
				_chop_right()
			if Input.is_action_pressed("up"):
				_undo_spins()
				_chop_up()
			if Input.is_action_pressed("down"):
				_undo_spins()
				_chop_down()
			##Sword smear and stamina
			if (Input.is_action_just_released("left") or Input.is_action_just_released("right")
			or Input.is_action_just_released("down") or Input.is_action_just_released("up")):
				_activate_chop_hitbox()
				chopAvailable = false
				chop_cooldown.start()
				await get_tree().create_timer(0.1).timeout
				sword_smear.visible = true
				Global.stamina.value -= 500
				await get_tree().create_timer(0.1).timeout
				sword_smear.visible = false
		
		if Input.is_action_pressed("enter"):
			_throwing()
		else:
			$ThrowUI.visible = false
		##Throwing
		if Input.is_action_just_released("enter") and throwAvailable:
			_throw()
			chopAvailable = false
			chop_cooldown.start()
			throwAvailable = false
			throw_cooldown.start()
			
		if wielder != null and not thrown:
			wielder._weapon_drag(position + animated_sprite.position + wielder._weapon_offsets())
	
	#Keeps throw UI with weapon. 
	throwUI.global_position = animated_sprite.global_position + Vector2(6, -5)
	#Keeps text with weapon. If we changed the node tree instead, text would rotate with weapon
	text.global_position = animated_sprite.global_position + Vector2(4, -25)
	#Moves shadow with sword
	shadow.global_position = animated_sprite.global_position + Vector2(6, 9)
	#Rotates shadow with sword
	shadow.rotation = animated_sprite.rotation

func _chop_left():
	#Flip things left if pressed left
	animated_sprite.scale.x = -1
	shadow.scale.x = -1
	##Chop left
	var tween = get_tree().create_tween()
	tween.tween_property(animated_sprite, "rotation_degrees", 100, 0.1)
	tween.tween_property(animated_sprite, "rotation_degrees", -120, 0.08)
	tween.tween_property(animated_sprite, "rotation_degrees", 0, 0.5)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(0,0)), 0.05)
	tween2.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(-10,0)), 0.08)
	tug = Vector2(-10,0)

func _chop_right():
	#Flip things right if pressed right
	animated_sprite.scale.x = 1
	shadow.scale.x = 1
	##Chop right
	var tween = get_tree().create_tween()
	tween.tween_property(animated_sprite, "rotation_degrees", -100, 0.1)
	tween.tween_property(animated_sprite, "rotation_degrees", 120, 0.08)
	tween.tween_property(animated_sprite, "rotation_degrees", 0, 0.5)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(0,0)), 0.05)
	tween2.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(10,0)), 0.08)
	tug = Vector2(10,0)

func _chop_up():
	#Flip things right if pressed up
	animated_sprite.scale.x = 1
	shadow.scale.x = 1
	##Chop up
	var tween = get_tree().create_tween()
	tween.tween_property(animated_sprite, "rotation_degrees", -190, 0.1)
	tween.tween_property(animated_sprite, "rotation_degrees", 30, 0.08)
	tween.tween_property(animated_sprite, "rotation_degrees", -90, 0.5)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(0,0)), 0.05)
	tween2.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(0,-10)), 0.08)
	tug = Vector2(0,-10)

func _chop_down():
	#Flip things right if pressed down
	animated_sprite.scale.x = 1
	shadow.scale.x = 1
	##Chop down
	var tween = get_tree().create_tween()
	tween.tween_property(animated_sprite, "rotation_degrees", -10, 0.1)
	tween.tween_property(animated_sprite, "rotation_degrees", 210, 0.08)
	tween.tween_property(animated_sprite, "rotation_degrees", 0, 0.5)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(0,0)), 0.05)
	tween2.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(0,10)), 0.08)
	tug = Vector2(0,10)

func _reset_chop():
	chopAvailable = true
	
func _reset_throw():
	throwAvailable = true

##Possession functions##
func _unassign_wielder():
	wielder = null
	hitbox.wielder = null

func _can_be_possessed():
	if possessed == false:
		##Appear text
		#create_tween().tween_property(text_sprite, "modulate:a",1,0.25)
		#Make sword flash and grow
		flash_and_grow_timer.start()
		_sword_flash_and_grow()
		#anim_player.play("can_be_possessed")

func _cannot_be_possessed():
	if possessed == false:
		##Disappear text
		#create_tween().tween_property(text_sprite, "modulate:a",0,0.5)
		#Stop sword flash and grow
		flash_and_grow_timer.stop()
		_reset_sword_flash_and_grow()
		#anim_player.play("stop_fx")

func _possessed():
	if dropped:
		_pickup_weapon()
	_raise_weapon()
	possessed = true
	##Disappear text
	#create_tween().tween_property(text_sprite, "modulate:a",0,0.5)
	#Stop sword flash and grow
	flash_and_grow_timer.stop()
	_reset_sword_flash_and_grow()
	#anim_player.play("stop_fx")
	#Wait, then emit possess particles
	await get_tree().create_timer(0.75).timeout
	possess_particles.emitting = true

func _vacated():
	_drop_weapon()
	possessed = false
	$ThrowUI.visible = false
	possess_particles.emitting = false
	#Wait, then make sword flash and grow
	await get_tree().create_timer(0.5).timeout
	flash_and_grow_timer.start()
	_sword_flash_and_grow()
	#anim_player.play("can_be_possessed")

##Throwing functions##

func _throwing():
	$ThrowUI.visible = true

func _throw():
	_active_throw_hitbox()
	Global.stamina.value -= 1000
	sword_smear.visible = true
	shadow.visible = true
	thrown = true
	dropped = true
	if Global.throw_angle == null:
		pass
	else:
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
	sword_smear.visible = false
	await get_tree().create_timer(0.6).timeout
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
	var arcVert = arcAdjust.map(func(i): return i*vertMag)
	
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

func _test():
	_reset_sword_flash_and_grow()
	_sword_flash_and_grow()

func _sword_flash_and_grow():
	var sizeTween = get_tree().create_tween()
	sizeTween.tween_property(animated_sprite, "scale", animated_sprite.scale * 1.1, 0.125)
	sizeTween.tween_property(animated_sprite, "scale", animated_sprite.scale / 1.1, 0.25)
	sizeTween.tween_property(animated_sprite, "scale", animated_sprite.scale * 1.1, 0.25)
	sizeTween.tween_property(animated_sprite, "scale", animated_sprite.scale / 1.1, 0.25)
	sizeTween.tween_property(animated_sprite, "scale", animated_sprite.scale * 1.0, 0.125)
	var modulateTween = get_tree().create_tween()
	modulateTween.tween_property(animated_sprite, "modulate", Color.html("#6091ff"), 0.4)
	modulateTween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.6)

func _reset_sword_flash_and_grow():
	if animated_sprite.scale.x < 0:
		animated_sprite.scale = Vector2(-1,1)
	if animated_sprite.scale.x > 0:
		animated_sprite.scale = Vector2(1,1)

func _drop_weapon():
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

func _activate_chop_hitbox():
	hitbox.set_collision_mask_value(2, true)
	await get_tree().create_timer(0.2).timeout
	hitbox.set_collision_mask_value(2, false)

func _active_throw_hitbox():
	hitbox.set_collision_mask_value(2, true)
	await get_tree().create_timer(0.7).timeout
	hitbox.set_collision_mask_value(2, false)
