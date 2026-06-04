---
phase: 2
reviewers: [gemini, ollama]
reviewed_at: 2026-06-04T00:00:00Z
plans_reviewed:
  - 02-001-natalia-sprite-portraits-PLAN.md
  - 02-002-autoloads-foundation-PLAN.md
  - 02-003-main-menu-PLAN.md
  - 02-004-options-menu-remap-PLAN.md
  - 02-005-dialogic-characters-dialogue-PLAN.md
skipped: [claude (self), opencode (empty output), qwen-cli (empty output)]
ollama_model: qwen2.5-coder:7b
---

# Cross-AI Plan Review — Phase 2: Infraestrutura

---

## Gemini Review

This is a comprehensive and well-structured infrastructure plan for **Jogo da Natália**. The division into waves with clear dependency tracking demonstrates a solid understanding of Godot's architecture. The decision to use a binary save format and avoid storing raw X/Y coordinates is particularly professional, as it prevents "save corruption" due to level design changes.

However, there are technical nuances regarding input handling in Godot 4 and the stability of Dialogic 2 (Alpha) that should be addressed to ensure a smooth implementation.

### 1. Summary
The plan successfully addresses the core infrastructure requirements (Save, Transition, Controls, Dialogue). It prioritizes stability by using `FileAccess` for binary saves and `CanvasLayer` for transitions. The parallelization of Wave 1 (Sprites vs. Foundation) is efficient. The most critical paths are the Dialogic 2 integration and the Input Remapping logic, both of which are prone to edge-case bugs in Godot 4.

### 2. Strengths
- **Robust Save Logic:** Storing `checkpoint_id` instead of `position: Vector2` (D-02) is an excellent choice to prevent players from spawning inside modified geometry after a game update.
- **Autoload Ordering:** The explicit mention of Dialogic's registration order (Plan 02, Task 4) is crucial; Dialogic 2 often crashes if its internal subsystems aren't initialized before custom scripts call them.
- **Layer Management:** Setting `SceneTransition` to `layer=100` ensures it stays above all gameplay and most UI elements.
- **Clean API Design:** The `ControlsManager` separate from `SaveManager` allows "Reset to Defaults" for controls without wiping story progress, which is a significant UX win.
- **Human-Verify Gates:** The inclusion of manual check-points for visual assets and remapping persistence is a realistic approach for a solo dev.

### 3. Concerns
- **Analog Stick Jitter during Remapping (HIGH):** In Plan 04, capturing `InputEventJoypadMotion` for remapping is dangerous. Even a slight "drift" or jitter on an analog stick can trigger a remap before the player presses the intended button.
- **Lack of "New Game" Confirmation (MEDIUM):** Plan 03 triggers `new_game()` immediately on a button flash. If a single save slot is used (D-01), an accidental click on "New Game" would permanently erase the player's progress without a "Are you sure?" prompt.
- **Dialogic 2 Alpha 19 Stability (MEDIUM):** Dialogic 2 is in active development. Alpha 19 is relatively stable but has known issues with "headless" execution and specific signal cleanup.
- **Portrait Scale (LOW):** 80px height in a 180px viewport is nearly 45% of the screen height. While JRPG-style, this might obscure significant gameplay or background art if the dialogue box is also large.
- **Python Quantization Quality (LOW):** Median-cut quantization without a fixed palette often produces "muddy" pixel art from real photos.

### 4. Suggestions
- **Input Thresholding:** For the `ControlsManager` remap logic, implement a threshold check for `InputEventJoypadMotion` (e.g., `if abs(event.axis_value) > 0.5`) to prevent stick drift from hijacking the remap UI.
- **Safe Save Writing:** In `SaveManager`, use `FileAccess.open` "Write" mode with atomic write pattern: write to `save.dat.tmp` then `DirAccess.rename` to replace the old save only after a successful write.
- **Confirmation Dialog:** Add a simple confirmation popup to the "New Game" button in Plan 03 if `SaveManager.save_exists()` is true.
- **Action Mapping Specifics:** In Godot 4, ensure `InputMap.action_erase_events(action)` is called before `InputMap.action_add_event(action, event)` during remapping to prevent multiple keys being bound to the same action.
- **Palette Enforcement:** In the Python script, consider using a specific 16-color palette (like **DB16** or **PICO-8**) rather than generic median-cut to give the generated sprites a more cohesive look.

### 5. Risk Assessment
**Overall Risk: MEDIUM**

The logic for saving and scene transitions is low-risk and standard. The "Medium" rating comes from **Dialogic 2 Alpha** and **Gamepad Remapping**. If Dialogic 2 Alpha 19 has a breaking change or if the gamepad remapping captures an axis incorrectly, it could stall the Wave 3 implementation. The plan's modularity (Autoloads Foundation first) provides a strong enough base to pivot if a specific plugin fails.

**Verdict:** The plans are ready for implementation, provided the **Analog Jitter** and **New Game Confirmation** issues are addressed during the coding phase.

---

## Ollama Review (qwen2.5-coder:7b)

### Summary
Plan 01 focuses primarily on generating Natália's sprite and portrait assets, Plan 02 on setting up autoloads for saving and controls, Plan 03 on creating the main menu, Plan 04 on an options menu for remapping controls, and Plan 05 on integrating Dialogic 2 for dialogue. Each plan aims to build foundational elements of the game incrementally.

