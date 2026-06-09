extends StaticBody2D

# --- Spawn tuning (visible in Inspector) ---
@export var spawn_rate: float = 2.0
@export var comment_scene: PackedScene = null

# --- Runtime state ---
var _spawn_timer: float = 0.0

@onready var spawn_point: Marker2D = $SpawnPoint


func _ready() -> void:
	add_to_group("hazards")
	_spawn_timer = spawn_rate


func _physics_process(delta: float) -> void:
	# Spawn projectiles on timer
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_comment()
		_spawn_timer = spawn_rate


func _spawn_comment() -> void:
	# Spawn and fire projectile if scene is configured
	if comment_scene == null:
		return

	var projectile = comment_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = spawn_point.global_position


func reset_to_origin() -> void:
	# Professor never resets — always stays in place
	pass
