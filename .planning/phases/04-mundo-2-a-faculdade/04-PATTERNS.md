# Phase 4: Mundo 2 — A Faculdade - Pattern Map

**Mapped:** 2026-06-09
**Files analyzed:** 14 new/modified files
**Analogs found:** 12 / 14 (85.7% match rate)

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `scenes/world2/mundo2_abertura.gd` | scene-controller | request-response | `scenes/world1/mundo1_abertura.gd` | exact |
| `scenes/world2/mundo2_abertura.tscn` | scene | UI/narrative | `scenes/world1/mundo1_abertura.tscn` | scene-pattern |
| `scenes/world2/fase1_campus.gd` | scene-controller | CRUD (enemy reset) | `scenes/world1/fase1_rua.gd` | exact |
| `scenes/world2/fase1_campus.tscn` | scene | spatial | `scenes/world1/fase1_rua.tscn` | level-pattern |
| `scenes/world2/fase2_atelie.gd` | scene-controller | CRUD (enemy reset) | `scenes/world1/fase1_rua.gd` | exact |
| `scenes/world2/fase2_atelie.tscn` | scene | spatial | `scenes/world1/fase1_rua.tscn` | level-pattern |
| `scenes/world2/fase3_madrugada.gd` | scene-controller | CRUD (enemy reset) | `scenes/world1/fase1_rua.gd` | exact |
| `scenes/world2/fase3_madrugada.tscn` | scene | spatial | `scenes/world1/fase1_rua.tscn` | level-pattern |
| `scenes/world2/boss_tfg.gd` | boss-controller | event-driven (Dialogic) | `scenes/world1/boss_pai.gd` | high (quality bar adaptation) |
| `scenes/world2/boss_tfg.tscn` | scene | narrative+spatial | `scenes/world1/boss_pai.tscn` | boss-pattern |
| `scenes/world2/impressora_raivosa.gd` | enemy | projectile-spawn | `scenes/world1/malandro.gd` | role-match (reskin patrol→fire) |
| `scenes/world2/impressora_raivosa.tscn` | scene | spatial | `scenes/world1/malandro.tscn` | enemy-pattern |
| `scenes/world2/professor_careca.gd` | enemy-hazard | projectile-homing | No exact analog | partial (homing projectile new) |
| `scenes/world2/professor_careca.tscn` | scene | spatial | No exact analog | partial |
| `scenes/world2/projeto_sketch.gd` | projectile | projectile-linear | No exact analog | no-match (new power projectile) |
| `scenes/world2/projeto_sketch.tscn` | scene | spatial | No exact analog | no-match |
| `scenes/world2/tfg_item.gd` | collectible | CRUD | `scenes/world1/prova_item.gd` | exact |
| `scenes/world2/tfg_item.tscn` | scene | spatial | `scenes/world1/prova_item.tscn` | collectible-pattern |
| `scenes/world2/maquete_rustica.tscn` | static-obstacle | collision-damage | `scenes/world1/static_obstacle.tscn` | exact |
| `scenes/world2/world2_end.gd` | scene-controller | request-response | `scenes/world1/world1_end.gd` | exact |
| `scenes/world2/world2_end.tscn` | scene | UI | `scenes/world1/world1_end.tscn` | end-screen-pattern |
| `scenes/world2/renato_cafe_npc.gd` | NPC | event-driven (dialog) | `scenes/world1/renato_npc.gd` | exact |
| `scenes/world2/renato_cafe_npc.tscn` | scene | spatial | `scenes/world1/renato_npc.tscn` | NPC-pattern |
| `scenes/world2/checkpoint_cafe.tscn` | static-collectible | CRUD | `scenes/world1/checkpoint.tscn` | sprite-variation |
| `scenes/player/player.gd` | player-controller | CRUD + powers | `scenes/player/player.gd` | self (modification) |
| `autoloads/save_manager.gd` | singleton | data-persistence | `autoloads/save_manager.gd` | self (schema bump) |
| `project.godot` | config | input-map | `project.godot` | self (new actions) |

## Pattern Assignments

### `scenes/world2/mundo2_abertura.gd` (scene-controller, request-response)

**Analog:** `scenes/world1/mundo1_abertura.gd` (EXACT MATCH)

**Pattern summary:** Auto-start Dialogic timeline on scene load, mark cutscene as seen, transition to first phase.

