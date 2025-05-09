extends Node2D

var orcs: Array[Node]
var originalOrcCount: int
var targets: Array[Node]
var objective_complete: bool
var handled_win: bool
var level_ended: bool = false
@onready var player = $Player
var weapon_ui_active: bool = false

func _ready():
	orcs = get_tree().get_nodes_in_group("Orcs")
	originalOrcCount = orcs.size()
	targets = get_tree().get_nodes_in_group("Targets")
	$TileMapLayer.visible = false

func _process(delta):
	targets = get_tree().get_nodes_in_group("Targets")
	objective_complete = targets.size() == 0
	
	if Global.stamina.value <= 0 and not level_ended and not level_ended:
		level_ended = true
		Global.master._restart_level()
	
	if objective_complete and not handled_win:
		handled_win = true
		#For now i have a fade and restart game because no new level, but this can be replaced with similar to how level one 
		#does it. Billy wants to put in a popup for objective complete as well.
		Global.master._last_level_win()
		await get_tree().create_timer(2).timeout
		Global.Transitioner._fade(false)
		await get_tree().create_timer(3).timeout
		get_tree().reload_current_scene()
