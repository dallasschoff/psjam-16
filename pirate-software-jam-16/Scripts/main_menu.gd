extends Control

var game_started = false

func _ready():
	$"MarginContainer/VBoxContainer/Start Button".grab_focus()
	SignalBus.transition_finished.connect(_start_game)

func _on_start_button_pressed():
	$"MarginContainer/VBoxContainer/Start Button".release_focus()
	Global.Transitioner._fade(true)
	
func _start_game():
	SignalBus.start_game.emit()
