---
plan: "00-004"
phase: "00-funda-o"
status: complete
completed: 2026-05-21
commits:
  - 9a1f68c
  - 043e9a8
  - f854d99
  - 276d783
  - 5d0e575
repo: https://github.com/renatoJAF92/jogo-natalia
---

## Summary

GitHub Actions pipeline criado com 3 jobs paralelos (Web, Windows, macOS). Todos os 3 exports passam verde na tag v0.0.4. Deploy skipped/continue-on-error por ausência de BUTLER_CREDENTIALS (esperado — secret não configurado ainda).

## What Was Built

- `.github/workflows/export.yml` — pipeline com 3 jobs paralelos
  - Trigger: tags `v*` (export + deploy) e PRs para main (export only)
  - Container: barichello/godot-ci:4.4.1
  - lfs: true em todos os 3 jobs
  - Import assets antes do export (resolve headless pitfall)
  - Deploy condicional: `if: startsWith(github.ref, 'refs/tags/v')`
  - `continue-on-error: true` no deploy (BUTLER_CREDENTIALS não configurado ainda)
  - BUTLER_CREDENTIALS via `${{ secrets.BUTLER_CREDENTIALS }}` (nunca hardcoded)
  - ITCH_USER: placeholder "ITCH_USER" (configurar quando itch.io page for criada)
- Correções iterativas para macOS export:
  - `textures/vram_compression/import_etc2_astc=true` em project.godot
  - `application/bundle_identifier="com.renatojaf.destiny-tales-of-natalia"` em export_presets.cfg
  - `codesign/codesign=1` (built-in ad-hoc, sem Xcode) em export_presets.cfg
- Repositório: https://github.com/renatoJAF92/jogo-natalia
- Tags criadas: v0.0, v0.0.1, v0.0.2, v0.0.3, v0.0.4

## Decisions Implemented

- D-14: Deploy em tags v*, export em PRs
- D-15: barichello/godot-ci:4.4.1
- D-16: ITCH_USER placeholder, BUTLER_CREDENTIALS via secret
- D-17: lfs: true nos 3 jobs
- D-18: --headless --export-release

## CI Results (run v0.0.4 — final green)

- Web Export: ✓ sucesso
- Windows Export: ✓ sucesso
- macOS Export: ✓ sucesso
- Deploy to itch.io: skipped (continue-on-error — sem BUTLER_CREDENTIALS)

## Lessons Learned (macOS export pitfalls)

1. `textures/vram_compression/import_etc2_astc=true` obrigatório em project.godot para universal/arm64
2. `application/bundle_identifier` obrigatório em export_presets.cfg
3. `codesign/codesign=1` (built-in ad-hoc) — codesign=3 (rcodesign) exige Xcode, não disponível em Linux CI

## Self-Check: PASSED
