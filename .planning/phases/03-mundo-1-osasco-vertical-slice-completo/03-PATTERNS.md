# Phase 3: Mundo 1 — Osasco (vertical slice completo) - Pattern Map

**Mapped:** 2026-06-08
**Files analyzed:** 9 new/modified files
**Analogs found:** 9 / 9

---

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `autoloads/audio_manager.gd` | service/autoload | request-response | `autoloads/controls_manager.gd` + `autoloads/save_manager.gd` | role-match |
| `scenes/world1/malandro.gd` | entity | event-driven | `scenes/player/player.gd` | role-match |
| `scenes/world1/checkpoint.gd` | trigger/utility | event-driven | `scenes/test_save/test_save.gd` + `scenes/test_movement/damage_trigger.gd` | role-match |
| `scenes/world1/prova_item.gd` | trigger/utility | event-driven | `scenes/test_movement/damage_trigger.gd` | exact |
| `scenes/world1/boss_pai.gd` | controller | event-driven | `scenes/test_dialogue/test_dialogue.gd` | role-match |
| `scenes/world1/fase1_rua.gd` (and fase2/fase3) | scene controller | request-response | `scenes/test_movement/test_movement.gd` | role-match |
| `scenes/world1/mundo1_abertura.gd` | scene controller | request-response | `scenes/test_dialogue/test_dialogue.gd` | exact |
| `scenes/player/player.gd` (MODIFY) | entity | event-driven | self | exact |
| `autoloads/save_manager.gd` (MODIFY) | service/autoload | CRUD | self | exact |
| `scenes/main_menu/main_menu.gd` (MODIFY) | controller | request-response | self | exact |

---

## Pattern Assignments

### `autoloads/audio_manager.gd` (autoload, request-response)

**Analogs:** `autoloads/save_manager.gd` (extends Node, _ready pattern) and `autoloads/controls_manager.gd` (Dictionary-based registration)

**Imports/extends pattern** (`save_manager.gd` lines 1–6, `controls_manager.gd` lines 1–4):
```gdscript
extends Node

# constants at top, then typed vars
const SAVE_PATH := "user://save.dat"
const SCHEMA_VERSION := 1
var current_save: Dictionary = {}
```

**Autoload _ready pattern** (`save_manager.gd` lines 8–9):
```gdscript
func _ready() -> void:
    load_game()
```
AudioManager mirrors this: create child nodes in `_ready()`, not at class level.

**Dictionary registration pattern** (`controls_manager.gd` lines 32–42 — ConfigFile load loop):
The `_sfx_players: Dictionary` in AudioManager follows the same "keyed lookup" pattern used for ACTIONS in controls_manager. Register with a String key, retrieve by key — same as `config.get_value(action, ...)`.

**Core pattern to copy** — minimal AudioManager following `save_manager.gd` structure:
```gdscript
extends Node

var _sfx_players: Dictionary = {}
var _music_player: AudioStreamPlayer

func _ready() -> void:
    _music_player = AudioStreamPlayer.new()
    _music_player.bus = "Master"
    add_child(_music_player)

func register_sfx(key: String, stream: AudioStream) -> void:
    var player := AudioStreamPlayer.new()
    player.stream = stream
    player.bus = "Master"
    add_child(player)
    _sfx_players[key] = player

func play_sfx(key: String) -> void:
    if _sfx_players.has(key):
        _sfx_players[key].play()
    # else: silent fail — Wave 1 stub prints, WAV files added in final wave

func play_music(stream: AudioStream) -> void:
    _music_player.stream = stream
    _music_player.play()

func stop_music() -> void:
    _music_player.stop()
```

**Error handling pattern:** Silent fail on missing key — same philosophy as `controls_manager.gd` line 34 (`if config.load(...) != OK: return`). Never crash on missing asset.

---

### `scenes/world1/malandro.gd` (entity, event-driven)

**Analog:** `scenes/player/player.gd`

**Extends + exports pattern** (`player.gd` lines 1–25):
```gdscript
extends CharacterBody2D

@export_group("Movement")
@export var run_speed: float = 200.0
@export var jump_velocity: float = -380.0
# ...
```
Malandro copies this structure: `extends CharacterBody2D`, `@export_group`, typed `@export var`.

**Runtime state pattern** (`player.gd` lines 27–42):
```gdscript
var _coyote_timer: int = 0
var _is_dashing: bool = false
var _knockback: Vector2 = Vector2.ZERO
var _is_hurt: bool = false
var _is_dead: bool = false
```
Malandro declares: `var _is_dead: bool = false`, `var _direction: float = 1.0`, `var _origin: Vector2`.

