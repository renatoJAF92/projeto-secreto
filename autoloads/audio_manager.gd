extends Node

# Centralized audio playback for SFX and music.
# Music plays on bus "Music" (idx 1), SFX on bus "SFX" (idx 2).

const _MUSIC_BUS := 1
const _SFX_BUS := 2

var _sfx_players: Dictionary = {}
var _music_player: AudioStreamPlayer

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)
	_apply_saved_volumes()

	var sfx_keys: Array[String] = [
		"jump", "checkpoint", "prova_coletada", "prova_apresentada", "dialogo_errado", "stomp", "dano", "vitoria",
		"prova_tfg_coletada", "qualidade_apresentada", "qualidade_perdida", "sketch_disparo", "amor_ativado", "dano_profundo"
	]
	for key: String in sfx_keys:
		var path: String = "res://assets/audio/sfx/" + key + ".wav"
		if ResourceLoader.exists(path):
			var stream: AudioStream = load(path) as AudioStream
			register_sfx(key, stream)

func _apply_saved_volumes() -> void:
	var music_vol: float = SaveManager.current_save.get("music_volume", 0.8)
	var sfx_vol: float = SaveManager.current_save.get("sfx_volume", 1.0)
	set_music_volume(music_vol)
	set_sfx_volume(sfx_vol)

func register_sfx(key: String, stream: AudioStream) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = "SFX"
	add_child(player)
	_sfx_players[key] = player

func play_sfx(key: String) -> void:
	if _sfx_players.has(key):
		_sfx_players[key].play()
	else:
		push_warning("AudioManager: sfx '" + key + "' not registered")

func play_music(stream: AudioStream) -> void:
	_music_player.stream = stream
	_music_player.play()

func stop_music() -> void:
	_music_player.stop()

func set_music_volume(linear: float) -> void:
	AudioServer.set_bus_volume_db(_MUSIC_BUS, linear_to_db(linear) if linear > 0.0 else -80.0)

func set_sfx_volume(linear: float) -> void:
	AudioServer.set_bus_volume_db(_SFX_BUS, linear_to_db(linear) if linear > 0.0 else -80.0)

func get_music_volume() -> float:
	var db := AudioServer.get_bus_volume_db(_MUSIC_BUS)
	return 0.0 if db <= -79.0 else db_to_linear(db)

func get_sfx_volume() -> float:
	var db := AudioServer.get_bus_volume_db(_SFX_BUS)
	return 0.0 if db <= -79.0 else db_to_linear(db)
