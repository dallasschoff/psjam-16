extends CanvasLayer

@onready var ui_bg = $bg
@onready var weapon_ui = $WeaponUI
@onready var player = $"../Player"
var weapon_ui_active: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		#Handle weapon UI
	if player.isPossessing and not weapon_ui_active:
		weapon_ui_active = true
		var tween = get_tree().create_tween()
		tween.tween_property(ui_bg, "position", Vector2(800, 1100), 0.6)
		tween.tween_property(ui_bg, "position", Vector2(800, 1110), 0.2)
		var tween2 = get_tree().create_tween()
		tween2.tween_property(weapon_ui, "position", Vector2(800, 1100), 0.6)
		tween2.tween_property(weapon_ui, "position", Vector2(800, 1110), 0.2)
	if player.isPossessing == false and weapon_ui_active:
		weapon_ui_active = false
		var tween = get_tree().create_tween()
		tween.tween_property(ui_bg, "position", Vector2(800, 1100), 0.2)
		tween.tween_property(ui_bg, "position", Vector2(800, 1285), 0.8)
		var tween2 = get_tree().create_tween()
		tween2.tween_property(weapon_ui, "position", Vector2(800, 1100), 0.2)
		tween2.tween_property(weapon_ui, "position", Vector2(800, 1285), 0.8)
