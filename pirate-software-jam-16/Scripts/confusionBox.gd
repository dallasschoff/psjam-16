extends Area2D

var final_radius = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($CollisionShape2D.shape, "radius", final_radius, 0.04)
	await get_tree().create_timer(0.04).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		area.get_parent()._confused()
