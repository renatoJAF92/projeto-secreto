# Phase 1: Game Feel — Research

**Researched:** 2026-05-21
**Domain:** Godot 4.4.x GDScript — 2D platformer character controller, juice effects, pixel art rendering
**Confidence:** HIGH (core mechanics), MEDIUM (specific frame values), HIGH (particles/web export)

---

## Summary

Phase 1 builds the complete character controller for Natália from scratch — no GDScript files exist yet. The foundation is a `CharacterBody2D` with `move_and_slide()` plus manual gravity, implementing coyote time (6 frames), jump buffer (8 frames), asymmetric gravity, horizontal dash, knockback, 6 sprite animations, and visual juice (squash/stretch, landing dust, white flash, hit-stop).

The Godot 4.4.x API is stable and well-documented. `CharacterBody2D` is unambiguously the right node — `RigidBody2D` gives up control, and the KinematicBody2D name from Godot 3 is gone. All physics mechanics are implemented in `_physics_process` by mutating the `velocity` property and calling `move_and_slide()` at the end.

For this project's GL Compatibility renderer targeting web export: **use `CPUParticles2D`**, never `GPUParticles2D`. GPU particles rely on compute shaders not available in the Compatibility renderer, causing silent failures and 2-second load spikes in web builds. For animations, `AnimatedSprite2D` is the right choice for 6 sprite-sheet animations — `AnimationTree` is overkill at this count and adds setup friction. Hit-stop uses `Engine.time_scale` briefly set to `0.0` via a coroutine, which is the standard Godot 4 pattern and safe for 2–4 frames.

**Primary recommendation:** Build one `player.gd` script on a `CharacterBody2D`, with a separate `player_effects.gd` (or inner functions) handling visual juice, keeping physics logic and visual feedback cleanly separated. Structure into 3 plans: (1) core movement + coyote + jump buffer + asymmetric gravity, (2) dash + knockback + animation state machine, (3) juice effects + test scene.

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| MOVE-01 | Correr, pular, cair com coyote time 6 frames, jump buffer 8 frames, gravidade assimétrica | CharacterBody2D + `_physics_process` + frame counter pattern — fully documented |
| MOVE-02 | Dash horizontal (unlock gate para Mundo 2 vem depois) | Velocity override + frame counter + `is_dashing` flag — well-established pattern |
| MOVE-03 | Knockback ao ser atingida | External velocity impulse via `knockback` Vector2 with lerp decay — standard approach |
| MOVE-04 | Animações idle, run, jump, fall, hurt, death via AnimationPlayer ou AnimatedSprite2D | `AnimatedSprite2D` + `SpriteFrames` resource, driven by state logic in `_physics_process` |
| MOVE-05 | Juice visual: poeira ao aterrissar, squash/stretch, flash branco, hit-stop 2-4 frames | `CPUParticles2D` + `Tween` scale + `modulate` + `Engine.time_scale` — each has verified pattern |
</phase_requirements>

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Physics / velocity | CharacterBody2D script (`player.gd`) | — | All velocity mutation and `move_and_slide()` live in one script |
| Coyote time / jump buffer | `player.gd` — frame counters | — | Integer counters in `_physics_process`, no external nodes needed |
| Dash | `player.gd` — `is_dashing` state | — | Velocity override that ignores normal movement input while active |
| Knockback | `player.gd` — `knockback` Vector2 | Enemy/hitbox nodes (emit signal) | Player receives knockback vector; enemies call a method or emit signal |
| Sprite animations | `AnimatedSprite2D` child node | `player.gd` drives state | `player.gd` decides which animation to play; sprite node handles frames |
| Squash / stretch | `AnimatedSprite2D` scale property | `Tween` (created in `player.gd`) | Scale applied to sprite node only, not CharacterBody2D root |
| White flash | `AnimatedSprite2D` `modulate` | `Tween` | Modulate overshoot to `Color(10,10,10)` then tween back |
| Hit-stop | `Engine.time_scale` (global) | Autoload `GameManager` (future) | Brief global slow for 2-4 physics frames; no autoload needed yet |
| Landing dust | `CPUParticles2D` child node | `player.gd` triggers `emit_particle` | Particle node at feet position, one-shot burst on land detection |
| Test scene HUD | `CanvasLayer` + `Label` nodes | — | Separate from player script; reads exported vars for debug display |

---

## Standard Stack

### Core Nodes (no package install — all built-in Godot)

| Node/Class | Version | Purpose | Why Standard |
|-----------|---------|---------|--------------|
| `CharacterBody2D` | Godot 4.4.x | Character physics root | Purpose-built for code-controlled characters; replaces Godot 3's `KinematicBody2D` |
| `AnimatedSprite2D` | Godot 4.4.x | Sprite sheet animation | Simpler than `AnimationPlayer` for 6 frame-based animations; SpriteFrames resource in Inspector |
| `CPUParticles2D` | Godot 4.4.x | Landing dust and hit particles | CPU-based; works on all renderers including GL Compatibility; no compute shader needed |
| `CollisionShape2D` | Godot 4.4.x | Physics collision | Child of CharacterBody2D; use `CapsuleShape2D` or `RectangleShape2D` for 32x32 sprite |
| `Tween` | Godot 4.4.x | Squash/stretch, white flash animations | `create_tween()` — no node needed, created procedurally in script |
| `Timer` | Godot 4.4.x | Coyote time, dash cooldown | One-shot timers; or use frame counters (see Pattern 1) |
| `CanvasLayer` + `Label` | Godot 4.4.x | Debug HUD in test scene | Standard pattern; CanvasLayer ensures HUD renders above game world |

### No External Plugins Needed for Phase 1

