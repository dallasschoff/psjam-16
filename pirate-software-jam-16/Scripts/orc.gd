extends CharacterBody2D

var blood = load("res://Scenes/Blood.tscn")

func _physics_process(delta: float) -> void:
	pass

func _hit(attack_damage):
	#Use this to handle hurting animations or any other FX when the orc gets hit
	var blood_instance = blood.instantiate()
	get_tree().current_scene.add_child(blood_instance)
	blood_instance.global_position = global_position + Vector2(0, -5)
	pass

func _die():
	queue_free()
