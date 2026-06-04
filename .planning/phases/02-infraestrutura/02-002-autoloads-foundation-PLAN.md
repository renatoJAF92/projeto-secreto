---
phase: 02-infraestrutura
plan: 02
type: execute
wave: 1
depends_on: []
files_modified:
  - addons/dialogic/
  - autoloads/save_manager.gd
  - autoloads/scene_transition.gd
  - autoloads/controls_manager.gd
  - scenes/scene_transition/scene_transition.tscn
  - scenes/test_save/test_save.tscn
  - scenes/test_save/test_save.gd
  - project.godot
autonomous: true
requirements: [SAVE-01, SAVE-02]
must_haves:
  truths:
    - "Dialogic 2 Alpha 19 está instalado e habilitado (DialogicGameHandler autoload registrado)"
    - "SaveManager persiste e carrega checkpoint_id, worlds_completed, powers_unlocked, seen_cutscenes via FileAccess.store_var"
    - "SaveManager.save_exists() reflete corretamente a existência de user://save.dat"
    - "SceneTransition é autoload CanvasLayer que sobrevive à troca de cena (layer=100)"
    - "ControlsManager carrega/salva controles em user://controls.cfg e remapeia sem conflito"
    - "project.godot tem [autoload] com SaveManager, SceneTransition, ControlsManager prefixados com *"
    - "scenes/test_save/test_save.tscn existe com Checkpoint Area2D que chama SaveManager.set_checkpoint('test_cp_01')"
  artifacts:
    - path: "autoloads/save_manager.gd"
      provides: "Save system autoload — SAVE-01, SAVE-02"
      contains: "func save_game"
    - path: "autoloads/scene_transition.gd"
      provides: "Transição de cena com fade sem freeze"
      contains: "func go_to"
    - path: "autoloads/controls_manager.gd"
      provides: "Remapeamento e persistência de controles"
      contains: "func remap_action"
    - path: "project.godot"
      provides: "Registro dos autoloads custom + plugin Dialogic habilitado"
      contains: "[autoload]"
  key_links:
    - from: "autoloads/save_manager.gd"
      to: "user://save.dat"
      via: "FileAccess.store_var / get_var(true)"
      pattern: "store_var"
    - from: "autoloads/controls_manager.gd"
      to: "user://controls.cfg"
      via: "ConfigFile.save / load"
      pattern: "ConfigFile"
    - from: "project.godot"
      to: "autoloads/*.gd"
      via: "secção [autoload] com prefixo *"
      pattern: "autoload"
---

<objective>
Instalar Dialogic 2 Alpha 19 e implementar os três autoloads de infraestrutura (SaveManager, SceneTransition, ControlsManager) que todos os planos seguintes e todos os 8 mundos consomem.

Purpose: É a fundação técnica da fase. SAVE-01/SAVE-02 vivem no SaveManager; SceneTransition e ControlsManager são pré-requisitos do Main Menu, Options Menu e Dialogic. Dialogic DEVE ser instalado PRIMEIRO (Pitfall 1) para evitar conflito de ordem de autoloads.
Output: addons/dialogic instalado, 3 autoloads, cena do SceneTransition, project.godot com [autoload].
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/STATE.md
@.planning/phases/02-infraestrutura/02-CONTEXT.md
@.planning/phases/02-infraestrutura/02-RESEARCH.md
@.planning/phases/02-infraestrutura/02-PATTERNS.md

<interfaces>
<!-- Contratos públicos que os planos 03/04/05 consomem. Implementar EXATAMENTE assim. -->

SaveManager (autoload, extends Node):
  const SAVE_PATH := "user://save.dat"
  const SCHEMA_VERSION := 1
  var current_save: Dictionary
  func save_exists() -> bool
  func load_game() -> void
  func save_game() -> void
  func new_game() -> void
  func set_checkpoint(checkpoint_id: String) -> void
  func mark_cutscene_seen(cutscene_id: String) -> void
  func has_seen_cutscene(cutscene_id: String) -> bool
  func _default_save() -> Dictionary  # version, checkpoint_id, worlds_completed[], powers_unlocked[], seen_cutscenes{}

