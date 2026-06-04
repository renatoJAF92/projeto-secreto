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
    - "NOVO JOGO com save existente exibe ConfirmationDialog antes de apagar progresso"
    - "NOVO JOGO chama SaveManager.new_game() apenas apos confirmacao (ou direto se nao ha save) e transita via SceneTransition"
    - "OPCOES abre o menu de opcoes via SceneTransition.go_to()"
    - "main_menu.tscn e a cena inicial do projeto (run/main_scene)"
  artifacts:
    - path: "scenes/main_menu/main_menu.tscn"
      provides: "Tela inicial Control com Continue/New Game/Opcoes + ConfirmationDialog — SAVE-03"
      contains: "ContinueButton"
    - path: "scenes/main_menu/main_menu.gd"
      provides: "Controller da tela inicial; consulta SaveManager; confirma sobrescrita de save"
      contains: "save_exists"
  key_links:
    - from: "scenes/main_menu/main_menu.gd"
      to: "SaveManager"
      via: "SaveManager.save_exists() para habilitar Continue e gatear a confirmacao de New Game"
      pattern: "SaveManager.save_exists"
    - from: "scenes/main_menu/main_menu.gd"
      to: "ConfirmNewGame (ConfirmationDialog)"
      via: "sinal confirmed -> SaveManager.new_game()"
      pattern: "confirmed"
    - from: "scenes/main_menu/main_menu.gd"
      to: "SceneTransition"
      via: "SceneTransition.go_to nas transicoes"
      pattern: "SceneTransition.go_to"
---

<objective>
Implementar a tela inicial (Main Menu) com CONTINUAR, NOVO JOGO e OPCOES, satisfazendo SAVE-03, e defini-la como cena inicial do projeto.

