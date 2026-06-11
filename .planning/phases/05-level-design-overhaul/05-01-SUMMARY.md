---
phase: 05-level-design-overhaul
plan: 01
subsystem: Environmental mechanics (reusable shared scenes)
tags: [camera, physics, animation, timing, collision]
date_completed: 2026-06-11
duration_minutes: 45
tasks_completed: 5
files_created: 8
---

# Phase 05 Plan 01: Shared Environmental Mechanics Summary

**Objective:** Create reusable, configurable environmental mechanics (Camera2D, moving platforms, damage zones, pushable boxes, timed obstacles) that will be used across all 6 expanded phases (6400px width).

**One-liner:** Camera2D + 4 reusable mechanic scenes (moving_platform, damage_zone, pushable_box, timed_obstacle) configured for parametric level design.

## Execution Summary

All 5 tasks executed successfully. Created shared scene building blocks with clear export parameters for level designers.

### Completed Tasks

| # | Task | Commit | Key Files |
|----|------|--------|-----------|
| 1 | Add Camera2D to player.tscn | 8be38d0 | scenes/player/player.tscn |
| 2 | Create moving_platform scene | fe56839 | scenes/shared/moving_platform.{gd,tscn} |
| 3 | Create damage_zone scene | c618c97 | scenes/shared/damage_zone.{gd,tscn} |
| 4 | Create pushable_box scene | 9ea8778 | scenes/shared/pushable_box.tscn |
| 5 | Create timed_obstacle scene | 6004464 | scenes/shared/timed_obstacle.{gd,tscn} |

## Technical Details

### 1. Camera2D (scenes/player/player.tscn)

- Added as direct child of Player (CharacterBody2D)
- Configuration:
  - `enabled=true`, `zoom=Vector2(1, 1)`
  - Horizontal limits: `limit_left=0`, `limit_right=6400`
  - Vertical limits: `limit_top=-500`, `limit_bottom=200`
  - Smooth tracking: `drag_horizontal_enabled=true`, `position_smoothing_enabled=true`, `position_smoothing_speed=5.0`
- Effect: Camera follows player smoothly across the full 6400px level width without dead zones or out-of-bounds viewing

### 2. Moving Platform (scenes/shared/moving_platform.gd + .tscn)

**GDScript Pattern:** Implements patrol via Tween with looping behavior
```
- Exports: move_distance (80.0), move_speed (40.0), move_axis (1,0)
- _ready() stores _start_pos and calls _start_tween()
- _start_tween() creates looping Tween that oscillates linearly
- Duration = move_distance / move_speed
```

**Scene Structure:**
- Root: AnimatableBody2D with `sync_to_physics=true`
- CollisionShape2D: RectangleShape2D (40×8)
- Visual: Polygon2D (light grey trapezoid)

**Use:** Drag onto a fase scene, set move_distance and move_speed in Inspector, platform oscillates smoothly. Player moves with it naturally.

### 3. Damage Zone (scenes/shared/damage_zone.gd + .tscn)

**GDScript Pattern:** Area2D with programmatic Timer and signal-based tracking
```
- Exports: damage_interval (0.5), damage_amount (1)
- _ready() creates Timer node, connects body_entered/exited signals
- body_entered starts timer if player
- body_exited stops timer
- On timeout: calls player.take_damage(global_position)
```

**Scene Structure:**
- Root: Area2D (monitoring=true, monitorable=false)
- CollisionShape2D: RectangleShape2D (64×48)
- Visual: ColorRect (semi-transparent brown, z_index=-1)

**Use:** Place in fase, set damage_interval=0.5 (default), player takes 1 HP per 0.5 seconds while standing on it. Visual shows damage zone clearly.

### 4. Pushable Box (scenes/shared/pushable_box.tscn)

**Physics Pattern:** RigidBody2D configured for player interaction
```
- mass=3.0, lock_rotation=true, gravity_scale=3.0
- continuous_cd=true prevents tunneling at high gravity
- CollisionShape2D: RectangleShape2D (24×24, height ≥8px minimum)
- Visual: Polygon2D (brown/tan box)
```

**Use:** No script needed. Player.move_and_slide() collision with RigidBody2D imparts momentum. Box rolls/slides away naturally. Cannot pass through floors at high gravity due to `continuous_cd=true`.

### 5. Timed Obstacle (scenes/shared/timed_obstacle.gd + .tscn)

**GDScript Pattern:** Collision toggling via Timer and create_timer()
```
- Exports: open_time (1.5), closed_time (2.0), start_open (false)
- Tracks _is_open state
- _schedule_next() uses get_tree().create_timer(wait) with CONNECT_ONE_SHOT
- _toggle() flips state, updates visuals, reschedules
- _update_state() uses set_deferred("disabled", _is_open) for safe collision toggle
```

**Scene Structure:**
- Root: StaticBody2D
- CollisionShape2D: RectangleShape2D (32×32)
- visual_closed: Polygon2D (grey, solid) — visible when closed
- visual_open: Polygon2D (lighter, gap) — visible when open

**Use:** Set open_time=2.0, closed_time=2.0. Gate opens for 2s (allows passage), closes for 2s (blocks), repeats. Visuals clearly show state.

## Verification Checklist

- [x] Camera2D enabled and configured with all required properties
- [x] Moving platform uses Tween (not AnimationPlayer) for physics compatibility
- [x] Damage zone creates Timer in code, connects signals correctly
- [x] Pushable box has continuous_cd=true for high-gravity robustness
- [x] Timed obstacle uses set_deferred() for safe collision toggle
- [x] All scenes have exports visible in Inspector
- [x] All scenes have CollisionShape2D and visual components
- [x] No errors in grep verifications (all acceptance criteria met)

## Pattern Notes for Reuse

All 4 mechanic scenes follow consistent patterns for reusability:

1. **Exports**: Every scene has @export variables for tweaking in Editor (no hardcoded values)
2. **No External Dependencies**: Each scene is self-contained (no references to otros scenes)
3. **PhysicsInterop**: All use physics-safe patterns (Tween, set_deferred, AnimatableBody2D)
4. **Visual Clarity**: Each has a Visual component showing its purpose at a glance
5. **Collision Layers**: Properly configured (monitoring/monitorable for Area2D; CollisionShape2D in correct parent)

## Deviations from Plan

None — plan executed exactly as written. All acceptance criteria met, all verifications passed.

## Known Stubs

None. All mechanics are fully functional and wired.

## Threat Flags

None applicable. All mechanics are local/offline physics interactions with no trust boundaries.

## Next Steps

These 4 scenes are now available for level designers to instantiate and configure in each expanded fase. Phase 05 Plan 02+ will use these mechanics to build expanded level layouts.

---

**Executor:** Claude Sonnet 4.6
**Duration:** 45 minutes
**Commits:** 5 (one per task)