**_physics_process pattern** (`player.gd` lines 51–122):
```gdscript
func _physics_process(delta: float) -> void:
    # 1. gravity always applied first
    velocity.y += (gravity_up if velocity.y < 0.0 else gravity_down) * delta
    # ...
    move_and_slide()
    # ...
    _update_animation()
```
Malandro follows the same order: guard dead check → gravity → horizontal patrol velocity → `move_and_slide()` → wall/edge check → `_update_animation()`.

**`set_deferred` collision disable pattern** (`player.gd` implicitly; RESEARCH.md Pitfall 3 confirmed):
```gdscript
# In die():
$CollisionShape2D.set_deferred("disabled", true)
# NEVER: $CollisionShape2D.disabled = true  (crashes in _physics_process)
```

**`create_timer` with `process_always=true` pattern** (`player.gd` lines 216–218):
```gdscript
func _start_hit_stop(frames: int = 3) -> void:
    Engine.time_scale = 0.0
    await get_tree().create_timer(frames / 60.0, true).timeout
    Engine.time_scale = 1.0
```
Malandro uses `get_tree().create_timer(0.3, true).timeout.connect(queue_free, CONNECT_ONE_SHOT)` for death delay — the `true` is mandatory per project convention.

**Animation state machine pattern** (`player.gd` lines 159–173):
```gdscript
func _update_animation() -> void:
    var new_anim: String
    if _is_hurt:
        new_anim = "hurt"
    elif _is_dead:
        new_anim = "death"
    # ...
    if sprite.sprite_frames and sprite.animation != new_anim:
        sprite.play(new_anim)
```
Malandro mirrors: guard `_is_dead` first, then walk states. The `sprite.animation != new_anim` guard prevents frame-0 freeze — required.

**@onready pattern** (`player.gd` lines 47–48):
```gdscript
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dust_particles: CPUParticles2D = $DustParticles
```
Malandro: `@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D`, `@onready var stomp_zone: Area2D = $StompZone`. Always typed, always `@onready`.

**signal connection in _ready pattern** (`player.gd` style; confirmed in test_dialogue.gd lines 9–11):
```gdscript
func _ready() -> void:
    start_button.pressed.connect(_on_start_pressed)
    skip_button.pressed.connect(_on_skip_pressed)
```
Malandro `_ready`: `stomp_zone.body_entered.connect(_on_stomp_zone_body_entered)`.

---

### `scenes/world1/checkpoint.gd` (trigger/utility, event-driven)

**Analogs:** `scenes/test_save/test_save.gd` (SaveManager.set_checkpoint pattern) + `scenes/test_movement/damage_trigger.gd` (Area2D body_entered pattern)

**Area2D body_entered pattern** (`damage_trigger.gd` lines 1–10, the cleanest Area2D analog in the project):
```gdscript
extends Area2D

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body.has_method("take_damage"):
        body.take_damage(global_position)
```

**SaveManager.set_checkpoint pattern** (`test_save.gd` lines 15–18):
```gdscript
func _on_checkpoint_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        SaveManager.set_checkpoint("test_cp_01")
        label.text = "SALVO: test_cp_01"
```

**Combined checkpoint pattern** — merge both analogs:
```gdscript
extends Area2D

@export var checkpoint_id: String = "mundo1_fase1_cp1"

var _activated: bool = false

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if _activated:
        return
    if body.is_in_group("player"):
        _activated = true
        SaveManager.set_checkpoint(checkpoint_id)
        AudioManager.play_sfx("checkpoint")
        _play_activate_animation()

func _play_activate_animation() -> void:
    var t := create_tween()
    t.tween_property($AnimatedSprite2D, "scale", Vector2(1.25, 1.25), 0.1)
    t.tween_property($AnimatedSprite2D, "scale", Vector2(1.0, 1.0), 0.15)
    $AnimatedSprite2D.modulate = Color("#E07020")
```

**Tween pattern** (from `player.gd` lines 191–193, project-standard tween creation):
```gdscript
var t := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
t.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.25)
```

---

### `scenes/world1/prova_item.gd` (trigger/utility, event-driven)

**Analog:** `scenes/test_movement/damage_trigger.gd` — exact same Area2D body_entered structure

**Core Area2D pattern** (`damage_trigger.gd` lines 1–10):
```gdscript
extends Area2D

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body.has_method("take_damage"):
        body.take_damage(global_position)
```

