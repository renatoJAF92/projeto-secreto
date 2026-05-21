---
phase: 01-game-feel
plan: 02
type: execute
wave: 2
status: pending
depends_on: [01]
files_modified:
  - scenes/player/player.gd
  - scenes/player/player.tscn
  - scenes/test_movement/test_movement.tscn
  - scenes/test_movement/test_movement.gd
  - scenes/test_movement/damage_trigger.gd
  - assets/sprites/player/natalia_placeholder.svg
autonomous: false
requirements: [MOVE-02, MOVE-03, MOVE-04]
must_haves:
  truths:
    - "Pressing dash makes Natália dash horizontally in the facing direction within 1 frame"
    - "Dash has a cooldown and grants brief invincibility while active"
    - "Walking into the damage trigger applies visible knockback away from the hit source"
    - "Taking damage plays the hurt animation, then returns to normal state"
    - "All 6 animations (idle, run, jump, fall, hurt, death) play in their correct states"
    - "Animations do not flicker or freeze on frame 0 (no play-every-frame bug)"
  artifacts:
    - path: "scenes/player/player.gd"
      provides: "Dash, knockback, take_damage, and 6-state animation machine"
      contains: "_start_dash"
    - path: "scenes/player/player.tscn"
      provides: "AnimatedSprite2D with a 6-animation SpriteFrames resource"
      contains: "SpriteFrames"
    - path: "scenes/test_movement/damage_trigger.gd"
      provides: "Area2D script that calls player.take_damage on body entry"
      contains: "take_damage"
  key_links:
    - from: "scenes/test_movement/damage_trigger.gd"
      to: "scenes/player/player.gd"
      via: "calls take_damage(global_position) on body_entered"
      pattern: "take_damage"
    - from: "scenes/player/player.gd"
      to: "scenes/player/player.tscn AnimatedSprite2D"
      via: "sprite.play(anim_name) driven by _update_animation"
      pattern: "sprite.play"
---

<objective>
Extend `player.gd` with horizontal dash (MOVE-02), knockback on damage (MOVE-03), and a complete 6-state animation machine (MOVE-04). Add a `SpriteFrames` resource with 6 placeholder animations to `player.tscn`, and add a damage trigger to the test scene so knockback and the hurt animation are observable.

Purpose: Dash and knockback are the two reactive mechanics on top of core movement. The animation state machine makes every player state visually distinct — essential before juice effects in Plan 03 hook onto animation events.
Output: Extended `player.gd`, `player.tscn` with SpriteFrames, a `damage_trigger.gd`, and a placeholder sprite asset.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/ROADMAP.md
@.planning/phases/01-game-feel/01-RESEARCH.md
@.planning/phases/01-game-feel/01-001-SUMMARY.md
@scenes/player/player.gd
@scenes/player/player.tscn
@scenes/test_movement/test_movement.tscn

# Phase Goal (user story)
## Phase Goal

**As a** jogadora, **I want to** dar dash, sofrer knockback ao tomar dano e ver a Natália animada em 6 estados, **so that** as reações e o feedback de combate sejam claros e satisfatórios.

# Depends on Plan 01
Plan 01 created `player.gd` (run/gravity/coyote/buffer/jump-cut), `player.tscn`
(CharacterBody2D + AnimatedSprite2D + CollisionShape2D), `test_movement.tscn`, and the
InputMap actions including `dash`. Plan 01 left `_on_land()` and `_update_animation()`
as extensible stubs and the AnimatedSprite2D with no SpriteFrames resource.

# Interfaces from Plan 01 (player.gd — extend this same file, do not rewrite)
- Existing exported vars: run_speed, jump_velocity, gravity_up, gravity_down, coyote_frames, jump_buffer_frames, jump_cut_multiplier
- Existing runtime vars: _was_on_floor, _coyote_timer, _jump_buffer_timer, _jumped_this_frame
- @onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
- _physics_process(delta) order: gravity -> horizontal -> coyote -> buffer -> jump -> jump-cut -> move_and_slide -> land -> animation
- Stub methods present: _on_land(), _update_animation()

# InputMap action available
- `dash` action exists in project.godot (added by Plan 01) — bound to SHIFT and K
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create placeholder sprite and 6-animation SpriteFrames in player.tscn</name>
  <files>assets/sprites/player/natalia_placeholder.svg, scenes/player/player.tscn</files>
  <action>
