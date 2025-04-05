extends Control

var game_started = false
var mobileControls : bool = false

func _ready():
	$"MarginContainer/VBoxContainer/Start Button".grab_focus()
	SignalBus.transition_finished.connect(_start_game) #Emitted by transitioner
	Global.MainMenu = self

func _on_start_button_pressed():
	$"MarginContainer/VBoxContainer/Start Button".release_focus()
	Global.Transitioner._fade(true)
	
func _start_game():
	SignalBus.start_game.emit() #Connects to master

func _on_mobile_controls_button_toggled(toggled_on: bool) -> void:
	if toggled_on == true: mobileControls = true
	else: mobileControls = false
