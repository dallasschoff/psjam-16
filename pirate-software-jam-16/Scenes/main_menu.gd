extends Control


func _on_start_button_pressed():
	SignalBus.start_game.emit()
