# Phase 05: Level Design Overhaul — Pattern Map

**Mapped:** 2026-06-10
**Files analyzed:** 15 new/modified files
**Analogs found:** 11 / 15 (with strong matches)

---

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `scenes/shared/moving_platform.gd` | mechanic/scene | transform | `scenes/world1/malandro.gd` | role-match |
| `scenes/shared/moving_platform.tscn` | scene | transform | `scenes/world1/malandro.tscn` | structure-match |
| `scenes/shared/damage_zone.gd` | mechanic/scene | event-driven | `scenes/test_movement/damage_trigger.gd` | exact |
| `scenes/shared/damage_zone.tscn` | scene | event-driven | `scenes/world1/checkpoint.tscn` | structure-match |
| `scenes/shared/pushable_box.gd` | mechanic/scene | physics | `scenes/world1/malandro.gd` | role-match |
| `scenes/shared/pushable_box.tscn` | scene | physics | `scenes/world1/malandro.tscn` | structure-match |
| `scenes/shared/timed_obstacle.gd` | mechanic/scene | event-driven | `scenes/test_movement/damage_trigger.gd` | role-match |
| `scenes/shared/timed_obstacle.tscn` | scene | event-driven | `scenes/world1/checkpoint.tscn` | structure-match |
| `scenes/world1/moto_dois_homens.gd` | enemy | CRUD | `scenes/world2/impressora_raivosa.gd` | exact |
| `scenes/world1/moto_dois_homens.tscn` | scene | CRUD | `scenes/world1/malandro.tscn` | structure-match |
| `scenes/world1/malandro_resistente.gd` | enemy-variant | CRUD | `scenes/world1/malandro.gd` | exact |
| `scenes/world1/malandro_resistente.tscn` | scene | CRUD | `scenes/world1/malandro.tscn` | structure-match |
| `scenes/world1/malandro_coraza.gd` | enemy-variant | CRUD | `scenes/world1/malandro.gd` | exact |
| `scenes/world1/malandro_coraza.tscn` | scene | CRUD | `scenes/world1/malandro.tscn` | structure-match |
| `scenes/player/player.tscn` | scene | transform | `scenes/player/player.tscn` | self |
| `scenes/world1/fase*.tscn` (3) | level | layout | `scenes/world1/fase1_rua.tscn` | self |
| `scenes/world2/fase*.tscn` (3) | level | layout | `scenes/world1/fase1_rua.tscn` | structure-match |

---

## Pattern Assignments

### Enemy Base Pattern: `malandro.gd` (CharacterBody2D patrol + stomp + body-hit)

**Analog:** `scenes/world1/malandro.gd`

**Class structure & state** (lines 1–22):
```gdscript
extends CharacterBody2D

@export_group("Patrol")
@export var patrol_speed: float = 40.0

var _origin: Vector2
var _direction: float = 1.0
var _is_dead: bool = false
var _stomped_this_frame: bool = false
const GRAVITY: float = 900.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var stomp_zone: Area2D = $StompZone
@onready var edge_ray: RayCast2D = $EdgeRayCast
```

**Initialization** (lines 19–25):
```gdscript
func _ready() -> void:
	_origin = global_position
	add_to_group("enemies")
	stomp_zone.body_entered.connect(_on_stomp_zone_body_entered)
	var body_hitbox: Area2D = $BodyHitbox
	body_hitbox.body_entered.connect(_on_body_hitbox_entered)
```

**Physics loop** (lines 27–52):
```gdscript
func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_stomped_this_frame = false
	velocity.y += GRAVITY * delta
	velocity.x = _direction * patrol_speed
	move_and_slide()

	if is_on_wall() or not edge_ray.is_colliding():
		_direction *= -1.0
		sprite.flip_h = _direction < 0.0
		edge_ray.position.x = abs(edge_ray.position.x) * _direction

	_update_animation()
```

