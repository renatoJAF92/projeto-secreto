extends AnimatableBody2D

@export_group("Movement")
@export var move_distance: float = 80.0
@export var move_speed: float = 40.0
@export var move_axis: Vector2 = Vector2(1, 0)
@export var phase_offset: float = 0.0  # 0.0 to 1.0 — starting position in cycle

var _start_pos: Vector2
var _time: float = 0.0


func _ready() -> void:
	_start_pos = position
	if move_speed > 0:
		var period = 2.0 * move_distance / move_speed
		_time = phase_offset * period


func _physics_process(delta: float) -> void:
	_time += delta
	var period = 2.0 * move_distance / move_speed if move_speed > 0 else 1.0
	var t = fmod(_time, period) / period
	var frac = 1.0 - abs(t * 2.0 - 1.0)  # triangle wave 0→1→0
	position = _start_pos + move_axis * move_distance * frac
