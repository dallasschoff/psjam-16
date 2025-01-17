extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#rotation = clamp(rotation, -90, 150)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("up") or Input.is_action_pressed("left"):
		rotation -= 0.2
	if Input.is_action_pressed("down") or Input.is_action_pressed("right"):
		rotation += 0.2
	#rotation = clamp(rotation, -90, 150)
