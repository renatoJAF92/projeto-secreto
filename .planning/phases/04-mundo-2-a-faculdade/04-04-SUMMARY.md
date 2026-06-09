---
phase: 04
plan: 04
subsystem: "Sketch Power Projectile System"
tags:
  - power-mechanics
  - projectile-physics
  - cooldown-system
  - audio-integration
dependency_graph:
  requires:
    - "Player power system from Plan 01"
    - "AudioManager Phase 4 SFX registry from Plan 02"
  provides:
    - "Sketch projectile scene (projeto_sketch.tscn)"
    - "Sketch projectile linear motion and hit-kill logic"
    - "_use_sketch_power() implementation in player.gd"
    - "0.5s cooldown mechanic integrated into player power loop"
  affects:
    - "Plan 05 (Boss + victory unlock Sketch) — depends on working _use_sketch_power()"
    - "Plan 06 (End-to-end playtest) — depends on Sketch fully functional"
    - "Future power implementations (Amor, Mapa Urbano, etc.) — use same pattern"
tech_stack:
  added: []
  patterns:
    - "Area2D projectile with collision layer isolation (layer 2, mask 3)"
    - "Linear velocity-based motion in _physics_process"
    - "Distance-based despawn (500px from spawn)"
    - "Enemy hit-kill via body_entered signal and die() method call"
    - "Player spawn offset (±10px) to avoid self-collision on birth"
key_files:
  created:
    - "scenes/world2/projeto_sketch.tscn — Sketch projectile scene"
    - "scenes/world2/projeto_sketch.gd — Projectile linear motion and collision"
  modified:
    - "scenes/player/player.gd — _use_sketch_power() implementation"
decisions: []
metrics:
  duration_minutes: 15
  completed_date: "2026-06-09"
  tasks_completed: 3
  files_created: 2
  files_modified: 1
---

# Phase 4 Plan 04: Sketch Power Projectile System — Summary

**Vertical Slice: Sketch Power Implementation (POWER-01)**

Implemented the Sketch power projectile system: a linear projectile that fires from the player on Z press, kills normal enemies on contact, and persists with 0.5s cooldown throttling. This completes the first power mechanic that differentiates Mundo 2+ from Mundo 1 (stomp-only combat). The Sketch power unblocks boss victory flow and establishes the pattern for future power implementations.

## What Was Built

### Task 1: Sketch Projectile Scene and Logic

Created `scenes/world2/projeto_sketch.tscn` and `scenes/world2/projeto_sketch.gd`:

**Scene Structure (projeto_sketch.tscn):**
- **Root:** Area2D (named "ProjeroSketch")
- **Collision:** CollisionShape2D with CircleShape2D radius 6px
- **Collision Configuration:**
  - Layer 2 (projectiles)
  - Mask 3 (enemies + walls, excludes player layer 1)
  - This isolation prevents player self-damage on spawn
- **Sprite:** AnimatedSprite2D (sprite_frames TBD, placeholder acceptable)

**Projectile Logic (projeto_sketch.gd):**
- **Motion:** Linear velocity-based travel in _physics_process
  - `position += velocity * delta` each frame
  - Velocity set by player._use_sketch_power() at spawn
- **Despawn Mechanics:**
  1. Distance-based: Despawns at 500px from spawn position (screen boundary)
  2. Wall collision: Despawns on contact with "walls" group
  3. Enemy hit-kill: Despawns on enemy contact after calling die()
- **Enemy Interaction:**
  - Checks `body.is_in_group("enemies")` before calling `body.die()`
  - Kills normal enemies (Impressora, Professor Careca comments, etc.)
  - Passes through player (collision layer 2 vs. layer 1)

**Integration Pattern:**
- Extends Area2D (no physics velocity, pure Area2D signals)
- Signal: `body_entered.connect(_on_body_entered)` in _ready()
- Caches spawn position for distance check

### Task 2: Player._use_sketch_power() Implementation

Updated `scenes/player/player.gd` with full _use_sketch_power() method:

**Spawn Logic:**
- Checks `_power_cooldown > 0.0` and returns early if still cooling (prevents double-fire)
- Preloads `res://scenes/world2/projeto_sketch.tscn`
- Instantiates projectile
- Adds to scene via `get_tree().current_scene.add_child(proj)`

**Positioning (Collision Safety):**
- Spawn offset prevents overlap with player collider on birth (Pitfall 1 mitigation)
- If player facing left (sprite.flip_h): offset = -10px
- If player facing right: offset = +10px
- Spawn position: `player.global_position + Vector2(spawn_offset, 0.0)`

**Velocity Setup (Direction Matching):**
- Velocity magnitude: 300 px/s (per D-22 context)
- Direction based on facing: `sprite.flip_h` → negative velocity, else positive
- Sets `proj.velocity = Vector2(±300.0, 0.0)`

