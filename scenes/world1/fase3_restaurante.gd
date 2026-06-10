extends Node2D

@onready var exit_trigger: Area2D = $ExitTrigger

func _ready() -> void:
	if exit_trigger:
		exit_trigger.body_entered.connect(_on_exit_trigger_body_entered)

func _on_exit_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SceneTransition.go_to("res://scenes/world1/boss_pai.tscn")
