extends Node

const SAVE_PATH := "user://save.dat"
const SCHEMA_VERSION := 3

const CHECKPOINT_SCENES: Dictionary = {
	"mundo1_fase1_cp1": "res://scenes/world1/fase1_rua.tscn",
	"mundo1_fase2_cp0": "res://scenes/world1/fase2_parque.tscn",
	"mundo1_fase2_cp1": "res://scenes/world1/fase2_parque.tscn",
	"mundo1_fase3_cp1": "res://scenes/world1/fase3_restaurante.tscn",
	"mundo2_fase1_cp1": "res://scenes/world2/fase1_campus.tscn",
	"mundo2_fase2_cp1": "res://scenes/world2/fase2_atelie.tscn",
	"mundo2_fase3_cp1": "res://scenes/world2/fase3_madrugada.tscn",
}
const DEFAULT_SCENE := "res://scenes/world1/fase1_rua.tscn"

var current_save: Dictionary = {}

func _ready() -> void:
	# Phase 3 pre-flight gate: validate Phase 2 completion
	if not (has_method("set_checkpoint") and has_method("has_seen_cutscene") and has_method("mark_cutscene_seen")):
		push_error("PHASE 2 NOT COMPLETE: SaveManager missing set_checkpoint, has_seen_cutscene, or mark_cutscene_seen. Execute Phase 2 fully before Phase 3.")
		get_tree().quit(1)
	load_game()

func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		current_save = _default_save()
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var data = file.get_var(true)  # allow_objects=true para Array/Dict aninhados (Pitfall 2)

		# Handle v2→v3 migration
		if data is Dictionary and data.get("version", 0) == 2:
			# Upgrade v2 to v3
			data["version"] = 3
			data["active_power"] = ""
			data["itens_tfg_mundo2"] = []
			current_save = data
			save_game()  # Persist the upgraded save
		elif data is Dictionary and data.get("version", 0) == SCHEMA_VERSION:
			current_save = data
		else:
			# Save corrompido ou versão incompatível (T-02-03, T-02-04)
			current_save = _default_save()
	else:
		current_save = _default_save()

func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(current_save, true)

func save() -> void:
	save_game()

func new_game() -> void:
	current_save = _default_save()
	save_game()

func set_checkpoint(checkpoint_id: String) -> void:
	current_save["checkpoint_id"] = checkpoint_id
	save_game()

func get_checkpoint_scene() -> String:
	var cp: String = current_save.get("checkpoint_id", "")
	return CHECKPOINT_SCENES.get(cp, DEFAULT_SCENE)

func mark_cutscene_seen(cutscene_id: String) -> void:
	current_save["seen_cutscenes"][cutscene_id] = true
	save_game()

func has_seen_cutscene(cutscene_id: String) -> bool:
	return current_save["seen_cutscenes"].get(cutscene_id, false)

func _default_save() -> Dictionary:
	return {
		"version": SCHEMA_VERSION,
		"checkpoint_id": "",
		"worlds_completed": [],
		"powers_unlocked": [],
		"active_power": "",
		"seen_cutscenes": {},
		"provas_mundo1": [],
		"itens_tfg_mundo2": [],
		"music_volume": 0.8,
		"sfx_volume": 1.0,
	}