**Imports pattern** (lines 1-5):
```gdscript
extends Node2D

@onready var skip_button: Button = $UILayer/SkipButton

const TIMELINE_ID := "mundo1_abertura"
```

**Core pattern** (lines 8-26):
```gdscript
func _ready() -> void:
	skip_button.pressed.connect(_on_skip_pressed)
	skip_button.visible = SaveManager.has_seen_cutscene(TIMELINE_ID)
	
	Dialogic.start(TIMELINE_ID)
	await Dialogic.timeline_ended
	
	SaveManager.mark_cutscene_seen(TIMELINE_ID)
	SaveManager.save_game()
	Dialogic.Inputs.auto_skip.enabled = false
	skip_button.visible = false
	
	SceneTransition.go_to("res://scenes/world1/fase1_rua.tscn")

func _on_skip_pressed() -> void:
	Dialogic.Inputs.auto_skip.enabled = true
	Dialogic.Inputs.auto_skip.time_per_event = 0.05
```

**Adaptation for mundo2_abertura.gd:**
- Change `TIMELINE_ID` from `"mundo1_abertura"` to `"mundo2_abertura"`
- Change final transition from `"res://scenes/world1/fase1_rua.tscn"` to `"res://scenes/world2/fase1_campus.tscn"`
- Copy pattern exactly otherwise (skip button, timeline handling, cutscene marking)

---

### `scenes/world2/fase1_campus.gd` / `fase2_atelie.gd` / `fase3_madrugada.gd` (scene-controller, CRUD)

**Analog:** `scenes/world1/fase1_rua.gd` (EXACT MATCH)

**Pattern summary:** Manage checkpoint respawn, enemy reset on death, exit trigger to next phase.

**Core pattern** (lines 1-36):
```gdscript
extends Node2D

func _ready() -> void:
	_checkpoint_position = checkpoint.global_position
	player.died.connect(_on_player_died)
	if exit_trigger:
		exit_trigger.body_entered.connect(_on_exit_trigger_body_entered)

@onready var player: CharacterBody2D = $Player
@onready var checkpoint: Area2D = $Checkpoint
@onready var exit_trigger: Area2D = $ExitTrigger

var _checkpoint_position: Vector2

func _on_player_died() -> void:
	# Instant respawn at checkpoint (no SceneTransition — must be <500ms per WORLD-05)
	player.global_position = _checkpoint_position
	player.velocity = Vector2.ZERO
	player._is_dead = false
	player._is_hurt = false
	_reset_enemies()

func _reset_enemies() -> void:
	# Restore all enemies to their origin positions
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("reset_to_origin"):
			enemy.reset_to_origin()

func _on_exit_trigger_body_entered(body: Node2D) -> void:
	# Player reached the end of the level — transition to fase2
	if body.is_in_group("player"):
		SceneTransition.go_to("res://scenes/world1/fase2_parque.tscn")
```

**Adaptation for cada fase:**
- `fase1_campus.gd`: Line 35 transition to `"res://scenes/world2/fase2_atelie.tscn"`
- `fase2_atelie.gd`: Line 35 transition to `"res://scenes/world2/fase3_madrugada.tscn"`
- `fase3_madrugada.gd`: Line 35 transition to `"res://scenes/world2/boss_tfg.tscn"`
- All other code identical to fase1_rua.gd

---

### `scenes/world2/boss_tfg.gd` (boss-controller, event-driven)

**Analog:** `scenes/world1/boss_pai.gd` (HIGH MATCH — quality bar adaptation)

**Pattern summary:** Gate minimum items collected, present items with HUD, run Dialogic timeline, handle choice signals, track quality metric (not trust), escalate threshold requirement, trigger victory/defeat.

**Structure pattern** (lines 1-19):
```gdscript
extends Node2D

var _quality: float = 0.0
const QUALITY_MAX: float = 100.0

var _quality_threshold: float = 70.0  # Must reach this to win

@onready var quality_bar_fill: ColorRect = %QualityBarFill
@onready var quality_pct_label: Label = %QualityPctLabel
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	_start_boss_sequence()

func _start_boss_sequence() -> void:
	# Gate: need at least 3 TFG items to fight the boss
	var itens = SaveManager.current_save.get("itens_tfg_mundo2", [])
	if itens.size() < 3:
		await _show_blocking_dialogue()
		return
```

