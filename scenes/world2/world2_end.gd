extends Node2D


func _ready() -> void:
	$MenuButton.pressed.connect(_on_menu_pressed)


func _on_menu_pressed() -> void:
	SceneTransition.go_to("res://scenes/main_menu/main_menu.tscn")
