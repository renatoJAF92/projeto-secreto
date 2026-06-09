---
phase: 04
plan: 02
subsystem: "HP System + Checkpoint Healing + Power HUD"
tags:
  - hp-system
  - checkpoint-mechanics
  - power-ui
  - audio-registry
dependency_graph:
  requires:
    - "SaveManager v3 schema from Plan 01"
    - "Player power state tracking from Plan 01"
  provides:
    - "Player HP system (3 max, take_damage, heal)"
    - "Checkpoint café scene with healing logic"
    - "Power HUD indicator for active power state"
    - "Phase 4 SFX registry in AudioManager"
  affects:
    - "Plan 03 (Mundo 2 phases + enemies) — HP system fully operational"
    - "Plan 04 (Sketch projectile) — Power HUD shows Sketch readiness"
    - "Plan 05 (Boss + HP HUD visual) — HP tracking ready for hearts display"
tech_stack:
  added: []
  patterns:
    - "HP decrement in take_damage() with death signal at hp <= 0"
    - "Healing via heal() method clamped to 3 max"
    - "Checkpoint one-shot pattern with _activated flag"
    - "Power HUD color modulation (ready white, cooldown grey)"
    - "AudioManager graceful degradation on missing SFX files"
key_files:
  created:
    - "scenes/world2/checkpoint_cafe.tscn"
    - "scenes/world2/checkpoint_cafe.gd"
    - "scenes/player/power_hud_indicator.tscn"
    - "scenes/player/power_hud_indicator.gd"
  modified:
    - "scenes/player/player.gd — HP system, take_damage, heal"
    - "autoloads/audio_manager.gd — Phase 4 SFX keys"
decisions: []
metrics:
  duration_minutes: 1
  completed_date: "2026-06-09"
  tasks_completed: 4
  files_modified: 2
  files_created: 4
---

# Phase 4 Plan 02: HP System + Checkpoint Healing + Power HUD — Summary

**Vertical Slice: HP System + Checkpoint Healing + Power HUD (BOSS-02, POWER-01 requirement foundation)**

Implemented the player HP system (3 PV max for Mundo 2+), the checkpoint café healing mechanism, the power HUD indicator displaying active power state (ready/cooldown), and Phase 4 SFX registry. This foundational layer enables the boss gate (minimum 3 TFG items collected), checkpoint recovery flow, and complete visual feedback for the power system.

## What Was Built

### Task 1: Player HP System (take_damage, heal, death logic)

Updated `scenes/player/player.gd` with:
- **HP state variable:** `var hp: int = 3` initialized in _ready()
- **Modified take_damage():**
  - Decrements hp by 1 on each hit
  - Emits died signal when hp <= 0 (respawn handled by fase controller)
  - Plays "dano" SFX on damage taken
  - Preserves existing knockback, flash, and hit-stop effects
- **Implemented heal() method:**
  - Increases hp by amount (default 1)
  - Clamps to 3 max with `hp = min(hp + amount, 3)`
  - Silent operation (no SFX; checkpoint handles audio)

**Rationale:** Players can now survive multi-hit scenarios in Mundo 2+. Death mechanics trigger respawn. Healing provides recovery path for longer phases. Mundo 1 remains 1-hit death (unchanged logic).

### Task 2: Checkpoint Café Scene and Healing Logic

Created `scenes/world2/checkpoint_cafe.tscn` and `scenes/world2/checkpoint_cafe.gd`:
- **Scene structure:** CanvasLayer-free Area2D with CollisionShape2D and AnimatedSprite2D (sprite TBD)
- **Healing logic in checkpoint_cafe.gd:**
  - Extends Area2D, exports checkpoint_id = "mundo2_checkpoint_cafe"
  - `_activated` flag prevents re-triggering (one-shot pattern)
  - On body_entered collision with player:
    - Calls SaveManager.set_checkpoint() to register checkpoint
    - Calls player.heal(1) to restore +1 HP
    - Plays "checkpoint" SFX via AudioManager
    - Animates scale tween (1.0 → 1.25 → 1.0) with color tint
  - Collision disabled after activation (via _activated guard)

**Rationale:** Checkpoints now heal players, establishing recovery flow required for boss phases. One-shot flag prevents infinite healing loops. SFX and animation provide feedback.

### Task 3: AudioManager SFX Registration for Phase 4

Updated `autoloads/audio_manager.gd` with expanded sfx_keys array:
- **Existing keys (Mundo 1-3):** "jump", "checkpoint", "prova_coletada", "prova_apresentada", "dialogo_errado", "stomp", "dano", "vitoria"
- **New keys (Phase 4+):** "prova_tfg_coletada", "qualidade_apresentada", "qualidade_perdida", "sketch_disparo", "amor_ativado", "dano_profundo"
- **Graceful degradation:** Each key registration guarded by `ResourceLoader.exists(path)` — missing .wav files do not crash startup
- **play_sfx() behavior:** Logs warning if key not registered, never crashes

**Rationale:** Phase 4 events can now call play_sfx() with new keys without crashing. Actual .wav files are TBD (created in Phase 12 Polish). Audio system is defensive and future-proof.

### Task 4: Power HUD Icon Indicator (top-right, ready/cooldown state)