**SaveManager dict access pattern** (`save_manager.gd` lines 38–40 and lines 43–44):
```gdscript
func set_checkpoint(checkpoint_id: String) -> void:
    current_save["checkpoint_id"] = checkpoint_id
    save_game()
```
Prova item mirrors: read with `.get("provas_mundo1", [])`, append, assign back, call `save_game()`.

**Defensive dict access** (RESEARCH.md Pitfall 2 + `save_manager.gd` line 21 `.get("version", 0)`):
```gdscript
# Always use .get() with default — save from Phase 2 won't have "provas_mundo1"
var provas: Array = SaveManager.current_save.get("provas_mundo1", [])
```

**`set_deferred` + `queue_free` with timer** (`player.gd` `_start_dash` CONNECT_ONE_SHOT pattern, line 137):
```gdscript
get_tree().create_timer(dash_cooldown).timeout.connect(func(): _can_dash = true, CONNECT_ONE_SHOT)
```
Prova item: `get_tree().create_timer(0.25, true).timeout.connect(queue_free, CONNECT_ONE_SHOT)`.

---

### `scenes/world1/boss_pai.gd` (controller, event-driven)

**Analog:** `scenes/test_dialogue/test_dialogue.gd`

**Dialogic start + await pattern** (`test_dialogue.gd` lines 18–29):
```gdscript
func start_cutscene(timeline_name: String) -> void:
    if Dialogic.current_timeline != null:
        return
    skip_button.visible = SaveManager.has_seen_cutscene(timeline_name)
    Dialogic.start(timeline_name)
    await Dialogic.timeline_ended
    SaveManager.mark_cutscene_seen(timeline_name)
    Dialogic.Inputs.auto_skip.enabled = false
    skip_button.visible = false
```

**signal connection in _ready** (`test_dialogue.gd` lines 9–11):
```gdscript
func _ready() -> void:
    start_button.pressed.connect(_on_start_pressed)
    skip_button.pressed.connect(_on_skip_pressed)
```

**Defensive SaveManager access pattern** (`save_manager.gd` line 21, `test_save.gd` line 11):
```gdscript
var cp: String = SaveManager.current_save.get("checkpoint_id", "(none)")
```
Boss: `var provas: Array = SaveManager.current_save.get("provas_mundo1", [])`.

**Combined boss pattern** — extend test_dialogue.gd structure with trust logic:
```gdscript
extends Node2D

var _trust: float = 0.0
const TRUST_MAX: float = 100.0

@onready var trust_bar_fill: ColorRect = $BossHUD/TrustBarFill

func _ready() -> void:
    _start_boss_sequence()

func _start_boss_sequence() -> void:
    var provas: Array = SaveManager.current_save.get("provas_mundo1", [])
    _trust = 0.0
    for prova_id in provas:
        await _show_prova_card(prova_id)
        add_trust(20.0)
    if Dialogic.current_timeline != null:
        return
    Dialogic.start("boss_abertura")
    Dialogic.signal_event.connect(_on_dialogic_signal)
    await Dialogic.timeline_ended
    Dialogic.signal_event.disconnect(_on_dialogic_signal)

func _on_dialogic_signal(argument: String) -> void:
    match argument:
        "choice_correct": add_trust(10.0)
        "choice_wrong": add_trust(-15.0)
        "renato_entrada": _trigger_renato_entrance()

func add_trust(amount: float) -> void:
    _trust = clampf(_trust + amount, 0.0, TRUST_MAX)
    _update_trust_bar()
    if _trust <= 0.0:
        _game_over_boss()
    elif _trust >= TRUST_MAX:
        _boss_victory()

func _update_trust_bar() -> void:
    trust_bar_fill.size.x = (_trust / TRUST_MAX) * 200.0  # 200px = full width
```

---

### `scenes/world1/fase1_rua.gd` / `fase2_parque.gd` / `fase3_restaurante.gd` (scene controller, request-response)

**Analog:** `scenes/test_movement/test_movement.gd` (scene with player reference) + `scenes/main_menu/main_menu.gd` (SceneTransition.go_to pattern)

**Scene script structure** (`test_movement.gd` lines 1–19):
```gdscript
extends CanvasLayer

@onready var player = $"../Player"
@onready var state_label: Label = $StateLabel

func _process(_delta: float) -> void:
    if player == null:
        return
    state_label.text = (...)
```

**SceneTransition.go_to pattern** (`main_menu.gd` lines 27–29):
```gdscript
func _on_continue_pressed() -> void:
    SceneTransition.go_to("res://scenes/test_movement/test_movement.tscn")
```

