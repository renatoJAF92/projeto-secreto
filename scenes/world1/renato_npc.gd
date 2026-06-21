extends StaticBody2D

var _player_in_zone: bool = false
var _dialogue_done: bool = false

func _ready() -> void:
	if has_node("DialogueZone"):
		$DialogueZone.body_entered.connect(_on_dialogue_zone_body_entered)
		$DialogueZone.body_exited.connect(_on_dialogue_zone_body_exited)

func _on_dialogue_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_zone = true
		if has_node("Prompt"):
			$Prompt.visible = true

func _on_dialogue_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_zone = false
		if has_node("Prompt"):
			$Prompt.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if _player_in_zone and not _dialogue_done and event.is_action_pressed("jump"):
		if not ResourceLoader.exists("res://dialogic/timelines/renato_restaurante.dtl"):
			return
		_dialogue_done = true
		get_tree().root.set_input_as_handled()
		_run_restaurant_sequence()

func _run_restaurant_sequence() -> void:
	var player = get_tree().get_first_node_in_group("player")

	# Freeze player and enemies during dialogue
	if player:
		player.process_mode = Node.PROCESS_MODE_DISABLED
		player.velocity = Vector2.ZERO
	get_tree().call_group("enemies", "set_process", false)
	get_tree().call_group("enemies", "set_physics_process", false)

	Dialogic.start("renato_restaurante")
	await Dialogic.timeline_ended

	# Restore
	if player:
		player.process_mode = Node.PROCESS_MODE_INHERIT
	get_tree().call_group("enemies", "set_process", true)
	get_tree().call_group("enemies", "set_physics_process", true)
