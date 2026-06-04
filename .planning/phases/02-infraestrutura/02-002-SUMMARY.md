---
phase: 02-infraestrutura
plan: "02"
subsystem: infrastructure
tags: [dialogic, save-system, scene-transition, input-remapping, autoloads, gamepad]
dependency_graph:
  requires: []
  provides:
    - SaveManager autoload (SAVE-01, SAVE-02)
    - SceneTransition autoload
    - ControlsManager autoload (ACCESS-02, ACCESS-03)
    - Dialogic 2 Alpha 19 plugin
  affects:
    - plan 03 (main menu usa SaveManager.save_exists())
    - plan 04 (options menu usa ControlsManager.remap_action())
    - plan 05 (Dialogic.start() disponível)
    - todos os 8 mundos (SceneTransition.go_to())
tech_stack:
  added:
    - Dialogic 2.0-Alpha-19 (addons/dialogic/)
  patterns:
    - Autoload singleton pattern (SaveManager, SceneTransition, ControlsManager)
    - CanvasLayer overlay fade (SceneTransition layer=100)
    - FileAccess.store_var() com schema version check
    - ConfigFile para persistência de controles separada do save
    - InputMap runtime remap com conflict detection
key_files:
  created:
    - addons/dialogic/ (957 arquivos, plugin completo)
    - autoloads/save_manager.gd
    - autoloads/scene_transition.gd
    - autoloads/controls_manager.gd
    - scenes/scene_transition/scene_transition.tscn
    - scenes/test_save/test_save.tscn
    - scenes/test_save/test_save.gd
  modified:
    - project.godot ([editor_plugins], [autoload] com Dialogic + 3 autoloads custom, [dialogic])
decisions:
  - "JOY_BUTTON_A/B e JOY_AXIS_LEFT_X como constantes globais (não JoyButton.A — não existe em Godot 4.4.1)"
  - "SceneTransition registrado via .tscn (não .gd direto) para ter o ColorRect Overlay como filho"
  - "Dialogic autoload adicionado manualmente no project.godot (plugin.gd registra em _enable_plugin() que só roda no editor)"
  - "String explícita em vez de inferência de tipo Variant (warning-as-error ativo em 4.4.1)"
metrics:
  duration: "8 min"
  completed_date: "2026-06-04"
  tasks_completed: 5
  files_created: 7
  files_modified: 1
---

# Phase 02 Plan 02: Autoloads Foundation Summary

**One-liner:** Dialogic 2 Alpha 19 instalado + SaveManager/SceneTransition/ControlsManager implementados com interfaces exatas consumidas pelos planos 03-05 e pelos 8 mundos.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Instalar e habilitar Dialogic 2 Alpha 19 | eaf1cfc | addons/dialogic/, project.godot |
| 2 | SaveManager + SceneTransition autoloads | 1169b9a | autoloads/save_manager.gd, autoloads/scene_transition.gd, scenes/scene_transition/scene_transition.tscn |
| 3 | ControlsManager autoload + gamepad defaults | 9a79194 | autoloads/controls_manager.gd |
| 4 | Registrar autoloads custom em project.godot | 9d3f9a6 | project.godot, autoloads/*.gd.uid |
| 5 | Criar cena de teste test_save.tscn | 6ab1689 | scenes/test_save/test_save.tscn, scenes/test_save/test_save.gd |

## Verification

- Godot 4.4.1 --headless --import: sem erros de parse (apenas DPITexture warning cosmético do editor do Dialogic, editor-only)
- project.godot: Dialogic (pos 459) < SaveManager (521) < SceneTransition (568) < ControlsManager (639) — ordem correta
- Nenhum erro `current_timeline` na startup (Pitfall 1 mitigado)
- Interfaces implementadas exatamente conforme o bloco `<interfaces>` do plano

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] JoyButton.A/B e JoyAxis.LEFT_X não existem em Godot 4.4.1**
- **Found during:** Task 4 (Godot headless --import apontou Parse Error no controls_manager.gd)
- **Issue:** O RESEARCH.md indicava `JoyButton.A`, `JoyButton.B`, `JoyAxis.LEFT_X` mas em Godot 4.4.1 esses enum members não são acessíveis via notação de ponto — apenas as constantes globais `JOY_BUTTON_A`, `JOY_BUTTON_B`, `JOY_AXIS_LEFT_X` existem
- **Fix:** Substituído para `JOY_BUTTON_A`, `JOY_BUTTON_B`, `JOY_AXIS_LEFT_X` (valores idênticos: 0, 1, 0)
- **Files modified:** autoloads/controls_manager.gd
- **Commit:** 9d3f9a6

**2. [Rule 1 - Bug] Inferência de tipo Variant tratada como erro em test_save.gd**
- **Found during:** Task 5 (Godot headless --import: "Warning treated as error")
- **Issue:** `var cp := SaveManager.current_save.get(...)` inferia tipo Variant e o projeto tem warnings-as-errors ativo. A linha 11 não compilava.
- **Fix:** Alterado para `var cp: String = SaveManager.current_save.get(...)` com tipo explícito
- **Files modified:** scenes/test_save/test_save.gd
- **Commit:** 6ab1689

**3. [Rule 2 - Missing] Dialogic autoload registrado manualmente**
- **Found during:** Task 1
- **Issue:** O plugin.gd do Dialogic registra `DialogicGameHandler` via `add_autoload_singleton()` em `_enable_plugin()` — mas esse callback só roda no editor GUI, não em headless. Sem o editor, o autoload não seria registrado automaticamente.
- **Fix:** Adicionado `Dialogic="*res://addons/dialogic/Core/DialogicGameHandler.gd"` manualmente no project.godot, antes dos autoloads custom. O Godot headless então inicializou corretamente e adicionou a seção [dialogic] automaticamente.
- **Files modified:** project.godot
- **Commit:** eaf1cfc

## Known Stubs

Nenhum. Todos os autoloads têm implementação completa e funcional. A cena test_save.tscn é uma cena de teste (não de produção) — isso é intencional conforme o plano.

## Threat Surface Scan

| Flag | File | Description |
|------|------|-------------|
| threat_flag: file_access | autoloads/save_manager.gd | FileAccess.get_var(true) em user://save.dat — mitigado com validação de tipo e versão de schema conforme T-02-03/T-02-04 |
| threat_flag: file_access | autoloads/controls_manager.gd | ConfigFile em user://controls.cfg — dados de controles do usuário |

Ambas as superfícies estão no threat model original do plano e têm mitigações implementadas.

## Self-Check: PASSED

Arquivos verificados:
- addons/dialogic/plugin.cfg: FOUND
- autoloads/save_manager.gd: FOUND
- autoloads/scene_transition.gd: FOUND
- autoloads/controls_manager.gd: FOUND
- scenes/scene_transition/scene_transition.tscn: FOUND
- scenes/test_save/test_save.tscn: FOUND
- scenes/test_save/test_save.gd: FOUND
- project.godot com [autoload] SaveManager/SceneTransition/ControlsManager: FOUND

Commits verificados:
- eaf1cfc: feat(02-002): instalar e habilitar Dialogic 2 Alpha 19
- 1169b9a: feat(02-002): SaveManager + SceneTransition autoloads
- 9a79194: feat(02-002): ControlsManager autoload com remapeamento e gamepad defaults
- 9d3f9a6: feat(02-002): registrar autoloads custom em project.godot + fix JOY enums
- 6ab1689: feat(02-002): cena de teste test_save.tscn para validar SAVE-01