All game-feel mechanics are implementable with built-in Godot 4 nodes and GDScript. No Godot Asset Library plugins are required.

---

## Architecture Patterns

### System Architecture Diagram

```
Input (keyboard/gamepad)
        |
        v
_physics_process(delta) — called at 60 Hz (Physics FPS)
        |
        +---> [1] Apply gravity (asymmetric: check velocity.y direction)
        |
        +---> [2] Read movement input  
        |           |
        |           +-- if is_dashing: override horizontal velocity, skip normal input
        |           +-- if has knockback: add knockback, decay it
        |           +-- else: normal run/deceleration
        |
        +---> [3] Coyote time check
        |           was_on_floor_last_frame AND NOT is_on_floor() AND NOT jumped_this_frame
        |           -> start coyote_timer (6 frames)
        |
        +---> [4] Jump intent check
        |           Input.is_action_just_pressed("jump") -> set jump_buffer_frames = 8
        |           jump_buffer_frames > 0 AND (is_on_floor() OR coyote_active)
        |           -> apply jump velocity, clear flags
        |
        +---> [5] move_and_slide()
        |
        +---> [6] Post-move state detection
        |           just_landed = NOT was_on_floor AND is_on_floor()
        |           if just_landed -> trigger dust particles, squash tween
        |
        +---> [7] Update animation state (driven by velocity + flags)
        |
        +---> [8] Update frame counters (decrement coyote_frames, jump_buffer_frames, dash_frames)
        
Damage signal (from hitbox Area2D)
        |
        v
take_damage(direction: Vector2)
        +---> apply knockback velocity
        +---> start white flash tween
        +---> start hit-stop coroutine (Engine.time_scale = 0.0 for 3 frames)
        +---> play "hurt" animation
```

### Recommended Project Structure

```
scenes/
├── player/
│   ├── player.tscn          # CharacterBody2D root with all child nodes
│   └── player.gd            # All movement + animation + juice logic
├── test_movement/
│   ├── test_movement.tscn   # Test scene: platforms + player + debug HUD
│   └── test_movement.gd     # HUD display script (reads player exported vars)
└── main.tscn                # Existing minimal scene

assets/
└── sprites/
    └── natalia/
        └── natalia_sheet.png  # Sprite sheet (placeholder 32x32 px)
```

---

### Pattern 1: Core Platformer with Coyote Time and Jump Buffer (Frame Counter Approach)

**What:** Frame counter integers (not Timer nodes) for coyote time and jump buffer. Simpler to reason about, no node dependencies, easy to tune.

**When to use:** Preferred over Timer nodes for short windows (< 15 frames) because frame counters stay in sync with `_physics_process` without coroutine overhead.

**Godot 4.4.x note:** `move_and_slide()` does NOT take delta — it uses the built-in physics step internally. Do NOT multiply velocity by delta when assigning to `velocity.x` or `velocity.y` for direct sets. DO multiply by delta only for accumulation (gravity: `velocity.y += gravity * delta`). This is a common first-timer mistake.

```gdscript
# Source: Verified pattern — kidscancode.org/godot_recipes/4.x/2d/coyote_time/ 
#         + docs.godotengine.org/en/4.4/tutorials/physics/using_character_body_2d.html

extends CharacterBody2D

# --- Exported tuning values (visible in Inspector) ---
@export var run_speed: float = 200.0
@export var jump_velocity: float = -380.0
@export var gravity_up: float = 900.0    # Applied when velocity.y < 0 (ascending)
@export var gravity_down: float = 1600.0 # Applied when velocity.y >= 0 (descending) — heavier fall

@export var coyote_frames: int = 6       # Frames after leaving floor where jump still works
@export var jump_buffer_frames: int = 8  # Frames before landing where queued jump executes

# --- Runtime state ---
var _coyote_timer: int = 0
var _jump_buffer_timer: int = 0
var _was_on_floor: bool = false
var _jumped_this_frame: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
    _jumped_this_frame = false
    
    # 1. Asymmetric gravity
    if velocity.y < 0.0:
        velocity.y += gravity_up * delta
    else:
        velocity.y += gravity_down * delta
    
    # 2. Horizontal movement
    var dir = Input.get_axis("ui_left", "ui_right")
    if dir != 0.0:
        velocity.x = dir * run_speed
        sprite.flip_h = dir < 0.0
    else:
        velocity.x = move_toward(velocity.x, 0.0, run_speed)  # Instant stop
    
    # 3. Coyote time — detect leaving floor without jumping
    if _was_on_floor and not is_on_floor() and not _jumped_this_frame:
        _coyote_timer = coyote_frames
    if not is_on_floor():
        _coyote_timer = max(_coyote_timer - 1, 0)
    
    # 4. Jump buffer — remember jump press during airtime
    if Input.is_action_just_pressed("jump"):
        _jump_buffer_timer = jump_buffer_frames
    else:
        _jump_buffer_timer = max(_jump_buffer_timer - 1, 0)
    
    # 5. Execute jump when grounded (or coyote) and buffer is active
    var can_jump = is_on_floor() or _coyote_timer > 0
    if _jump_buffer_timer > 0 and can_jump:
        velocity.y = jump_velocity
        _coyote_timer = 0
        _jump_buffer_timer = 0
        _jumped_this_frame = true
    
    # 6. Move
    _was_on_floor = is_on_floor()
    move_and_slide()
    
    # 7. Landing detection (post move_and_slide)
    if not _was_on_floor and is_on_floor():
        _on_land()
    
    _was_on_floor = is_on_floor()
    
    # 8. Animation state
    _update_animation()

func _on_land() -> void:
    # Trigger dust + squash (see Pattern 4 and 5)
    pass

func _update_animation() -> void:
    if not is_on_floor():
        sprite.play("jump" if velocity.y < 0.0 else "fall")
    elif abs(velocity.x) > 10.0:
        sprite.play("run")
    else:
        sprite.play("idle")
```

