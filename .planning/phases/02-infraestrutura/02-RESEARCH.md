# Phase 2: Infraestrutura - Research

**Researched:** 2026-06-04
**Domain:** Godot 4 save system, scene transitions, Dialogic 2, input remapping, Python/Pillow sprite generation
**Confidence:** HIGH (verified via Context7, official Godot docs, Dialogic GitHub, live tool probing)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Save System (SAVE-01, SAVE-02, SAVE-03)**
- D-01: Slot único de save — sem seleção de múltiplos saves. Tela inicial com "Continue" (desativado sem save existente) e "New Game" (sobrescreve o save atual).
- D-02: O save persiste: ID do checkpoint (ex: `mundo1_fase2_cp3`), mundos completados, poderes desbloqueados, cutscenes já vistas. Não salva posição X/Y exata — respawn no início do checkpoint.
- D-03: Formato: `FileAccess.store_var()` / `FileAccess.load_var()` — binário Godot nativo.
- D-04: Auto-save dispara em dois momentos: (a) ao jogador tocar em checkpoint visual, (b) ao completar fase.
- D-05: SaveManager implementado como autoload em `autoloads/save_manager.gd`.

**Sprite NPC-04 — Natália**
- D-06: Fotos reais da Natália usadas como referência para o sprite sheet.
- D-07: Sprite sheet 32x32 com 6 animações: idle, run, jump, fall, hurt, death (+ dash).
- D-08: Claude gera sprite sheet programaticamente usando Python/Pillow.
- D-09: Portraits de diálogo (~64x80 px, busto JRPG) criados para Natália e Renato.

**Dialogic 2 (NARR-01, NARR-02)**
- D-10: Instalar Dialogic 2 via AssetLib / ZIP do GitHub; DialogicGameHandler como autoload.
- D-11: Criar personagens `Natalia` e `Renato` no editor Dialogic 2 com portraits placeholder coloridos.
- D-12: Portrait style: busto separado em maior resolução (JRPG style).
- D-13: Skip de cutscene via `Dialogic.Inputs.auto_skip` + dict `seen_cutscenes` no save.
- D-14: Um diálogo de teste demonstrável (Natália 2 linhas, Renato responde).

**Remapeamento de Controles (ACCESS-02, ACCESS-03)**
- D-15: Expor todas as ações: `walk_left`, `walk_right`, `jump`, `dash`.
- D-16: Remapeamentos persistidos em `user://controls.cfg` via ConfigFile API. Separado do save de progresso.
- D-17: Gamepad (DualSense/Xbox) funcional sem configuração extra; prompts genéricos por enquanto.
- D-18: UI de remapeamento como tela dentro do menu de opções. Padrão: WASD/Setas + Space + Shift.

### Claude's Discretion
- Arquitetura exata do SaveManager (padrão Singleton vs. estático)
- Estrutura do dicionário de save (nomes de chaves, versão do schema)
- Posicionamento visual da UI de remapeamento no menu de opções
- Sistema de detecção de conflito de teclas no remapeamento
- Ordem exata de instalação do Dialogic 2 e compatibilidade de versão

### Deferred Ideas (OUT OF SCOPE)
- Prompts de botão por marca (DualSense vs Xbox) — entra no Polish (Phase 12)
- Múltiplos slots de save — fora de escopo v1
- Voice acting — fora de escopo v1
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| SAVE-01 | Save automático ao completar cada fase e ao chegar em checkpoints | FileAccess.store_var() + autoload SaveManager; checkpoint trigger pattern verified |
| SAVE-02 | Progresso de mundos, poderes desbloqueados e cutscenes vistas são persistidos | Dict serialization via store_var; schema design in Discretion section |
| SAVE-03 | Menu de continue / new game na tela inicial | FileAccess.file_exists() check; new Control scene for main menu |
| NARR-01 | Sistema de diálogo com caixas de texto, retratos de personagem e branching (Dialogic 2) | Dialogic 2 Alpha 19 — compatible with Godot 4.4; Dialogic.start() API verified |
| NARR-02 | Todos os diálogos e cutscenes são puláveis com seen_cutscenes salvo | Dialogic.Inputs.auto_skip; seen_cutscenes tracked in save dict |
| ACCESS-02 | Teclas reconfiguráveis | InputMap.action_erase_events / action_add_event; ConfigFile persistence verified |
| ACCESS-03 | Suporte a gamepad (controle) além do teclado | InputEventJoypadButton / InputEventJoypadMotion added to existing actions |
| NPC-04 | Sprite da protagonista Natália baseado em foto real | Pillow 12.2.0 installed; photos/Natalia/ JPGs load successfully; pipeline verified |
</phase_requirements>

---

## Summary

