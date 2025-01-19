extends Node2D
class_name HealthComponent

@export var MAX_HEALTH := 10.0
var HEALTH : float

@export var healthbar_component : HealthBar
@export var entity: CharacterBody2D
@export var animated_sprite: AnimatedSprite2D

func _ready():
	HEALTH = MAX_HEALTH
	healthbar_component.value = HEALTH
	healthbar_component.max_value = MAX_HEALTH
	update_healthbar()

func damage(attack_damage):
	HEALTH -= attack_damage
	update_healthbar()
	if HEALTH <= 0:
		entity._die()

func update_healthbar():
	healthbar_component.update(HEALTH)
	
func check_health():
	return HEALTH;