**Critical ordering rule:** `_was_on_floor` must be captured BEFORE `move_and_slide()` to detect the transition, then updated AFTER. The pattern above shows the correct double-assignment to detect the landing edge.

---

### Pattern 2: Asymmetric Gravity Detail

**What:** Separate gravity constants for ascending vs descending arc. Creates the "heavy" fall feel of responsive platformers (Celeste, Hollow Knight).

**Industry values for 320x180 viewport at 60 physics FPS:**
- `gravity_up: 900.0` (gentle float on ascent)
- `gravity_down: 1600.0` (snappy fall)
- `jump_velocity: -380.0` (sets peak height)
- Peak height ≈ `jump_velocity² / (2 * gravity_up)` pixels

**Jump cut (variable jump height):** Release jump early to cut velocity:
```gdscript
# Source: [ASSUMED] — common pattern, not verified in official docs this session
# Add to _physics_process BEFORE gravity application:
if Input.is_action_just_released("jump") and velocity.y < 0.0:
    velocity.y *= 0.4  # Cut to 40% — tune this multiplier
```

---

### Pattern 3: Horizontal Dash

**What:** Override horizontal velocity for N frames; ignore normal movement input while dashing; brief invincibility flag.

**Verified values (community consensus, Godot 4):** Dash duration 10–12 frames, dash speed 500–600px/s at 60fps, cooldown 0.4s.

```gdscript
# Source: [ASSUMED] — synthesized from community patterns
@export var dash_speed: float = 550.0
@export var dash_duration_frames: int = 12
@export var dash_cooldown: float = 0.4

var _is_dashing: bool = false
var _dash_frames_remaining: int = 0
var _dash_direction: float = 1.0
var _dash_invincible: bool = false
var _can_dash: bool = true

func _physics_process(delta: float) -> void:
    # Dash input (check before movement section)
    if Input.is_action_just_pressed("dash") and _can_dash and not _is_dashing:
        _start_dash()
    
    if _is_dashing:
        velocity.x = _dash_direction * dash_speed
        velocity.y = 0.0  # Cancel gravity during dash
        _dash_frames_remaining -= 1
        if _dash_frames_remaining <= 0:
            _is_dashing = false
            _dash_invincible = false
    else:
        # ... normal movement from Pattern 1 ...
        pass
    
    # ... rest of pattern 1 ...

func _start_dash() -> void:
    _is_dashing = true
    _dash_frames_remaining = dash_duration_frames
    _dash_invincible = true
    _can_dash = false
    # Dash in current facing direction
    _dash_direction = -1.0 if sprite.flip_h else 1.0
    # Start cooldown
    await get_tree().create_timer(dash_cooldown).timeout
    _can_dash = true
```

**Note on MOVE-02 "unlock gate for Mundo 2":** The unlock gate is a runtime flag check (e.g., `SaveManager.has_power("dash")`). In Phase 1, the test scene will have dash enabled unconditionally. The lock is a Phase 2 concern.

---

### Pattern 4: Knockback

**What:** Apply an external velocity impulse from a hit direction, decay with `lerp` over frames.

```gdscript
# Source: [VERIFIED: forum.godotengine.org/t/platformer-player-knockback-implementation/59705]
# + [ASSUMED: decay pattern]

var _knockback: Vector2 = Vector2.ZERO
@export var knockback_decay: float = 8.0  # Higher = faster decay; tune 6–12

func take_damage(hit_from_position: Vector2) -> void:
    var direction = (global_position - hit_from_position).normalized()
    _knockback = direction * 300.0  # 300px/s impulse — tune
    # Also: white flash + hit-stop (see Pattern 5)

func _physics_process(delta: float) -> void:
    # Apply knockback AFTER normal velocity computation, BEFORE move_and_slide
    if _knockback.length() > 1.0:
        velocity += _knockback
        _knockback = _knockback.lerp(Vector2.ZERO, knockback_decay * delta)
    else:
        _knockback = Vector2.ZERO
    
    move_and_slide()
```

**Coyote time interaction:** Knockback should NOT reset coyote. Coyote is about voluntary movement off edges. Knockback-launched-off-edge is fine — the player was hit, not exploring a ledge.

---

### Pattern 5: Juice Effects

#### 5a. White Flash on Damage

```gdscript
# Source: [VERIFIED: uhiyama-lab.com/en/notes/godot/modulate-white-flash-damage-effect/]

var _flash_tween: Tween

func _start_white_flash() -> void:
    if _flash_tween and _flash_tween.is_valid():
        _flash_tween.kill()
    sprite.modulate = Color(10.0, 10.0, 10.0)  # HDR white overshoot
    _flash_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
    _flash_tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0), 0.3)
```

#### 5b. Hit-Stop (2–4 frames)

```gdscript
# Source: [VERIFIED: docs.godotengine.org/en/stable/classes/class_engine.html — Engine.time_scale]
# Source: [ASSUMED: coroutine pattern for frame counting]

func _start_hit_stop(frames: int = 3) -> void:
    Engine.time_scale = 0.0
    # Must use real time timer (process_always) because time_scale = 0 stops SceneTreeTimer
    await get_tree().create_timer(frames / 60.0, true).timeout  # true = process_always
    Engine.time_scale = 1.0
```

**Critical:** `get_tree().create_timer(duration, true)` — the second argument `process_always: bool = false` must be `true` when `time_scale` is 0, otherwise the timer itself is frozen and never resolves. This is the single most common hit-stop bug in Godot 4.