Purpose: SAVE-03 — o ponto de entrada do jogador. CONTINUAR reflete o estado do save (desativado sem save); NOVO JOGO inicia/sobrescreve com confirmacao explicita; OPCOES leva ao remapeamento. Slice vertical: ao terminar, o jogador ve e interage com a tela inicial completa.
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
<!-- aviso vermelho #E53935. Acento foco #0F3460. Titulo 16px, botoes 128x20, gap 8px. -->
<!-- Viewport base 320x180. Copy: CONTINUAR / NOVO JOGO / OPCOES (UI-SPEC Copywriting Contract). -->
<!-- NOVO JOGO com save existente requer ConfirmationDialog (acao irreversivel — single save slot D-01). -->
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
    - `ConfirmNewGame` (ConfirmationDialog, name `ConfirmNewGame`, `dialog_text="Apagar progresso? Esta acao nao pode ser desfeita.", `ok_button_text="APAGAR"`, `cancel_button_text="CANCELAR"`, `dialog_hide_on_ok=true`, oculto por padrao). Este node existe para confirmar a sobrescrita do save unico (D-01) — substitui o antigo flash vermelho de 1 frame, julgado sutil demais para uma acao irreversivel.
    - `VersionLabel` (Label, text="v0.2", 8px, color `#8888AA`, canto inferior direito, y=172)
    Aplicar texture filter Nearest implicito pelo projeto; bordas quadradas (sem cantos arredondados). Cores exatas da paleta UI-SPEC secao Color Palette.
    Criar `scenes/main_menu/main_menu.gd` (`extends Control`) com `@onready` para os tres botoes e para `ConfirmNewGame`. `_ready()`:
    - `continue_button.disabled = not SaveManager.save_exists()`; se desabilitado, aplicar cor de texto/borda `#888888` (estado disabled wash).
    - Conectar `pressed` de cada botao a handlers e conectar o sinal `confirmed` de `ConfirmNewGame` a `_on_new_game_confirmed`.
    - `_on_continue_pressed`: transita para a primeira fase placeholder — usar `SceneTransition.go_to("res://scenes/test_movement/test_movement.tscn")` como destino temporario ate Phase 3 ter as fases reais.
    - `_on_new_game_pressed` (Addresses review concern: New Game overwrites save without confirmation — MEDIUM, Gemini): se `SaveManager.save_exists()` for true, chamar `confirm_new_game.popup_centered()` e RETORNAR — NAO chamar `SaveManager.new_game()` aqui. Se NAO ha save, prosseguir direto: `SaveManager.new_game()` e `SceneTransition.go_to("res://scenes/test_movement/test_movement.tscn")`. Remover completamente a abordagem do flash vermelho de 1 frame.
    - `_on_new_game_confirmed` (handler do sinal `confirmed` do ConfirmNewGame — so dispara quando o jogador clica APAGAR): `SaveManager.new_game()` e depois `SceneTransition.go_to("res://scenes/test_movement/test_movement.tscn")`. Se o jogador clicar CANCELAR, o ConfirmationDialog apenas fecha (sinal `confirmed` nao dispara) e nada acontece.
    - `_on_options_pressed`: `SceneTransition.go_to("res://scenes/options_menu/options_menu.tscn")`.
    - Foco inicial: se save existe, focar ContinueButton; senao NewGameButton (navegacao Up/Down + D-pad ja vem do foco padrao Godot entre botoes).
    Acessar SaveManager e SceneTransition por nome global (autoloads do Plano 02), sem preload.
    Rodar `godot --headless --path . --check-only`.
  </action>
  <acceptance_criteria>
    - `scenes/main_menu/main_menu.tscn` tem root Control e contem `ContinueButton`, `NewGameButton`, `OptionsButton`
    - `scenes/main_menu/main_menu.tscn` contem as strings `CONTINUAR`, `NOVO JOGO`, `OPCOES`
    - `scenes/main_menu/main_menu.tscn` contem `ConfirmNewGame` (node ConfirmationDialog)
    - `scenes/main_menu/main_menu.gd` contem `ConfirmationDialog` (ou o tipo do node) e conecta o sinal `confirmed` a um handler que chama `SaveManager.new_game()`
    - `scenes/main_menu/main_menu.gd` contem `SaveManager.save_exists`, `SaveManager.new_game`, `SceneTransition.go_to`
    - `_on_new_game_pressed` so chama `SaveManager.new_game()` diretamente quando NAO ha save; com save existente, exibe o ConfirmationDialog (popup) e retorna
    - `main_menu.gd` define `continue_button.disabled` a partir de `save_exists()`
    - Cor `1a1a2e` (ou Color equivalente) presente no Background do tscn
    - `godot --headless --path . --check-only` sai com codigo 0
  </acceptance_criteria>
  <verify>
    <automated>cd /Users/renatojaf/jogo-natalia; grep -q "ContinueButton" scenes/main_menu/main_menu.tscn; grep -q "NOVO JOGO" scenes/main_menu/main_menu.tscn; grep -q "ConfirmNewGame" scenes/main_menu/main_menu.tscn; grep -q "ConfirmationDialog" scenes/main_menu/main_menu.gd; grep -q "confirmed" scenes/main_menu/main_menu.gd; grep -q "SaveManager.save_exists" scenes/main_menu/main_menu.gd; grep -q "SceneTransition.go_to" scenes/main_menu/main_menu.gd; godot --headless --path . --check-only</automated>
  </verify>
  <done>Main Menu renderiza tres botoes com a paleta UI-SPEC; CONTINUAR reflete save_exists; NOVO JOGO com save exibe ConfirmationDialog antes de apagar; check passa.</done>
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
  <what-built>Tela inicial com CONTINUAR (desativado sem save), NOVO JOGO (com ConfirmationDialog quando ha save) e OPCOES, definida como cena inicial.</what-built>
  <how-to-verify>
    1. Apagar qualquer save existente: remover `user://save.dat` (no macOS: `~/Library/Application Support/Godot/app_userdata/Destiny — Tales of Natalia/save.dat`).
    2. Abrir o projeto no Godot e pressionar F5 (roda a cena inicial).
    3. Confirmar: CONTINUAR aparece esmaecido/desabilitado (sem save); NOVO JOGO e OPCOES habilitados.
    4. Clicar NOVO JOGO sem save — deve transitar (fade) direto para a fase placeholder, SEM dialogo de confirmacao (nao ha progresso a apagar). Voltar e reabrir: CONTINUAR agora deve estar habilitado (save foi criado).
    5. Com o save ja criado, clicar NOVO JOGO de novo — agora DEVE aparecer o ConfirmationDialog "Apagar progresso? Esta acao nao pode ser desfeita." com botoes APAGAR e CANCELAR. Clicar CANCELAR: nada acontece, volta ao menu, save intacto. Clicar NOVO JOGO de novo e clicar APAGAR: o save e sobrescrito e o jogo transita para a fase.
    6. Clicar OPCOES — deve transitar para o menu de opcoes (pode ainda nao existir se o Plano 04 nao rodou; nesse caso confirme apenas que a chamada nao crasha).
    7. Confirmar paleta: fundo escuro #1A1A2E, texto claro, botoes 128x20 centralizados.
  </how-to-verify>
  <resume-signal>Digite "approved" ou descreva ajustes de layout/comportamento.</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| MainMenu -> SaveManager | UI consulta estado do save; sem escrita direta de arquivo |
| NOVO JOGO -> SaveManager.new_game | Sobrescreve o save unico intencionalmente (D-01), agora gateado por ConfirmationDialog |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-02-07 | Tampering | NOVO JOGO apaga progresso por engano | mitigate | ConfirmationDialog ("Apagar progresso?") exibido antes de SaveManager.new_game() quando save existe; APAGAR/CANCELAR explicitos. Substitui o flash vermelho de 1 frame, sutil demais para acao irreversivel |
| T-02-08 | Denial of Service | CONTINUAR habilitado sem save valido | mitigate | disabled = not SaveManager.save_exists() avaliado em _ready() a cada entrada na cena |
</threat_model>

<verification>
- `godot --headless --path . --check-only` passa.
- main_menu.tscn e a cena inicial; tres botoes presentes com copy correto; ConfirmNewGame presente.
- Human-verify confirma CONTINUAR desabilitado sem save, e ConfirmationDialog antes de apagar progresso quando save existe (CANCELAR mantem intacto, APAGAR sobrescreve).
</verification>

<success_criteria>
SAVE-03 atendido: tela inicial com Continue (desativado sem save) e New Game protegido por confirmacao quando ha progresso; success criterion 2 do ROADMAP.
</success_criteria>

<output>
Apos completar, criar `.planning/phases/02-infraestrutura/02-003-SUMMARY.md`.
</output>
</content>
