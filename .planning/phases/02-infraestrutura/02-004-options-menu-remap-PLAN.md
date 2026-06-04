---
phase: 02-infraestrutura
plan: 04
type: execute
wave: 2
depends_on: [02]
files_modified:
  - scenes/options_menu/options_menu.tscn
  - scenes/options_menu/options_menu.gd
autonomous: false
requirements: [ACCESS-02, ACCESS-03]
must_haves:
  truths:
    - "Menu de opcoes lista walk_left, walk_right, jump, dash com o binding atual de cada"
    - "Jogador pode remapear qualquer das 4 acoes pressionando REMAP e depois uma tecla/botao"
    - "Conflito de tecla e resolvido silenciosamente (binding da outra acao limpo)"
    - "Remapeamento persiste em user://controls.cfg via ControlsManager"
    - "Gamepad (DualSense/Xbox) controla as 4 acoes sem config extra"
    - "RESETAR CONTROLES restaura defaults; VOLTAR retorna ao Main Menu"
  artifacts:
    - path: "scenes/options_menu/options_menu.tscn"
      provides: "UI de remapeamento Control — ACCESS-02"
      contains: "REMAP"
    - path: "scenes/options_menu/options_menu.gd"
      provides: "Controller de remapeamento; captura input e chama ControlsManager"
      contains: "remap_action"
  key_links:
    - from: "scenes/options_menu/options_menu.gd"
      to: "ControlsManager"
      via: "ControlsManager.remap_action / save_controls / load_controls"
      pattern: "ControlsManager.remap_action"
    - from: "scenes/options_menu/options_menu.gd"
      to: "InputMap"
      via: "InputMap.action_get_events para exibir binding atual"
      pattern: "InputMap.action_get_events"
---

<objective>
Implementar o menu de opcoes com remapeamento das 4 acoes de gameplay e suporte a gamepad, satisfazendo ACCESS-02 e ACCESS-03.

Purpose: ACCESS-02/ACCESS-03 — acessibilidade. O jogador remapeia teclas e usa gamepad sem config. Slice vertical: ao terminar, o jogador abre Opcoes, remapeia uma acao, e ela responde no gameplay; o controle ja funciona conectado.
Output: scenes/options_menu/ (tscn + gd).
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/phases/02-infraestrutura/02-CONTEXT.md
@.planning/phases/02-infraestrutura/02-UI-SPEC.md
@.planning/phases/02-infraestrutura/02-PATTERNS.md

<interfaces>
<!-- Consumido deste plano (definido no Plano 02): -->
ControlsManager.ACTIONS  # ["walk_left", "walk_right", "jump", "dash"]
ControlsManager.remap_action(action: String, new_event: InputEvent) -> void  # ja faz conflito + save
ControlsManager.save_controls() -> void
ControlsManager.load_controls() -> void
SceneTransition.go_to(scene_path: String) -> void

<!-- Captura de input via _input — padrao de player.gd linha 126 (PATTERNS.md secao options_menu.gd). -->
<!-- UI-SPEC.md Screen 2 OptionsMenu + Godot Node Specification (OptionsMenu scene tree) é o contrato visual. -->
<!-- Copy: OPCOES / RESETAR CONTROLES / VOLTAR / "Pressione uma tecla..." (UI-SPEC Copywriting). -->
<!-- Labels de acao em PT: walk_left="Andar Esq.", walk_right="Andar Dir.", jump="Pular", dash="Dash". -->
</interfaces>
</context>

<tasks>

