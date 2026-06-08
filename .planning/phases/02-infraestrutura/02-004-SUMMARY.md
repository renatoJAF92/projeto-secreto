---
plan: 02-004
phase: 02-infraestrutura
status: complete
completed: 2026-06-08
requirements_satisfied: [ACCESS-02, ACCESS-03]
commits:
  - afe1051  # options_menu.gd — remap controller + drift guard
  - d1ddda6  # options_menu.tscn — 4 action rows + reset/back
---

# SUMMARY — Plan 02-004: Options Menu Remap

## What Was Built

- `scenes/options_menu/options_menu.tscn` — UI de remapeamento com 4 action rows (Andar Esq., Andar Dir., Pular, Dash), botões REMAP/RESETAR CONTROLES/VOLTAR, paleta UI-SPEC (#1A1A2E, #E8E8F0, #0F3460)
- `scenes/options_menu/options_menu.gd` — controller completo: captura de input, drift guard, resolução de conflito, persistência via ControlsManager, exibição de binding atual

## Human Verify: APROVADO (2026-06-08)

- ✅ ACCESS-02: 4 ações remapeáveis com binding atual exibido; label "Pressione uma tecla..." durante captura
- ✅ Remap de Pular → J persistido em `user://controls.cfg` após fechar/reabrir Godot
- ✅ J funcional em `test_movement.tscn` após remap
- ✅ RESETAR CONTROLES restaura defaults (Pular = Space)
- ✅ ACCESS-03: drift guard ignora `abs(axis_value) <= 0.5`; gamepad DualSense/Xbox funciona sem config extra

## Decisões Técnicas

| Decisão | Rationale |
|---------|-----------|
| Drift guard `abs(event.axis_value) > 0.5` | Analógico solto emite eventos contínuos com valores baixos; threshold de 50% do curso evita remap acidental |
| Resolução de conflito silenciosa | ControlsManager.remap_action() limpa o evento da outra ação antes de atribuir — sem modal de confirmação |
| Persistência separada em `user://controls.cfg` | Isolada do save de progresso (D-16); reset de controles não apaga jogo |
| Escape/gamepad B cancela o remap | Previne ficar preso na tela de captura (T-02-10) |
