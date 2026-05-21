---
phase: 01-game-feel
plan: 03
type: execute
wave: 3
status: pending
depends_on: [01, 02]
files_modified:
  - scenes/player/player.gd
  - scenes/player/player.tscn
  - scenes/test_movement/test_movement.tscn
  - scenes/test_movement/test_movement.gd
autonomous: false
requirements: [MOVE-05]
must_haves:
  truths:
    - "A burst of dust particles appears at Natália's feet every time she lands"
    - "The sprite stretches tall on jump and squashes wide on landing, then springs back"
    - "Taking damage flashes the sprite white, then fades back to normal color"
    - "Taking damage briefly freezes the action for 2-4 frames (hit-stop)"
    - "All juice effects are visible in the isolated test scene with no other gameplay"
  artifacts:
    - path: "scenes/player/player.gd"
      provides: "Squash/stretch tweens, white flash, hit-stop, dust trigger"
      contains: "_start_hit_stop"
    - path: "scenes/player/player.tscn"
      provides: "CPUParticles2D dust node at the player's feet"
      contains: "CPUParticles2D"
  key_links:
    - from: "scenes/player/player.gd _on_land"
      to: "scenes/player/player.tscn DustParticles"
      via: "dust_particles.restart() on landing"
      pattern: "dust_particles.restart"
    - from: "scenes/player/player.gd take_damage"
      to: "_start_white_flash + _start_hit_stop"
      via: "called inside take_damage"
      pattern: "_start_hit_stop"
---

<objective>
Add all visual juice (MOVE-05) to complete Phase 1: landing dust via `CPUParticles2D`, squash/stretch tweens on jump and land, a white flash on damage, and a 3-frame hit-stop. Polish the test scene and run a final verification of all 5 phase Success Criteria.

Purpose: Juice is what turns correct mechanics into satisfying ones. This plan closes Phase 1's goal — "Natália se move com precisão e satisfação" — and is the last plan before any level is built.
Output: Fully juiced `player.gd` + `player.tscn` with a dust particle node, polished test scene, and a verified phase.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/ROADMAP.md
@.planning/phases/01-game-feel/01-RESEARCH.md
@.planning/phases/01-game-feel/01-001-SUMMARY.md
@.planning/phases/01-game-feel/01-002-SUMMARY.md
@scenes/player/player.gd
@scenes/player/player.tscn
@scenes/test_movement/test_movement.tscn

# Phase Goal (user story)
## Phase Goal

**As a** jogadora, **I want to** ver poeira ao aterrissar, squash/stretch no pulo, flash branco e hit-stop ao tomar dano, **so that** cada movimento e impacto da Natália pareça satisfatório.

# Depends on Plans 01 + 02
Plan 01 created the movement controller with the `_on_land()` stub. Plan 02 added dash,
knockback, the 6-state animation machine, and the `take_damage()` method. This plan hooks
juice into the `_on_land()` and `take_damage()` extension points those plans left ready.

# Interfaces from Plans 01/02 (player.gd — extend the same file)
- @onready var sprite: AnimatedSprite2D = $AnimatedSprite2D — squash/stretch and flash apply to THIS node, never the CharacterBody2D root
- _on_land() — called once on the airborne->grounded transition; currently a stub (or partial)
- take_damage(hit_from_position) — already applies knockback, clears jump buffer, sets _is_hurt; this plan adds flash + hit-stop calls inside it
- _apply_jump_stretch should be called from the jump-execution block (Plan 01 already calls a stretch stub or this plan wires it)

# Critical project constraints (from project.godot)
- Renderer is `gl_compatibility` — MUST use CPUParticles2D, NOT GPUParticles2D (RESEARCH.md Pitfall 5; GPU particles silently fail on web/Compatibility)
- `2d/snap/snap_2d_transforms_to_pixel=true` — scale tweens may sub-pixel jitter; keep tween durations < 0.3s (RESEARCH.md line 400)
</context>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: Add squash/stretch tweens and white flash to player.gd</name>
  <files>scenes/player/player.gd</files>
  <behavior>
    - On jump, the sprite snaps to a tall-narrow scale and tweens back to (1,1) with an elastic ease.
    - On landing, the sprite snaps to a wide-short scale and tweens back to (1,1) with an elastic ease.
    - Starting a new squash/stretch while one is running kills the old tween first (no scale drift).
    - On damage, the sprite modulate snaps to an HDR white and tweens back to normal color.
    - All scale/modulate effects target the AnimatedSprite2D, never the CharacterBody2D root.
  </behavior>
  <action>
Extend `scenes/player/player.gd` with squash/stretch and white flash per RESEARCH.md Pattern 5a and 5c (lines 344-398, 683-707).

Add runtime vars: `_flash_tween: Tween`, `_squash_tween: Tween`.

