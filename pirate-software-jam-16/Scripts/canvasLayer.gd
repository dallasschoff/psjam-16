extends CanvasLayer

@onready var ui_bg = $bg
@onready var weapon_ui = $WeaponUI
@onready var ui_bg2 = $bg2
@onready var weaponthrow_ui = $WeaponThrowUI

var mobileControls : bool = false
@onready var ghostMovementStick = $GhostMovement
@onready var mobileWeaponUI = $MWeaponUI
@onready var upTouchScreenButton = $MWeaponUI/UpTouchScreenButton
@onready var leftTouchScreenButton = $MWeaponUI/LeftTouchScreenButton
@onready var rightTouchScreenButton = $MWeaponUI/RightTouchScreenButton
@onready var downTouchScreenButton = $MWeaponUI/DownTouchScreenButton
@onready var spaceButton = $SpaceTouchScreenButton
var spaceButtonActive : bool = false
@onready var throwJS = $ThrowJS
var throwJSActive : bool = false

var mobile_weapon_ui_active: bool = false

@onready var player = $"../Player"
@onready var parent = get_parent()
var weapon_ui_active: bool = false

@onready var main_menu = Global.MainMenu

#Starting positions
var ui_bg_position_lvl_1 = Vector2(800, 1295)
var ui_bg_position = Vector2(650, 1295)
var ui_bg2_position = Vector2(950, 1295)

var mobileWeaponUI_up_position = Vector2(275, 950)
var mobileWeaponUI_down_position = Vector2(275, 1380)

var ghostMovementStick_up_position = Vector2(100, 800)
var ghostMovementStick_down_position = Vector2(100, 1295)

var spaceButton_up_position = Vector2(950, 975)
var spaceButton_down_position = Vector2(950, 1200)

var throwJS_up_position = Vector2(2100, 900)
var throwJS_down_position = Vector2(2100, 1230)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if main_menu.mobileControls == true:
		mobileControls = true
		ghostMovementStick.position = ghostMovementStick_up_position
	if main_menu.mobileControls == false: 
		mobileControls = false
		ghostMovementStick.position = ghostMovementStick_down_position
	throwJS.position = throwJS_down_position
	#Set some starting positions of UI elements
	if parent.name == "LevelOne":
		ui_bg.position = ui_bg_position_lvl_1
	if parent.name != "LevelOne":
		ui_bg.position = ui_bg_position
		ui_bg2.position = ui_bg2_position
	mobileWeaponUI.position = mobileWeaponUI_down_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if mobileControls == true:
		_handle_mobile_ui()
	if mobileControls == false:
		_handle_kb_ui()
	#Update color according to player stamina
	if player.stamina_color != null:
		ghostMovementStick._base.modulate = player.stamina_color
		throwJS._base.modulate = player.stamina_color
		if mobileControls == true:
			upTouchScreenButton.modulate = player.stamina_color
			leftTouchScreenButton.modulate = player.stamina_color
			rightTouchScreenButton.modulate = player.stamina_color
			downTouchScreenButton.modulate = player.stamina_color

func _handle_mobile_ui():
	#Handle possess button UI
	if player.canPossess and !spaceButtonActive:
			_raise_space_button()
	if player.isPossessing == false and player.canPossess == false and spaceButtonActive:
			_lower_space_button()
	
	#Handle throw joystick

	if player.isPossessing and !throwJSActive and parent.name != "LevelOne":
		_raise_throwJS()
		
	if player.isPossessing == false and throwJSActive:
		_lower_throwJS()
	
	#Movement stick is visible by default. Need to make it go away when possessing
	#Appear weapon UI
	if player.isPossessing and not mobile_weapon_ui_active:
		_raise_weapon_ui()
		#Make movement stick go away
		ghostMovementStick.position = ghostMovementStick_down_position
	
	#Disappear weapon UI
	if player.isPossessing == false and mobile_weapon_ui_active:
		_lower_weapon_ui()
		#Make movement stick appear
		_raise_movement_stick()
		
func _raise_weapon_ui():
	mobile_weapon_ui_active = true
	var tween = get_tree().create_tween()
	tween.tween_property(mobileWeaponUI, "position", mobileWeaponUI_up_position - Vector2(0, 10), 0.6)
	tween.tween_property(mobileWeaponUI, "position", mobileWeaponUI_up_position, 0.2)
func _lower_weapon_ui():
		mobile_weapon_ui_active = false
		#var tween = get_tree().create_tween()
		#tween.tween_property(mobileWeaponUI, "position", Vector2(180, 1010), 0.2)
		#tween.tween_property(mobileWeaponUI, "position", Vector2(180, 1360), 0.8)
		mobileWeaponUI.position = mobileWeaponUI_down_position

