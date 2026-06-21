extends Node2D

@export var fase_width: int = 6400

var _player: CharacterBody2D
var _transitioning: bool = false
var _saida_choice: String = ""

@onready var exit_trigger: Area2D = $ExitTrigger

func _ready() -> void:
	get_tree().debug_collisions_hint = false
	_player = get_tree().get_first_node_in_group("player")
	if _player:
		_player.scale = Vector2(1.3, 1.3)
	if _player and _player.has_node("Camera2D"):
		_player.get_node("Camera2D").limit_right = fase_width

	if exit_trigger:
		exit_trigger.body_entered.connect(_on_exit_trigger_body_entered)

	if _player and _player.has_signal("died"):
		_player.died.connect(_on_player_died)

	_restore_checkpoint_spawn()

func _on_exit_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not _transitioning:
		_transitioning = true
		_run_exit_cutscene()

func _run_exit_cutscene() -> void:
	# Freeze player and enemies for cutscene
	if _player:
		_player.process_mode = Node.PROCESS_MODE_DISABLED
		_player.velocity = Vector2.ZERO
	get_tree().call_group("enemies", "set_process", false)
	get_tree().call_group("enemies", "set_physics_process", false)

	Dialogic.start("restaurante_saida")
	await Dialogic.timeline_ended

	_saida_choice = ""
	Dialogic.signal_event.connect(_on_saida_signal)
	Dialogic.start("dia_seguinte")
	await Dialogic.timeline_ended
	Dialogic.signal_event.disconnect(_on_saida_signal)

	# Restore before transition
	if _player:
		_player.process_mode = Node.PROCESS_MODE_INHERIT
	get_tree().call_group("enemies", "set_process", true)
	get_tree().call_group("enemies", "set_physics_process", true)

	if _saida_choice == "fim_precoce":
		SceneTransition.go_to("res://scenes/main_menu/main_menu.tscn")
	else:
		SceneTransition.go_to("res://scenes/world1/boss_pai.tscn")

func _on_saida_signal(argument: String) -> void:
	_saida_choice = argument


func _on_player_died() -> void:
	_respawn()

func _respawn() -> void:
	var cp_id = SaveManager.current_save.get("checkpoint_id", "")
	var scene_path = SaveManager.CHECKPOINT_SCENES.get(cp_id, get_tree().current_scene.scene_file_path)
	SceneTransition.go_to(scene_path)

func _restore_checkpoint_spawn() -> void:
	if not _player:
		return
	var saved_id = SaveManager.current_save.get("checkpoint_id", "")
	if saved_id.is_empty():
		return
	for cp in get_tree().get_nodes_in_group("checkpoints"):
		if cp.get("checkpoint_id") == saved_id:
			_player.global_position = Vector2(cp.global_position.x + 24.0, cp.global_position.y + 16.0)
			return
