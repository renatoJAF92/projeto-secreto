extends Node

# Centralized audio playback for SFX and music.
# Follows the same pattern as SaveManager and ControlsManager autoloads.
# Silent-fails on missing SFX keys (never crashes on unregistered audio).

var _sfx_players: Dictionary = {}
var _music_player: AudioStreamPlayer

func _ready() -> void:
	# Initialize music player on Master bus
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Master"
	add_child(_music_player)

	# Register the 8 Mundo 1 SFX keys
	# Each registration is guarded by ResourceLoader.exists() so missing WAVs never crash startup
	var sfx_keys := ["jump", "checkpoint", "prova_coletada", "prova_apresentada", "dialogo_errado", "stomp", "dano", "vitoria"]
	for key in sfx_keys:
		var path := "res://assets/audio/sfx/" + key + ".wav"
		if ResourceLoader.exists(path):
			var stream = load(path)
			register_sfx(key, stream)

func register_sfx(key: String, stream: AudioStream) -> void:
	# Create a new AudioStreamPlayer for this SFX key
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = "Master"
	add_child(player)
	_sfx_players[key] = player

func play_sfx(key: String) -> void:
	# Silent fail if key not registered (stub behavior).
	# WAV files added by Phase 05 via register_sfx.
	if _sfx_players.has(key):
		_sfx_players[key].play()
	else:
		push_warning("AudioManager: sfx '" + key + "' not registered")

func play_music(stream: AudioStream) -> void:
	_music_player.stream = stream
	_music_player.play()

func stop_music() -> void:
	_music_player.stop()
