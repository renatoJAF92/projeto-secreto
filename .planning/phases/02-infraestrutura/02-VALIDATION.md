---
phase: 2
slug: infraestrutura
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-06-04
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | GDScript built-in (sem GUT — projeto usa test scenes manuais) |
| **Config file** | none — test scenes em `scenes/test_*` |
| **Quick run command** | `godot --headless --path . --check-only` |
| **Full suite command** | Human verify em Godot editor (checkpoints físicos) |
| **Estimated runtime** | ~5 min (human verify) |

---

## Sampling Rate

- **After every task commit:** verificação visual no Godot editor
- **After every plan wave:** human verify completo em test scene
- **Before `/gsd-verify-work`:** todos os success criteria 1-5 do ROADMAP.md aprovados
- **Max feedback latency:** 5 minutos

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 2-save-01 | save | 1 | SAVE-01 | — | N/A | manual | abrir test_save.tscn, tocar checkpoint, fechar e reabrir | ❌ Wave 0 | ⬜ pending |
| 2-save-02 | save | 1 | SAVE-02 | — | get_var(true) com verificação de tipo | manual | verificar save.dat após ciclo save/load | ❌ Wave 0 | ⬜ pending |
| 2-save-03 | save | 1 | SAVE-03 | — | N/A | manual | abrir main_menu.tscn; verificar estado dos botões | ❌ Wave 0 | ⬜ pending |
| 2-narr-01 | dialogic | 2 | NARR-01 | — | N/A | manual | abrir test_dialogue.tscn, pressionar Enter | ❌ Wave 0 | ⬜ pending |
| 2-narr-02 | dialogic | 2 | NARR-02 | — | N/A | manual | ver twice; verificar visibilidade do botão Pular | ❌ Wave 0 | ⬜ pending |
| 2-access-02 | controls | 3 | ACCESS-02 | — | N/A | manual | options_menu.tscn → remap → test_movement.tscn | ❌ Wave 0 | ⬜ pending |
| 2-access-03 | controls | 3 | ACCESS-03 | — | N/A | manual | conectar DualSense/Xbox; abrir test_movement.tscn | — | ⬜ pending |
| 2-npc-04 | sprites | 1 | NPC-04 | — | N/A | smoke | `godot --headless --path . --check-only` | ❌ Wave 0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `scenes/test_dialogue/test_dialogue.tscn` — cena de validação NARR-01/NARR-02
- [ ] `scenes/main_menu/main_menu.tscn` — cena principal com Continue/New Game (SAVE-03)
- [ ] `scenes/options_menu/options_menu.tscn` — UI de remapeamento (ACCESS-02)
- [ ] `scripts/generate_sprites.py` — script offline de geração de sprites (NPC-04)

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Auto-save ao tocar checkpoint | SAVE-01 | Requer interação física com objeto no Godot editor | Abrir test_save.tscn, mover player até checkpoint, fechar Godot, reabrir e verificar save.dat |
| Continue desabilitado sem save | SAVE-03 | Requer inspeção visual da UI | Abrir main_menu.tscn, verificar que botão Continue está desabilitado (disabled=true) |
| Dialogic 2 exibe retrato e avança | NARR-01 | Requer renderer ativo (não funciona headless) | Abrir test_dialogue.tscn no Godot editor, pressionar F6, verificar caixa com retrato e texto |
| Botão Pular visível em cutscene já vista | NARR-02 | Requer estado de jogo com seen_cutscenes preenchido | Executar diálogo de teste 2x; verificar que botão Pular aparece na segunda execução |
| Remapear tecla e testar gameplay | ACCESS-02 | Requer interação com menu e gameplay | Abrir options_menu, remapear Jump para outra tecla, abrir test_movement.tscn, verificar resposta |
| Gamepad sem configuração extra | ACCESS-03 | Requer hardware físico (DualSense/Xbox) | Conectar gamepad, abrir test_movement.tscn, verificar controles analógicos e botões |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 5 min
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