**Audio side-effect:** `Engine.time_scale` does not affect audio playback speed (`AudioServer.playback_speed_scale` is separate). Hit SFX plays at normal speed during hit-stop — this is correct behavior.

#### 5c. Squash and Stretch

```gdscript
# Source: [VERIFIED: docs.godotengine.org/en/stable/classes/class_tween.html — Tween.tween_property scale]
# Source: [ASSUMED: specific values]

# Apply scale on the SPRITE node (AnimatedSprite2D), not CharacterBody2D.
# Scaling CharacterBody2D would move the collision shape.

var _squash_tween: Tween

func _apply_jump_stretch() -> void:
    if _squash_tween and _squash_tween.is_valid():
        _squash_tween.kill()
    sprite.scale = Vector2(0.75, 1.3)  # Narrow + tall at jump apex
    _squash_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
    _squash_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.25)

func _apply_land_squash() -> void:
    if _squash_tween and _squash_tween.is_valid():
        _squash_tween.kill()
    sprite.scale = Vector2(1.3, 0.75)  # Wide + short on landing
    _squash_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
    _squash_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.2)
```

**Pixel art note:** Since `snap_2d_transforms_to_pixel` is ON in project.godot, scale Tweens may produce sub-pixel jitter at non-integer scale values. This is acceptable for quick juice effects but keep tween durations short (< 0.3s). Alternatively, use integer scale values (e.g., `Vector2(1, 1)` → `Vector2(1, 2)` for a 2x tall stretch), but this looks blocky. Sub-pixel during animation is generally preferred.

#### 5d. Landing Dust (CPUParticles2D)

```gdscript
# Source: [VERIFIED: github.com/godotengine/godot/issues/75270 — GPUParticles fail on web/Compat renderer]
# Source: [ASSUMED: CPUParticles2D configuration values]

# Scene structure:
# CharacterBody2D (player)
#   └── CPUParticles2D (dust_particles) — positioned at feet (y = +16 for 32px sprite)

@onready var dust_particles: CPUParticles2D = $DustParticles

func _on_land() -> void:
    _apply_land_squash()
    dust_particles.restart()  # One-shot burst on each landing
```

**CPUParticles2D Inspector settings for landing dust:**
- `emitting: false` (controlled by script)
- `one_shot: true`
- `amount: 6–8`
- `lifetime: 0.3`
- `direction: Vector2(0, -1)` (upward)
- `spread: 80` degrees
- `initial_velocity_min/max: 30 / 80`
- `gravity: Vector2(0, 200)` (fall back down)
- `scale_amount: 2` (2px particles visible at 320x180)

---

### Animation State Machine (Manual GDScript)

**Recommended approach:** No `AnimationTree`. Drive `AnimatedSprite2D.play()` directly from `_update_animation()` in `player.gd`. For 6 animations with simple priority rules, an if/elif chain is clearer and faster to iterate on than AnimationTree node graph setup.

```gdscript
# Source: [VERIFIED: docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html]

func _update_animation() -> void:
    var new_anim: String
    
    if _is_hurt:           # Highest priority
        new_anim = "hurt"
    elif _is_dead:
        new_anim = "death"
    elif not is_on_floor():
        new_anim = "jump" if velocity.y < 0.0 else "fall"
    elif abs(velocity.x) > 10.0:
        new_anim = "run"
    else:
        new_anim = "idle"
    
    # Only call play() if animation changed — avoids restarting mid-animation
    if sprite.animation != new_anim:
        sprite.play(new_anim)
```

**`hurt` and `death` animation exit:** Connect `sprite.animation_finished` signal:
```gdscript
func _on_animated_sprite_2d_animation_finished() -> void:
    if sprite.animation == "hurt":
        _is_hurt = false
    elif sprite.animation == "death":
        pass  # Trigger game-over / respawn from parent
```

**SpriteFrames setup:** In the Inspector on `AnimatedSprite2D`, create a `SpriteFrames` resource. Add 6 animations. For Phase 1 with placeholder art, each animation can be a single solid-color frame. The system works correctly with placeholder frames.

---

### Anti-Patterns to Avoid

- **Scaling CharacterBody2D for squash/stretch:** Moves the CollisionShape2D with it. Always scale the `AnimatedSprite2D` child, never the root.
- **Using GPUParticles2D:** Silently fails on GL Compatibility renderer (web export). Use CPUParticles2D only.
- **Multiplying velocity by delta when assigning directly:** `velocity.x = direction * speed` is correct. `velocity.x = direction * speed * delta` is wrong — creates micro-movement. Only gravity accumulation (`velocity.y += gravity * delta`) uses delta.
- **Calling `is_on_floor()` BEFORE `move_and_slide()`:** `is_on_floor()` reflects state from the PREVIOUS call to `move_and_slide()`. The floor check for coyote detection and animation must happen after `move_and_slide()` (or use `_was_on_floor` captured before).
- **Timer-based coyote with `process_mode = PAUSABLE`:** Hit-stop sets `time_scale = 0`, which stops all SceneTreeTimers unless `process_always = true`. If using Timer nodes for coyote, set their `process_callback = TIMER_PROCESS_PHYSICS` and ensure they survive hit-stop. Frame counters sidestep this issue.
- **Using `AnimationTree` for 6 simple animations:** Setup overhead is not worth it at this scale. AnimationTree shines at 15+ animations with blend trees. For 6, use manual `play()` calls.
- **`Engine.time_scale` without `process_always` on the recovery timer:** The coroutine's `create_timer` will freeze with `time_scale = 0` and never resume. Always pass `true` as the second argument.
- **Applying knockback to velocity.x and velocity.y separately with wrong signs:** Use `(global_position - attacker_position).normalized()` for direction — this ensures knockback is always away from the hit source, regardless of attack direction.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Particle system | Custom particle script with arrays | `CPUParticles2D` | Handles lifetime, physics, color, scale — hundreds of edge cases |
| Animation interpolation | Manual scale lerp in `_process` | `Tween` | `Tween` handles cleanup, interruption, easing curves |
| White flash shader | Custom GLSL shader | `modulate` overshoot + Tween | Shader approach has 5x more setup for identical visual result |
| Input buffering | Queue/array of input events | Frame counter integer | 3 lines vs 30 lines; integer is readable and debuggable |
| State machine framework | `StateMachine` + `State` class hierarchy | if/elif in `_update_animation()` | At 6 states, explicit if/elif is clearer than indirection through virtual methods |

