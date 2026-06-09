extends Node2D

var _quality: float = 0.0
const QUALITY_MAX: float = 100.0

var _quality_threshold: float = 70.0  # Initial pass threshold, raised by Professor

@onready var quality_bar_fill: ColorRect = %QualityBarFill
@onready var quality_pct_label: Label = %QualityPctLabel
@onready var game_over_flash: ColorRect = %FlashRect
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	_start_boss_sequence()

func _start_boss_sequence() -> void:
	# Gate: need at least 3 TFG items to fight the boss
	var itens = SaveManager.current_save.get("itens_tfg_mundo2", [])
	if itens.size() < 3:
		await _show_blocking_dialogue()
		return

	_quality = 0.0
	_update_hud()

	# Present each collected item and grant quality
	for item_id in itens:
		await _show_item_card(item_id)
		add_quality(20.0)

	# Guard: prevent timeline overlap
	if Dialogic.current_timeline != null:
		return

	# CRITICAL FIX: Connect signal BEFORE starting timeline
	# This ensures signal events from the timeline are captured
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.start("boss_abertura_tfg")
	await Dialogic.timeline_ended
	Dialogic.signal_event.disconnect(_on_dialogic_signal)

func _show_blocking_dialogue() -> void:
	# Show message that player needs more items
	Dialogic.start("boss_abertura_bloqueado_tfg")
	await Dialogic.timeline_ended
	SceneTransition.go_to("res://scenes/world2/fase3_madrugada.tscn")

func _show_item_card(item_id: String) -> void:
	# Map item IDs to display names
	var item_names = {
		"tfg_pesquisa": "Pesquisa",
		"tfg_masterplan": "Master Plan",
		"tfg_maquete": "Maquete"
	}

	var card = get_node("%ItemCard")
	if card:
		card.visible = true
		var name_label = get_node("%ItemNameLabel")
		if name_label:
			name_label.text = item_names.get(item_id, "Item")

		# Show the card for 1.5 seconds
		await get_tree().create_timer(1.5, true).timeout

		# Fade out the card
		var tween = create_tween()
		tween.tween_property(card, "modulate:a", 0.0, 0.3)

		# Hide and reset alpha
		card.visible = false
		card.modulate.a = 1.0

func _on_dialogic_signal(argument: String) -> void:
	match argument:
		"choice_correct":
			add_quality(10.0)
		"choice_wrong":
			add_quality(-15.0)
			AudioManager.play_sfx("dialogo_errado")
		"professor_increases_requirement":
			# Professor Perpétuo raises the bar
			_quality_threshold = minf(_quality_threshold + 15.0, QUALITY_MAX)

func add_quality(amount: float) -> void:
	_quality = clampf(_quality + amount, 0.0, QUALITY_MAX)
	_update_hud()

	if _quality < _quality_threshold:
		_trigger_game_over()
	elif _quality >= QUALITY_MAX:
		_trigger_victory()

func _update_hud() -> void:
	# Update quality bar width
	var fill_width: float = 200.0 * (_quality / QUALITY_MAX)
	quality_bar_fill.custom_minimum_size.x = fill_width

	# Update percentage label
	quality_pct_label.text = str(int(_quality)) + "%"

	# Step color based on quality level
	if _quality < 20.0:
		quality_bar_fill.color = Color("#E53935")  # Red
	elif _quality < 80.0:
		quality_bar_fill.color = Color("#4CAF50")  # Green
	else:
		quality_bar_fill.color = Color("#D4A017")  # Gold

func _trigger_game_over() -> void:
	# Update HUD for game over state
	quality_bar_fill.color = Color("#E53935")  # Red

	# Flash red
	game_over_flash.visible = true
	var flash_tween = create_tween()
	flash_tween.tween_property(game_over_flash, "modulate:a", 0.5, 0.2)
	flash_tween.tween_property(game_over_flash, "modulate:a", 0.0, 0.3)

	# End any active timeline to prevent UI artifacts
	Dialogic.end_timeline()

	# Wait a moment for animations
	await get_tree().create_timer(0.5, true).timeout

	# Reload the boss scene (items are saved in SaveManager, so they persist)
	SceneTransition.go_to("res://scenes/world2/boss_tfg.tscn")

func _trigger_victory() -> void:
	# Update HUD for victory state
	quality_bar_fill.color = Color("#D4A017")  # Gold

	AudioManager.play_sfx("vitoria")

	# Unlock powers retroactively
	var player_ref = player if has_node("Player") else null
	if player_ref and player_ref.has_method("unlock_power"):
		player_ref.unlock_power("sketch")
		player_ref.unlock_power("amor")

	# Mark mundo2 as completed
	var worlds = SaveManager.current_save.get("worlds_completed", [])
	if "mundo2" not in worlds:
		worlds.append("mundo2")
	SaveManager.current_save["worlds_completed"] = worlds
	SaveManager.mark_cutscene_seen("boss_vitoria_tfg")
	SaveManager.save_game()

	# Play victory dialogue
	Dialogic.start("boss_vitoria_tfg")
	await Dialogic.timeline_ended

	# White flash for victory
	var flash_tween = create_tween()
	game_over_flash.modulate = Color.WHITE
	game_over_flash.visible = true
	flash_tween.tween_property(game_over_flash, "modulate:a", 1.0, 0.2)
	flash_tween.tween_property(game_over_flash, "modulate:a", 0.0, 0.3)

	await flash_tween.finished
	game_over_flash.visible = false

	# Transition to world2_end with fallback
	var world_end_path = "res://scenes/world2/world2_end.tscn"
	if ResourceLoader.exists(world_end_path):
		SceneTransition.go_to(world_end_path)
	else:
		# Fallback to main menu if world2_end doesn't exist yet
		SceneTransition.go_to("res://scenes/main_menu/main_menu.tscn")
