extends CharacterBody2D

@export_group("Patrol")
@export var moto_speed_normal: float = 200.0
@export var moto_speed_solo: float = 280.0

var _direction: float = 1.0
var _is_dead: bool = false
var _stomped_this_frame: bool = false
var _hp: int = 2
var _phase: int = 1
const GRAVITY: float = 900.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var stomp_zone: Area2D = $StompZone
@onready var edge_ray: RayCast2D = $EdgeRayCast


func _ready() -> void:
	add_to_group("enemies")
	stomp_zone.body_entered.connect(_on_stomp_zone_body_entered)
	$BodyHitbox.body_entered.connect(_on_body_hitbox_entered)
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.play("walk_2")


func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	_stomped_this_frame = false
	velocity.y += GRAVITY * delta
	var cur_anim := sprite.animation
	if cur_anim == &"phase_death" or cur_anim == &"final_death":
		velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)
	else:
		var spd := moto_speed_normal if _phase == 1 else moto_speed_solo
		velocity.x = _direction * spd
	move_and_slide()
	if sprite.animation == &"walk_2" or sprite.animation == &"walk_1":
		if is_on_wall() or not edge_ray.is_colliding():
			_direction *= -1.0
			sprite.flip_h = _direction < 0.0
			edge_ray.position.x = abs(edge_ray.position.x) * _direction


func _on_animation_finished() -> void:
	if sprite.animation == &"phase_death":
		_phase = 2
		sprite.play("walk_1")
	elif sprite.animation == &"final_death":
		queue_free()


func _on_stomp_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.velocity.y > 30.0 and not _stomped_this_frame:
		_stomped_this_frame = true
		take_hit()
		body.velocity.y = body.jump_velocity * 0.6


func _on_body_hitbox_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or _is_dead or _stomped_this_frame:
		return
	if body.global_position.y < global_position.y - 8.0 and body.velocity.y > 30.0:
		_stomped_this_frame = true
		take_hit()
		body.velocity.y = body.jump_velocity * 0.6
	else:
		body.take_damage(global_position)


func take_hit() -> void:
	_hp -= 1
	AudioManager.play_sfx("stomp")
	if _hp <= 0:
		die()
	else:
		sprite.play("phase_death")


func take_damage(from_position: Vector2) -> void:
	take_hit()


func die() -> void:
	_is_dead = true
	$CollisionShape2D.set_deferred("disabled", true)
	AudioManager.play_sfx("stomp")
	sprite.play("final_death")
