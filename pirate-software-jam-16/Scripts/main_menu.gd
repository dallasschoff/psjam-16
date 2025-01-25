extends Control

var game_started = false

func _ready():
	$"MarginContainer/VBoxContainer/Start Button".grab_focus()

func _on_start_button_pressed():
	SignalBus.start_game.emit()
