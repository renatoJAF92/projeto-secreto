---
phase: 01-game-feel
plan: "02"
subsystem: player-mechanics
tags: [dash, knockback, animations, sprite-frames, placeholder-art]
dependency_graph:
  requires: [01-001-core-movement]
  provides: [dash-mechanic, knockback-system, animation-state-machine, damage-trigger]
  affects: [scenes/player/player.gd, scenes/player/player.tscn, scenes/test_movement/]
tech_stack:
  added: []
  patterns:
    - "6-state animation machine with priority guard (no play-every-frame)"
    - "Direction-based knockback via (global_position - hit_from_position).normalized()"
    - "Dash cooldown via one-shot timer (get_tree().create_timer)"
    - "Invincibility flag shared between dash and damage states"
key_files:
  created:
    - assets/sprites/player/natalia_placeholder.svg
    - scenes/test_movement/damage_trigger.gd
  modified:
    - scenes/player/player.gd
    - scenes/player/player.tscn
    - scenes/test_movement/test_movement.tscn
    - scenes/test_movement/test_movement.gd
decisions:
  - "Tasks 2+3+4 committed together — all three are modifications to player.gd and are deeply intertwined (dash sets _is_invincible used by take_damage, _is_hurt drives animation machine)"
  - "SVG placeholder for sprite — text-diffable, no Git LFS needed, Godot imports it as Texture2D"
  - "Knockback decay via Vector2.lerp per frame rather than a fixed impulse — smooth deceleration matches game feel goals"
  - "damage_trigger.gd connects body_entered in _ready() rather than via .tscn signal connection — avoids need for UID wiring in test scene"
metrics:
  duration: "~2 min"
  completed: "2026-05-21"
  tasks_total: 6
  tasks_completed: 5
  files_created: 2
  files_modified: 4
---

# Phase 01 Plan 02: Dash, Knockback, and Animations Summary

**One-liner:** Horizontal dash with i-frames and cooldown, direction-based knockback on damage, 6-state priority animation machine with `animation_finished` reset, and a red damage trigger in the test scene.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Placeholder sprite + 6-animation SpriteFrames | 03cb13f | natalia_placeholder.svg, player.tscn |
| 2 | Horizontal dash | 5d41d68 | player.gd |
| 3 | Knockback + take_damage | 5d41d68 | player.gd |
| 4 | 6-state animation machine | 5d41d68 | player.gd |
| 5 | Damage trigger in test scene | e3f62ab | damage_trigger.gd, test_movement.tscn, test_movement.gd |
| 6 | Human verify | PENDING | — checkpoint:human-verify |

## Implementation Details

### Dash (MOVE-02)
- `dash_speed = 550.0`, `dash_duration_frames = 12`, `dash_cooldown = 0.4s`
- `_start_dash()` sets direction from `sprite.flip_h`, grants invincibility, starts one-shot cooldown timer
- Gravity is skipped while `_is_dashing` (no gravity fighting `velocity.y = 0`)
- Dash cancels on jump: when jump executes, `_is_dashing = false` and `_dash_frames_remaining = 0`

### Knockback (MOVE-03)
- `knockback_impulse = 300.0`, `knockback_decay = 8.0` (lerp factor per second)
- Direction computed as `(global_position - hit_from_position).normalized()` — always away from hit source
- `_jump_buffer_timer = 0` in `take_damage()` — buffered jump does not fire after a hit
- `_coyote_timer` is NOT touched — being launched off a ledge by a hit is intentional
- Respects `_is_invincible`: no double-hit during dash or during existing i-frames

### Animation Machine (MOVE-04)
- Priority: `hurt` > `death` > `jump/fall` (by `velocity.y` sign) > `run` (if `abs(vx) > 10`) > `idle`
- Guard: `if sprite.sprite_frames and sprite.animation != new_anim: sprite.play(new_anim)` — no frame-0 freeze
- `_on_animated_sprite_2d_animation_finished()`: resets `_is_hurt = false` after hurt; logs death placeholder
- `hurt` and `death` SpriteFrames animations have `loop = false` so `animation_finished` fires correctly

### SpriteFrames
- 6 animations each with 1 frame referencing `natalia_placeholder.svg`
- `idle` (5fps loop), `run` (10fps loop), `jump` (5fps no-loop), `fall` (5fps no-loop), `hurt` (8fps no-loop), `death` (6fps no-loop)
- Signal `animation_finished` connected from AnimatedSprite2D to Player in player.tscn

### Test Scene
- `DamageTrigger` Area2D at (150, 145) — in the player's running path on the main floor
- Red Polygon2D visual (Color 0.85/0.2/0.2) makes it immediately visible
- HUD now shows: vel, on_floor, coyote, jump_buf, dashing, invincible, hurt
- HintLabel: "A/D run  SPACE jump  SHIFT/K dash  walk into red box for damage"

## Plan 03 Hooks Ready
- `take_damage()` has a comment marking where white-flash + hit-stop go
- `_on_land()` remains a stub for squash/stretch + dust in Plan 03
- `_is_invincible` is shared between dash and damage — Plan 03 can extend without conflict

## Deviations from Plan

### Structural note: Tasks 2+3+4 in single commit
- **Found during:** Execution
- **Reason:** All three tasks modify only `player.gd`. The dash variables (`_is_invincible`) are immediately consumed by `take_damage()`, and `_is_hurt` is immediately consumed by `_update_animation()`. Writing them in three separate partial states would produce non-compiling intermediate commits. Combined into one logical commit with full description.
- **Rule applied:** Rule 2 — maintaining correctness of each committed state
- **Commit:** 5d41d68

## Known Stubs

| Stub | File | Line | Reason |
|------|------|------|--------|
| `_on_land()` is empty | scenes/player/player.gd | ~110 | Intentional stub — Plan 03 adds squash/stretch + dust |
| `die()` sets `_is_dead = true` only | scenes/player/player.gd | ~128 | Intentional stub — Phase 3 wires real respawn logic |
| All 6 animations use same 1-frame placeholder | scenes/player/player.tscn | SpriteFrames | Intentional — real pixel art is Phase 2+ (NPC-04) |
| `take_damage()` has no health/lives system | scenes/player/player.gd | ~116 | Intentional — Phase 3 adds health system |

These stubs are intentional per RESEARCH.md and do not block plan goals. All plan objectives (dash, knockback, 6-state animation) are fully implemented.

## Threat Surface Scan

No new network endpoints, auth paths, or file access patterns introduced. Pure local game logic — no STRIDE concerns (confirmed per plan threat_model).

## Self-Check: PASSED

- [x] natalia_placeholder.svg exists at assets/sprites/player/natalia_placeholder.svg
- [x] player.tscn has SpriteFrames with 6 animations (03cb13f)
- [x] player.gd has _start_dash, take_damage, full _update_animation (5d41d68)
- [x] damage_trigger.gd exists with Area2D + take_damage call (e3f62ab)
- [x] test_movement.tscn has DamageTrigger node (e3f62ab)
- [x] test_movement.gd shows dashing/invincible/hurt in HUD (e3f62ab)
- Task 6 (checkpoint:human-verify) pending human approval
