extends StaticBody2D

var _player_in_zone: bool = false
var _has_healed: bool = false

func _ready() -> void:
	# Connect dialogue zone signals
	if has_node("DialogueZone"):
		$DialogueZone.body_entered.connect(_on_dialogue_zone_body_entered)
		$DialogueZone.body_exited.connect(_on_dialogue_zone_body_exited)

func _on_dialogue_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_zone = true
		if has_node("DialogueZone/Prompt"):
			$DialogueZone/Prompt.visible = true

func _on_dialogue_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_zone = false
		if has_node("DialogueZone/Prompt"):
			$DialogueZone/Prompt.visible = false

func _unhandled_input(event: InputEvent) -> void:
	# Check if player is in dialogue zone and pressed interact
	if _player_in_zone and event.is_action_pressed("jump"):
		# Guard: only start dialogue if the timeline exists (prevents crash before timeline is available)
		if not ResourceLoader.exists("res://dialogic/timelines/renato_cafe_fase3.dtl"):
			return

		# Start dialogue
		Dialogic.start("renato_cafe_fase3")
		await Dialogic.timeline_ended

		# Heal player once (protected by _has_healed guard)
		if not _has_healed:
			_has_healed = true
			var player = get_tree().get_first_node_in_group("player")
			if player and player.has_method("heal"):
				player.heal(1)
				AudioManager.play_sfx("checkpoint")

		get_tree().root.set_input_as_handled()
