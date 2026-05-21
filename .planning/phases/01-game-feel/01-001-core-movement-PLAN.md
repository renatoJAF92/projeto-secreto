---
phase: 01-game-feel
plan: 01
type: execute
wave: 1
status: pending
depends_on: []
files_modified:
  - project.godot
  - scenes/player/player.tscn
  - scenes/player/player.gd
  - scenes/test_movement/test_movement.tscn
  - scenes/test_movement/test_movement.gd
  - assets/sprites/player/.gitkeep
autonomous: false
requirements: [MOVE-01]
must_haves:
  truths:
    - "Player runs left and right with keyboard input"
    - "Player jumps and falls with asymmetric gravity (heavier fall)"
    - "Player can still jump for 6 frames after walking off a ledge (coyote time)"
    - "A jump pressed up to 8 frames before landing executes on landing (jump buffer)"
    - "Releasing jump mid-ascent cuts the jump short (variable jump height)"
    - "Test scene shows live debug values for velocity, coyote timer, jump buffer"
  artifacts:
    - path: "scenes/player/player.gd"
      provides: "CharacterBody2D movement controller with coyote time + jump buffer"
      contains: "_physics_process"
    - path: "scenes/player/player.tscn"
      provides: "Player scene: CharacterBody2D + AnimatedSprite2D + CollisionShape2D"
      contains: "CharacterBody2D"
    - path: "scenes/test_movement/test_movement.tscn"
      provides: "Isolated test scene with floor + ledge platform + debug HUD"
      contains: "test_movement"
    - path: "project.godot"
      provides: "InputMap actions: jump, dash, walk_left, walk_right"
      contains: "input"
  key_links:
    - from: "scenes/test_movement/test_movement.tscn"
      to: "scenes/player/player.tscn"
      via: "instanced child node named Player"
      pattern: "player.tscn"
    - from: "scenes/test_movement/test_movement.gd"
      to: "scenes/player/player.gd"
      via: "reads exported/runtime vars for HUD"
      pattern: "_coyote_timer"
---

<objective>
Build the foundation of Natália's character controller: a `CharacterBody2D` with run, asymmetric gravity, coyote time (6 frames), jump buffer (8 frames), and variable jump height. Create the isolated test scene with a floor and a ledge platform so coyote/buffer behavior is observable, plus a debug HUD.

Purpose: MOVE-01 is the bedrock of game feel. Every later mechanic (dash, knockback, juice) extends this script. Coyote time and jump buffer must be testable on a real ledge before any further work.
Output: `player.gd` + `player.tscn` + `test_movement.tscn` + `test_movement.gd`, and 4 InputMap actions in `project.godot`.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/ROADMAP.md
@.planning/phases/01-game-feel/01-RESEARCH.md
@project.godot

# Phase Goal (user story)
## Phase Goal

**As a** jogadora, **I want to** mover a Natália com corrida, pulo e queda responsivos (coyote time, jump buffer, gravidade assimétrica), **so that** o controle pareça preciso e satisfatório antes de qualquer fase ser construída.

# Project facts (from project.godot — already verified)
- Renderer: `gl_compatibility` — GPU particles will silently fail (relevant in Plan 03)
- Viewport: 320x180, stretch `canvas_items`, scale `integer`
- `2d/snap/snap_2d_transforms_to_pixel=true` — scale tweens may jitter (relevant in Plan 03)
- Physics FPS: default 60 Hz — coyote=6 and buffer=8 are calibrated for 60 Hz
- `project.godot` currently has NO `[input]` section — this plan adds it

# Current state
- `scenes/`, `scripts/`, `assets/sprites/player/` exist but contain no game code
- No GDScript files exist anywhere in the project
- `scenes/main.tscn` is a minimal Node2D + Label (do not modify)
</context>

<tasks>

<task type="auto">
  <name>Task 1: Add InputMap actions to project.godot</name>
  <files>project.godot</files>
  <action>
Add a new `[input]` section to `project.godot` defining four InputMap actions. Insert the section after the existing `[display]` section (before `[rendering]`), preserving all existing content exactly.

Define these four actions, each with `deadzone=0.5` and an `events` PackedStringArray of InputEventKey resources:
- `walk_left` — physical keycode A (4194433 is LEFT arrow; use keycode 65 for A) AND LEFT arrow (4194319)
- `walk_right` — physical keycode D (68) AND RIGHT arrow (4194321)
- `jump` — SPACE (32) AND keycode W (87) AND UP arrow (4194320)
- `dash` — SHIFT (4194325) AND keycode K (75)

Use the standard Godot 4.4 InputEventKey serialization format. Example for one action:

  walk_left={
  "deadzone": 0.5,
  "events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":65,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
  , Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":4194319,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
  ]
  }

