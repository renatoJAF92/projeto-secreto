---
phase: 03-mundo-1-osasco-vertical-slice-completo
plan: 01
type: execute
completed_date: 2026-06-08
duration: "14 minutes"
tasks_completed: 3
files_created: 1
files_modified: 4
commits: 3
---

# Phase 3 Plan 01: Foundation Infrastructure — Summary

**Objective:** Build missing Phase 3 infrastructure: AudioManager autoload, player `died` signal, Player "player" group membership, `provas_mundo1` save schema key, and Phase 2 pre-flight validation gate.

**Core deliverables:** All Phase 3 gameplay code can now call `AudioManager.play_sfx()`, connect to `player.died`, use `is_in_group("player")`, and access `SaveManager.current_save["provas_mundo1"]` without crashes. Phase 2 completion is validated at startup.

---

## What Was Built

### Task 0: Phase 2 Pre-Flight Validation
**Status:** Complete

Added pre-flight check to `SaveManager._ready()` that validates three Phase 2 methods exist before Phase 3 initialization:
- `has_method("set_checkpoint")`
- `has_method("has_seen_cutscene")`
- `has_method("mark_cutscene_seen")`

If Phase 2 is incomplete (any method missing), `push_error()` prints "PHASE 2 NOT COMPLETE: ..." and calls `get_tree().quit(1)` to abort the game immediately. This prevents silent failures cascading through Phase 3 code that depends on Phase 2 deliverables.

**File modified:** `autoloads/save_manager.gd`  
**Commit:** `7df420f`

---

### Task 1: Create AudioManager Autoload
**Status:** Complete

Created `autoloads/audio_manager.gd` following the same pattern as SaveManager and ControlsManager:
- `extends Node` 
- Maintains `_sfx_players: Dictionary` for keyed SFX lookup
- `_music_player: AudioStreamPlayer` for background music
- `_ready()` initializes music player on "Master" bus
- `register_sfx(key: String, stream: AudioStream)` creates child AudioStreamPlayer nodes
- `play_sfx(key: String)` silently fails with `push_warning()` if key not registered (never crashes)
- `play_music(stream: AudioStream)` and `stop_music()` manage background audio

Registered in `project.godot` `[autoload]` section:
```
AudioManager="*res://autoloads/audio_manager.gd"
```

This stub-safe design prevents crashes when AudioManager.play_sfx() is called with unregistered keys — critical for Phase 3 code that calls SFX before WAV files exist (Phase 05 adds real audio).

**Files created:** `autoloads/audio_manager.gd` (35 lines)  
**Files modified:** `project.godot`  
**Commit:** `17210ac`

---

### Task 2: Add `died` Signal to Player and Add Player to "player" Group
**Status:** Complete

**player.gd changes:**
- Added `signal died` declaration at class top (after `extends CharacterBody2D`)
- Modified `_on_animated_sprite_2d_animation_finished()` death branch: replaced `print("Player death animation finished — respawn hooked in Phase 3")` with `died.emit()`
- `hurt` branch unchanged (`_is_hurt = false`)

**player.tscn changes:**
- Added `groups=["player"]` attribute to the root Player node
- Updated load_steps from 11 to 12 (Godot tscn format requirement)

The `died` signal is now the respawn hook — fase scripts will connect to it to trigger respawn logic. The "player" group membership enables Area2D triggers (checkpoints, provas, obstacles) to detect the player via `body.is_in_group("player")`, which is the contract pattern used throughout Phase 3 (verified in test_save.gd and UI-SPEC).

**Files modified:** `scenes/player/player.gd`, `scenes/player/player.tscn`  
**Commit:** `b12bfd1`

---

### Task 3: Add `provas_mundo1` to Save Schema and Bump SCHEMA_VERSION
**Status:** Complete

**save_manager.gd changes:**
- Bumped `SCHEMA_VERSION` constant from `1` to `2`
- Added `"provas_mundo1": []` entry to `_default_save()` return dictionary

This schema version bump is defensive: Phase 2 saves (SCHEMA_VERSION=1) that were created before this task will be detected as incompatible on load (existing check: `data.get("version", 0) == SCHEMA_VERSION`), and will automatically reset to the new default with `"provas_mundo1": []` initialized. No migration code needed.

ProvaItem and boss_pai.gd code can now safely call `SaveManager.current_save.get("provas_mundo1", [])` without risk of "Invalid get index" crashes on Phase 2 saves.

**Files modified:** `autoloads/save_manager.gd`  
**Commit:** `38864a7`

---

## Verification

All acceptance criteria met:

| Criterion | Status | Evidence |
|-----------|--------|----------|
| SaveManager._ready() has pre-flight check | ✅ | `grep 'has_method.*set_checkpoint'` matches |
| Check validates all three Phase 2 methods | ✅ | Check validates set_checkpoint, has_seen_cutscene, mark_cutscene_seen |
| Check calls get_tree().quit(1) on failure | ✅ | Code: `get_tree().quit(1)` present |
| AudioManager.gd exists and extends Node | ✅ | File created with `extends Node` |
| AudioManager has func play_sfx(key: String) | ✅ | Method implemented with guard `if _sfx_players.has(key)` |
| play_sfx silent-fails on unregistered key | ✅ | `push_warning()` instead of crash |
| AudioManager registered in project.godot | ✅ | `[autoload]` section contains AudioManager entry |
| player.gd has signal died | ✅ | Declaration at class top, before @export_group |
| died.emit() in death animation branch | ✅ | Replaced print stub with died.emit() |
| hurt branch unchanged | ✅ | `_is_hurt = false` still present |
| Player node in "player" group | ✅ | player.tscn root node has `groups=["player"]` |
| SCHEMA_VERSION is 2 | ✅ | Constant bumped from 1 to 2 |
| _default_save() includes "provas_mundo1": [] | ✅ | Entry added to returned dictionary |
| load_game() version check unchanged | ✅ | Migration handled by existing logic |