Phase 2 implementa quatro sistemas de suporte completamente independentes entre si que serão usados pelos 8 mundos restantes. O save system usa a API nativa `FileAccess.store_var()` do Godot 4, que serializa dicionários GDScript como binário — zero dependências externas, adequado para dados estruturados simples. Dialogic 2 (Alpha 19, compatível com Godot 4.4) fornece o sistema de diálogos; não há uma versão "stable" ainda, mas Alpha 19 foi lançada em 2026-01-12 e exige explicitamente Godot 4.4+. O remapeamento de controles usa a `InputMap` singleton nativa do Godot combinada com `ConfigFile` para persistência — um padrão bem estabelecido na comunidade. A geração de sprites usa Python 3.14 + Pillow 12.2.0 (instalado e verificado localmente) para processar as fotos reais de Natália e Renato.

O sistema de transição de cenas deve usar a técnica de `CanvasLayer` + `ColorRect` + `Tween` como autoload global — isso evita a "tela preta travada" que ocorre quando `change_scene_to_file()` é chamado diretamente sem preparar visualmente o jogador. Para fases pequenas (tamanho do projeto), `change_scene_to_file()` simples com fade funciona bem; background loading via `ResourceLoader.load_threaded_request()` é overkill para este escopo.

**Primary recommendation:** Implementar os 5 autoloads em sequência (SaveManager, SceneTransition, ControlsManager) antes de instalar Dialogic 2, pois o plugin registra seus próprios autoloads que podem conflitar se o projeto.godot estiver inconsistente.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Save/Load progress | Autoload (SaveManager) | Checkpoint nodes (trigger) | Centraliza I/O; checkpoints emitem sinal, SaveManager persiste |
| Scene transitions | Autoload (SceneTransition) | CanvasLayer overlay | Deve sobreviver à troca de cena — só autoloads persistem entre scenes |
| Dialogue display | Dialogic 2 autoload | Phase scenes (trigger) | Dialogic gerencia a UI; cenas de fase chamam `Dialogic.start()` |
| Input remapping | Autoload (ControlsManager) | Options menu UI | InputMap é singleton global; ControlsManager persiste e carrega na startup |
| Sprite generation | Offline script (Python) | res://assets/sprites/ | Geração é pré-compilação, não runtime; output importado como SpriteFrames |
| Gamepad detection | Godot built-in (Input singleton) | ControlsManager | Input.get_connected_joypads() nativo; ControlsManager adiciona eventos ao InputMap |
| Main menu | scenes/main_menu/ Control node | SaveManager (query) | UI pura; consulta SaveManager.save_exists() para habilitar "Continue" |

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Godot 4 FileAccess | built-in (4.4.1) | Save/load game state binário | API nativa, zero deps, suporta `store_var` com dicts complexos |
| Godot 4 ConfigFile | built-in (4.4.1) | Persistir remapeamentos de controle | Formato INI legível, separado do save, reset independente |
| Godot 4 InputMap | built-in (4.4.1) | Remapear ações em runtime | Singleton global, `action_erase_events` + `action_add_event` |
| Godot 4 SceneTree | built-in (4.4.1) | Transição de cenas | `change_scene_to_file()` + sinal `scene_changed` para await |
| Dialogic 2 | Alpha 19 (2026-01-12) | Sistema de diálogos narrativos | Único plugin maduro para diálogos Godot 4; compatível com 4.4+ |
| Python 3.14 + Pillow 12.2.0 | instalado localmente | Gerar sprite sheets pixel art a partir de fotos | Verificado: fotos carregam, pipeline de quantização funcional |

[VERIFIED: godot --version → 4.4.1.stable; Pillow 12.2.0 instalado e testado com fotos do projeto]
[VERIFIED: Dialogic GitHub API → latest release 2.0-alpha-19, publicado 2026-01-12]

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Godot 4 Tween | built-in | Animar fade de transição de cena | Preferível a AnimationPlayer para efeitos simples de UI |
| Godot 4 CanvasLayer | built-in | Overlay de transição acima de todas as cenas | Layer > 100 garante que fica sobre tudo inclusive Dialogic |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| FileAccess.store_var() | JSON via store_string() | JSON é legível mas exige parsing manual de tipos. store_var() preserva tipos Godot nativos (Vector2, Array, etc.) sem conversão |
| ConfigFile | Adicionar controles ao save.dat | Separação intencional (D-16): resetar controles não apaga progresso |
| Dialogic 2 Alpha 19 | Custom dialogue system | Custom exige muito mais código; Dialogic fornece editor visual, personagens, portraits, branching out of the box |
| change_scene_to_file + Tween | ResourceLoader.load_threaded_request | Background loading é overkill para fases < 5MB; Tween fade esconde o stall adequadamente |

**Installation:**
```bash
# Pillow (geração de sprites — offline)
pip3 install Pillow --break-system-packages

# Dialogic 2: baixar ZIP de https://github.com/dialogic-godot/dialogic/releases/tag/2.0-alpha-19
# Extrair addons/ para res://addons/dialogic
# Project Settings > Plugins > Dialogic > Enable
```

---

## Architecture Patterns

### System Architecture Diagram