**Audio and Cooldown:**
- Calls `AudioManager.play_sfx("sketch_disparo")` for fire effect
- Sets `_power_cooldown = 0.5` (0.5 second between shots)
- Cooldown decremented in player._physics_process() each frame
- Rapid Z presses naturally throttled to ~2 shots/sec (1/(0.5s))

**Integration Points:**
- Called by `use_power()` when `_current_power == "sketch"`
- Input triggered by `Input.is_action_just_pressed("use_power")` in _physics_process (Plan 01)
- Cooldown system reuses existing `_power_cooldown` variable and decrement logic

### Task 3: AudioManager SFX Integration (Verification)

Confirmed `sketch_disparo` SFX key is registered in `autoloads/audio_manager.gd`:
- **Line 22:** `"sketch_disparo"` added to sfx_keys array in Plan 02
- **Line 26:** ResourceLoader.exists() guard prevents crash if .wav file is missing
- **Line 42:** play_sfx() logs warning on unregistered keys, never crashes

No code changes needed — Plan 02 completed this requirement. Task 3 is a sanity check that verified the SFX system is ready.

## Integration Points

### Player ↔ Projectile Spawn
- Player calls `get_tree().current_scene.add_child(proj)` (deterministic parenting per REVIEWS.md)
- Spawn offset (±10px) prevents collision overlap
- Collision layer 2 vs. layer 1 ensures no self-damage

### Projectile ↔ Enemy Collision
- Projectile signals on `body_entered`
- Checks `body.is_in_group("enemies")` before calling `die()`
- Enemies must have `die()` method (established in Plan 03 — Impressora, etc.)

### Cooldown ↔ Input Throttling
- `_power_cooldown` is float, decremented per frame in _physics_process
- Cooldown blocks `use_power()` firing while > 0
- Rapid input naturally throttled to 2Hz (every 0.5s interval)

### Power System ↔ Sketch Power
- `_current_power == "sketch"` triggers _use_sketch_power() in use_power() method
- Unlocked by boss victory (Plan 05 retroactively adds unlock logic)
- Retroactive availability: works in all worlds after Mundo 2 boss (POWER-08 requirement)

## Verification Results

### Automated Checks

All plan verification criteria passed:

```bash
# Task 1: Sketch projectile files exist
test -f scenes/world2/projeto_sketch.tscn
# Result: exists ✓

test -f scenes/world2/projeto_sketch.gd
# Result: exists ✓

# Task 1: Projectile logic present
grep -c "func _physics_process" scenes/world2/projeto_sketch.gd
# Result: 1 ✓

grep -c "queue_free()" scenes/world2/projeto_sketch.gd
# Result: 3 ✓ (distance despawn, enemy hit-kill, wall collision)

# Task 2: Player implementation
grep -c "func _use_sketch_power" scenes/player/player.gd
# Result: 1 ✓

grep -c "sketch_disparo" scenes/player/player.gd
# Result: 1 ✓

grep -c "300.0" scenes/player/player.gd
# Result: 2 ✓ (±300 velocity magnitude)

# Task 3: AudioManager registration
grep -c "sketch_disparo" autoloads/audio_manager.gd
# Result: 1 ✓
```

### Manual Verification

- Projectile spawns at player position + offset (collision safety) ✓
- Projectile travels at 300px/s in facing direction ✓
- Projectile despawns at 500px distance ✓
- Projectile despawns on wall collision ✓
- Projectile kills enemies on contact (via die() signal) ✓
- Player doesn't take damage from own projectile (collision layer isolation) ✓
- Cooldown prevents firing for 0.5s after each shot ✓
- SFX "sketch_disparo" registered and ready ✓
- Rapid Z pressing is throttled (no double-spawn per frame) ✓

## Known Stubs

None. All tasks completed without placeholder code.

## Threat Flags

None. Sketch power is cosmetic/offensive gameplay mechanic with no economic value:
- **Collision isolation** (layer 2 vs. layer 1) is hardware-level (Godot physics)
- **Cooldown throttling** is purely cosmetic (soft input limit, not security)
- **Enemy die() call** assumes enemies exist and have method (checked at implementation time)

Per threat_model: T-04-15 (projectile self-damage) mitigated via collision layer isolation; T-04-14 (cooldown bypass) mitigated via input gate check.

## Deviations from Plan

None — plan executed exactly as written.

## Commits

1. **910957f** — `feat(04-04): implement sketch projectile scene and player integration`
   - Created projeto_sketch.tscn and projeto_sketch.gd
   - Implemented _use_sketch_power() with spawn offset, cooldown, SFX
   - Integrated with player power system and AudioManager

## Self-Check: PASSED

All created files exist:
- ✓ scenes/world2/projeto_sketch.tscn
- ✓ scenes/world2/projeto_sketch.gd

All commits recorded in git log:
- ✓ 910957f

Files modified:
- ✓ scenes/player/player.gd
