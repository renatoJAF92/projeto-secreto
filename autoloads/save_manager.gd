extends Node

const SAVE_PATH := "user://save.dat"
const SCHEMA_VERSION := 1

var current_save: Dictionary = {}

func _ready() -> void:
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
		if data is Dictionary and data.get("version", 0) == SCHEMA_VERSION:
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

func new_game() -> void:
	current_save = _default_save()
	save_game()

func set_checkpoint(checkpoint_id: String) -> void:
	current_save["checkpoint_id"] = checkpoint_id
	save_game()

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
		"seen_cutscenes": {},
	}