Use `physical_keycode` for letter keys (A/D/W/K) so the layout works on non-QWERTY keyboards; use `keycode` for SPACE/SHIFT/arrows. Replicate the block for each of the four actions.

Do NOT remove the default `ui_left`/`ui_right`/`ui_accept` actions — they remain available implicitly (they are engine built-ins not stored in project.godot). The player script will use the new custom actions, not `ui_*`.
  </action>
  <verify>
    <automated>grep -E 'walk_left=|walk_right=|jump=|dash=' project.godot | wc -l | grep -q 4 && echo "OK: 4 actions defined" || echo "FAIL"</automated>
  </verify>
  <done>`project.godot` contains an `[input]` section with `walk_left`, `walk_right`, `jump`, and `dash` actions; existing sections unchanged; file still parses (opens in Godot without error).</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Create player.gd movement controller and player.tscn</name>
  <files>scenes/player/player.gd, scenes/player/player.tscn, assets/sprites/player/.gitkeep</files>
  <behavior>
    - Pressing walk_right sets velocity.x to +run_speed; walk_left sets -run_speed; neither = velocity.x decays to 0 via move_toward.
    - Asymmetric gravity: when velocity.y < 0, gravity_up (900) applied; when velocity.y >= 0, gravity_down (1600) applied — fall is heavier than rise.
    - Coyote time: after _was_on_floor was true and is_on_floor() becomes false without a jump, _coyote_timer is set to coyote_frames (6) and decrements each airborne frame.
    - Jump buffer: pressing jump sets _jump_buffer_timer to jump_buffer_frames (8); it decrements each frame; jump executes when buffer > 0 AND (is_on_floor OR _coyote_timer > 0).
    - Variable jump: releasing jump while velocity.y < 0 multiplies velocity.y by 0.4.
    - On landing transition (was airborne, now on floor), _on_land() is called exactly once.
  </behavior>
  <action>
Create `scenes/player/player.gd` extending `CharacterBody2D`. This is the MOVE-01 portion of the controller. Plans 02 and 03 will extend this same file — design it so dash/knockback/juice slot in cleanly. Implement exactly per RESEARCH.md Pattern 1 + Pattern 2.

Exported tuning vars (group them with `@export_group("Movement")`):
- `run_speed: float = 200.0`
- `jump_velocity: float = -380.0`
- `gravity_up: float = 900.0`
- `gravity_down: float = 1600.0`
- `coyote_frames: int = 6`
- `jump_buffer_frames: int = 8`
- `jump_cut_multiplier: float = 0.4`

Runtime state vars: `_was_on_floor: bool`, `_coyote_timer: int`, `_jump_buffer_timer: int`, `_jumped_this_frame: bool`.

`@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D`

`_physics_process(delta)` ordered exactly as RESEARCH.md Pattern 1 lines 170-218:
1. `_jumped_this_frame = false`
2. Asymmetric gravity: `velocity.y += (gravity_up if velocity.y < 0.0 else gravity_down) * delta`
3. Horizontal movement using `Input.get_axis("walk_left", "walk_right")` — when dir != 0: `velocity.x = dir * run_speed` and `sprite.flip_h = dir < 0.0`; else `velocity.x = move_toward(velocity.x, 0.0, run_speed)`
4. Coyote: `if _was_on_floor and not is_on_floor() and not _jumped_this_frame: _coyote_timer = coyote_frames`; then `if not is_on_floor(): _coyote_timer = max(_coyote_timer - 1, 0)`
5. Jump buffer: `if Input.is_action_just_pressed("jump"): _jump_buffer_timer = jump_buffer_frames` else `_jump_buffer_timer = max(_jump_buffer_timer - 1, 0)`
6. Jump execution: `if _jump_buffer_timer > 0 and (is_on_floor() or _coyote_timer > 0):` set `velocity.y = jump_velocity`, `_coyote_timer = 0`, `_jump_buffer_timer = 0`, `_jumped_this_frame = true`
7. Jump cut: `if Input.is_action_just_released("jump") and velocity.y < 0.0: velocity.y *= jump_cut_multiplier`
8. `_was_on_floor = is_on_floor()` then `move_and_slide()` (NO arguments — Godot 4 API)
9. Landing detection: `if not _was_on_floor and is_on_floor(): _on_land()`
10. `_was_on_floor = is_on_floor()`
11. `_update_animation()`

Add stub methods that Plans 02/03 will fill: `func _on_land() -> void: pass` and `func _update_animation() -> void:` — for this plan `_update_animation` plays "idle"/"run"/"jump"/"fall" guarded by `if sprite.sprite_frames and sprite.animation != new_anim: sprite.play(new_anim)` (the `sprite_frames` null-guard avoids errors before SpriteFrames exists).

