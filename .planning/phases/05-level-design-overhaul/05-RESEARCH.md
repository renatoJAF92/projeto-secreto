# Phase 05 — Research: Level Design Overhaul

**Generated:** 2026-06-10
**Method:** Inline research (codebase analysis + Godot 4 patterns)

---

## Summary

This phase rewrites all 6 existing phase scenes from 1600px to 6400px, adds 4 environmental mechanics, creates new enemy variants, and improves placeholder art. All changes are additive rewrites of `.tscn` and `.gd` files — no new autoloads or systems needed.

---

## 1. Phase Expansion: 1600px → 6400px

### Current layout (every fase scene)
| Node | Current value | Required change |
|------|--------------|-----------------|
| `Background` ColorRect | `offset_right = 1600.0` | `offset_right = 6400.0` |
| `Floor` StaticBody2D position | `Vector2(800, 168)` | `Vector2(3200, 168)` |
| `FloorShape` RectangleShape2D | `size = Vector2(1600, 16)` | `size = Vector2(6400, 16)` |
| `WallRight` position | `Vector2(1608, 90)` | `Vector2(6408, 90)` |
| `ExitTrigger` position | `Vector2(1555, 144)` | `Vector2(6355, 144)` |
| `Checkpoint` position | mid (≈760-790, 118) | `Vector2(3200, 118)` |

### Enemy/item distribution
Current fases pack all content in 0–1500px. In 6400px fases, distribute content across:
- **Section 1 (x: 0–2800px):** ~40% of enemies, intro mechanics
- **Checkpoint (x: 3200px)**
- **Section 2 (x: 3600–6200px):** ~60% of enemies, harder variants, advanced mechanics

### Camera2D — REQUIRED for wide scenes
Currently `player.tscn` has no Camera2D. With 6400px fases, player must have a following camera with limits. **This must be added as part of this phase.**

```gdscript
# Add to player.tscn as child of Player:
[node name="Camera2D" type="Camera2D" parent="."]
enabled = true
zoom = Vector2(1, 1)
limit_left = 0
limit_right = 6400   # set per-scene or via script
limit_top = -500
limit_bottom = 200
drag_horizontal_enabled = true
drag_horizontal_offset = 0.1
position_smoothing_enabled = true
position_smoothing_speed = 5.0
```

**Godot 4 Camera2D limits per scene:** Call `$Camera2D.limit_right = 6400` in the fase's `_ready()` if Camera2D is on the player. Or set directly in player.tscn with a default of 6400 (all fase overhaul scenes are the same width).

---

## 2. Moving Platforms

### Best approach: AnimatableBody2D + Tween

`AnimatableBody2D` (Godot 4.1+) is the correct node for platforms that carry the player:
- Inherits `StaticBody2D` — player stands on it correctly via `move_and_slide()`
- Has `sync_to_physics = true` — syncs to physics frame for smooth, no-jitter movement
- Move it by setting `global_position` in `_physics_process()` or via a Tween

```gdscript
# moving_platform.gd
extends AnimatableBody2D

@export var move_distance: float = 80.0
@export var move_speed: float = 40.0
@export var move_axis: Vector2 = Vector2(1, 0)  # horizontal or vertical

var _start_pos: Vector2
var _tween: Tween

func _ready() -> void:
	_start_pos = global_position
	_start_tween()

func _start_tween() -> void:
	_tween = create_tween().set_loops()
	var end_pos = _start_pos + move_axis * move_distance
	_tween.tween_property(self, "global_position", end_pos, move_distance / move_speed)
	_tween.tween_property(self, "global_position", _start_pos, move_distance / move_speed)
```

**TSCN structure:**
```
[node name="MovingPlatform" type="AnimatableBody2D"]
sync_to_physics = true
script = ExtResource("moving_platform")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("RectangleShape2D_platform")

[node name="Visual" type="ColorRect" parent="."]  # or Polygon2D
```

**Pitfall:** Do NOT use `AnimationPlayer` with position tracks on physics bodies — it bypasses physics and causes tunneling. Always use Tween or direct position assignment in `_physics_process`.

---

## 3. Damage Zones (Passive)

### Pattern: Area2D + Timer