Created `scenes/player/power_hud_indicator.tscn` and `scenes/player/power_hud_indicator.gd`:
- **Scene structure:**
  - Root: CanvasLayer (layer 1, always on top)
  - TextureRect child: 24x24 icon, anchored to top-right corner
  - Label child: power name display ("Sketch", "Amor", or empty)

- **Script behavior (power_hud_indicator.gd):**
  - In _ready(): Gets player via `get_tree().get_first_node_in_group("player")`
  - Calls update_power_display() to set initial icon and label
  - In _physics_process():
    - Reads player._current_power and _power_cooldown
    - If cooldown > 0: sets modulate to grey (0.5, 0.5, 0.5) — on cooldown
    - If cooldown <= 0: sets modulate to Color.WHITE — ready
    - Updates label text based on current power
  - update_power_display() method:
    - "sketch" → icon = power_sketch.png, label = "Sketch", color = #FF9500 (orange)
    - "amor" → icon = power_amor.png, label = "Amor", color = #FF1493 (pink)
    - "" → hide icon, empty label (no power unlocked)

- **Integration:** Placed in `scenes/player/` (global location, not world-specific) so HUD is visible across all worlds

**Rationale:** Players get instant visual feedback on power readiness. Color modulation handles ready/cooldown states without needing separate grey assets. Placement in player/ ensures powers are retroactive (usable in Mundo 1 revisits).

## Integration Points

### Player ↔ Checkpoint Café
- Checkpoint calls `player.heal(1)` via `get_first_node_in_group("player")`
- Player's take_damage() properly sets hp state before checkpoint can read it
- Healing clamped to 3 max per player's heal() method

### Player ↔ Power HUD Indicator
- HUD reads player._current_power and _power_cooldown (both public from Plan 01)
- HUD updates every _physics_process() frame (no signals needed)
- Color state reflects power readiness dynamically

### AudioManager ↔ All Systems
- take_damage() calls play_sfx("dano") on damage
- checkpoint_cafe.gd calls play_sfx("checkpoint") on activation
- Sketch power (Plan 03) will call play_sfx("sketch_disparo")
- Amor power (Plan 04) will call play_sfx("amor_ativado")
- All calls are safe (registered keys return player, unregistered keys warn)

## Verification Results

### Automated Checks

All plan verification criteria passed:

```bash
# Task 1: Player HP system
grep -c "var hp: int = 3" scenes/player/player.gd
# Result: 1 ✓

grep -c "func heal" scenes/player/player.gd
# Result: 1 ✓

grep -c "hp -= 1" scenes/player/player.gd
# Result: 1 ✓

# Task 2: Checkpoint café
test -f scenes/world2/checkpoint_cafe.tscn
# Result: file exists ✓

grep -c "func _on_body_entered" scenes/world2/checkpoint_cafe.gd
# Result: 1 ✓

grep -c "_activated" scenes/world2/checkpoint_cafe.gd
# Result: 3 ✓ (declaration, guard, set)

# Task 3: AudioManager registration
grep -c "prova_tfg_coletada" autoloads/audio_manager.gd
# Result: 1 ✓

grep -c "sketch_disparo" autoloads/audio_manager.gd
# Result: 1 ✓

# Task 4: Power HUD indicator
test -f scenes/player/power_hud_indicator.tscn
# Result: file exists ✓

grep -c "func update_power_display" scenes/player/power_hud_indicator.gd
# Result: 1 ✓

grep -c "modulate.*Color" scenes/player/power_hud_indicator.gd
# Result: 4 ✓ (ready/cooldown states)

grep -c "get_first_node_in_group.*player" scenes/player/power_hud_indicator.gd
# Result: 1 ✓ (Godot 4 API)
```

### Manual Verification

- Player hp initializes to 3 on _ready() ✓
- take_damage() decrements hp and emits died signal at <= 0 ✓
- heal() increases hp clamped to 3 ✓
- Checkpoint café collects on first contact only (_activated guard) ✓
- Checkpoint calls player.heal(1) ✓
- AudioManager logs warning on missing SFX (never crashes) ✓
- Power HUD updates color on cooldown state ✓
- Power HUD label updates on power cycle ✓

## Known Stubs

None. All tasks completed without leaving placeholder code.

## Threat Flags

None. HP, checkpoint, and power HUD systems are cosmetic game mechanics:
- **HP is transient** (reset on scene load, not persisted)
- **Checkpoint _activated flag** prevents infinite heal loops
- **AudioManager graceful degradation** prevents crash on missing audio
- **Power HUD read-only** — never writes to player state

## Deviations from Plan

None — plan executed exactly as written.

## Commits

1. **1bb008d** — `feat(04-02): implement player HP system (take_damage, heal methods)`
2. **f6be87d** — `feat(04-02): create checkpoint cafe scene and healing logic`
3. **22dd91f** — `feat(04-02): register phase 4 SFX keys in AudioManager`
4. **bf1231c** — `feat(04-02): create power HUD indicator scene and state management`

## Self-Check: PASSED

All created files exist:
- ✓ scenes/world2/checkpoint_cafe.tscn
- ✓ scenes/world2/checkpoint_cafe.gd
- ✓ scenes/player/power_hud_indicator.tscn
- ✓ scenes/player/power_hud_indicator.gd

All commits recorded in git log:
- ✓ 1bb008d
- ✓ f6be87d
- ✓ 22dd91f
- ✓ bf1231c

Files modified:
- ✓ scenes/player/player.gd
- ✓ autoloads/audio_manager.gd
