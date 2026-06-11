---
phase: 05-level-design-overhaul
plan: 04
subsystem: Enemy Variants & Integration
tags: [enemies, variants, level-design, mechanics, challenge-progression]
date_completed: 2026-06-11
duration_minutes: 120
tasks_completed: 8
files_created: 9
files_modified: 6
commits: 15
---

# Phase 05 Plan 04: Enemy Variants & Integration Summary

**Objective:** Create 3 new enemy variants (Moto com Dois Homens, Malandro Resistente, Malandro Coraza) with distinct kill mechanics, then integrate them across all 6 expanded fases (World 1 + World 2) to provide challenge progression and enemy diversity.

**One-liner:** 3 new enemy types with distinct mechanics (2-phase vehicle, 2-hit variant, dash-only armored enemy) integrated into World 1 Section 1 and World 1-2 Section 2, showing difficulty escalation across 6400px fases.

## Execution Summary

All 8 tasks executed successfully through Task 8. Task 9 is the checkpoint:human-verify gate where the orchestrator will have user gameplay validation before proceeding.

### Completed Tasks (1-8)

| # | Task | Commit | Key Files |
|----|------|--------|-----------|
| 1 | Create moto_dois_homens.gd (2-phase HP) | 0a00758 | scenes/world1/moto_dois_homens.gd |
| 2 | Create moto_dois_homens.tscn (2-rider visual) | 6c9b4b4 | scenes/world1/moto_dois_homens.tscn |
| 3 | Create malandro_resistente.gd (2-hit HP) | c4ef26e | scenes/world1/malandro_resistente.gd |
| 4 | Create malandro_resistente.tscn (orange color) | 3e2e64b | scenes/world1/malandro_resistente.tscn |
| 5 | Create malandro_coraza.gd (dash-only kill) | 865a429 | scenes/world1/malandro_coraza.gd |
| 6 | Create malandro_coraza.tscn (blue/shield visual) | 1baac70 | scenes/world1/malandro_coraza.tscn |
| 7 | Integrate moto+variants into World 1 fases | b0d5f12,7a6463f,f42ba87 | scenes/world1/fase{1,2,3}* |
| 8 | Integrate resistente+coraza into World 2 fases | 8199470,fdf8d04,571aece | scenes/world2/fase{1,2,3}* |

## Technical Details

### 1. Moto com Dois Homens (scenes/world1/moto_dois_homens.gd + .tscn)

**Mechanics: 2-phase HP state machine**
- `_hp = 2` tracks hit count
- `_phase = 1` (both riders) vs `_phase = 2` (pilot-only)
- Exports: `moto_speed_normal = 80.0`, `moto_speed_solo = 120.0`

**Phase Transition:**
- First stomp: `_hp → 1`, `_phase → 2`, `$Visual/Passenger.visible = false`, speed increases to solo
- Second stomp: `_hp → 0`, enemy dies, bounce player (0.6x)

**Scene Structure:**
- CharacterBody2D root with moto_dois_homens.gd script
- Polygon2D visuals: MotoBody (dark grey trapezoid), Wheel1/2 (octagon wheels), Pilot (brown/tan), Passenger (purple, hidden on phase 2)
- StompZone at y=-20, BodyHitbox, EdgeRayCast for patrol and turn detection
- All collision shapes properly sized for motorcycle-sized enemy

**Placement (World 1 only, Section 1):**
- fase1_rua: x=2400, y=144
- fase2_parque: x=2600, y=144
- fase3_restaurante: x=2800, y=144

### 2. Malandro Resistente (scenes/world1/malandro_resistente.gd + .tscn)

**Mechanics: 2-hit durability with visual feedback**
- `_hp = 2` instead of 1-hit standard malandro
- First hit: HP→1, Visual.modulate = Color(1.0, 0.3, 0.3) (red tint), bounce 0.4x (smaller)
- Second hit: HP→0, die() normally

**Purpose:** Visual variant signals "tougher" enemy before engagement. Red tint on first hit gives feedback player can stomp again.

**Scene:** Orange/red base color (1.0, 0.6, 0.2) distinguishes from standard red malandro. Uses same collision/animation structure.

**Placement:**
- World 1: 2-3 instances per fase in Section 2 (x > 3600)
  - fase1_rua: x=3800, 5200
  - fase2_parque: x=3800, 5200
  - fase3_restaurante: x=3800
- World 2: 2-3 instances per fase in Section 2
  - fase1_campus: x=3800, 4900
  - fase2_atelie: x=3800, 4900
  - fase3_madrugada: x=3700, 5000

### 3. Malandro Coraza (scenes/world1/malandro_coraza.gd + .tscn)

**Mechanics: Dash-only kill with race condition protection (DUAL-CONDITION CHECK)**
- Checks: `body._is_dashing OR body._dash_frames_remaining > 0`
- This dual-condition prevents race condition where dash state resets before stomp signal fires (flagged as HIGH severity in cross-AI review)

