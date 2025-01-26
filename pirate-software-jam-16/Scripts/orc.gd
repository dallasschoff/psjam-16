extends CharacterBody2D
class_name Orc

var bloodScene = load("res://Scenes/Blood.tscn")
@onready var head = $Head
@onready var body = $Body
@onready var leftArm = $"Left Arm"
@onready var rightArm = $"Right Arm"
var weapon
@export var left_handed : bool

func _ready():
	add_to_group("Orcs")

func _physics_process(delta: float) -> void:
	var animation = "idle_down"
	head.play(animation)
	body.play(animation)
	leftArm.play(animation)
	rightArm.play(animation)

func _hit(attack_damage):
	#Use this to handle hurting animations or any other FX when the orc gets hit
	var blood = bloodScene.instantiate()
	get_tree().current_scene.add_child(blood)
	blood.global_position = global_position + Vector2(0, -5)

func _die():
	if weapon != null and !weapon.dropped:
		weapon._drop_weapon()
	queue_free()

func _weapon_offsets() -> Vector2:
	if left_handed:
		return Vector2(10, -5)
	else:
		return Vector2 (-10, -5)

func _weapon_drag(tug: Vector2) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", tug, 0.08)
