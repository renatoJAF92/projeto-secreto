extends Area2D

const SPEED: float = 220.0
var _direction: float = 1.0

func init(direction: float) -> void:
	_direction = direction
	if direction < 0:
		$AnimatedSprite2D.flip_h = true

func _physics_process(delta: float) -> void:
	global_position.x += SPEED * _direction * delta
	if global_position.x < -200 or global_position.x > 7000:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(global_position)
		queue_free()