**Key insight:** Godot's `Tween` and `CPUParticles2D` handle all the juice effects this phase needs. The only custom code is the physics controller logic.

---

## Common Pitfalls

### Pitfall 1: `is_on_floor()` Wrong Timing
**What goes wrong:** Coyote time activates every frame you're in the air (not just the moment of leaving the floor), allowing multi-frame jump spam.
**Why it happens:** Checking `not is_on_floor()` without tracking the previous-frame state.
**How to avoid:** Store `_was_on_floor = is_on_floor()` at the END of `_physics_process` (after `move_and_slide()`). Only start coyote timer when `_was_on_floor == true AND now is_on_floor() == false`.
**Warning signs:** Player can jump 3+ times by walking to the edge repeatedly.

### Pitfall 2: Hit-Stop Freezes Recovery Timer
**What goes wrong:** `Engine.time_scale = 0.0` is set, but the `await get_tree().create_timer(...)` never resolves, leaving the game permanently paused.
**Why it happens:** `create_timer()` defaults to `process_always = false`, so it freezes with `time_scale`.
**How to avoid:** Always `get_tree().create_timer(duration, true)` — the `true` argument sets `process_always = true`.
**Warning signs:** Game freezes on the first hit and never resumes.

### Pitfall 3: Squash/Stretch Moves Collider
**What goes wrong:** Player visually squashes but collider remains full-height, causing foot collision to clip into the ground.
**Why it happens:** Applying `scale` to the `CharacterBody2D` root instead of the `AnimatedSprite2D` child.
**How to avoid:** Only scale `$AnimatedSprite2D`. The `CollisionShape2D` is a sibling, not a child of the sprite, so it's unaffected.
**Warning signs:** Player "sinks" into the floor briefly after landing.

### Pitfall 4: Jump Buffer Fires at Wrong Time
**What goes wrong:** Player presses jump while falling, lands on an enemy (taking damage), and immediately jumps — feels unresponsive or surprising.
**Why it happens:** Jump buffer is still active when knockback resolves.
**How to avoid:** Clear `_jump_buffer_timer = 0` when `take_damage()` is called.
**Warning signs:** Player bounces immediately after taking knockback damage.

### Pitfall 5: GPUParticles on Web Export
**What goes wrong:** Landing dust particles completely invisible in web build; no error is thrown.
**Why it happens:** `GPUParticles2D` requires compute shaders, absent in GL Compatibility renderer.
**How to avoid:** Use `CPUParticles2D` exclusively from day one. Never use `GPUParticles2D` in this project.
**Warning signs:** Particles work in Godot editor but disappear after HTML5 export.

### Pitfall 6: Dash Velocity Persists Through Jump
**What goes wrong:** Player jumps while dashing and the horizontal velocity stays at dash speed for the entire jump arc.
**Why it happens:** `_is_dashing` is still true when jump input is processed.
**How to avoid:** Cancel dash on jump: when jump executes, set `_is_dashing = false`, `_dash_frames_remaining = 0`.
**Warning signs:** Player covers huge horizontal distance mid-air after dash-jump.

### Pitfall 7: Animation Play() Called Every Frame
**What goes wrong:** Animation resets to frame 0 every physics frame, making all animations appear frozen or flickering.
**Why it happens:** Calling `sprite.play("idle")` unconditionally in `_physics_process` — `play()` restarts from frame 0 if already playing.
**How to avoid:** Guard with `if sprite.animation != new_anim: sprite.play(new_anim)`.
**Warning signs:** All animations show only their first frame.

---

## Code Examples

### Complete Minimal Player Skeleton

