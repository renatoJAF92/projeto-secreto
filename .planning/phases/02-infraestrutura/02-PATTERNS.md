# Phase 2: Infraestrutura - Pattern Map

**Mapped:** 2026-06-04
**Files analyzed:** 13 new/modified files
**Analogs found:** 9 / 13

---

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `autoloads/save_manager.gd` | service/singleton | file-I/O | `scenes/player/player.gd` (Node lifecycle + state) | partial — same `extends Node`, `_ready()`, GDScript conventions |
| `autoloads/scene_transition.gd` | service/singleton | request-response | `scenes/test_movement/test_movement.gd` (CanvasLayer + `@onready`) | role-match — both extend CanvasLayer |
| `autoloads/controls_manager.gd` | service/singleton | file-I/O | `scenes/player/player.gd` (InputMap actions read) | partial — player reads InputMap, ControlsManager writes it |
| `scenes/main_menu/main_menu.gd` | controller/UI | request-response | `scenes/test_movement/test_movement.gd` (scene script, node refs) | role-match — same scene script pattern |
| `scenes/main_menu/main_menu.tscn` | config/scene | request-response | `scenes/test_movement/test_movement.tscn` | role-match — same tscn structure with CanvasLayer UI overlay |
| `scenes/options_menu/options_menu.gd` | controller/UI | request-response | `scenes/test_movement/test_movement.gd` + `_input()` in `player.gd` | role-match — UI controller using `_input()` for key capture |
| `scenes/options_menu/options_menu.tscn` | config/scene | request-response | `scenes/test_movement/test_movement.tscn` | role-match — same tscn layout pattern |
| `scenes/test_dialogue/test_dialogue.tscn` | config/scene (test) | event-driven | `scenes/test_movement/test_movement.tscn` | exact — same test scene pattern |
| `scripts/generate_sprites.py` | utility/offline | batch/transform | `serve.py` | partial — same Python script conventions (shebang, imports, functions) |
| `addons/dialogic/` | config/plugin | event-driven | none — external plugin | no analog |
| `assets/sprites/natalia_spritesheet.png` | asset/binary | batch | `assets/sprites/player/natalia_placeholder.svg` | partial — same asset path convention |
| `assets/sprites/portraits/natalia_portrait.png` | asset/binary | batch | `assets/sprites/player/natalia_placeholder.svg` | partial — same asset path convention |
| `assets/sprites/portraits/renato_portrait.png` | asset/binary | batch | `assets/sprites/player/natalia_placeholder.svg` | partial — same asset path convention |
| `dialogic/characters/Natalia.dch` | config/data | event-driven | none — Dialogic data format | no analog |
| `dialogic/characters/Renato.dch` | config/data | event-driven | none — Dialogic data format | no analog |
| `dialogic/timelines/test_dialogue.dtl` | config/data | event-driven | none — Dialogic data format | no analog |

---

## Pattern Assignments

### `autoloads/save_manager.gd` (service/singleton, file-I/O)

**Analog:** `scenes/player/player.gd`

**GDScript file header pattern** (player.gd lines 1-25):
```gdscript
extends Node  # SaveManager extends Node (not CharacterBody2D)

# --- Constants at top ---
const SAVE_PATH := "user://save.dat"
const SCHEMA_VERSION := 1

# --- State vars typed with := ---
var current_save: Dictionary = {}
var _save_exists: bool = false
```

**`_ready()` lifecycle entry point** (player.gd lines 51):
```gdscript
func _ready() -> void:
    load_game()  # Load on startup — same pattern as player initializing state in _physics_process
```

**Signal connection pattern** (player.gd line 137):
```gdscript
# One-shot signal connection using lambda — use for async callbacks
get_tree().create_timer(dash_cooldown).timeout.connect(func(): _can_dash = true, CONNECT_ONE_SHOT)
```

**Typed return signatures** (player.gd lines 131-225):
```gdscript
# All functions have explicit return types
func _start_dash() -> void:
func take_damage(hit_from_position: Vector2) -> void:
func _update_animation() -> void:
# SaveManager follows same convention:
func save_exists() -> bool:
func load_game() -> void:
func save_game() -> void:
```

**`await` pattern for async operations** (player.gd line 217):
```gdscript
# Godot 4 await — used for coroutines and signal waits
await get_tree().create_timer(frames / 60.0, true).timeout
# SaveManager uses no await internally (synchronous FileAccess), but
# callers that need to wait for scene change use await
```

