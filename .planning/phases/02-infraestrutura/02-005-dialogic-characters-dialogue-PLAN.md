---
phase: 02-infraestrutura
plan: 05
type: execute
wave: 3
depends_on: [01, 02]
files_modified:
  - dialogic/characters/Natalia.dch
  - dialogic/characters/Renato.dch
  - dialogic/timelines/test_dialogue.dtl
  - scenes/test_dialogue/test_dialogue.tscn
  - scenes/test_dialogue/test_dialogue.gd
autonomous: false
requirements: [NARR-01, NARR-02]
must_haves:
  truths:
    - "Uma caixa de diálogo Dialogic 2 exibe texto com retrato de personagem e avança com input"
    - "Natalia.dch e Renato.dch existem com portraits referenciando natalia_portrait.png e renato_portrait.png"
    - "test_dialogue.dtl tem timeline com Natália falando 2 linhas e Renato respondendo 1"
    - "start_cutscene() em test_dialogue.gd usa SaveManager.has_seen_cutscene() para habilitar auto_skip"
    - "Cutscene já vista tem botão Pular visível; nova cutscene não tem botão proeminente"
    - "SaveManager.mark_cutscene_seen() é chamado ao fim da timeline"
  artifacts:
    - path: "dialogic/characters/Natalia.dch"
      provides: "Personagem Dialogic: Natália com portrait natalia_portrait.png"
      contains: "natalia_portrait"
    - path: "dialogic/characters/Renato.dch"
      provides: "Personagem Dialogic: Renato com portrait renato_portrait.png"
      contains: "renato_portrait"
    - path: "dialogic/timelines/test_dialogue.dtl"
      provides: "Timeline de teste: Natália 2 linhas + Renato 1 resposta"
      contains: "test_dialogue"
    - path: "scenes/test_dialogue/test_dialogue.tscn"
      provides: "Cena de validação NARR-01/NARR-02 com botão Pular"
      contains: "SkipButton"
    - path: "scenes/test_dialogue/test_dialogue.gd"
      provides: "Controller com start_cutscene() e lógica de skip seen"
      contains: "func start_cutscene"
  key_links:
    - from: "scenes/test_dialogue/test_dialogue.gd"
      to: "SaveManager"
      via: "SaveManager.has_seen_cutscene() e mark_cutscene_seen()"
      pattern: "SaveManager.has_seen_cutscene"
    - from: "scenes/test_dialogue/test_dialogue.gd"
      to: "Dialogic"
      via: "Dialogic.start() + await Dialogic.timeline_ended"
      pattern: "Dialogic.start"
    - from: "dialogic/characters/Natalia.dch"
      to: "assets/sprites/portraits/natalia_portrait.png"
      via: "portrait path reference"
      pattern: "natalia_portrait"
---

<objective>
Configurar os personagens Dialogic 2 (Natalia e Renato com seus portraits pixel art), criar a timeline de teste de diálogo, e implementar a cena de validação `test_dialogue.tscn` com lógica completa de skip-on-seen usando SaveManager — satisfazendo NARR-01 e NARR-02.

Purpose: NARR-01 e NARR-02 são a espinha dorsal da narrativa dos 8 mundos. A infraestrutura do diálogo (personagens configurados, API `start_cutscene()`, integração com seen_cutscenes) deve estar funcional antes de Phase 3 adicionar diálogos de enredo. Slice vertical: ao terminar, um diálogo completo com portrait e skip funciona end-to-end.
Output: dialogic/characters/ (2 personagens), dialogic/timelines/ (1 timeline teste), scenes/test_dialogue/ (tscn + gd).
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/ROADMAP.md
@.planning/phases/02-infraestrutura/02-CONTEXT.md
@.planning/phases/02-infraestrutura/02-RESEARCH.md
@.planning/phases/02-infraestrutura/02-UI-SPEC.md
@scenes/player/player.gd
@project.godot

<interfaces>
<!-- Contratos públicos estabelecidos no Plan 02 (já implementados) -->
SaveManager (autoload disponível):
  func has_seen_cutscene(cutscene_id: String) -> bool
  func mark_cutscene_seen(cutscene_id: String) -> void

