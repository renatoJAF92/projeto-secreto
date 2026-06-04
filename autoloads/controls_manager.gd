extends Node

const CONTROLS_PATH := "user://controls.cfg"
const ACTIONS := ["walk_left", "walk_right", "jump", "dash"]

func _ready() -> void:
	_add_gamepad_defaults()
	load_controls()

func _add_gamepad_defaults() -> void:
	# Pulo: botão A (JOY_BUTTON_A = 0) — padrão Xbox/DualSense South (ACCESS-03)
	var joy_jump := InputEventJoypadButton.new()
	joy_jump.button_index = JOY_BUTTON_A
	InputMap.action_add_event("jump", joy_jump)

	# Dash: botão B (JOY_BUTTON_B = 1) — padrão Xbox East / DualSense Circle
	var joy_dash := InputEventJoypadButton.new()
	joy_dash.button_index = JOY_BUTTON_B
	InputMap.action_add_event("dash", joy_dash)

	# Movimento: Left Stick — JOY_AXIS_LEFT_X = 0
	var joy_left := InputEventJoypadMotion.new()
	joy_left.axis = JOY_AXIS_LEFT_X
	joy_left.axis_value = -1.0
	InputMap.action_add_event("walk_left", joy_left)

	var joy_right := InputEventJoypadMotion.new()
	joy_right.axis = JOY_AXIS_LEFT_X
	joy_right.axis_value = 1.0
	InputMap.action_add_event("walk_right", joy_right)

func load_controls() -> void:
	var config := ConfigFile.new()
	if config.load(CONTROLS_PATH) != OK:
		return  # Sem arquivo: usa defaults do project.godot + gamepad
	for action in ACTIONS:
		if config.has_section(action):
			InputMap.action_erase_events(action)
			for event_data in config.get_value(action, "events", []):
				var event := _deserialize_event(event_data)
				if event:
					InputMap.action_add_event(action, event)

func save_controls() -> void:
	var config := ConfigFile.new()
	for action in ACTIONS:
		var events := InputMap.action_get_events(action)
		var serialized := []
		for event in events:
			var s := _serialize_event(event)
			if s:
				serialized.append(s)
		config.set_value(action, "events", serialized)
	config.save(CONTROLS_PATH)

func remap_action(action: String, new_event: InputEvent) -> void:
	# Detectar conflito: remover new_event de outras ações (mitiga T-02-05 DoS)
	for other_action in ACTIONS:
		if other_action != action:
			InputMap.action_erase_event(other_action, new_event)
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, new_event)
	save_controls()  # Salvar imediatamente após remap (Pitfall 5)

func _serialize_event(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		return {"type": "key", "physical_keycode": event.physical_keycode}
	elif event is InputEventJoypadButton:
		return {"type": "joypad_button", "button_index": event.button_index}
	elif event is InputEventJoypadMotion:
		return {"type": "joypad_motion", "axis": event.axis, "axis_value": event.axis_value}
	return {}

func _deserialize_event(data: Dictionary) -> InputEvent:
	match data.get("type", ""):
		"key":
			var e := InputEventKey.new()
			e.physical_keycode = data["physical_keycode"]
			return e
		"joypad_button":
			var e := InputEventJoypadButton.new()
			e.button_index = data["button_index"]
			return e
		"joypad_motion":
			var e := InputEventJoypadMotion.new()
			e.axis = data["axis"]
			e.axis_value = data["axis_value"]
			return e
	return null