**Autoload registration** (`project.godot` lines 1-61 — no autoloads yet; pattern from RESEARCH.md):
```ini
[autoload]
SaveManager="*res://autoloads/save_manager.gd"
```
The `*` prefix makes the node a global singleton accessible by name from any script.

---

### `autoloads/scene_transition.gd` (service/singleton, request-response)

**Analog:** `scenes/test_movement/test_movement.gd`

**CanvasLayer extension pattern** (test_movement.gd lines 1-4):
```gdscript
extends CanvasLayer  # SceneTransition also extends CanvasLayer

@onready var player = $"../Player"    # @onready for child refs
@onready var state_label: Label = $StateLabel
# SceneTransition equivalent:
# @onready var overlay: ColorRect = $Overlay
```

**Tween pattern from player.gd** (player.gd lines 191-201):
```gdscript
# Tween creation and property animation — copy this pattern for fade
_squash_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
_squash_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.25)

# For SceneTransition, simpler tween without trans/ease:
# var t := create_tween()
# t.tween_property(overlay, "color:a", 1.0, 0.3)
# await t.finished
```

**`await` on Tween.finished** — same `await` pattern as player.gd line 217:
```gdscript
# Pattern: create tween → await its finished signal
await get_tree().create_timer(frames / 60.0, true).timeout
# SceneTransition equivalent:
# await t.finished
```

**CanvasLayer layer property** — set in `_ready()` like player.gd sets @export defaults:
```gdscript
func _ready() -> void:
    layer = 100  # Above Dialogic UI layer (Dialogic uses default ~0-10)
    overlay.color = Color(0, 0, 0, 0)  # Start transparent
```

---

### `autoloads/controls_manager.gd` (service/singleton, file-I/O)

**Analog:** `scenes/player/player.gd` (InputMap action reads) + `scenes/player/player.gd` (_input hook)

**Input action constant list** (player.gd lines 68, 76, 87, 93):
```gdscript
# player.gd reads these exact action names — ControlsManager manages the same set
Input.get_axis("walk_left", "walk_right")
Input.is_action_just_pressed("dash")
Input.is_action_just_pressed("jump")
Input.is_action_just_released("jump")
# ControlsManager constant:
# const ACTIONS := ["walk_left", "walk_right", "jump", "dash"]
```

**`_input()` pattern** (player.gd lines 126-128):
```gdscript
# _input captures events even during physics freeze
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("jump"):
        _jump_buffer_timer = jump_buffer_frames
# Options menu uses same _input() to capture remap key presses
```

**Typed function signatures** (same as all player.gd functions):
```gdscript
func load_controls() -> void:
func save_controls() -> void:
func remap_action(action: String, new_event: InputEvent) -> void:
func _serialize_event(event: InputEvent) -> Dictionary:
func _deserialize_event(data: Dictionary) -> InputEvent:
```

---

### `scenes/main_menu/main_menu.gd` (controller/UI, request-response)

**Analog:** `scenes/test_movement/test_movement.gd`

**Scene script with @onready refs** (test_movement.gd lines 1-4):
```gdscript
extends CanvasLayer  # main_menu.gd extends Control (not CanvasLayer)

@onready var player = $"../Player"
@onready var state_label: Label = $StateLabel
# main_menu.gd equivalent:
# extends Control
# @onready var continue_button: Button = $VBoxContainer/ContinueButton
# @onready var new_game_button: Button = $VBoxContainer/NewGameButton
```

**_ready() wiring buttons** — follow player.gd signal connection pattern (player.gd line 137):
```gdscript
# In main_menu._ready(), connect button signals:
func _ready() -> void:
    $ContinueButton.disabled = not SaveManager.save_exists()
    $ContinueButton.pressed.connect(_on_continue_pressed)
    $NewGameButton.pressed.connect(_on_new_game_pressed)
```

**Autoload access pattern** — from project.godot autoload config; accessed by global name:
```gdscript
# SaveManager is autoloaded; access directly by name (no $, no preload)
SaveManager.save_exists()
SaveManager.new_game()
SceneTransition.go_to("res://scenes/world1/fase1.tscn")
```

**_process pattern** (test_movement.gd lines 7-19):
```gdscript
# test_movement uses _process for UI update each frame
func _process(_delta: float) -> void:
    if player == null:
        return
    state_label.text = (...)
# main_menu does NOT need _process — event-driven via button signals only
```