Phase 1 uses placeholder art — no real sprite is needed (RESEARCH.md Open Question 1; NPC-04 real sprite is Phase 2).

Create `assets/sprites/player/natalia_placeholder.svg` — a single 32x32 SVG of a solid-color rectangle (e.g. `fill="#d98ab0"`, a pink-ish placeholder) with a small darker square near the top to indicate "head/facing". SVG keeps the asset text-diffable and avoids needing Git LFS for a placeholder. Godot imports SVG as a texture.

Edit `scenes/player/player.tscn`: add an embedded `SpriteFrames` resource to the `AnimatedSprite2D` node's `sprite_frames` property. Define exactly 6 animations, each using the single placeholder texture as its one frame (placeholder art is intentional — RESEARCH.md line 467):
- `idle` — speed 5 fps, loop = true
- `run` — speed 10 fps, loop = true
- `jump` — speed 5 fps, loop = false
- `fall` — speed 5 fps, loop = false
- `hurt` — speed 8 fps, loop = false
- `death` — speed 6 fps, loop = false

Each animation has 1 frame referencing the placeholder texture (`res://assets/sprites/player/natalia_placeholder.svg`). The `hurt` and `death` animations MUST have `loop = false` so the `animation_finished` signal fires (required by the state machine in Task 4).

Set the AnimatedSprite2D's default `animation = "idle"` and `autoplay = "idle"`.

Connect the AnimatedSprite2D's `animation_finished` signal to a method `_on_animated_sprite_2d_animation_finished` on the Player root (the connection lives in the .tscn; the method is added in Task 4).
  </action>
  <verify>
    <automated>test -f assets/sprites/player/natalia_placeholder.svg && grep -q 'SpriteFrames' scenes/player/player.tscn && grep -cE '"name": ?&"(idle|run|jump|fall|hurt|death)"' scenes/player/player.tscn | grep -qv '^0$' && echo "OK" || echo "FAIL"</automated>
  </verify>
  <done>`natalia_placeholder.svg` exists; `player.tscn` AnimatedSprite2D has a SpriteFrames resource with 6 animations (idle, run, jump, fall, hurt, death); hurt and death have loop=false; `animation_finished` is connected to the Player.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Add horizontal dash to player.gd</name>
  <files>scenes/player/player.gd</files>
  <behavior>
    - Pressing dash while _can_dash is true and not already dashing starts a dash within the same frame (response in <=1 physics frame).
    - While dashing: velocity.x is forced to _dash_direction * dash_speed, velocity.y is 0 (gravity skipped), normal horizontal input is ignored.
    - Dash lasts dash_duration_frames (12) then ends; _is_invincible returns to false.
    - After a dash ends, _can_dash stays false until dash_cooldown (0.4s) elapses.
    - Jumping during a dash cancels the dash (no dash-velocity carried into the jump arc).
  </behavior>
  <action>
Extend `scenes/player/player.gd` (do NOT rewrite — add to the existing file). Implement dash per RESEARCH.md Pattern 3 and the Code Examples skeleton (lines 592-681).

Add to `@export_group("Dash")`:
- `dash_speed: float = 550.0`
- `dash_duration_frames: int = 12`
- `dash_cooldown: float = 0.4`

Add runtime vars: `_is_dashing: bool`, `_dash_frames_remaining: int`, `_dash_direction: float = 1.0`, `_can_dash: bool = true`, `_is_invincible: bool`.

Modify `_physics_process` so the gravity + horizontal-movement block becomes dash-aware (RESEARCH.md lines 595-618):
- Gravity: only apply `velocity.y += gravity * delta` when `not _is_dashing` (dash cancels gravity).
- After gravity, branch:
  - `if _is_dashing:` set `velocity.x = _dash_direction * dash_speed`, `velocity.y = 0.0`, decrement `_dash_frames_remaining`; when it hits 0 set `_is_dashing = false` and `_is_invincible = false`.
  - `else:` run the existing horizontal-movement block from Plan 01, AND add the dash trigger: `if Input.is_action_just_pressed("dash") and _can_dash: _start_dash()`.

Add `_start_dash()` (RESEARCH.md lines 675-681):
- `_is_dashing = true`, `_is_invincible = true`, `_can_dash = false`
- `_dash_direction = -1.0 if sprite.flip_h else 1.0`
- `_dash_frames_remaining = dash_duration_frames`
- Start cooldown: `get_tree().create_timer(dash_cooldown).timeout.connect(func(): _can_dash = true, CONNECT_ONE_SHOT)`