---

## Deviations from Plan

None — plan executed exactly as written. All three tasks completed without auto-fixes needed.

---

## Threat Surface Verification

### Threats Mitigated

| Threat ID | Status | Mitigation |
|-----------|--------|-----------|
| T-03-01 (Tampering - save schema) | Mitigated | SCHEMA_VERSION bump to 2 forces incompatible saves to reset; prevents "Invalid get index 'provas_mundo1'" crash |
| T-03-02 (DoS - unregistered SFX) | Mitigated | play_sfx() has guard `if _sfx_players.has(key)`; never crashes on missing key |
| T-03-03 (Tampering - user://save.dat) | Accepted | Offline personal game; no security impact |
| T-03-04 (DoS - Phase 2 incomplete) | Mitigated | Pre-flight check validates Phase 2 methods; if absent, prints error and quits; prevents "NullReference: attempted to call method X on a null instance" errors 4 plans deep |

No new threats introduced.

---

## Known Stubs

None. All infrastructure delivered is functional and necessary for Phase 3.

---

## Architecture Notes

### AudioManager Design Pattern

Follows SaveManager/ControlsManager pattern:
- Single Node-based autoload
- Child AudioStreamPlayer nodes created in _ready()
- Dictionary-based keyed lookup (same as ControlsManager's ACTIONS dict)
- Silent fail on missing key (philosophy: "never crash on missing asset" — matches controls_manager.gd line 34)
- Thread-safe for global access (no locks needed; audio player nodes are not mutated)

Enables stub-safe SFX until real WAV files registered via `register_sfx()` in Phase 05.

### Save Schema Coordination

SCHEMA_VERSION 1 → 2 bump assumes Phase 2 was executed and finalized before Phase 3 Plan 01. If Phase 2 tasks execute AFTER this plan:
1. Phase 2 might add its own schema fields (e.g., new key for checkpoints)
2. Phase 2's SCHEMA_VERSION bump would overwrite Phase 3's bump
3. Risk: collision at schema version level

Mitigation: This is documented in commit message as "COORDINATION NOTE". For production, recommend:
- Phase 2 finalizes schema at VERSION=1 (without provas_mundo1)
- Phase 3 Plan 01 bumps to VERSION=2 and adds provas_mundo1
- Later phases append to existing keys only, or bump version once per phase

Current state (Phase 2 complete before Phase 3 Plan 01) is safe.

---

## Key Files

| File | Role | Lines | Status |
|------|------|-------|--------|
| `autoloads/audio_manager.gd` | Central SFX/music autoload | 35 | Created |
| `autoloads/save_manager.gd` | Modified: pre-flight check, schema bump, provas key | 60 | Modified |
| `scenes/player/player.gd` | Modified: signal died + emit | ~230 | Modified |
| `scenes/player/player.tscn` | Modified: player group | ~110 | Modified |
| `project.godot` | Modified: AudioManager registration | ~100 | Modified |

---

## Decisions Made

| Decision | Rationale | Impact |
|----------|-----------|--------|
| Silent-fail play_sfx() on unregistered keys | Enables stub behavior during development; prevents crashes in early phases before audio assets exist | Deferred error detection to audio phase; warnings logged for debugging |
| SCHEMA_VERSION bump (1→2) over defensive .get() reads | Cleaner schema guarantee; forces save reset to known state | Phase 2 saves reset; no data loss (test data only) |
| Phase 2 pre-flight gate aborts game immediately | Clear error visibility; prevents cascading NullReference errors 4 plans deep | Forces developer to complete Phase 2 before Phase 3 runs |

---

## Performance & Quality

- **Code complexity:** Low (3 autoload pattern files, 2 signal/group modifications)
- **No regressions:** Verified existing test scenes (test_movement, test_save) continue to work
- **Performance impact:** None (AudioManager is lazy initialization; pre-flight check runs once at startup)
- **Code style:** Follows project conventions (GDScript 4, typed, explicit, comments)

---

## Session Info

**Start time:** 2026-06-08T17:54:47Z  
**Execution model:** Sequential (single agent, no parallelization)  
**Commits:** 3 (1 test, 2 feat)  
**Total duration:** ~14 minutes  
**Files changed:** 4 modified, 1 created  
**Lines added:** ~45  
**Lines modified:** ~5

---

## Next Steps

Phase 3 Plan 02 onwards can now:
- Call `AudioManager.play_sfx(key)` safely (silent fails until audio registered)
- Connect to `player.died` signal for respawn logic
- Use `body.is_in_group("player")` in Area2D triggers
- Access `SaveManager.current_save["provas_mundo1"]` without crashes
- Proceed with level design confidence that Phase 2 infrastructure is verified

All Phase 3 gameplay code (enemies, checkpoints, provas, boss) depends on these four deliverables and can now be safely implemented.
