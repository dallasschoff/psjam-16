extends Node2D

@onready var anim_player = $AnimationPlayer
@onready var animated_sprite = $AnimatedSprite2D
@onready var shadow = $Shadow
@onready var text_sprite = $Text
@onready var possess_particles = $AnimatedSprite2D/PossessParticles
@onready var sword_smear = $AnimatedSprite2D/SwordSmear
@onready var throwUI = $ThrowUI
@onready var text = $Text

@export var throwRatioVH = 0.6

var possessed = false
var thrown : bool
var wielded : bool
@export var wielder : Orc

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.can_possess.connect(_can_be_possessed) #Emitted by interactionArea
	SignalBus.cannot_possess.connect(_cannot_be_possessed) #Emitted by interactionArea
	SignalBus.possessed.connect(_possessed) #Emitted by player
	SignalBus.vacated.connect(_vacated) #Emitted by player
	text_sprite.modulate = Color(1,1,1,0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if possessed:
		##Chopping
		if not Input.is_action_pressed("enter"):
			if Input.is_action_pressed("left"):
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
			if Input.is_action_pressed("right"):
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
			if Input.is_action_pressed("up"):
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
			if Input.is_action_pressed("down"):
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
			##Sword smear and stamina
			if Input.is_action_just_released("left") or Input.is_action_just_released("right")\
			or Input.is_action_just_released("down") or Input.is_action_just_released("up"):
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
		if Input.is_action_just_released("enter"):
			_throw()
			
	if wielder:
		position = wielder._weapon_offsets()
	
	#Keeps throw UI with weapon. 
	throwUI.global_position = animated_sprite.global_position + Vector2(6, -5)
	#Keeps text with weapon. If we changed the node tree instead, text would rotate with weapon
	text.global_position = animated_sprite.global_position + Vector2(4, -25)
	#Moves shadow with sword
	shadow.global_position = animated_sprite.global_position + Vector2(6, 16)
	#Rotates shadow with sword
	shadow.rotation = animated_sprite.rotation

##Possession functions##

func _can_be_possessed(interactionArea):
	if possessed == false:
		anim_player.play("can_be_possessed")
		create_tween().tween_property(text_sprite, "modulate:a",1,0.25)
		pass

func _cannot_be_possessed(interactionArea):
	if possessed == false:
		create_tween().tween_property(text_sprite, "modulate:a",0,0.5)
		anim_player.play("stop_fx")
		pass

func _possessed():
	possessed = true
	create_tween().tween_property(text_sprite, "modulate:a",0,0.5)
	anim_player.play("stop_fx")
	await get_tree().create_timer(0.75).timeout
	possess_particles.emitting = true

func _vacated():
	possessed = false
	$ThrowUI.visible = false
	possess_particles.emitting = false
	await get_tree().create_timer(0.5).timeout
	anim_player.play("can_be_possessed")

##Throwing functions##

func _throwing():
	$ThrowUI.visible = true

func _throw():
	Global.stamina.value -= 1000
	sword_smear.visible = true
	thrown = true
	if Global.throw_angle == null:
		pass
	else:
	#if abs(Global.throw_angle) < 215 and abs(Global.throw_angle) > 145:
		
		#Getting throw information
		var throwTweenValues = throwCalc(1,Global.throw_angle)
		var horzTweens = throwTweenValues[0]
		var vertTweens = throwTweenValues[1]
		
		#Right facing throw
		var tween = get_tree().create_tween()
		tween.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(horzTweens[0], vertTweens[0])), 0.3)
		tween.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(horzTweens[1], vertTweens[1])), 0.1667)
		tween.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(horzTweens[2], vertTweens[2])), 0.067)
		tween.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(horzTweens[3], vertTweens[3])), 0.067)
		
		
		var tween2 = get_tree().create_tween()
		tween2.tween_property(animated_sprite, "rotation", (animated_sprite.rotation + 7.5), 0.6)
	
	await get_tree().create_timer(0.4).timeout
	sword_smear.visible = false

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
	else:
		throwSide = 1 # left
	
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
