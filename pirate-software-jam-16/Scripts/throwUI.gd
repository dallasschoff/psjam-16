extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("up") or Input.is_action_pressed("left"):
		pass
	if Input.is_action_pressed("down") or Input.is_action_pressed("right"):
		pass