Dash-cancel on jump (RESEARCH.md Pitfall 6, line 530): in the jump-execution block from Plan 01, when a jump fires also set `_is_dashing = false` and `_dash_frames_remaining = 0` so dash velocity does not persist into the jump arc.
  </action>
  <verify>
    <automated>grep -q '_start_dash' scenes/player/player.gd && grep -q 'is_action_just_pressed("dash")' scenes/player/player.gd && grep -q '_is_dashing' scenes/player/player.gd && grep -q 'CONNECT_ONE_SHOT' scenes/player/player.gd && echo "OK" || echo "FAIL"</automated>
  </verify>
  <done>`player.gd` has `_start_dash()`, dash velocity override, dash-aware gravity, cooldown via one-shot timer, and dash cancels on jump.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 3: Add knockback and take_damage to player.gd</name>
  <files>scenes/player/player.gd</files>
  <behavior>
    - take_damage(hit_from_position) computes direction = (global_position - hit_from_position).normalized() and sets _knockback to direction * knockback_impulse.
    - take_damage returns immediately (no effect) when _is_invincible is true.
    - take_damage clears _jump_buffer_timer to 0 (no buffered jump fires after a hit).
    - take_damage sets _is_hurt = true.
    - Each frame, while _knockback length > 1, _knockback is added to velocity and decayed toward zero via lerp; below the threshold it snaps to ZERO.
    - Knockback does NOT reset the coyote timer.
  </behavior>
  <action>
Extend `scenes/player/player.gd` with knockback per RESEARCH.md Pattern 4 (lines 313-336) and the skeleton (lines 665-673).

Add to `@export_group("Knockback")`:
- `knockback_decay: float = 8.0`
- `knockback_impulse: float = 300.0`

Add runtime vars: `_knockback: Vector2 = Vector2.ZERO`, `_is_hurt: bool`.

Add the knockback application block to `_physics_process`, placed AFTER the dash/horizontal-movement block and BEFORE `move_and_slide()` (RESEARCH.md lines 620-625):
- `if _knockback.length() > 1.0:` then `velocity += _knockback` and `_knockback = _knockback.lerp(Vector2.ZERO, knockback_decay * delta)`
- `else:` `_knockback = Vector2.ZERO`

Add the public `take_damage(hit_from_position: Vector2) -> void` method (RESEARCH.md lines 665-673):
- `if _is_invincible: return`
- `var direction := (global_position - hit_from_position).normalized()`
- `_knockback = direction * knockback_impulse`
- `_jump_buffer_timer = 0` (RESEARCH.md Pitfall 4 — cancel buffered jump on hit)
- `_is_hurt = true`
- For this plan, `take_damage` ends here. Plan 03 adds white-flash + hit-stop calls inside this method.

Do NOT touch `_coyote_timer` in `take_damage` — knockback off a ledge is intentional (RESEARCH.md line 336).
  </action>
  <verify>
    <automated>grep -q 'func take_damage' scenes/player/player.gd && grep -q '_knockback' scenes/player/player.gd && grep -q 'knockback_decay' scenes/player/player.gd && grep -q '_jump_buffer_timer = 0' scenes/player/player.gd && echo "OK" || echo "FAIL"</automated>
  </verify>
  <done>`player.gd` has `take_damage()` that applies a direction-based knockback impulse, respects invincibility, clears the jump buffer, and sets `_is_hurt`; knockback decays via lerp each frame; coyote timer untouched.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 4: Complete the 6-state animation machine in player.gd</name>
  <files>scenes/player/player.gd</files>
  <behavior>
    - _update_animation picks exactly one of: hurt, death, jump, fall, run, idle by priority.
    - Priority order: hurt (if _is_hurt) > death (if _is_dead) > jump/fall (if airborne, by velocity.y sign) > run (if abs(velocity.x) > 10) > idle.
    - sprite.play() is called ONLY when the target animation differs from the current one (no flicker).
    - When the hurt animation finishes, _is_hurt is reset to false.
  </behavior>
  <action>
Replace the placeholder `_update_animation()` stub in `scenes/player/player.gd` with the full 6-state machine per RESEARCH.md Animation State Machine section (lines 432-465).

Add runtime var `_is_dead: bool` (death is triggered for completeness; respawn is Phase 3 per RESEARCH.md Open Question 3).

