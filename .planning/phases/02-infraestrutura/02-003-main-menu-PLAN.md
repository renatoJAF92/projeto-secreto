---
phase: 02-infraestrutura
plan: 03
type: execute
wave: 2
depends_on: [02]
files_modified:
  - scenes/main_menu/main_menu.tscn
  - scenes/main_menu/main_menu.gd
  - project.godot
autonomous: false
requirements: [SAVE-03]
must_haves:
  truths:
    - "Tela inicial apresenta CONTINUAR, NOVO JOGO e OPCOES"
    - "CONTINUAR esta desativado quando nao existe save (SaveManager.save_exists() == false)"
    - "NOVO JOGO chama SaveManager.new_game() e transita via SceneTransition"
    - "OPCOES abre o menu de opcoes via SceneTransition.go_to()"
    - "main_menu.tscn e a cena inicial do projeto (run/main_scene)"
  artifacts:
    - path: "scenes/main_menu/main_menu.tscn"
      provides: "Tela inicial Control com Continue/New Game/Opcoes — SAVE-03"
      contains: "ContinueButton"
    - path: "scenes/main_menu/main_menu.gd"
      provides: "Controller da tela inicial; consulta SaveManager"
      contains: "save_exists"
  key_links:
    - from: "scenes/main_menu/main_menu.gd"
      to: "SaveManager"
      via: "SaveManager.save_exists() para habilitar Continue"
      pattern: "SaveManager.save_exists"
    - from: "scenes/main_menu/main_menu.gd"
      to: "SceneTransition"
      via: "SceneTransition.go_to nas transicoes"
      pattern: "SceneTransition.go_to"
---

<objective>
Implementar a tela inicial (Main Menu) com CONTINUAR, NOVO JOGO e OPCOES, satisfazendo SAVE-03, e defini-la como cena inicial do projeto.

Purpose: SAVE-03 — o ponto de entrada do jogador. CONTINUAR reflete o estado do save (desativado sem save); NOVO JOGO inicia/sobrescreve; OPCOES leva ao remapeamento. Slice vertical: ao terminar, o jogador ve e interage com a tela inicial completa.
Output: scenes/main_menu/ (tscn + gd), project.godot apontando para a nova cena inicial.
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
SaveManager.save_exists() -> bool
SaveManager.new_game() -> void
SceneTransition.go_to(scene_path: String) -> void

<!-- UI-SPEC.md secao Screen 1 + Godot Node Specification (MainMenu scene tree) é o contrato visual. -->
<!-- Paleta: fundo #1A1A2E; texto #E8E8F0; desabilitado #888888; acao verde #4CAF50; -->
<!-- aviso vermelho #E53935 (flash 1 frame). Acento foco #0F3460. Titulo 16px, botoes 128x20, gap 8px. -->
<!-- Viewport base 320x180. Copy: CONTINUAR / NOVO JOGO / OPCOES (UI-SPEC Copywriting Contract). -->
</interfaces>
</context>

<tasks>

<task type="auto">
  <name>Task 1: Cena e script do Main Menu</name>
  <files>scenes/main_menu/main_menu.tscn, scenes/main_menu/main_menu.gd</files>
  <read_first>
    - scenes/test_movement/test_movement.tscn (formato .tscn de referencia: header gd_scene, ext_resource script, padrao de nodes)
    - scenes/test_movement/test_movement.gd (padrao de scene script: @onready, _ready)
    - .planning/phases/02-infraestrutura/02-UI-SPEC.md secao Screen 1 MainMenu + Godot Node Specification (arvore de nodes exata)
    - .planning/phases/02-infraestrutura/02-PATTERNS.md secao main_menu.gd e main_menu.tscn (acesso a autoload por nome global)
  </read_first>
  <action>
    Criar `scenes/main_menu/main_menu.tscn` com root `Control` (name `MainMenu`, anchors full-rect) seguindo a arvore exata do UI-SPEC Godot Node Specification:
    - `Background` (ColorRect, 320x180, color `#1A1A2E`)
    - `TitleLabel` (Label, text="Destiny — Tales de Natalia" ou o config/name do projeto, 16px, centralizado, y=40, color `#E8E8F0`)
    - `ButtonGroup` (VBoxContainer, centralizado H, y=80, separation=8) com tres filhos `ContinueButton` (128x20, text="CONTINUAR"), `NewGameButton` (128x20, text="NOVO JOGO"), `OptionsButton` (128x20, text="OPCOES")
    - `VersionLabel` (Label, text="v0.2", 8px, color `#8888AA`, canto inferior direito, y=172)
    Aplicar texture filter Nearest implicito pelo projeto; bordas quadradas (sem cantos arredondados). Cores exatas da paleta UI-SPEC secao Color Palette.
    Criar `scenes/main_menu/main_menu.gd` (`extends Control`) com `@onready` para os tres botoes. `_ready()`:
    - `continue_button.disabled = not SaveManager.save_exists()`; se desabilitado, aplicar cor de texto/borda `#888888` (estado disabled wash).
    - Conectar `pressed` de cada botao a handlers: `_on_continue_pressed` (transita para a primeira fase placeholder — usar `SceneTransition.go_to("res://scenes/test_movement/test_movement.tscn")` como destino temporario ate Phase 3 ter as fases reais), `_on_new_game_pressed` (flash vermelho `#E53935` 1 frame se `SaveManager.save_exists()`, depois `SaveManager.new_game()` e `SceneTransition.go_to(...)` para a mesma fase), `_on_options_pressed` (`SceneTransition.go_to("res://scenes/options_menu/options_menu.tscn")`).
    - Foco inicial: se save existe, focar ContinueButton; senao NewGameButton (navegacao Up/Down + D-pad ja vem do foco padrao Godot entre botoes).
    Acessar SaveManager e SceneTransition por nome global (autoloads do Plano 02), sem preload.
    Rodar `godot --headless --path . --check-only`.
  </action>
  <acceptance_criteria>
    - `scenes/main_menu/main_menu.tscn` tem root Control e contem `ContinueButton`, `NewGameButton`, `OptionsButton`
    - `scenes/main_menu/main_menu.tscn` contem as strings `CONTINUAR`, `NOVO JOGO`, `OPCOES`
    - `scenes/main_menu/main_menu.gd` contem `SaveManager.save_exists`, `SaveManager.new_game`, `SceneTransition.go_to`
    - `main_menu.gd` define `continue_button.disabled` a partir de `save_exists()`
    - Cor `1a1a2e` (ou Color equivalente) presente no Background do tscn
    - `godot --headless --path . --check-only` sai com codigo 0
  </acceptance_criteria>
  <verify>
    <automated>cd /Users/renatojaf/jogo-natalia; grep -q "ContinueButton" scenes/main_menu/main_menu.tscn; grep -q "NOVO JOGO" scenes/main_menu/main_menu.tscn; grep -q "SaveManager.save_exists" scenes/main_menu/main_menu.gd; grep -q "SceneTransition.go_to" scenes/main_menu/main_menu.gd; godot --headless --path . --check-only</automated>
  </verify>
  <done>Main Menu renderiza tres botoes com a paleta UI-SPEC; CONTINUAR reflete save_exists; check passa.</done>
