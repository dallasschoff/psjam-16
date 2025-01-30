extends Node2D

var orcs: Array[Node]
var originalOrcCount: int
var objective_complete: bool
var handled_win: bool
@onready var player = $Player
@onready var ui_bg = $Camera2D/bg
@onready var weapon_ui = $Camera2D/WeaponUI
var weapon_ui_active: bool = false

func _ready():
	orcs = get_tree().get_nodes_in_group("Orcs")
	originalOrcCount = orcs.size()
	$TileMapLayer.visible = false

func _process(delta):
	#Handle win
	orcs = get_tree().get_nodes_in_group("Orcs")
	objective_complete = orcs.size() < originalOrcCount
	if objective_complete and not handled_win:
		handled_win = true
		Global.master._next_level()
	#Handle weapon UI
	if player.isPossessing and not weapon_ui_active:
		weapon_ui_active = true
		var tween = get_tree().create_tween()
		tween.tween_property(ui_bg, "position", Vector2(0, 101), 0.8)
		tween.tween_property(ui_bg, "position", Vector2(0, 103), 0.2)
		var tween2 = get_tree().create_tween()
		tween2.tween_property(weapon_ui, "position", Vector2(0, 101), 0.8)
		tween2.tween_property(weapon_ui, "position", Vector2(0, 103), 0.2)
	if player.isPossessing == false and weapon_ui_active:
		weapon_ui_active = false
		var tween = get_tree().create_tween()
		tween.tween_property(ui_bg, "position", Vector2(0, 101), 0.2)
		tween.tween_property(ui_bg, "position", Vector2(0, 139), 0.8)
		var tween2 = get_tree().create_tween()
		tween2.tween_property(weapon_ui, "position", Vector2(0, 101), 0.2)
		tween2.tween_property(weapon_ui, "position", Vector2(0, 139), 0.8)