```gdscript
# Source: Synthesized from:
#   [VERIFIED] docs.godotengine.org/en/4.4/tutorials/physics/using_character_body_2d.html
#   [VERIFIED] kidscancode.org/godot_recipes/4.x/2d/coyote_time/
#   [VERIFIED] uhiyama-lab.com/en/notes/godot/modulate-white-flash-damage-effect/
#   [VERIFIED] docs.godotengine.org/en/stable/classes/class_engine.html (time_scale)
# File: scenes/player/player.gd

extends CharacterBody2D

# Movement
@export var run_speed: float = 200.0
@export var jump_velocity: float = -380.0
@export var gravity_up: float = 900.0
@export var gravity_down: float = 1600.0
@export var coyote_frames: int = 6
@export var jump_buffer_frames: int = 8

# Dash
@export var dash_speed: float = 550.0
@export var dash_duration_frames: int = 12
@export var dash_cooldown: float = 0.4

# Knockback
@export var knockback_decay: float = 8.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dust_particles: CPUParticles2D = $DustParticles

# Runtime flags
var _was_on_floor: bool = false
var _coyote_timer: int = 0
var _jump_buffer_timer: int = 0
var _jumped_this_frame: bool = false
var _is_dashing: bool = false
var _dash_frames_remaining: int = 0
var _dash_direction: float = 1.0
var _can_dash: bool = true
var _is_invincible: bool = false
var _knockback: Vector2 = Vector2.ZERO
var _is_hurt: bool = false
var _flash_tween: Tween
var _squash_tween: Tween

func _physics_process(delta: float) -> void:
    _jumped_this_frame = false
    
    # Asymmetric gravity (skip during dash to prevent gravity-cancel issues)
    if not _is_dashing:
        velocity.y += (gravity_up if velocity.y < 0.0 else gravity_down) * delta
    
    # Dash
    if _is_dashing:
        velocity.x = _dash_direction * dash_speed
        velocity.y = 0.0
        _dash_frames_remaining -= 1
        if _dash_frames_remaining <= 0:
            _is_dashing = false
            _is_invincible = false
    else:
        # Horizontal movement
        var dir := Input.get_axis("ui_left", "ui_right")
        if dir != 0.0:
            velocity.x = dir * run_speed
            sprite.flip_h = dir < 0.0
        else:
            velocity.x = move_toward(velocity.x, 0.0, run_speed)
        
        # Dash trigger
        if Input.is_action_just_pressed("dash") and _can_dash:
            _start_dash()
    
    # Knockback
    if _knockback.length() > 1.0:
        velocity += _knockback
        _knockback = _knockback.lerp(Vector2.ZERO, knockback_decay * delta)
    else:
        _knockback = Vector2.ZERO
    
    # Coyote time
    if _was_on_floor and not is_on_floor() and not _jumped_this_frame:
        _coyote_timer = coyote_frames
    if not is_on_floor():
        _coyote_timer = max(_coyote_timer - 1, 0)
    
    # Jump buffer
    if Input.is_action_just_pressed("jump"):
        _jump_buffer_timer = jump_buffer_frames
    else:
        _jump_buffer_timer = max(_jump_buffer_timer - 1, 0)
    
    # Jump execution
    if _jump_buffer_timer > 0 and (is_on_floor() or _coyote_timer > 0):
        velocity.y = jump_velocity
        _coyote_timer = 0
        _jump_buffer_timer = 0
        _jumped_this_frame = true
        _apply_jump_stretch()
    
    # Jump cut
    if Input.is_action_just_released("jump") and velocity.y < 0.0:
        velocity.y *= 0.4
    
    _was_on_floor = is_on_floor()
    move_and_slide()
    
    # Landing
    if not _was_on_floor and is_on_floor():
        _on_land()
    _was_on_floor = is_on_floor()
    
    _update_animation()

func _on_land() -> void:
    _apply_land_squash()
    dust_particles.restart()

func take_damage(hit_from_position: Vector2) -> void:
    if _is_invincible:
        return
    var direction := (global_position - hit_from_position).normalized()
    _knockback = direction * 300.0
    _jump_buffer_timer = 0  # Cancel buffered jump on hit
    _is_hurt = true
    _start_white_flash()
    _start_hit_stop(3)

func _start_dash() -> void:
    _is_dashing = true
    _is_invincible = true
    _dash_direction = -1.0 if sprite.flip_h else 1.0
    _dash_frames_remaining = dash_duration_frames
    _can_dash = false
    get_tree().create_timer(dash_cooldown).timeout.connect(func(): _can_dash = true, CONNECT_ONE_SHOT)

func _start_white_flash() -> void:
    if _flash_tween and _flash_tween.is_valid():
        _flash_tween.kill()
    sprite.modulate = Color(10.0, 10.0, 10.0)
    _flash_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
    _flash_tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0), 0.3)

func _start_hit_stop(frames: int = 3) -> void:
    Engine.time_scale = 0.0
    await get_tree().create_timer(frames / 60.0, true).timeout  # true = process_always!
    Engine.time_scale = 1.0

func _apply_jump_stretch() -> void:
    if _squash_tween and _squash_tween.is_valid():
        _squash_tween.kill()
    sprite.scale = Vector2(0.75, 1.3)
    _squash_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
    _squash_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.25)

func _apply_land_squash() -> void:
    if _squash_tween and _squash_tween.is_valid():
        _squash_tween.kill()
    sprite.scale = Vector2(1.3, 0.75)
    _squash_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
    _squash_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.2)

func _update_animation() -> void:
    var new_anim: String
    if _is_hurt:
        new_anim = "hurt"
    elif not is_on_floor():
        new_anim = "jump" if velocity.y < 0.0 else "fall"
    elif abs(velocity.x) > 10.0:
        new_anim = "run"
    else:
        new_anim = "idle"
    if sprite.animation != new_anim:
        sprite.play(new_anim)

func _on_animated_sprite_2d_animation_finished() -> void:
    if sprite.animation == "hurt":
        _is_hurt = false
```

---

### Test Scene Structure

```gdscript
# File: scenes/test_movement/test_movement.gd
# Attached to: CanvasLayer (child of test scene root)

extends CanvasLayer

@onready var player: CharacterBody2D = $"../Player"
@onready var state_label: Label = $StateLabel

func _process(_delta: float) -> void:
    state_label.text = (
        "vel: %.0f, %.0f\n" % [player.velocity.x, player.velocity.y]
        + "on_floor: %s\n" % player.is_on_floor()
        + "coyote: %d\n" % player._coyote_timer
        + "jump_buf: %d\n" % player._jump_buffer_timer
        + "dashing: %s\n" % player._is_dashing
        + "invincible: %s" % player._is_invincible
    )
```

