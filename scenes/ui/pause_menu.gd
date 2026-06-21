extends CanvasLayer

@onready var _overlay: ColorRect = $Overlay
@onready var _panel: Panel = $Panel
@onready var _resume_btn: Button = $Panel/ButtonList/ResumeButton
@onready var _codigos_btn: Button = $Panel/ButtonList/CodigosButton
@onready var _options_btn: Button = $Panel/ButtonList/OptionsButton
@onready var _quit_btn: Button = $Panel/ButtonList/QuitButton
@onready var _code_panel: Panel = $CodePanel
@onready var _code_input: LineEdit = $CodePanel/VBox/CodeInput
@onready var _confirm_btn: Button = $CodePanel/VBox/BtnRow/ConfirmBtn
@onready var _cancel_btn: Button = $CodePanel/VBox/BtnRow/CancelBtn
@onready var _feedback_label: Label = $FeedbackLabel

var _open: bool = false


func _ready() -> void:
	_resume_btn.pressed.connect(close)
	_codigos_btn.pressed.connect(_on_codigos)
	_options_btn.pressed.connect(_on_options)
	_quit_btn.pressed.connect(_on_quit)
	_confirm_btn.pressed.connect(_on_code_confirm)
	_cancel_btn.pressed.connect(_on_code_cancel)
	_code_input.text_submitted.connect(func(_t): _on_code_confirm())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		var scene_path := get_tree().current_scene.scene_file_path
		if "options_menu" in scene_path or "main_menu" in scene_path:
			return
		get_viewport().set_input_as_handled()
		if _open:
			close()
		else:
			open()


func open() -> void:
	_open = true
	_overlay.visible = true
	_panel.visible = true
	_code_panel.visible = false
	get_tree().paused = true
	_resume_btn.grab_focus()


func close() -> void:
	_open = false
	_overlay.visible = false
	_panel.visible = false
	_code_panel.visible = false
	get_tree().paused = false


func _on_options() -> void:
	close()
	SceneTransition.go_to("res://scenes/options_menu/options_menu.tscn")


func _on_quit() -> void:
	close()
	AudioManager.stop_music()
	SceneTransition.go_to("res://scenes/main_menu/main_menu.tscn")


func _on_codigos() -> void:
	_panel.visible = false
	_code_panel.visible = true
	_code_input.text = ""
	_code_input.grab_focus()


func _on_code_cancel() -> void:
	_code_panel.visible = false
	_panel.visible = true
	_resume_btn.grab_focus()


func _on_code_confirm() -> void:
	var code := _code_input.text.strip_edges().to_lower()
	if code == "motherlode":
		_activate_invincibility()
		return
	_on_code_cancel()


func _activate_invincibility() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and "invincible" in player:
		player.invincible = true
	close()
	_show_feedback()


func _show_feedback() -> void:
	_feedback_label.modulate.a = 1.0
	_feedback_label.visible = true
	var t := create_tween()
	t.tween_interval(1.8)
	t.tween_property(_feedback_label, "modulate:a", 0.0, 0.6)
	t.tween_callback(func(): _feedback_label.visible = false)
