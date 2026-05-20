---
phase: 0
slug: funda-o
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-05-20
---

# Phase 0 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Verificação manual + comandos shell (sem framework de testes automático — Phase 0 é configuração pura) |
| **Config file** | N/A |
| **Quick run command** | `grep "gl_compatibility" project.godot && git lfs ls-files` |
| **Full suite command** | `godot --headless --export-release "Web" export/web/index.html && python3 serve.py` |
| **Estimated runtime** | ~2-5 minutos (export web é o gargalo) |

---

## Sampling Rate

- **After every task commit:** Run `grep "gl_compatibility" project.godot && git lfs ls-files`
- **After every plan wave:** Run export web completo + servir localmente + abrir no browser
- **Before `/gsd-verify-work`:** Todos os 4 success criteria do ROADMAP.md verificados

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 00-xx-01 | 01 | 1 | EXPORT-03 | — | `BUTLER_CREDENTIALS` apenas em secrets GitHub, nunca hardcoded | manual | `grep "gl_compatibility" project.godot` | ❌ Wave 0 | ⬜ pending |
| 00-xx-02 | 01 | 1 | SC-1 | — | Export web gera HTML5 sem erro | smoke | `godot --headless --export-release "Web" export/web/index.html` | ❌ Wave 0 | ⬜ pending |
| 00-xx-03 | 01 | 1 | SC-2 | — | Git LFS rastreia binários | shell | `git lfs ls-files` | ❌ Wave 0 | ⬜ pending |
| 00-xx-04 | 01 | 1 | SC-3 | — | Estrutura de pastas commitada | shell | `git show --stat HEAD` | ❌ Wave 0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `.gitattributes` com todas as regras LFS (`*.png`, `*.jpg`, `*.wav`, `*.ogg`, `*.mp3`, `*.ttf`, `*.otf`, `*.scn`, `*.res`)
- [ ] `.gitignore` com `.godot/`, `*.translation`, `export/`
- [ ] `project.godot` com configurações pixel art e Compatibility renderer
- [ ] `export_presets.cfg` com 3 presets (Web, Windows Desktop, macOS)
- [ ] `.github/workflows/export.yml` com godot-ci pipeline
- [ ] `scenes/main.tscn` com Node2D + Label "v0.0 — Destiny: Tales of Natalia"
- [ ] `serve.py` script Python com CORS headers para teste web local

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Renderer Compatibility persiste após reabrir projeto | EXPORT-03 | Requer interação com o editor Godot | Abrir projeto no editor > Project Settings > Rendering > confirmar "Compatibility" |
| Build HTML5 abre no browser sem tela preta | SC-1 | Requer browser real | `cd export/web && python3 serve.py`, abrir `http://localhost:8000`, confirmar label "v0.0" visível |
| CI deploy funciona em push de tag | D-14 | Requer GitHub Actions + itch.io configurados | Criar tag `v0.0`, verificar Actions tab no GitHub, confirmar job "green" |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 300s (export web é o mais lento)
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
