---
phase: 5
reviewers: [ollama]
reviewed_at: 2026-06-10T15:32:00Z
plans_reviewed: [05-01-PLAN.md, 05-02-PLAN.md, 05-03-PLAN.md, 05-04-PLAN.md]
skipped: [claude (self), gemini (daily quota exhausted), opencode (Gemini dependency), qwen (no auth)]
---

# Cross-AI Plan Review — Phase 5: Level Design Overhaul

## Gemini Review

> **Skipped:** Daily free-tier quota exhausted (HTTP 429). Retry tomorrow or upgrade to paid tier.

---

## OpenCode Review

> **Skipped:** OpenCode is configured with GEMINI_API_KEY only; inherited the same quota exhaustion.

---

## Qwen Review

> **Skipped:** Qwen Code CLI has no auth type configured. Run `qwen auth` to set up before next review.

---

## Ollama Review (qwen2.5-coder:7b, local)

### PLAN 01 — Shared Environmental Mechanics

**Summary**
Plan 01 sets up a framework for shared environmental mechanics that will be used across all fases. It includes creating the Camera2D and individual scenes for different mechanisms like moving platforms, damage zones, pushable boxes, and timed obstacles.

**Strengths**
- **Modular Design:** Each mechanic is designed as its own Node or scene, making it reusable.
- **Camera Control:** Proper setup of Camera2D ensures smooth scrolling and limit enforcement.
- **Ease of Management:** Individual scenes simplify the process of adding these mechanics to each fase.

**Concerns**
- **[MEDIUM] Complexity with Many Instances:** With many instances of each mechanic spread across fases, performance might suffer significantly in large scenes.
- **[LOW] Testing Overhead:** Each individual mechanic requires thorough testing in its own environment before integration.
- **[LOW] Resource Intensive:** Creating multiple instances may lead to increased memory and processing overhead.

**Suggestions**
- Implement basic collision handling for simple static obstacles like pushable boxes (no need for scripts if functionality is physics-based).
- Consider using scene inheritance instead of copying resources for similar enemies or mechanics.
- Performance profiling during development to gauge impact of large-scale instances.

**Risk Assessment**
MEDIUM — Potential performance issues with many active nodes and instances in large fases. Camera setup is generally straightforward, but extensive testing will be required for smooth gameplay.

---

### PLAN 02 — World 1 Level Expansion

**Summary**
Plan 02 expands the first three worlds from 1600px to 6400px width by populating fases with enemies, parallax backgrounds, and proper camera control. Key tasks include expanding backgrounds, setting up checkpoint scenes, adding mechanics, and creating specific enemy compositions unique to each fase.

**Strengths**
- **Comprehensive Level Design:** The inclusion of all required components (enemies, parallax, camera) ensures a richer gameplay experience.
- **Scripting Cohesion:** Camera settings are controlled through scripting, providing dynamic control over player movement and vision.
- **Parallax Integration:** Multiple layers for each fase offer depth and visual appeal.

**Concerns**
- **[HIGH] Implementation Order:** This plan directly depends on Plan 01. The completion of Plan 01 is essential before this can be implemented.
- **[MEDIUM] Enemy Placement Complexity:** Balancing enemies across different sections might require fine-tuning.
- **[LOW] Parallax Background Management:** Ensuring the parallax follows camera movements smoothly and scales correctly with camera zoom could be challenging.

**Suggestions**
- Introduce a system for auto-balancing enemy density based on fase length to ensure consistent challenge.
- Regularly check that camera scripts are interacting correctly with parallax layers to avoid any clipping or misalignment issues.
- Provide visual feedback during design sessions using the Godot editor to preview how the phased backgrounds will work in game.

**Risk Assessment**
HIGH — Potential issues arise from failing to implement Plan 01 first. Balancing enemies throughout fases will likely require multiple playtesting iterations.

---

### PLAN 03 — World 2 Level Expansion

**Summary**
Plan 03 mirrors the approach of Plan 02 for the second three worlds, adding distinct themes and enemy compositions while expanding from 1600px to 6400px width. Features thematic distinctions (ateliê pushable focus, madrugada hazard focus) and blue parallax tint.

**Strengths**
- **Scalable Architecture:** Extends the modular approach from Plans 01 and 02, ensuring consistency.
- **Focus on Theme:** Each fase gets its own theming and mechanics specific to the world's atmosphere.
- **Testing Efficiency:** Enemy balancing follows a structured process per foe type.

**Concerns**
- **[HIGH] Dependency Management:** Plan 03 relies on completion of Plans 01 and 02. Any delays propagate.
- **[MEDIUM] Overhead for Complex Fases:** If any fase requires complex mechanics or multiple instances, performance monitoring will be necessary.
- **[LOW] Error Handling on Implementation:** Missing enemy stomp effects or misplaced obstacles might require manual debugging.

**Suggestions**
- Introduce a system to automatically generate and test enemy placements within each fase based on predefined criteria (e.g., avoiding dense clusters or overlaps).
- Regular parallax preview checks during design sessions to ensure the background scrolls correctly.