CRITICAL — do NOT multiply velocity by delta on direct assignment (`velocity.x = dir * run_speed` is correct, not `* delta`). Only gravity accumulation uses delta. See RESEARCH.md anti-patterns line 475.

Create `scenes/player/player.tscn` with this node tree:
- `CharacterBody2D` (root, name "Player") — attach `player.gd`
  - `AnimatedSprite2D` (name "AnimatedSprite2D") — no SpriteFrames yet (added in Plan 02); leave `sprite_frames` empty
  - `CollisionShape2D` (name "CollisionShape2D") — `RectangleShape2D` with `size = Vector2(20, 30)` (fits a 32x32 sprite with small margins)

Create `assets/sprites/player/.gitkeep` only if the directory is empty (keep the directory tracked; placeholder sprite frames come in Plan 02).
  </action>
  <verify>
    <automated>test -f scenes/player/player.gd && grep -q 'extends CharacterBody2D' scenes/player/player.gd && grep -q 'move_and_slide()' scenes/player/player.gd && grep -q 'walk_left' scenes/player/player.gd && grep -q '_coyote_timer' scenes/player/player.gd && test -f scenes/player/player.tscn && echo "OK" || echo "FAIL"</automated>
  </verify>
  <done>`player.gd` extends CharacterBody2D, calls `move_and_slide()` with no arguments, implements coyote timer + jump buffer + asymmetric gravity + jump cut; `player.tscn` has CharacterBody2D + AnimatedSprite2D + CollisionShape2D and references player.gd.</done>
</task>

<task type="auto">
  <name>Task 3: Create test_movement scene with floor, ledge platform, and debug HUD</name>
  <files>scenes/test_movement/test_movement.tscn, scenes/test_movement/test_movement.gd</files>
  <action>
Create the isolated MOVE-01 test scene. This scene IS the test suite (RESEARCH.md Validation Architecture — no automated framework for feel).

`scenes/test_movement/test_movement.gd` extends `CanvasLayer`. It reads the player's runtime vars and renders them to a Label every frame:
- `@onready var player: CharacterBody2D = $"../Player"`
- `@onready var state_label: Label = $StateLabel`
- `_process(_delta)` sets `state_label.text` to a multi-line string showing: `velocity.x`, `velocity.y`, `is_on_floor()`, `_coyote_timer`, `_jump_buffer_timer`. Use the exact format from RESEARCH.md lines 740-748. Accessing `_`-prefixed vars across scripts is allowed in GDScript and is intentional here for debug display.

`scenes/test_movement/test_movement.tscn` node tree:
- `Node2D` (root, name "TestMovement")
  - `StaticBody2D` (name "MainFloor") at `position = Vector2(160, 160)`
    - `CollisionShape2D` — `RectangleShape2D` `size = Vector2(320, 16)`
    - `Sprite2D` OR `ColorRect`-equivalent: use a `Polygon2D` or a `Sprite2D` with no texture is invisible — instead add a child `ColorRect` is a Control node (wrong). Use a `Sprite2D` is not visible without texture. Simplest visible placeholder: add a `Line2D` is awkward. Use a `Polygon2D` (name "Visual") with `polygon = PackedVector2Array([Vector2(-160,-8), Vector2(160,-8), Vector2(160,8), Vector2(-160,8)])` and `color = Color(0.3, 0.3, 0.35)`.
  - `StaticBody2D` (name "LedgePlatform") at `position = Vector2(240, 110)` — a narrow raised platform for testing coyote time at its edge
    - `CollisionShape2D` — `RectangleShape2D` `size = Vector2(64, 12)`
    - `Polygon2D` (name "Visual") `polygon = PackedVector2Array([Vector2(-32,-6), Vector2(32,-6), Vector2(32,6), Vector2(-32,6)])`, `color = Color(0.4, 0.35, 0.3)`
  - `Player` — instance of `scenes/player/player.tscn`, `position = Vector2(80, 120)`
  - `CanvasLayer` (name "HUD") — attach `test_movement.gd`
    - `Label` (name "StateLabel") anchored top-left, `position = Vector2(4, 4)`, small font OK at default size

