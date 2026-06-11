extends StaticBody2D

@export_group("Timing")
@export var open_time: float = 1.5
@export var closed_time: float = 2.0
@export var start_open: bool = false

var _is_open: bool = false


func _ready() -> void:
	_is_open = start_open
	_update_state()
	_schedule_next()


func _schedule_next() -> void:
	var wait_time = open_time if _is_open else closed_time
	get_tree().create_timer(wait_time).timeout.connect(_toggle, CONNECT_ONE_SHOT)


func _toggle() -> void:
	_is_open = not _is_open
	_update_state()
	_schedule_next()


func _update_state() -> void:
	# Toggle collision: open=disabled, closed=enabled
	$CollisionShape2D.set_deferred("disabled", _is_open)

	# Toggle visuals
	if has_node("visual_closed"):
		$visual_closed.visible = not _is_open
	if has_node("visual_open"):
		$visual_open.visible = _is_open