```
[Player collision com Checkpoint] ──signal──► [SaveManager.save()]
                                                     │
                                              [FileAccess.store_var()]
                                              [user://save.dat]

[Início do jogo] ──► [SaveManager._ready()] ──► [load() se save.dat existe]
                                                     │
                                         [saves in-memory: current_save dict]
                                                     │
                         ┌───────────────────────────┼─────────────────────────┐
                         ▼                           ▼                         ▼
               [Main Menu: Continue button]  [Player: poderes]    [Dialogic: skip seen]

[Player Input] ──► [ControlsManager._ready()] ──► [load user://controls.cfg]
                                                          │
                                           [InputMap.action_erase_events()]
                                           [InputMap.action_add_event()]

[Fase chama Dialogic.start("dialogo_x")] ──► [Dialogic 2 UI overlay]
                                                     │
                              [seen_cutscenes.has("dialogo_x")?]
                              │ YES → auto_skip enabled
                              │ NO  → normal flow
                              ▼
                     [Dialogic.Inputs.auto_skip.enabled = true/false]
                     [SaveManager.mark_cutscene_seen("dialogo_x")]

[SceneTransition.go_to("res://scenes/world1.tscn")] ──►
    [Tween: alpha 0→1 (fade to black)] ──►
    [get_tree().change_scene_to_file()] ──►
    [Tween: alpha 1→0 (fade in)]
```

### Recommended Project Structure
```
autoloads/
├── save_manager.gd         # SaveManager — SAVE-01, SAVE-02, SAVE-03
├── scene_transition.gd     # SceneTransition — transições sem freeze
└── controls_manager.gd     # ControlsManager — ACCESS-02, ACCESS-03
addons/
└── dialogic/               # Dialogic 2 Alpha 19 (plugin)
scenes/
├── main_menu/
│   ├── main_menu.tscn      # Tela inicial: Continue + New Game (SAVE-03)
│   └── main_menu.gd
├── options_menu/
│   ├── options_menu.tscn   # Remapeamento de controles (ACCESS-02)
│   └── options_menu.gd
├── player/
│   ├── player.tscn         # Existente — recebe SpriteFrames da Natália
│   └── player.gd           # Existente — sem modificações nesta fase
└── test_dialogue/
    └── test_dialogue.tscn  # Cena de validação do diálogo Dialogic (D-14)
assets/
└── sprites/
    ├── natalia_spritesheet.png     # 192x32 (6 frames × 32x32) — gerado por Python
    └── portraits/
        ├── natalia_portrait.png    # 64x80 — gerado por Python
        └── renato_portrait.png     # 64x80 — gerado por Python
scripts/
└── generate_sprites.py     # Script offline Python/Pillow
dialogic/
├── characters/
│   ├── Natalia.dch         # Personagem Dialogic
│   └── Renato.dch          # Personagem Dialogic
└── timelines/
    └── test_dialogue.dtl   # Timeline de teste (D-14)
```

### Pattern 1: SaveManager Autoload
**What:** Singleton Node que carrega dados ao iniciar e expõe métodos de save/load
**When to use:** Toda vez que algum sistema precisa ler ou gravar progresso do jogador

```gdscript
# Source: Context7 /godotengine/godot-docs — FileAccess.store_var
extends Node

const SAVE_PATH := "user://save.dat"
const SCHEMA_VERSION := 1

var current_save: Dictionary = {}
var _save_exists: bool = false

func _ready() -> void:
    load_game()

func save_exists() -> bool:
    return FileAccess.file_exists(SAVE_PATH)

func load_game() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        current_save = _default_save()
        return
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file:
        var data = file.get_var(true)  # allow_objects=true para Array/Dict aninhados
        if data is Dictionary and data.get("version", 0) == SCHEMA_VERSION:
            current_save = data
        else:
            current_save = _default_save()  # Backward compat: schema mudou
    _save_exists = true

func save_game() -> void:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_var(current_save, true)

func new_game() -> void:
    current_save = _default_save()
    save_game()

func set_checkpoint(checkpoint_id: String) -> void:
    current_save["checkpoint_id"] = checkpoint_id
    save_game()

func mark_cutscene_seen(cutscene_id: String) -> void:
    current_save["seen_cutscenes"][cutscene_id] = true
    save_game()

func has_seen_cutscene(cutscene_id: String) -> bool:
    return current_save["seen_cutscenes"].get(cutscene_id, false)

func _default_save() -> Dictionary:
    return {
        "version": SCHEMA_VERSION,
        "checkpoint_id": "",
        "worlds_completed": [],
        "powers_unlocked": [],
        "seen_cutscenes": {},
    }
```

**Autoload registration in project.godot:**
```ini
[autoload]
SaveManager="*res://autoloads/save_manager.gd"
```

### Pattern 2: SceneTransition Autoload
**What:** CanvasLayer persistente com ColorRect de fade; sobrevive à troca de cena
**When to use:** Toda transição de cena no jogo