**Item presentation pattern** (from boss_pai.gd lines 22-36):
```gdscript
	_quality = 0.0
	_update_hud()
	
	# Present each collected item and grant quality
	for item_id in itens:
		await _show_item_card(item_id)
		add_quality(20.0)
	
	# Guard: prevent timeline overlap
	if Dialogic.current_timeline != null:
		return
	
	# CRITICAL: Connect signal BEFORE starting timeline
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.start("boss_abertura_tfg")
	await Dialogic.timeline_ended
	Dialogic.signal_event.disconnect(_on_dialogic_signal)
```

**Signal handling pattern** (lines 77-85 adapted):
```gdscript
func _on_dialogic_signal(argument: String) -> void:
	match argument:
		"choice_correct":
			add_quality(10.0)
		"choice_wrong":
			add_quality(-15.0)
			AudioManager.play_sfx("dialogo_errado")
		"professor_increases_requirement":
			# Professor Perpétuo raises the bar
			_quality_threshold = minf(_quality_threshold + 15.0, QUALITY_MAX)
```

**Quality metric and victory logic** (lines 87-131 adapted):
```gdscript
func add_quality(amount: float) -> void:
	_quality = clampf(_quality + amount, 0.0, QUALITY_MAX)
	_update_hud()
	
	if _quality < _quality_threshold:
		_trigger_game_over()
	elif _quality >= QUALITY_MAX:
		_trigger_victory()

func _trigger_victory() -> void:
	AudioManager.play_sfx("vitoria")
	
	# Unlock powers retroactively
	var player_ref = player if has_node("Player") else null
	if player_ref and player_ref.has_method("unlock_power"):
		player_ref.unlock_power("sketch")
		player_ref.unlock_power("amor")
	
	SaveManager.current_save["worlds_completed"].append("mundo2")
	SaveManager.current_save["seen_cutscenes"]["boss_vitoria_tfg"] = true
	SaveManager.save_game()
	
	# Victory dialogue
	Dialogic.start("boss_vitoria_tfg")
	await Dialogic.timeline_ended
	
	SceneTransition.go_to("res://scenes/world2/mundo2_end.tscn")

func _trigger_game_over() -> void:
	quality_bar_fill.color = Color("#E53935")  # Red
	AudioManager.play_sfx("dialogo_errado")
	
	# Flash red and retry
	var flash_tween = create_tween()
	flash_tween.tween_property(game_over_flash, "modulate:a", 0.5, 0.2)
	flash_tween.tween_property(game_over_flash, "modulate:a", 0.0, 0.3)
	
	await get_tree().create_timer(0.5, true).timeout
	SceneTransition.go_to("res://scenes/world2/boss_tfg.tscn")
```

**HUD update pattern** (lines 98-112 adapted):
```gdscript
func _update_hud() -> void:
	var fill_width: float = 200.0 * (_quality / QUALITY_MAX)
	quality_bar_fill.custom_minimum_size.x = fill_width
	quality_pct_label.text = str(int(_quality)) + "%"
	
	# Step color by quality level
	if _quality < 20.0:
		quality_bar_fill.color = Color("#E53935")  # Red
	elif _quality < 80.0:
		quality_bar_fill.color = Color("#4CAF50")  # Green
	else:
		quality_bar_fill.color = Color("#D4A017")  # Gold
```

---

### `scenes/world2/impressora_raivosa.gd` (enemy, projectile-spawn)

**Analog:** `scenes/world1/malandro.gd` (ROLE MATCH — adapt patrol to projectile fire)

**Pattern summary:** CharacterBody2D that inherits stomp-death mechanics from malandro but replaces patrol+gravity with projectile firing at intervals.

**Reusable components from malandro.gd:**

**Stomp detection pattern** (lines 55-72):
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

**Die and reset patterns** (lines 75-88):
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

