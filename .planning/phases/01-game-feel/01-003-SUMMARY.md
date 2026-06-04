---
phase: 01-game-feel
plan: "03"
subsystem: player-juice
tags: [godot4, gdscript, CPUParticles2D, squash-stretch, white-flash, hit-stop, juice]
dependency_graph:
  requires: [01-001-core-movement, 01-002-dash-knockback-animations]
  provides: [landing-dust, squash-stretch-tweens, white-flash, hit-stop, polished-test-scene]
  affects: [scenes/player/player.gd, scenes/player/player.tscn, scenes/test_movement/]
tech_stack:
  added: []
  patterns:
    - "CPUParticles2D one-shot burst triggered via restart() on _on_land()"
    - "Tween kill-guard before create_tween() prevents scale/modulate drift on overlapping effects"
    - "Engine.time_scale=0 hit-stop with create_timer(duration, true) — process_always mandatory"
    - "AnimatedSprite2D scale/modulate targets ONLY — never CharacterBody2D root"
    - "_start_hit_stop called without await from take_damage — detached coroutine pattern"
key_files:
  created: []
  modified:
    - scenes/player/player.gd
    - scenes/player/player.tscn
    - scenes/test_movement/test_movement.tscn
    - scenes/test_movement/test_movement.gd
key_decisions:
  - "CPUParticles2D (never GPUParticles2D): GL Compatibility renderer for web export — GPU particles silently fail"
  - "create_timer(frames/60.0, true) for hit-stop: process_always=true mandatory or timer freezes at time_scale=0"
  - "All tween durations under 0.3s: snap_2d_transforms_to_pixel is ON, longer tweens cause sub-pixel jitter"
  - "_start_hit_stop called without await in take_damage: detached coroutine, function returns immediately"
  - "ControlsLabel anchored bottom-left in pt-BR: matches project language; replaces previous English HintLabel"
metrics:
  duration: "~15 min"
  completed: "2026-06-04"
  tasks_total: 5
  tasks_completed: 4
  files_created: 0
  files_modified: 4
---

# Phase 01 Plan 03: Juice Effects Summary

**One-liner:** Landing dust via CPUParticles2D, elastic squash/stretch tweens on jump and land, HDR white flash tween on damage, and 3-frame hit-stop via Engine.time_scale=0 with process_always timer — all juice hooked into _on_land() and take_damage() extension points.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Squash/stretch tweens + white flash | cd609a4 | player.gd |
| 2 | Hit-stop + wire flash+hit-stop into take_damage | 188af76 | player.gd |
| 3 | CPUParticles2D landing dust in player.tscn + _on_land() | dab289f | player.gd, player.tscn |
| 4 | Polish test scene HUD (time_scale readout + ControlsLabel) | 3a7fe5a | test_movement.gd, test_movement.tscn |
| 5 | Human verify — ALL 5 Phase 1 Success Criteria | PENDING | checkpoint:human-verify |

## Implementation Details

### Squash / Stretch (Task 1)

- `_apply_jump_stretch()`: snap `sprite.scale = Vector2(0.75, 1.3)` (tall+narrow), elastic ease-out tween to `Vector2(1.0, 1.0)` in 0.25s
- `_apply_land_squash()`: snap `sprite.scale = Vector2(1.3, 0.75)` (wide+short), elastic ease-out tween to `Vector2(1.0, 1.0)` in 0.2s
- Both use `_squash_tween` with kill-guard; wired: jump stretch in jump execution block, land squash in `_on_land()`

### White Flash (Task 1)

- `_start_white_flash()`: sets `sprite.modulate = Color(10.0, 10.0, 10.0)` (HDR overshoot), quint ease-out tween to `Color(1.0, 1.0, 1.0)` in 0.3s
- Uses `_flash_tween` with kill-guard for overlap safety

### Hit-Stop (Task 2)

- `_start_hit_stop(frames: int = 3)`: `Engine.time_scale = 0.0`, await `create_timer(frames / 60.0, true).timeout`, `Engine.time_scale = 1.0`
- `process_always = true` is mandatory — normal SceneTreeTimer is frozen at `time_scale=0` and never fires (RESEARCH.md Pitfall 2)
- Called without `await` inside `take_damage()` — runs as detached coroutine, take_damage returns immediately
- `@export var hit_stop_frames: int = 3` — Inspector-tunable (valid range 2-4 per MOVE-05)

### Landing Dust (Task 3)