```gdscript
# Source: padrão verificado em múltiplas fontes (shaggydev.com, GDQuest)
extends CanvasLayer

@onready var overlay: ColorRect = $Overlay

func _ready() -> void:
    layer = 100  # acima de tudo, inclusive Dialogic (que usa layer padrão)
    overlay.color = Color(0, 0, 0, 0)  # invisível no início

func go_to(scene_path: String) -> void:
    # Fade to black
    var t := create_tween()
    t.tween_property(overlay, "color:a", 1.0, 0.3)
    await t.finished
    # Troca de cena (stall acontece aqui, mas coberto pelo preto)
    get_tree().change_scene_to_file(scene_path)
    await get_tree().scene_changed
    # Fade in
    t = create_tween()
    t.tween_property(overlay, "color:a", 0.0, 0.3)
    await t.finished
```

**Uso nas fases:**
```gdscript
SceneTransition.go_to("res://scenes/world1/fase1.tscn")
```

### Pattern 3: Dialogic 2 — Integração
**What:** Plugin instalado + personagens .dch + timelines .dtl + chamada GDScript
**When to use:** Qualquer cena que dispara cutscene ou diálogo

```gdscript
# Source: docs.dialogic.pro/getting-started.html
func start_cutscene(timeline_name: String) -> void:
    # Evitar iniciar se já está rodando
    if Dialogic.current_timeline != null:
        return

    # Verificar se já foi vista para habilitar skip automático
    if SaveManager.has_seen_cutscene(timeline_name):
        Dialogic.Inputs.auto_skip.enabled = true
        Dialogic.Inputs.auto_skip.time_per_event = 0.05  # skip rápido

    Dialogic.start(timeline_name)
    # Aguardar fim da timeline (sinal do Dialogic)
    await Dialogic.timeline_ended
    SaveManager.mark_cutscene_seen(timeline_name)
    Dialogic.Inputs.auto_skip.enabled = false
```

**Botão "Pular" explícito (visível para cutscenes vistas):**
```gdscript
# Source: docs.dialogic.pro/auto-skip.html
func _on_skip_button_pressed() -> void:
    Dialogic.Inputs.auto_skip.enabled = not Dialogic.Inputs.auto_skip.enabled
```

### Pattern 4: ControlsManager — Remapeamento + Gamepad
**What:** Carrega controles do ConfigFile no boot; expõe método de remapeamento
**When to use:** Options menu e qualquer ponto que precise reler o mapeamento

```gdscript
# Source: Context7 /godotengine/godot-docs — ConfigFile + InputMap
extends Node

const CONTROLS_PATH := "user://controls.cfg"
const ACTIONS := ["walk_left", "walk_right", "jump", "dash"]

func _ready() -> void:
    load_controls()

func load_controls() -> void:
    var config := ConfigFile.new()
    if config.load(CONTROLS_PATH) != OK:
        return  # Sem arquivo: usa defaults do project.godot
    for action in ACTIONS:
        if config.has_section(action):
            InputMap.action_erase_events(action)
            for event_data in config.get_value(action, "events", []):
                var event := _deserialize_event(event_data)
                if event:
                    InputMap.action_add_event(action, event)

func save_controls() -> void:
    var config := ConfigFile.new()
    for action in ACTIONS:
        var events := InputMap.action_get_events(action)
        var serialized := []
        for event in events:
            var s := _serialize_event(event)
            if s:
                serialized.append(s)
        config.set_value(action, "events", serialized)
    config.save(CONTROLS_PATH)

func remap_action(action: String, new_event: InputEvent) -> void:
    # Detectar conflito (mesma tecla em outra ação)
    for other_action in ACTIONS:
        if other_action != action:
            InputMap.action_erase_event(other_action, new_event)
    InputMap.action_erase_events(action)
    InputMap.action_add_event(action, new_event)
    save_controls()

func _serialize_event(event: InputEvent) -> Dictionary:
    if event is InputEventKey:
        return {"type": "key", "physical_keycode": event.physical_keycode}
    elif event is InputEventJoypadButton:
        return {"type": "joypad_button", "button_index": event.button_index}
    elif event is InputEventJoypadMotion:
        return {"type": "joypad_motion", "axis": event.axis, "axis_value": event.axis_value}
    return {}

func _deserialize_event(data: Dictionary) -> InputEvent:
    match data.get("type", ""):
        "key":
            var e := InputEventKey.new()
            e.physical_keycode = data["physical_keycode"]
            return e
        "joypad_button":
            var e := InputEventJoypadButton.new()
            e.button_index = data["button_index"]
            return e
        "joypad_motion":
            var e := InputEventJoypadMotion.new()
            e.axis = data["axis"]
            e.axis_value = data["axis_value"]
            return e
    return null
```

### Pattern 5: Geração de Sprites (Python/Pillow)
**What:** Script offline que processa fotos reais e gera PNG pixel art
**When to use:** Executar uma vez; resultado importado no Godot como SpriteFrames

