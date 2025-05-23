extends State
class_name Roam

@export var spawned_with_weapon: bool = false
@onready var character: CharacterBody2D
var home_location: Vector2
var move_to: Vector2
var random: bool = false
var allow_roaming = false
var arrived_x: bool = false
var wander_option: int
var stuck1frame : bool = false
var unsticking: bool = false
var stillStuck: bool = false
var character_velocity : Vector2
var character_global_position: Vector2
var previous_position : Vector2

func enter():
	character = get_parent().get_parent()
	home_location = character.global_position
	randomize_wander(false)
	
func update(_delta: float):
	if spawned_with_weapon and character.weapon == null:
		#transitioned.emit(self, "retrieve")
		pass
	if spawned_with_weapon and character.weapon != null and character.weapon.possessed:
		allow_roaming = false
		random = false
	if random:
		random = false
		await get_tree().create_timer(2).timeout
		randomize_wander(false)
	
func physics_update(_delta: float):
	if allow_roaming: #and not character.walking_raycast.is_colliding():
		if round(character.global_position.y) != move_to.y:
			_move_to_y()
		else:
			if round(character.global_position.x) != move_to.x:
				_move_to_x()
			else:
				character.velocity = Vector2(0,0)
				allow_roaming = false
				random = true
				
	#if allow_roaming and character.walking_raycast.is_colliding():
		#character.velocity = Vector2(0,0)
		##Flip character raycast so its not colliding anymore
		#character.walking_raycast.target_position = Vector2.ZERO - character.walking_raycast.target_position
		#allow_roaming = false
		#await get_tree().create_timer(1).timeout
		#randomize_wander(true)
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

func randomize_wander(override_to_home: bool):
	wander_option = randi_range(1, 4)
	if override_to_home:
		move_to = home_location
		allow_roaming = true
		return
	#Return to home
	if wander_option == 1:
		move_to = home_location
	#Randomize wander
	else:
		var direction = Vector2([-1, 1].pick_random(), [-1, 1].pick_random())
		var length = Vector2(randi_range(20, 30), randi_range(20, 30))
		move_to = (direction * length) + round(character.global_position)
	allow_roaming = true

func _unstick():
	unsticking = false
	randomize_wander(false)
