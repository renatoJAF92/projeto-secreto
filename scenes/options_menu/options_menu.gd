extends Control

var _came_from_pause: bool = false

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

	$MenuButtons/ControlsButton.pressed.connect(_on_controls_pressed)
	$MenuButtons/MenuPrincipalButton.pressed.connect(_on_menu_principal_pressed)
	$MenuButtons/BackButton.pressed.connect(_on_back)

	$MenuButtons/ControlsButton.grab_focus()


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


func _on_controls_pressed() -> void:
	SceneTransition.go_to("res://scenes/options_menu/controls_menu.tscn")


func _on_menu_principal_pressed() -> void:
	if _came_from_pause:
		get_tree().paused = false
	AudioManager.stop_music()
	SceneTransition.go_to("res://scenes/main_menu/main_menu.tscn")


func _on_back() -> void:
	if _came_from_pause:
		get_tree().paused = false
		SceneTransition.go_back()
	else:
		SceneTransition.go_to("res://scenes/main_menu/main_menu.tscn")
