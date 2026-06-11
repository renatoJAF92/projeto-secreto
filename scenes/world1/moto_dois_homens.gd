extends CharacterBody2D

# --- Patrol tuning (visible in Inspector) ---
@export_group("Patrol")
@export var moto_speed_normal: float = 80.0
@export var moto_speed_solo: float = 120.0

# --- Runtime state ---
var _origin: Vector2
var _direction: float = 1.0
var _is_dead: bool = false
var _stomped_this_frame: bool = false
var _hp: int = 2  # 2 hits: first drops passenger, second kills
var _phase: int = 1  # 1 = both riders, 2 = pilot only
const GRAVITY: float = 900.0

@onready var stomp_zone: Area2D = $StompZone
@onready var edge_ray: RayCast2D = $EdgeRayCast


func _ready() -> void:
	_origin = global_position
	add_to_group("enemies")
	stomp_zone.body_entered.connect(_on_stomp_zone_body_entered)
	var body_hitbox: Area2D = $BodyHitbox
	body_hitbox.body_entered.connect(_on_body_hitbox_entered)


func _physics_process(delta: float) -> void:
	# Guard: if dead, do nothing
	if _is_dead:
		return

	# Reset stomp flag at the start of each frame
	_stomped_this_frame = false

	# Apply gravity
	velocity.y += GRAVITY * delta

	# Horizontal patrol — choose speed based on phase
	var patrol_speed = moto_speed_normal if _phase == 1 else moto_speed_solo
	velocity.x = _direction * patrol_speed

	# Move and slide
	move_and_slide()

	# Turn logic: at walls or when edge RayCast stops detecting floor
	if is_on_wall() or not edge_ray.is_colliding():
		_direction *= -1.0
		# Flip the edge_ray position to the new front
		edge_ray.position.x = abs(edge_ray.position.x) * _direction

	# Update visuals
	_update_visual()


func _on_stomp_zone_body_entered(body: Node2D) -> void:
	# velocity.y may be 0 if move_and_slide already resolved the collision this frame
	if body.is_in_group("player") and body.velocity.y >= 0.0 and not _stomped_this_frame:
		_stomped_this_frame = true
		take_hit()
		body.velocity.y = body.jump_velocity * 0.6


func _on_body_hitbox_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or _is_dead or _stomped_this_frame:
		return
	# Fallback stomp: player center clearly above enemy center and not moving upward
	if body.global_position.y < global_position.y - 8.0 and body.velocity.y >= 0.0:
		_stomped_this_frame = true
		take_hit()
		body.velocity.y = body.jump_velocity * 0.6
	else:
		body.take_damage(global_position)


func take_hit() -> void:
	_hp -= 1
	if _hp <= 0:
		die()
	else:
		# Phase 2: passenger knocked off, moto speeds up
		_phase = 2
		if has_node("Visual/Passenger"):
			$Visual/Passenger.visible = false


func die() -> void:
	_is_dead = true
	$CollisionShape2D.set_deferred("disabled", true)
	AudioManager.play_sfx("stomp")
	get_tree().create_timer(0.3, true).timeout.connect(queue_free, CONNECT_ONE_SHOT)


func reset_to_origin() -> void:
	global_position = _origin
	_is_dead = false
	_hp = 2
	_phase = 1
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", false)
	if has_node("Visual/Passenger"):
		$Visual/Passenger.visible = true


func _update_visual() -> void:
	# Optional: add idle animation or passenger bobbing here
	pass
