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

func _process(delta):
	targets = get_tree().get_nodes_in_group("Targets")
	objective_complete = targets.size() == 0
	
	if Global.stamina.value <= 0 and not level_ended:
		level_ended = true
		Global.master._restart_level()
	
	if objective_complete and not handled_win and not level_ended:
		handled_win = true
		Global.master._next_level()
	#Handle weapon UI
	if player.isPossessing and not weapon_ui_active:
		weapon_ui_active = true
		var tween = get_tree().create_tween()
		tween.tween_property(ui_bg, "position", Vector2(-34, 101), 0.6)
		tween.tween_property(ui_bg, "position", Vector2(-34, 103), 0.2)
		var tween2 = get_tree().create_tween()
		tween2.tween_property(weapon_ui, "position", Vector2(-34, 101), 0.6)
		tween2.tween_property(weapon_ui, "position", Vector2(-34, 103), 0.2)
		var tween3 = get_tree().create_tween()
		tween3.tween_property(ui_bg2, "position", Vector2(19, 101), 0.6)
		tween3.tween_property(ui_bg2, "position", Vector2(19, 103), 0.2)
		var tween4 = get_tree().create_tween()
		tween4.tween_property(weaponthrow_ui, "position", Vector2(19, 101), 0.6)
		tween4.tween_property(weaponthrow_ui, "position", Vector2(19, 103), 0.2)
	if player.isPossessing == false and weapon_ui_active:
		weapon_ui_active = false
		var tween = get_tree().create_tween()
		tween.tween_property(ui_bg, "position", Vector2(-34, 101), 0.2)
		tween.tween_property(ui_bg, "position", Vector2(-34, 139), 0.8)
		var tween2 = get_tree().create_tween()
		tween2.tween_property(weapon_ui, "position", Vector2(-34, 101), 0.2)
		tween2.tween_property(weapon_ui, "position", Vector2(-34, 139), 0.8)
		var tween3 = get_tree().create_tween()
		tween3.tween_property(ui_bg2, "position", Vector2(19, 101), 0.2)
		tween3.tween_property(ui_bg2, "position", Vector2(19, 139), 0.8)
		var tween4 = get_tree().create_tween()
		tween4.tween_property(weaponthrow_ui, "position", Vector2(19, 101), 0.2)
		tween4.tween_property(weaponthrow_ui, "position", Vector2(19, 139), 0.8)
