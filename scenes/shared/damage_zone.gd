extends Area2D

@export_group("Damage")
@export var damage_interval: float = 0.5
@export var damage_amount: int = 1

var _timer: Timer
var _player_inside: bool = false


func _ready() -> void:
	monitoring = true
	monitorable = false

	# Create timer programmatically
	_timer = Timer.new()
	_timer.wait_time = damage_interval
	_timer.one_shot = false
	add_child(_timer)
	_timer.timeout.connect(_on_timer_timeout)

	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		_timer.start()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		_timer.stop()


func _on_timer_timeout() -> void:
	if _player_inside and has_overlapping_bodies():
		var bodies = get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("player"):
				body.take_damage(global_position)