**Risk Assessment**
MEDIUM — Structured dependency chain is clearly defined. The main risk is delays cascading from earlier plans.

---

### PLAN 04 — Enemy Variants + Integration

**Summary**
Plan 04 introduces three new enemy variants (Moto com Dois Homens, Malandro Resistente, Malandro Coraza) with unique behaviors and integrates them into all six fases. Includes a human verification checkpoint at the end.

**Strengths**
- **Diverse Enemy Pool:** Specific enemy variations add variety and depth to gameplay.
- **Complex Mechanisms:** Each variant has distinct behaviors that test the robustness of the game's systems.
- **Verification Workflow:** Human verification ensures each variant behaves correctly before integration is finalized.

**Concerns**
- **[HIGH] Integration Order:** Depends on completion of Plans 01 through 03; must be strictly maintained.
- **[HIGH] Testing Extensive Behavior Scenarios:** Each enemy type requires many scenario tests — stomp mechanics, dash detection, phase transitions.
- **[MEDIUM] Resource Management:** Creating and testing multiple variants may consume significant development time.

**Suggestions**
- Implement prototype testing for each enemy variant before full integration.
- Regularly test enemy interactions with obstacles, other enemies, and the player.
- Automated testing for repetitive triggers (stomp zone entry, phase 2 transition).

**Risk Assessment**
HIGH — Inter-dependencies on 3 previous plans plus the complexity of `_is_dashing` detection at stomp-time creates a real risk of subtle bugs in the Coraza variant.

---

## Consensus Summary

*Based on 1 reviewer (Ollama/qwen2.5-coder:7b). Gemini, OpenCode, and Qwen unavailable this session.*

### Agreed Strengths

- **Modular scene architecture** — Each mechanic and enemy as its own reusable `.tscn` is well-designed and follows Godot best practices.
- **Structured wave dependency chain** — Wave 1 → 2 → 3 → 4 dependency ordering is explicit and correct.
- **Verification coverage** — Human checkpoint in Plan 04 plus automated `grep`-based verifications in every task provide good quality gates.
- **Thematic differentiation** — World 2 fases each have a distinct mechanical emphasis (campus: mixed enemies, ateliê: pushable focus, madrugada: hazard focus) which will create gameplay variety.

### Agreed Concerns

1. **[HIGH] Dependency cascade risk** — Plans 02, 03, and 04 are all blocked until prior waves complete. Any bug in Plan 01 (e.g., Camera2D limit not applying correctly) will block all 3 subsequent waves.

2. **[HIGH] Malandro Coraza `_is_dashing` check fragility** — The dash-only kill mechanic reads `body._is_dashing` directly from the player at stomp-time. If the player's dash state is reset before the stomp zone signal fires, the check will always be false and the enemy will be unkillable. This is the highest-risk implementation detail across all 4 plans.

3. **[HIGH] Plan 04 `autonomous: false`** — Unlike Plans 01–03, Plan 04 cannot execute without human intervention. The human-verify checkpoint blocks full automation of the phase. Ensure the Godot project is in a playable state before reaching Wave 4.

4. **[MEDIUM] Performance with 6400px fases** — Each expanded fase will have 8–12 enemy instances + 3–4 mechanic instances + 2 parallax layers all active simultaneously. In Godot 4 this is generally fine, but should be profiled on target hardware (especially web export).

5. **[MEDIUM] Camera2D `limit_right` set in both player.tscn (6400) and fase scripts** — Redundant or conflicting. If player.tscn sets `limit_right=6400` globally and some fase has a different required width in the future, the per-scene script override is critical — but the task description says "call player.$Camera2D.limit_right = 6400" in each script, which is correct. Just ensure the player.tscn default doesn't silently conflict with a different value in tests.

### Divergent Views

None — single reviewer session.

### Reviewer-Added Concerns Not In Plans

1. **Camera2D `limit_right` hardcoded to 6400** — All 6 fase scripts set this same value. This works for Phase 5, but creates a maintenance risk if fase widths differ in future phases. Consider an exported variable on the fase script (e.g., `@export var fase_width: int = 6400`) and use that to set both the floor width and camera limit.

2. **`set_deferred("disabled", _is_open)` in timed_obstacle.gd** — This is the correct Godot 4 pattern for safe collision toggling mid-physics-step. Good call in the plan — but the verification grep (`grep -c "set_deferred.*disabled"`) should be confirmed to not match commented-out code.

3. **`continuous_cd=true` on pushable_box.tscn** — The plan specifies Continuous Collision Detection for the RigidBody2D. In Godot 4 this is `continuous_cd` property, which is correct. However, with `gravity_scale=3` and `mass=3`, the box will fall quickly — verify it doesn't clip through thin floors when dropped from height.

4. **`motion_mirroring=Vector2(6400, 0)` on parallax layers** — Good to prevent seams. Just verify this is set on the `ParallaxLayer` node (not `ParallaxBackground`) since the property lives on the layer in Godot 4.

---

*To incorporate this feedback into planning:*
```
/gsd-plan-phase 5 --reviews
```
