extends Node2D

@onready var anim_player = $AnimationPlayer
@onready var animated_sprite = $AnimatedSprite2D
@onready var text_sprite = $Text
@onready var particles = $AnimatedSprite2D/CPUParticles2D
@onready var throwUI = $ThrowUI

var possessed = false
var thrown : bool
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
		
		if Input.is_action_pressed("enter") and not thrown:
			_throwing()
		else:
			$ThrowUI.visible = false
		
		if Input.is_action_just_released("enter"):
			_throw()
	throwUI.global_position = global_position

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
	anim_player.play("throw")
	Global.stamina.value -= 1000
	thrown = true
