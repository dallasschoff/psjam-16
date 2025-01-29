extends Node2D

var orcs: Array[Node]
var originalOrcCount: int
var targets: Array[Node]
var objective_complete: bool
var handled_win: bool
var level_ended: bool = false

func _ready():
	orcs = get_tree().get_nodes_in_group("Orcs")
	originalOrcCount = orcs.size()
	targets = get_tree().get_nodes_in_group("Targets")

func _process(delta):
	targets = get_tree().get_nodes_in_group("Targets")
	objective_complete = targets.size() == 0
	
	if Global.stamina.value <= 0 and not level_ended:
		level_ended = true
		Global.master._restart_level()
	
	if objective_complete and not handled_win:
		handled_win = true
		#For now i have a fade and restart game because no new level, but this can be replaced with similar to how level one 
		#does it. Billy wants to put in a popup for objective complete as well.
		await get_tree().create_timer(1).timeout
		Global.Transitioner._fade(false)
		await get_tree().create_timer(2).timeout
		get_tree().reload_current_scene()