**New pattern for impressora_raivosa.gd** (replace patrol with fire):
```gdscript
extends CharacterBody2D

@export var fire_rate: float = 2.0
@export var projectile_scene: PackedScene

var _is_dead: bool = false
var _stomped_this_frame: bool = false
var _origin: Vector2
var _fire_timer: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var stomp_zone: Area2D = $StompZone

func _ready() -> void:
	_origin = global_position
	add_to_group("enemies")
	stomp_zone.body_entered.connect(_on_stomp_zone_body_entered)
	var body_hitbox: Area2D = $BodyHitbox
	body_hitbox.body_entered.connect(_on_body_hitbox_entered)
	_fire_timer = fire_rate

func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	
	_stomped_this_frame = false
	
	# Fire projectile on timer (no patrol, no gravity)
	_fire_timer -= delta
	if _fire_timer <= 0.0:
		_spawn_projectile()
		_fire_timer = fire_rate
	
	_update_animation()

func _spawn_projectile() -> void:
	if not projectile_scene:
		return
	var proj = projectile_scene.instantiate()
	get_parent().add_child(proj)
	proj.global_position = global_position + Vector2(12.0, 0.0)  # Offset from sprite center
	proj.velocity.x = 150.0  # Fire to the right

# ... (stomp, die, reset_to_origin patterns copied from malandro.gd) ...
```

**Key differences from malandro:**
- Remove `patrol_speed`, `_direction`, edge_ray, wall-turn logic
- Add `fire_rate`, `_fire_timer`, `projectile_scene`
- Replace `_physics_process` patrol logic with projectile spawn timer
- Keep stomp detection and die/reset methods identical

---

### `scenes/world2/professor_careca.gd` (enemy-hazard, projectile-homing)

**Analog:** NO EXACT MATCH — partial pattern from boss_pai.gd signal handling

**Pattern summary:** Static NPC that spawns homing projectiles periodically. Player cannot stomp it. Projectiles seek player position.

**New pattern (no existing analog in codebase):**
```gdscript
extends StaticBody2D

@export var comment_scene: PackedScene
@export var spawn_rate: float = 2.0

var _is_dead: bool = false
var _spawn_timer: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("hazards")  # Not "enemies" — untouchable
	_spawn_timer = spawn_rate

func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_comment()
		_spawn_timer = spawn_rate

func _spawn_comment() -> void:
	if not comment_scene:
		return
	var comment = comment_scene.instantiate()
	get_parent().add_child(comment)
	comment.global_position = global_position + Vector2(16.0, -16.0)
	comment.target_player = true  # Signal to projectile to seek player

# Professor Careca cannot be killed (untouchable hazard)
func reset_to_origin() -> void:
	# No-op; stays in place
	pass
```

**Homing projectile pattern** (NEW):
```gdscript
# professor_careca_comment.gd
extends Area2D

@export var speed: float = 80.0
@export var despawn_distance: float = 350.0

var _spawned_position: Vector2
var _target: Node2D = null
var target_player: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_spawned_position = global_position

func _physics_process(delta: float) -> void:
	# Lazy-init player reference on first frame
	if not _target and target_player:
		_target = get_tree().first_child_of_type(CharacterBody2D)
	
	if _target:
		# Simple seek towards player
		var direction = (_target.global_position - global_position).normalized()
		position += direction * speed * delta
	
	# Despawn if too far
	if global_position.distance_to(_spawned_position) > despawn_distance:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(global_position)
		queue_free()
```

---

### `scenes/world2/projeto_sketch.gd` (projectile, projectile-linear)

**Analog:** NO EXACT MATCH — new power projectile type

**Pattern summary:** Area2D projectile that travels in a straight line and deals hit-kill on contact with enemies.

**New pattern (inspired by collectible despawn from prova_item.gd):**
```gdscript
extends Area2D

@export var speed: float = 300.0

var _spawned_position: Vector2

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_spawned_position = global_position

func _physics_process(delta: float) -> void:
	# Move in direction velocity is set (by player on spawn)
	position += velocity * delta
	
	# Despawn if too far (screen boundary)
	if global_position.distance_to(_spawned_position) > 500.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	# Hit-kill on enemy
	if body.is_in_group("enemies") and body.has_method("die"):
		body.die()
		queue_free()
	# Pass through player (check collision layer in scene)
	# Hit wall/floor: despawn
	elif body.is_in_group("walls"):
		queue_free()
```

---

### `scenes/world2/tfg_item.gd` (collectible, CRUD)

**Analog:** `scenes/world1/prova_item.gd` (EXACT MATCH)

**Pattern summary:** Area2D collectible that saves item ID to SaveManager on contact.

