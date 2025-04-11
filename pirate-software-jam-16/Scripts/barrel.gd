extends Node2D
class_name Barrel

var destroyed: bool = false
@onready var alert_box_scene: PackedScene = load("res://Scenes/AlertBox.tscn")

#When barrel is hit by a weapon, break
func _hurtbox_entered(_area):
	if not destroyed:
		# Play audio
		$CrackSound.play()
		destroyed = true
		$Sprite2D.play("breaking")
		$CollisionBox.set_collision_layer_value(1, false)
		_create_alert()

func _create_alert():
	var alert_box = alert_box_scene.instantiate()
	get_parent().add_child(alert_box)
	alert_box.global_position = global_position