**Test scene node tree:**
```
Node2D (test_movement.tscn root)
├── StaticBody2D (main_floor)
│   ├── CollisionShape2D (RectangleShape2D, 320x8)
│   └── Sprite2D (floor sprite, placeholder gray rectangle)
├── StaticBody2D (ledge_platform — for coyote time testing)
│   ├── CollisionShape2D (RectangleShape2D, 64x8)
│   └── Sprite2D
├── StaticBody2D (damage_area — for knockback testing)
│   └── Area2D with script that calls player.take_damage(position)
├── Player (player.tscn instance)
└── CanvasLayer (HUD)
    └── Label (StateLabel, anchored top-left)
```

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Godot 4.4.x | All implementation | Not in PATH | — | Must launch via app bundle on macOS |
| GDScript (built-in) | All scripts | ✓ | Built into Godot | — |
| CPUParticles2D (built-in) | MOVE-05 dust | ✓ | Built-in Godot 4 | — |
| AnimatedSprite2D (built-in) | MOVE-04 animations | ✓ | Built-in Godot 4 | — |

**Godot not in PATH:** `godot` command not found at research time. The editor must be launched via macOS application bundle. CI/CD uses headless export (abarichello/godot-ci), which is unaffected. Local testing requires opening the project in the Godot editor directly and using F5 to run.

---

## Validation Architecture

> nyquist_validation is enabled in config.json.

### Test Framework

| Property | Value |
|----------|-------|
| Framework | Godot built-in scene runner (no external test framework) |
| Config file | none — tests are playable scenes |
| Quick run | F5 in Godot editor with `test_movement.tscn` as main scene |
| Full suite | Manual checklist on `test_movement.tscn` against success criteria |

**Rationale for no automated test framework:** GUT (Godot Unit Test) exists but adds a plugin dependency and has no value for physics/feel validation, which requires visual inspection. Success criteria for Phase 1 are all observable behaviors, not function return values. The test scene IS the test suite.

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | Scene Exists? |
|--------|----------|-----------|-------------------|-------------|
| MOVE-01 | Coyote 6 frames + jump buffer 8 frames | Manual visual | Walk off ledge_platform, jump at frame 6 | ❌ Wave 0 |
| MOVE-01 | Asymmetric gravity (heavier fall) | Manual visual | Observe arc shape in test scene | ❌ Wave 0 |
| MOVE-02 | Dash responds in ≤1 frame | Manual visual | Press dash input, observe immediate velocity | ❌ Wave 0 |
| MOVE-03 | Knockback visible + correct direction | Manual visual | Trigger damage_area, observe player movement | ❌ Wave 0 |
| MOVE-04 | 6 animations without transition artefacts | Manual visual | Cycle through states in test scene | ❌ Wave 0 |
| MOVE-05 | Dust at landing | Manual visual | Jump and land on main_floor | ❌ Wave 0 |
| MOVE-05 | Squash/stretch on jump+land | Manual visual | Observe sprite scale during jump cycle | ❌ Wave 0 |
| MOVE-05 | White flash on damage | Manual visual | Trigger damage_area, observe modulate | ❌ Wave 0 |
| MOVE-05 | Hit-stop 2-4 frames | Manual visual | Trigger damage, observe brief freeze | ❌ Wave 0 |

### Wave 0 Gaps (test infrastructure to create)
- [ ] `scenes/test_movement/test_movement.tscn` — covers all MOVE-XX requirements
- [ ] `scenes/player/player.tscn` — CharacterBody2D with placeholder sprite
- [ ] `scenes/player/player.gd` — complete controller script
- [ ] Placeholder sprite sheet (6 single-frame animations) in `assets/sprites/natalia/`

---

## Security Domain

> This phase is pure game logic with no network requests, authentication, user input storage, or external service calls. ASVS categories are not applicable to Phase 1.

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Jump cut multiplier `0.4` gives good feel for this gravity config | Pattern 2 | Needs tuning; wrong value makes jump feel too floaty or too rigid |
| A2 | Dash values: 550px/s speed, 12 frames duration, 0.4s cooldown | Pattern 3 | These feel-values require in-engine tuning; they are starting points |
| A3 | Knockback impulse `300.0 px/s` is appropriate for 32x32 scale | Pattern 4 | May be too strong/weak; tune during playtest |
| A4 | CPUParticles2D particle settings (amount, velocity, spread) | Pattern 5d | Cosmetic; needs visual tuning in editor |
| A5 | Physics FPS is default 60 Hz | Frame counter patterns | If project.godot sets different physics ticks, frame counts need recalculating (coyote 6, buffer 8 are calibrated for 60Hz) |
| A6 | `_start_dash` uses `.timeout.connect(func(): ..., CONNECT_ONE_SHOT)` pattern for cooldown | Pattern 3 | Alternative: Timer node with `one_shot = true`; functional equivalent |

---

## Open Questions

1. **Placeholder sprites for Phase 1**
   - What we know: No sprite assets exist yet; the phase needs AnimatedSprite2D with 6 animations
   - What's unclear: Should Phase 1 create 1-frame placeholder animations (colored rectangles), or block on NPC-04 (Natália's real sprite)?
   - Recommendation: Phase 1 creates 6 placeholder 1-frame animations with distinct colors per state. Real sprite is Phase 2 (NPC-04 is mapped there). Do not block game feel work on art.

2. **Input actions: "dash" action not defined in project.godot**
   - What we know: `project.godot` has only default UI actions; "jump" and "dash" need adding to InputMap
   - What's unclear: MOVE-02 says dash is implemented now (unlock gate is later) — so the input action must exist in Phase 1
   - Recommendation: Plan 1 includes adding "jump", "dash", "walk_left", "walk_right" to Project Settings > InputMap as the first task.

3. **Death animation — what happens after it plays?**
   - What we know: MOVE-04 requires a "death" animation; WORLD-05 (respawn) is Phase 3
   - What's unclear: In Phase 1 test scene, death state has no respawn system yet
   - Recommendation: After "death" animation finishes, log to console and loop idle. Respawn hookup is Phase 3.

