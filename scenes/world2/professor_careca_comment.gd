extends Area2D

# --- Behavior tuning (visible in Inspector) ---
@export var speed: float = 80.0
@export var despawn_distance: float = 350.0

# --- Runtime state ---
var _spawned_position: Vector2
var _target: Node2D = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_spawned_position = global_position


func _physics_process(delta: float) -> void:
	# CRITICAL Pitfall 3 (per RESEARCH.md): Lazy-init player on first frame where it exists
	if not _target and get_tree():
		_target = get_tree().get_first_node_in_group("player")

	# Home toward player if target exists
	if _target:
		var direction = (_target.global_position - global_position).normalized()
		global_position += direction * speed * delta

	# Despawn if traveled too far
	if global_position.distance_to(_spawned_position) > despawn_distance:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	# Hit player — deal damage and despawn
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(global_position)
		queue_free()
