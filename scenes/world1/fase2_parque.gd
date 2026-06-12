extends Node2D

@export var fase_width: int = 6400

const DEATHS_FOR_BIKE: int = 5

var _death_count: int = 0
var _player: CharacterBody2D

@onready var exit_trigger: Area2D = $ExitTrigger


func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	_player = player
	if player and player.has_node("Camera2D"):
		player.get_node("Camera2D").limit_right = fase_width

	if exit_trigger:
		exit_trigger.body_entered.connect(_on_exit_trigger_body_entered)

	if player and player.has_signal("died"):
		player.died.connect(_on_player_died)

	# Restore bicycle mode if it was active when this scene reloaded
	if SaveManager.current_save.get("bicycle_active", false):
		_apply_bicycle_mode()


func _on_exit_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Clear bicycle mode and death count when exiting fase2
		SaveManager.current_save["bicycle_active"] = false
		SaveManager.current_save["fase2_deaths"] = 0
		SaveManager.save_game()
		SceneTransition.go_to("res://scenes/world1/fase3_restaurante.tscn")


func _on_player_died() -> void:
	_death_count = SaveManager.current_save.get("fase2_deaths", 0) + 1
	SaveManager.current_save["fase2_deaths"] = _death_count
	SaveManager.save_game()

	if _death_count >= DEATHS_FOR_BIKE and not SaveManager.current_save.get("bicycle_active", false):
		_show_bike_choice()
	else:
		_respawn()


func _show_bike_choice() -> void:
	var choice_scene = preload("res://scenes/ui/bike_choice.tscn")
	var dialog = choice_scene.instantiate()
	add_child(dialog)
	dialog.chose_bicycle.connect(_on_bike_choice_made)


func _on_bike_choice_made(yes: bool) -> void:
	if yes:
		SaveManager.current_save["bicycle_active"] = true
		SaveManager.save_game()
	_respawn()


func _respawn() -> void:
	var checkpoint = SaveManager.current_save.get("checkpoint", "mundo1_fase2_cp1")
	var scene_path = SaveManager.CHECKPOINT_SCENES.get(checkpoint, "res://scenes/world1/fase2_parque.tscn")
	SceneTransition.go_to(scene_path)


func _apply_bicycle_mode() -> void:
	if not _player:
		return
	if _player.has_method("enable_bicycle_mode"):
		_player.enable_bicycle_mode()