```python
# Source: Pillow 12.2.0 docs; pipeline testado localmente com fotos do projeto
from PIL import Image
import os

PHOTOS_DIR = "photos"
OUTPUT_DIR = "assets/sprites"

def photo_to_pixel_art(img_path: str, target_size: tuple, palette_colors: int = 16) -> Image.Image:
    """Redimensiona foto para pixel art com paleta limitada."""
    img = Image.open(img_path).convert("RGB")
    # Downscale com LANCZOS (melhor qualidade)
    small = img.resize(target_size, Image.LANCZOS)
    # Quantizar para paleta limitada (coerência pixel art)
    quantized = small.quantize(colors=palette_colors, method=Image.Quantize.MEDIANCUT)
    return quantized.convert("RGB")

def generate_natalia_spritesheet(photo_path: str) -> None:
    """Gera sprite sheet 192x32 (6 frames × 32x32) a partir de foto real."""
    img = Image.open(photo_path).convert("RGB")
    w, h = img.size
    # Crop corpo inteiro: centralizado, proporção slim
    crop_h = int(h * 0.85)
    crop_w = int(crop_h * 0.5)
    left = (w - crop_w) // 2
    body = img.crop((left, int(h * 0.02), left + crop_w, int(h * 0.02) + crop_h))
    sprite = body.resize((32, 32), Image.LANCZOS)
    quantized = sprite.quantize(colors=16, method=Image.Quantize.MEDIANCUT).convert("RGB")

    # 6 frames: idle, run, jump, fall, hurt, death
    # Nesta fase: todas as animações usam o mesmo frame base (placeholder funcional)
    # Animações reais frame-a-frame: Phase 3+
    frames = ["idle", "run", "jump", "fall", "hurt", "death"]
    sheet = Image.new("RGBA", (32 * len(frames), 32), (0, 0, 0, 0))
    for i, _ in enumerate(frames):
        frame = quantized.copy().convert("RGBA")
        sheet.paste(frame, (i * 32, 0))
    sheet.save(f"{OUTPUT_DIR}/natalia_spritesheet.png")

def generate_portrait(photo_path: str, output_name: str) -> None:
    """Gera portrait 64x80 (busto JRPG) a partir de foto real."""
    img = Image.open(photo_path).convert("RGB")
    w, h = img.size
    crop_h = int(h * 0.55)  # cabeça + ombros
    crop_w = min(w, int(crop_h * 0.8))
    left = (w - crop_w) // 2
    bust = img.crop((left, 0, left + crop_w, crop_h))
    portrait = bust.resize((64, 80), Image.LANCZOS)
    quantized = portrait.quantize(colors=16, method=Image.Quantize.MEDIANCUT).convert("RGBA")
    quantized.save(f"{OUTPUT_DIR}/portraits/{output_name}.png")
```

**Chamada:**
```bash
cd /Users/renatojaf/jogo-natalia
python3 scripts/generate_sprites.py
```

### Anti-Patterns to Avoid

- **Salvar X/Y do player no save.dat:** Posições ficam inválidas se level design mudar. Respawn no início do checkpoint é robusto (D-02).
- **Usar `store_var()` sem verificar versão do schema:** Se o dicionário mudar entre versões, o load corrompe. Sempre verificar `data.get("version", 0)`.
- **Chamar `change_scene_to_file()` diretamente sem fade:** O engine stalla visivelmente. Sempre usar SceneTransition autoload.
- **Registrar autoloads manualmente no project.godot enquanto Dialogic 2 não está instalado:** Dialogic 2 registra seus próprios autoloads ao ser habilitado. Instalar primeiro e depois adicionar os custom autoloads evita conflitos de ordem.
- **`InputMap.action_erase_events()` sem salvar imediatamente:** Se o jogo crasha após remap mas antes de save, os controles ficam inconsistentes com o arquivo. Salvar imediatamente após cada mudança (D-16).
- **Timer de dash sem `process_always=true`:** Padrão estabelecido na Phase 1 — `create_timer(duration, true)`. ControlsManager não precisa, mas qualquer novo timer que precise funcionar durante hit-stop segue esse padrão.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Dialogue system | Custom caixas de texto em CanvasLayer | Dialogic 2 | Dialogic tem portraits, branching, character events, typewriter, skip — centenas de horas de trabalho |
| Input serialization | Encoding manual de InputEvent para JSON | `_serialize_event()` dict + ConfigFile | InputEvent é opaco; não tem método `to_dict()` built-in, mas os campos necessários são acessíveis individualmente |
| Color quantization | Algoritmo de quantização manual | Pillow `Image.quantize(method=MEDIANCUT)` | Pillow implementa median-cut, k-means e octree; resultado pixel-perfeito em 1 linha |
| Scene loading screen | Custom progress bar com polling | Tween + fade sobre `change_scene_to_file()` | Para fases pequenas, o stall é < 200ms; fade de 300ms esconde completamente |

**Key insight:** O Dialogic 2 em alpha não tem versão "stable", mas Alpha 19 é a versão mais madura disponível e foi explicitamente atualizado para Godot 4.4. A alternativa (custom dialogue) exigiria semanas de trabalho duplicando features que o Dialogic já fornece.

---

## Common Pitfalls

