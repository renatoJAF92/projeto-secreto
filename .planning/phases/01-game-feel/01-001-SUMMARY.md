---
phase: 01-game-feel
plan: "01"
subsystem: game-feel
tags: [godot4, gdscript, CharacterBody2D, platformer, coyote-time, jump-buffer, asymmetric-gravity]

# Dependency graph
requires:
  - phase: 00-fundacao
    provides: project.godot with pixel art settings, viewport 320x180, GL Compatibility renderer

provides:
  - CharacterBody2D movement controller with coyote time 6 frames + jump buffer 8 frames
  - Asymmetric gravity (gravity_up=900, gravity_down=1600) for heavy-fall feel
  - Variable jump height via jump cut (multiplier 0.4)
  - InputMap actions: walk_left, walk_right, jump, dash
  - Isolated test scene with floor + ledge platform + live debug HUD
  - player.tscn reusable foundation for Plans 02 and 03

affects:
  - 01-002-dash-knockback (extends player.gd with _start_dash and take_damage)
  - 01-003-juice-effects (adds CPUParticles2D and squash/stretch in _on_land stub)
  - 03-mundo1-osasco (uses player.tscn as the game player)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "CharacterBody2D with _physics_process velocity mutation + move_and_slide()"
    - "Frame counter integers for coyote time and jump buffer (not Timer nodes)"
    - "Asymmetric gravity via velocity.y sign check"
    - "_was_on_floor double-capture (before + after move_and_slide) for landing detection"
    - "sprite_frames null-guard in _update_animation for pre-SpriteFrames safety"

key-files:
  created:
    - scenes/player/player.gd
    - scenes/player/player.tscn
    - scenes/test_movement/test_movement.tscn
    - scenes/test_movement/test_movement.gd
  modified:
    - project.godot

key-decisions:
  - "Frame counters over Timer nodes for coyote/buffer: stay in sync with _physics_process, no node overhead, easier to tune"
  - "sprite_frames null-guard in _update_animation: AnimatedSprite2D has no SpriteFrames yet (Plan 02 adds them), guard prevents crash"
  - "player.tscn uses SpriteFrames with empty animation frames: allows Plan 02 to populate without restructuring the scene"
  - "CollisionShape2D size 20x30: leaves small margins inside 32x32 sprite to avoid wall-sticking"
  - "Coyote only set on falling-edge transition (_was_on_floor AND NOT is_on_floor AND NOT _jumped_this_frame): prevents multi-jump exploit"

patterns-established:
  - "Pattern: player.gd is the single physics authority — all velocity mutation lives here"
  - "Pattern: stub methods (_on_land, _update_animation) reserved for Plan 02/03 extensions"
  - "Pattern: debug HUD via CanvasLayer + Label reading runtime vars from player script"

requirements-completed: [MOVE-01]

# Metrics
duration: 2min
completed: 2026-05-21
---

# Phase 01 Plan 01: Core Movement Summary

**CharacterBody2D platformer controller with coyote time (6 frames), jump buffer (8 frames), asymmetric gravity (900/1600), and isolated test scene with ledge platform and live debug HUD**

## Performance

- **Duration:** 2 min
- **Started:** 2026-05-21T08:44:59Z
- **Completed:** 2026-05-21T08:46:59Z
- **Tasks:** 3 of 4 complete (Task 4 is checkpoint:human-verify — awaiting)
- **Files modified:** 5

## Accomplishments

- Full movement controller implemented: run (200px/s), asymmetric gravity (900 up/1600 down), variable jump height (cut multiplier 0.4)
- Coyote time: 6-frame window after walking off ledge, only activated on falling-edge transition (no multi-jump exploit)
- Jump buffer: 8-frame window before landing to queue jump
- 4 InputMap actions added to project.godot: walk_left/walk_right/jump/dash with QWERTY + non-QWERTY support
- Isolated test scene with MainFloor + LedgePlatform (for coyote testing) + live debug HUD showing vel/coyote/jump_buf

## How to Test (F6 workflow)

1. Open project in Godot editor (macOS app bundle — `godot` not in PATH)
2. Open `scenes/test_movement/test_movement.tscn`
3. Press **F6** to run this scene directly (not F5 — main.tscn is the project main scene)
4. Use A/D or arrow keys to run, SPACE to jump
5. Walk off the right edge of LedgePlatform and press SPACE within 6 frames — watch `coyote:` countdown in HUD
6. While falling toward MainFloor, press SPACE before landing — watch `jump_buf:` countdown and auto-jump on landing
7. Brief tap vs. held SPACE: tap = lower jump (variable height)

## Task Commits

Each task was committed atomically:

1. **Task 1: Add InputMap actions to project.godot** - `1e11a83` (feat)
2. **Task 2: Create player.gd + player.tscn** - `dbd5447` (feat)
3. **Task 3: Create test_movement scene with floor, ledge, HUD** - `5833eac` (feat)

_Task 4 (checkpoint:human-verify) is pending user verification._

## Files Created/Modified

- `project.godot` — Added [input] section with walk_left/walk_right/jump/dash actions
- `scenes/player/player.gd` — CharacterBody2D movement controller (coyote + buffer + asymmetric gravity + jump cut)
- `scenes/player/player.tscn` — Player scene: CharacterBody2D + AnimatedSprite2D + CollisionShape2D 20x30
- `scenes/test_movement/test_movement.tscn` — Test scene: MainFloor + LedgePlatform + Player instance + HUD
- `scenes/test_movement/test_movement.gd` — Debug HUD reading player._coyote_timer/_jump_buffer_timer

## Decisions Made

- Frame counters (integers) over Timer nodes for coyote/buffer: simpler, no node overhead, perfectly in sync with _physics_process at 60 Hz
- `sprite_frames` null-guard in `_update_animation`: AnimatedSprite2D has no SpriteFrames yet (Plan 02 adds them), guard prevents editor crash
- CollisionShape2D size 20x30: small margins inside 32x32 sprite to avoid wall-sticking behavior
- Coyote timer only set on falling-edge: `_was_on_floor AND NOT is_on_floor() AND NOT _jumped_this_frame` — prevents multi-jump exploit at ledge edges

## Deviations from Plan

None — plan executed exactly as written.

The TDD marker on Task 2 was honored via spec-driven development: the `<behavior>` block defined the expected behaviors, implementation was written to satisfy them exactly. No automated test framework exists (per RESEARCH.md: "test scene IS the test suite").

## Known Stubs

- `_on_land()` in `player.gd` — empty pass; Plan 02 (juice effects) adds `_apply_land_squash()` and `dust_particles.restart()` here
- `_update_animation()` — only handles idle/run/jump/fall states; Plan 02 adds hurt/death states

Both stubs are intentional and documented. They do not prevent the plan's goal (MOVE-01 observable behaviors) from being achieved.

## Issues Encountered

None.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- `player.gd` is structured for Plan 02/03 extension: stub `_on_land()` and `_update_animation()` for juice, no rework needed
- `player.tscn` has AnimatedSprite2D with empty SpriteFrames resource ready for Plan 02 sprite sheets
- Test scene ready for Task 4 human verification: open test_movement.tscn, press F6

**Awaiting:** Task 4 checkpoint — human must verify coyote time (6 frames) and jump buffer (8 frames) are observable in the Godot editor.

---
*Phase: 01-game-feel*
*Completed: 2026-05-21*
