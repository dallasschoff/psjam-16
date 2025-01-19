extends Node2D

@onready var anim_player = $AnimationPlayer
@onready var animated_sprite = $AnimatedSprite2D
@onready var text_sprite = $Text

var possessed = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.can_possess.connect(_can_be_possessed)
	SignalBus.cannot_possess.connect(_cannot_be_possessed)
	SignalBus.possessed.connect(_possessed)
	SignalBus.vacated.connect(_vacated)
	text_sprite.modulate = Color(1,1,1,0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if possessed:
		if Input.is_action_pressed("up") or Input.is_action_pressed("left"):
			animated_sprite.rotation -= 0.2
		if Input.is_action_pressed("down") or Input.is_action_pressed("right"):
			animated_sprite.rotation += 0.2
		#rotation = clamp(rotation, -90, 150)

func _can_be_possessed():
	if possessed == false:
		anim_player.play("can_be_possessed")
		create_tween().tween_property(text_sprite, "modulate:a",1,0.25)
		pass

func _cannot_be_possessed():
	anim_player.play("RESET")
	create_tween().tween_property(text_sprite, "modulate:a",0,0.5)
	pass

func _possessed():
	possessed = true
	create_tween().tween_property(text_sprite, "modulate:a",0,0.5)
	anim_player.play("RESET")

func _vacated():
	possessed = false
