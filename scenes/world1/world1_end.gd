extends Node2D


func _ready() -> void:
	$Title.modulate.a = 0.0
	$Subtitle.modulate.a = 0.0
	$MenuButton.modulate.a = 0.0
	$MenuButton.pressed.connect(_on_menu_pressed)

	var t := create_tween()
	t.tween_interval(0.6)
	t.tween_property($Title, "modulate:a", 1.0, 1.2)
	t.tween_property($Subtitle, "modulate:a", 1.0, 1.0)
	t.tween_interval(0.5)
	t.tween_property($MenuButton, "modulate:a", 1.0, 0.8)


func _on_menu_pressed() -> void:
	SceneTransition.go_to("res://scenes/main_menu/main_menu.tscn")
