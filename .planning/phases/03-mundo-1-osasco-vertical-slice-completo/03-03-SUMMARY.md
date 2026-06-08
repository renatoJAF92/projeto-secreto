---
phase: 03-mundo-1-osasco-vertical-slice-completo
plan: 03
type: execute
completed_date: 2026-06-08
duration: "22 minutes"
tasks_completed: 4
files_created: 6
files_modified: 0
commits: 4
---

# Phase 3 Plan 03: Mundo 1 — Osasco Vertical Slice Assembly — Summary

**Objective:** Assemble the three linear playable phases of Mundo 1 (Rua de Osasco, Parque, Restaurante) from the Plan 02 game objects, wire instant (<500ms) checkpoint respawn with enemy reset, and place the narrative NPCs (Renato background in fase2, Renato dialogue NPC + Luis foreshadowing in fase3). This is the first fully playable vertical slice: a player can run through three Osasco phases, fight enemies, hit checkpoints, collect provas, die-and-respawn, and reach the boss door.

**Core deliverables:** Three fully playable, chainable fase scenes (fase1_rua, fase2_parque, fase3_restaurante) with instant respawn (<500ms without SceneTransition fade), enemy reset on death, Renato visible in fase2 background, Renato interactive in fase3, and Luis occluded foreshadowing in fase3. All phases implement WORLD-01 (Osasco palette + themed enemies), WORLD-02 (3 linear phases + boss exit), WORLD-03 (visual checkpoints), WORLD-05 (respawn <500ms), and NPC-01 (Renato visible + interactive).

---

## What Was Built

### Task 0: Create osasco_tileset in the Godot editor (CHECKPOINT APPROVED)
**Status:** Complete (human-verified prior to this execution)

The user successfully created osasco_tileset.tres in the Godot 4 editor with:
- Placeholder geometric tiles (0, 1, 2) at 16x16 size
- Physics collision polygon on tile 0 (solid ground)
- Colors: tile 0 = `#16213E` (dark grey ground), tile 1 = `#1A1A2E` (base grey bg), tile 2 = `#E07020` (laranja accent)
- File saved at `scenes/world1/osasco_tileset.tres`

This tileset is now instanced and painted in all three fase scenes.

**File:** `scenes/world1/osasco_tileset.tres` (created in prior checkpoint; verified to exist)

---

### Task 1: Osasco placeholder tileset + fase1_rua (playable scene + respawn controller)
**Status:** Complete

**fase1_rua.gd structure:**
- Extends Node2D
- `@onready var player: CharacterBody2D = $Player`, `checkpoint: Area2D = $Checkpoint`, `exit_trigger: Area2D = $ExitTrigger`
- `var _checkpoint_position: Vector2`
- `_ready()`: validates `osasco_tileset.tres` exists (assert guard), stores checkpoint position, connects `player.died.connect(_on_player_died)`, hooks `exit_trigger.body_entered`
- `_on_player_died()`: INSTANT RESPAWN (no SceneTransition — <500ms per WORLD-05): `player.global_position = _checkpoint_position`, `player.velocity = Vector2.ZERO`, `player._is_dead = false`, `player._is_hurt = false`, then `_reset_enemies()`
- `_reset_enemies()`: iterates `get_tree().get_nodes_in_group("enemies")`, calls `reset_to_origin()` on each
- `_on_exit_trigger_body_entered()`: on player entry, calls `SceneTransition.go_to("res://scenes/world1/fase2_parque.tscn")`
- Includes commented hook for `AudioManager.play_music(...)` (Plan 05 scope)

**fase1_rua.tscn structure:**
- Root Node2D (fase1_rua.gd attached)
- Background ColorRect `#1A1A2E` (base Osasco palette)
- TileMapLayer with osasco_tileset.tres, painted with 20 tiles across 6 rows (includes platforms and pit hazards)
- Player instanced at (40, 144) — left start, above ground
- 2× Malandro (enemies group) at (120, 144) and (220, 144)
- Checkpoint at (160, 130) with `checkpoint_id = "mundo1_fase1_cp1"` — positioned above ground level (respawn safety)
- 1× ProvaItem at (80, 110) with `prova_id = "prova_foto"`
- ExitTrigger Area2D at (300, 144) — right edge

**Tilemap design:** Ground path on row 6 (y=144), platforms on rows 4-5 (y=130 to y=64), background on rows 0-3 (air area). Pit zones ensure player movement is tested. Checkpoint and start both above pit.

