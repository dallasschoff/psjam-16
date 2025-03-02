extends State
class_name Path

@onready var character: CharacterBody2D
@export var path: String
var points: Array[Vector2]
var point_index: int = 0
var back_track: bool = false
var move_to: Vector2
var allow_pathing: bool = false
var stuck1frame : bool = false

func enter():
	var point_strings = path.split("/")
	for point in point_strings:
		var split_point = point.split(",")
		points.append(Vector2(int(split_point[0]), int(split_point[1])))
	
	character = get_parent().get_parent()
	move_to = points[point_index]
	allow_pathing = true

func physics_update(_delta: float):
	if allow_pathing:
		if round(character.global_position.x) != move_to.x:
			_move_to_x()
		else:
			if round(character.global_position.y) != move_to.y:
				_move_to_y()
			else:
				print("Arrived at ", move_to)
				character.velocity = Vector2(0,0)
				allow_pathing = false
				if point_index == 0 or point_index == points.size() - 1:
					back_track = !back_track
				await get_tree().create_timer(1).timeout
				_set_and_iterate_path_point()
		character.move_and_slide()
	var character_position = character.global_position
	character_position

#Checks if char is stuck on this frame and the previous frame, then unsticks
	if character.velocity == Vector2(0,0) and move_to != round(character.global_position) and stuck1frame:
			_unstick()
#Checks if char is stuck on this frame
	if character.velocity == Vector2(0,0) and move_to != round(character.global_position):
		stuck1frame = true

func _move_to_x():
	var direction = 1 if character.global_position.direction_to(move_to).x > 0 else -1
	character.walking_raycast.target_position = Vector2(direction, 0).normalized() * 20
	character.velocity.x = direction * character.move_speed
	character.velocity.y = 0

func _move_to_y():
	var direction = 1 if character.global_position.direction_to(move_to).y > 0 else -1
	character.walking_raycast.target_position = Vector2(0, direction).normalized() * 20
	character.velocity.y = direction * character.move_speed
	character.velocity.x = 0
	
func _set_and_iterate_path_point():
	if not back_track and point_index < points.size() - 1:
		point_index += 1
	if back_track and point_index > 0:
		point_index -= 1
	move_to = points[point_index]
	allow_pathing = true

func _unstick():
	await get_tree().create_timer(1.5).timeout
	_set_and_iterate_path_point()
