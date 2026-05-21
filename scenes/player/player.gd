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

# --- Runtime state ---
var _was_on_floor: bool = false
var _coyote_timer: int = 0
var _jump_buffer_timer: int = 0
var _jumped_this_frame: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	_jumped_this_frame = false

	# 1. Asymmetric gravity: heavier fall than rise
	velocity.y += (gravity_up if velocity.y < 0.0 else gravity_down) * delta

	# 2. Horizontal movement
	var dir := Input.get_axis("walk_left", "walk_right")
	if dir != 0.0:
		velocity.x = dir * run_speed
		sprite.flip_h = dir < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, run_speed)

	# 3. Coyote time — detect transition from floor to air (not from a jump)
	if _was_on_floor and not is_on_floor() and not _jumped_this_frame:
		_coyote_timer = coyote_frames
	if not is_on_floor():
		_coyote_timer = max(_coyote_timer - 1, 0)

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

	# 7. Capture was_on_floor BEFORE move_and_slide (reflects previous frame state)
	_was_on_floor = is_on_floor()
	move_and_slide()

	# 8. Landing detection (post move_and_slide — landing edge transition)
	if not _was_on_floor and is_on_floor():
		_on_land()
	_was_on_floor = is_on_floor()

	# 9. Update animation state
	_update_animation()


# Stub: Plans 02/03 will add squash/stretch + dust here
func _on_land() -> void:
	pass


# Animation state machine — Plan 02 adds hurt/death states
# Guarded by sprite_frames null-check: avoids errors before SpriteFrames exists (Plan 02)
func _update_animation() -> void:
	var new_anim: String
	if not is_on_floor():
		new_anim = "jump" if velocity.y < 0.0 else "fall"
	elif abs(velocity.x) > 10.0:
		new_anim = "run"
	else:
		new_anim = "idle"
	if sprite.sprite_frames and sprite.animation != new_anim:
		sprite.play(new_anim)
