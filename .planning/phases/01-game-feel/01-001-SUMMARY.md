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
    - "pre_floor snapshot before move_and_slide, re-read after for accurate landing/coyote detection"
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
  - "CollisionShape2D size 20x30: leaves small margins inside 32x32 sprite to avoid wall-sticking"
  - "Coyote only set on falling-edge transition (pre_floor AND NOT is_on_floor AND NOT _jumped_this_frame): prevents multi-jump exploit"
  - "Coyote detection runs after move_and_slide: pre_floor captured before slide, transition checked after — correct per-frame accuracy"

patterns-established:
  - "Pattern: player.gd is the single physics authority — all velocity mutation lives here"
  - "Pattern: stub methods (_on_land, _update_animation) reserved for Plan 02/03 extensions"
  - "Pattern: debug HUD via CanvasLayer + Label reading runtime vars from player script"

requirements-completed: [MOVE-01]

# Metrics
duration: 70min
completed: 2026-05-21
---

# Phase 01 Plan 01: Core Movement Summary

**CharacterBody2D platformer controller with coyote time (6 frames), jump buffer (8 frames), asymmetric gravity (900/1600), and isolated test scene with ledge platform and live debug HUD — MOVE-01 human-verified approved**

## Performance

- **Duration:** ~70 min
- **Started:** 2026-05-21T08:44:59Z
- **Completed:** 2026-05-21T09:57:58Z
- **Tasks:** 4 of 4 complete (including checkpoint:human-verify — approved)
- **Files modified:** 6

## Accomplishments

- Full movement controller implemented: run (200px/s), asymmetric gravity (900 up/1600 down), variable jump height (cut multiplier 0.4)
- Coyote time: 6-frame window after walking off ledge, only activated on falling-edge transition (no multi-jump exploit)
- Jump buffer: 8-frame window before landing to queue jump
- 4 InputMap actions added to project.godot: walk_left/walk_right/jump/dash with QWERTY + non-QWERTY support (physical_keycode for letter keys)
- Isolated test scene with MainFloor + LedgePlatform (for coyote testing) + live debug HUD showing vel/coyote/jump_buf
- Human checkpoint passed: all MOVE-01 success criteria verified in Godot editor — run, jump, coyote (6 frames), jump buffer (8 frames), and variable jump height all confirmed working

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
4. **Task 4: Human checkpoint** - approved; no code commit (human verified in Godot editor)

**Post-task-3 bug fix commits (applied before checkpoint):**
- `473362a` — Removed invalid PackedVector2Array sub_resources from test_movement.tscn (scene parse error)
- `e572486` — Removed type annotation on player var in HUD script (cross-script _ var access requires untyped)
- `55fc0c8` — Fixed Color values to use 4 components (RGBA) in test_movement.tscn
- `4aca4ae` — Fixed coyote time detection to run after move_and_slide (was before, breaking floor-state accuracy)

**Plan checkpoint metadata:** `baff373` (docs: complete core-movement plan)

## Files Created/Modified

- `project.godot` — Added [input] section with walk_left/walk_right/jump/dash actions (physical_keycode for A/D/W/K, keycode for SPACE/SHIFT/arrows)
- `scenes/player/player.gd` — CharacterBody2D movement controller (coyote + buffer + asymmetric gravity + jump cut); stubs for _on_land and _update_animation
- `scenes/player/player.tscn` — Player scene: CharacterBody2D + AnimatedSprite2D (no SpriteFrames yet) + CollisionShape2D 20x30
- `scenes/test_movement/test_movement.tscn` — Test scene: MainFloor + LedgePlatform (y=110) + Player instance + HUD CanvasLayer
- `scenes/test_movement/test_movement.gd` — Debug HUD reading player._coyote_timer/_jump_buffer_timer
- `assets/sprites/player/.gitkeep` — Directory placeholder until Plan 02 adds sprite sheet

## Decisions Made

