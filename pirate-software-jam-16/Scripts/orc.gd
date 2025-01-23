extends CharacterBody2D
class_name Orc

var blood = load("res://Scenes/Blood.tscn")
@onready var head = $Head
@onready var body = $Body
@onready var leftArm = $"Left Arm"
@onready var rightArm = $"Right Arm"

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
	var blood_instance = load(blood)
	add_child(blood_instance)
	blood_instance.global_position = global_position + Vector2(0, -5)

func _die():
	queue_free()

func _weapon_offsets() -> Vector2:
	return position + Vector2(10, 5)
