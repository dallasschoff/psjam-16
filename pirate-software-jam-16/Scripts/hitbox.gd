extends Node2D
class_name Hitbox

@export var attack_damage := 10.0
@onready var attack_area = $CollisionShape2D
var wielder

func _on_area_entered(area):
	if area is HurtboxComponent and area.get_parent() != wielder:
		var hurtbox: HurtboxComponent = area
		hurtbox.damage(attack_damage)
