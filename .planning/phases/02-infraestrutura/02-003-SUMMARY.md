---
phase: 02-infraestrutura
plan: "03"
subsystem: main-menu
status: checkpoint-pending
tags: [ui, save-system, scene-transition, SAVE-03]
dependency_graph:
  requires: [02-002-autoloads-foundation]
  provides: [main-menu-scene, initial-scene]
  affects: [project.godot, scenes/main_menu/]
tech_stack:
  added: []
  patterns: [Control-root-scene, ConfirmationDialog, autoload-access-by-name, VBoxContainer-button-group]
key_files:
  created:
    - scenes/main_menu/main_menu.tscn
    - scenes/main_menu/main_menu.gd
  modified:
    - project.godot
decisions:
  - "ConfirmationDialog usado para confirmacao de NOVO JOGO com save existente — substitui o flash vermelho de 1 frame do UI-SPEC original (T-02-07 threat mitigado)"
  - "Destino temporario de Continue/New Game: res://scenes/test_movement/test_movement.tscn ate Phase 3 ter fases reais"
  - "ButtonGroup centrado horizontalmente com VBoxContainer posicionado em x=96 para viewport 320px"
metrics:
  duration: ~10min
  completed_date: "2026-06-04T21:04:00Z"
  tasks_completed: 2
  tasks_total: 3
  files_count: 3
---

# Phase 02 Plan 03: Main Menu Summary

**One-liner:** Tela inicial pixel art com CONTINUAR/NOVO JOGO/OPCOES, ConfirmationDialog para sobrescrita de save, e projeto definido para iniciar pelo main menu.

## Status

**CHECKPOINT PENDENTE — Aguardando verificacao humana no Godot Editor.**

Os 2 tasks automaticos foram concluidos. O Task 3 (`checkpoint:human-verify`) requer que o usuario abra o projeto no Godot, pressione F5 e valide o comportamento visual e de interacao da tela inicial.

## Tasks Concluidos

| Task | Nome | Commit | Arquivos |
|------|------|--------|---------|
| 1 | Cena e script do Main Menu | 4597fa6 | scenes/main_menu/main_menu.tscn, scenes/main_menu/main_menu.gd |
| 2 | Definir Main Menu como cena inicial | 1ac8adb | project.godot |

## Checkpoint Pendente

**Task 3:** Verificacao humana da tela inicial no Godot Editor.

**Como verificar:**
1. Remover save existente: `~/Library/Application Support/Godot/app_userdata/Destiny — Tales of Natalia/save.dat`
2. Abrir projeto no Godot e pressionar F5
3. Confirmar CONTINUAR desabilitado (sem save), NOVO JOGO e OPCOES habilitados
4. Clicar NOVO JOGO sem save — deve transitar diretamente (sem dialogo)
5. Reabrir: CONTINUAR deve estar habilitado (save criado)
6. Clicar NOVO JOGO com save — deve aparecer ConfirmationDialog com APAGAR/CANCELAR
7. Testar CANCELAR (nada acontece) e APAGAR (sobrescreve e transita)
8. Clicar OPCOES — confirmar que nao crasha
9. Validar paleta: fundo escuro #1A1A2E, texto claro, botoes 128x20 centralizados

**Sinal de retomada:** Digite "approved" ou descreva ajustes necessarios.

## O que foi implementado

### scenes/main_menu/main_menu.tscn
Cena Control com full-rect anchors contendo:
- `Background` (ColorRect 320x180, color #1A1A2E)
- `TitleLabel` (Label, "Destiny — Tales de Natalia", 16px, centralizado, y=40)
- `ButtonGroup` (VBoxContainer, centrado H, y=80, separation=8) com:
  - `ContinueButton` (128x20, "CONTINUAR")
  - `NewGameButton` (128x20, "NOVO JOGO")
  - `OptionsButton` (128x20, "OPCOES")
- `VersionLabel` (Label, "v0.2", canto inferior direito, y=172)
- `ConfirmNewGame` (ConfirmationDialog, "Apagar progresso? Esta acao nao pode ser desfeita.", APAGAR/CANCELAR)

### scenes/main_menu/main_menu.gd
- `continue_button.disabled = not SaveManager.save_exists()` em `_ready()`
- Cor #888888 aplicada ao ContinueButton quando desabilitado
- Foco inicial: ContinueButton se save existe, NewGameButton caso contrario
- `_on_new_game_pressed`: exibe ConfirmationDialog se save existe e retorna; chama `SaveManager.new_game()` + `SceneTransition.go_to()` apenas se NAO ha save
- `_on_new_game_confirmed`: chamado pelo sinal `confirmed` — `SaveManager.new_game()` + `SceneTransition.go_to()`
- `_on_continue_pressed`: `SceneTransition.go_to("res://scenes/test_movement/test_movement.tscn")`
- `_on_options_pressed`: `SceneTransition.go_to("res://scenes/options_menu/options_menu.tscn")`

### project.godot
- `run/main_scene` alterado de `res://scenes/main.tscn` para `res://scenes/main_menu/main_menu.tscn`

## Deviations from Plan

### Auto-aplicado: ConfirmationDialog em vez de flash vermelho

**Tipo:** Alinhamento com PLAN.md (que ja incorpora a correcao do Gemini review)

O UI-SPEC original (02-UI-SPEC.md) descrevia um flash vermelho de 1 frame no botao NOVO JOGO. O PLAN.md (task 1) ja havia atualizado isso para um ConfirmationDialog como mitigacao de T-02-07 (risco de apagar progresso por engano). A implementacao segue o PLAN.md — nenhum desvio adicional necessario.

## Threat Surface Scan

Nenhuma nova superficie de ataque introduzida alem do que ja estava no threat_model do plano:
- T-02-07 (Tampering — NOVO JOGO apaga progresso por engano): MITIGADO via ConfirmationDialog
- T-02-08 (DoS — CONTINUAR sem save): MITIGADO via `disabled = not SaveManager.save_exists()`

## Known Stubs

- `_on_continue_pressed` e `_on_new_game_confirmed` transitam para `res://scenes/test_movement/test_movement.tscn` como destino placeholder ate Phase 3 ter as fases reais. Comportamento intencional, documentado no PLAN.md task 1.
- `_on_options_pressed` aponta para `res://scenes/options_menu/options_menu.tscn` que sera criada no Plano 04.

## Self-Check

```
scenes/main_menu/main_menu.tscn   — FOUND (4597fa6)
scenes/main_menu/main_menu.gd     — FOUND (4597fa6)
project.godot (main_menu)         — FOUND (1ac8adb)
```

## Self-Check: PASSED
