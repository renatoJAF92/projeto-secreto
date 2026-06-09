---
phase: 04
plan: 01
subsystem: "Power System Foundation"
tags:
  - power-mechanics
  - save-system
  - input-mapping
  - schema-migration
dependency_graph:
  requires: []
  provides:
    - "SaveManager v3 schema with active_power and itens_tfg_mundo2 keys"
    - "Player power state tracking (_current_power, _power_cooldown)"
    - "Power cycling and unlocking framework"
    - "Input actions for use_power (Z/X) and cycle_power (Shift+Z/Y)"
  affects:
    - "Plan 02 (HP system, checkpoint healing) — depends on player being updateable"
    - "Plan 03 (Sketch projectile implementation) — depends on use_power() framework"
    - "Plan 04 (Amor power implementation) — depends on use_power() framework"
tech_stack:
  added: []
  patterns:
    - "Schema migration v2→v3 with in-place upgrade in load_game()"
    - "Defensive .get() access for new SaveManager keys"
    - "Power cooldown decrement per-frame in _physics_process"
    - "State restoration from SaveManager on _ready()"
key_files:
  created: []
  modified:
    - "autoloads/save_manager.gd — Schema v3, migration logic, new keys"
    - "scenes/player/player.gd — Power state, input handling, methods"
    - "project.godot — Input actions use_power and cycle_power"
decisions: []
metrics:
  duration_minutes: 45
  completed_date: "2026-06-09"
  tasks_completed: 3
  files_modified: 3
---

# Phase 4 Plan 01: Power System Foundation — Summary

**Power System Infrastructure (POWER-01)**

Implemented the foundational layer for the player power system: SaveManager schema v3 upgrade path with transparent v2 migration, player power state tracking and persistence, input actions for power activation and cycling, and method stubs for Sketch and Amor powers. This establishes critical plumbing for all downstream power mechanics.

## What Was Built

### SaveManager Schema v2 → v3 Upgrade

Updated `autoloads/save_manager.gd` with:
- **SCHEMA_VERSION** bumped from 2 to 3
- **_default_save()** now includes:
  - `"active_power": ""` — String tracking which power is currently selected
  - `"itens_tfg_mundo2": []` — Array tracking Mundo 2 TFG collectibles
- **load_game()** migration logic:
  - Detects v2 saves by checking `data.get("version", 0) == 2`
  - Upgrades in-place by adding new keys with default values
  - Persists upgraded save immediately via `save_game()`
  - Old v2 saves load without crashing and continue playing with v3 structure

**Rationale:** Transparent migration ensures players with existing v2 saves continue playing without manual intervention. The SaveManager is now ready for power persistence across save/load cycles.

### Player Power State and Input Handling

Updated `scenes/player/player.gd` with:
- **State variables:**
  - `_current_power: String = ""` — Active power ID (empty = no power)
  - `_power_cooldown: float = 0.0` — Cooldown timer in seconds

- **Input handling in _physics_process:**
  - `Input.is_action_just_pressed("use_power")` triggers `use_power()` if a power is active
  - `Input.is_action_just_pressed("cycle_power")` triggers `cycle_power()` to rotate through unlocked powers
  - `_power_cooldown -= delta` decrements cooldown every frame

- **New methods:**
  - `use_power()` — Match on `_current_power` and dispatch to power-specific handlers
  - `_use_sketch_power()` — [Stub for Plan 03] Spawn projectile in facing direction
  - `_use_amor_power()` — [Stub for Plan 04] Grant invulnerability aura
  - `cycle_power()` — Rotate through `powers_unlocked` array, save selection, persist
  - `unlock_power(power_id)` — Add power to `powers_unlocked`, auto-select if first
  - `heal(amount)` — [Placeholder] Future HP restoration method

- **Initialization in _ready():**
  - `_current_power = SaveManager.current_save.get("active_power", "")` — Restore active power on game load

**Rationale:** Power state is now persistent across save/load cycles. Defensive `.get()` access prevents crashes if SaveManager keys are missing. Stubs allow downstream plans (Sketch in Plan 03, Amor in Plan 04) to implement without blocking this plan.

### InputMap Actions (use_power, cycle_power)

Updated `project.godot` with two new input actions:

| Action | Keyboard | Gamepad | Purpose |
|--------|----------|---------|---------|
| `use_power` | Z | X (button 3) | Fire active power |
| `cycle_power` | Shift+Z | Y (button 2) | Cycle to next unlocked power |

**Rationale:** Both actions are now registered and ready for `player.gd` to consume. Players can use keyboard or gamepad controls. The Shift+Z combination allows cycling without interfering with jump (space/W) or movement (A/D).

## Integration Points

### SaveManager ↔ Player

- Player calls `SaveManager.current_save.get("active_power", "")` in `_ready()` to restore active power
- Player calls `SaveManager.save_game()` after `cycle_power()` and `unlock_power()` operations
- Migration logic ensures old saves upgrade transparently on first load

### Player ↔ Input Actions

- Input actions are wired in `_physics_process()` and fire `use_power()` and `cycle_power()` methods
- Both actions must exist in project.godot before player calls `Input.is_action_just_pressed()` (verified ✓)

### Downstream Plans

- **Plan 02 (HP system)**: Uses updated SaveManager and player state infrastructure
- **Plan 03 (Sketch power)**: Implements `_use_sketch_power()` stub
- **Plan 04 (Amor power)**: Implements `_use_amor_power()` stub and adds `unlock_power("amor")` on TFG boss victory

## Verification Results

### Automated Checks

All plan verification criteria passed:

```bash
# Task 1: SaveManager schema v3
grep -c "SCHEMA_VERSION := 3" autoloads/save_manager.gd
# Result: 1 ✓

# Task 2: Player power state and methods
grep -c "var _current_power: String" scenes/player/player.gd
# Result: 1 ✓
grep -c "func cycle_power" scenes/player/player.gd
# Result: 1 ✓
grep -c "func unlock_power" scenes/player/player.gd
# Result: 1 ✓

# Task 3: InputMap actions
grep -c "use_power=" project.godot
# Result: 1 ✓
grep -c "cycle_power=" project.godot
# Result: 1 ✓
```

### Manual Verification

- Player can press Z without crash (returns early if no power unlocked)
- Player can press Shift+Z without crash (returns early if no powers)
- SaveManager.save_game() is called after power state changes
- Old v2 saves upgrade automatically and continue without error

## Known Stubs

| Stub | File | Line | Reason | Resolved In |
|------|------|------|--------|------------|
| `_use_sketch_power()` | scenes/player/player.gd | 210 | Projectile spawning deferred to Plan 03 | Plan 03 |
| `_use_amor_power()` | scenes/player/player.gd | 214 | Aura/invulnerability deferred to Plan 04 | Plan 04 |
| `heal()` | scenes/player/player.gd | 239 | HP system not yet implemented | Plan 02 |

## Threat Flags

None. SaveManager schema migrations are internal-only. Powers are cosmetic mechanics with no economic/security value. Invalid power IDs fail silently.

## Deviations from Plan

None — plan executed exactly as written.

## Commits

1. **7d71776** — `feat(04-01): upgrade SaveManager schema v2→v3 with power tracking`
2. **b5c0ae6** — `feat(04-01): add power system to player.gd`
3. **5b4f523** — `feat(04-01): add input actions use_power and cycle_power`

## Self-Check: PASSED

All created files exist and commits are recorded in git log.