**Core pattern** (lines 1-27):
```gdscript
extends Area2D

@export var prova_id: String = "prova_foto"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	# Defensive read: use .get() with default to handle missing key
	var provas: Array = SaveManager.current_save.get("provas_mundo1", [])

	# Guard against duplicate collection
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

**Adaptation for tfg_item.gd:**
- Change `prova_id` default from `"prova_foto"` to `"tfg_pesquisa_campo"` (or respective item ID)
- Change SaveManager key from `"provas_mundo1"` to `"itens_tfg_mundo2"`
- Change SFX from `"prova_coletada"` to `"prova_tfg_coletada"` (register new SFX in AudioManager)
- Copy all other patterns (particle effect, hide sprite, despawn timer) exactly

---

### `scenes/world2/renato_cafe_npc.gd` (NPC, event-driven)

**Analog:** `scenes/world1/renato_npc.gd` (EXACT MATCH with healing mechanic)

**Pattern summary:** StaticBody2D NPC with dialogue zone that triggers on player proximity.

**Core pattern** (lines 1-32):
```gdscript
extends StaticBody2D

var _player_in_zone: bool = false

func _ready() -> void:
	# Connect dialogue zone signals
	if has_node("DialogueZone"):
		$DialogueZone.body_entered.connect(_on_dialogue_zone_body_entered)
		$DialogueZone.body_exited.connect(_on_dialogue_zone_body_exited)

func _on_dialogue_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_zone = true
		if has_node("Prompt"):
			$Prompt.visible = true

func _on_dialogue_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_zone = false
		if has_node("Prompt"):
			$Prompt.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if _player_in_zone and event.is_action_pressed("jump"):
		if not ResourceLoader.exists("res://dialogic/timelines/renato_restaurante.dtl"):
			return
		
		Dialogic.start("renato_restaurante")
		get_tree().root.set_input_as_handled()
```

**Adaptation for renato_cafe_npc.gd (Fase 3):**
- Change timeline ID from `"renato_restaurante"` to `"renato_cafe_fase3"`
- Add healing mechanic after dialogue ends:
```gdscript
func _unhandled_input(event: InputEvent) -> void:
	if _player_in_zone and event.is_action_pressed("jump"):
		if not ResourceLoader.exists("res://dialogic/timelines/renato_cafe_fase3.dtl"):
			return
		
		Dialogic.start("renato_cafe_fase3")
		await Dialogic.timeline_ended
		
		# Heal player +1 PV (will implement in player.gd in next pattern)
		var player_ref = get_tree().first_child_of_type(CharacterBody2D)
		if player_ref and player_ref.has_method("heal"):
			player_ref.heal(1)
			AudioManager.play_sfx("checkpoint")  # Healing SFX
		
		get_tree().root.set_input_as_handled()
```

---

### `scenes/world2/world2_end.gd` (scene-controller, request-response)

**Analog:** `scenes/world1/world1_end.gd` (EXACT MATCH)

**Pattern summary:** Placeholder end-screen scene with menu button.

**Core pattern** (lines 1-10):
```gdscript
extends Node2D

func _ready() -> void:
	$MenuButton.pressed.connect(_on_menu_pressed)

func _on_menu_pressed() -> void:
	SceneTransition.go_to("res://scenes/main_menu/main_menu.tscn")
```

**Adaptation for world2_end.gd:**
- Copy pattern exactly (no changes needed)
- Scene should show "Parabéns!" or victory message before menu button

---

### `scenes/player/player.gd` (player-controller, CRUD + powers)

**Analog:** `scenes/player/player.gd` (SELF MODIFICATION — add power system)

**Pattern summary:** Add power usage, cycling, and persistence to existing player movement and damage system.

**New variables to add at top** (after existing state variables, ~line 43):
```gdscript
# Power system (new in Phase 4)
var _current_power: String = ""  # "" = no power
var _power_cooldown: float = 0.0
```

**New input handling in _physics_process** (add after dash input check, ~line 79):
```gdscript
		# Power usage (new)
		if Input.is_action_just_pressed("use_power") and _current_power != "":
			use_power()
		
		# Power cycling (new)
		if Input.is_action_just_pressed("cycle_power"):
			cycle_power()
		
		_power_cooldown -= delta
