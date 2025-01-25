extends Control

var game_started = false

func _process(float) -> void:
	if Input.is_action_just_pressed("enter") and not game_started:
		_on_start_button_pressed()
		game_started = true

func _on_start_button_pressed():
	SignalBus.start_game.emit()