<task type="auto">
  <name>Task 1: Cena do Options Menu (arvore de remapeamento)</name>
  <files>scenes/options_menu/options_menu.tscn</files>
  <read_first>
    - scenes/test_movement/test_movement.tscn (formato .tscn de referencia)
    - scenes/main_menu/main_menu.tscn (se existir — mesmo padrao Control + ColorRect background; pode rodar em paralelo, nao depender do conteudo)
    - .planning/phases/02-infraestrutura/02-UI-SPEC.md secao Screen 2 OptionsMenu + Godot Node Specification (arvore exata)
  </read_first>
  <action>
    Criar `scenes/options_menu/options_menu.tscn` com root `Control` (name `OptionsMenu`, full-rect) seguindo a arvore do UI-SPEC Godot Node Specification:
    - `Background` (ColorRect 320x180, color `#1A1A2E`)
    - `TitleLabel` (Label, text="OPCOES", 16px, x=8, y=8, color `#E8E8F0`)
    - `Divider` (ColorRect 304x1, color `#0F3460`, y=28)
    - `ActionList` (VBoxContainer, x=8, y=36, separation=4) com 4 HBoxContainers `ActionRow_WalkLeft`, `ActionRow_WalkRight`, `ActionRow_Jump`, `ActionRow_Dash`. Cada row: Label de acao (96px, ex "Andar Esq."), Label de binding (96px, centralizado, name `BindingLabel`), Button "REMAP" (48x16, name `RemapButton`).
    - `Divider2` (ColorRect 304x1, color `#0F3460`, y=136)
    - `BottomButtons` (HBoxContainer, x=8, y=144, separation=8) com `ResetButton` (144x16, text="RESETAR CONTROLES") e `BackButton` (64x16, text="VOLTAR").
    Cores exatas da paleta UI-SPEC; bordas quadradas; touch target minimo 16px de altura nos botoes de row, 24px ideal (UI-SPEC). Nomear os nodes para o script encontrar por path.
    Nao adicionar logica no tscn — apenas estrutura. `godot --headless --path . --check-only`.
  </action>
  <acceptance_criteria>
    - `scenes/options_menu/options_menu.tscn` tem root Control e 4 ActionRow (WalkLeft, WalkRight, Jump, Dash)
    - Contem strings `OPCOES`, `RESETAR CONTROLES`, `VOLTAR`, `REMAP`
    - Contem `ResetButton` e `BackButton`
    - `godot --headless --path . --check-only` sai com codigo 0
  </acceptance_criteria>
  <verify>
    <automated>cd /Users/renatojaf/jogo-natalia; grep -q "ActionRow_Jump" scenes/options_menu/options_menu.tscn; grep -q "RESETAR CONTROLES" scenes/options_menu/options_menu.tscn; grep -q "VOLTAR" scenes/options_menu/options_menu.tscn; grep -q "REMAP" scenes/options_menu/options_menu.tscn; godot --headless --path . --check-only</automated>
  </verify>
  <done>Estrutura do Options Menu com 4 rows de acao e botoes Reset/Voltar conforme UI-SPEC; check passa.</done>
</task>