SceneTransition (autoload, extends CanvasLayer, layer=100):
  func go_to(scene_path: String) -> void  # fade out -> change_scene_to_file -> fade in

ControlsManager (autoload, extends Node):
  const CONTROLS_PATH := "user://controls.cfg"
  const ACTIONS := ["walk_left", "walk_right", "jump", "dash"]
  func load_controls() -> void
  func save_controls() -> void
  func remap_action(action: String, new_event: InputEvent) -> void
  func _serialize_event(event: InputEvent) -> Dictionary
  func _deserialize_event(data: Dictionary) -> InputEvent

<!-- Codigo de referencia completo dos 4 autoloads esta em 02-RESEARCH.md Patterns 1-4. -->
<!-- Defaults de gamepad em RESEARCH.md secao Code Examples (_add_gamepad_defaults). -->
</interfaces>
</context>

<tasks>

<task type="auto">
  <name>Task 1: Instalar e habilitar Dialogic 2 Alpha 19</name>
  <files>addons/dialogic/, project.godot</files>
  <read_first>
    - project.godot (estado atual: SEM [autoload], SEM [editor_plugins]; renderer gl_compatibility; input map com 4 acoes)
    - .planning/phases/02-infraestrutura/02-RESEARCH.md secao Common Pitfalls Pitfall 1 (Dialogic PRIMEIRO, antes dos autoloads custom)
    - .planning/phases/02-infraestrutura/02-RESEARCH.md secao Installation (download ZIP do release 2.0-alpha-19)
  </read_first>
  <action>
    Baixar Dialogic 2 Alpha 19 do GitHub release: https://github.com/dialogic-godot/dialogic/releases/tag/2.0-alpha-19. Usar `gh release download 2.0-alpha-19 --repo dialogic-godot/dialogic` ou curl do ZIP do asset do release. Extrair o diretorio `addons/dialogic` para `res://addons/dialogic`.
    Habilitar o plugin: adicionar a seccao `[editor_plugins]` em project.godot com `enabled=PackedStringArray("res://addons/dialogic/plugin.cfg")`. Ao habilitar, o Dialogic registra `DialogicGameHandler` (acessivel como `Dialogic`) como autoload — confirmar que a entrada aparece. Se o registro automatico nao ocorrer em modo headless, adicionar manualmente a entrada de autoload do Dialogic conforme o plugin.cfg do Dialogic.
    Validar compatibilidade com Godot 4.4.1 (TODO do STATE.md): rodar `godot --headless --path . --check-only` e confirmar ausencia de erros de parse do plugin. Se Alpha 19 tiver erro critico em 4.4.1 (Assumption A1 do RESEARCH), documentar no SUMMARY e parar para decisao.
    Verificar a ordem dos autoloads em project.godot APOS instalar — Dialogic deve estar registrado antes de adicionar os autoloads custom na Task 4 deste plano (a Task 4 adiciona os custom DEPOIS).
  </action>
  <acceptance_criteria>
    - Diretorio `addons/dialogic/plugin.cfg` existe
    - `project.godot` contem `[editor_plugins]` com `res://addons/dialogic/plugin.cfg`
    - `godot --headless --path . --check-only` sai com codigo 0 (plugin parseavel em 4.4.1)
    - Dialogic acessivel: autoload do Dialogic presente na config (grep por `Dialogic` em project.godot OU em .godot/global_script_class_cache)
  </acceptance_criteria>
  <verify>
    <automated>cd /Users/renatojaf/jogo-natalia; test -f addons/dialogic/plugin.cfg; grep -q "addons/dialogic/plugin.cfg" project.godot; godot --headless --path . --check-only</automated>
  </verify>
  <done>Dialogic 2 Alpha 19 instalado, habilitado e parseavel em Godot 4.4.1; sem erros de plugin.</done>
</task>

