extends Node2D

@onready var anim_player = $AnimationPlayer
@onready var animated_sprite = $AnimatedSprite2D
@onready var shadow = $Shadow
@onready var text_sprite = $Text
@onready var particles = $AnimatedSprite2D/CPUParticles2D
@onready var throwUI = $ThrowUI
@onready var text = $Text

var possessed = false
var thrown : bool
var wielded : bool

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
		if not Input.is_action_pressed("enter"):
			if Input.is_action_pressed("up") or Input.is_action_pressed("left"):
				animated_sprite.rotation -= 0.2
			if Input.is_action_pressed("down") or Input.is_action_pressed("right"):
				animated_sprite.rotation += 0.2
		
		if Input.is_action_pressed("enter"):
			_throwing()
		else:
			$ThrowUI.visible = false
		
		if Input.is_action_just_released("enter"):
			_throw()
	
	#Keeps throw UI with weapon. 
	throwUI.global_position = animated_sprite.global_position + Vector2(6, -5)
	#Keeps text with weapon. If we changed the node tree instead, text would rotate with weapon
	text.global_position = animated_sprite.global_position + Vector2(4, -25)
	#Moves shadow with sword
	shadow.global_position = animated_sprite.global_position + Vector2(6, 16)
	#Rotates shadow with sword
	shadow.rotation = animated_sprite.rotation
	
##Possession functions ##

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
	particles.emitting = true

func _vacated():
	possessed = false
	$ThrowUI.visible = false
	particles.emitting = false
	await get_tree().create_timer(0.5).timeout
	anim_player.play("can_be_possessed")

##Throwing functions##

func _throwing():
	$ThrowUI.visible = true

func _throw():
	#anim_player.play("throw")
	Global.stamina.value -= 1000
	thrown = true
	if Global.throw_angle == null:
		pass
	if abs(Global.throw_angle) < 215 and abs(Global.throw_angle) > 145:
		#Right facing throw
		var tween = get_tree().create_tween()
		tween.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(66,-23)), 0.3)
		tween.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(105,-5)), 0.1667)
		tween.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(112, 5)), 0.067)
		tween.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(115, 5)), 0.067)
		var tween2 = get_tree().create_tween()
		tween2.tween_property(animated_sprite, "rotation", (animated_sprite.rotation + 7.5), 0.6)
	if abs(Global.throw_angle) < 35 and abs(Global.throw_angle) >=0\
	or abs(Global.throw_angle) > 325 and abs(Global.throw_angle) < 360:
		#Left facing throw
		var tween = get_tree().create_tween()
		tween.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(-66,-23)), 0.3)
		tween.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(-105,-5)), 0.1667)
		tween.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(-112, 5)), 0.067)
		tween.tween_property(animated_sprite, "position", (animated_sprite.position + Vector2(-115, 5)), 0.067)
		var tween2 = get_tree().create_tween()
		tween2.tween_property(animated_sprite, "rotation", (animated_sprite.rotation - 7.5), 0.6)