```gdscript
# damage_zone.gd
extends Area2D

@export var damage_interval: float = 0.5
@export var damage_amount: int = 1

var _player: CharacterBody2D = null
var _damage_timer: Timer

func _ready() -> void:
	_damage_timer = Timer.new()
	_damage_timer.wait_time = damage_interval
	_damage_timer.one_shot = false
	_damage_timer.timeout.connect(_deal_damage)
	add_child(_damage_timer)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player = body
		_damage_timer.start()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player = null
		_damage_timer.stop()

func _deal_damage() -> void:
	if _player and is_instance_valid(_player):
		_player.take_damage(global_position)
```

**Visual:** ColorRect with semi-transparent color (lama: brown, névoa: purple). Use `modulate.a = 0.4` for transparency.

**Pitfall:** `Area2D` monitoring must be `true`. If `process_mode = WHEN_PAUSED`, damage won't trigger during hit-stop (good — we want that).

---

## 4. Pushable Objects

### Best approach: RigidBody2D with lock_rotation

```gdscript
# pushable_box.gd  (or no script needed for basic push)
extends RigidBody2D
```

```
[node name="Caixa" type="RigidBody2D"]
mass = 3.0
lock_rotation = true
gravity_scale = 3.0

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("RectangleShape2D_box")  # size = Vector2(24, 24)

[node name="Visual" type="Polygon2D" parent="."]
```

**Why RigidBody2D:** Simpler than CharacterBody2D for pushables — collision with player naturally imparts momentum. The player's `move_and_slide()` pushes it.

**Godot 4 pitfall:** `RigidBody2D` in physics groups — make sure it is NOT in "enemies" group, otherwise enemy detection logic fires. Add to "pushable" group.

**Caveat:** The player's `move_and_slide()` pushes RigidBody2D via physics naturally. No extra code needed in player.gd.

---

## 5. Timed Obstacles

### Pattern: Timer + CollisionShape2D toggling

```gdscript
# timed_obstacle.gd
extends StaticBody2D

@export var open_time: float = 1.5
@export var closed_time: float = 2.0
@export var start_open: bool = false

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var visual_closed: Polygon2D = $VisualClosed
@onready var visual_open: Polygon2D = $VisualOpen

var _is_open: bool = false

func _ready() -> void:
	_is_open = start_open
	_update_state()
	_schedule_next()

func _schedule_next() -> void:
	var wait = open_time if _is_open else closed_time
	get_tree().create_timer(wait).timeout.connect(_toggle, CONNECT_ONE_SHOT)

func _toggle() -> void:
	_is_open = not _is_open
	_update_state()
	_schedule_next()

func _update_state() -> void:
	collision.set_deferred("disabled", _is_open)
	visual_closed.visible = not _is_open
	visual_open.visible = _is_open
```

**Use cases:**
- Portão automático: gate that opens/closes
- Sprinkler: shows as open channel (ColorRect) when active, closed platform when inactive
- Relógio de ponto (Mundo 2): stylized as time-card gate

---

## 6. Multi-Piece Polygon2D Enemy Art

### Pattern: Hierarchical Polygon2D under CharacterBody2D

Each enemy has a `Visual` node (Node2D) grouping all Polygon2D parts:

```
CharacterBody2D (enemy)
├── CollisionShape2D
├── StompZone (Area2D)
├── BodyHitbox (Area2D)
├── EdgeRayCast (RayCast2D)
├── AnimatedSprite2D (or remove if using pure Polygon2D)
└── Visual (Node2D)
    ├── Legs (Polygon2D)       # lower trapezoid
    ├── Torso (Polygon2D)      # main body rectangle
    ├── Head (Polygon2D)       # circle approximated as octagon
    ├── Accessory (Polygon2D)  # boné for malandro, pasta for professor, etc.
    └── Eyes (Polygon2D)       # 2 small squares
```

**Malandro improved art:**
```gdscript
# Legs: PackedVector2Array(-8, 0, 8, 0, 6, 16, -6, 16)   # trapezoid
# Torso: PackedVector2Array(-7, -14, 7, -14, 8, 0, -8, 0)  # rectangle with shoulder
# Head: PackedVector2Array(-5, -24, 5, -24, 6, -15, -6, -15) # rounded rectangle approx
# Boné: PackedVector2Array(-7, -24, 7, -24, 5, -28, -5, -28)  # flat cap brim
```

