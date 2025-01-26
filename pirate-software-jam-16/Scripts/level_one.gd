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
		#**Uncomment this to see transition after win**
		#await get_tree().create_timer(1).timeout
		#Global.Transitioner._fade(false)
		print("Objective Complete!")
