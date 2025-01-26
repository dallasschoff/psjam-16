extends Control

@onready var mainMenu: Control = $MainMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.start_game.connect(_start_game)
	Global.Transitioner = $Transitioner

func _start_game():
	var scene = load(Global.levelOne).instantiate()
	add_child(scene)
	Global.Transitioner._unfade()