---

### `scenes/main_menu/main_menu.tscn` (config/scene, request-response)

**Analog:** `scenes/test_movement/test_movement.tscn`

**Scene file header** (test_movement.tscn lines 1-6):
```
[gd_scene load_steps=7 format=3 uid="uid://c5tm3v87k2p1"]

[ext_resource type="Script" uid="..." path="res://scenes/test_movement/test_movement.gd" id="2_hud"]
```

**CanvasLayer UI overlay pattern** (test_movement.tscn lines 52-70):
```
[node name="HUD" type="CanvasLayer" parent="."]
script = ExtResource("2_hud")

[node name="StateLabel" type="Label" parent="HUD"]
offset_left = 4.0
offset_top = 4.0
offset_right = 200.0
offset_bottom = 180.0
```

**main_menu.tscn root node:** Use `Control` (full-screen UI scene) rather than `Node2D` or `CanvasLayer`. Script attached via `script = ExtResource("...")`.

**Node naming convention** (test_movement.tscn):
- PascalCase node names: `MainFloor`, `LedgePlatform`, `DamageTrigger`, `StateLabel`
- main_menu nodes: `MainMenu` (root), `VBoxContainer`, `ContinueButton`, `NewGameButton`

---

### `scenes/options_menu/options_menu.gd` (controller/UI, request-response)

**Analog:** `scenes/player/player.gd` (`_input()` capture) + `scenes/test_movement/test_movement.gd` (scene script)

**`_input()` for raw event capture** (player.gd lines 126-128):
```gdscript
# This exact pattern is reused in options_menu for remap listening
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("jump"):
        _jump_buffer_timer = jump_buffer_frames
# options_menu.gd equivalent:
func _input(event: InputEvent) -> void:
    if _waiting_for_input.is_empty():
        return
    if event is InputEventKey or event is InputEventJoypadButton:
        get_viewport().set_input_as_handled()
        ControlsManager.remap_action(_waiting_for_input, event)
        _waiting_for_input = ""
        _refresh_ui()
```

**State flag pattern** (player.gd lines 27-44 — `_is_dashing`, `_can_dash`, `_is_hurt`):
```gdscript
# Single-underscore prefix for private runtime state
var _is_dashing: bool = false
var _can_dash: bool = true
var _is_hurt: bool = false
# options_menu.gd equivalent:
var _waiting_for_input: String = ""  # empty = not waiting
```

**@onready refs** (test_movement.gd lines 3-4):
```gdscript
@onready var player = $"../Player"
@onready var state_label: Label = $StateLabel
# options_menu.gd will have refs to remap buttons and current-key labels
```

---

### `scenes/options_menu/options_menu.tscn` (config/scene, request-response)

**Analog:** `scenes/test_movement/test_movement.tscn`

Same tscn format pattern as main_menu.tscn. Root node: `Control`. Script attached via `script = ExtResource(...)`.

**ControlsLabel text pattern** (test_movement.tscn line 72):
```
text = "A/D correr  |  SPACE pular  |  SHIFT/K dash  |  caixa vermelha = dano"
```
Options menu will display current key bindings in Label nodes next to each remap Button.

---

### `scenes/test_dialogue/test_dialogue.tscn` (config/scene/test, event-driven)

**Analog:** `scenes/test_movement/test_movement.tscn`

**Test scene pattern** (test_movement.tscn lines 1-3, 16-18):
```
[gd_scene load_steps=7 format=3 uid="uid://c5tm3v87k2p1"]

[node name="TestMovement" type="Node2D"]

[node name="Player" parent="." instance=ExtResource("1_player")]
position = Vector2(80, 120)
```

`test_dialogue.tscn` follows the same structure:
- Root `Node2D` named `TestDialogue`
- A Button or Area2D to trigger `Dialogic.start("test_dialogue")`
- A script with `_ready()` that calls `Dialogic.start()` directly (no trigger needed for smoke test)
- No Player instance needed unless demonstrating in-gameplay dialogue

---

### `scripts/generate_sprites.py` (utility/offline, batch/transform)

**Analog:** `serve.py`

**Python script header** (serve.py lines 1-16):
```python
#!/usr/bin/env python3
"""
serve.py — Servidor HTTP local com CORS headers para testar web export do Godot.
...
Uso:
    cd export/web
    python3 /Users/renatojaf/jogo-natalia/serve.py
"""

from http.server import HTTPServer, SimpleHTTPRequestHandler, test
import sys
```

