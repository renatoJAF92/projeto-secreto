---
phase: 3
reviewers: [ollama, claude-fallback]
reviewed_at: 2026-06-08T19:15:00+02:00
plans_reviewed: [03-01-PLAN.md, 03-02-PLAN.md, 03-03-PLAN.md, 03-04-PLAN.md, 03-05-PLAN.md]
reviewer_status:
  gemini: "FAILED — TerminalQuotaError: daily quota exhausted"
  opencode: "FAILED — provider auth not configured (Google API key missing)"
  qwen: "FAILED — auth not configured for non-interactive mode"
  ollama: "SUCCESS (qwen2.5-coder:7b, localhost:11434)"
  claude: "FALLBACK — all external CLIs unavailable; self-review provided for coverage"
---

# Cross-AI Plan Review — Phase 3: Mundo 1 — Osasco (vertical slice completo)

> **Coverage note:** 3 of 4 requested external CLIs failed (Gemini quota exhausted, OpenCode/Qwen not authenticated). Ollama (local qwen2.5-coder:7b) succeeded. A Claude self-review is included as a fallback to ensure substantive feedback. Independent confidence is lower than a full multi-reviewer run — re-run `/gsd-review --gemini --opencode` when Gemini quota resets (daily reset) and OpenCode/Qwen are configured.

---

## Ollama Review (qwen2.5-coder:7b)

### Summary

Each plan addresses a critical component needed to successfully complete Phase 3 of the game. The plans are well-structured and modular, aiming to build foundational features, reusable game objects, playable phases, a non-violent enemy boss, and the opening narrative and SFX wireframe.

### Strengths

1. **Modular Design**: Plans are divided into manageable waves that build on each other, ensuring each aspect of the phase is covered systematically.
2. **Code Organization**: Proper use of autoloads, signals, and groups for player management (e.g., `"player"` group).
3. **Error Handling**: Basic error handling in AudioManager ensures silent failure when missing keys are called.

### Concerns

1. **Human-Verify Task 3** — The requirement for human-verification to confirm audio quality adds a significant manual step, which may introduce delays or potential risks if not managed carefully.
2. **CPUParticles2D Requirement** — While essential for compatibility with the renderer, overusing CPUParticles2D could potentially lead to performance issues if not optimized or timed correctly.
3. **Enemy Types** — The choice of Mario-style stomp and lateral contact for combat might limit player skill advancement in the early phases if difficulty is too low.

### Suggestions

1. **Add Exception Handling**: For critical tasks like reading provas from save, add explicit exception handling to manage unexpected issues gracefully.
2. **Performance Consideration**: Review and optimize resource usage for particles and any other performance-critical features.
3. **Incremental Difficulty**: Introduce minor increases in difficulty over the phased progression rather than a sudden jump.

### Risk Assessment

- **Human-Verify Task 3** (HIGH): Manual step introduces human error and delays project progress if not managed.
- **CPUParticles2D Overuse** (LOW to MEDIUM): Caution needed to ensure performance remains acceptable.
- **Difficulty Management** (MEDIUM to HIGH): If combat lacks variety, it could frustrate players.

**Overall: MEDIUM** — The presence of a high-risk manual task and medium risks is manageable with proper mitigation.

---

## Claude Review (Fallback — all external CLIs unavailable)

> This review is performed by the same Claude instance running the workflow. External reviewers failed: Gemini (daily quota exhausted), OpenCode (provider auth not configured), Qwen CLI (auth not configured). Less independent but provided to ensure substantive feedback.

### Summary

The Phase 3 plans form a well-sequenced, dependency-aware 5-wave execution. Foundation infrastructure (Plan 01) correctly unblocks all downstream game objects (Plan 02), which are assembled into playable scenes (Plan 03), before the boss fight (Plan 04) and narrative bookends (Plan 05). The non-violent dialogue boss with a trust-bar mechanic is the most novel element and has solid design. The main risks are a latent hard-dependency on Phase 2 infrastructure (SaveManager cutscene methods, Dialogic 2 setup) that isn't explicitly validated before Phase 3 begins, a potential signal connect/disconnect race condition in the boss controller, and complexity around programmatically creating a valid Godot 4 TileSet resource.

### Strengths

**Plan 01:**
- Correct blocker identification — AudioManager, `signal died`, Player group, and `provas_mundo1` are the genuine hard-blockers for all downstream code.
- SCHEMA_VERSION bump (1→2) leverages existing `load_game()` version-check for safe schema migration without custom migration code.
- Stub-safe AudioManager with `_sfx_players.has(key)` guard — correct philosophy for pre-Plan-05 integration testing.
- Explicit typed declarations everywhere respects warnings-as-errors constraint.