<task type="auto">
  <name>Task 2: SaveManager + SceneTransition autoloads</name>
  <files>autoloads/save_manager.gd, autoloads/scene_transition.gd, scenes/scene_transition/scene_transition.tscn</files>
  <read_first>
    - autoloads/ (vazio — confirmar)
    - scenes/player/player.gd (convencoes: extends, constantes UPPER_CASE, var tipadas com :=, funcoes com return type, padrao de tween linhas 187-201, await linha 217)
    - .planning/phases/02-infraestrutura/02-RESEARCH.md secao Pattern 1 (SaveManager codigo completo) e Pattern 2 (SceneTransition)
    - .planning/phases/02-infraestrutura/02-RESEARCH.md secao Common Pitfalls Pitfall 2 (get_var(true)) e Pitfall 3 (SceneTransition deve ser autoload CanvasLayer)
  </read_first>
  <action>
    Criar `autoloads/save_manager.gd` (`extends Node`) implementando EXATAMENTE a interface do bloco interfaces e o codigo de RESEARCH.md Pattern 1: `const SAVE_PATH := "user://save.dat"`, `const SCHEMA_VERSION := 1`, `var current_save: Dictionary = {}`. `_ready()` chama `load_game()`. `load_game()` usa `FileAccess.open(SAVE_PATH, FileAccess.READ)` e `file.get_var(true)` (allow_objects=true — Pitfall 2); valida `data is Dictionary and data.get("version", 0) == SCHEMA_VERSION` antes de aceitar, senao `current_save = _default_save()` (mitigacao de save corrompido — Tampering). `save_game()` usa `file.store_var(current_save, true)`. `_default_save()` retorna `{"version": SCHEMA_VERSION, "checkpoint_id": "", "worlds_completed": [], "powers_unlocked": [], "seen_cutscenes": {}}`. Implementar `save_exists()`, `new_game()`, `set_checkpoint()` (grava checkpoint_id + save_game — SAVE-01), `mark_cutscene_seen()`, `has_seen_cutscene()`.
    Criar `autoloads/scene_transition.gd` (`extends CanvasLayer`) com `@onready var overlay: ColorRect = $Overlay`. `_ready()` define `layer = 100` (acima do Dialogic em layer 50) e `overlay.color = Color(0,0,0,0)`. `go_to(scene_path: String) -> void`: criar tween fade `overlay` `color:a` 0 para 1 em 0.3s, `await t.finished`, `get_tree().change_scene_to_file(scene_path)`, `await get_tree().scene_changed`, tween fade 1 para 0, `await t.finished`. Usar `change_scene_to_file` (nao `change_scene`).
    Criar `scenes/scene_transition/scene_transition.tscn`: root `CanvasLayer` (name `SceneTransition`) com script `scene_transition.gd`, filho `ColorRect` (name `Overlay`) com anchors full-rect (offset 0 a 320x180) e `color = Color(0,0,0,0)`. Este .tscn e o que sera registrado como autoload (CanvasLayer precisa de cena para o ColorRect).
    NAO registrar ainda em project.godot — Task 4 faz o registro de todos juntos, apos Dialogic.
  </action>
  <acceptance_criteria>
    - `autoloads/save_manager.gd` contem `func save_game`, `func _default_save`, `get_var(true)`, `"seen_cutscenes"`
    - `autoloads/save_manager.gd` valida `data is Dictionary` e `data.get("version"` antes de usar
    - `autoloads/scene_transition.gd` contem `extends CanvasLayer`, `layer = 100`, `change_scene_to_file`, `func go_to`
    - `scenes/scene_transition/scene_transition.tscn` tem root CanvasLayer e filho ColorRect chamado `Overlay`
    - `godot --headless --path . --check-only` sai com codigo 0
  </acceptance_criteria>
  <verify>
    <automated>cd /Users/renatojaf/jogo-natalia; grep -q "func save_game" autoloads/save_manager.gd; grep -q "get_var(true)" autoloads/save_manager.gd; grep -q "layer = 100" autoloads/scene_transition.gd; grep -q "change_scene_to_file" autoloads/scene_transition.gd; grep -q "Overlay" scenes/scene_transition/scene_transition.tscn; godot --headless --path . --check-only</automated>
  </verify>
  <done>SaveManager e SceneTransition implementados conforme a interface; check headless passa.</done>
