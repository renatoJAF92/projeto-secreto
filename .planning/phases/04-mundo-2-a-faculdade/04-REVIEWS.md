---
phase: 4
reviewers: [ollama]
reviewed_at: 2026-06-09T12:55:00Z
plans_reviewed: [04-01-PLAN.md, 04-02-PLAN.md, 04-03-PLAN.md, 04-04-PLAN.md, 04-05-PLAN.md]
skipped: [claude (running inside Claude Code)]
unavailable: [gemini (quota exhausted), opencode (provider auth error — needs Google API key configured in opencode settings), qwen (auth not configured), codex (not installed), cursor (not installed)]
---

# Cross-AI Plan Review — Phase 4: Mundo 2 — A Faculdade

## Ollama Review (qwen2.5-coder:7b)

## Summary

Plan 01, 02, and 04 cover essential systems such as save/load, player power states, and projectile mechanics. Plan 03 handles the core gameplay for Mundo 2, while Plan 05 provides the culminating boss fight, cutscene, and conclusion of Phase 4.

## Strengths

- **Separation of Concerns:** Each plan focuses on a specific module (save/load, player powers), making them modular and easier to review.
- **Modular Implementation:** Plans are well-isolated from dependencies until they are needed, which reduces complexity.
- **Progressive Build-Up:** Worlds 1 completes the core mechanics before expanding into each subsequent phase with additional features and systems.

## Concerns

1. **Dependency Order:**
   - **HIGH** — Plan 03 depends on Plans 01 and 02 being fully implemented to function properly. However, if these plans are not completed as specified or encounter issues, it could severely impact Phase 4's success.

2. **Edge Cases and Error Handling:**
   - **MEDIUM** — There is a need for thorough error handling, especially in transition scenes and power-ups, to ensure seamless execution of complex interactions.

3. **Over-Engineering:**
   - **LOW** — While the current plans do not appear overly complex or over-engineered, careful review of these plans is necessary to prevent unnecessary bloat. Specifically, ensuring that every feature is genuinely needed or simplifying some if deemed overly complicated.

4. **Quality Bar and Boss Fight Mechanics:**
   - **MEDIUM** — Quality bar mechanics need robust testing to validate their performance under different player choices. Similarly, the boss fight should be rigorously tested for consistency and fairness across multiple playthroughs to prevent frustration or trivialization of gameplay.

5. **Dialogic Integration:**
   - **LOW** — Ensure Dialogic is correctly integrated into the scenes with proper signal events. The issue addressed in "Plan notes" about the order of signal connections should be confirmed as fixed.

## Suggestions

1. **Dependency Management:** Clearly document which parts of each phase are dependent on others and verify that all dependencies are met before advancing to subsequent phases.
2. **Comprehensive Testing:** Plan meticulous testing protocols for all systems included in these plans, especially around edge cases where player interaction with power-ups, enemy respawn mechanics, and quality bar thresholds occur.
3. **Refinement of Power-Up Mechanics:** Ensure each power-up (Sketch, Amor, etc.) is balanced and useful without causing frustration or over-simplify if the functionality seems redundant.

## Risk Assessment

**LOW** — The phases are well-defined with clear dependencies between them. However, risks introduced due to incomplete or misimplemented plans can potentially derail Phase 4 unless they are promptly addressed.

---

## Gemini Review

*Unavailable — Gemini API quota exhausted on 2026-06-09. Retry tomorrow.*

---

## OpenCode Review

*Unavailable — OpenCode provider requires Google Generative AI API key configured in opencode settings. Run `opencode providers` to configure.*

---

## Consensus Summary

*Synthesized from Ollama review + direct plan analysis by reviewing agent.*

### Agreed Strengths

- **Wave structure is well-designed**: Plans 01+02 run in wave 1 (foundation), Plans 03+04 in wave 2 (content), Plan 05 in wave 3 (boss). Clear progressive dependency.
- **Copy-pattern strategy reduces risk**: Every new scene/script copies from an established Phase 3 pattern (checkpoint.gd, malandro.gd, fase1_rua.gd, boss_pai.gd). This avoids starting from scratch and preserves tested behaviors.
- **Schema migration is defensive**: v2→v3 upgrade in Plan 01 handles old saves in-place with `.get()` fallbacks. No breaking changes to existing players.
- **Boss gate is well-specified**: ≥3 items required before boss entry is enforced at the code level (not just by design). Threshold escalation is capped with `minf()` to prevent impossible scenarios.
- **Dialogic signal ordering fixed**: Plans explicitly connect `Dialogic.signal_event` BEFORE calling `Dialogic.start()`, addressing the known Phase 3 lesson.
- **Security/threat model per plan**: Each plan includes STRIDE analysis appropriate for a single-player offline game.

### Agreed Concerns