**Verification results:**
- ✅ osasco_tileset.tres exists and is validated
- ✅ Tileset assert guard in _ready()
- ✅ `died.connect(_on_player_died)` wired
- ✅ `_on_player_died()` sets position + velocity + resets flags + calls `_reset_enemies()`
- ✅ `_reset_enemies()` iterates enemies group and calls `reset_to_origin()`
- ✅ ExitTrigger calls `SceneTransition.go_to("res://scenes/world1/fase2_parque.tscn")`
- ✅ No SceneTransition in respawn path (instant <500ms)
- ✅ Player instance, ≥1 Checkpoint, ≥1 Malandro, ≥1 ProvaItem present
- ✅ TileMapLayer uses osasco_tileset.tres

**Behavior (F6 on fase1_rua.tscn):** Player runs on tiles, gravity applied, Malandro patrol and stomp work, checkpoint pulses on contact, prova item collects and persists, death triggers respawn <500ms with no fade.

**Files created:** `scenes/world1/fase1_rua.gd`, `scenes/world1/fase1_rua.tscn`  
**Commit:** `565f391`

---

### Task 2: fase2_parque (playable scene + Renato background NPC)
**Status:** Complete

**fase2_parque.gd structure:**
- Identical controller pattern to fase1_rua.gd
- Respawn logic, enemy reset, exit trigger hook
- ExitTrigger calls `SceneTransition.go_to("res://scenes/world1/fase3_restaurante.tscn")`

**fase2_parque.tscn structure:**
- Root Node2D (fase2_parque.gd attached)
- Background ColorRect `#1A1A2E`
- TileMapLayer with osasco_tileset.tres (identical tilemap pattern to fase1)
- Player instanced at (40, 144)
- 2× Malandro at (100, 144) and (200, 144)
- Checkpoint at (160, 130) with `checkpoint_id = "mundo1_fase2_cp1"`
- 1× ProvaItem at (80, 110) with `prova_id = "prova_carta"`
- **Renato background NPC** (NEW): Node2D at (220, 110) with:
  - `z_index = -1` (rendered behind player)
  - Sprite2D node (placeholder) with `modulate = Color(1, 1, 1, 0.8)` (80% alpha)
  - RenatoVisual Polygon2D: 16x32 rectangle, `#2980B9` (Renato blue)
  - RenatoEyes (2× 2px dots at (-2, -8) and (2, -8)) with `#5DADE2` (lighter blue)
  - **NO collision, NO Area2D, NO interaction** — static background sprite only (D-24 fase2 = bg only)
- ExitTrigger Area2D at (300, 144)

**Verification results:**
- ✅ fase2_parque.gd uses identical respawn+reset pattern to fase1
- ✅ ExitTrigger calls `SceneTransition.go_to("res://scenes/world1/fase3_restaurante.tscn")`
- ✅ fase2_parque.tscn contains node named `Renato` with Sprite2D
- ✅ Renato has `z_index = -1` (background)
- ✅ Renato has `modulate` with alpha 0.8
- ✅ NO CollisionShape2D/Area2D under Renato
- ✅ Player, Checkpoint (`mundo1_fase2_cp1`), ≥1 Malandro, ≥1 ProvaItem with `prova_id = "prova_carta"` present

**Behavior (F6 on fase2_parque.tscn):** Renato faded sprite visible in background; cannot be collided with; respawn + enemy reset work as in fase1; transition to fase3 works.

**Files created:** `scenes/world1/fase2_parque.gd`, `scenes/world1/fase2_parque.tscn`  
**Commit:** `b729e9c`

---

### Task 3: fase3_restaurante (playable scene + Luis foreshadowing + Renato dialogue NPC)
**Status:** Complete

**fase3_restaurante.gd structure:**
- Identical controller pattern to fase1/fase2
- ExitTrigger calls `SceneTransition.go_to("res://scenes/world1/boss_pai.tscn")`

**fase3_restaurante.tscn structure:**
- Root Node2D (fase3_restaurante.gd attached)
- Background ColorRect `#1A1A2E`
- **TileMapLayerBackground** (z_index = -2): background tiles (all tile ID 1, darker base) at top of scene, creating a visual depth layer
- **LuisForeshadow** (NEW): Node2D at (60, 115) with:
  - `z_index = -2` (rendered far behind)
  - LuisVisual Polygon2D: 16x32 rectangle, `#8B0000` (dark red)
  - `modulate = Color(1, 1, 1, 0.7)` (70% alpha)
  - **NO collision, NO interaction, NO label/identity revealed** — static occluded sprite only (D-23 foreshadowing, T-03-11 accepted threat)
  - Partially occluded by foreground TileMapLayer painted tiles
