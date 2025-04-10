class_name VirtualJoystick

extends Control

## A simple virtual joystick for touchscreens, with useful options.
## Github: https://github.com/MarcoFazioRandom/Virtual-Joystick-Godot

# Other variables
var value1
var value2
var t 
@onready var baseSprite = $Base/BaseSprite
@onready var tipSprite = $Base/Tip/TipSprite
@onready var throwText = $Base/Tip/TipSprite/ThrowText
@onready var controllerSprite = $ControllerSprite
@onready var arrowSprite = $ArrowSprite

var direction
var stamina_warning : bool
var stamina_color

# EXPORTED VARIABLE

## The color of the button when the joystick is pressed.
@export var pressed_color := Color.GRAY

## If the input is inside this range, the output is zero.
@export_range(0, 200, 1) var deadzone_size : float = 10

## The max distance the tip can reach.
@export_range(0, 500, 1) var clampzone_size : float = 75

enum Joystick_mode {
	FIXED, ## The joystick doesn't move.
	DYNAMIC, ## Every time the joystick area is pressed, the joystick position is set on the touched position.
	FOLLOWING ## When the finger moves outside the joystick area, the joystick will follow it.
}

## If the joystick stays in the same position or appears on the touched position when touch is started
@export var joystick_mode := Joystick_mode.FIXED

enum Visibility_mode {
	ALWAYS, ## Always visible
	TOUCHSCREEN_ONLY, ## Visible on touch screens only
	WHEN_TOUCHED ## Visible only when touched
}

## If the joystick is always visible, or is shown only if there is a touchscreen
@export var visibility_mode := Visibility_mode.ALWAYS

## If true, the joystick uses Input Actions (Project -> Project Settings -> Input Map)
@export var use_input_actions := true

@export var action_left := "ui_left"
@export var action_right := "ui_right"
@export var action_up := "ui_up"
@export var action_down := "ui_down"

## If true, joystick functions for throwing
@export var throw_js := false

# PUBLIC VARIABLES

## If the joystick is receiving inputs.
var is_pressed := false

# The joystick output.
var output := Vector2.ZERO

# PRIVATE VARIABLES

var _touch_index : int = -1

@onready var _base := $Base
@onready var _tip := $Base/Tip

@onready var _base_default_position : Vector2 = _base.position
@onready var _tip_default_position : Vector2 = _tip.position

@onready var _default_color : Color = _tip.modulate

# FUNCTIONS

func _ready() -> void:
	#if ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch"):
		#printerr("The Project Setting 'emulate_mouse_from_touch' should be set to False")
	if not ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse"):
		printerr("The Project Setting 'emulate_touch_from_mouse' should be set to True")
	
	if not DisplayServer.is_touchscreen_available() and visibility_mode == Visibility_mode.TOUCHSCREEN_ONLY :
		hide()
	
	if visibility_mode == Visibility_mode.WHEN_TOUCHED:
		hide()
	
	if throw_js:
		clampzone_size = 125

func _process(delta: float) -> void:
	updatePlayerStamina()
	controllerSprite.global_position = tipSprite.global_position
	##Make throw arrow visible on the JS itself
	if throw_js and Input.is_action_pressed("enter"):
		#arrowSprite.visible = true
		controllerSprite.visible = true
		tipSprite.visible = false
	if throw_js and not Input.is_action_pressed("enter"):
		arrowSprite.visible = false
		controllerSprite.visible = false
		$Base/BaseSprite.visible = true
		tipSprite.visible = true
	#Make sprites visible for throw JS
	if throw_js:
		$Base.texture = null
		#load("null")
		$Base/Tip.texture = null
		#oad("null")
		$Base/BaseSprite.visible = true
		$Base/StaminaBar.visible = false
		controllerSprite.look_at(_base.global_position + _base.pivot_offset)
		arrowSprite.look_at(_base.global_position + _base.pivot_offset)
		
		var direction = Vector2(0,0)
		direction.x = -Input.get_action_strength("left") + Input.get_action_strength("right")
		direction.y = +Input.get_action_strength("down") - Input.get_action_strength("up")
		value1 =  arrowSprite.position
		value2 = -direction * 160 + _base.position + _base.pivot_offset
		t = 5.0 * delta
		arrowSprite.position = value1.lerp(value2, t)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _is_point_inside_joystick_area(event.position) and _touch_index == -1:
				if joystick_mode == Joystick_mode.DYNAMIC or joystick_mode == Joystick_mode.FOLLOWING or (joystick_mode == Joystick_mode.FIXED and _is_point_inside_base(event.position)):
					if joystick_mode == Joystick_mode.DYNAMIC or joystick_mode == Joystick_mode.FOLLOWING:
						_move_base(event.position)
					if visibility_mode == Visibility_mode.WHEN_TOUCHED:
						show()
					_touch_index = event.index
					if not throw_js:
						_tip.modulate = pressed_color
					_update_joystick(event.position)
					get_viewport().set_input_as_handled()
		elif event.index == _touch_index:
			_reset()
			if visibility_mode == Visibility_mode.WHEN_TOUCHED:
				hide()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		if event.index == _touch_index:
			_update_joystick(event.position)
			get_viewport().set_input_as_handled()