```

**New power methods to add at end of file** (after _on_animated_sprite_2d_animation_finished):
```gdscript
func use_power() -> void:
	if _power_cooldown > 0.0:
		return
	
	match _current_power:
		"sketch":
			_use_sketch_power()
		"amor":
			_use_amor_power()

func _use_sketch_power() -> void:
	# Spawn projectile in direction facing
	var proj = preload("res://scenes/world2/projeto_sketch.tscn").instantiate()
	get_parent().add_child(proj)
	var offset = 10.0 if not sprite.flip_h else -10.0
	proj.global_position = global_position + Vector2(offset, 0.0)
	proj.velocity.x = 300.0 if not sprite.flip_h else -300.0
	AudioManager.play_sfx("sketch_disparo")
	_power_cooldown = 0.5

func _use_amor_power() -> void:
	# Create invulnerability aura for ~2s
	_is_invincible = true
	# TODO: Spawn visual aura (CPUParticles2D or Area2D circle)
	get_tree().create_timer(2.0, true).timeout.connect(func(): _is_invincible = false, CONNECT_ONE_SHOT)
	AudioManager.play_sfx("amor_ativado")
	_power_cooldown = 4.0

func cycle_power() -> void:
	var unlocked = SaveManager.current_save.get("powers_unlocked", [])
	if unlocked.is_empty():
		return
	
	var current_idx = unlocked.find(_current_power)
	if current_idx == -1:
		current_idx = 0
	else:
		current_idx = (current_idx + 1) % unlocked.size()
	
	_current_power = unlocked[current_idx]
	SaveManager.current_save["active_power"] = _current_power
	SaveManager.save_game()

func unlock_power(power_id: String) -> void:
	var unlocked = SaveManager.current_save.get("powers_unlocked", [])
	if power_id not in unlocked:
		unlocked.append(power_id)
		SaveManager.current_save["powers_unlocked"] = unlocked
	
	# Auto-select if first power
	if _current_power == "":
		_current_power = power_id
		SaveManager.current_save["active_power"] = power_id
	
	SaveManager.save_game()

func heal(amount: int = 1) -> void:
	# Phase 4+: restore health (3 PV max)
	# TODO: Implement when HP system is wired in Phase 4
	pass

func _ready_restore_powers() -> void:
	# Call from _ready() to restore active_power from save
	_current_power = SaveManager.current_save.get("active_power", "")
```

**Also add call in _ready()** (at end of existing _ready logic):
```gdscript
	_current_power = SaveManager.current_save.get("active_power", "")
```

**Key changes:**
- Add `_current_power` and `_power_cooldown` to state tracking
- Wire `use_power` and `cycle_power` input actions in `_physics_process`
- Implement `use_power()`, `_use_sketch_power()`, `_use_amor_power()`, `cycle_power()`, `unlock_power()` methods
- Load `_current_power` from SaveManager on `_ready()`

---

### `autoloads/save_manager.gd` (singleton, data-persistence)

**Analog:** `autoloads/save_manager.gd` (SELF MODIFICATION — schema v2→v3)

**Pattern summary:** Bump schema version, add new keys to default save, handle old save migration.

**Changes needed:**

**Line 4: Bump schema version**
```gdscript
const SCHEMA_VERSION := 3
```

**Lines 18-31: Add migration logic for v2→v3 saves**
```gdscript
func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		current_save = _default_save()
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var data = file.get_var(true)
		
		# Handle v2→v3 migration
		if data is Dictionary and data.get("version", 0) == 2:
			# Upgrade v2 to v3
			data["version"] = 3
			data["active_power"] = ""
			data["itens_tfg_mundo2"] = []
			current_save = data
			save_game()  # Persist the upgraded save
		elif data is Dictionary and data.get("version", 0) == SCHEMA_VERSION:
			current_save = data
		else:
			# Save corrupted or future version
			current_save = _default_save()
	else:
		current_save = _default_save()
```

**Lines 53-61: Update _default_save() with new keys**
```gdscript
func _default_save() -> Dictionary:
	return {
		"version": SCHEMA_VERSION,
		"checkpoint_id": "",
		"worlds_completed": [],
		"powers_unlocked": [],
		"active_power": "",  # NEW in v3
		"seen_cutscenes": {},
		"provas_mundo1": [],
		"itens_tfg_mundo2": [],  # NEW in v3
	}