</task>

<task type="auto">
  <name>Task 3: ControlsManager autoload + defaults de gamepad</name>
  <files>autoloads/controls_manager.gd</files>
  <read_first>
    - scenes/player/player.gd (acoes usadas: walk_left, walk_right, jump, dash — linhas 68, 76, 87, 93; padrao _input linha 126)
    - project.godot secao [input] (eventos atuais por acao — keycodes que ControlsManager preserva como defaults)
    - .planning/phases/02-infraestrutura/02-RESEARCH.md secao Pattern 4 (ControlsManager completo) e Code Examples (_add_gamepad_defaults)
    - .planning/phases/02-infraestrutura/02-RESEARCH.md secao Common Pitfalls Pitfall 5 (salvar imediatamente apos remap)
  </read_first>
  <action>
    Criar `autoloads/controls_manager.gd` (`extends Node`) implementando a interface do bloco interfaces e RESEARCH.md Pattern 4: `const CONTROLS_PATH := "user://controls.cfg"`, `const ACTIONS := ["walk_left", "walk_right", "jump", "dash"]`.
    `_ready()`: chamar `_add_gamepad_defaults()` (adiciona eventos de gamepad as 4 acoes — ACCESS-03, sem config extra) e depois `load_controls()` (sobrepoe com remaps salvos, se houver).
    `_add_gamepad_defaults()` conforme RESEARCH.md Code Examples: jump = `JoyButton.A`, dash = `JoyButton.B`, walk_left = `InputEventJoypadMotion` axis `JoyAxis.LEFT_X` value -1.0, walk_right = mesmo axis value 1.0. Adicionar via `InputMap.action_add_event`.
    `load_controls()`: `ConfigFile.new()`; se `config.load(CONTROLS_PATH) != OK` retorna (usa defaults do project.godot + gamepad). Para cada action com seccao: `InputMap.action_erase_events(action)` e re-adicionar via `_deserialize_event`.
    `save_controls()`: serializar `InputMap.action_get_events(action)` por acao com `_serialize_event`, gravar com `config.set_value(action, "events", serialized)` e `config.save(CONTROLS_PATH)`.
    `remap_action(action, new_event)`: deteccao de conflito (DoS mitigation) — para cada `other_action != action` em ACTIONS, `InputMap.action_erase_event(other_action, new_event)`; depois `action_erase_events(action)` + `action_add_event(action, new_event)`; chamar `save_controls()` IMEDIATAMENTE (Pitfall 5).
    `_serialize_event`/`_deserialize_event` para os 3 tipos: `key` (physical_keycode), `joypad_button` (button_index), `joypad_motion` (axis, axis_value) — conforme Pattern 4.
    NAO registrar em project.godot ainda — Task 4 registra.
  </action>
  <acceptance_criteria>
    - `autoloads/controls_manager.gd` contem `const ACTIONS := ["walk_left", "walk_right", "jump", "dash"]`
    - Contem `func remap_action`, `func save_controls`, `func load_controls`, `func _add_gamepad_defaults`
    - `remap_action` chama `save_controls()` apos o remap (Pitfall 5)
    - `remap_action` limpa o new_event das outras acoes antes de adicionar (mitigacao conflito)
    - `_add_gamepad_defaults` usa `JoyButton.A`, `JoyButton.B`, `JoyAxis.LEFT_X`
    - `godot --headless --path . --check-only` sai com codigo 0
  </acceptance_criteria>
  <verify>
    <automated>cd /Users/renatojaf/jogo-natalia; grep -q "func remap_action" autoloads/controls_manager.gd; grep -q "save_controls()" autoloads/controls_manager.gd; grep -q "_add_gamepad_defaults" autoloads/controls_manager.gd; grep -q "JoyButton.A" autoloads/controls_manager.gd; grep -Eq 'ACTIONS . \["walk_left"' autoloads/controls_manager.gd; godot --headless --path . --check-only</automated>
  </verify>
  <done>ControlsManager implementado com remap, conflito, persistencia e defaults de gamepad; check passa.</done>
