extends Node2D
class_name TreeBranch

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $HitboxHurtbox
@export var collision_damage: int = 50
var fallen: bool = false

#When broken area is hit by a weapon, fall off tree and activate hitbox area mask
#When falling branch hits a character with a hurtbox, deal collision damage
func _hurtbox_entered(area): #Called by hitbox.gd from weapons
	if not fallen:
		# Play audio
		$CrackSound.play()
		
		fallen = true
		var tween = get_tree().create_tween()
		tween.parallel().tween_property(self, "global_position", Vector2(global_position.x - 20, global_position.y + 60), 1)
		tween.parallel().tween_property(self, "rotation_degrees", -190.0, 1)
		await get_tree().create_timer(0.8).timeout
		hitbox.set_collision_mask_value(2, true)
		await get_tree().create_timer(1).timeout
		hitbox.set_collision_mask_value(2, false)

func _on_hitbox_area_entered(area):
	if area is HurtboxComponent:
		var hurtbox: HurtboxComponent = area
		hurtbox.damage(collision_damage)
