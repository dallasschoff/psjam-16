extends State
class_name Retrieve

@onready var character: CharacterBody2D
var weapon
var weapon_in_range: bool = false
var weapon_animated_sprite

func enter():
	character = get_parent().get_parent()
	weapon = character.dropped_weapon
	weapon_animated_sprite = weapon.animated_sprite
	
func update(_delta: float):
	if weapon_in_range:
		weapon._picked_up(character)
		transitioned.emit(self, "roam")
	
func physics_update(_delta: float):
	if not weapon_in_range:
		if round(character.global_position.x) != round(weapon_animated_sprite.global_position.x):
			_move_to_x()
		if round(character.global_position.x) == round(weapon_animated_sprite.global_position.x):
			if round(character.global_position.y) != round(weapon_animated_sprite.global_position.y):
				_move_to_y()
			else:
				weapon_in_range = true
	character.move_and_slide()
		
func _move_to_x():
	var direction = 1 if character.global_position.direction_to(weapon_animated_sprite.global_position).x > 0 else -1
	character.walking_raycast.target_position = Vector2(direction, 0).normalized() * 20
	character.velocity.x = direction * character.move_speed
	character.velocity.y = 0

func _move_to_y():
	var direction = 1 if character.global_position.direction_to(weapon_animated_sprite.global_position).y > 0 else -1
	character.walking_raycast.target_position = Vector2(0, direction).normalized() * 20
	character.velocity.y = direction * character.move_speed
	character.velocity.x = 0