`generate_sprites.py` follows the same conventions:
- Shebang `#!/usr/bin/env python3`
- Module docstring with description and usage (`python3 scripts/generate_sprites.py`)
- Constants in UPPER_CASE at module level
- Functions with clear single responsibility
- `if __name__ == '__main__':` guard

**Python class pattern** (serve.py lines 21-24):
```python
class CORSRequestHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        SimpleHTTPRequestHandler.end_headers(self)
```
`generate_sprites.py` uses module-level functions (no classes needed) — simpler than serve.py.

---

## Shared Patterns

### GDScript Node Lifecycle
**Source:** `scenes/player/player.gd` lines 1-50
**Apply to:** All `.gd` autoloads and scene scripts

```gdscript
# 1. extends declaration at top — always first line
extends Node  # or CharacterBody2D, CanvasLayer, Control, etc.

# 2. @export_group for inspector-visible tuning vars (only for scene nodes, not autoloads)
@export_group("Movement")
@export var run_speed: float = 200.0

# 3. Private runtime state with single underscore prefix, typed
var _is_dashing: bool = false
var _knockback: Vector2 = Vector2.ZERO

# 4. @onready for child node refs — never in constructor
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# 5. _ready() for initialization
func _ready() -> void:
    load_game()  # or connect signals, set initial state

# 6. All functions have explicit return type annotation
func save_exists() -> bool:
    return FileAccess.file_exists(SAVE_PATH)

func load_game() -> void:
    pass  # void return — no 'return' needed at end
```

### Tween Creation
**Source:** `scenes/player/player.gd` lines 187-201, 205-210
**Apply to:** `autoloads/scene_transition.gd`, any future UI animation

```gdscript
# Kill existing tween before starting new one (prevents conflicts)
if _squash_tween and _squash_tween.is_valid():
    _squash_tween.kill()

# Create tween with chained configuration
_squash_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
_squash_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.25)

# For SceneTransition (no trans/ease needed for simple fade):
var t := create_tween()
t.tween_property(overlay, "color:a", 1.0, 0.3)
await t.finished
```

### `await` for async operations
**Source:** `scenes/player/player.gd` line 217
**Apply to:** `autoloads/scene_transition.gd`

```gdscript
# MUST use process_always=true for timers that must run during time_scale=0
await get_tree().create_timer(frames / 60.0, true).timeout

# scene_transition equivalent (scene changes don't need process_always):
await get_tree().scene_changed
```

### Signal Connection (one-shot lambda)
**Source:** `scenes/player/player.gd` line 137
**Apply to:** All autoloads and scene scripts that need one-shot callbacks

```gdscript
# CONNECT_ONE_SHOT disconnects automatically after first call
get_tree().create_timer(dash_cooldown).timeout.connect(func(): _can_dash = true, CONNECT_ONE_SHOT)
```

### @onready Pattern
**Source:** `scenes/test_movement/test_movement.gd` lines 3-4
**Apply to:** All scene scripts (`main_menu.gd`, `options_menu.gd`)

```gdscript
@onready var player = $"../Player"          # path with ".." for parent traversal
@onready var state_label: Label = $StateLabel  # typed @onready when type is known
```

### Particle System
**Source:** `scenes/player/player.gd` line 48, `scenes/player/player.tscn` lines 71-83
**Apply to:** Any future scene with particles

```gdscript
# ALWAYS use CPUParticles2D — never GPUParticles2D (gl_compatibility renderer)
@onready var dust_particles: CPUParticles2D = $DustParticles
dust_particles.restart()  # one-shot burst
```

### Scene File Format
**Source:** `scenes/test_movement/test_movement.tscn` lines 1-72
**Apply to:** All new `.tscn` files

```
[gd_scene load_steps=N format=3 uid="uid://XXXXXXXX"]

[ext_resource type="Script" uid="uid://XXXXXXXX" path="res://path/to/script.gd" id="1_name"]

[sub_resource type="RectangleShape2D" id="RectangleShape2D_name"]
size = Vector2(width, height)

[node name="RootNode" type="Node2D"]      # or Control, CanvasLayer, etc.

[node name="ChildNode" type="Label" parent="."]
offset_left = 4.0
offset_top = 4.0
text = "..."

[connection signal="pressed" from="Button" to="." method="_on_button_pressed"]
```