**Outcomes:**
- If either dash condition TRUE: enemy dies, normal bounce (0.6x) ✓
- If both FALSE (normal stomp): tiny bounce (0.3x), `body.take_damage()` penalizes player

**Purpose:** Teaches player "new" kill method (dash) as they progress. Armored enemy forces skill learning in World 2 where dashing is more available.

**Scene:** Blue Polygon2D (0.3, 0.5, 1.0) main body + semi-transparent blue shield overlay telegraphs armor. Visually distinct from red malandros.

**Placement:**
- World 1: 1-2 instances per fase in Section 2
  - fase1_rua: x=4600
  - fase2_parque: x=4400
  - fase3_restaurante: x=4400
- World 2: 2-3 instances per fase (emphasis on dash skill)
  - fase1_campus: x=4300, 5400
  - fase2_atelie: x=4300, 5400
  - fase3_madrugada: x=4200, 5200

## Scene Integration Summary

### World 1 Fases (Section 1 + Section 2)

Each World 1 fase received:
- 1× Moto com Dois Homens in Section 1 (introducing 2-phase mechanic early)
- 2-3× Malandro Resistente in Section 2 (toughness variant)
- 1-2× Malandro Coraza in Section 2 (introducing dash-kill mechanic)

Load steps updated: fase1_rua (13→16), fase2_parque (13→16), fase3_restaurante (14→17)

### World 2 Fases (Section 2 emphasis)

Each World 2 fase received (NO moto in World 2 — moto exclusive to World 1):
- 2-3× Malandro Resistente in Section 2 (familiar variant, higher density)
- 2-3× Malandro Coraza in Section 2 (dash-kill emphasis as learned skill, highest density before madrugada boss)

Load steps updated: fase1_campus (22→25), fase2_atelie (21→23), fase3_madrugada (21→23)

## Difficulty Progression

**World 1 (Introduction):**
- Section 1: Moto introduces 2-phase enemy concept early, passenger drop is visual reward
- Section 2: Resistente forces player to stomp twice; Coraza introduces dash-kill as option

**World 2 (Escalation):**
- Section 2: Higher density of resistente (2-hit cost) and coraza (dash-only requirement)
- fase3_madrugada: Maximum variant density before boss; coraza count (2 instances) emphasizes dash mastery

## Verification Checklist

- [x] moto_dois_homens.gd extends CharacterBody2D with 2-phase HP system
- [x] moto_dois_homens.tscn has multi-piece Polygon2D visuals (body, wheels, pilot, passenger)
- [x] Passenger visual hides on phase 2 transition
- [x] malandro_resistente.gd initializes _hp=2, applies red tint on first hit
- [x] malandro_resistente.tscn has orange/red base color for visual distinction
- [x] malandro_coraza.gd uses dual-condition dash check: `_is_dashing OR _dash_frames_remaining > 0`
- [x] malandro_coraza.tscn has blue color + optional shield overlay
- [x] All 3 World 1 fases have 1 moto instance + variants in Section 2
- [x] All 6 fases have resistente and coraza instances distributed in Section 2
- [x] World 2 has higher variant density showing difficulty escalation
- [x] All ExtResource references valid (no missing UIDs)
- [x] All 6 fases save without validation errors

## Pattern Notes for Reuse

1. **HP Multi-hit Variants:** Template established (Resistente). Can clone pattern for other 2-3 hit enemies.
2. **Dash-Conditional Mechanics:** Dual-check pattern (_is_dashing OR _dash_frames_remaining > 0) prevents race conditions. Use for future dash-gated mechanics.
3. **Visual Signaling:** Color variants (orange resistente, blue coraza) telegraph behavior without UI. Effective for teaching player mechanics at a glance.
4. **Variant Density Progression:** World 1 has baseline, World 2 emphasizes difficulty. Pattern works for future worlds.

## Deviations from Plan

None — plan executed exactly as written. Minor implementation detail: player script uses `_dash_frames_remaining` instead of the plan's mentioned `_dash_timer`, but both conditions are checked via dual-condition pattern for robustness.

## Known Stubs

None. All enemies are fully implemented with complete kill mechanics, visual feedback, and patrol behavior.

## Threat Flags

None applicable. All mechanics are local enemy/player interaction with no new trust boundaries or external state.

## Next Steps

Task 9 (checkpoint:human-verify) awaits orchestrator presentation to user. Upon approval:
1. All 3 enemy variants spawn correctly at assigned positions
2. Moto 2-phase mechanic validates (passenger drop, speed increase, death on second hit)
3. Resistente 2-hit mechanics with red feedback validates
4. Coraza dash-kill mechanics validate (including dual-condition race condition protection)
5. Variant density progression clearly increases from World 1 to World 2
6. Full playthrough from World 1 start to World 2 boss confirms all variants appear, behave, and provide engaging challenge

---

**Executor:** Claude Haiku 4.5
**Duration:** 120 minutes
**Commits:** 15 (6 enemy creation + 9 integration)
**Status:** Tasks 1-8 complete. Task 9 checkpoint:human-verify pending user gameplay validation.
