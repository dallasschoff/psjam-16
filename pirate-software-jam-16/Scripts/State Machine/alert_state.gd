extends State
class_name Alert

@export var range: int = 50
@export var spawned_with_weapon: bool = false
@onready var character: CharacterBody2D
var home_location: Vector2
var move_to: Vector2
var target_point: Vector2
var randomize: bool = false
var allow_roaming = false
var arrived_x: bool = false
var wander_option: int

func enter():
	character = get_parent().get_parent()
	target_point = character.alert_target_position
	set_move_to()
	
func update(_delta: float):
	if spawned_with_weapon and character.weapon == null:
		pass
	if spawned_with_weapon and character.weapon != null and character.weapon.possessed:
		allow_roaming = false
		randomize = false
	if randomize:
		randomize = false
		await get_tree().create_timer(2).timeout
		randomize_wander()
	
func physics_update(_delta: float):
	if allow_roaming and not character.walking_raycast.is_colliding():
		if round(character.global_position.x) != move_to.x:
			_move_to_x()
		else:
			if round(character.global_position.y) != move_to.y:
				_move_to_y()
			else:
				character.velocity = Vector2(0,0)
				allow_roaming = false
				randomize = true
	if allow_roaming and character.walking_raycast.is_colliding():
		character.velocity = Vector2(0,0)
		
	character.move_and_slide()
	
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

func set_move_to():
	move_to = Vector2(randi_range(target_point.x-25, target_point.x+25),
		randi_range(target_point.y-25, target_point.y+25))
	home_location = move_to
	allow_roaming = true
		
func randomize_wander():
	wander_option = randi_range(1, 3)
	var direction = Vector2([-1, 1].pick_random(), [-1, 1].pick_random())
	var length = Vector2(randi_range(10, 15), randi_range(10, 15))
	move_to = (direction * length) + round(character.global_position)
	#Return to first move_to
	if wander_option == 1:
		move_to = home_location
	allow_roaming = true
