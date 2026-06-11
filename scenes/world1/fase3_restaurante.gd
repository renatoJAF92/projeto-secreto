extends Node2D

@export var fase_width: int = 6400
@onready var exit_trigger: Area2D = $ExitTrigger

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("Camera2D"):
		player.get_node("Camera2D").limit_right = fase_width

	if exit_trigger:
		exit_trigger.body_entered.connect(_on_exit_trigger_body_entered)

func _on_exit_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SceneTransition.go_to("res://scenes/world1/boss_pai.tscn")