<task type="auto">
  <name>Task 2: Controller de remapeamento + gamepad</name>
  <files>scenes/options_menu/options_menu.gd</files>
  <read_first>
    - scenes/player/player.gd (padrao _input linha 126; estado privado com prefixo _ linhas 27-44)
    - autoloads/controls_manager.gd (do Plano 02 — interface remap_action, save_controls, load_controls, ACTIONS)
    - .planning/phases/02-infraestrutura/02-UI-SPEC.md secao Screen 2 Remap flow (fluxo de 6 passos) e Gamepad display
    - .planning/phases/02-infraestrutura/02-RESEARCH.md secao Code Examples (start_remap + _input para captura)
    - .planning/phases/02-infraestrutura/02-PATTERNS.md secao options_menu.gd
  </read_first>
  <action>
    Criar `scenes/options_menu/options_menu.gd` (`extends Control`).
    Estado: `var _waiting_for_input: String = ""` (vazio = nao aguardando).
    `_ready()`: `@onready`/get_node para os 4 BindingLabel e 4 RemapButton, ResetButton, BackButton. Conectar `pressed` de cada RemapButton a `start_remap(action_name)` com o nome da acao correspondente. Conectar ResetButton a `_on_reset`, BackButton a `_on_back`. Chamar `_refresh_ui()` para popular os BindingLabels.
    `start_remap(action_name)`: setar `_waiting_for_input = action_name`; mudar o BindingLabel da row para "Pressione uma tecla..." (cor `#8888AA`).
    `_input(event)` (padrao player.gd linha 126): se `_waiting_for_input.is_empty()` retorna. Se Escape (`InputEventKey` keycode ESC) ou gamepad B durante espera, cancelar sem mudanca e `_refresh_ui()`. Se `event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion`: `get_viewport().set_input_as_handled()`, `ControlsManager.remap_action(_waiting_for_input, event)` (ControlsManager ja resolve conflito e salva — Plano 02), `_waiting_for_input = ""`, `_refresh_ui()`.
    `_refresh_ui()`: para cada acao em ControlsManager.ACTIONS, ler `InputMap.action_get_events(action)` e formatar texto legivel no BindingLabel (nome da tecla via `OS.get_keycode_string(event.physical_keycode)` para teclas; glyph generico amarelo `#FFDD57` para gamepad — prompts genericos D-17, sem marca).
    `_on_reset()`: apagar `user://controls.cfg` (`DirAccess.remove_absolute` no caminho global, ou `ControlsManager` expoe reset; se nao expoe, remover arquivo e chamar `ControlsManager.load_controls()` que recai nos defaults + gamepad), depois `_refresh_ui()`.
    `_on_back()`: `SceneTransition.go_to("res://scenes/main_menu/main_menu.tscn")`.
    Acessar ControlsManager e SceneTransition por nome global (autoloads do Plano 02).
    `godot --headless --path . --check-only`.
  </action>
  <acceptance_criteria>
    - `scenes/options_menu/options_menu.gd` contem `extends Control`, `_waiting_for_input`, `func _input`, `func start_remap`, `func _refresh_ui`
    - Contem `ControlsManager.remap_action` e `InputMap.action_get_events`
    - `_input` chama `get_viewport().set_input_as_handled()` ao capturar o remap
    - `_on_back` chama `SceneTransition.go_to` para o main_menu
    - `godot --headless --path . --check-only` sai com codigo 0
  </acceptance_criteria>
  <verify>
    <automated>cd /Users/renatojaf/jogo-natalia; grep -q "_waiting_for_input" scenes/options_menu/options_menu.gd; grep -q "ControlsManager.remap_action" scenes/options_menu/options_menu.gd; grep -q "InputMap.action_get_events" scenes/options_menu/options_menu.gd; grep -q "SceneTransition.go_to" scenes/options_menu/options_menu.gd; godot --headless --path . --check-only</automated>
  </verify>
  <done>Remapeamento captura input, persiste via ControlsManager, exibe binding atual e suporta gamepad; check passa.</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>Menu de opcoes com remapeamento das 4 acoes, resolucao silenciosa de conflito, persistencia e gamepad.</what-built>
  <how-to-verify>
    1. Abrir `scenes/options_menu/options_menu.tscn` no Godot, pressionar F6.
    2. Confirmar que as 4 linhas (Andar Esq., Andar Dir., Pular, Dash) mostram o binding atual (A, D, Space, Shift/K).
    3. Clicar REMAP em "Pular"; o label vira "Pressione uma tecla..."; pressionar J. Confirmar que o binding de Pular vira J.
    4. Fechar e reabrir o Godot (ou rodar de novo): o binding de Pular deve continuar J (persistido em controls.cfg).
    5. Abrir `scenes/test_movement/test_movement.tscn` (F6) e confirmar que J agora faz pular.
    6. Voltar ao Options, clicar RESETAR CONTROLES; bindings voltam ao default (Pular = Space).
    7. Conectar um gamepad (DualSense/Xbox): em test_movement, mover com o analogico esquerdo e pular com A/South — sem configuracao extra.
  </how-to-verify>
  <resume-signal>Digite "approved" ou descreva ajustes de remap/gamepad/layout.</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| Input do jogador -> remap | Evento de tecla/botao capturado e gravado como binding |
| OptionsMenu -> user://controls.cfg | Persistencia de controles separada do save (D-16) |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-02-09 | Denial of Service | Remapear duas acoes para a mesma tecla deixa uma sem controle | mitigate | ControlsManager.remap_action limpa o new_event das outras acoes antes de adicionar; UI faz _refresh_ui apos remap |
| T-02-10 | Denial of Service | Jogador remapeia para tecla inutilizavel e fica preso na tela | mitigate | Escape/gamepad B cancela o remap em andamento; RESETAR CONTROLES restaura defaults sem afetar o save |
</threat_model>

<verification>
- `godot --headless --path . --check-only` passa.
- 4 rows de acao + Reset/Voltar presentes; remap_action e action_get_events referenciados.
- Human-verify confirma remap persistente, conflito silencioso, reset e gamepad.
</verification>

<success_criteria>
ACCESS-02 e ACCESS-03 atendidos: jogador remapeia qualquer das 4 acoes e usa gamepad sem config; success criterion 4 do ROADMAP.
</success_criteria>

<output>
Apos completar, criar `.planning/phases/02-infraestrutura/02-004-SUMMARY.md`.
</output>
