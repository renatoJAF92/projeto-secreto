extends StaticBody2D

@export_group("Timing")
@export var open_time: float = 2.0
@export var closed_time: float = 4.0
@export var start_open: bool = false

const WARNING_DURATION := 0.6  # blink time before toggling

var _is_open: bool = false


func _ready() -> void:
	_is_open = start_open
	_apply_state()
	_schedule_next()


func _schedule_next() -> void:
	var wait_time := (open_time if _is_open else closed_time) - WARNING_DURATION
	get_tree().create_timer(max(wait_time, 0.1)).timeout.connect(_start_warning, CONNECT_ONE_SHOT)


func _start_warning() -> void:
	var sprite: AnimatedSprite2D = $AnimatedSprite2D
	var blink_tween := create_tween().set_loops(3)
	blink_tween.tween_property(sprite, "modulate", Color(1.8, 0.4, 0.1), 0.1)
	blink_tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0), 0.1)
	await get_tree().create_timer(WARNING_DURATION).timeout
	_toggle()


func _toggle() -> void:
	_is_open = not _is_open
	_apply_state()
	_schedule_next()


func _apply_state() -> void:
	$CollisionShape2D.set_deferred("disabled", _is_open)
	$AnimatedSprite2D.play("open" if _is_open else "closed")
	$AnimatedSprite2D.modulate = Color(1.0, 1.0, 1.0)