Dialogic (autoload instalado pelo Plan 02):
  func start(timeline_name: String) -> Node
  signal timeline_ended
  var Inputs.auto_skip.enabled: bool
  var Inputs.auto_skip.time_per_event: float
  var current_timeline  # null se nao rodando

<!-- Portraits gerados pelo Plan 01 -->
Portrait Natália: assets/sprites/portraits/natalia_portrait.png (64x80 px)
Portrait Renato:  assets/sprites/portraits/renato_portrait.png (64x80 px)

<!-- UI-SPEC.md para a caixa de diálogo (consultar para implementar SkipButton) -->
Dialogue box: altura 56px, portrait 64x80, cor fundo #1A1A2E, texto #E8E8F0, fonte m5x7/8px
SkipButton: visível (visible=true) quando seen; oculto (visible=false) quando not seen
</interfaces>
</context>

<tasks>

<task type="auto">
  <name>Task 1: Criar estrutura de diretórios Dialogic e personagem Natalia.dch</name>
  <files>dialogic/characters/Natalia.dch</files>
  <read_first>
    - project.godot (confirmar que Dialogic está instalado e habilitado — seção [editor_plugins])
    - addons/dialogic/plugin.cfg (verificar versão e estrutura do plugin instalado)
    - assets/sprites/portraits/natalia_portrait.png (confirmar que existe após Plan 01)
    - .planning/phases/02-infraestrutura/02-RESEARCH.md seção Pattern 3 (Dialogic 2 integração) e Pitfall 4 (Dialogic.start aceita nome sem extensão)
    - .planning/phases/02-infraestrutura/02-CONTEXT.md D-11, D-12 (personagens com portraits placeholder coloridos; portrait estilo JRPG busto)
  </read_first>
  <action>
    Criar o diretório `dialogic/characters/` e o arquivo `Natalia.dch` no formato JSON do Dialogic 2. O formato .dch é JSON com campos: `"name"`, `"display_name"`, `"color"` (hex), `"portraits"` (dict de variante → path), `"export_overrides"`, `"description"`. Estrutura mínima necessária:
    - `"name": "Natalia"` (deve coincidir com o nome usado em `Dialogic.start()`)
    - `"display_name": "Natália"`
    - `"color": "#8B4BA0"` (roxo — cor placeholder definida em D-11)
    - `"portraits"`: `{"default": {"scene": "res://assets/sprites/portraits/natalia_portrait.png"}}` — se natalia_portrait.png ainda não existir (Plan 01 pendente), usar placeholder `{"default": {"scene": ""}}` e adicionar nota no SUMMARY
    - Verificar o formato exato do .dch inspecionando a pasta `addons/dialogic/` por exemplos ou pelo editor do plugin (se `godot --headless` puder gerar)
    - Criar `dialogic/` e `dialogic/characters/` via mkdir
  </action>
  <acceptance_criteria>
    - Arquivo `dialogic/characters/Natalia.dch` existe
    - `Natalia.dch` é JSON válido (parseable por `python3 -c "import json; json.load(open('dialogic/characters/Natalia.dch'))"`)
    - Contém `"name": "Natalia"` e `"display_name": "Natália"`
    - Contém referência a portrait: campo `"portraits"` não vazio
    - `godot --headless --path . --check-only` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>cd /Users/renatojaf/jogo-natalia; test -f dialogic/characters/Natalia.dch; python3 -c "import json; d=json.load(open('dialogic/characters/Natalia.dch')); assert d['name']=='Natalia'"; godot --headless --path . --check-only</automated>
  </verify>
  <done>Natalia.dch criado como JSON válido com name e portrait; check headless passa.</done>
</task>