func _move_base(new_position: Vector2) -> void:
	_base.global_position = new_position - _base.pivot_offset * get_global_transform_with_canvas().get_scale()

func _move_tip(new_position: Vector2) -> void:
	_tip.global_position = new_position - _tip.pivot_offset * _base.get_global_transform_with_canvas().get_scale()

func _is_point_inside_joystick_area(point: Vector2) -> bool:
	var x: bool = point.x >= global_position.x and point.x <= global_position.x + (size.x * get_global_transform_with_canvas().get_scale().x)
	var y: bool = point.y >= global_position.y and point.y <= global_position.y + (size.y * get_global_transform_with_canvas().get_scale().y)
	return x and y

func _get_base_radius() -> Vector2:
	return _base.size * _base.get_global_transform_with_canvas().get_scale() / 2

func _is_point_inside_base(point: Vector2) -> bool:
	var _base_radius = _get_base_radius()
	var center : Vector2 = _base.global_position + _base_radius
	var vector : Vector2 = point - center
	if vector.length_squared() <= _base_radius.x * _base_radius.x:
		return true
	else:
		return false

func _update_joystick(touch_position: Vector2) -> void:
	var _base_radius = _get_base_radius()
	var center : Vector2 = _base.global_position + _base_radius
	var vector : Vector2 = touch_position - center
	vector = vector.limit_length(clampzone_size)
	
	if joystick_mode == Joystick_mode.FOLLOWING and touch_position.distance_to(center) > clampzone_size:
		_move_base(touch_position - vector)
	
	_move_tip(center + vector)
	
	if vector.length_squared() > deadzone_size * deadzone_size:
		is_pressed = true
		output = (vector - (vector.normalized() * deadzone_size)) / (clampzone_size - deadzone_size)
	else:
		is_pressed = false
		output = Vector2.ZERO
	
	#Make throw UI appear when throw joystick is touched
	if throw_js:
		Input.action_press("enter")
	
	if use_input_actions:
		# Release actions
		if output.x >= 0 and Input.is_action_pressed(action_left):
			Input.action_release(action_left)
		if output.x <= 0 and Input.is_action_pressed(action_right):
			Input.action_release(action_right)
		if output.y >= 0 and Input.is_action_pressed(action_up):
			Input.action_release(action_up)
		if output.y <= 0 and Input.is_action_pressed(action_down):
			Input.action_release(action_down)
		# Press actions
		if output.x < 0:
			Input.action_press(action_left, -output.x)
		if output.x > 0:
			Input.action_press(action_right, output.x)
		if output.y < 0:
			Input.action_press(action_up, -output.y)
		if output.y > 0:
			Input.action_press(action_down, output.y)
		#print(output)

func _reset():
	is_pressed = false
	output = Vector2.ZERO
	_touch_index = -1
	_tip.modulate = _default_color
	_base.position = _base_default_position
	_tip.position = _tip_default_position
	# Release actions
	if use_input_actions:
		for action in [action_left, action_right, action_down, action_up]:
			if Input.is_action_pressed(action):
				Input.action_release(action)
		if throw_js:
			Input.action_release("enter")

func updatePlayerStamina():
	if Global.stamina != null:
		$Base/StaminaBar.value = Global.stamina.value
	##Update stamina color
	##var stamina_color
	#var stamina_ratio = $Base/StaminaBar.get_as_ratio()
	#var yellow_value = 0.8
	#
	#if stamina_ratio > yellow_value:
		#stamina_color = lerp(Color.YELLOW, Color8(255,255,255,255), (stamina_ratio - yellow_value) / (1-yellow_value))
	#if stamina_ratio <= yellow_value:
		#stamina_color = lerp(Color.RED, Color.YELLOW, stamina_ratio / yellow_value)
	#$Base/StaminaBar.tint_progress = Color(stamina_color)
