extends Node2D

var orcs: Array[Node]
var originalOrcCount: int
var targets: Array[Node]
var originalTargetsCount: int
var objective_complete: bool
var handled_win: bool
@onready var player = $Player
var level_ended: bool = false

var weaponsGroup : Array
var possessedWeapon : Node2D

func _ready():
	orcs = get_tree().get_nodes_in_group("Orcs")
	originalOrcCount = orcs.size()
	targets = get_tree().get_nodes_in_group("Targets")
	originalTargetsCount = targets.size()
	$TileMapLayer.visible = false
	
	# Deleting target particles
	$Orc/TargetParticles.queue_free()
	$Orc2/TargetParticles.queue_free()

func _process(_delta):
	targets = get_tree().get_nodes_in_group("Targets")
	objective_complete = targets.size() < originalTargetsCount
	
	if Global.stamina.value <= 0 and not level_ended:
		level_ended = true
		Global.master._restart_level()
	
	if objective_complete and not handled_win and not level_ended:
		handled_win = true
		Global.master._next_level()
	
	#if Input.is_action_just_pressed("enter"):
		#weaponsGroup = get_tree().get_nodes_in_group("Weapons")
		#for i in weaponsGroup:
			#if i.possessed == true:
				#possessedWeapon = i
				#print(possessedWeapon)
