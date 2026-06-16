extends CanvasLayer

@onready var _overlay: ColorRect = $Overlay
@onready var _panel: Panel = $Panel
@onready var _resume_btn: Button = $Panel/ButtonList/ResumeButton
@onready var _options_btn: Button = $Panel/ButtonList/OptionsButton
@onready var _quit_btn: Button = $Panel/ButtonList/QuitButton

var _open: bool = false


func _ready() -> void:
	_resume_btn.pressed.connect(close)
	_options_btn.pressed.connect(_on_options)
	_quit_btn.pressed.connect(_on_quit)


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
	get_tree().paused = true
	_resume_btn.grab_focus()


func close() -> void:
	_open = false
	_overlay.visible = false
	_panel.visible = false
	get_tree().paused = false


func _on_options() -> void:
	close()
	SceneTransition.go_to("res://scenes/options_menu/options_menu.tscn")


func _on_quit() -> void:
	close()
	AudioManager.stop_music()
	SceneTransition.go_to("res://scenes/main_menu/main_menu.tscn")
