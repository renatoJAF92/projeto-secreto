extends StaticBody2D

var _player_in_zone: bool = false
var _dialogue_done: bool = false
var _fim_precoce: bool = false

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
	Dialogic.signal_event.connect(_on_dialogic_signal)

	Dialogic.start("renato_restaurante")
	await Dialogic.timeline_ended

	Dialogic.start("restaurante_saida")
	await Dialogic.timeline_ended

	Dialogic.start("dia_seguinte")
	await Dialogic.timeline_ended

	Dialogic.signal_event.disconnect(_on_dialogic_signal)

	if _fim_precoce:
		SceneTransition.go_to("res://scenes/main_menu/main_menu.tscn")

func _on_dialogic_signal(arg: String) -> void:
	if arg == "fim_precoce":
		_fim_precoce = true