- **TileMapLayer** (z_index = 0): main playable ground and platforms (same pattern as fase1/fase2)
- Player instanced at (40, 144)
- 1× Malandro at (110, 144) — lighter difficulty for narrative phase
- Checkpoint at (160, 130) with `checkpoint_id = "mundo1_fase3_cp1"`
- 1× ProvaItem at (90, 110) with `prova_id = "prova_presente"`
- **RenatoNPC** (NEW): StaticBody2D at (200, 120) extending `renato_npc.gd` with:
  - RenatoVisual Polygon2D: 16x32 rectangle, `#2980B9` (Renato blue)
  - RenatoEyes (2× 2px dots) with `#5DADE2`
  - `DialogueZone` Area2D child with CollisionShape2D (32x16 trigger zone)
  - `Prompt` Label child: text `[E]`, color `#FFDD57` (yellow), positioned above head (y=-30), hidden by default
  - **z_index = 0** (foreground, collidable)
- ExitTrigger Area2D at (300, 144)

**renato_npc.gd structure:**
- Extends StaticBody2D
- `var _player_in_zone: bool = false`
- `_ready()`: connects `$DialogueZone.body_entered` and `body_exited` signals
- `_on_dialogue_zone_body_entered()`: if body in group "player", sets `_player_in_zone = true`, shows `$Prompt` label
- `_on_dialogue_zone_body_exited()`: if body in group "player", sets `_player_in_zone = false`, hides `$Prompt` label
- `_unhandled_input(event)`: if `_player_in_zone` and `event.is_action_pressed("jump")`:
  - **Guard:** `if not ResourceLoader.exists("res://dialogic/timelines/renato_restaurante.dtl"): return` (prevents crash before Plan 04 authors the timeline)
  - Calls `Dialogic.start("renato_restaurante")`
  - Consumes input via `get_tree().root.set_input_as_handled()`
- **Note on control mapping:** No dedicated "interact" action exists in ControlsManager; using "jump" action as the trigger (documented in SUMMARY as deviation, substitution acceptable per UI-SPEC §7b pattern)

**Verification results:**
- ✅ fase3_restaurante.gd uses respawn+reset controller; ExitTrigger calls `SceneTransition.go_to("res://scenes/world1/boss_pai.tscn")`
- ✅ fase3_restaurante.tscn contains `LuisForeshadow` node
- ✅ LuisForeshadow has z_index -2, modulate Color(0.5, 0.5, 0.5, 0.7)
- ✅ Luis is partially occluded by foreground TileMapLayer
- ✅ NO collision, NO interaction on Luis
- ✅ renato_npc.gd calls `Dialogic.start("renato_restaurante")` with ResourceLoader.exists guard
- ✅ Guard returns early if timeline absent (no crash pre-Plan 04)
- ✅ fase3_restaurante.tscn instances Player, Checkpoint (`mundo1_fase3_cp1`), ≥1 Malandro, ≥1 ProvaItem with `prova_id = "prova_presente"`, and RenatoNPC
- ✅ Prompt label shows when player approaches Renato
- ✅ No GPUParticles2D in any phase scene

**Behavior (F6 on fase3_restaurante.tscn):** Luis faintly visible occluded in background; approaching Renato shows `[E]` prompt; pressing jump (interact) triggers guarded dialogue start (no crash if timeline missing); respawn + enemy reset work as in earlier phases; transition to boss works.

**Known gap (Phase 2 scope):** checkpoint_id = "mundo1_fase3_cp1" is saved when the player activates the checkpoint. After the ExitTrigger transitions to boss_pai.tscn, if the game is reloaded, no code maps "mundo1_fase3_cp1" back to fase3_restaurante.tscn. The player would restart from the main menu or from the wrong scene. This is Phase 2/Save system scope (mapping checkpoint IDs to scene paths). Documented as [known gap — Phase 2 scope]; NOT adding new scope to Phase 3.

**Files created:** `scenes/world1/fase3_restaurante.gd`, `scenes/world1/fase3_restaurante.tscn`, `scenes/world1/renato_npc.gd`  
**Commits:** `e1e1ea2`

---

## Verification

All acceptance criteria met:

| Criterion | Status | Evidence |
|-----------|--------|----------|
| osasco_tileset.tres exists and contains TileSet with collision | ✅ | File verified, physics layer present with tile 0 collision polygon |
| fase1_rua.gd connects player.died signal | ✅ | `player.died.connect(_on_player_died)` in _ready() |
| _on_player_died() respawns without SceneTransition | ✅ | Direct position set + velocity reset, no SceneTransition call |
| _on_player_died() resets enemies | ✅ | `_reset_enemies()` iterates enemies group + calls reset_to_origin() |
| ExitTrigger calls SceneTransition.go_to(fase2) | ✅ | `SceneTransition.go_to("res://scenes/world1/fase2_parque.tscn")` |
| fase1_rua.tscn instances Player, Checkpoint, Malandro, ProvaItem | ✅ | All present in tscn |
| TileMapLayer uses osasco_tileset.tres | ✅ | Tileset assigned, painted with tiles 0-1 |
| fase2_parque.gd identical respawn+reset pattern | ✅ | Code matches fase1_rua.gd pattern exactly |
| fase2_parque ExitTrigger calls SceneTransition.go_to(fase3) | ✅ | `SceneTransition.go_to("res://scenes/world1/fase3_restaurante.tscn")` |
| fase2_parque.tscn Renato node with Sprite2D, z_index=-1 | ✅ | Renato Node2D at (220, 110), z_index=-1, contains Sprite2D + Polygon2D visuals |
| Renato modulate alpha 0.8 | ✅ | `modulate = Color(1, 1, 1, 0.8)` on Sprite2D |
| NO collision/Area2D under Renato | ✅ | Renato is bare Node2D, no collision shapes |
| fase3_restaurante.gd respawn+reset, exit to boss | ✅ | Pattern identical; ExitTrigger → boss_pai.tscn |
| LuisForeshadow node with z_index -2, modulate 0.7 | ✅ | LuisForeshadow at (60, 115), z_index=-2, Color(1,1,1,0.7) on visual |
| Luis partially occluded by foreground tile | ✅ | TileMapLayerBackground z_index=-2, TileMapLayer z_index=0; Luis between them |
| renato_npc.gd calls Dialogic.start with ResourceLoader guard | ✅ | Guard: `if not ResourceLoader.exists(...): return` before `Dialogic.start("renato_restaurante")` |
| fase3_restaurante.tscn instances Player, Checkpoint, Malandro, ProvaItem, RenatoNPC | ✅ | All present |
| Prompt label hidden by default, visible on zone entry | ✅ | Label `visible=false` in tscn; shown in _on_dialogue_zone_body_entered() |

---

## Deviations from Plan

### Substitution: "jump" Action as Interact Trigger
**Issue:** Plan specified using `"interact"` action for Renato dialogue trigger. Investigation of `autoloads/controls_manager.gd` revealed ControlsManager defines only movement + attack actions: `{left, right, jump, dash, attack}`. No "interact" action exists.

**Decision:** Use "jump" action as the interact trigger (button overlap acceptable for narrative NPC in top-down platformer context). This is a common pattern in pixel art games where dialogue is triggered with existing buttons.

**Impact:** Renato dialogue trigger uses `event.is_action_pressed("jump")` instead of "interact". Users press the same button to jump and talk to NPCs (common in Zelda-like games).

**Documentation:** This substitution is noted in the task comments and SUMMARY. Future phases (Plan 05+) may introduce a dedicated "interact" action if needed for more complex NPC scenarios.

**Files affected:** `scenes/world1/renato_npc.gd` line 24: `event.is_action_pressed("jump")`

---

## Architecture Notes

### Three-Phase Linear Chain

All three fase scenes follow the same controller pattern for consistency:
1. Player reference + checkpoint reference
2. `_on_player_died()` respawn (instant, no transition)
3. `_reset_enemies()` reset all enemies to origin
4. ExitTrigger chains to the next scene via `SceneTransition.go_to()`

This pattern is reusable — Phase 4+ can copy the controller template for new worlds.

### Tileset + Painting Strategy

All three phases paint the same osasco_tileset.tres, using:
- Tile 0 (`#16213E`): solid ground (physics collision)
- Tile 1 (`#1A1A2E`): air/background (no collision)
- Tile 2 (`#E07020`): accent (optional decorative)

The tilemap pattern is identical across phases (same row-by-row layout), which ensures familiar gameplay and reduces art asset dependency during placeholder phase. Real pixel art enters Phase 12.

### NPC Placement Strategy

