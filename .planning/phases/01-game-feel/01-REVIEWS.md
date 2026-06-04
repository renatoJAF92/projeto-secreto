---
phase: 01
reviewers: [gemini]
reviewed_at: 2026-06-04T00:00:00Z
plans_reviewed:
  - 01-001-core-movement-PLAN.md
  - 01-002-dash-knockback-animations-PLAN.md
  - 01-003-juice-effects-PLAN.md
---

# Cross-AI Plan Review — Phase 1: Game Feel

> Reviewed after phase completion (post-execution review).
> CLIs available at review time: Gemini 0.44.1.
> Skipped: claude (self, running inside Claude Code).
> Not available: codex, opencode, qwen, ollama, kimi, lm_studio.

---

## Gemini Review

The Phase 1 implementation plans for **"Jogo da Natália"** are exceptionally well-structured and technically sound. By prioritizing fundamental "Game Feel" (coyote time, jump buffering, and asymmetric gravity) before level construction, the project establishes a high-quality baseline. The choice of frame-based counters over Timer nodes demonstrates a deep understanding of platformer precision in Godot 4.

### 1. Summary

The overall phase quality is **Excellent**. The plans move beyond basic movement to address the "juice" and responsiveness that define modern 2D platformers. The adherence to strict technical constraints (`gl_compatibility`, `CPUParticles2D`) while implementing complex feel-mechanics like hit-stops and squash-and-stretch ensures a robust foundation for the upcoming worlds.

### 2. Strengths

- **Precision Timing:** Using 6/8 frame counters instead of standard Timer nodes ensures frame-perfect responsiveness that is perfectly synced with `_physics_process` logic.
- **Physics Architecture:** Asymmetric gravity and the "Jump Cut" multiplier are industry-standard implementations that prevent the movement from feeling "floaty."
- **Clean Juice Decoupling:** Modifying the `AnimatedSprite2D` for squash/stretch and white flashes, rather than the `CharacterBody2D` root, prevents visual effects from interfering with collision logic or physics calculations.
- **HTML5 Readiness:** Proactive use of `CPUParticles2D` avoids the common pitfall of developing a game that fails to render correctly on the web.
- **Debugging Foresight:** Including a live HUD for velocity and buffer states in the test scene significantly accelerates the "tuning" phase.

### 3. Concerns

- **Vertical Knockback (MEDIUM):** The current code sets `velocity.x = _knockback.x` but ignores the Y component during the override. If an enemy is below the player, the player won't be "popped" upwards, making the damage feel flat.
- **Hit-Stop & Input Deadlock (MEDIUM):** When `Engine.time_scale = 0.0`, `_physics_process` stops. If a player presses 'Jump' during the 3 frames of hit-stop, the action might be missed or the `_jump_buffer_timer` won't increment because the process is frozen.
- **Velocity Override vs. Influence (LOW):** Using `=` for knockback prevents infinite speed but also prevents the player from "fighting back" against the stun. This can make the character feel unresponsive during hit-stun.
- **Z-Index/Layering (LOW):** Landing dust particles need to be explicitly managed in the node tree to ensure they don't appear "behind" floor tiles or "inside" the player sprite at 320x180 resolution.

### 4. Suggestions

- **Input Buffering during Hit-Stop:** Consider using `_input(event)` or a separate input-capture boolean to ensure that a jump command issued during the hit-stop freeze is executed the moment `time_scale` returns to 1.0.
- **Knockback Verticality:** Modify the `_knockback` Vector2 to include a slight upward impulse (e.g., `velocity.y = -150.0`) when hit, which helps clear the player from the damage source.
- **Invincibility Visuals:** Beyond the initial white flash, implement a "flicker" effect (modulating alpha) for the duration of `_is_invincible` to provide clear feedback on the safety window.
- **Animation Priority Guard:** Ensure the "Hurt" animation state has total priority over "Run" or "Fall" until the knockback velocity drops below a certain threshold (e.g., 50.0).

### 5. Risk Assessment

**Overall Risk: LOW**
The technical foundations are very strong. The modular approach to juice and movement ensures that "feel" issues can be tuned by adjusting constants in the Inspector rather than refactoring core code. The project is well-positioned for Phase 2.

---

## Consensus Summary

*(Single reviewer — no consensus divergence applicable)*

### Strengths Validated

- Frame counters over Timer nodes for coyote/buffer — correct and precise approach
- AnimatedSprite2D-only targeting for juice effects — avoids physics/collision interference
- CPUParticles2D usage throughout — HTML5 export safety confirmed
- Live HUD in test scene — accelerates tuning in future phases

### Concerns to Address (Priority Order)

| Severity | Concern | Suggested Fix |
|----------|---------|---------------|
| MEDIUM | Input deadlock during hit-stop: `_jump_buffer_timer` can't increment when `time_scale=0` | Buffer jump input via `_input(event)` or a boolean flag outside `_physics_process` |
| MEDIUM | Vertical knockback ignored: `velocity.x = _knockback.x` drops Y component | Apply small upward impulse (`velocity.y = -150`) on damage in `take_damage()` |
| LOW | Invincibility has no visual duration feedback (only initial flash) | Add alpha flicker during `_is_invincible` window |
| LOW | DustParticles z-index not explicitly set — may render behind tiles | Set `z_index` on DustParticles node, or ensure layer order is correct in `player.tscn` |

### Recommended Actions Before Phase 3 (World Building)

The MEDIUM concerns are worth addressing in a quick fix pass before Phase 3, since they affect the core combat feel that will be present in every world:

1. `take_damage()` — add `velocity.y = min(velocity.y, -150.0)` to always pop the player slightly upward
2. `_input(event)` — capture jump press during hit-stop freeze and fire it on resume

These can be done as a `/gsd-fast` pass at any point, or incorporated into Phase 2 if movement tweaks are already planned.
