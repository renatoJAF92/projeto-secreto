---
plan: "00-001"
phase: "00-funda-o"
status: complete
completed: 2026-05-21
commits:
  - c204f1d
  - 98be6ab
---

## Summary

Git LFS ativado (3.7.1), estrutura de pastas commitada, .gitattributes/.gitignore e serve.py no lugar.

## What Was Built

- `.gitattributes` — 10 regras Git LFS (*.png, *.jpg, *.webp, *.wav, *.ogg, *.mp3, *.scn, *.res, *.ttf, *.otf)
- `.gitignore` — 3 exclusões essenciais: `.godot/`, `*.translation`, `export/` + `.DS_Store`
- Estrutura de pastas com `.gitkeep`: scenes/, assets/sprites/{player,enemies,ui}/, assets/audio/{sfx,music}/, scripts/, autoloads/
- `export/` criado localmente mas excluído do git (verificado)
- `.github/workflows/` criado (receberá export.yml no plano 004)
- `serve.py` — servidor HTTP com Cross-Origin-Opener-Policy e Cross-Origin-Embedder-Policy para testar web export com SharedArrayBuffer

## Decisions Implemented

- D-06: Git LFS com .gitattributes rastreando todos os tipos de asset binário
- D-07: .gitignore mínimo (.godot/, *.translation, export/)
- D-08: Estrutura de pastas completa desde o início
- D-09: autoloads/ vazia (scripts entram na Phase 2)

## Key Files

key-files:
  created:
    - .gitattributes
    - .gitignore
    - serve.py
    - scenes/.gitkeep
    - autoloads/.gitkeep

## Verification

- `git lfs version` → git-lfs/3.7.1 ✓
- `grep -c "filter=lfs" .gitattributes` → 10 ✓
- `grep ".godot/" .gitignore` → .godot/ ✓
- `ls scenes/.gitkeep autoloads/.gitkeep` → ambos existem ✓
- `python3 -c "import ast; ast.parse(open('serve.py').read())"` → syntax OK ✓
- `export/` existe no filesystem mas NÃO aparece no git status ✓
- 2 novos commits (c204f1d, 98be6ab) ✓

## Self-Check: PASSED