**Colors:**
- Malandro: body=dark red, head=skin tone, cap=grey
- Impressora: body=grey/beige, arm=darker grey, eyes=red
- Professor: body=brown (suit), head=skin, bald head=slightly lighter

**Animation via code:** To animate walking, use `_physics_process` to oscillate leg positions:
```gdscript
func _update_visual(delta: float) -> void:
	var t = Time.get_ticks_msec() / 200.0
	$Visual/Legs.position.x = sin(t) * 2.0  # simple sway
```

---

## 7. Parallax Background

### Godot 4 approach: ParallaxBackground + ParallaxLayer

```
Fase (Node2D)
├── ParallaxBackground (Node)     ← z_index = -5 (behind everything)
│   ├── ParallaxLayer (layer 1 — far)
│   │   └── ColorRect or Polygon2D (prédios/skyline)
│   └── ParallaxLayer (layer 2 — mid)
│       └── ColorRect or Polygon2D (postes/janelas)
├── Floor (StaticBody2D)
├── Player
└── ...
```

**Configuration:**
```
[node name="ParallaxBackground" type="ParallaxBackground"]
# No settings needed — auto-follows camera

[node name="ParallaxLayerFar" type="ParallaxLayer" parent="ParallaxBackground"]
motion_scale = Vector2(0.2, 0)
motion_mirroring = Vector2(6400, 0)

[node name="FarVisual" type="ColorRect" parent="ParallaxLayerFar"]
offset_right = 6400
offset_bottom = 180
color = Color(0.05, 0.05, 0.10, 1)  # darker background for distant buildings
```

**Mundo 1 (Osasco) parallax layers:**
- Layer 1 (far, scale 0.2): silhouette de prédios — Polygon2D rectangles of varying heights
- Layer 2 (mid, scale 0.5): postes de luz — thin tall Polygon2D every 80px

**Mundo 2 (Faculdade) parallax layers:**
- Layer 1 (far, scale 0.2): estantes de biblioteca — horizontal rectangles
- Layer 2 (mid, scale 0.5): mesas e cadeiras no fundo — wider rectangles

**CRITICAL pitfall with canvas_items stretch mode:** `ParallaxBackground` relies on `scroll_offset` and viewport camera. With `canvas_items` + `integer` scale, it works correctly as long as Camera2D is attached to the player (not a separate node). No issues observed in Godot 4.4.

---

## 8. Moto com Dois Homens Enemy

### Two-phase design pattern

```gdscript
# moto_dois_homens.gd
extends CharacterBody2D

@export var moto_speed_normal: float = 80.0
@export var moto_speed_solo: float = 120.0  # faster after passenger falls

var _hp: int = 2          # 2 hits total
var _phase: int = 1        # 1 = both; 2 = pilot only
var _is_dead: bool = false
var _stomped_this_frame: bool = false
const GRAVITY: float = 900.0

@onready var passenger_visual: Node2D = $Visual/Passenger
@onready var stomp_zone: Area2D = $StompZone
```

**Hit logic:**
```gdscript
func take_hit() -> void:
	_hp -= 1
	if _hp <= 0:
		die()
	elif _hp == 1:
		# Passenger falls — phase 2
		_phase = 2
		passenger_visual.hide()
		patrol_speed = moto_speed_solo
```

**Visual structure (pure Polygon2D):**
```
Moto (CharacterBody2D)
└── Visual (Node2D)
    ├── MotoBody (Polygon2D)     # horizontal trapezoid ~32×14
    ├── Wheel1 (Polygon2D)       # octagon at front
    ├── Wheel2 (Polygon2D)       # octagon at back
    ├── Pilot (Node2D)
    │   ├── PilotBody (Polygon2D)
    │   └── PilotHead (Polygon2D)
    └── Passenger (Node2D)       # hidden on phase 2
        ├── PassengerBody (Polygon2D)
        └── PassengerHead (Polygon2D)
```