**Stomp detection** (lines 55–73):
```gdscript
func _on_stomp_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.velocity.y >= 0.0 and not _stomped_this_frame:
		_stomped_this_frame = true
		die()
		body.velocity.y = body.jump_velocity * 0.6

func _on_body_hitbox_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or _is_dead or _stomped_this_frame:
		return
	if body.global_position.y < global_position.y - 8.0 and body.velocity.y >= 0.0:
		_stomped_this_frame = true
		die()
		body.velocity.y = body.jump_velocity * 0.6
	else:
		body.take_damage(global_position)
```

**Death & reset** (lines 75–89):
```gdscript
func die() -> void:
	_is_dead = true
	sprite.play("death")
	$CollisionShape2D.set_deferred("disabled", true)
	AudioManager.play_sfx("stomp")
	get_tree().create_timer(0.3, true).timeout.connect(queue_free, CONNECT_ONE_SHOT)

func reset_to_origin() -> void:
	global_position = _origin
	_is_dead = false
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", false)
	sprite.play("walk")
```

---

### Enemy Variant: Firing/Multi-Phase — `impressora_raivosa.gd`

**Analog:** `scenes/world2/impressora_raivosa.gd`

**Extended pattern: fire timer + projectile spawn** (lines 4–5, 16–17, 58–61):
```gdscript
@export var fire_rate: float = 2.0
@export var projectile_scene: PackedScene = null

var _fire_timer: float = 0.0

# In _physics_process:
_fire_timer -= delta
if _fire_timer <= 0.0:
	_spawn_projectile()
	_fire_timer = fire_rate
```

**Projectile spawning** (lines 87–96):
```gdscript
func _spawn_projectile() -> void:
	if projectile_scene == null:
		return

	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = global_position + Vector2(0, -8)
```

**Reset variant** (lines 106–112):
```gdscript
func reset_to_origin() -> void:
	global_position = _origin
	_is_dead = false
	velocity = Vector2.ZERO
	_fire_timer = fire_rate  # Reset fire timer on scene reset
	$CollisionShape2D.set_deferred("disabled", false)
	sprite.play("walk")
```

---

### Scene Structure: Enemy .tscn

**Analog:** `scenes/world1/malandro.tscn`

**Header & node tree** (lines 1–49):
```tscn
[gd_scene load_steps=6 format=3 uid="uid://wj8twxy6wvmx"]

[ext_resource type="Script" path="res://scenes/world1/malandro.gd" id="1"]
[ext_resource type="Resource" path="res://scenes/world1/malandro_sprite_frames.tres" id="2_frames"]

[sub_resource type="CapsuleShape2D" id="CapsuleShape2D_malandro"]
radius = 6.0
height = 22.0

[sub_resource type="RectangleShape2D" id="RectangleShape2D_stomp"]
size = Vector2(16, 4)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_body"]
size = Vector2(14, 28)

[node name="Malandro" type="CharacterBody2D" groups=["enemies"]]
script = ExtResource("1")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("CapsuleShape2D_malandro")

[node name="AnimatedSprite2D" type="AnimatedSprite2D" parent="."]
sprite_frames = ExtResource("2_frames")
animation = &"walk"
autoplay = "walk"

[node name="Visual" type="Polygon2D" parent="."]
color = Color(0.784313, 0.188235, 0.188235, 1)
polygon = PackedVector2Array(-8, -16, 8, -16, 8, 16, -8, 16)

[node name="StompZone" type="Area2D" parent="."]
position = Vector2(0, -16)
monitoring = true
monitorable = false

[node name="CollisionShape2D" type="CollisionShape2D" parent="StompZone"]
shape = SubResource("RectangleShape2D_stomp")

[node name="BodyHitbox" type="Area2D" parent="."]
monitoring = true
monitorable = false

[node name="CollisionShape2D" type="CollisionShape2D" parent="BodyHitbox"]
shape = SubResource("RectangleShape2D_body")

[node name="EdgeRayCast" type="RayCast2D" parent="."]
position = Vector2(10, 0)
target_position = Vector2(0, 20)
```

