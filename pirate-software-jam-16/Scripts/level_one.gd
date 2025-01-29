extends Node2D

var orcs: Array[Node]
var originalOrcCount: int
var objective_complete: bool
var handled_win: bool

func _ready():
	orcs = get_tree().get_nodes_in_group("Orcs")
	originalOrcCount = orcs.size()

func _process(delta):
	orcs = get_tree().get_nodes_in_group("Orcs")
	objective_complete = orcs.size() < originalOrcCount
	
	if objective_complete and not handled_win:
		handled_win = true
		Global.master._next_level()
