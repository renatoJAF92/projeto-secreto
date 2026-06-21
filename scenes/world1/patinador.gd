extends CharacterBody2D

@export_group("Patrol")
@export var patrol_speed: float = 130.0

@export_group("Attack")
@export var attack_range: float = 40.0
@export var attack_cooldown: float = 1.2

var _origin: Vector2
var _direction: float = 1.0
var _is_dead: bool = false
var _stomped_this_frame: bool = false
var _is_attacking: bool = false
var _attack_timer: float = 0.0
const GRAVITY: float = 900.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var stomp_zone: Area2D = $StompZone
@onready var edge_ray: RayCast2D = $EdgeRayCast


func _ready() -> void:
	_origin = global_position
	add_to_group("enemies")
	stomp_zone.body_entered.connect(_on_stomp_zone_body_entered)
	$BodyHitbox.body_entered.connect(_on_body_hitbox_entered)
	sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	_stomped_this_frame = false
	velocity.y += GRAVITY * delta
	_attack_timer -= delta

	if _is_attacking:
		velocity.x = move_toward(velocity.x, 0.0, patrol_speed)
		move_and_slide()
		return

	velocity.x = _direction * patrol_speed
	move_and_slide()

	if is_on_wall() or not edge_ray.is_colliding():
		_direction *= -1.0
		sprite.flip_h = _direction < 0.0
		edge_ray.position.x = abs(edge_ray.position.x) * _direction

	var player = get_tree().get_first_node_in_group("player")
	if player and _attack_timer <= 0.0 and abs(player.global_position.x - global_position.x) < attack_range:
		_is_attacking = true
		_attack_timer = attack_cooldown
		sprite.play("attack")
	elif sprite.animation != "run":
		sprite.play("run")


func _on_animation_finished() -> void:
	if sprite.animation == "attack":
		_is_attacking = false


func _on_stomp_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.velocity.y > 30.0 and not _stomped_this_frame:
		_stomped_this_frame = true
		die()
		body.velocity.y = body.jump_velocity * 0.6


func _on_body_hitbox_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or _is_dead or _stomped_this_frame:
		return
	if body.global_position.y < global_position.y - 8.0 and body.velocity.y > 30.0:
		_stomped_this_frame = true
		die()
		body.velocity.y = body.jump_velocity * 0.6
	else:
		body.take_damage(global_position)


func die() -> void:
	_is_dead = true
	sprite.play("death")
	$CollisionShape2D.set_deferred("disabled", true)
	AudioManager.play_sfx("stomp")
	get_tree().create_timer(0.3, true).timeout.connect(queue_free, CONNECT_ONE_SHOT)