**Key configuration notes:**
- CharacterBody2D root with `groups=["enemies"]`
- Three child collision zones: main body, stomp (top), body-hit
- AnimatedSprite2D OR Polygon2D for visual (current uses both; can replace sprite with pure Polygon2D)
- StompZone positioned at `(0, -16)` — above enemy head
- EdgeRayCast for floor detection during patrol

---

### Level Scene: Fase .tscn Expansion Template

**Analog:** `scenes/world1/fase1_rua.tscn`

**Header for expanded fase** (lines 1–18):
```tscn
[gd_scene load_steps=10 format=3 uid="uid://i1b0e1vl0s1i"]

[ext_resource type="Script" path="res://scenes/world1/fase1_rua.gd" id="1_script"]
[ext_resource type="PackedScene" uid="uid://b3kp7mjpv8n4" path="res://scenes/player/player.tscn" id="2_player"]
[ext_resource type="TileSet" uid="uid://c7xykjmutl5oj" path="res://scenes/world1/osasco_tileset.tres" id="3_tileset"]
[ext_resource type="PackedScene" path="res://scenes/world1/malandro.tscn" id="4_malandro"]
[ext_resource type="PackedScene" path="res://scenes/world1/checkpoint.tscn" id="5_checkpoint"]
[ext_resource type="PackedScene" path="res://scenes/world1/prova_item.tscn" id="6_prova"]

[sub_resource type="RectangleShape2D" id="RectangleShape2D_floor"]
size = Vector2(1600, 16)  # EXPAND TO Vector2(6400, 16)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_exit"]
size = Vector2(32, 48)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_wall"]
size = Vector2(16, 200)
```

**Background & floor expansion** (lines 22–26, 79–82):
```tscn
[node name="Background" type="ColorRect" parent="."]
offset_right = 1600.0  # EXPAND TO 6400.0
offset_bottom = 180.0
color = Color(0.101961, 0.101961, 0.18039, 1)

[node name="Floor" type="StaticBody2D" parent="."]
position = Vector2(800, 168)  # EXPAND TO Vector2(3200, 168)

[node name="FloorShape" type="CollisionShape2D" parent="Floor"]
shape = SubResource("RectangleShape2D_floor")  # size now 6400
```

**Wall & exit repositioning** (lines 90–100):
```tscn
[node name="WallLeft" type="StaticBody2D" parent="."]
position = Vector2(-8, 90)  # KEEP at -8

[node name="WallRight" type="StaticBody2D" parent="."]
position = Vector2(1608, 90)  # EXPAND TO Vector2(6408, 90)

[node name="ExitTrigger" type="Area2D" parent="."]
position = Vector2(1555, 144)  # EXPAND TO Vector2(6355, 144)
```

**Checkpoint repositioning** (lines 66–68):
```tscn
[node name="Checkpoint" parent="." instance=ExtResource("5_checkpoint")]
position = Vector2(790, 118)  # EXPAND TO Vector2(3200, 118)
checkpoint_id = "mundo1_fase1_cp1"
```

---

### Shared Mechanic: Area2D Event Pattern

**Analog:** `scenes/test_movement/damage_trigger.gd`

**Minimal Area2D event pattern** (complete file):
```gdscript
extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(global_position)
```

**Variant with state & savemanager** (from `scenes/world1/prova_item.gd`):
```gdscript
extends Area2D

@export var prova_id: String = "prova_foto"

var _activated: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or _activated:
		return

	var provas: Array = SaveManager.current_save.get("provas_mundo1", [])
	if prova_id not in provas:
		provas.append(prova_id)
		SaveManager.current_save["provas_mundo1"] = provas
		SaveManager.save_game()

	AudioManager.play_sfx("prova_coletada")
	$CPUParticles2D.emitting = true
	$AnimatedSprite2D.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	get_tree().create_timer(0.25, true).timeout.connect(queue_free, CONNECT_ONE_SHOT)
```

