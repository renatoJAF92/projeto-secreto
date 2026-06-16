extends Control

var _waiting_for_input: String = ""
var _came_from_pause: bool = false

const _ACTION_ROWS := {
	"walk_left": "ActionList/ActionRow_WalkLeft",
	"walk_right": "ActionList/ActionRow_WalkRight",
	"jump": "ActionList/ActionRow_Jump",
	"dash": "ActionList/ActionRow_Dash",
}

@onready var _music_slider: HSlider = $AudioSection/MusicRow/MusicSlider
@onready var _sfx_slider: HSlider = $AudioSection/SFXRow/SFXSlider
@onready var _music_val: Label = $AudioSection/MusicRow/MusicValueLabel
@onready var _sfx_val: Label = $AudioSection/SFXRow/SFXValueLabel


func _ready() -> void:
	var prev := SceneTransition.previous_scene
	_came_from_pause = ("fase" in prev or "mundo" in prev or "boss" in prev or "world" in prev)

	_music_slider.value = SaveManager.current_save.get("music_volume", 0.8)
	_sfx_slider.value = SaveManager.current_save.get("sfx_volume", 1.0)
	_update_volume_labels()

	_music_slider.value_changed.connect(_on_music_volume_changed)
	_sfx_slider.value_changed.connect(_on_sfx_volume_changed)

	for action in ControlsManager.ACTIONS:
		var remap_btn: Button = get_node(_ACTION_ROWS[action] + "/RemapButton")
		remap_btn.pressed.connect(start_remap.bind(action))
	$BottomButtons/ResetButton.pressed.connect(_on_reset)
	$BottomButtons/BackButton.pressed.connect(_on_back)
	_refresh_ui()


func _on_music_volume_changed(value: float) -> void:
	AudioManager.set_music_volume(value)
	SaveManager.current_save["music_volume"] = value
	SaveManager.save()
	_update_volume_labels()


func _on_sfx_volume_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)
	SaveManager.current_save["sfx_volume"] = value
	SaveManager.save()
	_update_volume_labels()


func _update_volume_labels() -> void:
	_music_val.text = "%d%%" % int(_music_slider.value * 100)
	_sfx_val.text = "%d%%" % int(_sfx_slider.value * 100)


func start_remap(action_name: String) -> void:
	_waiting_for_input = action_name
	var binding_label: Label = get_node(_ACTION_ROWS[action_name] + "/BindingLabel")
	binding_label.text = "Pressione uma tecla..."
	binding_label.modulate = Color(0.533333, 0.533333, 0.666667, 1)


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
	for action in ControlsManager.ACTIONS:
		var binding_label: Label = get_node(_ACTION_ROWS[action] + "/BindingLabel")
		binding_label.modulate = Color(1, 1, 1, 1)

		var events := InputMap.action_get_events(action)
		if events.is_empty():
			binding_label.text = "-"
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

		if parts.is_empty():
			binding_label.text = "?"
		else:
			binding_label.text = " / ".join(parts)

		var has_gamepad := events.any(func(e): return e is InputEventJoypadButton or e is InputEventJoypadMotion)
		if has_gamepad:
			binding_label.modulate = Color(1.0, 0.866667, 0.341176, 1)


func _on_reset() -> void:
	var dir := DirAccess.open("user://")
	if dir and dir.file_exists("controls.cfg"):
		dir.remove("controls.cfg")
	InputMap.load_from_project_settings()
	ControlsManager._add_gamepad_defaults()
	_refresh_ui()


func _on_back() -> void:
	if _came_from_pause:
		get_tree().paused = false
		SceneTransition.go_back()
	else:
		SceneTransition.go_to("res://scenes/main_menu/main_menu.tscn")
