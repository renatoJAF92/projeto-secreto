extends CharacterBody2D

# --- Movement tuning (visible in Inspector) ---
@export_group("Movement")
@export var run_speed: float = 200.0
@export var jump_velocity: float = -380.0
@export var gravity_up: float = 900.0
@export var gravity_down: float = 1600.0
@export var coyote_frames: int = 6
@export var jump_buffer_frames: int = 8
@export var jump_cut_multiplier: float = 0.4

@export_group("Dash")
@export var dash_speed: float = 550.0
@export var dash_duration_frames: int = 12
@export var dash_cooldown: float = 0.4

@export_group("Knockback")
@export var knockback_decay: float = 8.0
@export var knockback_impulse: float = 300.0

# --- Runtime state ---
var _coyote_timer: int = 0
var _jump_buffer_timer: int = 0
var _jumped_this_frame: bool = false

# Dash state
var _is_dashing: bool = false
var _dash_frames_remaining: int = 0
var _dash_direction: float = 1.0
var _can_dash: bool = true
var _is_invincible: bool = false

# Knockback / damage state
var _knockback: Vector2 = Vector2.ZERO
var _is_hurt: bool = false
var _is_dead: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	_jumped_this_frame = false

	# 1. Asymmetric gravity: heavier fall than rise (skipped while dashing)
	if not _is_dashing:
		velocity.y += (gravity_up if velocity.y < 0.0 else gravity_down) * delta

	# 2. Dash takes priority over normal horizontal movement
	if _is_dashing:
		velocity.x = _dash_direction * dash_speed
		velocity.y = 0.0
		_dash_frames_remaining -= 1
		if _dash_frames_remaining <= 0:
			_is_dashing = false
			_is_invincible = false
	else:
		# Normal horizontal movement
		var dir := Input.get_axis("walk_left", "walk_right")
		if dir != 0.0:
			velocity.x = dir * run_speed
			sprite.flip_h = dir < 0.0
		else:
			velocity.x = move_toward(velocity.x, 0.0, run_speed)

		# Dash trigger
		if Input.is_action_just_pressed("dash") and _can_dash:
			_start_dash()

	# 3. Knockback application — added AFTER movement, BEFORE move_and_slide
	if _knockback.length() > 1.0:
		velocity += _knockback
		_knockback = _knockback.lerp(Vector2.ZERO, knockback_decay * delta)
	else:
		_knockback = Vector2.ZERO

	# 4. Jump buffer — remember jump press during airtime
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_frames
	else:
		_jump_buffer_timer = max(_jump_buffer_timer - 1, 0)

	# 5. Jump cut (variable height) — release jump early to cut ascent
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut_multiplier

	# 6. Execute jump when buffer active and grounded (or coyote still valid)
	if _jump_buffer_timer > 0 and (is_on_floor() or _coyote_timer > 0):
		velocity.y = jump_velocity
		_coyote_timer = 0
		_jump_buffer_timer = 0
		_jumped_this_frame = true
		# Dash-cancel on jump: prevent dash velocity from carrying through jump arc
		_is_dashing = false
		_dash_frames_remaining = 0

	# 7. Snapshot floor state BEFORE move_and_slide, then slide
	var pre_floor := is_on_floor()
	move_and_slide()

	# 8. Coyote: detect walk-off-edge transition (pre=on, post=off, didn't jump)
	if pre_floor and not is_on_floor() and not _jumped_this_frame:
		_coyote_timer = coyote_frames
	if not is_on_floor():
		_coyote_timer = max(_coyote_timer - 1, 0)

	# 9. Landing detection
	if not pre_floor and is_on_floor():
		_on_land()

	# 10. Update animation state
	_update_animation()


func _start_dash() -> void:
	_is_dashing = true
	_is_invincible = true
	_can_dash = false
	_dash_direction = -1.0 if sprite.flip_h else 1.0
	_dash_frames_remaining = dash_duration_frames
	get_tree().create_timer(dash_cooldown).timeout.connect(func(): _can_dash = true, CONNECT_ONE_SHOT)


# Called by hazards/enemies — direction-based knockback away from hit source
func take_damage(hit_from_position: Vector2) -> void:
	if _is_invincible:
		return
	var direction := (global_position - hit_from_position).normalized()
	_knockback = direction * knockback_impulse
	_jump_buffer_timer = 0  # Cancel buffered jump so it doesn't fire after the hit
	_is_hurt = true
	# Plan 03 will add white-flash + hit-stop here


# Stub: Plans 02/03 will add squash/stretch + dust here
func _on_land() -> void:
	pass


# Animation state machine — 6 states by priority
# Guard: only call play() when animation actually changes (prevents frame-0 freeze)
func _update_animation() -> void:
	var new_anim: String
	if _is_hurt:
		new_anim = "hurt"
	elif _is_dead:
		new_anim = "death"
	elif not is_on_floor():
		new_anim = "jump" if velocity.y < 0.0 else "fall"
	elif abs(velocity.x) > 10.0:
		new_anim = "run"
	else:
		new_anim = "idle"
	if sprite.sprite_frames and sprite.animation != new_anim:
		sprite.play(new_anim)


# Connected to AnimatedSprite2D.animation_finished signal (wired in player.tscn)
func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "hurt":
		_is_hurt = false
	elif sprite.animation == "death":
		print("Player death animation finished — respawn hooked in Phase 3")


# Temporary helper: exposes death animation for test scene
# Phase 3 will wire real death/respawn logic
func die() -> void:
	_is_dead = true
