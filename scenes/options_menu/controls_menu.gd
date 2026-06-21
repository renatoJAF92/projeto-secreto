extends Control

var _waiting_for_input: String = ""

const _ACTION_ROWS := {
	"walk_left":  "ActionList/ActionRow_WalkLeft",
	"walk_right": "ActionList/ActionRow_WalkRight",
	"jump":       "ActionList/ActionRow_Jump",
	"dash":       "ActionList/ActionRow_Dash",
	"attack":     "ActionList/ActionRow_Attack",
	"block":      "ActionList/ActionRow_Block",
}


func _ready() -> void:
	for action in _ACTION_ROWS:
		var remap_btn: Button = get_node(_ACTION_ROWS[action] + "/RemapButton")
		remap_btn.pressed.connect(start_remap.bind(action))
	$BottomButtons/ResetButton.pressed.connect(_on_reset)
	$BottomButtons/BackButton.pressed.connect(_on_back)
	_refresh_ui()


func start_remap(action_name: String) -> void:
	_waiting_for_input = action_name
	var lbl: Label = get_node(_ACTION_ROWS[action_name] + "/BindingLabel")
	lbl.text = "Pressione uma tecla..."
	lbl.modulate = Color(0.533333, 0.533333, 0.666667, 1)


func _input(event: InputEvent) -> void:
	if _waiting_for_input.is_empty():
		return

	if event is InputEventKey and event.physical_keycode == KEY_ESCAPE and event.pressed:
		_waiting_for_input = ""
		_refresh_ui()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_B and event.pressed:
		_waiting_for_input = ""
		_refresh_ui()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventJoypadMotion and abs(event.axis_value) <= 0.5:
		return

	var accepted := false
	if event is InputEventKey and event.pressed:
		accepted = true
	elif event is InputEventJoypadButton and event.pressed:
		accepted = true
	elif event is InputEventJoypadMotion and abs(event.axis_value) > 0.5:
		accepted = true

	if accepted:
		get_viewport().set_input_as_handled()
		ControlsManager.remap_action(_waiting_for_input, event)
		_waiting_for_input = ""
		_refresh_ui()


func _refresh_ui() -> void:
	for action in _ACTION_ROWS:
		var lbl: Label = get_node(_ACTION_ROWS[action] + "/BindingLabel")
		lbl.modulate = Color(1, 1, 1, 1)
		var events := InputMap.action_get_events(action)
		if events.is_empty():
			lbl.text = "-"
			continue
		var parts: PackedStringArray = []
		for ev in events:
			if ev is InputEventKey:
				var k := OS.get_keycode_string(ev.physical_keycode)
				if not k.is_empty():
					parts.append(k)
			elif ev is InputEventJoypadButton:
				parts.append("BTN%d" % ev.button_index)
			elif ev is InputEventJoypadMotion:
				parts.append("AXIS%d" % ev.axis)
		lbl.text = " / ".join(parts) if not parts.is_empty() else "?"
		var has_pad := events.any(func(e): return e is InputEventJoypadButton or e is InputEventJoypadMotion)
		if has_pad:
			lbl.modulate = Color(1.0, 0.866667, 0.341176, 1)


func _on_reset() -> void:
	var dir := DirAccess.open("user://")
	if dir and dir.file_exists("controls.cfg"):
		dir.remove("controls.cfg")
	InputMap.load_from_project_settings()
	ControlsManager._add_gamepad_defaults()
	_refresh_ui()


func _on_back() -> void:
	SceneTransition.go_to("res://scenes/options_menu/options_menu.tscn")
