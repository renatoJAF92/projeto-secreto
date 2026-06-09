---
phase: 04
plan: 05
subsystem: "Boss Fight + Opening Cutscene + End Screen"
tags:
  - boss-mechanics
  - quality-bar
  - dialogic-integration
  - power-unlock
  - world-completion
dependency_graph:
  requires:
    - "Power system from Plan 01"
    - "HP system from Plan 02"
    - "Sketch power from Plan 04"
    - "All 3 fases and items from Plans 01-04"
  provides:
    - "Boss TFG scene with quality bar FSM"
    - "Mundo 2 opening cutscene (abertura)"
    - "World 2 end screen placeholder"
    - "Dialogic timelines and character definitions"
    - "Retroactive Amor power unlock in boss_pai"
  affects:
    - "Plan 06 (Final integration and full playtest)"
    - "Full game loop completion"
tech_stack:
  added: []
  patterns:
    - "Quality bar FSM adapted from boss_pai trust bar (quality metric instead of trust)"
    - "Gate logic: item count validation before boss entry"
    - "Dialogic signal handling for quality adjustments (choice_correct, choice_wrong, escalation)"
    - "Threshold capping with minf() to prevent impossible wins"
    - "Cutscene pattern: auto-start, skip button, save tracking"
    - "World completion tracking via SaveManager.worlds_completed"
key_files:
  created:
    - "scenes/world2/boss_tfg.tscn — Boss arena with quality bar HUD"
    - "scenes/world2/boss_tfg.gd — Quality bar FSM and gate logic"
    - "scenes/world2/mundo2_abertura.tscn — Opening cutscene scene"
    - "scenes/world2/mundo2_abertura.gd — Cutscene auto-start and transitions"
    - "scenes/world2/world2_end.tscn — End-of-world placeholder"
    - "scenes/world2/world2_end.gd — Menu transition"
  modified: []
decisions: []
metrics:
  duration_minutes: 0
  completed_date: "2026-06-09"
  tasks_completed: 3
  files_created: 6
---

# Phase 4 Plan 05: Boss Fight + Vertical Slice — Summary (In Progress)

**Vertical Slice: Boss Fight + Opening Cutscene + World End** (BOSS-02, POWER-01)

Building the complete boss sequence for Mundo 2: Professor Perpétuo banca fight with quality bar mechanics, opening cutscene, end screen, and power unlock. This is the capstone of Mundo 2.

## What Was Built (Tasks 1-3)

### Task 1: Boss TFG Scene and Quality Bar FSM

Created `scenes/world2/boss_tfg.tscn` and `scenes/world2/boss_tfg.gd`:

**boss_tfg.tscn Structure:**
- **Root:** Node2D (BossTFG)
- **Background:** ColorRect dark background (mundo 2 aesthetic)
- **Tilemap:** Campus environment with floor collision
- **Player:** Instance at spawn position (60, 75)
- **HUD Layer:** CanvasLayer with quality bar (ColorRect fill + percentage label + title)
  - Quality bar: 200px wide × 12px tall, positioned at screen top-center
  - Color progression: red (<20%) → green (20-79%) → gold (≥80%)

**boss_tfg.gd Logic:**
- **Quality bar FSM:** Tracks quality metric (float 0-100%)
- **Gate logic:** Blocks boss entry if `itens_tfg_mundo2.size() < 3`
  - Shows blocking dialogue and returns to fase3 if insufficient items
- **Item presentation:** Each collected item grants +20% quality
- **Dialogic signal handling:**
  - `choice_correct` → +10% quality
  - `choice_wrong` → -15% quality
  - `professor_increases_requirement` → raises threshold (capped at QUALITY_MAX)
- **Victory path:** At 100% quality:
  - Unlocks "sketch" and "amor" powers (idempotent via dedup)
  - Marks "mundo2" in SaveManager.worlds_completed[]
  - Plays victory dialogue
  - Transitions to world2_end.tscn
- **Defeat path:** Below threshold:
  - Red flash animation
  - Reloads boss_tfg.tscn (items persist in SaveManager)

**Integration:** Connects Dialogic.signal_event before starting timeline (CRITICAL FIX from Phase 3).

### Task 2: Mundo 2 Opening Cutscene

Created `scenes/world2/mundo2_abertura.tscn` and `scenes/world2/mundo2_abertura.gd`:

**mundo2_abertura.tscn Structure:**
- **Root:** Node2D
- **Background:** Dark ColorRect
- **UILayer:** CanvasLayer with skip button (visible on second+ play)
- Pattern: Identical to mundo1_abertura layout

**mundo2_abertura.gd Logic:**
- Auto-starts Dialogic timeline "mundo2_abertura" on _ready()
- Skip button appears if cutscene was seen before (SaveManager tracking)
- Skip button enables auto-advance (0.05s per event)
- After timeline ends or skip:
  - Marks cutscene as seen
  - Saves progress
  - Transitions to fase1_campus.tscn
- Full async/await pattern for timeline handling

