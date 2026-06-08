extends Node2D

func _ready() -> void:
	# Store checkpoint position for respawn
	_checkpoint_position = checkpoint.global_position

	# Hook player death signal to respawn logic
	player.died.connect(_on_player_died)

	# Hook exit trigger
	if exit_trigger:
		exit_trigger.body_entered.connect(_on_exit_trigger_body_entered)

@onready var player: CharacterBody2D = $Player
@onready var checkpoint: Area2D = $Checkpoint
@onready var exit_trigger: Area2D = $ExitTrigger

var _checkpoint_position: Vector2

func _on_player_died() -> void:
	# Instant respawn at checkpoint (no SceneTransition — must be <500ms per WORLD-05)
	player.global_position = _checkpoint_position
	player.velocity = Vector2.ZERO
	player._is_dead = false
	player._is_hurt = false
	_reset_enemies()

func _reset_enemies() -> void:
	# Restore all enemies to their origin positions
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("reset_to_origin"):
			enemy.reset_to_origin()

func _on_exit_trigger_body_entered(body: Node2D) -> void:
	# Player reached the end of the level — transition to boss
	if body.is_in_group("player"):
		SceneTransition.go_to("res://scenes/world1/boss_pai.tscn")
