extends CharacterBody2D
class_name Orc

var bloodScene = load("res://Scenes/Blood.tscn")
@onready var head = $Head
@onready var body = $Body
@onready var leftArm = $"Left Arm"
@onready var rightArm = $"Right Arm"
@onready var walking_raycast: RayCast2D = $WalkingRaycast
@onready var animation_tree: AnimationTree = $AnimationTree
var direction
var weapon
var dropped_weapon
@export var left_handed : bool
@export var move_speed: int = 30
@export var target: bool = false

func _ready():
	if target:
		add_to_group("Targets")
	add_to_group("Orcs")
	animation_tree.active = true

func _process(delta):
	if weapon != null and not weapon.possessed:
		update_animation_parameters()
	else:
		update_animation_parameters()

func _physics_process(delta: float) -> void:
	if weapon != null and weapon.possessed and weapon.direction != null:
		direction = weapon.direction
		walking_raycast.target_position = weapon.direction * 20
	else:
		direction = walking_raycast.target_position.normalized()

func _hit(attack_damage):
	#Use this to handle hurting animations or any other FX when the orc gets hit
	var blood = bloodScene.instantiate()
	get_parent().add_child(blood)
	blood.global_position = global_position + Vector2(0, -5)

func _die():
	Global.stamina.value += 1000
	
	# Play audio
	$DeathSound.play()
	
	if weapon != null and !weapon.dropped:
		weapon._drop_weapon()
		
	$".".hide()
	await get_tree().create_timer(5).timeout
	queue_free()

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