</task>

<task type="auto">
  <name>Task 2: Definir Main Menu como cena inicial</name>
  <files>project.godot</files>
  <read_first>
    - project.godot (linha `run/main_scene="res://scenes/main.tscn"` — sera trocada)
    - scenes/main_menu/main_menu.tscn (cena criada na Task 1)
  </read_first>
  <action>
    Em project.godot, alterar `run/main_scene` de `"res://scenes/main.tscn"` para `"res://scenes/main_menu/main_menu.tscn"`. Isto faz o jogo iniciar pela tela inicial (SAVE-03 — o jogador ve Continue/New Game ao abrir).
    Confirmar que `godot --headless --path . --check-only` continua passando e que a cena referenciada existe.
  </action>
  <acceptance_criteria>
    - `project.godot` contem `run/main_scene="res://scenes/main_menu/main_menu.tscn"`
    - `project.godot` NAO contem mais `run/main_scene="res://scenes/main.tscn"`
    - `godot --headless --path . --check-only` sai com codigo 0
  </acceptance_criteria>
  <verify>
    <automated>cd /Users/renatojaf/jogo-natalia; grep -q 'run/main_scene="res://scenes/main_menu/main_menu.tscn"' project.godot; godot --headless --path . --check-only</automated>
  </verify>
  <done>Projeto inicia pela tela inicial.</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>Tela inicial com CONTINUAR (desativado sem save), NOVO JOGO e OPCOES, definida como cena inicial.</what-built>
  <how-to-verify>
    1. Apagar qualquer save existente: remover `user://save.dat` (no macOS: `~/Library/Application Support/Godot/app_userdata/Destiny — Tales of Natalia/save.dat`).
    2. Abrir o projeto no Godot e pressionar F5 (roda a cena inicial).
    3. Confirmar: CONTINUAR aparece esmaecido/desabilitado (sem save); NOVO JOGO e OPCOES habilitados.
    4. Clicar NOVO JOGO — deve transitar (fade) para a fase placeholder. Voltar e reabrir: CONTINUAR agora deve estar habilitado (save foi criado).
    5. Clicar OPCOES — deve transitar para o menu de opcoes (pode ainda nao existir se o Plano 04 nao rodou; nesse caso confirme apenas que a chamada nao crasha).
    6. Confirmar paleta: fundo escuro #1A1A2E, texto claro, botoes 128x20 centralizados.
  </how-to-verify>
  <resume-signal>Digite "approved" ou descreva ajustes de layout/comportamento.</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| MainMenu -> SaveManager | UI consulta estado do save; sem escrita direta de arquivo |
| NOVO JOGO -> SaveManager.new_game | Sobrescreve o save unico intencionalmente (D-01) |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-02-07 | Tampering | NOVO JOGO apaga progresso por engano | accept | Single-slot intencional (D-01); flash vermelho de 1 frame como aviso visual; jogo pessoal, perda recuperavel rejogando |
| T-02-08 | Denial of Service | CONTINUAR habilitado sem save valido | mitigate | disabled = not SaveManager.save_exists() avaliado em _ready() a cada entrada na cena |
</threat_model>

<verification>
- `godot --headless --path . --check-only` passa.
- main_menu.tscn e a cena inicial; tres botoes presentes com copy correto.
- Human-verify confirma CONTINUAR desabilitado sem save e habilitado apos New Game.
</verification>

<success_criteria>
SAVE-03 atendido: tela inicial com Continue (desativado sem save) e New Game; success criterion 2 do ROADMAP.
</success_criteria>

<output>
Apos completar, criar `.planning/phases/02-infraestrutura/02-003-SUMMARY.md`.
</output>