**Stomp detection:** Same as malandro — player stomps from above kills passenger (phase 1 → 2). Second stomp kills pilot. The `_hp` counter handles this.

---

## 9. Enemy Variants

### 2-hit variant (`malandro_resistente.gd`)

Extend `malandro.gd` pattern:
```gdscript
var _hp: int = 2
var _hit_once: bool = false

func _on_stomp_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.velocity.y >= 0.0:
		_hp -= 1
		if _hp <= 0:
			die()
			body.velocity.y = body.jump_velocity * 0.6
		else:
			# First hit: flash, knockback player up but don't die
			_hit_once = true
			$Visual.modulate = Color(1, 0.3, 0.3)  # red tint = "damaged"
			body.velocity.y = body.jump_velocity * 0.4  # smaller bounce
```

### Dash-only killable variant (`malandro_coraza.gd`)

```gdscript
func _on_stomp_zone_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if body._is_dashing:
		# Dash kill — works
		die()
		body.velocity.y = body.jump_velocity * 0.6
	elif body.velocity.y >= 0.0:
		# Normal stomp — bounces player but enemy survives
		body.velocity.y = body.jump_velocity * 0.3  # small bounce
		body.take_damage(global_position)  # player takes damage for trying
```

**Visual differentiation:** Give coraza enemies a `modulate = Color(0.3, 0.3, 1.0)` blue tint or a visible "shield" Polygon2D ring around them.

---

## 10. Section Design Within a Fase

No engine mechanics needed — section identity is conveyed through:

1. **Background section markers:** Place second ColorRect at x=3200 with slightly different color behind the main background
2. **Enemy type change:** Section 1 uses only standard malandros; Section 2 introduces resistentes + coraza variants
3. **Platform density:** Section 1 = mostly ground level; Section 2 = more platforms

**Section break visual (cheap and effective):**
```
[node name="SectionDivider" type="ColorRect" parent="."]
offset_left = 3000
offset_top = 0
offset_right = 3010
offset_bottom = 180
color = Color(0.8, 0.8, 0.8, 0.15)  # thin vertical line
```

---

## 11. SaveManager: No Changes Required

The `CHECKPOINT_SCENES` dict already has the correct keys for all 6 fases. Moving the checkpoint from x≈760 to x=3200 only changes the position in the `.tscn` — the checkpoint_id string (e.g., `"mundo1_fase1_cp1"`) stays the same.

Only change needed: the `checkpoint.tscn` position in each fase scene becomes `Vector2(3200, 118)`.

---

## 12. Key Technical Risks

| Risk | Mitigation |
|------|-----------|
| Camera2D missing on player — out-of-bounds view | Add Camera2D to player.tscn as first step of execution |
| AnimatableBody2D not available in Godot 4.4 | It is available since 4.0 — confirmed |
| ParallaxBackground not following camera correctly | Camera2D must be child of player (not scene root) — already our pattern |
| RigidBody2D pushable tunneling through thin walls | Set `continuous_cd = true` on RigidBody2D |
| `_is_dashing` read from enemy — player variable is private | GDScript allows external read of `_` vars; or add `is_dashing()` public getter to player |
| Timed obstacle timer surviving scene change | `get_tree().create_timer()` is freed with the scene — safe |
| load_steps wrong after adding new resources to .tscn | Increment `load_steps` in `[gd_scene]` header for each new ext_resource or sub_resource |

---

## 13. Execution Order Recommendation

This phase rewrites 6 existing fases + creates new enemy scripts + adds Camera2D. Best split into waves:

**Wave 1:** Camera2D (player.tscn) + common shared mechanics (moving_platform.gd, damage_zone.gd, pushable_box.gd, timed_obstacle.gd) + improved enemy base art shared between worlds

**Wave 2:** Rewrite World 1 fases (fase1_rua, fase2_parque, fase3_restaurante) — all 3 to 6400px with new content + enemies

**Wave 3:** Rewrite World 2 fases (fase1_campus, fase2_atelie, fase3_madrugada) — all 3 to 6400px with new content + enemies

**Wave 4:** New enemies (moto_dois_homens, malandro_resistente, malandro_coraza) + human verification checkpoint

## RESEARCH COMPLETE