Optionally add `@export_group("Juice")` tuning vars if you want them Inspector-editable: `jump_stretch := Vector2(0.75, 1.3)`, `land_squash := Vector2(1.3, 0.75)`. Hardcoding the literals is also acceptable.

Add `_apply_jump_stretch() -> void` (RESEARCH.md lines 695-700):
- If `_squash_tween` exists and `is_valid()`, `kill()` it.
- `sprite.scale = Vector2(0.75, 1.3)` (tall + narrow at jump start).
- `_squash_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)`.
- `_squash_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.25)`.

Add `_apply_land_squash() -> void` (RESEARCH.md lines 702-707):
- Same kill-guard.
- `sprite.scale = Vector2(1.3, 0.75)` (wide + short on landing).
- Elastic ease-out tween back to `Vector2(1.0, 1.0)` over `0.2`.

Add `_start_white_flash() -> void` (RESEARCH.md lines 683-688):
- If `_flash_tween` exists and `is_valid()`, `kill()` it.
- `sprite.modulate = Color(10.0, 10.0, 10.0)` (HDR white overshoot).
- `_flash_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)`.
- `_flash_tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0), 0.3)`.

Wire `_apply_jump_stretch()` into the jump-execution block of `_physics_process` (right after `velocity.y = jump_velocity` is set), if Plan 01/02 did not already wire it.

CRITICAL: all `scale` and `modulate` writes target `sprite` (the AnimatedSprite2D). Scaling the CharacterBody2D root moves the CollisionShape2D and makes the player sink into the floor (RESEARCH.md Pitfall 3). Keep all tween durations < 0.3s to limit sub-pixel jitter (RESEARCH.md line 400).
  </action>
  <verify>
    <automated>grep -q '_apply_jump_stretch' scenes/player/player.gd && grep -q '_apply_land_squash' scenes/player/player.gd && grep -q '_start_white_flash' scenes/player/player.gd && grep -q 'TRANS_ELASTIC' scenes/player/player.gd && grep -q 'Color(10' scenes/player/player.gd && echo "OK" || echo "FAIL"</automated>
  </verify>
  <done>`player.gd` has `_apply_jump_stretch()`, `_apply_land_squash()`, and `_start_white_flash()`, all targeting the AnimatedSprite2D with kill-guarded tweens; jump stretch is wired into the jump block.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Add hit-stop to player.gd and wire flash + hit-stop into take_damage</name>
  <files>scenes/player/player.gd</files>
  <behavior>
    - _start_hit_stop sets Engine.time_scale to 0, waits a real-time interval of frames/60 seconds, then restores time_scale to 1.
    - The recovery timer uses create_timer(duration, true) so it is NOT frozen by time_scale = 0.
    - take_damage calls _start_white_flash() and _start_hit_stop(3) in addition to its existing knockback/jump-buffer/hurt behavior.
    - After a hit, the game resumes normally (time_scale returns to 1, never stuck at 0).
  </behavior>
  <action>
Extend `scenes/player/player.gd` with hit-stop per RESEARCH.md Pattern 5b (lines 359-372, 690-692).

Add `@export var hit_stop_frames: int = 3` (in the Juice group; valid range 2-4 per MOVE-05).

Add `_start_hit_stop(frames: int = 3) -> void`:
- `Engine.time_scale = 0.0`
- `await get_tree().create_timer(frames / 60.0, true).timeout`
- `Engine.time_scale = 1.0`

The SECOND argument to `create_timer` MUST be `true` (`process_always`). With `time_scale = 0.0`, a normal SceneTreeTimer is frozen and never fires, permanently pausing the game (RESEARCH.md Pitfall 2 — the single most common hit-stop bug). This is non-negotiable.

Edit the existing `take_damage(hit_from_position: Vector2)` method (added in Plan 02): after the existing `_is_hurt = true` line, add:
- `_start_white_flash()`
- `_start_hit_stop(hit_stop_frames)`

Note: `_start_hit_stop` is a coroutine (uses `await`). Calling it without `await` from `take_damage` is correct — it runs as a detached coroutine and `take_damage` returns immediately. Do not `await` it inside `take_damage`.
  </action>
  <verify>
    <automated>grep -q '_start_hit_stop' scenes/player/player.gd && grep -q 'Engine.time_scale = 0.0' scenes/player/player.gd && grep -q 'Engine.time_scale = 1.0' scenes/player/player.gd && grep -qE 'create_timer\([^,]+, ?true\)' scenes/player/player.gd && grep -A12 'func take_damage' scenes/player/player.gd | grep -q '_start_white_flash' && echo "OK" || echo "FAIL"</automated>
  </verify>
  <done>`player.gd` has `_start_hit_stop()` using `create_timer(duration, true)`; `take_damage()` now also calls `_start_white_flash()` and `_start_hit_stop(hit_stop_frames)`; game always resumes after a hit.</done>