`_update_animation()`:
- Compute `new_anim` by priority: `if _is_hurt: "hurt"` / `elif _is_dead: "death"` / `elif not is_on_floor(): "jump" if velocity.y < 0.0 else "fall"` / `elif abs(velocity.x) > 10.0: "run"` / `else: "idle"`.
- Guard: `if sprite.sprite_frames and sprite.animation != new_anim: sprite.play(new_anim)` (RESEARCH.md Pitfall 7 — never call play() unconditionally).

Add the signal handler `_on_animated_sprite_2d_animation_finished() -> void` (connected to the AnimatedSprite2D in Task 1):
- `if sprite.animation == "hurt": _is_hurt = false`
- `elif sprite.animation == "death": print("Player death animation finished — respawn hooked in Phase 3")` (RESEARCH.md Open Question 3 — log and continue; no respawn system yet).

Add a temporary debug `die()` method for the test scene: `func die() -> void: _is_dead = true` so the death animation is reachable from the test scene (Phase 3 wires real death).
  </action>
  <verify>
    <automated>grep -q 'func _update_animation' scenes/player/player.gd && grep -q '_on_animated_sprite_2d_animation_finished' scenes/player/player.gd && grep -q 'sprite.animation != new_anim' scenes/player/player.gd && grep -cE '"(idle|run|jump|fall|hurt|death)"' scenes/player/player.gd | grep -qv '^0$' && echo "OK" || echo "FAIL"</automated>
  </verify>
  <done>`_update_animation()` selects from all 6 animations by priority and only calls `play()` on change; `animation_finished` resets `_is_hurt` after hurt; a `die()` helper exposes the death animation for testing.</done>
</task>

<task type="auto">
  <name>Task 5: Add a damage trigger to the test scene</name>
  <files>scenes/test_movement/damage_trigger.gd, scenes/test_movement/test_movement.tscn, scenes/test_movement/test_movement.gd</files>
  <action>
Add a hazard to `test_movement.tscn` so knockback (MOVE-03) and the hurt animation (MOVE-04) are observable.

Create `scenes/test_movement/damage_trigger.gd` extending `Area2D`:
- In `_ready()`, connect `body_entered` to a handler.
- Handler `_on_body_entered(body: Node2D) -> void`: `if body.has_method("take_damage"): body.take_damage(global_position)` — passing the trigger's own `global_position` so the player computes a knockback direction away from it (RESEARCH.md Pattern 4).

