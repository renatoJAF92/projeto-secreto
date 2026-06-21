extends Area2D

@export var spawn_interval: float = 5.0
@export var active_duration: float = 2.5
@export var start_delay: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_set_active(false)
	get_tree().create_timer(start_delay).timeout.connect(_start_cycle, CONNECT_ONE_SHOT)


func _start_cycle() -> void:
	while true:
		_set_active(true)
		await get_tree().create_timer(active_duration).timeout
		_set_active(false)
		await get_tree().create_timer(spawn_interval).timeout


func _set_active(value: bool) -> void:
	sprite.visible = value
	collision.set_deferred("disabled", not value)
	if value:
		sprite.play("burn")


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if body.has_method("instant_kill"):
		body.instant_kill()
	elif body.has_method("die"):
		body.die()
