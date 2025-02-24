extends Node2D

var orcs: Array[Node]
var originalOrcCount: int
var targets: Array[Node]
var objective_complete: bool
var handled_win: bool
var level_ended: bool = false
@onready var player = $Player
@onready var ui_bg = $Camera2D/bg
@onready var weapon_ui = $Camera2D/WeaponUI
@onready var ui_bg2 = $Camera2D/bg2
@onready var weaponthrow_ui = $Camera2D/WeaponThrowUI
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
		Global.master._next_level()