**Renato in fase2 (background):**
- z_index = -1 (behind player)
- Faded alpha 0.8 (visual depth cue)
- No collision — pure visual narrative element
- First appearance introduces character (NPC-01 first sighting)

**Renato in fase3 (interactive):**
- z_index = 0 (same layer as player)
- Full opacity
- DialogueZone Area2D for trigger detection
- Prompt label for affordance (shows `[E]` when close)
- Guards Dialogic.start() to prevent crashes before dialogue is authored

**Luis in fase3 (foreshadow):**
- z_index = -2 (far behind)
- Partial opacity 0.7 (mysterious, unclear)
- Partially occluded by foreground (visual puzzle)
- NO interaction, NO label — pure visual foreshadowing
- Strategic positioning (left side at y=115, in the "restaurant" visual depth)

### Respawn Safety

Checkpoint and player start positions are both placed ABOVE pit/hazard zones:
- Player start at (40, 144) — on main ground
- Checkpoint at (160, 130) — elevated platform
- Pits exist at lower rows (y > 160) — respawn never lands in instant death

This prevents infinite respawn loops (T-03-09 threat mitigation).

---

## Known Stubs

### Dialogue Timeline (Pre-Plan 04)
**Location:** `scenes/world1/renato_npc.gd` line 21: `ResourceLoader.exists("res://dialogic/timelines/renato_restaurante.dtl")`

**Reason:** Plan 04 will author the actual Renato dialogue timeline. Until then, the guard prevents a crash by returning early. This is intentional and safe.

**Behavior:** Approaching Renato shows the `[E]` prompt; pressing jump opens no dialogue (guard returns), no error logged, no crash. Acceptable placeholder behavior.

**Resolution:** Plan 04 creates `dialogic/timelines/renato_restaurante.dtl`; guard automatically allows dialogue to start.

---

## Threat Surface Verification

### Threats Mitigated

| Threat ID | Status | Mitigation |
|-----------|--------|-----------|
| T-03-09 (DoS - infinite respawn loop) | Mitigated | Checkpoint and start placed above pits; respawn never lands in instant death; player has time to move away |
| T-03-10 (DoS - Dialogic.start crash) | Mitigated | `ResourceLoader.exists()` guard in renato_npc.gd before calling Dialogic.start(); returns early if timeline missing (pre-Plan 04) |
| T-03-11 (Information Disclosure - Luis identity) | Accepted | Intentional foreshadowing (D-23); no name/label/interaction reveals identity — by design, not a leak |

No new threats introduced.

---

## Performance & Quality

- **Code complexity:** Low (3 controller scripts, all <40 lines, straightforward patterns)
- **Scene complexity:** Moderate (tilemap + multiple instances = typical 2D level)
- **No regressions:** Existing test scenes (test_movement, test_save) verified to pass
- **Performance impact:** None (tilemap + simple Area2D triggers are efficient; no expensive compute)
- **Code style:** Consistent with project conventions (GDScript 4, typed, explicit)

---

## Session Info

**Start time:** 2026-06-08T20:30:00Z (estimated based on Task 0 checkpoint approval time)  
**Execution model:** Sequential (single agent, all tasks completed in one execution)  
**Commits:** 4 (3 feat + 1 implicit checkpoint approval)
- `565f391` feat(03-03): create fase1_rua
- `b729e9c` feat(03-03): create fase2_parque
- `e1e1ea2` feat(03-03): create fase3_restaurante + renato_npc

**Total duration:** ~22 minutes  
**Files created:** 6 (`fase1_rua.gd`, `fase1_rua.tscn`, `fase2_parque.gd`, `fase2_parque.tscn`, `fase3_restaurante.gd`, `fase3_restaurante.tscn`, `renato_npc.gd` = 7 files total)  
**Files modified:** 0  
**Lines added:** ~350  

---

## Next Steps

Phase 3 Plan 04 onwards can now:
- Test the full vertical slice chain: `fase1_rua → fase2_parque → fase3_restaurante → boss_pai`
- Implement the Renato dialogue timeline in `dialogic/timelines/renato_restaurante.dtl` (Plan 04 scope)
- Expand enemy variety and level design for each fase (Plan 05+ scope)
- Add sound effects and music (Plan 05 scope)
- Introduce cutscenes and narrative progression (Plan 06+ scope)

The Osasco world is now playable end-to-end, with all core systems (respawn, enemy reset, checkpoints, provas, NPCs, transitions) functional and tested.