Set this scene as a convenient run target: leave `scenes/main.tscn` as the project main scene, but note in the SUMMARY that the tester runs `test_movement.tscn` directly with F6 in the Godot editor.
  </action>
  <verify>
    <automated>test -f scenes/test_movement/test_movement.tscn && test -f scenes/test_movement/test_movement.gd && grep -q 'extends CanvasLayer' scenes/test_movement/test_movement.gd && grep -q 'player.tscn' scenes/test_movement/test_movement.tscn && grep -q 'LedgePlatform' scenes/test_movement/test_movement.tscn && echo "OK" || echo "FAIL"</automated>
  </verify>
  <done>`test_movement.tscn` contains a MainFloor, a raised LedgePlatform, a Player instance, and a HUD CanvasLayer with a StateLabel; `test_movement.gd` reads player velocity/coyote/buffer and writes them to the label.</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <name>Task 4: Verify MOVE-01 game feel in the Godot editor</name>
  <what-built>Core movement controller (run, asymmetric gravity, coyote time 6 frames, jump buffer 8 frames, variable jump height) and an isolated test scene with a floor, a ledge platform, and a live debug HUD.</what-built>
  <how-to-verify>
1. Open the project in the Godot editor (macOS app bundle — `godot` is not in PATH).
2. Open `scenes/test_movement/test_movement.tscn` and press F6 to run this scene.
3. Run + jump check: hold A/D to run, press SPACE to jump. The character should move at a steady speed and stop instantly when keys release. The fall should visibly feel heavier/faster than the rise (asymmetric gravity).
4. Coyote time: walk off the right edge of the LedgePlatform and press SPACE *just after* leaving the edge. Watch the HUD `coyote:` value count 6 -> 0. A jump pressed while `coyote > 0` must succeed.
5. Jump buffer: while falling toward the MainFloor, press SPACE *before* touching ground. Watch `jump_buf:` count 8 -> 0. If you land while `jump_buf > 0`, the character should jump immediately on contact.
6. Variable jump height: tap SPACE briefly vs. hold it — a brief tap should produce a noticeably lower jump (jump cut).
7. Confirm there is no multi-jump exploit: you cannot jump 3+ times by walking to a ledge repeatedly.
</how-to-verify>
  <resume-signal>Type "approved" if coyote (6 frames) and jump buffer (8 frames) are both observable on the ledge and movement feels right, or describe what feels off (e.g., "fall too floaty", "coyote never triggers").</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

Phase 1 is pure local game logic — no network, auth, or persisted user input. No STRIDE register applies (RESEARCH.md Security Domain). This section instead captures Godot-specific implementation pitfalls.

## Implementation Pitfalls (plan-specific)

| Pitfall | Mitigation |
|---------|------------|
| `move_and_slide()` called with arguments (Godot 3 habit) | Godot 4: `move_and_slide()` takes NO arguments; velocity is a property. Verified in RESEARCH.md State of the Art. |
| Multiplying direct velocity assignment by delta | `velocity.x = dir * run_speed` — never `* delta`. Only `velocity.y += gravity * delta` uses delta. |
| `is_on_floor()` checked before `move_and_slide()` | It reflects the PREVIOUS frame. Capture `_was_on_floor` before move, re-read after. Coyote uses `_was_on_floor`. |
| Coyote timer set every airborne frame (multi-jump exploit) | Only set `_coyote_timer` on the falling-edge transition: `_was_on_floor AND NOT is_on_floor() AND NOT _jumped_this_frame`. |
| `_update_animation()` crashing before SpriteFrames exists | Guard `sprite.play()` with `if sprite.sprite_frames and sprite.animation != new_anim`. SpriteFrames are added in Plan 02. |
| Using `ui_left`/`ui_right` instead of custom actions | Use the new `walk_left`/`walk_right`/`jump`/`dash` actions so remapping (Phase 2 ACCESS-02) has a clean target. |
</threat_model>

<verification>
- `project.godot` parses and contains 4 new input actions (`walk_left`, `walk_right`, `jump`, `dash`).
- `player.gd` extends CharacterBody2D, uses `move_and_slide()` with no args, implements coyote + buffer + asymmetric gravity + jump cut.
- `player.tscn` instances cleanly with AnimatedSprite2D + CollisionShape2D.
- `test_movement.tscn` runs with F6 and the HUD updates live.
- Human checkpoint confirms Success Criterion 1: coyote 6 frames + jump buffer 8 frames observable on the ledge platform.
</verification>

<success_criteria>
- MOVE-01 satisfied: run, jump, fall with coyote time 6 frames, jump buffer 8 frames, asymmetric gravity — all observable in `test_movement.tscn`.
- No multi-jump exploit at ledge edges.
- Player and test scenes are reusable foundations for Plans 02 and 03 (no rework needed).
</success_criteria>

<output>
After completion, create `.planning/phases/01-game-feel/01-001-SUMMARY.md` recording: final tuning values used, the F6 test-scene workflow, any feel adjustments made during the checkpoint, and confirmation that `player.gd` is structured for Plan 02/03 extension.
</output>