<task type="auto">
  <name>Task 2: Criar personagem Renato.dch</name>
  <files>dialogic/characters/Renato.dch</files>
  <read_first>
    - dialogic/characters/Natalia.dch (usar como template exato de formato)
    - assets/sprites/portraits/renato_portrait.png (confirmar existência após Plan 01)
    - .planning/phases/02-infraestrutura/02-CONTEXT.md D-11 (cor placeholder Renato: azul)
  </read_first>
  <action>
    Criar `dialogic/characters/Renato.dch` com o mesmo formato de Natalia.dch:
    - `"name": "Renato"`
    - `"display_name": "Renato"`
    - `"color": "#4A7BC0"` (azul — cor placeholder D-11)
    - `"portraits"`: `{"default": {"scene": "res://assets/sprites/portraits/renato_portrait.png"}}`
    Copiar estrutura JSON de Natalia.dch e ajustar apenas name, display_name, color e portrait path.
  </action>
  <acceptance_criteria>
    - Arquivo `dialogic/characters/Renato.dch` existe
    - `Renato.dch` é JSON válido com `"name": "Renato"` e `"display_name": "Renato"`
    - Contém `"color": "#4A7BC0"` (azul)
    - Contém referência a `renato_portrait.png` no campo portraits
    - `godot --headless --path . --check-only` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>cd /Users/renatojaf/jogo-natalia; test -f dialogic/characters/Renato.dch; python3 -c "import json; d=json.load(open('dialogic/characters/Renato.dch')); assert d['name']=='Renato'"; grep -q "renato_portrait" dialogic/characters/Renato.dch; godot --headless --path . --check-only</automated>
  </verify>
  <done>Renato.dch criado como JSON válido; check headless passa.</done>
</task>

<task type="auto">
  <name>Task 3: Criar timeline de teste test_dialogue.dtl</name>
  <files>dialogic/timelines/test_dialogue.dtl</files>
  <read_first>
    - dialogic/characters/Natalia.dch (nome exato do personagem para usar na timeline)
    - dialogic/characters/Renato.dch (nome exato do personagem para usar na timeline)
    - addons/dialogic/ (inspecionar estrutura de .dtl existente em exemplos ou templates do plugin para formato correto)
    - .planning/phases/02-infraestrutura/02-CONTEXT.md D-14 (diálogo de teste: Natália 2 linhas, Renato responde 1)
    - .planning/phases/02-infraestrutura/02-RESEARCH.md Pitfall 4 (Dialogic.start aceita nome "test_dialogue" sem extensão)
  </read_first>
  <action>
    Criar `dialogic/timelines/` e `dialogic/timelines/test_dialogue.dtl`. O formato .dtl do Dialogic 2 é um arquivo de texto com um event por linha em formato `[event_type argument="value" ...]`. Estrutura mínima para o diálogo de teste (D-14):
    - Line 1: `[dialogic_event text character="Natalia" portrait="default" text="De Osasco à Espanha — essa é a minha história."]`
    - Line 2: `[dialogic_event text character="Natalia" portrait="default" text="Cada obstáculo me fez mais forte."]`
    - Line 3: `[dialogic_event text character="Renato" portrait="default" text="E eu estive aqui em cada passo."]`
    - Line 4: `[dialogic_event end_timeline]`
    Verificar o formato exato inspecionando qualquer arquivo .dtl de exemplo no addons/dialogic/. Se o formato for diferente, adaptar preservando os 3 eventos de diálogo (Natalia x2, Renato x1) e o end_timeline.
    O nome do arquivo `test_dialogue.dtl` permite chamá-lo como `Dialogic.start("test_dialogue")` (Pitfall 4 — sem extensão).
  </action>
  <acceptance_criteria>
    - Arquivo `dialogic/timelines/test_dialogue.dtl` existe
    - Contém ao menos 3 eventos de diálogo (Natalia x2, Renato x1)
    - Contém evento de fim de timeline (end_timeline ou equivalente)
    - `godot --headless --path . --check-only` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>cd /Users/renatojaf/jogo-natalia; test -f dialogic/timelines/test_dialogue.dtl; grep -c "Natalia" dialogic/timelines/test_dialogue.dtl; grep -q "Renato" dialogic/timelines/test_dialogue.dtl; godot --headless --path . --check-only</automated>
  </verify>
  <done>Timeline test_dialogue.dtl criada com 3 eventos (Natalia 2x, Renato 1x) + end.</done>
</task>

