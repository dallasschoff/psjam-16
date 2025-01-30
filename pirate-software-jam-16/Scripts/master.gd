extends Control

@onready var mainMenu: Control = $MainMenu
var current_level_string
var current_level
var levels: Array[String] = [
	"res://Scenes/LevelOne.tscn",
	"res://Scenes/LevelTwo.tscn",
	"res://Scenes/LevelThree.tscn"
	]
var level_index: int = 0
@onready var winningSFXLength = $WinningSound.stream.get_length()
@onready var losingSFXLength = $LosingSound.stream.get_length()

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.master = self
	SignalBus.start_game.connect(_start_game) #Emitted by main menu
	Global.Transitioner = $Transitioner

func _start_game():
	current_level_string = levels[level_index]
	var scene = load(current_level_string).instantiate()
	mainMenu.hide()
	add_child(scene)
	current_level = scene
	Global.Transitioner._unfade()

func _next_level():
	# play winning sound
	$OST.stop()
	await get_tree().create_timer(1).timeout
	$WinningSound.play()
	await get_tree().create_timer(winningSFXLength + 1).timeout
	$OST.play()
	
	#await get_tree().create_timer(1).timeout
	Global.Transitioner._fade(false)
	await get_tree().create_timer(1.5).timeout
	level_index += 1
	current_level.queue_free()
	current_level_string = levels[level_index]
	var scene = load(current_level_string).instantiate()
	mainMenu.hide()
	add_child(scene)
	current_level = scene
	Global.Transitioner._unfade()

func _restart_level():
	# play losing sound
	$OST.stop()
	await get_tree().create_timer(1).timeout
	$LosingSound.play()
	#await get_tree().create_timer(losingSFXLength + 1).timeout
	#$OST.play()

	await get_tree().create_timer(0.5).timeout 
	Global.Transitioner._fade(false)
	await get_tree().create_timer(1.5).timeout
	$OST.play()
	current_level.queue_free()
	var scene = load(current_level_string).instantiate()
	mainMenu.hide()
	add_child(scene)
	current_level = scene
	Global.Transitioner._unfade()