**Core fase script pattern** — combining both analogs:
```gdscript
extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var checkpoint: Area2D = $Checkpoint

var _checkpoint_position: Vector2

func _ready() -> void:
    _checkpoint_position = checkpoint.global_position
    player.died.connect(_on_player_died)

func _on_player_died() -> void:
    player.global_position = _checkpoint_position
    player.velocity = Vector2.ZERO
    player._is_dead = false
    player._is_hurt = false
    _reset_enemies()

func _reset_enemies() -> void:
    for enemy in get_tree().get_nodes_in_group("enemies"):
        if enemy.has_method("reset_to_origin"):
            enemy.reset_to_origin()

func _go_to_next_fase(next_path: String) -> void:
    SceneTransition.go_to(next_path)
```

---

### `scenes/world1/mundo1_abertura.gd` (scene controller, request-response)

**Analog:** `scenes/test_dialogue/test_dialogue.gd` — exact match for Dialogic cutscene scene

**Full pattern** (`test_dialogue.gd` lines 1–34):
```gdscript
extends Node2D

const TIMELINE_ID := "test_dialogue"

func _ready() -> void:
    start_button.pressed.connect(_on_start_pressed)
    skip_button.pressed.connect(_on_skip_pressed)

func start_cutscene(timeline_name: String) -> void:
    if Dialogic.current_timeline != null:
        return
    skip_button.visible = SaveManager.has_seen_cutscene(timeline_name)
    Dialogic.start(timeline_name)
    await Dialogic.timeline_ended
    SaveManager.mark_cutscene_seen(timeline_name)
    Dialogic.Inputs.auto_skip.enabled = false
    skip_button.visible = false
```

mundo1_abertura.gd replaces `TIMELINE_ID = "test_dialogue"` with `"mundo1_abertura"`, removes StartButton (auto-starts in `_ready()`), and on `timeline_ended` calls `SceneTransition.go_to("res://scenes/world1/fase1_rua.tscn")`.

---

### `scenes/player/player.gd` (MODIFY — add `signal died`)

**Analog:** self — this is an additive modification only

**Current stub at line 181–182** (exact text to replace):
```gdscript
elif sprite.animation == "death":
    print("Player death animation finished — respawn hooked in Phase 3")
```

**Change:** Add `signal died` at class top (after `extends CharacterBody2D`, before `@export_group`), and replace the print with `died.emit()`:
```gdscript
# At class top — line 2 (before @export_group):
signal died

# In _on_animated_sprite_2d_animation_finished (line 178–182):
func _on_animated_sprite_2d_animation_finished() -> void:
    if sprite.animation == "hurt":
        _is_hurt = false
    elif sprite.animation == "death":
        died.emit()
```

**Explicit type convention** (CLAUDE.md + RESEARCH.md): `signal died` is a bare signal with no parameters — consistent with GDScript 4 typed signal pattern (no parameters needed for respawn, as scene script reads player state directly).

---

### `autoloads/save_manager.gd` (MODIFY — add `provas_mundo1`)

**Analog:** self — additive modification to `_default_save()`

**Current `_default_save` pattern** (`save_manager.gd` lines 49–56):
```gdscript
func _default_save() -> Dictionary:
    return {
        "version": SCHEMA_VERSION,
        "checkpoint_id": "",
        "worlds_completed": [],
        "powers_unlocked": [],
        "seen_cutscenes": {},
    }
```

**Change 1:** Increment `SCHEMA_VERSION` from `1` to `2` (line 3) — forces reset of saves from Phase 2 that lack `provas_mundo1`. The load_game() check on line 21 (`data.get("version", 0) == SCHEMA_VERSION`) handles migration automatically.

**Change 2:** Add `"provas_mundo1": []` to the returned dict.

**Migration safety pattern** already in `load_game()` (line 21–25):
```gdscript
if data is Dictionary and data.get("version", 0) == SCHEMA_VERSION:
    current_save = data
else:
    # Save corrompido ou versão incompatível
    current_save = _default_save()
```
No additional migration code needed — version bump + _default_save update is sufficient.

---

### `scenes/main_menu/main_menu.gd` (MODIFY — update go_to() targets)

**Analog:** self — three line changes

**Current pattern** (`main_menu.gd` lines 27–43):
```gdscript
func _on_continue_pressed() -> void:
    SceneTransition.go_to("res://scenes/test_movement/test_movement.tscn")

func _on_new_game_pressed() -> void:
    if SaveManager.save_exists():
        confirm_new_game.popup_centered()
        return
    SaveManager.new_game()
    SceneTransition.go_to("res://scenes/test_movement/test_movement.tscn")

func _on_new_game_confirmed() -> void:
    SaveManager.new_game()
    SceneTransition.go_to("res://scenes/test_movement/test_movement.tscn")
```

