---
plan: 02-005
phase: 02-infraestrutura
status: complete
completed: 2026-06-08
requirements_satisfied: [NARR-01, NARR-02]
commits:
  - be28a04  # wip: initial implementation
  - 4ca6cc2  # fix: Dialogic box size + font for 320x180 viewport
  - 98dba01  # fix: dialogic_default_action missing from input map
  - 466e54e  # fix: join/leave events in timeline
  - f8cc62f  # fix: portrait format in .dch files
  - b944f7b  # fix: skip button toggle behavior
  - 9ecd338  # fix: SkipButton CanvasLayer 2
---

# SUMMARY — Plan 02-005: Dialogic Characters + Dialogue

## What Was Built

- `dialogic/characters/Natalia.dch` — personagem Dialogic 2 com portrait `natalia_portrait.png`
- `dialogic/characters/Renato.dch` — personagem Dialogic 2 com portrait `renato_portrait.png`
- `dialogic/timelines/test_dialogue.dtl` — timeline de teste: Natália 2 linhas + Renato 1 + join/leave
- `dialogic/pixel_art_style.tres` — DialogicStyle customizado para viewport 320×180
- `scenes/test_dialogue/test_dialogue.tscn` — cena de validação com StartButton + SkipButton (CanvasLayer 2)
- `scenes/test_dialogue/test_dialogue.gd` — controller com `start_cutscene()` + skip-on-seen

## Human Verify: APROVADO (2026-06-08)

- ✅ NARR-01: caixa de diálogo com texto e retrato de personagem, avança com Enter/Space
- ✅ NARR-02: PULAR oculto na primeira vez; visível na segunda; clicar acelera com auto_skip
- ✅ Retratos de Natália (esquerda) e Renato (direita) aparecem corretamente
- ✅ Nenhum erro no Output do Godot

## Desvios e Bugs Encontrados

### 1. Dialogic box_size 550px > viewport 320px
O default VN style usa `box_size = Vector2(550, 110)`. Em um viewport 320×180, o box extravasa 115px para a esquerda, cortando o início do texto. **Fix:** criado `dialogic/pixel_art_style.tres` com `box_size = Vector2(300, 56)`, `box_margin_bottom = 4`, `global_font_size = 8`, `global_font_color = #E8E8F0`. Registrado em `project.godot` como `layout/default_style`.

### 2. dialogic_default_action ausente do project.godot
O plugin registra essa action via editor (`add_dialogic_default_action()`), mas o `project.godot` não tinha a entrada. Sem ela, Enter/Space/clique não avançavam o diálogo. **Fix:** entrada adicionada manualmente ao `[input]` com os 5 eventos (Enter, clique esquerdo, Space, X, JoyButton A).

### 3. Retratos com formato errado nos .dch
O campo `scene` nos personagens apontava para o PNG diretamente. Dialogic espera uma `PackedScene` — o PNG deve ir em `export_overrides.image` dentro do `default_portrait.tscn`. **Fix:** `.dch` corrigidos para `"scene": "res://addons/dialogic/Modules/Character/default_portrait.tscn"` + `"export_overrides": {"image": "res://...png"}`.

### 4. Retratos não apareciam sem eventos join
Em Dialogic 2, uma linha de texto com personagem exibe o nome no label, mas não posiciona o retrato na tela. Eventos `join`/`leave` são obrigatórios. **Fix:** `join Natalia (default) left` e `join Renato (default) right` adicionados à timeline; `leave all` no fim.

### 5. SkipButton bloqueado pelo DialogicNode_Input
O Dialogic roda no CanvasLayer 1 e o `DialogicNode_Input` intercepta todos os cliques antes de qualquer Control no layer 0. O SkipButton era inatingível durante o diálogo. **Fix:** SkipButton movido para um `CanvasLayer` de layer=2 na cena; `@onready` atualizado para `$UILayer/SkipButton`.

### 6. Comportamento de skip era toggle
`_on_skip_pressed` fazia `enabled = not enabled`. Como `start_cutscene` já habilitava `auto_skip = true` ao entrar em cutscene vista, clicar PULAR desabilitava (ficava lento). **Fix:** `start_cutscene` não pré-habilita auto_skip — apenas mostra o botão. `_on_skip_pressed` só habilita (nunca desabilita), com `time_per_event = 0.05`.

## Decisões Técnicas

| Decisão | Rationale |
|---------|-----------|
| DialogicStyle custom em `dialogic/pixel_art_style.tres` | Não modificar o default do plugin — arquivo no diretório do projeto, versionado, não sobrescreve updates do Dialogic |
| `box_size = Vector2(300, 56)` | Margem de 10px em cada lado do viewport de 320px; altura 56px = UI-SPEC |
| `global_font_size = 8` | UI-SPEC especifica m5x7/8px; fonte m5x7 ainda não adicionada ao projeto (TODO polish) |
| SkipButton em CanvasLayer 2 | Garante prioridade de input sem modificar o plugin Dialogic |
| skip one-way (enable only) | Semântica clara: PULAR = "quero ir rápido"; o toggle confundia o jogador |
| `join left` / `join right` | Posicionamento clássico VN; retratos 64×80 cabem em 20% do viewport de 320px |

## TODO (Fase de Polish)

- Adicionar fonte `m5x7.ttf` ao projeto e configurar em `pixel_art_style.tres` → `global_font` (Phase 12)
- Retratos reais de Natália e Renato (fotos → pixel art) substituem os placeholders coloridos gerados
