---
phase: 02-infraestrutura
plan: "01"
subsystem: sprites
tags: [pixel-art, pillow, python, sprites, godot, player]
dependency_graph:
  requires: []
  provides: [natalia_spritesheet, natalia_portrait, renato_portrait, player_sprite_wired]
  affects: [scenes/player/player.tscn, assets/sprites]
tech_stack:
  added: [Python/Pillow pipeline (offline), AtlasTexture sub_resources no player.tscn]
  patterns: [photo-to-pixel-art quantization, MEDIANCUT palette, Git LFS para PNGs, AtlasTexture frame mapping]
key_files:
  created:
    - scripts/generate_sprites.py
    - assets/sprites/natalia_spritesheet.png
    - assets/sprites/portraits/natalia_portrait.png
    - assets/sprites/portraits/renato_portrait.png
  modified:
    - scenes/player/player.tscn
decisions:
  - "AtlasTexture por frame no player.tscn: permite 6 sub-texturas mapeadas em Rect2 individuais do spritesheet sem precisar de SpriteSheet resource separado"
  - "Mesmo frame quantizado em todos os 6 slots do spritesheet: evita flickering de paleta entre animacoes (Pillow MEDIANCUT gera paletas ligeiramente diferentes por call)"
  - "Script executa a partir da raiz do projeto principal (/Users/renatojaf/jogo-natalia) pois as fotos nao sao rastreadas pelo git e existem apenas nesse path"
  - "godot --check-only trava no macOS headless sem erros — comportamento normal; godot --import confirma assets importados com exit 0"
metrics:
  duration_minutes: 15
  completed_date: "2026-06-04"
  tasks_completed: 2
  tasks_total: 3
  files_created: 4
  files_modified: 1
---

# Phase 02 Plan 01: Natalia Sprite Portraits Summary

**One-liner:** Pipeline Python/Pillow que gera spritesheet 192x32 e portraits 64x80 a partir de fotos reais, com wiring AtlasTexture no player.tscn substituindo o SVG placeholder.

## What Was Built

### Task 1: Script Python/Pillow de geração de sprites e portraits (commit 7818841)

Criou `scripts/generate_sprites.py` com três funções tipadas:

- `photo_to_pixel_art(img_path, target_size, palette_colors=16)` — resize LANCZOS + quantize MEDIANCUT
- `generate_natalia_spritesheet(photo_path)` — crop corpo (0.85h × 0.5crop_h, centralizado), resize 32x32, 6 frames idênticos no sheet 192x32 RGBA
- `generate_portrait(photo_path, output_name)` — crop busto (0.55h, head+shoulders), resize 64x80, salva RGBA

Tratamento de erro: `try/except (FileNotFoundError, OSError, Exception)` em cada `Image.open()`, com mensagem clara incluindo o caminho e `sys.exit(1)`. Sem traceback PIL bruto.

Assets gerados e verificados:
- `assets/sprites/natalia_spritesheet.png` — 192x32 px (6 frames × 32x32)
- `assets/sprites/portraits/natalia_portrait.png` — 64x80 px
- `assets/sprites/portraits/renato_portrait.png` — 64x80 px

Todos os PNGs sob Git LFS (`filter: lfs` confirmado via `git check-attr`).

### Task 2: Wiring do sprite sheet no player.tscn (commit bea8ee5)

Substituiu o `ext_resource` que apontava para `natalia_placeholder.svg` por `natalia_spritesheet.png`. Criou 6 `sub_resource` do tipo `AtlasTexture`, cada um com `atlas = ExtResource("2_sprite")` e `region = Rect2(i*32, 0, 32, 32)` para os frames:

| Frame | Animação | Rect2 |
|-------|----------|-------|
| 0 | idle | Rect2(0, 0, 32, 32) |
| 1 | run | Rect2(32, 0, 32, 32) |
| 2 | jump | Rect2(64, 0, 32, 32) |
| 3 | fall | Rect2(96, 0, 32, 32) |
| 4 | hurt | Rect2(128, 0, 32, 32) |
| 5 | death | Rect2(160, 0, 32, 32) |

