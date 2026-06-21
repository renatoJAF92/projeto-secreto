extends CanvasLayer

# On-screen touch controls for Android.
# Fires InputEventAction for walk_left, walk_right, jump, dash.
# Automatically shown only when a touchscreen is detected.

# Set to true by any choice/dialog UI so touch events pass through to UI buttons unblocked.
var ui_mode: bool = false

const BTN_SIZE := 22.0
const BTN_ALPHA := 0.50
const BTN_ALPHA_PRESSED := 0.90

# [action, symbol, base_x_from_left OR negative = from_right, y_from_bottom]
const BUTTON_DEFS := [
	{ "action": "walk_left",  "symbol": "◀", "side": "left",  "col": 0 },
	{ "action": "walk_right", "symbol": "▶", "side": "left",  "col": 1 },
	{ "action": "dash",       "symbol": "»",  "side": "right", "col": 1 },
	{ "action": "jump",       "symbol": "▲", "side": "right", "col": 0 },
]

const PAD_X := 5.0
const PAD_Y := 4.0
const GAP   := 3.0

const PAUSE_BTN_W := 18.0
const PAUSE_BTN_H := 12.0

var _panels: Array = []
var _rects:  Array = []
var _touch_map: Dictionary = {}  # touch_index → action
var _pause_rect: Rect2 = Rect2()

func _ready() -> void:
	layer = 100

	if not DisplayServer.is_touchscreen_available():
		# Uncomment below to show on desktop for layout testing:
		# pass
		queue_free()
		return

	_build()
	get_viewport().size_changed.connect(_build)
	# Auto-disable during Dialogic choice prompts so touches reach the choice buttons.
	call_deferred("_connect_dialogic_choices")


func _connect_dialogic_choices() -> void:
	var dialogic := get_node_or_null("/root/Dialogic")
	if dialogic and dialogic.has_subsystem("Choices"):
		dialogic.Choices.question_shown.connect(func(_i): ui_mode = true)
		dialogic.Choices.choice_selected.connect(func(_i): ui_mode = false)


func _build() -> void:
	for child in get_children():
		child.queue_free()
	_panels.clear()
	_rects.clear()

	var vp := Vector2(320, 180)  # game viewport is always 320x180

	for data in BUTTON_DEFS:
		var col: int = data["col"]
		var side: String = data["side"]

		var x: float
		if side == "left":
			x = PAD_X + col * (BTN_SIZE + GAP)
		else:
			x = vp.x - PAD_X - BTN_SIZE - col * (BTN_SIZE + GAP)

		var y: float = vp.y - PAD_Y - BTN_SIZE

		var rect := Rect2(Vector2(x, y), Vector2(BTN_SIZE, BTN_SIZE))
		_rects.append(rect)

		var panel := Panel.new()
		panel.position = rect.position
		panel.custom_minimum_size = rect.size
		panel.size = rect.size
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var style := StyleBoxFlat.new()
		var r := int(BTN_SIZE * 0.5)
		style.corner_radius_top_left = r
		style.corner_radius_top_right = r
		style.corner_radius_bottom_left = r
		style.corner_radius_bottom_right = r
		style.bg_color = Color(0.05, 0.05, 0.1, 0.7)
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		style.border_color = Color(1.0, 1.0, 1.0, 0.55)
		panel.add_theme_stylebox_override("panel", style)
		panel.modulate.a = BTN_ALPHA

		var lbl := Label.new()
		lbl.text = data["symbol"]
		lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_color_override("font_color", Color.WHITE)
		lbl.add_theme_font_size_override("font_size", 9)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(lbl)

		add_child(panel)
		_panels.append(panel)

	# Pause button — top-right corner
	_pause_rect = Rect2(
		Vector2(vp.x - PAD_X - PAUSE_BTN_W, PAD_Y),
		Vector2(PAUSE_BTN_W, PAUSE_BTN_H)
	)
	var pause_panel := Panel.new()
	pause_panel.position = _pause_rect.position
	pause_panel.custom_minimum_size = _pause_rect.size
	pause_panel.size = _pause_rect.size
	pause_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var pause_style := StyleBoxFlat.new()
	pause_style.corner_radius_top_left = 3
	pause_style.corner_radius_top_right = 3
	pause_style.corner_radius_bottom_left = 3
	pause_style.corner_radius_bottom_right = 3
	pause_style.bg_color = Color(0.05, 0.05, 0.1, 0.7)
	pause_style.border_width_left = 1
	pause_style.border_width_top = 1
	pause_style.border_width_right = 1
	pause_style.border_width_bottom = 1
	pause_style.border_color = Color(1.0, 1.0, 1.0, 0.55)
	pause_panel.add_theme_stylebox_override("panel", pause_style)
	pause_panel.modulate.a = BTN_ALPHA

	var pause_lbl := Label.new()
	pause_lbl.text = "II"
	pause_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pause_lbl.add_theme_color_override("font_color", Color.WHITE)
	pause_lbl.add_theme_font_size_override("font_size", 7)
	pause_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_panel.add_child(pause_lbl)
	add_child(pause_panel)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_on_press(event.index, event.position)
		else:
			_on_release(event.index)
	elif event is InputEventScreenDrag:
		_on_drag(event.index, event.position)


func _on_press(idx: int, pos: Vector2) -> void:
	# In UI mode (choice dialogs open) — don't consume events so UI buttons receive them.
	if ui_mode:
		return

	# Pause button tap
	if _pause_rect.has_point(pos):
		_fire("pause", true)
		_fire("pause", false)
		get_viewport().set_input_as_handled()
		return

	for i in range(_rects.size()):
		if _rects[i].has_point(pos):
			if idx not in _touch_map:
				var action: String = BUTTON_DEFS[i]["action"]
				_touch_map[idx] = action
				_fire(action, true)
				_panels[i].modulate.a = BTN_ALPHA_PRESSED
			get_viewport().set_input_as_handled()
			return


func _on_release(idx: int) -> void:
	if idx in _touch_map:
		var action: String = _touch_map[idx]
		_touch_map.erase(idx)
		_fire(action, false)
		_unhighlight(action)


func _on_drag(idx: int, pos: Vector2) -> void:
	if idx in _touch_map:
		var old_action: String = _touch_map[idx]
		# Check if finger slid off the original button
		var still_on := false
		for i in range(_rects.size()):
			if BUTTON_DEFS[i]["action"] == old_action and _rects[i].has_point(pos):
				still_on = true
				break
		if not still_on:
			_on_release(idx)
			_on_press(idx, pos)
	else:
		_on_press(idx, pos)


func _fire(action: String, pressed: bool) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = pressed
	ev.strength = 1.0 if pressed else 0.0
	Input.parse_input_event(ev)


func _unhighlight(action: String) -> void:
	for i in range(BUTTON_DEFS.size()):
		if BUTTON_DEFS[i]["action"] == action:
			_panels[i].modulate.a = BTN_ALPHA