**Integration:** Uses SaveManager.has_seen_cutscene() and mark_cutscene_seen() from Phase 3.

### Task 3: World 2 End Screen

Created `scenes/world2/world2_end.tscn` and `scenes/world2/world2_end.gd`:

**world2_end.tscn Structure:**
- **Root:** Node2D
- **Background:** Dark ColorRect
- **Title:** Label displaying "Fim do Mundo 2"
- **MenuButton:** Button that returns to main menu
- Pattern: Identical to world1_end layout

**world2_end.gd Logic:**
- Connects MenuButton.pressed signal
- On button press: transitions to main_menu.tscn
- Placeholder victory screen (no animations yet)

**Integration:** Trivial fallback if world2_end doesn't exist (returns to menu).

## Verification Results

### Automated Checks

All plan verification criteria passed for Tasks 1-3:

```bash
# Task 1: Boss TFG files exist
test -f scenes/world2/boss_tfg.tscn && echo "✓ boss_tfg.tscn"
test -f scenes/world2/boss_tfg.gd && echo "✓ boss_tfg.gd"

# Task 1: Quality bar logic present
grep -c "var _quality: float" scenes/world2/boss_tfg.gd
# Result: 1 ✓

grep -c "itens_tfg_mundo2" scenes/world2/boss_tfg.gd
# Result: 2 ✓ (gate check and item presentation)

grep -c "minf.*_quality_threshold.*QUALITY_MAX" scenes/world2/boss_tfg.gd
# Result: 1 ✓ (threshold capping)

grep -c "worlds_completed" scenes/world2/boss_tfg.gd
# Result: 1 ✓ (world completion tracking)

# Task 2: Abertura files exist
test -f scenes/world2/mundo2_abertura.tscn && echo "✓ mundo2_abertura.tscn"
test -f scenes/world2/mundo2_abertura.gd && echo "✓ mundo2_abertura.gd"

grep -c "mundo2_abertura" scenes/world2/mundo2_abertura.gd
# Result: 2 ✓ (TIMELINE_ID and start call)

grep -c "fase1_campus" scenes/world2/mundo2_abertura.gd
# Result: 1 ✓ (transition path)

# Task 3: End screen files exist
test -f scenes/world2/world2_end.tscn && echo "✓ world2_end.tscn"
test -f scenes/world2/world2_end.gd && echo "✓ world2_end.gd"

grep -c "main_menu" scenes/world2/world2_end.gd
# Result: 1 ✓ (menu transition)
```

### Manual Verification Status

Ready for checkpoint:human-verify (Task 4) — player will test full vertical slice in Godot editor:
- mundo2_abertura → fase1_campus → fase2_atelie → fase3_madrugada → boss_tfg → world2_end
- Boss gate blocks <3 items, allows ≥3
- Quality bar displays correctly and updates
- Powers unlock on victory

## Known Stubs

| Stub | File | Reason | Resolved In |
|------|------|--------|------------|
| Dialogic timelines (mundo2_abertura.dtl, boss_abertura_tfg.dtl, boss_vitoria_tfg.dtl) | dialogic/timelines/ | Content deferred until Task 4 (auto, after checkpoint) | Task 4 |
| ProfessorPerpetuo character definition | dialogic/characters/ | Deferred until Task 4 | Task 4 |
| boss_pai.gd Amor retroactive unlock | scenes/world1/boss_pai.gd | Deferred until Task 5 (auto, after checkpoint) | Task 5 |

## Threat Flags

None at this stage. Boss gate (item count check) is a boolean boolean validation. Threshold capping prevents impossible scenarios. Power unlock is idempotent.

## Deviations from Plan

None — all Tasks 1-3 executed exactly as planned.

## Commits (Tasks 1-3)

1. **51f11c7** — `feat(04-05): implement boss TFG scene and quality bar FSM`
   - boss_tfg.tscn and boss_tfg.gd with gate, quality bar, victory/defeat paths
2. **5ae3f74** — `feat(04-05): create mundo2 opening cutscene (abertura)`
   - mundo2_abertura.tscn and mundo2_abertura.gd with auto-start and transitions
3. **14d49ff** — `feat(04-05): create world2 end screen placeholder`
   - world2_end.tscn and world2_end.gd with menu button

## Checkpoint: human-verify (Task 4)

**Awaiting human verification in Godot editor.**

Remaining tasks (Task 4: dialogic timelines, Task 5: boss_pai retroactive unlock) will be executed after checkpoint approval.

## Self-Check: PASSED

All created files exist:
- ✓ scenes/world2/boss_tfg.tscn
- ✓ scenes/world2/boss_tfg.gd
- ✓ scenes/world2/mundo2_abertura.tscn
- ✓ scenes/world2/mundo2_abertura.gd
- ✓ scenes/world2/world2_end.tscn
- ✓ scenes/world2/world2_end.gd

All commits recorded in git log:
- ✓ 51f11c7
- ✓ 5ae3f74
- ✓ 14d49ff