### InputMap Action Names
**Source:** `project.godot` lines 28-52, `scenes/player/player.gd` lines 68, 76, 87, 93
**Apply to:** `autoloads/controls_manager.gd`, `scenes/options_menu/options_menu.gd`

Canonical action names (exact strings used in both project.godot and player.gd):
- `"walk_left"` — A key + Left Arrow (physical_keycode 65, keycode 4194319)
- `"walk_right"` — D key + Right Arrow (physical_keycode 68, keycode 4194321)
- `"jump"` — Space + W + Up Arrow (keycode 32, physical_keycode 87, keycode 4194320)
- `"dash"` — Shift + K (keycode 4194325, physical_keycode 75)

### Python Script Conventions
**Source:** `serve.py` lines 1-30
**Apply to:** `scripts/generate_sprites.py`

```python
#!/usr/bin/env python3
"""Module docstring with description and Uso: block."""

from module import Class, function
import sys

CONSTANT_NAME = "value"  # UPPER_CASE module-level constants

def function_name(param: str) -> None:
    """Single-responsibility function with type hints."""
    pass

if __name__ == '__main__':
    # Entry point guard
    pass
```

---

## No Analog Found

Files with no close match in the codebase (planner should use RESEARCH.md patterns instead):

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `addons/dialogic/` | plugin | event-driven | External Dialogic 2 plugin — downloaded from GitHub releases, not hand-written |
| `dialogic/characters/Natalia.dch` | data/config | event-driven | Dialogic 2 character format — created via Dialogic editor UI, not GDScript |
| `dialogic/characters/Renato.dch` | data/config | event-driven | Dialogic 2 character format — created via Dialogic editor UI, not GDScript |
| `dialogic/timelines/test_dialogue.dtl` | data/config | event-driven | Dialogic 2 timeline format — visual scripting format, not GDScript |
| `assets/sprites/natalia_spritesheet.png` | asset/binary | batch | Generated by Python script — no GDScript analog; use RESEARCH.md Pattern 5 |
| `assets/sprites/portraits/natalia_portrait.png` | asset/binary | batch | Generated by Python script — no GDScript analog; use RESEARCH.md Pattern 5 |
| `assets/sprites/portraits/renato_portrait.png` | asset/binary | batch | Generated by Python script — no GDScript analog; use RESEARCH.md Pattern 5 |

---

## Key Observations for Planner

1. **The autoloads directory is empty** — `autoloads/` exists but has no `.gd` files yet. All three autoloads (`save_manager.gd`, `scene_transition.gd`, `controls_manager.gd`) are net-new with no in-project analog. Use RESEARCH.md Patterns 1-4 as the primary source.

2. **project.godot has no `[autoload]` section** — The planner must add this section when registering the three custom autoloads. Dialogic adds its own entries when the plugin is enabled.

3. **The only existing scene script** is `test_movement.gd` (extends CanvasLayer) and `damage_trigger.gd` (extends Area2D) — both are minimal. The main_menu and options_menu scripts will be the most complex GDScript in the project so far.

4. **SpriteFrames structure is established** in `player.tscn` lines 6-55 — the 6 animation names (`idle`, `run`, `jump`, `fall`, `hurt`, `death`) are already wired. The Python-generated `natalia_spritesheet.png` must produce a texture that replaces `natalia_placeholder.svg` in that SpriteFrames resource.

5. **No existing UI/Control scenes** — `main_menu.tscn` and `options_menu.tscn` will be the first `Control`-rooted scenes in the project. Use `test_movement.tscn` as format reference but switch root node type from `Node2D` to `Control`.

6. **Dialogic 2 must be installed BEFORE registering custom autoloads** — see RESEARCH.md Pitfall 1. Planner should make Dialogic installation Wave 0 / first task.

---

## Metadata

**Analog search scope:** `/Users/renatojaf/jogo-natalia/scenes/`, `/Users/renatojaf/jogo-natalia/autoloads/`, `/Users/renatojaf/jogo-natalia/scripts/`, `/Users/renatojaf/jogo-natalia/project.godot`
**Files scanned:** 8 files (player.gd, player.tscn, test_movement.gd, test_movement.tscn, damage_trigger.gd, main.tscn, project.godot, serve.py)
**Pattern extraction date:** 2026-06-04