</task>

<task type="auto">
  <name>Task 4: Registrar autoloads custom em project.godot (apos Dialogic)</name>
  <files>project.godot</files>
  <read_first>
    - project.godot (estado apos Task 1: tem [editor_plugins] Dialogic + autoload do Dialogic)
    - .planning/phases/02-infraestrutura/02-RESEARCH.md secao Code Examples (registro de autoloads com prefixo *)
    - .planning/phases/02-infraestrutura/02-RESEARCH.md secao Common Pitfalls Pitfall 1 (custom autoloads DEPOIS do Dialogic na ordem)
  </read_first>
  <action>
    Na seccao `[autoload]` de project.godot (criada/estendida sem remover a entrada do Dialogic), adicionar APOS a entrada do Dialogic:
    `SaveManager="*res://autoloads/save_manager.gd"`
    `SceneTransition="*res://scenes/scene_transition/scene_transition.tscn"`
    `ControlsManager="*res://autoloads/controls_manager.gd"`
    Atencao: SceneTransition aponta para a CENA `.tscn` (precisa do ColorRect), nao para o `.gd`. SaveManager e ControlsManager apontam para o `.gd` (sao Node puros). O prefixo `*` marca como singleton global.
    A ordem importa (Pitfall 1): o autoload do Dialogic deve vir ANTES dos tres custom na seccao [autoload]. Garantir que nenhum autoload custom referencia `Dialogic` em `_ready()` (eles nao referenciam, mas confirmar).
    Validar startup headless: `godot --headless --path . --check-only` sem o erro `Invalid get index 'current_timeline' on base 'null'` (sinal de ordem errada — Pitfall 1).
  </action>
  <acceptance_criteria>
    - `project.godot` contem `SaveManager="*res://autoloads/save_manager.gd"`
    - `project.godot` contem `SceneTransition="*res://scenes/scene_transition/scene_transition.tscn"`
    - `project.godot` contem `ControlsManager="*res://autoloads/controls_manager.gd"`
    - A entrada de autoload do Dialogic aparece ANTES das tres entradas custom na seccao [autoload]
    - `godot --headless --path . --check-only` sai com codigo 0 e sem erro `current_timeline` no output
  </acceptance_criteria>
  <verify>
    <automated>cd /Users/renatojaf/jogo-natalia; grep -q "res://autoloads/save_manager.gd" project.godot; grep -q "res://scenes/scene_transition/scene_transition.tscn" project.godot; grep -q "res://autoloads/controls_manager.gd" project.godot; godot --headless --path . --check-only</automated>
  </verify>
  <done>Tres autoloads custom registrados apos o Dialogic; startup headless sem erro de ordem.</done>
</task>

