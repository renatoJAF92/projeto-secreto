extends Node2D

var _trust: float = 0.0
const TRUST_MAX: float = 100.0
var _is_game_over: bool = false

@onready var trust_bar_fill: ColorRect = %TrustBarFill
@onready var trust_pct_label: Label = %TrustPctLabel
@onready var trust_label: Label = %TrustLabel
@onready var prova_card: NinePatchRect = %ProvaCard
@onready var prova_name_label: Label = %ProvaNameLabel
@onready var prova_icon: Sprite2D = %ProvaIcon
@onready var game_over_flash: ColorRect = %FlashRect


func _ready() -> void:
	_start_boss_sequence()


func _start_boss_sequence() -> void:
	var provas: Array = SaveManager.current_save.get("provas_mundo1", [])

	if provas.size() < 1:
		Dialogic.start("boss_abertura_bloqueado")
		await Dialogic.timeline_ended
		SceneTransition.go_to("res://scenes/world1/fase3_restaurante.tscn")
		return

	_trust = 0.0
	_update_hud()

	for prova_id in provas:
		await _show_prova_card(prova_id)
		add_trust(25.0)

	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.start("boss_abertura")
	await Dialogic.timeline_ended
	Dialogic.signal_event.disconnect(_on_dialogic_signal)

	if _is_game_over:
		return

	if _trust < TRUST_MAX:
		Dialogic.start("boss_derrota")
		await Dialogic.timeline_ended
		_go_to_checkpoint()
		return

	Dialogic.start("boss_renato_entrada")
	await Dialogic.timeline_ended

	Dialogic.start("boss_vitoria")
	await Dialogic.timeline_ended

	SceneTransition.go_to("res://scenes/world1/world1_end.tscn")


func _on_dialogic_signal(argument: String) -> void:
	match argument:
		"choice_correct":
			add_trust(25.0)
		"choice_wrong":
			add_trust(-20.0)
			if AudioManager.has_method("play_sfx"):
				AudioManager.play_sfx("dialogo_errado")


func add_trust(amount: float) -> void:
	_trust = clampf(_trust + amount, 0.0, TRUST_MAX)
	_update_hud()
	if _trust <= 0.0:
		_trigger_game_over()


func _update_hud() -> void:
	var fill_width: float = 200.0 * (_trust / TRUST_MAX)
	trust_bar_fill.custom_minimum_size.x = fill_width
	trust_pct_label.text = str(int(_trust)) + "%"

	if _trust < 20.0:
		trust_bar_fill.color = Color("#E53935")
	elif _trust < 80.0:
		trust_bar_fill.color = Color("#4CAF50")
	else:
		trust_bar_fill.color = Color("#D4A017")


func _trigger_game_over() -> void:
	if _is_game_over:
		return
	_is_game_over = true

	trust_bar_fill.color = Color("#E53935")
	trust_label.text = "CONFIANÇA PERDIDA"
	trust_label.modulate = Color("#E53935")

	game_over_flash.visible = true
	var flash := create_tween()
	flash.tween_property(game_over_flash, "modulate:a", 0.5, 0.2)
	flash.tween_property(game_over_flash, "modulate:a", 0.0, 0.3)

	if Dialogic.current_timeline != null:
		Dialogic.end_timeline()

	await get_tree().create_timer(0.5, true).timeout
	_go_to_checkpoint()


func _go_to_checkpoint() -> void:
	SceneTransition.go_to(SaveManager.get_checkpoint_scene())


func _show_prova_card(prova_id: String) -> void:
	var prova_names := {
		"prova_foto": "Foto",
		"prova_carta": "Carta",
		"prova_presente": "Presente"
	}
	prova_card.visible = true
	prova_name_label.text = prova_names.get(prova_id, "Prova")
	prova_icon.visible = true

	await get_tree().create_timer(1.5, true).timeout

	var tween := create_tween()
	tween.tween_property(prova_card, "modulate:a", 0.0, 0.3)
	await tween.finished
	prova_card.visible = false
	prova_card.modulate.a = 1.0
