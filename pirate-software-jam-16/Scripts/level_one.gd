extends Node2D

var orcs: Array[Node]
var originalOrcCount: int
var targets: Array[Node]
var objective_complete: bool
var handled_win: bool
@onready var player = $Player
var level_ended: bool = false

func _ready():
	orcs = get_tree().get_nodes_in_group("Orcs")
	originalOrcCount = orcs.size()
	$TileMapLayer.visible = false
	
	# Deleting target particles
	$Orc/TargetParticles.queue_free()
	$Orc2/TargetParticles.queue_free()

func _process(delta):
	targets = get_tree().get_nodes_in_group("Targets")
	objective_complete = targets.size() == 1
	
	if Global.stamina.value <= 0 and not level_ended:
		level_ended = true
		Global.master._restart_level()
	
	if objective_complete and not handled_win and not level_ended:
		handled_win = true
		Global.master._next_level()