func _raise_movement_stick():
	var tween2 = get_tree().create_tween()
	tween2.tween_property(ghostMovementStick, "position", ghostMovementStick_up_position - Vector2(0, 10), 0.6)
	tween2.tween_property(ghostMovementStick, "position", ghostMovementStick_up_position, 0.2)
	#ghostMovementStick.position = Vector2(0, 892)

func _raise_space_button():
	spaceButtonActive = true
	var tween = get_tree().create_tween()
	tween.tween_property(spaceButton, "position", spaceButton_up_position - Vector2(0, 10), 0.4)
	tween.tween_property(spaceButton, "position", spaceButton_up_position, 0.2)
func _lower_space_button():
	spaceButtonActive = false
	var tween = get_tree().create_tween()
	tween.tween_property(spaceButton, "position", spaceButton_up_position - Vector2(0, 10), 0.2)
	tween.tween_property(spaceButton, "position", spaceButton_down_position, 0.4)

func _raise_throwJS():
	throwJSActive = true
	var tween = get_tree().create_tween()
	tween.tween_property(throwJS, "position", throwJS_up_position - Vector2(0, 10), 0.4)
	tween.tween_property(throwJS, "position", throwJS_up_position, 0.2)
func _lower_throwJS():
	throwJSActive = false
	var tween = get_tree().create_tween()
	tween.tween_property(throwJS, "position", throwJS_up_position - Vector2(0, 10), 0.2)
	tween.tween_property(throwJS, "position", throwJS_down_position, 0.4)

func _handle_kb_ui():
	#Handle weapon UI
	if parent.name == "LevelOne":
		#Appear
		if player.isPossessing and not weapon_ui_active:
			weapon_ui_active = true
			var tween = get_tree().create_tween()
			tween.tween_property(ui_bg, "position", Vector2(800, 1100), 0.6)
			tween.tween_property(ui_bg, "position", Vector2(800, 1110), 0.2)
			var tween2 = get_tree().create_tween()
			tween2.tween_property(weapon_ui, "position", Vector2(800, 1100), 0.6)
			tween2.tween_property(weapon_ui, "position", Vector2(800, 1110), 0.2)
		#Disappear
		if player.isPossessing == false and weapon_ui_active:
			weapon_ui_active = false
			var tween = get_tree().create_tween()
			tween.tween_property(ui_bg, "position", Vector2(800, 1100), 0.2)
			tween.tween_property(ui_bg, "position", Vector2(800, 1285), 0.8)
			var tween2 = get_tree().create_tween()
			tween2.tween_property(weapon_ui, "position", Vector2(800, 1100), 0.2)
			tween2.tween_property(weapon_ui, "position", Vector2(800, 1285), 0.8)
	if parent.name != "LevelOne":
		#Appear
		if player.isPossessing and not weapon_ui_active:
			weapon_ui_active = true
			var tween = get_tree().create_tween()
			tween.tween_property(ui_bg, "position", Vector2(650, 1100), 0.6)
			tween.tween_property(ui_bg, "position", Vector2(650, 1110), 0.2)
			var tween2 = get_tree().create_tween()
			tween2.tween_property(weapon_ui, "position", Vector2(650, 1100), 0.6)
			tween2.tween_property(weapon_ui, "position", Vector2(650, 1110), 0.2)
			var tween3 = get_tree().create_tween()
			tween3.tween_property(ui_bg2, "position", Vector2(950, 1100), 0.6)
			tween3.tween_property(ui_bg2, "position", Vector2(950, 1110), 0.2)
			var tween4 = get_tree().create_tween()
			tween4.tween_property(weaponthrow_ui, "position", Vector2(950, 1100), 0.6)
			tween4.tween_property(weaponthrow_ui, "position", Vector2(950, 1110), 0.2)
		#Disappear
		if player.isPossessing == false and weapon_ui_active:
			weapon_ui_active = false
			var tween = get_tree().create_tween()
			tween.tween_property(ui_bg, "position", Vector2(650, 1100), 0.2)
			tween.tween_property(ui_bg, "position", Vector2(650, 1285), 0.8)
			var tween2 = get_tree().create_tween()
			tween2.tween_property(weapon_ui, "position", Vector2(650, 1100), 0.2)
			tween2.tween_property(weapon_ui, "position", Vector2(650, 1285), 0.8)
			var tween3 = get_tree().create_tween()
			tween3.tween_property(ui_bg2, "position", Vector2(950, 1100), 0.2)
			tween3.tween_property(ui_bg2, "position", Vector2(950, 1285), 0.8)
			var tween4 = get_tree().create_tween()
			tween4.tween_property(weaponthrow_ui, "position", Vector2(950, 1100), 0.2)
			tween4.tween_property(weaponthrow_ui, "position", Vector2(950, 1285), 0.8)
