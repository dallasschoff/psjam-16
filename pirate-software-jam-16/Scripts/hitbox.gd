extends Node2D
class_name Hitbox

@export var attack_damage := 10.0
@onready var attack_area = $CollisionShape2D

func _on_area_entered(area):
	if area is HurtboxComponent:
		var hurtbox: HurtboxComponent = area
		hurtbox.damage(attack_damage)