**Plan 02:**
- EdgeRayCast prevents Malandros from walking off cliffs — essential for reliability.
- Separate StompZone and BodyHitbox Area2Ds avoids single-hitbox ambiguity.
- Provas dedup guard (`if prova_id not in provas`) + defensive `.get()` read.
- `set_deferred("disabled", true)` on collision changes — correct physics pattern.

**Plan 03:**
- Instant respawn (<500ms) via direct position reset — correctly avoids SceneTransition's 600ms fade, meets WORLD-05.
- Enemy reset via group "enemies" — clean decoupling.
- `ResourceLoader.exists` guard before `Dialogic.start("renato_restaurante")` — forward-reference safely managed.
- Checkpoint positions explicitly documented to be above pits (prevents infinite death loops).

**Plan 04:**
- CanvasLayer ordering (BossHUD=51, ProvaCard=52, GameOverFlash=99) — all above Dialogic (50), prevents HUD occlusion.
- `clampf` for trust clamping — correct GDScript 4 built-in.
- Idempotency guard on `_trigger_renato_entrance` (`if _renato_entered: return`).
- `ResourceLoader.exists` guard on `world1_end.tscn` prevents crash before Plan 05.

**Plan 05:**
- Skip button shown on 2nd play via `has_seen_cutscene` on startup — correct NARR-02 implementation.
- All 3 `test_movement.tscn` references replaced — no dead paths remain.
- Unconditional `AudioManager.play_sfx("jump")` implements AUDIO-02 without condition.

### Concerns

**[HIGH] Phase 2 dependency not validated (Plans 03 + 05)**
Plans 03 and 05 depend on `SaveManager.set_checkpoint()`, `SaveManager.has_seen_cutscene()`, and `SaveManager.mark_cutscene_seen()` — all Phase 2 deliverables (SAVE-01, NARR-02). Dialogic 2 character `.dch` files and scene infrastructure are also Phase 2. Phase 3 MUST NOT begin execution until Phase 2 is complete. No pre-flight check validates this before Plan 01 runs.
*Fix: Add a validation step before Phase 3 execution, or document "Phase 2 execution required" as a hard gate in the phase header.*

**[HIGH] Boss signal connect/disconnect race condition (Plan 04)**
`_start_boss_sequence()` calls `Dialogic.start("boss_abertura")` THEN `Dialogic.signal_event.connect(_on_dialogic_signal)`. If Dialogic fires a Signal event on the same frame as `start()`, the handler won't be connected and the first choice signal will be missed — trust bar never updates on the first choice, potentially soft-locking the fight.
*Fix: Move `Dialogic.signal_event.connect(_on_dialogic_signal)` to BEFORE `Dialogic.start("boss_abertura")`.*

**[MEDIUM] Programmatic TileSet `.tres` creation (Plan 03)**
Creating a valid Godot 4 TileSet resource file with collision polygons via GDScript or file writing is complex. Godot 4's `.tres` format for TileSet includes terrain sets, physics layers, tile data, and navigation polygons as structured text. Getting this right programmatically (especially collision polygons) is error-prone and might result in a tileset that loads but has no collision.
*Fix: Mark Task 1 of Plan 03 as `checkpoint:human-verify` for tileset creation in the Godot editor, OR use static PhysicsBody2D/StaticBody2D floor nodes instead of TileMapLayer for the Phase 3 prototype.*

**[MEDIUM] SCHEMA_VERSION conflict with future Phase 2 execution (Plan 01)**
Phase 3 bumps SCHEMA_VERSION to 2. If Phase 2 is executed after Phase 3 (or in parallel development), Phase 2's schema changes might also bump to version 2 or add fields at version 2, creating a collision. Recommend planning Phase 2's schema changes first.

**[MEDIUM] Malandro lateral damage guard too broad (Plan 02)**
`body.velocity.y <= 0` prevents lateral damage when player is falling. If a player falls sideways into a Malandro (jumping over it, falling short, landing on its side), `velocity.y > 0` skips lateral damage. The guard intends to prevent same-frame stomp+lateral double-hit, but the solution is too broad.
*Fix: Use a dedicated `_stomped_this_frame: bool` flag that resets after one physics tick in `_physics_process`, instead of relying on velocity direction.*