- Frame counters (integers) over Timer nodes for coyote/buffer: simpler, no node overhead, perfectly in sync with _physics_process at 60 Hz
- `sprite_frames` null-guard in `_update_animation`: AnimatedSprite2D has no SpriteFrames yet (Plan 02 adds them), guard prevents editor crash
- CollisionShape2D size 20x30: small margins inside 32x32 sprite to avoid wall-sticking behavior
- Coyote timer only set on falling-edge: `_was_on_floor AND NOT is_on_floor() AND NOT _jumped_this_frame` — prevents multi-jump exploit at ledge edges

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Coyote time detection ran before move_and_slide**
- **Found during:** Task 3 (testing coyote behavior on ledge)
- **Issue:** Initial implementation checked the floor-state transition before calling `move_and_slide()`. The `is_on_floor()` result reflected the previous frame, making walk-off detection unreliable at ledge edges.
- **Fix:** Captured `pre_floor := is_on_floor()` before `move_and_slide()`, then checked the transition `pre_floor AND NOT is_on_floor()` after the slide. This gives accurate per-frame floor state.
- **Files modified:** `scenes/player/player.gd`
- **Verification:** Coyote HUD value counts 6→0 correctly when walking off LedgePlatform; human checkpoint confirmed
- **Committed in:** `4aca4ae`

**2. [Rule 1 - Bug] Invalid PackedVector2Array sub_resources in test_movement.tscn**
- **Found during:** Task 3 (scene validation)
- **Issue:** Generated .tscn file contained malformed PackedVector2Array sub_resource blocks that Godot 4 rejects on parse.
- **Fix:** Removed invalid sub_resource blocks; Polygon2D polygon data is stored inline in node properties, not as sub_resources.
- **Files modified:** `scenes/test_movement/test_movement.tscn`
- **Committed in:** `473362a`

**3. [Rule 1 - Bug] Type annotation on cross-script variable access**
- **Found during:** Task 3 (HUD script)
- **Issue:** `var player: Player = $"../Player"` failed — GDScript requires untyped access to `_`-prefixed vars on CharacterBody2D instances across scripts.
- **Fix:** Removed `: Player` type annotation; `var player = $"../Player"` works correctly for duck-typed debug access.
- **Files modified:** `scenes/test_movement/test_movement.gd`
- **Committed in:** `e572486`

**4. [Rule 1 - Bug] Color constructor required 4 components**
- **Found during:** Task 3 (scene parse)
- **Issue:** Color values in .tscn were written as `Color(0.3, 0.3, 0.35)` — Godot 4 .tscn serialization requires `Color(r, g, b, a)` with alpha.
- **Fix:** Added alpha=1.0 to all Color() calls in the scene file.
- **Files modified:** `scenes/test_movement/test_movement.tscn`
- **Committed in:** `55fc0c8`

---

**Total deviations:** 4 auto-fixed (all Rule 1 bugs)
**Impact on plan:** All fixes required for scene to parse and coyote time to function correctly. No scope creep.

The TDD marker on Task 2 was honored via spec-driven development: the `<behavior>` block defined the expected behaviors, implementation was written to satisfy them exactly. No automated test framework exists (per RESEARCH.md: "test scene IS the test suite").

## Known Stubs

- `_on_land()` in `player.gd` — empty pass; Plan 02 (juice effects) adds `_apply_land_squash()` and `dust_particles.restart()` here
- `_update_animation()` — only handles idle/run/jump/fall states; Plan 02 adds hurt/death states

Both stubs are intentional and documented. They do not prevent the plan's goal (MOVE-01 observable behaviors) from being achieved.

## Issues Encountered

- GDScript does not allow typed access to `_`-prefixed vars on a node reference typed as a custom class — switched to untyped `var player` in HUD script. This is idiomatic for debug scripts accessing runtime state.
- Godot 4 .tscn format requires exact serialization: Color needs 4 components, Polygon2D polygon data is inline not a sub_resource. These are format constraints, not logic issues.
- Coyote time requires the floor-state check to happen after `move_and_slide()`, not before — the pre/post capture pattern is now documented in player.gd comments for future maintainers.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

**Plan 02 (dash + knockback + animations) can start immediately:**
- `player.gd` is structured for extension: `_on_land()` and `_update_animation()` are stubs with clear extension points; physics loop order documented in comments
- `player.tscn` has AnimatedSprite2D in place; only SpriteFrames resource is missing (Plan 02 adds sprite sheet)
- All 4 InputMap actions are defined; `dash` action is wired and ready in project.godot
- Plan 02 inserts dash state between horizontal movement and jump execution — no physics loop restructuring needed

**Tuning note:** `coyote_frames` was bumped from 6 to 8 during the human checkpoint via the Inspector (set in `test_movement.tscn` Player instance). The player.gd default remains 6 — the override in the test scene reflects the felt result. Plan 02 should evaluate whether to update the default in player.gd.

**Renderer constraint:** GL Compatibility renderer is active — GPU particles will fail silently. Plan 03 juice effects must use CPUParticles2D, not GPUParticles2D.

---
*Phase: 01-game-feel*
*Completed: 2026-05-21*