Edit `scenes/test_movement/test_movement.tscn`: add an `Area2D` node (name "DamageTrigger") at `position = Vector2(150, 145)` (sitting on the main floor, in the player's running path):
- Attach `damage_trigger.gd`.
- Child `CollisionShape2D` — `RectangleShape2D` `size = Vector2(16, 24)`.
- Child `Polygon2D` (name "Visual") — a small red square, `color = Color(0.85, 0.2, 0.2)`, `polygon` a 16x24 rect, so the hazard is visible.
- Set the Area2D `monitoring = true`.

Extend `test_movement.gd` HUD: add `_is_dashing`, `_is_invincible`, and `_is_hurt` to the displayed debug lines (per RESEARCH.md lines 740-748) so dash/invincibility/hurt state is visible during the checkpoint.

Optionally add an on-screen hint Label (or extend StateLabel) listing controls: "A/D run, SPACE jump, SHIFT/K dash, walk into red box for damage".
  </action>
  <verify>
    <automated>test -f scenes/test_movement/damage_trigger.gd && grep -q 'extends Area2D' scenes/test_movement/damage_trigger.gd && grep -q 'take_damage' scenes/test_movement/damage_trigger.gd && grep -q 'DamageTrigger' scenes/test_movement/test_movement.tscn && grep -q '_is_dashing' scenes/test_movement/test_movement.gd && echo "OK" || echo "FAIL"</automated>
  </verify>
  <done>`damage_trigger.gd` calls `player.take_damage(global_position)` on body entry; `test_movement.tscn` has a visible red DamageTrigger Area2D; the HUD shows dash/invincible/hurt state.</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <name>Task 6: Verify dash, knockback, and all 6 animations</name>
  <what-built>Horizontal dash with cooldown and i-frames, direction-based knockback on damage, a complete 6-state animation machine (idle/run/jump/fall/hurt/death), placeholder sprite with a 6-animation SpriteFrames, and a damage trigger in the test scene.</what-built>
  <how-to-verify>
1. Open the project in the Godot editor and run `scenes/test_movement/test_movement.tscn` (F6).
2. Dash (MOVE-02): face right (press D), then press SHIFT or K. The character should shoot horizontally immediately — the dash must respond within ~1 frame of the input. Watch the HUD `dashing:` flip to true and `invincible:` to true during the dash. Press dash again immediately — it should be blocked until the 0.4s cooldown ends.
3. Dash-jump: start a dash, then press SPACE mid-dash. The dash should cancel — the character should NOT keep dash speed through the whole jump arc.
4. Knockback (MOVE-03): run into the red DamageTrigger box. Natália should be pushed *away* from the box (opposite the side she entered from). Approach from the left -> knocked left; from the right -> knocked right.
5. Hurt animation (MOVE-04): on the same hit, the `hurt:` HUD value flips true and the hurt animation plays, then automatically returns to idle/run/etc.
6. Animation states (MOVE-04): cycle through every state — stand still (idle), run (run), jump up (jump), fall down (fall), take damage (hurt). Confirm no animation flickers or freezes on its first frame (no play-every-frame bug). The placeholder is a single-color square, so "flicker" means the animation visibly resets every frame — it should not.
</how-to-verify>
  <resume-signal>Type "approved" if dash responds within 1 frame, knockback direction is always away from the hazard, and all 6 animation states play cleanly — or describe what is broken (e.g., "dash carries through jump", "knockback wrong direction", "hurt animation never exits").</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

Phase 1 is pure local game logic — no STRIDE register applies (RESEARCH.md Security Domain). This section captures Godot-specific implementation pitfalls.

## Implementation Pitfalls (plan-specific)

| Pitfall | Mitigation |
|---------|------------|
| Dash velocity persists through a jump | On jump execution, set `_is_dashing = false` and `_dash_frames_remaining = 0` (RESEARCH.md Pitfall 6). |
| Gravity applied during dash, fighting `velocity.y = 0` | Skip gravity when `_is_dashing` is true. |
| Knockback direction computed with wrong signs | Always use `(global_position - hit_from_position).normalized()` — away from the hit source regardless of attack angle (RESEARCH.md line 480). |
| Buffered jump fires right after taking knockback | `take_damage()` sets `_jump_buffer_timer = 0` (RESEARCH.md Pitfall 4). |
| `play()` called every frame — animations freeze on frame 0 | Guard with `if sprite.animation != new_anim` (RESEARCH.md Pitfall 7). |
| `hurt`/`death` loop, so `animation_finished` never fires | Set `loop = false` on hurt and death in the SpriteFrames resource. |
| Knockback resets coyote time | Do NOT touch `_coyote_timer` in `take_damage` — being launched off a ledge by a hit is intended (RESEARCH.md line 336). |
| Using GPUParticles2D anywhere | Not in this plan, but: this project's GL Compatibility renderer requires CPUParticles2D only (relevant in Plan 03). |
</threat_model>

<verification>
- `player.tscn` AnimatedSprite2D has a SpriteFrames resource with all 6 animations; hurt/death are non-looping.
- `player.gd` has `_start_dash()`, `take_damage()`, full `_update_animation()`, and the `animation_finished` handler.
- `damage_trigger.gd` calls `take_damage(global_position)` on body entry.
- Human checkpoint confirms Success Criteria 2, 3 (partial — knockback + hurt), and 4: dash ≤1 frame, knockback visible and correctly directed, all 6 animations clean.
</verification>

<success_criteria>
- MOVE-02 satisfied: horizontal dash available, responds within 1 frame, has cooldown and i-frames, cancels on jump.
- MOVE-03 satisfied: knockback on damage is visible and always directed away from the hit source.
- MOVE-04 satisfied: all 6 animations (idle, run, jump, fall, hurt, death) play in their correct states without transition artefacts.
- `player.gd` is structured so Plan 03 can hook white-flash + hit-stop into `take_damage()` and dust + squash into `_on_land()`.
</success_criteria>

<output>
After completion, create `.planning/phases/01-game-feel/01-002-SUMMARY.md` recording: final dash/knockback tuning values, the SpriteFrames setup, any feel adjustments from the checkpoint, and confirmation that `take_damage()` and `_on_land()` are ready for Plan 03 juice hooks.
</output>