</task>

<task type="auto">
  <name>Task 3: Add CPUParticles2D landing dust to player.tscn and wire it</name>
  <files>scenes/player/player.tscn, scenes/player/player.gd</files>
  <action>
Add landing dust per RESEARCH.md Pattern 5d (lines 404-429). Use `CPUParticles2D` — NEVER `GPUParticles2D`: this project's `gl_compatibility` renderer makes GPU particles silently fail on web export (RESEARCH.md Pitfall 5).

Edit `scenes/player/player.tscn`: add a `CPUParticles2D` child of the Player root, named `DustParticles`, positioned at the player's feet — `position = Vector2(0, 15)` (bottom edge of the ~30px-tall collision shape).

Configure the CPUParticles2D node properties (RESEARCH.md lines 419-428):
- `emitting = false` (script-controlled)
- `one_shot = true`
- `amount = 8`
- `lifetime = 0.3`
- `direction = Vector2(0, -1)` (puff upward)
- `spread = 80.0` (degrees)
- `initial_velocity_min = 30.0`, `initial_velocity_max = 80.0`
- `gravity = Vector2(0, 200)` (particles fall back down)
- `scale_amount_min = 2.0`, `scale_amount_max = 2.0` (2px particles, visible at 320x180)
- `color = Color(0.7, 0.65, 0.55)` (dusty tan)

Edit `scenes/player/player.gd`:
- Add `@onready var dust_particles: CPUParticles2D = $DustParticles`.
- In `_on_land()` (the stub from Plan 01), add `_apply_land_squash()` and `dust_particles.restart()`. `restart()` re-emits the one-shot burst on every landing (RESEARCH.md line 416). Ensure `_on_land()` now contains exactly: the land squash call and the dust restart call.
  </action>
  <verify>
    <automated>grep -q 'CPUParticles2D' scenes/player/player.tscn && ! grep -q 'GPUParticles2D' scenes/player/player.tscn && grep -q 'DustParticles' scenes/player/player.tscn && grep -q 'dust_particles' scenes/player/player.gd && grep -A4 'func _on_land' scenes/player/player.gd | grep -q 'restart' && echo "OK" || echo "FAIL"</automated>
  </verify>
  <done>`player.tscn` has a `CPUParticles2D` named DustParticles at the feet, configured one-shot; NO GPUParticles2D anywhere; `_on_land()` calls `_apply_land_squash()` and `dust_particles.restart()`.</done>
</task>

<task type="auto">
  <name>Task 4: Polish the test scene HUD and add a controls legend</name>
  <files>scenes/test_movement/test_movement.tscn, scenes/test_movement/test_movement.gd</files>
  <action>
Final polish so the test scene cleanly demonstrates all 5 phase Success Criteria with no other gameplay (MOVE-05 success gate requires effects visible in an isolated test scene).

Edit `scenes/test_movement/test_movement.gd`:
- Confirm the HUD `StateLabel` shows: `velocity.x/y`, `is_on_floor()`, `_coyote_timer`, `_jump_buffer_timer`, `_is_dashing`, `_is_invincible`, `_is_hurt`. Add `Engine.time_scale` to the readout so the hit-stop freeze is visible as a value drop.
- Keep `_process` defensive: if `player` is null, skip (avoids errors if the scene tree changes).

Edit `scenes/test_movement/test_movement.tscn`:
- Add a second `Label` (name "ControlsLabel") under the HUD CanvasLayer, anchored bottom-left, text: `A/D correr  |  SPACE pular  |  SHIFT/K dash  |  caixa vermelha = dano`.
- Verify the LedgePlatform (for coyote testing) and the DamageTrigger (for knockback/flash/hit-stop testing) from Plans 01-02 are present and positioned so a player can reach both easily.
- Ensure no extra gameplay elements (enemies, collectibles) are in the scene — MOVE-05's gate requires juice visible in isolation.

Do not change the project main scene; the tester runs `test_movement.tscn` directly with F6.
  </action>
  <verify>
    <automated>grep -q 'time_scale' scenes/test_movement/test_movement.gd && grep -q 'ControlsLabel' scenes/test_movement/test_movement.tscn && grep -q 'LedgePlatform' scenes/test_movement/test_movement.tscn && grep -q 'DamageTrigger' scenes/test_movement/test_movement.tscn && echo "OK" || echo "FAIL"</automated>
  </verify>
  <done>The test scene HUD shows full debug state including `Engine.time_scale`; a controls legend Label is present; the LedgePlatform and DamageTrigger are reachable; no extraneous gameplay elements.</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <name>Task 5: Final Phase 1 verification — all 5 Success Criteria</name>
  <what-built>The complete Phase 1 game feel: core movement with coyote time + jump buffer, dash, knockback, 6 animations, plus all juice — landing dust (CPUParticles2D), squash/stretch tweens, white flash, and 3-frame hit-stop. Verified in the isolated `test_movement.tscn`.</what-built>
  <how-to-verify>
