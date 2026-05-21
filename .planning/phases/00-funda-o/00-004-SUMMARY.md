---
plan: "00-004"
phase: "00-funda-o"
status: complete
completed: 2026-05-21
commits:
  - 9a1f68c
  - 043e9a8
repo: https://github.com/renatoJAF92/jogo-natalia
---

## Summary

GitHub Actions pipeline criado com 3 jobs paralelos (Web, Windows, macOS). Web ✓ e Windows ✓ exportaram com sucesso. macOS corrigido (ETC2 ASTC habilitado) — re-testado via tag v0.0.1. Deploy skipped/failed por ausência de BUTLER_CREDENTIALS (esperado — secret não configurado ainda).

## What Was Built

- `.github/workflows/export.yml` — pipeline com 3 jobs paralelos
  - Trigger: tags `v*` (export + deploy) e PRs para main (export only)
  - Container: barichello/godot-ci:4.4.1
  - lfs: true em todos os 3 jobs
  - Import assets antes do export (resolve headless pitfall)
  - Deploy condicional: `if: startsWith(github.ref, 'refs/tags/v')`
  - BUTLER_CREDENTIALS via `${{ secrets.BUTLER_CREDENTIALS }}` (nunca hardcoded)
  - ITCH_USER: placeholder "ITCH_USER" (D-16)
- Correção: `project.godot` com `textures/vram_compression/import_etc2_astc=true` para macOS universal
- Repositório: https://github.com/renatoJAF92/jogo-natalia
- Tags criadas: v0.0, v0.0.1

## Decisions Implemented

- D-14: Deploy em tags v*, export em PRs
- D-15: barichello/godot-ci:4.4.1
- D-16: ITCH_USER placeholder, BUTLER_CREDENTIALS via secret
- D-17: lfs: true nos 3 jobs
- D-18: --headless --export-release

## CI Results (run 26209960592 — tag v0.0)

- Web Export: ✓ sucesso — artifact "web" disponível
- Windows Export: ✓ sucesso — artifact "windows" disponível
- macOS Export: ✗ falhou — ETC2 ASTC desabilitado (corrigido em v0.0.1)
- Deploy to itch.io: falhou por falta de BUTLER_CREDENTIALS (esperado)

## Self-Check: PASSED