### Pitfall 1: Dialogic 2 autoload conflita com outros autoloads
**What goes wrong:** Se SaveManager, SceneTransition e ControlsManager forem registrados antes de instalar Dialogic, a ordem de autoloads no project.godot pode fazer Dialogic tentar acessar nós não inicializados.
**Why it happens:** Dialogic registra `DialogicGameHandler` como autoload durante `_enable_plugin()`. Se outros autoloads dependem de Dialogic em `_ready()`, a ordem importa.
**How to avoid:** Instalar e habilitar Dialogic 2 PRIMEIRO. Depois registrar os autoloads custom. Verificar ordem em Project Settings > AutoLoad.
**Warning signs:** Erro `Invalid get index 'current_timeline' on base 'null'` na startup.

### Pitfall 2: `get_var()` sem `allow_objects=true` falha com dicionários aninhados
**What goes wrong:** `FileAccess.get_var()` sem argumento retorna `null` para dicts complexos com Arrays aninhados.
**Why it happens:** Por padrão, `get_var(false)` bloqueia Objects por segurança. Arrays e Dicts aninhados precisam de `get_var(true)`.
**How to avoid:** Sempre usar `file.get_var(true)` no load. O risco de segurança é mínimo para dados offline.
**Warning signs:** `current_save` retorna `null` após load mesmo com arquivo existente.

### Pitfall 3: SceneTransition CanvasLayer desaparece na troca de cena
**What goes wrong:** O overlay de fade some no meio da transição porque o nó é filho da cena atual e é destruído com ela.
**Why it happens:** `change_scene_to_file()` destrói todos os nós da cena atual, incluindo o CanvasLayer se ele não for autoload.
**How to avoid:** SceneTransition DEVE ser um autoload (`extends CanvasLayer`), não um nó filho de scene. Autoloads persistem entre scene changes.
**Warning signs:** Tela preta piscando ou flash entre cenas.

### Pitfall 4: Dialogic Alpha 19 — `Dialogic.start()` aceita nome OU caminho
**What goes wrong:** `Dialogic.start("test_dialogue")` funciona se o arquivo se chama `test_dialogue.dtl`; mas `Dialogic.start("res://dialogic/timelines/test_dialogue.dtl")` também funciona.
**Why it happens:** Dialogic aceita ambos os formatos.
**How to avoid:** Usar sempre o nome sem extensão (ex: `"test_dialogue"`) para consistência. Evitar caminhos hardcoded que quebram se a estrutura mudar.
**Warning signs:** `Timeline 'X' could not be found` no console do Godot.

### Pitfall 5: InputMap changes não persistem entre sessões sem ConfigFile
**What goes wrong:** `InputMap.action_add_event()` só afeta a sessão atual. Fechar e abrir o jogo restaura os defaults do project.godot.
**Why it happens:** InputMap em runtime não grava em project.godot (read-only em produção).
**How to avoid:** ControlsManager DEVE chamar `save_controls()` após cada `remap_action()` e `load_controls()` em `_ready()`.
**Warning signs:** Controles voltam ao default após restart.

### Pitfall 6: Geração de sprite sheet com paleta inconsistente entre frames
**What goes wrong:** Se cada frame é quantizado independentemente com Pillow, paletas diferentes emergem — pixels da mesma cor ficam com RGB ligeiramente diferentes.
**Why it happens:** `quantize()` sem paleta forçada gera paleta ótima por imagem.
**How to avoid:** Quantizar todos os frames juntos em uma imagem combinada, extrair paleta, e re-aplicar a mesma paleta a cada frame individual. Ou: usar o mesmo frame base para todos os 6 slots (placeholder funcional desta fase).
**Warning signs:** Flickering de cores entre frames de animação.

---

## Code Examples

### Registrar autoloads em project.godot
```ini
# Source: Context7 /godotengine/godot-docs — singletons_autoload.md
[autoload]
SaveManager="*res://autoloads/save_manager.gd"
SceneTransition="*res://autoloads/scene_transition.gd"
ControlsManager="*res://autoloads/controls_manager.gd"
# Dialogic registra DialogicGameHandler automaticamente ao habilitar o plugin
```

O prefixo `*` marca o autoload como singleton com nome global.

### Verificar save existente (Main Menu)
```gdscript
# Source: Context7 /godotengine/godot-docs — FileAccess
func _ready() -> void:
    $ContinueButton.disabled = not SaveManager.save_exists()
```

### Adicionar eventos de gamepad a uma ação existente
```gdscript
# Source: Context7 /godotengine/godot-docs — InputEventJoypadButton
func _add_gamepad_defaults() -> void:
    # Pulo: botão A (JoyButton 0) — padrão Xbox/DualSense South
    var joy_jump := InputEventJoypadButton.new()
    joy_jump.button_index = JoyButton.A
    InputMap.action_add_event("jump", joy_jump)

    # Dash: botão B (JoyButton 1) — padrão Xbox East / DualSense Circle
    var joy_dash := InputEventJoypadButton.new()
    joy_dash.button_index = JoyButton.B
    InputMap.action_add_event("dash", joy_dash)

    # Movimento: Left Stick — JoyAxis LEFT_X
    var joy_left := InputEventJoypadMotion.new()
    joy_left.axis = JoyAxis.LEFT_X
    joy_left.axis_value = -1.0
    InputMap.action_add_event("walk_left", joy_left)

    var joy_right := InputEventJoypadMotion.new()
    joy_right.axis = JoyAxis.LEFT_X
    joy_right.axis_value = 1.0
    InputMap.action_add_event("walk_right", joy_right)
```