Open the project in the Godot editor and run `scenes/test_movement/test_movement.tscn` (F6). Verify ALL 5 phase Success Criteria:

1. **Coyote + jump buffer (MOVE-01):** Walk off the LedgePlatform edge and jump within ~6 frames — the jump still fires. While falling, press SPACE before landing — the jump fires on contact. Both timers visible counting down on the HUD.
2. **Dash (MOVE-02):** Press SHIFT/K — Natália dashes horizontally within 1 frame; cooldown blocks immediate re-dash.
3. **Knockback + flash + hit-stop (MOVE-03 / MOVE-05):** Run into the red DamageTrigger box. Confirm three things on a single hit: (a) visible knockback away from the box, (b) the sprite flashes bright white then fades back, (c) the action briefly freezes for 2-4 frames — the HUD `time_scale` value should momentarily drop to 0. Critically: the game must RESUME after the freeze (never stay frozen).
4. **6 animations (MOVE-04):** Cycle idle / run / jump / fall / hurt; trigger `die()` if exposed for death. No flicker, no freeze-on-frame-0, clean transitions.
5. **Dust + squash/stretch (MOVE-05):** Jump and land repeatedly. On takeoff the sprite stretches tall; on landing it squashes wide and springs back; a puff of dust appears at the feet on every landing. All visible in this isolated scene.

If you have a web build available, optionally export and confirm the dust particles still appear in the browser (GL Compatibility / CPUParticles2D regression check) — not required to pass, but noted.
</how-to-verify>
  <resume-signal>Type "approved" if all 5 Success Criteria pass — coyote/buffer, dash, knockback+flash+hit-stop (game resumes), 6 clean animations, dust+squash/stretch all visible. Otherwise describe which criterion fails (e.g., "game stays frozen after hit-stop", "no dust on landing", "squash makes player sink into floor").</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

Phase 1 is pure local game logic — no STRIDE register applies (RESEARCH.md Security Domain). This section captures Godot-specific implementation pitfalls.

## Implementation Pitfalls (plan-specific)

| Pitfall | Mitigation |
|---------|------------|
| `GPUParticles2D` used for dust | Use `CPUParticles2D` only. GPU particles need compute shaders absent in GL Compatibility — they silently fail on web export (RESEARCH.md Pitfall 5). |
| Hit-stop freezes the game permanently | `create_timer(duration, true)` — the `true` (process_always) flag is mandatory; with `time_scale = 0` a normal timer never fires (RESEARCH.md Pitfall 2). |
| Squash/stretch scales the CharacterBody2D root | Apply `scale` only to the AnimatedSprite2D child — scaling the root moves the collider and the player sinks into the floor (RESEARCH.md Pitfall 3). |
| Overlapping tweens drift the scale/modulate | Kill the existing tween (`if tween and tween.is_valid(): tween.kill()`) before starting a new one. |
| Long scale tweens cause sub-pixel jitter | `snap_2d_transforms_to_pixel` is ON — keep all juice tween durations < 0.3s (RESEARCH.md line 400). |
| `await`-ing `_start_hit_stop` inside `take_damage` | Call it without `await` — it runs as a detached coroutine so `take_damage` returns immediately. |
| Audio slows during hit-stop | It does not — `Engine.time_scale` does not affect `AudioServer`; hit SFX play at normal speed, which is correct (RESEARCH.md line 372). |
</threat_model>

<verification>
- `player.gd` has squash/stretch, white flash, and hit-stop; `take_damage()` calls flash + hit-stop; `_on_land()` calls land squash + dust restart.
- `player.tscn` has a `CPUParticles2D` dust node; no `GPUParticles2D` anywhere in the project.
- Hit-stop recovery timer uses `process_always = true` — game always resumes.
- Human checkpoint confirms ALL 5 phase Success Criteria pass in the isolated test scene.
</verification>

<success_criteria>
- MOVE-05 satisfied: landing dust, squash/stretch on jump and land, white flash on damage, and 2-4 frame hit-stop all visible in `test_movement.tscn`.
- All 5 Phase 1 Success Criteria verified by the human checkpoint.
- No GPU-particle web-export regression risk (CPUParticles2D used throughout).
- Phase 1 goal met: Natália moves with precision and satisfaction — phase ready to close.
</success_criteria>

<output>
After completion, create `.planning/phases/01-game-feel/01-003-SUMMARY.md` recording: final juice tuning values (squash/stretch scales, flash duration, hit-stop frames, particle settings), confirmation that all 5 Success Criteria passed, the F6 test-scene workflow, and a note that `player.tscn`/`player.gd` are the reusable controller for all later worlds.
</output>