<task type="auto">
  <name>Task 4: Implementar test_dialogue.tscn + test_dialogue.gd com lógica de skip</name>
  <files>scenes/test_dialogue/test_dialogue.tscn, scenes/test_dialogue/test_dialogue.gd</files>
  <read_first>
    - scenes/test_movement/test_movement.tscn (padrão de cena de teste: Node2D root + script)
    - scenes/test_movement/test_movement.gd (padrão de script: extends, @onready, _ready, signal connections)
    - scenes/player/player.gd (convenções: tipagem :=, funções com return type, await)
    - .planning/phases/02-infraestrutura/02-RESEARCH.md Pattern 3 (start_cutscene completo com auto_skip e await)
    - .planning/phases/02-infraestrutura/02-CONTEXT.md D-13 (skip: visible=false por padrão; visible=true se seen)
    - .planning/phases/02-infraestrutura/02-UI-SPEC.md seção DialogueBox (altura 56px, cor #1A1A2E, SkipButton)
    - autoloads/save_manager.gd (interface: has_seen_cutscene, mark_cutscene_seen)
  </read_first>
  <action>
    Criar `scenes/test_dialogue/test_dialogue.tscn`: root `Node2D` (name `TestDialogue`) com script `test_dialogue.gd`. Adicionar filho `Button` (name `SkipButton`, text "PULAR", visible=false, posição canto superior direito ~280x8 em 320x180). Adicionar filho `Button` (name `StartButton`, text "INICIAR DIÁLOGO", posição centralizada) para disparar o diálogo via clique.

    Criar `scenes/test_dialogue/test_dialogue.gd` (`extends Node2D`):
    - `@onready var skip_button: Button = $SkipButton`
    - `@onready var start_button: Button = $StartButton`
    - `const TIMELINE_ID := "test_dialogue"` (nome sem extensão — Pitfall 4)
    - `func _ready() -> void`: conectar `start_button.pressed` a `_on_start_pressed`; conectar `skip_button.pressed` a `_on_skip_pressed`
    - `func _on_start_pressed() -> void`: chamar `start_cutscene(TIMELINE_ID)`
    - `func start_cutscene(timeline_name: String) -> void` (padrão de RESEARCH.md Pattern 3):
      - Se `Dialogic.current_timeline != null`: return (evitar iniciar se já rodando)
      - Se `SaveManager.has_seen_cutscene(timeline_name)`: `Dialogic.Inputs.auto_skip.enabled = true`; `Dialogic.Inputs.auto_skip.time_per_event = 0.05`; `skip_button.visible = true` (NARR-02: botão visível para vistas)
      - Senão: `skip_button.visible = false` (não proeminente para cutscenes não vistas)
      - `Dialogic.start(timeline_name)`
      - `await Dialogic.timeline_ended`
      - `SaveManager.mark_cutscene_seen(timeline_name)` (gravar que foi vista — NARR-02)
      - `Dialogic.Inputs.auto_skip.enabled = false`
      - `skip_button.visible = false`
    - `func _on_skip_pressed() -> void`: `Dialogic.Inputs.auto_skip.enabled = not Dialogic.Inputs.auto_skip.enabled`
  </action>
  <acceptance_criteria>
    - `scenes/test_dialogue/test_dialogue.tscn` existe com root Node2D, filho SkipButton (visible=false) e StartButton
    - `scenes/test_dialogue/test_dialogue.gd` contém `func start_cutscene`
    - `start_cutscene` chama `SaveManager.has_seen_cutscene` e `mark_cutscene_seen`
    - `start_cutscene` seta `skip_button.visible = true` quando seen e `false` quando not seen (NARR-02)
    - `start_cutscene` usa `await Dialogic.timeline_ended` (não polling)
    - `start_cutscene` usa `Dialogic.Inputs.auto_skip.enabled` para skip automático em cutscenes vistas
    - `godot --headless --path . --check-only` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>cd /Users/renatojaf/jogo-natalia; test -f scenes/test_dialogue/test_dialogue.tscn; test -f scenes/test_dialogue/test_dialogue.gd; grep -q "func start_cutscene" scenes/test_dialogue/test_dialogue.gd; grep -q "has_seen_cutscene" scenes/test_dialogue/test_dialogue.gd; grep -q "mark_cutscene_seen" scenes/test_dialogue/test_dialogue.gd; grep -q "skip_button.visible" scenes/test_dialogue/test_dialogue.gd; grep -q "auto_skip" scenes/test_dialogue/test_dialogue.gd; godot --headless --path . --check-only</automated>
  </verify>
  <done>test_dialogue.tscn e .gd implementados com lógica completa de skip-on-seen via SaveManager.</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <name>Task 5: Human verify — diálogo Dialogic funcional com portrait e skip</name>
  <files>scenes/test_dialogue/test_dialogue.tscn</files>
  <read_first>
    - scenes/test_dialogue/test_dialogue.tscn (cena a abrir no editor)
    - .planning/ROADMAP.md §Phase 2 success criterion 3 (caixa de diálogo com retrato, avança com input, pulável)
  </read_first>
  <action>
    Abrir a cena `scenes/test_dialogue/test_dialogue.tscn` no editor Godot (F6 para rodar isolada).
    Verificar manualmente:
    1. Clicar INICIAR DIÁLOGO — caixa de diálogo Dialogic aparece com texto "De Osasco à Espanha" e retrato da Natália
    2. Pressionar Enter/Space — avança para a segunda linha de Natália
    3. Pressionar Enter/Space — avança para a linha do Renato com retrato do Renato
    4. Pressionar Enter/Space — timeline termina; botão Pular some
    5. Clicar INICIAR DIÁLOGO novamente — desta vez botão Pular aparece (cutscene já vista)
    6. Clicar Pular — diálogo avança automaticamente em velocidade alta (auto_skip)
    Confirmar: nenhum erro no console do Godot durante o teste.
  </action>
  <acceptance_criteria>
    - Caixa de diálogo aparece com texto e portrait de personagem (NARR-01 ✓)
    - Diálogo avança com Enter/Space sem travar
    - Botão PULAR oculto na primeira vez; visível na segunda vez (NARR-02 ✓)
    - Clicar PULAR na segunda vez faz a timeline avançar automaticamente
    - Nenhum erro no Output do Godot durante o playtest
  </acceptance_criteria>
  <done>Diálogo Dialogic 2 funcional com portrait e skip-on-seen validado em human verify.</done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| dialogic/timelines/*.dtl → Dialogic | Arquivos de timeline lidos pelo runtime; formato incorreto pode causar crash do plugin |
| SaveManager.has_seen_cutscene → UI skip | Dado lido do save.dat; corrompido → cutscene tratada como não vista (comportamento seguro — pior caso: usuário re-assiste) |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-05-01 | Tampering | seen_cutscenes corrompido no save | accept | Se save.dat for inválido, SaveManager já faz fallback para _default_save() (T-02-03); cutscene é re-exibida — perda mínima |
| T-05-02 | Integrity | Dialogic.start() em timeline inexistente | mitigate | Usar constante `TIMELINE_ID = "test_dialogue"` em vez de string literal; Pitfall 4 documentado |
| T-05-03 | DoS | Dialogic.start() chamado enquanto timeline já roda | mitigate | start_cutscene() verifica `Dialogic.current_timeline != null` antes de iniciar |
</threat_model>

<verification>
- `godot --headless --path . --check-only` passa com todos os arquivos Dialogic criados.
- dialogic/characters/Natalia.dch e Renato.dch são JSON válidos com name e portrait.
- dialogic/timelines/test_dialogue.dtl tem 3 eventos de diálogo e end.
- test_dialogue.gd contém start_cutscene() com has_seen_cutscene + mark_cutscene_seen + auto_skip.
- Human verify confirma diálogo com portrait + skip funcional (success criterion 3 do ROADMAP).
</verification>

<success_criteria>
NARR-01: Uma caixa de diálogo Dialogic 2 exibe texto com retrato de personagem, avança com input do jogador e é pulável via botão dedicado.
NARR-02: Cutscene já vista tem botão Pular visível desde o início; nova cutscene oculta o botão. seen_cutscenes registrado no save via SaveManager.mark_cutscene_seen().
</success_criteria>

<output>
Após completar, criar `.planning/phases/02-infraestrutura/02-005-SUMMARY.md`.
</output>