**[HIGH] Plans 01 and 02 both modify `scenes/player/player.gd` in Wave 1 (parallel)**
- Plan 01 adds power state variables + input handling + use_power/cycle_power/unlock_power methods to player.gd
- Plan 02 adds hp variable + take_damage/heal methods to player.gd
- Both are in `wave: 1` with `depends_on: []`, meaning they'd execute in parallel if the executor runs them that way
- **Risk**: Merge conflict or overwrite between the two plans editing the same file
- **Fix**: Executor should treat player.gd modifications as sequential, or explicitly note that Plan 02's player.gd edits must happen AFTER Plan 01's. Consider adding `depends_on: [04-01]` to Plan 02 for the player.gd task specifically.

**[HIGH] `first_child_of_type(CharacterBody2D)` is not a standard Godot 4 API**
- Referenced in Plan 02 (`power_hud_indicator.gd`), Plan 03 (`professor_careca_comment.gd`, `renato_cafe_npc.gd`)
- Godot 4's actual API for this pattern is `get_tree().get_first_node_in_group("player")` (if player is in "player" group) or a direct `@onready` reference via scene structure
- **Risk**: Script crashes at runtime with "method not found" error; none of the nodes that need the player reference will function
- **Fix**: Replace all `get_tree().first_child_of_type(CharacterBody2D)` calls with `get_tree().get_first_node_in_group("player")` (requires player to be in "player" group, which is standard) or use a direct node path reference

**[MEDIUM] Power HUD placed in `scenes/world2/` but needs to be global**
- `power_hud_indicator.tscn` is world2-specific per Plan 02
- The power system is retroactive — Sketch/Amor are usable in Mundo 1 revisits too
- A world2-scoped HUD won't appear when player revisits earlier worlds
- **Fix**: Consider placing the power HUD in the player scene itself (as a CanvasLayer child of the player) or in a global HUD scene that all worlds instance

**[MEDIUM] Renato café NPC heals on every dialogue trigger (no one-shot guard)**
- Plan 03 Task 6 copies renato_npc pattern but adds `player.heal(1)` after `await Dialogic.timeline_ended`
- No `_activated` or one-shot guard on the NPC (unlike the checkpoint)
- **Risk**: Player can spam dialogue interaction to get infinite heals
- **Fix**: Add a `_has_healed: bool = false` guard to renato_cafe_npc.gd (same pattern as `_activated` in checkpoint_cafe.gd)

**[MEDIUM] Sketch projectile spawned with `get_parent().add_child(proj)` — node tree coupling**
- Plan 04 Task 2: projectile is added to player's parent node
- If the player scene is nested or the parent changes, projectiles could be parented to unexpected nodes
- **Fix**: Use `get_tree().current_scene.add_child(proj)` or a dedicated `Projectiles` node added via `$"/root/GameScene/Projectiles"` for deterministic parenting

**[LOW] Plan 04 verify check uses `def` instead of `func`**
- `grep -c "def _use_sketch_power"` — GDScript uses `func`, not Python's `def`
- The automated verify will always output `0` and appear to fail
- **Fix**: Change to `grep -c "func _use_sketch_power"`

**[LOW] SaveManager v3 schema missing `worlds_completed` awareness check**
- Plan 05 boss victory calls `SaveManager marks mundo2 complete` (adds to `worlds_completed[]`)
- Plan 01's v3 migration only adds `active_power` and `itens_tfg_mundo2`
- `worlds_completed` presumably exists from Phase 3's schema, but no explicit verification is planned
- **Fix**: Add a verify step in Plan 05 or Plan 01 to confirm `worlds_completed` key exists in the schema with `SaveManager.current_save.get("worlds_completed", [])`

### Divergent Views

- **Dependency risk**: Ollama considers dependency order a HIGH concern. Direct plan analysis finds the wave structure sound — the real dependency risk is specifically Plans 01+02 sharing player.gd (see above), not a general ordering issue.
- **Risk assessment**: Ollama rates overall risk as LOW. Direct analysis finds 2 HIGH issues (player.gd conflict, non-existent API) that could cause runtime crashes. Actual risk: **MEDIUM** pending those two fixes.

---

## Priority Action Items Before Execution

1. **[CRITICAL]** Add `depends_on: [04-01]` to Plan 02, or explicitly serialize player.gd modifications (Plan 01 first, Plan 02 second)
2. **[CRITICAL]** Replace all `first_child_of_type(CharacterBody2D)` calls with `get_tree().get_first_node_in_group("player")` in Plans 02 and 03
3. **[RECOMMENDED]** Add one-shot guard `_has_healed: bool` to `renato_cafe_npc.gd`
4. **[RECOMMENDED]** Move power HUD to player scene (world-agnostic) instead of scenes/world2/
5. **[MINOR]** Fix Plan 04 verify grep: `def` → `func`
6. **[MINOR]** Add `worlds_completed` key existence check to Plan 01 or 05 verification

```
To incorporate feedback into planning:
  /gsd-plan-phase 4 --reviews
```
