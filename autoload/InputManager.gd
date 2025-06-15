extends Node

signal input_mode_changed(mode: String)

enum InputMode { KEYBOARD, TOUCH }
var current_mode: InputMode = InputMode.KEYBOARD
var touch_controls_enabled: bool = false

var input_map: Dictionary = {
	"move_up": ["w", "up"],
	"move_down": ["s", "down"],
	"move_left": ["a", "left"],
	"move_right": ["d", "right"],
	"interact": ["e", "space"],
	"attack": ["space", "enter"],
	"block": ["shift"],
	"inventory": ["i", "tab"],
	"pause": ["escape"]
}

func _ready():
	detect_input_mode()
	setup_input_actions()
	
func _input(event):
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		switch_to_touch_mode()
	elif event is InputEventKey or event is InputEventMouseButton:
		switch_to_keyboard_mode()

func detect_input_mode():
	# Default to keyboard for desktop, touch for mobile
	if OS.get_name() in ["iOS", "Android"]:
		switch_to_touch_mode()
	else:
		switch_to_keyboard_mode()
		
func switch_to_touch_mode():
	if current_mode != InputMode.TOUCH:
		current_mode = InputMode.TOUCH
		touch_controls_enabled = true
		input_mode_changed.emit("touch")
		print("Switched to touch controls")
		
func switch_to_keyboard_mode():
	if current_mode != InputMode.KEYBOARD:
		current_mode = InputMode.KEYBOARD
		touch_controls_enabled = false
		input_mode_changed.emit("keyboard")
		print("Switched to keyboard controls")

func setup_input_actions():
	# Ensure all input actions are properly set up
	if not InputMap.has_action("move_up"):
		InputMap.add_action("move_up")
		var event = InputEventKey.new()
		event.keycode = KEY_W
		InputMap.action_add_event("move_up", event)
		event = InputEventKey.new()
		event.keycode = KEY_UP
		InputMap.action_add_event("move_up", event)
	
	if not InputMap.has_action("move_down"):
		InputMap.add_action("move_down")
		var event = InputEventKey.new()
		event.keycode = KEY_S
		InputMap.action_add_event("move_down", event)
		event = InputEventKey.new()
		event.keycode = KEY_DOWN
		InputMap.action_add_event("move_down", event)
	
	if not InputMap.has_action("move_left"):
		InputMap.add_action("move_left")
		var event = InputEventKey.new()
		event.keycode = KEY_A
		InputMap.action_add_event("move_left", event)
		event = InputEventKey.new()
		event.keycode = KEY_LEFT
		InputMap.action_add_event("move_left", event)
	
	if not InputMap.has_action("move_right"):
		InputMap.add_action("move_right")
		var event = InputEventKey.new()
		event.keycode = KEY_D
		InputMap.action_add_event("move_right", event)
		event = InputEventKey.new()
		event.keycode = KEY_RIGHT
		InputMap.action_add_event("move_right", event)
	
	if not InputMap.has_action("interact"):
		InputMap.add_action("interact")
		var event = InputEventKey.new()
		event.keycode = KEY_E
		InputMap.action_add_event("interact", event)
		event = InputEventKey.new()
		event.keycode = KEY_SPACE
		InputMap.action_add_event("interact", event)

func is_action_pressed(action: String) -> bool:
	return Input.is_action_pressed(action)

func is_action_just_pressed(action: String) -> bool:
	return Input.is_action_just_pressed(action) 