---
phase: 04
slug: mundo-2-a-faculdade
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-06-09
---

# Phase 04 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Godot 4 headless export + manual in-editor playtest |
| **Config file** | `project.godot` |
| **Quick run command** | `godot --headless --quit 2>&1 | grep -E 'ERROR|SCRIPT ERROR'` |
| **Full suite command** | In-editor playtest per scene (manual) |
| **Estimated runtime** | ~5 seconds (headless check) |

---

## Sampling Rate

- **After every task commit:** Run headless error check
- **After every plan wave:** Run in-editor playtest for affected scenes
- **Before `/gsd-verify-work`:** Full world playthrough (mundo2 abertura → fase1 → fase2 → fase3 → boss)
- **Max feedback latency:** 10 seconds (headless), manual per wave

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| save-schema | W1 | 1 | POWER-01 | — | Save v2→v3 migration loads without crash | headless | `godot --headless --quit` | ✅ | ⬜ pending |
| power-system | W1 | 1 | POWER-01 | — | active_power persists across scene transitions | manual | playtest | ✅ W0 | ⬜ pending |
| boss-tfg | W2 | 2 | BOSS-02 | — | Quality bar reaches 100% with all 5 items | manual | playtest | ✅ W0 | ⬜ pending |
| itens-tfg | W2 | 2 | BOSS-02 | — | 3/5 minimum gate blocks banca entry | manual | playtest | ✅ W0 | ⬜ pending |
| enemies | W1 | 1 | — | — | Impressora fires projectile, Maquete damages on contact | manual | playtest | ✅ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- No additional test infrastructure needed — Godot scenes are the test harness.
- Headless check for parse/compile errors is the automated safety net.

*Existing infrastructure (Godot 4 + GDScript) covers all phase requirements.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| HP hearts display correctly at 3/2/1/0 PV | D-07 | In-editor HUD render | Take damage 3x, verify hearts decrement. Activate checkpoint, verify +1 PV. |
| Sketch projectile persists in Mundo 1 revisit | POWER-01 | Cross-world persistence | Load Phase 1 save with sketch unlocked, fire Z, verify projectile spawns. |
| Professor Perpétuo escalates banca threshold | BOSS-02 | Boss dialogue logic | Trigger boss, wait for threshold event (80%→95%), verify quality bar target updates. |
| Boss TFG: <3 items blocks entry | BOSS-02 | Scene gate guard | Attempt boss_tfg.tscn with 2/5 items, verify blocked message + return to fase3. |
| Power cycle Shift+Z | POWER-01 | Input system | Unlock both Amor and Sketch, press Shift+Z, verify icon changes in HUD. |
| Renato NPC cures +1 PV | D-08 | NPC interaction | Walk into Renato's zone in fase3, verify PV increments with dialogue line. |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s (headless)
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