```

**Key changes:**
- Bump `SCHEMA_VERSION` from 2 to 3
- Add `active_power: String` (default "") to track which power is active
- Add `itens_tfg_mundo2: Array` (default []) to track collected TFG items
- Add v2→v3 migration in `load_game()` to upgrade old saves in-place
- Call `save_game()` after migration to persist upgraded version

---

### `project.godot` (config, input-map)

**Analog:** `project.godot` (SELF MODIFICATION — add new input actions)

**Pattern summary:** Add two new input actions to InputMap for power usage.

**Changes needed:**

Add the following input actions to the `[input]` section (after existing `dash=` entry):

```ini
use_power={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":90,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
, Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":3,"pressure":0.0,"pressed":false,"script":null)
]
}
cycle_power={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":true,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":90,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
, Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":2,"pressure":0.0,"pressed":false,"script":null)
]
}
```

**Key mappings:**
- `use_power`: Z (keyboard), X (gamepad button 3)
- `cycle_power`: Shift+Z (keyboard), Y (gamepad button 2)

---

### `autoloads/audio_manager.gd` (singleton, SFX registry)

**Analog:** `autoloads/audio_manager.gd` (SELF MODIFICATION — register new SFX)

**Pattern summary:** Add new Mundo 2 SFX keys to registration array in `_ready()`.

**Changes needed:**

**Lines 16-23: Expand SFX keys array**
```gdscript
	# Register the 8 Mundo 1 SFX keys + 6 Mundo 2 SFX keys
	var sfx_keys: Array[String] = [
		"jump", "checkpoint", "prova_coletada", "prova_apresentada", 
		"dialogo_errado", "stomp", "dano", "vitoria",
		"prova_tfg_coletada", "qualidade_apresentada", "qualidade_perdida",
		"sketch_disparo", "amor_ativado", "dano_profundo"
	]
	for key: String in sfx_keys:
		var path: String = "res://assets/audio/sfx/" + key + ".wav"
		if ResourceLoader.exists(path):
			var stream: AudioStream = load(path) as AudioStream
			register_sfx(key, stream)
```

**New SFX to register:**
- `prova_tfg_coletada` — TFG item collection (similar tone to prova_coletada)
- `qualidade_apresentada` — Quality bar increases (positive chime)
- `qualidade_perdida` — Quality bar decreases (negative bleep)
- `sketch_disparo` — Sketch power fires (paper whoosh)
- `amor_ativado` — Amor power activates (chime/sparkle)
- `dano_profundo` — Professor's comment hits (impact sound)

---

## Shared Patterns

### Stomp Detection (Double-Stage Guard)
**Source:** `scenes/world1/malandro.gd` (lines 55-72)
**Apply to:** `impressora_raivosa.gd`, any future patrol enemies
```gdscript
# Stage 1: StompZone collider-based detection
func _on_stomp_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.velocity.y >= 0.0 and not _stomped_this_frame:
		_stomped_this_frame = true
		die()
		body.velocity.y = body.jump_velocity * 0.6

# Stage 2: Fallback BodyHitbox center-based detection
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

**Why:** Covers edge case where player center is not clearly above enemy center on first frame. Prevents double-stomp in same frame.

---

### Enemy Reset on Player Death
**Source:** `scenes/world1/fase1_rua.gd` (lines 26-30)
**Apply to:** All phase controllers (`fase1_campus.gd`, `fase2_atelie.gd`, `fase3_madrugada.gd`)
```gdscript
func _reset_enemies() -> void:
	# Restore all enemies to their origin positions
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("reset_to_origin"):
			enemy.reset_to_origin()
```

**Why:** Centralized, group-based reset prevents sync bugs. Single loop instead of manual enemy resets per scene.

---

### Item Persistence with Defensive Read
**Source:** `scenes/world1/prova_item.gd` (lines 10-21)
**Apply to:** `tfg_item.gd`, any future collectibles
```gdscript
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	# Defensive read: use .get() with default to handle missing key
	var items: Array = SaveManager.current_save.get("itens_tfg_mundo2", [])

	# Guard against duplicate collection
	if item_id not in items:
		items.append(item_id)
		SaveManager.current_save["itens_tfg_mundo2"] = items
		SaveManager.save_game()

	AudioManager.play_sfx("prova_tfg_coletada")
	# ... despawn animations ...
```

**Why:** `.get(key, default)` prevents crashes on save version bumps (v2→v3). Duplicate guard prevents over-saving.

