extends State
class_name Alert

@export var spawned_with_weapon: bool = false
@onready var character: CharacterBody2D
var home_location: Vector2
var move_to: Vector2
var target_point: Vector2
var random: bool = false
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
		random = false
	if random:
		random = false
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
				random = true
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
	# Sets a position for the orc to go to when alerted. Within a box but outside of an inner rectangle
	await get_tree().create_timer(1.0).timeout #Gives orcs a sec to think before moving
	
	## All of this should let you get an x component that is outside of -5 to 5 range.
	## We use randi_range to find a value, then if it's not within our parameters, we change it
	var halfBoxLength = 20
	var exlcudedValues = 10
	
	var move_to_x = randi_range(target_point.x-halfBoxLength, target_point.x+halfBoxLength)
	#Checking for if value is -5 to 0
	if move_to_x > target_point.x - exlcudedValues and move_to_x < target_point.x:
		move_to_x = target_point.x - exlcudedValues
	#Checking for if value is 0 to 5
	if move_to_x < target_point.x + exlcudedValues and move_to_x > target_point.x:
		move_to_x = target_point.x + exlcudedValues
	
	var move_to_y = randi_range(target_point.y-halfBoxLength, target_point.y+halfBoxLength)
	#Checking for if value is -5 to 0
	if move_to_y > target_point.y - exlcudedValues and move_to_y < target_point.y:
		move_to_y = target_point.y - exlcudedValues
	#Checking for if value is 0 to 5
	if move_to_y < target_point.y + exlcudedValues and move_to_y > target_point.y:
		move_to_y = target_point.y + exlcudedValues

	move_to = Vector2(move_to_x, move_to_y)
	home_location = move_to
	allow_roaming = true

func randomize_wander():
	wander_option = randi_range(1, 3)
	var direction = Vector2([-1, 1].pick_random(), [-1, 1].pick_random())
	var length = Vector2(randi_range(15, 20), randi_range(15, 20))
	move_to = (direction * length) + round(character.global_position)
	#Return to first move_to
	if wander_option == 1:
		move_to = home_location
	allow_roaming = true
