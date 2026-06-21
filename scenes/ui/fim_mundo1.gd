extends Node2D

func _ready() -> void:
	$Label.modulate.a = 0.0
	var t := create_tween()
	t.tween_interval(0.8)
	t.tween_property($Label, "modulate:a", 1.0, 1.5)
	t.tween_interval(4.5)
	t.tween_property($Label, "modulate:a", 0.0, 1.0)
	t.tween_callback(func(): SceneTransition.go_to("res://scenes/main_menu/main_menu.tscn"))