**Change:** Replace `"res://scenes/test_movement/test_movement.tscn"` (all 3 occurrences) with `"res://scenes/world1/mundo1_abertura.tscn"`. No structural change — same SceneTransition.go_to() call, same SaveManager.new_game() call.

---

## Shared Patterns

### Area2D body_entered with player group check
**Source:** `scenes/test_movement/damage_trigger.gd` lines 1–10 and `scenes/test_save/test_save.gd` lines 15–17
**Apply to:** `checkpoint.gd`, `prova_item.gd`, static_obstacle trigger nodes, NPC dialogue trigger zones

```gdscript
# Pattern: connect in _ready, guard with is_in_group("player")
func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if not body.is_in_group("player"):
        return
    # ... action
```

### SaveManager defensive read
**Source:** `save_manager.gd` line 21 (`.get("version", 0)`), `test_save.gd` line 11 (`.get("checkpoint_id", "(none)")`)
**Apply to:** All scripts that read `current_save` — `prova_item.gd`, `boss_pai.gd`, `checkpoint.gd`, `fase_N.gd` respawn logic

```gdscript
# Always .get() with a default — never direct ["key"] access
var provas: Array = SaveManager.current_save.get("provas_mundo1", [])
var cp: String = SaveManager.current_save.get("checkpoint_id", "")
```

### Tween animation (procedural, no AnimationPlayer)
**Source:** `scenes/player/player.gd` lines 191–201
**Apply to:** `checkpoint.gd` pulse animation, boss trust bar color change, prova collection flash

```gdscript
var t := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
t.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.25)
# For simple one-way tweens (no elastic):
var t := create_tween()
t.tween_property(node, "property", target_value, duration)
```

### CollisionShape2D deferred disable
**Source:** `player.gd` convention (RESEARCH.md Pitfall 3, also `damage_trigger.gd` implies it via Area2D use)
**Apply to:** `malandro.gd` die(), `prova_item.gd` after collection

```gdscript
# Always set_deferred — never direct assignment during physics
$CollisionShape2D.set_deferred("disabled", true)
```

### create_timer with process_always=true
**Source:** `scenes/player/player.gd` lines 216–218
**Apply to:** `malandro.gd` death delay, `prova_item.gd` queue_free delay, any timer that must survive hit-stop

```gdscript
await get_tree().create_timer(duration, true).timeout
# For one-shot callbacks:
get_tree().create_timer(0.3, true).timeout.connect(queue_free, CONNECT_ONE_SHOT)
```

### Dialogic start + await + signal disconnect
**Source:** `scenes/test_dialogue/test_dialogue.gd` lines 18–29
**Apply to:** `boss_pai.gd`, `mundo1_abertura.gd`, any NPC dialogue trigger

```gdscript
Dialogic.start("timeline_name")
Dialogic.signal_event.connect(_on_dialogic_signal)
await Dialogic.timeline_ended
Dialogic.signal_event.disconnect(_on_dialogic_signal)
SaveManager.mark_cutscene_seen("timeline_name")
```

### CPUParticles2D (never GPUParticles2D)
**Source:** `scenes/player/player.gd` line 48 (`@onready var dust_particles: CPUParticles2D = $DustParticles`)
**Apply to:** `prova_item.gd` collection burst, `checkpoint.gd` activation glow, boss victory particles

```gdscript
@onready var particles: CPUParticles2D = $CPUParticles2D
# Trigger: particles.restart()  (one-shot burst)
# or: particles.emitting = true
```

### SceneTransition.go_to() for full scene changes only
**Source:** `scenes/main_menu/main_menu.gd` lines 27–43, `autoloads/scene_transition.gd` lines 9–22
**Apply to:** Phase-to-phase transitions (fase1→fase2→fase3→boss), menu→world1 — NOT for respawn

```gdscript
# Takes 0.6s total (0.3s fade out + 2 frames + 0.3s fade in)
# DO NOT use for respawn (violates WORLD-05 < 500ms requirement)
SceneTransition.go_to("res://scenes/world1/fase2_parque.tscn")
```

---

## No Analog Found

All files have analogs in the codebase. No research-only patterns required.

---

## Metadata

**Analog search scope:** `/Users/renatojaf/jogo-natalia/autoloads/`, `/Users/renatojaf/jogo-natalia/scenes/` (excluding addons/)
**Files scanned:** 9 project GDScript files (excluding Dialogic addon internals)
**Pattern extraction date:** 2026-06-08
