extends Control

@onready var continue_button: Button = $ButtonGroup/ContinueButton
@onready var new_game_button: Button = $ButtonGroup/NewGameButton
@onready var options_button: Button = $ButtonGroup/OptionsButton
@onready var confirm_panel: Panel = $ConfirmPanel
@onready var confirm_btn: Button = $ConfirmPanel/ButtonRow/ConfirmButton
@onready var cancel_btn: Button = $ConfirmPanel/ButtonRow/CancelButton
@onready var background_image: TextureRect = $BackgroundImage

const _BG_PATH := "res://assets/sprites/ui/menu_background.png"
const _MUSIC_PATH := "res://assets/audio/music/menu_theme.ogg"
const _MUSIC_PATH_WAV := "res://assets/audio/music/menu_theme.wav"


func _ready() -> void:
	if ResourceLoader.exists(_BG_PATH):
		background_image.texture = load(_BG_PATH)

	var music_path := _MUSIC_PATH if ResourceLoader.exists(_MUSIC_PATH) else _MUSIC_PATH_WAV
	if ResourceLoader.exists(music_path):
		AudioManager.play_music(load(music_path))

	continue_button.disabled = not SaveManager.save_exists()
	if continue_button.disabled:
		continue_button.add_theme_color_override("font_color", Color("#888888"))
		continue_button.add_theme_color_override("font_disabled_color", Color("#888888"))

	continue_button.pressed.connect(_on_continue_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)
	options_button.pressed.connect(_on_options_pressed)
	confirm_btn.pressed.connect(_on_new_game_confirmed)
	cancel_btn.pressed.connect(func(): confirm_panel.visible = false)

	if SaveManager.save_exists():
		continue_button.grab_focus()
	else:
		new_game_button.grab_focus()


func _on_continue_pressed() -> void:
	AudioManager.stop_music()
	SceneTransition.go_to(SaveManager.get_checkpoint_scene())


func _on_new_game_pressed() -> void:
	if SaveManager.save_exists():
		confirm_panel.visible = true
		confirm_btn.grab_focus()
		return
	SaveManager.new_game()
	AudioManager.stop_music()
	SceneTransition.go_to("res://scenes/world1/mundo1_abertura.tscn")


func _on_new_game_confirmed() -> void:
	confirm_panel.visible = false
	SaveManager.new_game()
	AudioManager.stop_music()
	SceneTransition.go_to("res://scenes/world1/mundo1_abertura.tscn")


func _on_options_pressed() -> void:
	if ResourceLoader.exists("res://scenes/options_menu/options_menu.tscn"):
		SceneTransition.go_to("res://scenes/options_menu/options_menu.tscn")
