extends CharacterBody2D

@export_group("Patrol")
@export var patrol_range: float = 120.0
@export var patrol_speed: float = 60.0
@export var flight_height: float = -60.0

@export_group("Attack")
@export var detection_range_x: float = 160.0
@export var detection_range_y: float = 180.0
@export var dive_duration: float = 1.2
@export var post_dive_cooldown: float = 2.0

enum State { PATROL, DIVING, COOLDOWN }

var _state: State = State.PATROL
var _is_dead: bool = false
var _dir: float = 1.0
var _origin: Vector2
var _stomped_this_frame: bool = false

var _dive_t: float = 0.0
var _dive_p0: Vector2
var _dive_p1: Vector2
var _dive_p2: Vector2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var stomp_zone: Area2D = $StompZone
@onready var hurt_zone: Area2D = $HurtZone


func _ready() -> void:
	_origin = global_position
	add_to_group("enemies")
	stomp_zone.body_entered.connect(_on_stomp_entered)
	hurt_zone.body_entered.connect(_on_hurt_entered)
	hurt_zone.monitoring = false


func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	_stomped_this_frame = false

	match _state:
		State.PATROL:
			_do_patrol(delta)
		State.DIVING:
			_do_dive(delta)
		State.COOLDOWN:
			_do_patrol(delta)


func _do_patrol(delta: float) -> void:
	position.x += _dir * patrol_speed * delta
	position.y = _origin.y + flight_height + sin(Time.get_ticks_msec() * 0.004) * 4.0

	var dist = position.x - _origin.x
	if dist > patrol_range or dist < -patrol_range:
		_dir *= -1.0

	sprite.flip_h = _dir < 0.0
	if sprite.animation != "fly":
		_play_anim("fly")

	if _state == State.PATROL:
		_check_player_in_range()


func _check_player_in_range() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var dx = abs(player.global_position.x - global_position.x)
	var dy = player.global_position.y - global_position.y
	if dx < detection_range_x and dy > 0 and dy < detection_range_y:
		_start_dive(player.global_position)


func _start_dive(target: Vector2) -> void:
	_state = State.DIVING
	_dive_t = 0.0
	hurt_zone.monitoring = true
	_dive_p0 = global_position
	_dive_p1 = Vector2(target.x, target.y - 4.0)
	_dive_p2 = Vector2(_origin.x + _dir * patrol_range * 0.5, _origin.y + flight_height)


func _do_dive(delta: float) -> void:
	_dive_t += delta / dive_duration
	if _dive_t >= 1.0:
		_dive_t = 1.0
		global_position = _dive_p2
		_state = State.COOLDOWN
		hurt_zone.monitoring = false
		_play_anim("fly")
		get_tree().create_timer(post_dive_cooldown).timeout.connect(
			func(): _state = State.PATROL, CONNECT_ONE_SHOT
		)
		return

	# V-shaped path: dive straight to player, then back up
	var t := _dive_t
	if t < 0.5:
		global_position = _dive_p0.lerp(_dive_p1, t * 2.0)
	else:
		global_position = _dive_p1.lerp(_dive_p2, (t - 0.5) * 2.0)

	if sprite.animation != "dive":
		_play_anim("dive")
	sprite.flip_h = (_dive_p1.x - _dive_p0.x) < 0.0


func _on_stomp_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.velocity.y > 30.0 and not _stomped_this_frame:
		_stomped_this_frame = true
		die()
		body.velocity.y = body.jump_velocity * 0.6


func _on_hurt_entered(body: Node2D) -> void:
	if body.is_in_group("player") and _state == State.DIVING:
		body.take_damage(global_position)


func die() -> void:
	if _is_dead:
		return
	_is_dead = true
	hurt_zone.monitoring = false
	$CollisionShape2D.set_deferred("disabled", true)
	AudioManager.play_sfx("stomp")
	_play_anim("death")
	get_tree().create_timer(0.4).timeout.connect(queue_free, CONNECT_ONE_SHOT)


func _play_anim(anim: String) -> void:
	match anim:
		"fly":
			sprite.scale = Vector2(0.45, 0.45)  # fly source is 960x540 (large native content)
		"dive", "death":
			sprite.scale = Vector2(0.75, 0.75)  # attack/death source is 109x64 (small native content)
	sprite.play(anim)