**Checkpoint activation pattern** (from `scenes/world1/checkpoint.gd`, lines 8–19):
```gdscript
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

---

### Player Enhancement: Camera2D Addition

**Analog:** `scenes/player/player.tscn` (to be modified)

**Add to player.tscn** (new child node of Player root):
```tscn
[node name="Camera2D" type="Camera2D" parent="."]
enabled = true
zoom = Vector2(1, 1)
limit_left = 0
limit_right = 6400
limit_top = -500
limit_bottom = 200
drag_horizontal_enabled = true
drag_horizontal_offset = 0.1
position_smoothing_enabled = true
position_smoothing_speed = 5.0
```

**Optional: Script call from fase _ready()** (if per-scene limit_right is needed):
```gdscript
func _ready() -> void:
	if has_node("Camera2D"):
		$Camera2D.limit_right = 6400  # Set per-scene
```

---

### Player State: Dash Immunity Check

**Analog:** `scenes/player/player.gd`

**Dash state field** (line 34):
```gdscript
var _is_dashing: bool = false
```

**Accessible from enemies** — line 386 of RESEARCH.md notes that `_is_dashing` can be read by enemies:
```gdscript
# In malandro_coraza.gd:
if body._is_dashing:
	die()
	body.velocity.y = body.jump_velocity * 0.6
```

No changes to player.gd needed; field is already readable.

---

### SaveManager: Checkpoint Configuration (No Code Changes)

**Analog:** `autoloads/save_manager.gd`

**Existing checkpoint dict** (lines 6–13):
```gdscript
const CHECKPOINT_SCENES: Dictionary = {
	"mundo1_fase1_cp1": "res://scenes/world1/fase1_rua.tscn",
	"mundo1_fase2_cp1": "res://scenes/world1/fase2_parque.tscn",
	"mundo1_fase3_cp1": "res://scenes/world1/fase3_restaurante.tscn",
	"mundo2_fase1_cp1": "res://scenes/world2/fase1_campus.tscn",
	"mundo2_fase2_cp1": "res://scenes/world2/fase2_atelie.tscn",
	"mundo2_fase3_cp1": "res://scenes/world2/fase3_madrugada.tscn",
}
```

**No structural changes required.** Only the checkpoint position in each `.tscn` (from `Vector2(790, 118)` to `Vector2(3200, 118)`) changes per fase.

---

## Shared Patterns

### Enemy Variant: 2-Hit Resistant (`malandro_resistente.gd`)

**Extend `malandro.gd` with:**
```gdscript
var _hp: int = 2

func _on_stomp_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.velocity.y >= 0.0 and not _stomped_this_frame:
		_stomped_this_frame = true
		_hp -= 1
		if _hp <= 0:
			die()
			body.velocity.y = body.jump_velocity * 0.6
		else:
			# First hit: stun + smaller bounce
			$Visual.modulate = Color(1, 0.3, 0.3)  # red tint
			body.velocity.y = body.jump_velocity * 0.4
```

**Visual differentiation:** Red tint or larger sprite in `.tscn`.

---

### Enemy Variant: Dash-Only Killable (`malandro_coraza.gd`)

**Extend `malandro.gd` with:**
```gdscript
func _on_stomp_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not _stomped_this_frame:
		_stomped_this_frame = true
		if body._is_dashing:
			die()
			body.velocity.y = body.jump_velocity * 0.6
		else:
			body.velocity.y = body.jump_velocity * 0.3  # small bounce
			body.take_damage(global_position)  # player takes damage for trying
```

**Visual differentiation:** Blue tint or shield overlay in `.tscn`.

---

### Enemy Variant: Moto com Dois Homens (`moto_dois_homens.gd`)

**Extend `impressora_raivosa.gd` (firing variant) pattern with:**
```gdscript
var _hp: int = 2
var _phase: int = 1  # 1 = both; 2 = pilot only

