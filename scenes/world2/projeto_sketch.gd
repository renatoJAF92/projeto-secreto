extends Area2D


@export var speed: float = 300.0

var velocity: Vector2 = Vector2.ZERO
var _spawned_position: Vector2


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_spawned_position = global_position


func _physics_process(delta: float) -> void:
	position += velocity * delta

	# Despawn if too far (screen boundary)
	if global_position.distance_to(_spawned_position) > 500.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	# Hit-kill on enemy
	if body.is_in_group("enemies") and body.has_method("die"):
		body.die()
		queue_free()
	# Pass through player (checked via collision layer isolation in scene)
	# Hit wall/floor: despawn
	elif body.is_in_group("walls"):
		queue_free()