<task type="auto">
  <name>Task 5: Criar cena de teste test_save.tscn para validar SAVE-01</name>
  <files>scenes/test_save/test_save.tscn, scenes/test_save/test_save.gd</files>
  <read_first>
    - autoloads/save_manager.gd (interface: set_checkpoint(checkpoint_id: String), save_exists(), current_save dict)
    - scenes/test_movement/test_movement.tscn (padrão de cena de teste: Node2D root + StaticBody2D chão + instância player)
    - scenes/player/player.tscn (cena do player a instanciar como filho)
    - .planning/phases/02-infraestrutura/02-VALIDATION.md seção SAVE-01 (procedimento de teste manual)
  </read_first>
  <action>
    Criar `scenes/test_save/test_save.gd` (`extends Node2D`). O script deve ter `@onready var label: Label = $StatusLabel` e em `_ready()` atualizar o label com `SaveManager.save_exists()` e `SaveManager.current_save.get("checkpoint_id", "(none)")`. Adicionar `func _on_checkpoint_entered(body: Node2D) -> void`: se body tem método `is_in_group("player")`, chamar `SaveManager.set_checkpoint("test_cp_01")` e atualizar o label para "SALVO: test_cp_01".
    Criar `scenes/test_save/test_save.tscn`: root `Node2D` (name `TestSave`) com script `test_save.gd`. Adicionar:
    - `StaticBody2D` + `CollisionShape2D` (RectangleShape2D 320x16) como chão em y=160
    - `Label` (name `StatusLabel`) em posição (8, 8) com text "Checkpoints: aguardando..."
    - `Area2D` (name `Checkpoint`) em posição (160, 120) com `CollisionShape2D` (CircleShape2D radius=16); conectar sinal `body_entered` a `_on_checkpoint_entered` no script da cena root
    - Instância de `scenes/player/player.tscn` posicionada em (80, 120)
    Não registrar como cena principal — é apenas cena de teste. Abrir com F6 no editor para validar manualmente.
  </action>
  <acceptance_criteria>
    - `scenes/test_save/test_save.tscn` existe com root Node2D, filho Checkpoint (Area2D) e filho StatusLabel (Label)
    - `scenes/test_save/test_save.gd` contém `func _on_checkpoint_entered` que chama `SaveManager.set_checkpoint("test_cp_01")`
    - `godot --headless --path . --check-only` sai com código 0
    - (manual) Abrir test_save.tscn, F6, caminhar até o checkpoint → label muda para "SALVO: test_cp_01"; fechar e reabrir mostra checkpoint_id no label (SAVE-01 verificado)
  </acceptance_criteria>
  <verify>
    <automated>cd /Users/renatojaf/jogo-natalia; test -f scenes/test_save/test_save.tscn; test -f scenes/test_save/test_save.gd; grep -q "set_checkpoint" scenes/test_save/test_save.gd; godot --headless --path . --check-only</automated>
  </verify>
  <done>test_save.tscn criada com Checkpoint Area2D que aciona SaveManager.set_checkpoint(); check headless passa.</done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| Arquivo user://save.dat -> SaveManager | Save binario carregado do disco; pode estar corrompido ou de versao antiga |
| Arquivo user://controls.cfg -> ControlsManager | Config de controles; chave pode mapear acoes em conflito |
| Plugin Dialogic -> project.godot autoloads | Plugin externo registra proprio autoload; ordem afeta integridade |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-02-03 | Tampering | save.dat corrompido ou adulterado | mitigate | load_game verifica `data is Dictionary` e `data.get("version") == SCHEMA_VERSION`; fallback para _default_save() |
| T-02-04 | Tampering | Schema version mismatch ao carregar | mitigate | Sempre checar campo version; save incompativel -> fresh start via _default_save() |
| T-02-05 | Denial of Service | Conflito de tecla no remap (mesma tecla em 2 acoes) | mitigate | remap_action apaga o new_event de todas as outras acoes antes de adicionar a acao alvo |
| T-02-06 | Tampering | Ordem de autoload Dialogic corrompida | mitigate | Instalar Dialogic PRIMEIRO; registrar custom DEPOIS; check-only sem erro current_timeline |
</threat_model>

<verification>
- `godot --headless --path . --check-only` passa com Dialogic instalado e 3 autoloads registrados.
- SaveManager, SceneTransition, ControlsManager presentes em [autoload] com prefixo *.
- Nenhum erro `current_timeline` na startup (ordem de autoload correta).
</verification>

<success_criteria>
SAVE-01 e SAVE-02 implementados (SaveManager persiste checkpoint, mundos, poderes, cutscenes via store_var com versionamento de schema). Infraestrutura (Dialogic, SceneTransition, ControlsManager) pronta para os planos 03/04/05.
</success_criteria>

<output>
Apos completar, criar `.planning/phases/02-infraestrutura/02-002-SUMMARY.md`.
</output>
