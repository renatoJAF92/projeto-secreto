extends CharacterBody2D

signal died

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
@export var knockback_vertical_impulse: float = 150.0

@export_group("Juice")
@export var hit_stop_frames: int = 3

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

# Power system (new in Phase 4)
var _current_power: String = ""  # "" = no power
var _power_cooldown: float = 0.0

# Juice tween handles
var _flash_tween: Tween
var _squash_tween: Tween

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dust_particles: CPUParticles2D = $DustParticles


func _ready() -> void:
	_current_power = SaveManager.current_save.get("active_power", "")


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

		# Power usage (new)
		if Input.is_action_just_pressed("use_power") and _current_power != "":
			use_power()

		# Power cycling (new)
		if Input.is_action_just_pressed("cycle_power"):
			cycle_power()

	# 3. Knockback application — SET velocity.x (not +=) to prevent per-frame accumulation
	if _knockback.length() > 1.0:
		velocity.x = _knockback.x
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

	# 5.5. Power cooldown decrement
	_power_cooldown -= delta

	# 6. Execute jump when buffer active and grounded (or coyote still valid)
	if _jump_buffer_timer > 0 and (is_on_floor() or _coyote_timer > 0):
		velocity.y = jump_velocity
		_coyote_timer = 0
		_jump_buffer_timer = 0
		_jumped_this_frame = true
		# Dash-cancel on jump: prevent dash velocity from carrying through jump arc
		_is_dashing = false
		_dash_frames_remaining = 0
		_apply_jump_stretch()
		AudioManager.play_sfx("jump")

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


# Captures jump press even when _physics_process is frozen by hit-stop (time_scale=0)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		_jump_buffer_timer = jump_buffer_frames


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
	velocity.y = min(velocity.y, -knockback_vertical_impulse)  # Pop upward on hit
	_jump_buffer_timer = 0  # Cancel buffered jump so it doesn't fire after the hit
	_is_hurt = true
	_start_white_flash()
	_start_hit_stop(hit_stop_frames)  # Detached coroutine — take_damage returns immediately


func _on_land() -> void:
	_apply_land_squash()
	dust_particles.restart()  # One-shot burst on every landing


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
		died.emit()


# --- Power system (Phase 4+) ---

func use_power() -> void:
	if _power_cooldown > 0.0:
		return

	match _current_power:
		"sketch":
			_use_sketch_power()
		"amor":
			_use_amor_power()


func _use_sketch_power() -> void:
	# Plan 03: projectile spawn
	pass


func _use_amor_power() -> void:
	# Plan 04: aura spawn
	pass


func cycle_power() -> void:
	var unlocked = SaveManager.current_save.get("powers_unlocked", [])
	if unlocked.is_empty():
		return

	var current_idx = unlocked.find(_current_power)
	if current_idx == -1:
		current_idx = 0
	else:
		current_idx = (current_idx + 1) % unlocked.size()

	_current_power = unlocked[current_idx]
	SaveManager.current_save["active_power"] = _current_power
	SaveManager.save_game()


func unlock_power(power_id: String) -> void:
	var unlocked = SaveManager.current_save.get("powers_unlocked", [])
	if power_id not in unlocked:
		unlocked.append(power_id)
		SaveManager.current_save["powers_unlocked"] = unlocked

	# Auto-select if first power
	if _current_power == "":
		_current_power = power_id
		SaveManager.current_save["active_power"] = power_id

	SaveManager.save_game()


func heal(amount: int = 1) -> void:
	# Phase 4+: restore health (3 PV max)
	# TODO: Implement when HP system is wired in Phase 4
	pass


# --- Juice effects ---

# Squash sprite tall+narrow on jump takeoff; elastic ease-out back to (1,1)
func _apply_jump_stretch() -> void:
	if _squash_tween and _squash_tween.is_valid():
		_squash_tween.kill()
	sprite.scale = Vector2(0.75, 1.3)
	_squash_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_squash_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.25)


# Squash sprite wide+short on landing; elastic ease-out back to (1,1)
func _apply_land_squash() -> void:
	if _squash_tween and _squash_tween.is_valid():
		_squash_tween.kill()
	sprite.scale = Vector2(1.3, 0.75)
	_squash_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_squash_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.2)


# Flash sprite to HDR white then tween back to normal color
func _start_white_flash() -> void:
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	sprite.modulate = Color(10.0, 10.0, 10.0)
	_flash_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	_flash_tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0), 0.3)


# Freeze game for N frames then resume — MUST use create_timer(duration, true) so
# the timer is NOT paused by time_scale=0 (RESEARCH.md Pitfall 2)
func _start_hit_stop(frames: int = 3) -> void:
	Engine.time_scale = 0.0
	await get_tree().create_timer(frames / 60.0, true).timeout
	Engine.time_scale = 1.0


# Temporary helper: exposes death animation for test scene
# Phase 3 will wire real death/respawn logic
func die() -> void:
	_is_dead = true