CPUParticles2D `DustParticles` node at `position = Vector2(0, 15)` (feet):

| Property | Value |
|----------|-------|
| emitting | false (script-controlled) |
| one_shot | true |
| amount | 8 |
| lifetime | 0.3s |
| direction | Vector2(0, -1) — puff upward |
| spread | 80.0 degrees |
| initial_velocity_min/max | 30.0 / 80.0 |
| gravity | Vector2(0, 200) — fall back down |
| scale_amount_min/max | 2.0 / 2.0 — 2px visible at 320x180 |
| color | Color(0.7, 0.65, 0.55, 1) — dusty tan |

`_on_land()` now: `_apply_land_squash()` + `dust_particles.restart()`

### Test Scene Polish (Task 4)

- HUD `StateLabel` now shows: vel, on_floor, coyote, jump_buf, dashing, invincible, hurt, **time_scale** (hit-stop freeze visible as 1.0→0.0 drop)
- `_process` has null-guard: `if player == null: return`
- `ControlsLabel` anchored bottom-left: "A/D correr | SPACE pular | SHIFT/K dash | caixa vermelha = dano"
- `LedgePlatform` (for coyote testing) and `DamageTrigger` (for knockback/flash/hit-stop) confirmed present

## Juice Tuning Values (Inspector-tunable)

| Parameter | Value | Export group |
|-----------|-------|-------------|
| jump stretch scale | Vector2(0.75, 1.3) | hardcoded |
| land squash scale | Vector2(1.3, 0.75) | hardcoded |
| jump stretch duration | 0.25s | hardcoded |
| land squash duration | 0.20s | hardcoded |
| white flash peak | Color(10, 10, 10) HDR | hardcoded |
| white flash duration | 0.30s | hardcoded |
| hit_stop_frames | 3 | @export Juice |

All tween durations are under 0.3s per RESEARCH.md constraint (snap_2d_transforms_to_pixel is ON).

## Deviations from Plan

None — plan executed exactly as written. All four juice functions implemented per RESEARCH.md Pattern 5a/5b/5c/5d. No Rule 1/2/3 interventions needed.

## Known Stubs

| Stub | File | Reason |
|------|------|--------|
| All 6 animations use 1-frame placeholder | player.tscn | Intentional — real pixel art is Phase 2+ (NPC-04) |
| `die()` sets `_is_dead = true` only | player.gd | Intentional — Phase 3 adds health/respawn system |
| `take_damage()` has no health/lives | player.gd | Intentional — Phase 3 adds health system |

## Threat Surface Scan

No new network endpoints, auth paths, or file access patterns introduced. Pure local game logic — no STRIDE concerns (confirmed per plan threat_model).

## Self-Check

- [x] player.gd has `_apply_jump_stretch`, `_apply_land_squash`, `_start_white_flash` — cd609a4
- [x] player.gd has `_start_hit_stop` with `create_timer(duration, true)` — 188af76
- [x] player.gd `take_damage()` calls `_start_white_flash()` and `_start_hit_stop()` — 188af76
- [x] player.tscn has CPUParticles2D `DustParticles`, no GPUParticles2D — dab289f
- [x] player.gd `_on_land()` calls `_apply_land_squash()` and `dust_particles.restart()` — dab289f
- [x] test_movement.gd has `Engine.time_scale` in HUD readout — 3a7fe5a
- [x] test_movement.tscn has `ControlsLabel`, `LedgePlatform`, `DamageTrigger` — 3a7fe5a

## Self-Check: PASSED

All files verified on disk. All commits verified in git log.

## Next Step

Task 5 (checkpoint:human-verify): Open `scenes/test_movement/test_movement.tscn` in the Godot editor, press F6, and verify all 5 Phase 1 Success Criteria:
1. Coyote + jump buffer (HUD timers visible)
2. Dash (SHIFT/K, cooldown blocks re-dash)
3. Knockback + white flash + hit-stop (time_scale drops to 0 then resumes — never stays frozen)
4. 6 clean animations (idle/run/jump/fall/hurt/death — no flicker)
5. Landing dust + squash/stretch (every landing: particles at feet + sprite spring)

Once approved, `player.gd` and `player.tscn` are the reusable player controller for all later worlds (Phase 3+). Phase 1 goal achieved: "Natália se move com precisão e satisfação."

---
*Phase: 01-game-feel*
*Completed: 2026-06-04 (pending Task 5 human-verify)*
