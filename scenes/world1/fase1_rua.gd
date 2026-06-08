extends Node2D

func _ready() -> void:
	print("[Fase1Rua] _ready START")
	if not ResourceLoader.exists("res://scenes/world1/osasco_tileset.tres"):
		push_error("[Fase1Rua] osasco_tileset.tres not found")
	print("[Fase1Rua] tileset check ok, checkpoint=", checkpoint)
	_checkpoint_position = checkpoint.global_position
	print("[Fase1Rua] checkpoint pos ok, player=", player)
	player.died.connect(_on_player_died)
	print("[Fase1Rua] player.died connected")
	if exit_trigger:
		exit_trigger.body_entered.connect(_on_exit_trigger_body_entered)
	print("[Fase1Rua] _ready DONE")

	# AudioManager.play_music(...) wired in Plan 05 — for now, commented out
	# AudioManager.play_music(preload("res://assets/music/mundo1.ogg"))

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
	# Player reached the end of the level — transition to fase2
	if body.is_in_group("player"):
		SceneTransition.go_to("res://scenes/world1/fase2_parque.tscn")