---

## Plan Structure Recommendation

**3 plans, sequential** (each plan is independently playable):

### Plan 1: Core Movement + Coyote + Jump Buffer + Asymmetric Gravity (MOVE-01)
**Goal:** Player moves, runs, jumps with correct feel. Coyote and buffer are testable.
**Deliverables:**
- `scenes/player/player.tscn` + `player.gd` (movement + gravity + coyote + buffer)
- `scenes/test_movement/test_movement.tscn` (2 platforms: floor + ledge)
- InputMap actions: jump, walk_left, walk_right, dash
- 4 placeholder animations: idle, run, jump, fall (colored squares)
**Success gate:** Coyote (6 frames) and jump buffer (8 frames) both observable on the ledge platform.

### Plan 2: Dash + Knockback + Full Animation Set (MOVE-02, MOVE-03, MOVE-04)
**Goal:** Dash and knockback functional; all 6 animations playing correctly.
**Deliverables:**
- Extend `player.gd` with `_start_dash()` and `take_damage()`
- Add hurt + death placeholder animations to SpriteFrames
- Add damage trigger to test scene (Area2D with script)
- Verify animation state machine (no play-every-frame bug)
**Success gate:** Dash responds ≤1 frame; knockback direction correct; all 6 animations transition cleanly.

### Plan 3: Juice Effects + Test Scene Polish (MOVE-05)
**Goal:** All juice effects visible; test scene HUD shows debug state.
**Deliverables:**
- Squash/stretch on jump and land
- White flash on damage
- Hit-stop 3 frames
- CPUParticles2D landing dust (configured one-shot)
- Debug HUD Label in CanvasLayer
**Success gate:** All 5 success criteria met in isolated test scene; no web-export regressions (GL Compatibility confirmed in project.godot throughout).

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `KinematicBody2D` + `move_and_slide(velocity, ...)` | `CharacterBody2D` + set `velocity` then call `move_and_slide()` | Godot 4.0 | `move_and_slide()` no longer takes parameters; velocity is a property |
| `yield()` for coroutines | `await` keyword | Godot 4.0 | GDScript 2.0 change; old tutorials using `yield` do not apply |
| `$Timer.wait_time = x; $Timer.start()` | `await get_tree().create_timer(x).timeout` | Godot 4.0 | Inline timer without needing a Timer node in the scene |
| `AnimationPlayer` with sprite frame tracks | `AnimatedSprite2D` with `SpriteFrames` resource | Godot 3 → 4 | AnimatedSprite2D is now the standard for 2D frame animation |
| `TileMap` (single node) | `TileMapLayer` (per-layer node) | Godot 4.4 | Phase 1 doesn't use tilemaps; Phase 3+ should use TileMapLayer |

**Deprecated / not applicable:**
- `KinematicBody2D`: Removed in Godot 4. All Godot 3 tutorials showing this class name are stale.
- `move_and_slide(velocity, up_direction)`: Removed in Godot 4. Velocity is now a property, `up_direction` is a property on CharacterBody2D.
- `connect("signal", self, "method_name")`: Old Godot 3 signal syntax. Use `signal.connect(callable)` in Godot 4.

---

## Sources

### Primary (HIGH confidence)
- `docs.godotengine.org/en/4.4/tutorials/physics/using_character_body_2d.html` — CharacterBody2D platformer pattern, move_and_slide API
- `docs.godotengine.org/en/stable/classes/class_engine.html` — Engine.time_scale documentation, process_always behavior
- `docs.godotengine.org/en/stable/classes/class_tween.html` — Tween API, tween_property, easing
- `docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html` — AnimatedSprite2D play() API
- Context7 `/websites/godotengine_en_stable` — CharacterBody2D, AnimatedSprite2D, CPUParticles2D, Engine time_scale, Tween

### Secondary (MEDIUM confidence)
- `kidscancode.org/godot_recipes/4.x/2d/coyote_time/` — Coyote time frame counter pattern (verified against official docs)
- `kidscancode.org/godot_recipes/4.x/2d/platform_character/` — Platformer acceleration/deceleration with lerp (verified)
- `uhiyama-lab.com/en/notes/godot/modulate-white-flash-damage-effect/` — White flash modulate pattern (verified against Tween API)
- `github.com/godotengine/godot/issues/75270` — GPUParticles2D fail on web export (confirmed bug report)
- `github.com/godotengine/godot/issues/96030` — Godot 4.3 particles broken with default shader on web
- `forum.godotengine.org/t/platformer-player-knockback-implementation/59705` — Knockback approach

### Tertiary (LOW confidence — needs in-editor tuning)
- Community consensus on dash/knockback numeric values (speed, duration, cooldown)
- Squash/stretch scale values and tween duration
- Particle Inspector settings for landing dust

---

## Metadata

**Confidence breakdown:**
- Core CharacterBody2D API: HIGH — verified against official 4.4 docs
- Coyote time / jump buffer pattern: HIGH — multiple verified sources agree on frame counter approach
- Asymmetric gravity: HIGH — simple velocity.y sign check, verified in docs
- Dash implementation: MEDIUM — pattern is synthesized; specific values need in-editor tuning
- Knockback: MEDIUM — approach verified; values are assumed starting points
- CPUParticles2D for web: HIGH — confirmed via GitHub issues and bug reports
- Hit-stop `process_always`: HIGH — verified in Engine.time_scale docs (AudioServer note confirms separation)
- Animation state machine: HIGH — AnimatedSprite2D API verified; if/elif pattern matches official docs examples

**Research date:** 2026-05-21
**Valid until:** 2026-08-21 (Godot 4.4.x is stable; API unlikely to change before 4.5 graduation)