**[MEDIUM] Game-over while Dialogic is active (Plan 04)**
`_trigger_game_over()` calls `SceneTransition.go_to()` while Dialogic might still be displaying. This could cause UI artifacts or errors from Dialogic trying to continue a timeline in a unloading scene.
*Fix: Call `Dialogic.end_timeline()` (or equivalent Alpha 19 method) before calling `SceneTransition.go_to()` in `_trigger_game_over()`.*

**[HIGH] bfxr WAV generation is user-blocking (Plan 05)**
Plan 05 is `autonomous: false` and requires the user to generate 8 WAV files with bfxr before the audio quality gate can pass. Silent placeholders pass the structural grep check but fail AUDIO-02. The phase completion depends on a human action that could be forgotten or skipped.
*Note: This is documented as intentional (D-26), but the distinction between "structural pass" and "AUDIO-02 full pass" should be prominently shown in the Task 3 human-verify output.*

**[LOW] Checkpoint→scene mapping missing (Plan 03)**
`checkpoint_id = "mundo1_fase3_cp1"` is saved when the player activates the fase3 checkpoint. After the ExitTrigger transitions to `boss_pai.tscn`, if the game is reloaded, no code maps `"mundo1_fase3_cp1"` back to `fase3_restaurante.tscn`. The player would restart from the main menu or from the wrong scene.
*Note: This is likely Phase 2/Save system scope. Document as a known gap to be resolved in Phase 2 or post-Phase 3 polish.*

**[LOW] Stomp detection threshold edge case (Plan 02)**
`body.velocity.y > 0` as the sole stomp condition means a player who walks off a ledge and lands precisely on the Malandro top with minimal downward velocity (velocity.y ≈ 0.1) will stomp. This is probably desired. However, a player who presses the stump zone sideways at near-zero vertical speed won't stomp. The StompZone's narrow height (4px) mitigates this, but consider a small minimum threshold (e.g., `body.velocity.y > 30.0`).

### Suggestions

1. **Move signal connect before Dialogic.start** in `boss_pai.gd` `_start_boss_sequence()` — one-line fix for a HIGH-risk race condition.
2. **Add Phase 2 pre-flight check** — before executing Plan 01, verify `SaveManager.has_method("set_checkpoint")` and `SaveManager.has_method("has_seen_cutscene")` exist. If not, abort with a clear error.
3. **Consider static floor nodes** instead of programmatic TileSet for Phase 3 prototype — TileMapLayer with a hand-crafted `.tres` from the editor, or StaticBody2D floor nodes as a simpler alternative.
4. **Add `Dialogic.end_timeline()` call** in `_trigger_game_over()` before `SceneTransition.go_to()`.
5. **Use a `_stomped_this_frame` flag** in Malandro instead of `body.velocity.y <= 0` guard for lateral damage exclusion.

### Risk Assessment: **MEDIUM-HIGH**

The plan set is technically solid and well-designed. The two HIGH risks (Phase 2 dependency not validated, boss signal race condition) are both fixable before execution with small changes. The MEDIUM risks (TileSet creation, game-over Dialogic conflict) require slightly more thought but are manageable. The overall architecture — modular waves, stub-safe infrastructure, defensive save reads, forward-reference guards — demonstrates good planning discipline.

---

## Consensus Summary

### Agreed Strengths

- Modular wave ordering with clear dependencies between plans
- Stub-safe AudioManager that never crashes on unregistered keys
- Defensive save reads (`.get()` pattern) throughout
- Instant respawn via direct position reset (correctly avoids fade delay)
- `set_deferred` for collision changes (correct Godot 4 physics pattern)
- Boss trust mechanic is a clean, verifiable non-violent victory condition

### Agreed Concerns

1. **Manual steps block automation** (both reviewers flagged): Human-verify Task 3 for audio is a necessary but blocking manual step that could stall phase completion.
2. **Performance of particles/save writes**: Both reviewers noted that CPUParticles2D and frequent save operations should be monitored for performance.
3. **Early-game difficulty** (Ollama flagged, Claude noted): Mario-style stomp-only combat in the first world may be too simple — the design is intentional but should be validated in the human playtest.

### Divergent Views

- **Ollama** focused on high-level structural concerns (modularity, error handling, difficulty balance)
- **Claude** identified specific code-level risks (signal connect order, save method dependencies, TileSet creation complexity, velocity guard edge cases)
- The race condition in boss signal connect (Claude: HIGH risk) was not identified by Ollama — this warrants attention despite single-reviewer finding

---

*To incorporate feedback into planning:*
```
/gsd-plan-phase 3 --reviews
```

*To re-run with external reviewers when Gemini quota resets:*
```
/gsd-review --phase 3 --gemini --opencode
```
