extends CharacterBody2D

# --- Fire tuning (visible in Inspector) ---
@export var fire_rate: float = 2.0
@export var projectile_scene: PackedScene = null

# --- Patrol tuning (visible in Inspector) ---
@export_group("Patrol")
@export var patrol_speed: float = 40.0

# --- Runtime state ---
var _origin: Vector2
var _direction: float = 1.0
var _is_dead: bool = false
var _stomped_this_frame: bool = false
var _fire_timer: float = 0.0
const GRAVITY: float = 900.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var stomp_zone: Area2D = $StompZone
@onready var edge_ray: RayCast2D = $EdgeRayCast


func _ready() -> void:
	_origin = global_position
	add_to_group("enemies")
	_fire_timer = fire_rate
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

	# Horizontal patrol
	velocity.x = _direction * patrol_speed

	# Move and slide
	move_and_slide()

	# Turn logic: at walls or when edge RayCast stops detecting floor
	if is_on_wall() or not edge_ray.is_colliding():
		_direction *= -1.0
		sprite.flip_h = _direction < 0.0
		# Flip the edge_ray position to the new front
		edge_ray.position.x = abs(edge_ray.position.x) * _direction

	# Fire projectiles
	_fire_timer -= delta
	if _fire_timer <= 0.0:
		_spawn_projectile()
		_fire_timer = fire_rate

	# Update animation
	_update_animation()


func _on_stomp_zone_body_entered(body: Node2D) -> void:
	# velocity.y may be 0 if move_and_slide already resolved the collision this frame
	if body.is_in_group("player") and body.velocity.y >= 0.0 and not _stomped_this_frame:
		_stomped_this_frame = true
		die()
		body.velocity.y = body.jump_velocity * 0.6


func _on_body_hitbox_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or _is_dead or _stomped_this_frame:
		return
	# Fallback stomp: player center clearly above enemy center and not moving upward
	if body.global_position.y < global_position.y - 8.0 and body.velocity.y >= 0.0:
		_stomped_this_frame = true
		die()
		body.velocity.y = body.jump_velocity * 0.6
	else:
		body.take_damage(global_position)


func _spawn_projectile() -> void:
	# Spawn and fire projectile if scene is configured
	if projectile_scene == null:
		return

	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = global_position + Vector2(0, -8)
	# Projectile handles its own velocity


func die() -> void:
	_is_dead = true
	sprite.play("death")
	$CollisionShape2D.set_deferred("disabled", true)
	AudioManager.play_sfx("stomp")
	get_tree().create_timer(0.3, true).timeout.connect(queue_free, CONNECT_ONE_SHOT)


func reset_to_origin() -> void:
	global_position = _origin
	_is_dead = false
	velocity = Vector2.ZERO
	_fire_timer = fire_rate
	$CollisionShape2D.set_deferred("disabled", false)
	sprite.play("walk")


# Animation state machine
func _update_animation() -> void:
	var new_anim: String
	if _is_dead:
		new_anim = "death"
	else:
		new_anim = "walk"
	if sprite.sprite_frames and sprite.animation != new_anim:
		sprite.play(new_anim)