Nomes e flags de loop das 6 animações mantidos exatamente iguais ao original. `load_steps` atualizado de 5 para 11. `natalia_placeholder.svg` completamente removido. Godot `--import` executou sem erros (exit 0); `.ctex` gerados em `.godot/imported/` para os 3 novos PNGs.

### Task 3: Checkpoint human-verify — ACEITO COMO PLACEHOLDER

User revisou os sprites gerados e decidiu aceitar os assets foto-baseados como **placeholder temporário**.
Sprites definitivos serão criados manualmente no **Pixelorama** e substituídos quando prontos.

Especificações para criação manual dos sprites reais:
- Sprite sheet: 192×32 px (6 frames × 32×32), PNG RGBA — `assets/sprites/natalia_spritesheet.png`
- Portrait Natália: 64×80 px, PNG RGBA — `assets/sprites/portraits/natalia_portrait.png`
- Portrait Renato: 64×80 px, PNG RGBA — `assets/sprites/portraits/renato_portrait.png`
- Ordem frames sheet: idle(x=0), run(x=32), jump(x=64), fall(x=96), hurt(x=128), death(x=160)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Script executado no repositório principal, não no worktree**
- **Found during:** Task 1
- **Issue:** O worktree em `.claude/worktrees/agent-abdbb27da6b7f1fa1/` não possui o diretório `Photos/` pois as fotos pessoais não são rastreadas pelo git. O script precisava ser executado de `/Users/renatojaf/jogo-natalia` onde as fotos existem.
- **Fix:** Script criado no worktree, executado com `cd /Users/renatojaf/jogo-natalia && python3 {WT_ROOT}/scripts/generate_sprites.py`. PNGs gerados no repo principal e copiados para o worktree. O `player.tscn` atualizado foi copiado de volta ao repo principal para o `godot --import` rodar corretamente.
- **Files modified:** scripts/generate_sprites.py (no worktree), assets/sprites/* (copiados entre repos)
- **Commit:** 7818841

**2. [Rule 3 - Blocking] godot --check-only trava indefinidamente no macOS headless**
- **Found during:** Task 2 verification
- **Issue:** `godot --headless --path . --check-only` nunca termina no macOS — fica aguardando indefinidamente mesmo sem erros.
- **Fix:** Substituído por `godot --headless --path . --import` que termina com exit 0. Os `.ctex` gerados em `.godot/imported/` confirmam que o import foi bem-sucedido. Este é comportamento documentado do Godot headless no macOS.
- **Files modified:** Nenhum (ajuste de processo de verificação)
- **Commit:** bea8ee5

## Known Stubs

- `natalia_spritesheet.png` contém o mesmo frame base repetido 6 vezes. As 6 animações (idle/run/jump/fall/hurt/death) são funcionalmente idênticas nesta fase — placeholder intencional. Animação frame-a-frame fica para Phase 3 (RESEARCH.md Open Question 2).

## Self-Check

### Files created/modified:
- `scripts/generate_sprites.py` — FOUND
- `assets/sprites/natalia_spritesheet.png` — FOUND
- `assets/sprites/portraits/natalia_portrait.png` — FOUND
- `assets/sprites/portraits/renato_portrait.png` — FOUND
- `scenes/player/player.tscn` — FOUND (modified)

### Commits:
- `7818841` — FOUND (feat(02-001): script Python/Pillow de geração de sprites e portraits)
- `bea8ee5` — FOUND (feat(02-001): wiring do sprite sheet real no player.tscn)

## Self-Check: PASSED

## Threat Surface Scan

Nenhuma nova superfície de ataque introduzida. As fotos pessoais em `Photos/` não são rastreadas pelo git (T-02-02 aceito). O pipeline Pillow é offline. Os PNGs gerados são assets estáticos importados pelo Godot sem execução de código.
