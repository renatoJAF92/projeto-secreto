extends AnimatableBody2D

@export_group("Movement")
@export var move_distance: float = 80.0
@export var move_speed: float = 40.0
@export var move_axis: Vector2 = Vector2(1, 0)

var _start_pos: Vector2


func _ready() -> void:
	_start_pos = position
	_start_tween()


func _start_tween() -> void:
	var duration = move_distance / move_speed if move_speed > 0 else 1.0
	var end_pos = _start_pos + move_axis * move_distance

	var tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "position", end_pos, duration)
	tween.tween_property(self, "position", _start_pos, duration)
