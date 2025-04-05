extends CharacterBody2D
class_name Orc

var bloodScene = load("res://Scenes/Blood.tscn")
@onready var alert_box_scene: PackedScene = load("res://Scenes/AlertBox.tscn")

@onready var walking_raycast: RayCast2D = $WalkingRaycast
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var target_particles = $TargetParticles
@onready var body = $Body
var direction
var weapon
var dropped_weapon
var alerted: bool = false
var confused: bool = false
var alert_target_position: Vector2
@export var left_handed : bool
@export var move_speed: int = 30
@export var target: bool = false
@export_enum("Green", "Purple", "Blue", "Red") var color : String

func _ready():
	if target:
		add_to_group("Targets")
		target_particles.emitting = true
	add_to_group("Orcs")
	animation_tree.active = true
	
	if color == "Green":
		body.sprite_frames = load("res://Assets/SpriteFrames/OrcGreen.tres")
	if color == "Purple":
		body.sprite_frames = load("res://Assets/SpriteFrames/OrcPurple.tres")
	if color == "Blue":
		body.sprite_frames = load("res://Assets/SpriteFrames/OrcBlue.tres")
	if color == "Red":
		body.sprite_frames = load("res://Assets/SpriteFrames/OrcRed.tres")

func _process(_delta):
	if weapon != null and not weapon.possessed:
		update_animation_parameters()
	else:
		update_animation_parameters()

func _physics_process(_delta: float) -> void:
	if weapon != null and weapon.possessed and weapon.direction != null:
		direction = weapon.direction
		walking_raycast.target_position = weapon.direction * 20
	else:
		direction = walking_raycast.target_position.normalized()

func _hit(_attack_damage): #Called by hurtboxComponent.gd
	#Use this to handle hurting animations or any other FX when the orc gets hit
	var blood = bloodScene.instantiate()
	get_parent().add_child(blood)
	blood.global_position = global_position + Vector2(0, -5)

func _die():
	if Global.stamina.value > 0:
		Global.stamina.value += 1000
	_play_sound()
	_create_alert()
	if weapon != null and !weapon.dropped:
		weapon._drop_weapon()
	queue_free()

func _create_alert():
	var alert_box = alert_box_scene.instantiate()
	get_parent().add_child(alert_box)
	alert_box.global_position = global_position

func _alerted(target_position): #Called by alertBox.gd, which is instantiated by alerting items
	alerted = true
	$ConfusedSprite.visible = false
	$AlertSprite.visible = true
	$AlertSprite.play("default")
	alert_target_position = target_position
	## Goal of this is to execute a function in the StateMachine, 
	## which is only a child of the Orc in the Level scenes
	for child in get_children():
		if child is StateMachine:
			child._create_alert_state()

func _confused(): #Called by confusionBox.gd, which is instantiated by confusing events
	if not alerted and not confused:
		confused = true
		$ConfusedSprite.visible = true
		$ConfusedSprite.play("default")

func _play_sound():
	var rand = randf()
	if rand < 0.49:
		var sound_player = AudioStreamPlayer.new()
		sound_player.stream = load("res://Assets/Sounds/death_groan.wav")
		sound_player.volume_db = -15
		get_parent().add_child(sound_player)
		sound_player.play()
	elif rand > 0.49 and rand < 0.98:
		var sound_player = AudioStreamPlayer.new()
		sound_player.stream = load("res://Assets/Sounds/death_grunt.wav")
		sound_player.volume_db = -15
		get_parent().add_child(sound_player)
		sound_player.play()
	else:
		var sound_player = AudioStreamPlayer.new()
		sound_player.stream = load("res://Assets/Sounds/death_terrible_scream.wav")
		sound_player.volume_db = -15
		get_parent().add_child(sound_player)
		sound_player.play()

func _weapon_offsets():
	if left_handed:
		match direction:
			Vector2(0, 1):
				return Vector2 (10, -5)
			Vector2(0, -1):
				return Vector2 (-10, -5)
			Vector2(-1, 0):
				return Vector2 (0, -5)
			Vector2(1, 0):
				return Vector2 (0, -5)
			#default case if direction is null
			_:
				return Vector2 (10, -5)
	else:
		match direction:
			Vector2(0, 1):
				return Vector2 (-10, -5)
			Vector2(0, -1):
				return Vector2 (10, -5)
			Vector2(-1, 0):
				return Vector2 (0, -5)
			Vector2(1, 0):
				return Vector2 (0, -5)
			#default case if direction is null
			_:
				return Vector2 (-10, -5)

func _weapon_drag(tug: Vector2) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", tug, 0.08)
	
func update_animation_parameters():
	animation_tree["parameters/conditions/idling"] = true if velocity == Vector2.ZERO else false
	animation_tree["parameters/conditions/walking"] = true if velocity != Vector2.ZERO else false
	
	if (direction != Vector2.ZERO):
		animation_tree["parameters/idle/blend_position"] = direction
		animation_tree["parameters/walk/blend_position"] = direction
