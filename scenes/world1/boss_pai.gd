extends Node2D

var _trust: float = 0.0
const TRUST_MAX: float = 100.0

var _renato_entered: bool = false

@onready var trust_bar_fill: ColorRect = %TrustBarFill
@onready var trust_pct_label: Label = %TrustPctLabel
@onready var trust_label: Label = %TrustLabel
@onready var prova_card: NinePatchRect = %ProvaCard
@onready var prova_sprite: TextureRect = %ProvaSprite
@onready var prova_name_label: Label = %ProvaNameLabel
@onready var game_over_flash: ColorRect = %FlashRect
@onready var player: CharacterBody2D = $Player
@onready var renato_entrance: Node2D = $RenatoEntrance

func _ready() -> void:
	renato_entrance.visible = true
	_start_boss_sequence()

func _start_boss_sequence() -> void:
	var provas: Array = SaveManager.current_save.get("provas_mundo1", [])

	# Gate: need at least 2 provas to fight the boss
	if provas.size() < 2:
		# Show blocking message and return to fase3
		var blocking_dialogue = await _show_blocking_dialogue()
		return

	_trust = 0.0
	_update_hud()

	# Present each collected prova and grant trust
	for prova_id in provas:
		await _show_prova_card(prova_id)
		add_trust(20.0)

	# Guard: prevent timeline overlap
	if Dialogic.current_timeline != null:
		return

	# CRITICAL FIX: Connect signal BEFORE starting timeline
	# This ensures signal events from the timeline are captured
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.start("boss_abertura")
	await Dialogic.timeline_ended
	Dialogic.signal_event.disconnect(_on_dialogic_signal)

func _show_blocking_dialogue() -> void:
	# Show message that player needs more provas
	Dialogic.start("boss_abertura_bloqueado")
	await Dialogic.timeline_ended
	SceneTransition.go_to("res://scenes/world1/fase3_restaurante.tscn")

func _show_prova_card(prova_id: String) -> void:
	# Map prova IDs to display names
	var prova_names = {
		"prova_foto": "Foto",
		"prova_carta": "Carta",
		"prova_presente": "Presente"
	}

	prova_card.visible = true
	prova_name_label.text = prova_names.get(prova_id, "Prova")

	# Show the card for 1.5 seconds
	await get_tree().create_timer(1.5, true).timeout

	# Fade out the card
	var tween = create_tween()
	tween.tween_property(prova_card, "modulate:a", 0.0, 0.3)

	# Hide and reset alpha
	prova_card.visible = false
	prova_card.modulate.a = 1.0

func _on_dialogic_signal(argument: String) -> void:
	match argument:
		"choice_correct":
			add_trust(20.0)
		"choice_wrong":
			add_trust(-15.0)
			AudioManager.play_sfx("dialogo_errado")
		"renato_entrada":
			_trigger_renato_entrance()

func add_trust(amount: float) -> void:
	_trust = clampf(_trust + amount, 0.0, TRUST_MAX)
	_update_hud()

	if _trust <= 0.0:
		_trigger_game_over()
	elif _trust >= TRUST_MAX:
		_trigger_victory()
	elif _trust >= 80.0 and not _renato_entered and Dialogic.current_timeline == null:
		_trigger_renato_entrance()

func _update_hud() -> void:
	# Update trust bar width
	var fill_width: float = 200.0 * (_trust / TRUST_MAX)
	trust_bar_fill.custom_minimum_size.x = fill_width

	# Update percentage label
	trust_pct_label.text = str(int(_trust)) + "%"

	# Step color based on trust level
	if _trust < 20.0:
		trust_bar_fill.color = Color("#E53935")  # Red
	elif _trust < 80.0:
		trust_bar_fill.color = Color("#4CAF50")  # Green
	else:
		trust_bar_fill.color = Color("#D4A017")  # Gold

func _trigger_renato_entrance() -> void:
	if _renato_entered:
		return

	_renato_entered = true

	Dialogic.start("boss_renato_entrada")
	await Dialogic.timeline_ended

	add_trust(15.0)

func _trigger_game_over() -> void:
	# Update HUD for game over state
	trust_bar_fill.color = Color("#E53935")  # Red
	trust_label.text = "CONFIANÇA PERDIDA"
	trust_label.modulate = Color("#E53935")

	# Shake the bar
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	for _i in range(3):
		tween.tween_property(trust_bar_fill, "position:x", 2.0, 0.1)
		tween.tween_property(trust_bar_fill, "position:x", 0.0, 0.1)

	# Flash red
	game_over_flash.visible = true
	var flash_tween = create_tween()
	flash_tween.tween_property(game_over_flash, "modulate:a", 0.5, 0.2)
	flash_tween.tween_property(game_over_flash, "modulate:a", 0.0, 0.3)

	# End any active timeline to prevent UI artifacts
	Dialogic.end_timeline()

	# Wait a moment for animations
	await get_tree().create_timer(0.5, true).timeout

	# Reload the boss scene (provas are saved in SaveManager, so they persist)
	SceneTransition.go_to("res://scenes/world1/boss_pai.tscn")

func _trigger_victory() -> void:
	Dialogic.end_timeline()
	trust_bar_fill.color = Color("#D4A017")  # Gold

	# Create victory particle burst
	if has_node("VictoryParticles"):
		$VictoryParticles.emitting = true

	AudioManager.play_sfx("vitoria")
	player.unlock_power("amor")

	# Play victory dialogue
	Dialogic.start("boss_vitoria")
	await Dialogic.timeline_ended

	# White flash for victory
	var flash_tween = create_tween()
	game_over_flash.modulate = Color.WHITE
	game_over_flash.visible = true
	flash_tween.tween_property(game_over_flash, "modulate:a", 1.0, 0.2)
	flash_tween.tween_property(game_over_flash, "modulate:a", 0.0, 0.3)

	await flash_tween.finished
	game_over_flash.visible = false

	# Transition to World 2 opening cutscene
	SceneTransition.go_to("res://scenes/world2/mundo2_abertura.tscn")
