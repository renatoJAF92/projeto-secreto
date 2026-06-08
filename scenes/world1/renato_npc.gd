extends StaticBody2D

var _player_in_zone: bool = false

func _ready() -> void:
	# Connect dialogue zone signals
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
	# Check if player is in dialogue zone and pressed interact
	if _player_in_zone and event.is_action_pressed("jump"):
		# Guard: only start dialogue if the timeline exists (prevents crash before Plan 04)
		if not ResourceLoader.exists("res://dialogic/timelines/renato_restaurante.dtl"):
			return

		# Start dialogue
		Dialogic.start("renato_restaurante")
		get_tree().root.set_input_as_handled()
