extends Control

@onready var continue_button: Button = $ButtonGroup/ContinueButton
@onready var new_game_button: Button = $ButtonGroup/NewGameButton
@onready var options_button: Button = $ButtonGroup/OptionsButton
@onready var confirm_new_game: ConfirmationDialog = $ConfirmNewGame


func _ready() -> void:
	continue_button.disabled = not SaveManager.save_exists()

	if continue_button.disabled:
		continue_button.add_theme_color_override("font_color", Color("#888888"))
		continue_button.add_theme_color_override("font_disabled_color", Color("#888888"))

	continue_button.pressed.connect(_on_continue_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)
	options_button.pressed.connect(_on_options_pressed)
	confirm_new_game.confirmed.connect(_on_new_game_confirmed)

	if SaveManager.save_exists():
		continue_button.grab_focus()
	else:
		new_game_button.grab_focus()


func _on_continue_pressed() -> void:
	SceneTransition.go_to("res://scenes/test_movement/test_movement.tscn")


func _on_new_game_pressed() -> void:
	if SaveManager.save_exists():
		confirm_new_game.popup_centered()
		return

	SaveManager.new_game()
	SceneTransition.go_to("res://scenes/test_movement/test_movement.tscn")


func _on_new_game_confirmed() -> void:
	SaveManager.new_game()
	SceneTransition.go_to("res://scenes/test_movement/test_movement.tscn")


func _on_options_pressed() -> void:
	# options_menu será implementado no plano 02-004
	if ResourceLoader.exists("res://scenes/options_menu/options_menu.tscn"):
		SceneTransition.go_to("res://scenes/options_menu/options_menu.tscn")
	else:
		OS.alert("Menu de Opções em desenvolvimento.", "Em breve")