### Strengths
- **Plan 01:** Clear specifications for sprite sheet generation and integration into gameplay.
- **Plan 02:** Provides a well-defined structure for autoloads, crucial for managing saves, transitions, and controls across scenes.
- **Plan 03:** Focuses on a critical interface element that is essential for player interaction.
- **Plan 04:** Addresses control remapping, an important feature for enhancing accessibility.
- **Plan 05:** Sets up dialogue with characters and timelines, aligning well with narrative requirements.

### Concerns
- **Plan 01:** Error handling in the Python script is lacking (HIGH). No checks are included if the input photo doesn't exist or can't be processed.
- **Plan 02:** Potential issues with Dialogic registration order could cause null reference errors (MEDIUM). The plan explicitly documents this but doesn't provide a workaround.
- **Plan 03:** The main menu is quite minimal and lacks features like difficulty selection, level completion notifications, or high scores (LOW).
- **Plan 04:** There's no consideration for keyboard vs gamepad control interaction outside of remapping (LOW), which could affect usability.
- **Plan 05:** While the plan outlines a basic dialogue system, it does not touch on voice-over scenarios or complex branching logic that might be necessary in a full game (MEDIUM).

### Suggestions
- **Plan 01:** Add robust error handling to ensure script correctness and resilience against issues like missing files.
- **Plan 02:** Introduce a fallback mechanism for Dialogic registration order to prevent critical errors. If the initial approach fails, allow a retry or fallback solution.
- **Plan 03:** Consider adding features like difficulty selection and score tracking if time permits without compromising plan scope.
- **Plan 04:** Extend the options menu to include settings for keyboard and gamepad control defaults.
- **Plan 05:** Expand the dialogue system to accommodate more complex scenarios, such as voice-over integration or dynamic dialogue choices.

### Risk Assessment
**Overall Risk Level: MEDIUM**

The plan has some significant risks, particularly with Dialogic registration order. Addressing these through error handling and fallback mechanisms will mitigate risk. Additionally, incomplete features may limit functionality but are manageable given the incremental approach of the phases.

---

## Consensus Summary

Both reviewers assessed **MEDIUM** overall risk, converging on the same top concerns.

### Agreed Strengths
- **Save architecture is solid:** Storing `checkpoint_id` (not X/Y position) is explicitly praised by Gemini as a professional choice that prevents geometry-change bugs across game versions.
- **Autoload ordering discipline:** Both reviewers flag the Dialogic-before-custom-autoloads constraint as important; both note the plan documents it clearly.
- **ControlsManager isolation:** Separating controls persistence from save progress is a clean UX decision praised by Gemini; Ollama confirms the design is well-defined.
- **Wave-based parallelization:** Plan 01 + Plan 02 running in Wave 1 (parallel) is noted as efficient.

### Agreed Concerns

1. **Analog stick jitter in remap capture (HIGH — Gemini):** When `options_menu.gd` awaits `InputEventJoypadMotion`, stick drift can fire the remap unintentionally. **Fix:** Add `if abs(event.axis_value) > 0.5` threshold guard in `_input()` before calling `ControlsManager.remap_action()`. This is a code-level fix during Plan 04 execution.

2. **Dialogic 2 Alpha 19 stability / registration order (MEDIUM — both):** Alpha software with known headless-mode quirks. The plan documents the ordering constraint but does not have a fallback if Alpha 19 is incompatible with Godot 4.4.1. **Mitigation already present:** the plan says to stop and document if `--check-only` fails. Add: pin the exact Alpha 19 commit SHA in SUMMARY if download succeeds.

3. **"New Game" overwrites save without confirmation (MEDIUM — Gemini):** 1-frame red flash is too subtle for irreversible action. **Fix:** Show a `ConfirmationDialog` ("Apagar progresso?") before calling `SaveManager.new_game()` when a save exists.

4. **Python script missing error handling (HIGH — Ollama):** If `Photos/Natalia/IMG_20260222_212225.jpg` is missing or corrupted, the script will crash with an unhandled PIL exception. **Fix:** Wrap `Image.open()` calls in `try/except` with a clear error message, and verify the output size before saving.

### Divergent Views
- **Portrait scale (LOW — Gemini only):** 64×80px portrait on a 180px viewport = ~44% screen height. Gemini flags this as potentially obscuring gameplay; Ollama does not raise it. Worth monitoring in the human-verify gate of Plan 05 — if the dialogue box + portrait covers too much, reduce portrait height to 56px and crop tighter.
- **Scope of options menu (LOW — Ollama only):** Ollama suggests adding difficulty and score tracking to Plan 03/04. These are out of scope for Phase 2 (deferred to Phase 12 — Polish) and should NOT be added.
- **Palette quality (LOW — Gemini only):** Gemini suggests DB16/PICO-8 palette over generic MEDIANCUT. This is a preference for the pixel art aesthetic; the plan's 16-color MEDIANCUT approach is a valid pragmatic choice for a photo-to-pixel-art pipeline. Not a blocker.

---

## Action Items Before Execution

| Priority | Plan | Fix |
|----------|------|-----|
| HIGH | Plan 04 | Add `abs(event.axis_value) > 0.5` threshold in remap `_input()` |
| HIGH | Plan 01 | Wrap PIL `Image.open()` in `try/except FileNotFoundError, Exception` |
| MEDIUM | Plan 03 | Add `ConfirmationDialog` before `SaveManager.new_game()` when save exists |
| LOW | Plan 05 | Monitor portrait height in human-verify; reduce if obscures gameplay |

---

*To incorporate feedback: `/gsd-plan-phase 2 --reviews`*
