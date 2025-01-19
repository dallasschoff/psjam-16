extends Area2D
class_name HurtboxComponent

@export var health_component : HealthComponent
@export var entity: CharacterBody2D

func damage(attack_damage):
	if health_component:
		health_component.damage(attack_damage)
	if entity:
		entity._hit(attack_damage)