@onready var passenger_visual: Node2D = $Visual/Passenger

func take_hit() -> void:
	_hp -= 1
	if _hp <= 0:
		die()
	elif _hp == 1:
		_phase = 2
		passenger_visual.hide()
		patrol_speed = moto_speed_solo
```

**Visual structure in .tscn:** Moto with two humanoid figures (Pilot + Passenger).

---

### Timed Obstacle Pattern

**Pattern: Timer-based collision toggle** (from RESEARCH.md section 5):
```gdscript
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

---

### Damage Zone Pattern

**Pattern: Area2D with repeating damage timer** (from RESEARCH.md section 3):
```gdscript
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

**Visual:** ColorRect with `modulate.a = 0.4` (semi-transparent brown for mud, purple for fog, etc.).

---

### Moving Platform Pattern

**Pattern: AnimatableBody2D with Tween** (from RESEARCH.md section 2):
```gdscript
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

**Scene structure:** AnimatableBody2D root with CollisionShape2D + Visual (ColorRect or Polygon2D).

---

### Pushable Box Pattern

**Pattern: RigidBody2D with locked rotation** (from RESEARCH.md section 4):
```
[node name="Caixa" type="RigidBody2D"]
mass = 3.0
lock_rotation = true
gravity_scale = 3.0

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("RectangleShape2D_box")

[node name="Visual" type="Polygon2D" parent="."]
```

**No script needed.** Pushes naturally via physics when player collides. Ensure NOT in "enemies" group.

---

## No Analog Found

No files require analog patterns that do not exist in the codebase:

| File | Role | Reason |
|------|------|--------|
| (all files have analogs) | — | All mechanical patterns exist in codebase; only scene layout expansion needed |

---

## Metadata

**Analog search scope:** `scenes/world1/`, `scenes/world2/`, `scenes/player/`, `scenes/test_movement/`, `autoloads/`

**Files scanned:** 45

**Pattern extraction date:** 2026-06-10

**Key findings:**
1. **Enemy base pattern** exists in `malandro.gd` — stomp + body-hit detection fully established
2. **Firing variant pattern** exists in `impressora_raivosa.gd` — fire timer + projectile spawn
3. **Area2D event pattern** exists in three variants (damage_trigger, prova_item, checkpoint)
4. **Scene structure** established in `malandro.tscn` and `fase1_rua.tscn` — ready for expansion
5. **Player dash state** (`_is_dashing`) is publicly readable by enemies — no changes needed
6. **SaveManager checkpoint dict** already has all 6 fase keys — only position updates required
7. **No missing patterns** — all 4 environmental mechanics (moving platform, damage zone, pushable box, timed obstacle) can be implemented from scratch using established patterns (Tween, Area2D, Timer, RigidBody2D)

---

## Execution Notes for Planner

1. **Wave 1:** Create shared mechanics (`moving_platform.gd/tscn`, `damage_zone.gd/tscn`, `pushable_box.gd/tscn`, `timed_obstacle.gd/tscn`) — copy structure from `malandro.tscn`, adapt scripts from patterns above
2. **Wave 2:** Add Camera2D to `player.tscn` — single node addition with fixed limit_right=6400
3. **Wave 3:** Expand all 6 fase scenes (`.tscn` only) — scale 1600px→6400px, reposition checkpoint/walls/exit, double-check tilemap extends
4. **Wave 4:** Create enemy variants (`malandro_resistente.gd`, `malandro_coraza.gd`) — extend `malandro.gd` with HP + phase logic
5. **Wave 5:** Create `moto_dois_homens.gd/tscn` — combine firing logic from `impressora_raivosa.gd` + 2-phase mechanics
6. **Wave 6:** Populate fases with new enemies and mechanics — position in .tscn, configure exports in Inspector

---