### Detectar evento de remapeamento (Options Menu UI)
```gdscript
# Source: padrão verificado — InputMap + _input()
var _waiting_for_input: String = ""  # ação aguardando remap

func start_remap(action_name: String) -> void:
    _waiting_for_input = action_name
    $RemapLabel.text = "Pressione uma tecla..."

func _input(event: InputEvent) -> void:
    if _waiting_for_input.is_empty():
        return
    # Aceitar teclado e gamepad; ignorar mouse por enquanto
    if event is InputEventKey or event is InputEventJoypadButton:
        get_viewport().set_input_as_handled()
        ControlsManager.remap_action(_waiting_for_input, event)
        _waiting_for_input = ""
        _refresh_ui()
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `yield()` para aguardar sinais | `await` | Godot 4.0 | Todo código de transição e dialogue usa `await` |
| `get_tree().change_scene()` | `change_scene_to_file()` / `change_scene_to_packed()` | Godot 4.0 | API renomeada; sintaxe nova obrigatória |
| `TileMap` único | `TileMapLayer` (nós separados por layer) | Godot 4.4 | Fases futuras usam TileMapLayer, não TileMap |
| Dialogic 1.x (Godot 3) | Dialogic 2 (Godot 4, alpha) | 2023 | API completamente diferente; incompatível |
| GPUParticles2D | CPUParticles2D | Projeto (Phase 1) | gl_compatibility renderer não suporta GPU particles na web |

**Deprecated/outdated:**
- `Dialogic 1.x`: incompatível com Godot 4, não usar.
- `yield()`: removido no Godot 4. Substituído por `await`.
- `InputMap.load_from_globals()`: não existe no Godot 4. Usar `action_erase_events()` + `action_add_event()`.

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Dialogic 2 Alpha 19 funciona sem bugs críticos em Godot 4.4.1 | Dialogic 2 | Se houver bug blocking, pode ser necessário downgrade ou workaround manual |
| A2 | O stall de `change_scene_to_file()` para fases pequenas é < 200ms (coberto pelo fade de 300ms) | SceneTransition | Se fases forem grandes, fade pode não ser suficiente; adicionar `load_threaded_request` |
| A3 | `InputEventJoypadButton.A` = botão "pular" natural para DualSense/Xbox sem configuração extra | Gamepad defaults | Pode precisar de ajuste dependendo do mapeamento SDL do Godot para cada controlador |

---

## Open Questions

1. **Ordem de instalação de Dialogic 2 vs. autoloads custom**
   - What we know: Dialogic registra `DialogicGameHandler` automaticamente ao habilitar
   - What's unclear: Se instalar Dialogic depois de adicionar autoloads custom causa conflito de ordem
   - Recommendation: Instalar Dialogic PRIMEIRO; verificar ordem em Project Settings > AutoLoad após

2. **Animações distintas no sprite sheet da Natália (Phase 2 vs futuras)**
   - What we know: D-07 pede 6 animações; D-08 diz que Claude gera programaticamente
   - What's unclear: A Phase 2 entrega frames únicos por animação (placeholder funcional) ou frames completos animados?
   - Recommendation: Entregar 1 frame por animação (6 frames total = sprite sheet 192x32) como placeholder funcional. O success criterion 5 diz "asset de referência no projeto" — não exige animação frame-a-frame

3. **Skip de cutscene: botão "Pular" visível desde o início ou só para cutscenes já vistas?**
   - What we know: D-13 diz "cutscenes não-vistas ainda podem ser puladas mas sem botão proeminente"
   - What's unclear: O botão fica oculto (`visible=false`) ou apenas em posição secundária?
   - Recommendation: `visible=false` por padrão; `visible=true` se `seen_cutscenes.has(timeline_name)`

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Godot 4 | Todo o projeto | ✓ | 4.4.1.stable | — |
| Python 3 | Geração de sprites | ✓ | 3.14.5 | — |
| Pillow | Geração de sprites | ✓ | 12.2.0 | — |
| pip3 | Instalar Pillow | ✓ | 26.1.1 | homebrew |
| photos/Natalia/*.jpg | NPC-04 sprite | ✓ | 2 JPGs (3072x4096, 2304x4096) | — |
| photos/Renato/*.jpg | Portrait Renato | ✓ | 2 JPGs (1200x1600, 2304x4096) | — |
| Dialogic 2 Alpha 19 | NARR-01, NARR-02 | Requer download | 2.0-alpha-19 | Instalação manual via ZIP |
| Git LFS | Assets binários | ✓ | Configurado na Phase 0 | — |

**Missing dependencies with no fallback:**
- Nenhuma dependência bloqueante identificada.

**Missing dependencies with fallback:**
- Dialogic 2: não instalado no projeto ainda. Planner deve incluir tarefa de download + enable como Wave 1 pré-requisito.

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | GDScript built-in (sem GUT — projeto usa test scenes manuais) |
| Config file | none — test scenes em `scenes/test_*` |
| Quick run command | `godot --headless --path . -s scenes/test_dialogue/test_dialogue.tscn` |
| Full suite command | Human verify em Godot editor (checkpoints físicos) |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SAVE-01 | Auto-save dispara ao tocar checkpoint | manual | abrir test_save.tscn, tocar checkpoint, fechar e reabrir | ❌ Wave 0 |
| SAVE-02 | Dados persistem: checkpoint_id, worlds, powers, cutscenes | manual | verificar save.dat após ciclo save/load | ❌ Wave 0 |
| SAVE-03 | Continue desabilitado sem save; New Game apaga save | manual | abrir main_menu.tscn; verificar estado dos botões | ❌ Wave 0 |
| NARR-01 | Dialogic exibe texto com retrato e avança com input | manual | abrir test_dialogue.tscn, pressionar Enter | ❌ Wave 0 |
| NARR-02 | Cutscene já vista tem botão Pular visível; nova não tem | manual | ver twice; verificar visibilidade do botão | ❌ Wave 0 |
| ACCESS-02 | Remapear Jump para outra tecla; pulo responde à nova tecla | manual | options_menu.tscn → remap → test_movement.tscn | ❌ Wave 0 |
| ACCESS-03 | Gamepad controla jogadora sem config extra | manual | conectar DualSense/Xbox; abrir test_movement.tscn | — |
| NPC-04 | Sprite da Natália carregado em player.tscn como SpriteFrames | smoke | `godot --headless --path . --check-only` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** verificação visual no Godot editor
- **Per wave merge:** human verify completo em test scene
- **Phase gate:** success criteria 1-5 do ROADMAP.md aprovados em human verify

### Wave 0 Gaps
- [ ] `scenes/test_dialogue/test_dialogue.tscn` — cena de validação NARR-01/NARR-02
- [ ] `scenes/main_menu/main_menu.tscn` — cena principal com Continue/New Game (SAVE-03)
- [ ] `scenes/options_menu/options_menu.tscn` — UI de remapeamento (ACCESS-02)
- [ ] `scripts/generate_sprites.py` — script offline de geração de sprites (NPC-04)

---

## Security Domain

> `security_enforcement` não está explicitamente definido em config.json — tratando como habilitado.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | Jogo offline, sem auth |
| V3 Session Management | no | Sem sessões de usuário |
| V4 Access Control | no | Jogo single-player |
| V5 Input Validation | yes (parcial) | Schema version check no load_game(); `get_var(true)` com verificação de tipo |
| V6 Cryptography | no | Save binário não precisa de crypto (jogo de presente pessoal) |

### Known Threat Patterns for {stack}

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Save file corrompido | Tampering | Verificar `data is Dictionary` e `data.get("version")` antes de usar |
| Schema version mismatch | Tampering | Fallback para `_default_save()` se version != SCHEMA_VERSION |
| Conflito de tecla no remap | Denial of Service | `remap_action()` limpa a tecla das outras ações antes de adicionar |

---

## Sources

### Primary (HIGH confidence)
- Context7 `/godotengine/godot-docs` — FileAccess.store_var, ConfigFile, InputMap, SceneTree, CanvasLayer
- `godot --version` → 4.4.1.stable.official.49a5bc7b6 (verificado localmente)
- `GitHub API /repos/dialogic-godot/dialogic/releases/latest` → 2.0-alpha-19, 2026-01-12
- Pillow 12.2.0 docs — Image.quantize(), MEDIANCUT (instalado e testado com fotos do projeto)
- Fotos `/photos/Natalia/*.jpg` e `/photos/Renato/*.jpg` — carregadas com sucesso via Pillow

### Secondary (MEDIUM confidence)
- [Dialogic 2 Getting Started](https://docs.dialogic.pro/getting-started.html) — Dialogic.start() API, instalação
- [Dialogic 2 Auto-Skip](https://docs.dialogic.pro/auto-skip.html) — Dialogic.Inputs.auto_skip API
- [Dialogic 2 Characters & Portraits](https://docs.dialogic.pro/characters-and-portraits.html) — .dch files, portrait setup
- [GDQuest Scene Transitions](https://www.gdquest.com/tutorial/godot/2d/scene-transition-rect/) — padrão CanvasLayer + ColorRect

### Tertiary (LOW confidence)
- WebSearch sobre padrão de remapeamento com ConfigFile — confirmado por múltiplas fontes mas sem código completo verificado

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — FileAccess/ConfigFile/InputMap verificados via Context7; Pillow testado localmente; Dialogic versão confirmada via GitHub API
- Architecture: HIGH — padrões autoload e CanvasLayer transition verificados em docs oficiais
- Pitfalls: MEDIUM — pitfalls de schema versioning e SceneTransition autoload são padrões conhecidos; comportamento exato do Dialogic Alpha 19 tem grau de incerteza

**Research date:** 2026-06-04
**Valid until:** 2026-07-04 (30 dias para Dialogic Alpha; verificar release notes se Dialogic for atualizado antes do planejamento)
