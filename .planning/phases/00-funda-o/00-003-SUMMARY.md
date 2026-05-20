---
plan: "00-003"
phase: "00-funda-o"
status: complete
completed: 2026-05-21
commits:
  - 14db8c2
  - f0b4747
---

## Summary

3 export presets criados (Web, Windows Desktop, macOS), export_presets.cfg commitado, build HTML5 testado no navegador — "v0.0 — Destiny: Tales of Natalia" exibido corretamente.

## What Was Built

- `export_presets.cfg` — 3 presets com nomes exatos para CLI:
  - preset 0: name="Web", platform="Web", export/web/index.html, thread_support=false
  - preset 1: name="Windows Desktop", platform="Windows Desktop", export/windows/destiny-tales-of-natalia.exe, x86_64
  - preset 2: name="macOS", platform="macOS", export/mac/destiny-tales-of-natalia.zip
- Export templates 4.4.1 instalados localmente
- Build HTML5 gerado: export/web/ com index.html, index.js, index.wasm, index.pck
- Verificação no navegador: texto "v0.0 — Destiny: Tales of Natalia" exibido sem erros
- Correção: .gitattributes e .gitignore restaurados após Godot sobrescrever ao criar projeto

## Decisions Implemented

- D-10: export_presets.cfg commitado no repositório
- D-11: 3 presets configurados (Web, Windows Desktop, macOS)
- D-12: Export web local testado — build HTML5 funcional no navegador

## Key Files

key-files:
  created:
    - export_presets.cfg
  generated_locally:
    - export/web/index.html (não versionado)

## Verification

- `grep -c 'name=' export_presets.cfg` → 6 (3 presets × name em [preset.N] e [preset.N.options]) ✓
- `grep 'name="Web"' export_presets.cfg` → linha encontrada ✓
- `grep 'name="Windows Desktop"' export_presets.cfg` → linha encontrada ✓
- `grep 'name="macOS"' export_presets.cfg` → linha encontrada ✓
- export/web/index.html existe localmente ✓
- http://localhost:8000 exibiu "v0.0 — Destiny: Tales of Natalia" ✓
- export/ ausente do git status ✓

## Requirements

- EXPORT-03: parcialmente satisfeito (export web funciona localmente; CI confirma em plano 004)

## Self-Check: PASSED