---

### Boss Dialogic Signal Handling
**Source:** `scenes/world1/boss_pai.gd` (lines 38-47, 77-86)
**Apply to:** `boss_tfg.gd` and any future boss scenes
```gdscript
# CRITICAL: Connect signal BEFORE starting timeline
if Dialogic.current_timeline != null:
	return

Dialogic.signal_event.connect(_on_dialogic_signal)
Dialogic.start("boss_abertura_tfg")
await Dialogic.timeline_ended
Dialogic.signal_event.disconnect(_on_dialogic_signal)

func _on_dialogic_signal(argument: String) -> void:
	match argument:
		"choice_correct":
			add_quality(10.0)
		"choice_wrong":
			add_quality(-15.0)
			AudioManager.play_sfx("dialogo_errado")
```

**Why:** Signal events fire only if listener is connected BEFORE timeline starts. Prevents race conditions.

---

### Checkpoint One-Shot Activation
**Source:** `scenes/world1/checkpoint.gd` (lines 12-19)
**Apply to:** `checkpoint_cafe.tscn` (no changes needed if reused as-is)
```gdscript
func _on_body_entered(body: Node2D) -> void:
	if _activated:
		return
	if body.is_in_group("player"):
		_activated = true
		SaveManager.set_checkpoint(checkpoint_id)
		AudioManager.play_sfx("checkpoint")
		_play_activate_animation()
```

**Why:** `_activated` flag prevents re-triggering. Ensures +1 PV heals only once per checkpoint visit.

---

### Hit-Stop Pattern (Engine.time_scale)
**Source:** `scenes/player/player.gd` (lines 218-221)
**Apply to:** Any hit/impact feedback in phase bosses or damage events
```gdscript
func _start_hit_stop(frames: int = 3) -> void:
	Engine.time_scale = 0.0
	await get_tree().create_timer(frames / 60.0, true).timeout
	Engine.time_scale = 1.0
```

**Why:** `create_timer(..., true)` with `process_always=true` runs even at time_scale=0. Prevents timer from being paused by hit-stop itself.

---

### Power Unlock Retrofit on Boss Defeat
**Source:** `scenes/world1/boss_pai.gd` (lines 161-191, adapted)
**Apply to:** `boss_tfg.gd` victory path and `boss_pai.gd` modification (retroactive for Amor)
```gdscript
func _trigger_victory() -> void:
	# ... victory animations ...
	
	# Unlock powers retroactively
	var player_ref = player if has_node("Player") else null
	if player_ref and player_ref.has_method("unlock_power"):
		player_ref.unlock_power("sketch")
		player_ref.unlock_power("amor")  # Also unlock Amor at TFG boss for Phase 4 completeness
	
	SaveManager.current_save["worlds_completed"].append("mundo2")
	SaveManager.save_game()
```

**Why:** Centralizes power unlock logic. Retroactively setting `"amor"` in Phase 4's boss_tfg ensures both powers are available after Mundo 2 completion.

---

## No Analog Found

Files with no close match in the codebase (planner should use RESEARCH.md patterns or create from scratch):

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `scenes/world2/professor_careca.gd` | enemy-hazard | projectile-homing | Homing projectile spawner is new in Phase 4; no patrol+projectile combo exists in Phase 3 |
| `scenes/world2/professor_careca_comment.gd` | projectile | homing-seek | Homing AI (simple seek) new; Phase 3 only has static obstacles and patrol enemies |
| `scenes/world2/projeto_sketch.gd` | projectile | linear-travel | Player-spawned projectile power new in Phase 4; no precedent in Phase 1-3 |

All other files have exact analogs (malandro, boss_pai, prova_item, checkpoint, renato_npc, mundo1_abertura, world1_end, fase1_rua) that can be copied/adapted with minor tweaks.

---

## Metadata

**Analog search scope:** `scenes/world1/`, `autoloads/`, `project.godot`
**Files scanned:** 11 source files (malandro, static_obstacle, prova_item, boss_pai, checkpoint, renato_npc, mundo1_abertura, world1_end, fase1_rua, player, save_manager)
**Pattern extraction date:** 2026-06-09
**GDScript version:** Godot 4.4.1+

---

*Phase 4 ready for planning. Planner has all patterns documented and reference code identified.*
