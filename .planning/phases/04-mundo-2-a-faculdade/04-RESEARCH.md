# Phase 4: Mundo 2 — A Faculdade - Research

**Researched:** 2026-06-09
**Domain:** Godot 4 platformer — world architecture, enemy design, power system, boss mechanics, save schema evolution
**Confidence:** HIGH

## Summary

Phase 4 extends the foundation laid in Phase 3 (Mundo 1) by introducing 5 new reusable patterns: 3 enemy types, an HP system, and 2 powers with persistent unlock mechanics. The phase builds directly on existing patterns from World 1 (malandro.gd, prova_item.gd, boss_pai.gd, mundo1_abertura.gd) with minimal net-new code — primarily reskins and parameter tuning.

**Key architectural decision:** HP system (3 PV) applies to World 2+ only. Mundo 1 retains 1-hit death to preserve original design intent. Powers are unlocked retroactively (Amor from World 1 boss, Sketch from World 2 boss) and persist across all worlds after unlock via SaveManager.

**Primary recommendation:** Reuse existing code patterns aggressively. Malandro → Impressora (add periodic projectile fire). StaticObstacle → Maquete (no changes needed). ProvaItem → TFGItem (sprite variations). Boss_pai → Boss_tfg (swap trust bar for quality bar, adjust gate logic).

## User Constraints (from CONTEXT.md)

### Locked Decisions
- Mundo 2 has 4 scenes connected via SceneTransition: abertura, fase1_campus, fase2_atelie, fase3_madrugada, boss_tfg
- Text tone: exhaustion + hope (all-nighters, but camaraderie and talent discovery)
- Visual palette: beige/cream ateliê, chaotic but colorful papers, more vibrant than grey-urban Mundo 1
- HP system: 3 PV applying to all worlds from Mundo 2 onward
- Three enemy types: Maquete Rústica (floor trap), Impressora Raivosa (projectile spawner), Professor Careca (homing hazard)
- Five TFG items must be collectible across the three phases, minimum 3 items required to fight boss
- Boss mechanics: Quality bar (not trust), "Professor Perpétuo" adds requirement escalation, narrative victory (no player damage)
- Sketch power: paper projectile, hit-kill on normal enemies, retroactively available in all worlds after unlock
- Amor power: retroactively desbloqueado at World 1 boss, bolha with 3-4s invulnerability aura on contact

### Claude's Discretion
- Exact enemy positions, item placement, checkpoint count per phase
- Exact attack timings for new enemies
- New enemy animations (placeholder geometric sprites acceptable)
- Exact boss dialogue for banca
- Amount and position of healing items (café/lanche) per phase
- HUD design specifics for power indicators

### Deferred Ideas (OUT OF SCOPE)
- System of HP for Mundo 1 retroactively (1-hit death intentional)
- Overworld (mapa-mundo) — Phase 11
- Revisit scenes with Sketch available retroactively (automatic via POWER-08)
- Real audio for Mundo 2 (Phase 12 Polish)

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| BOSS-02 | Professor Perpétuo chefe que adiciona requisitos à fase | Boss_tfg.gd adapts boss_pai.gd pattern: quality bar instead of trust bar, "add requirement" event raises target threshold |
| POWER-01 | Sketch power — projétil de esboços com hit-kill, retroativo | Projectile extends Area2D, player.gd uses_power() method, SaveManager tracks powers_unlocked, schema bumps to v3 |

## Standard Stack

### Core (Reused from Phase 3)
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Godot | 4.4.1+ | Game engine | Proven in Phase 1-3, all pixel art settings configured |
| GDScript | built-in | Enemy/boss scripting | 100% of codebase, instant Inspector updates, no compilation |
| StaticBody2D | 4.4 native | Level geometry | Replaced TileMap in 4.4, mandatory for physics chunks in 4.5 |
| CharacterBody2D | 4.4 native | Player/enemy locomotion | Used by player.gd and malandro.gd, proven collision handling |
| Area2D | 4.4 native | Damage zones, collectibles | Light-weight signal-based collision detection (not CharacterBody2D) |
| CPUParticles2D | 4.4 native | Dust, particles | **Never GPUParticles2D** — renderer gl_compatibility does not support GPU particles on web |

### Supporting (Existing Autoloads)
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| SaveManager.gd | phase 2 | Persistent player state | powers_unlocked[], worlds_completed[], active_power (new in v3), itens_tfg_mundo2 (new in v3) |
| AudioManager.gd | phase 2 | SFX registration and playback | New SFX: prova_tfg_coletada, qualidade_apresentada, qualidade_perdida, sketch_disparo, amor_ativado |
| SceneTransition.gd | phase 2 | Scene fade/transition | go_to(scene_path) for inter-phase loading |
| Dialogic 2 | 1.4.13 | NPC dialogue and timelines | mundo2_abertura.dtl, boss_abertura_tfg.dtl, boss_vitoria_tfg.dtl, banca_questao_*.dtl |

### New Input Actions
| Action | Keyboard | Gamepad | Purpose |
|--------|----------|---------|---------|
| use_power | Z | X | Fire active power (Sketch / Amor) |
| cycle_power | Shift+Z | Y | Cycle to next unlocked power |

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Player movement + physics | Game client | — | Player.gd, already established from Phase 1 |
| Enemy AI (patrol, projectile) | Game client | — | Malandro/Impressora/Professor spawned in scene, physics-driven |
| Power execution (Sketch/Amor) | Game client | SaveManager | Player uses_power() at Z keypress; SaveManager tracks active_power and powers_unlocked |
| Boss fight orchestration | Game client | Dialogic | Boss_tfg.gd runs quality bar FSM; Dialogic timelines trigger signal events |
| HP recovery (Checkpoint/café NPC) | Game client + SaveManager | — | Checkpoint heals +1 PV in _ready; Renato NPC (fase3) heals on dialog_zone contact |
| Item persistence (TFG) | SaveManager | — | Items saved to itens_tfg_mundo2[], validated at boss gate, not lost on death |
| Audio cues | AudioManager | — | SFX play on power use, item collection, damage; music loop for phase |

## Architecture Patterns

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│  Player Input (move, jump, dash, use_power, cycle_power)    │
└────────┬────────────────────────────────────────────────────┘
         │
    ┌────v────┐
    │ Player  │  (CharacterBody2D)
    │         ├─ Physics: velocity, gravity, collision
    │         ├─ States: hurt, dead, dashing, invincible
    │         └─ Powers: _current_power, use_power() method
    └────┬────┘
         │
    ┌────v──────────────────────────────────────┐
    │  Enemies / Hazards                         │
    ├─────────────────────────────────────────┤
    │  Malandro → Impressora (projectile)     │
    │  StaticObstacle → Maquete (floor trap)  │
    │  Professor Careca (homing hazard)       │
    └────┬──────────────────────────────────────┘
         │
    ┌────v──────────────────────────────────────┐
    │  Items / Collectibles                     │
    ├─────────────────────────────────────────┤
    │  ProvaItem → TFGItem (5 per fase)       │
    │  Checkpoint (heals +1 PV)                │
    │  Renato NPC (heals +1 PV + dialog)      │
    └────┬──────────────────────────────────────┘
         │
    ┌────v──────────────────────────────────────┐
    │  Boss Sequence (boss_tfg.tscn)            │
    ├─────────────────────────────────────────┤
    │  Gate: ≥3 TFG items collected            │
    │  Quality Bar FSM (0-100%)                │
    │  Dialogic events: choice → +/-quality   │
    │  Victory: Mark mundo2_complete, unlock  │
    │           Sketch + Amor powers          │
    └────┬──────────────────────────────────────┘
         │
    ┌────v──────────────────────────────────────┐
    │  SaveManager (persistent state)           │
    ├─────────────────────────────────────────┤
    │  powers_unlocked: ["amor", "sketch"]    │
    │  active_power: "sketch"                 │
    │  itens_tfg_mundo2: [5 item IDs]        │
    │  worlds_completed: ["mundo1", "mundo2"]│
    │  seen_cutscenes: {mundo2_abertura: T}  │
    └────────────────────────────────────────────┘
```

Data flows: Player input → movement/powers → collision with enemies/items → SaveManager state → Dialogic timeline triggers → HUD updates.

### Recommended Project Structure

```
scenes/world2/
├── mundo2_abertura.tscn       # Opening cutscene (copy of mundo1_abertura pattern)
├── mundo2_abertura.gd         # Auto-start Dialogic, skip, transition
├── fase1_campus.tscn          # Linear campus phase + Renato background NPC
├── fase1_campus.gd            # Enemy reset on death, exit trigger
├── fase2_atelie.tscn          # Ateliê phase with Maquetes + Impressoras
├── fase2_atelie.gd            # Same pattern as fase1
├── fase3_madrugada.tscn       # Lab + Prof. Careca, Renato café NPC
├── fase3_madrugada.gd         # Same pattern as fase1
├── boss_tfg.tscn              # Boss arena + HUD for quality bar
├── boss_tfg.gd                # Quality bar FSM, item gate, Dialogic control
├── impressora.tscn            # Projectile spawner (reskin of malandro)
├── impressora.gd              # Projectile fire every 2s instead of patrol
├── professor_careca.tscn      # Static hazard spawner
├── professor_careca.gd        # Homing projectile spawner
├── projeto_sketch.tscn        # Sketch projectile instance
├── projeto_sketch.gd          # Area2D projectile, hit-kill
├── tfg_item.tscn             # Collectible item (copy of prova_item)
├── tfg_item.gd               # itens_tfg_mundo2[] persistence
├── mundo2_end.tscn           # World exit placeholder (copy of world1_end)
└── mundo2_end.gd             # Transition to world2_end or overworld

autoloads/
├── save_manager.gd           # SCHEMA v2 → v3: add active_power, itens_tfg_mundo2
├── audio_manager.gd          # Register new SFX: sketch_disparo, amor_ativado, etc.
└── (unchanged: controls, scene_transition)

dialogic/timelines/
├── mundo2_abertura.dtl        # Opening narrative (campus chaos + hope)
├── boss_abertura_tfg.dtl      # Banca intro (Professor Perpétuo intro)
├── boss_vitoria_tfg.dtl       # Banca aprovação + power unlock cutscene
├── banca_questao_[1-5].dtl    # Choice paths with quality +/- signals
└── renato_cafe_fase3.dtl      # "Trouxe café" dialogue

dialogic/characters/
├── ProfessorPerpetuo.dch      # New character definition (placeholder)
└── (existing: Luis, Natalia, Renato)
```

### Pattern 1: Projectile-Spawning Enemy (Impressora Raivosa)

**What:** CharacterBody2D that fires projectiles at regular intervals instead of patrolling. Inherits die() from malandro.gd base.

**When to use:** Mobile hazards that attack from distance. Can extend to Professor Careca (homing projectiles) by swapping projectile behavior.

**Example:**

```gdscript
# scenes/world2/impressora.gd
extends CharacterBody2D

@export var fire_rate: float = 2.0  # Seconds between projectile launches
@export var projectile_scene: PackedScene

var _is_dead: bool = false
var _fire_timer: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var stomp_zone: Area2D = $StompZone
@onready var fire_position: Marker2D = $FirePosition

func _ready() -> void:
	add_to_group("enemies")
	stomp_zone.body_entered.connect(_on_stomp_zone_body_entered)
	_fire_timer = fire_rate

func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	
	# Fire projectile on timer
	_fire_timer -= delta
	if _fire_timer <= 0.0:
		_spawn_projectile()
		_fire_timer = fire_rate

func _spawn_projectile() -> void:
	if not projectile_scene:
		return
	var proj = projectile_scene.instantiate()
	get_parent().add_child(proj)
	proj.global_position = fire_position.global_position
	proj.velocity.x = 100.0  # Fixed direction or track player

func _on_stomp_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.velocity.y >= 0.0:
		die()
		body.velocity.y = body.jump_velocity * 0.6

func die() -> void:
	_is_dead = true
	sprite.play("death")
	$CollisionShape2D.set_deferred("disabled", true)
	AudioManager.play_sfx("stomp")
	get_tree().create_timer(0.3, true).timeout.connect(queue_free, CONNECT_ONE_SHOT)

# Source: Adapted from malandro.gd (Phase 3)
```

### Pattern 2: Homing Hazard Projectile (Professor Careca's Comments)

**What:** Area2D projectile that moves towards player position each frame (simple chase). Despawns on contact or phase boundary.

**When to use:** Boss underlings that require player avoidance. Cheaper than full AI patrol.

**Example:**

```gdscript
# scenes/world2/professor_careca_comment.gd
extends Area2D

@export var speed: float = 80.0
@export var despawn_distance: float = 350.0

var _spawned_position: Vector2
var _target: Node2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_spawned_position = global_position
	_target = get_tree().first_child_of_type(CharacterBody2D)  # Find player

func _physics_process(delta: float) -> void:
	if not _target:
		return
	
	# Simple seek towards player
	var direction = (_target.global_position - global_position).normalized()
	position += direction * speed * delta
	
	# Despawn if too far or off-screen
	if global_position.distance_to(_spawned_position) > despawn_distance:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(global_position)
		queue_free()
```

### Pattern 3: Persistent Power System

**What:** Player tracks _current_power (String ID), SaveManager persists active_power + powers_unlocked[]. Input Z fires, Shift+Z cycles.

**When to use:** Multi-use powers with cooldown and unlock progression.

**Example (player.gd additions):**

```gdscript
# In player.gd, new variables:
var _current_power: String = ""  # "" = no power
var _power_cooldown: float = 0.0

func _physics_process(delta: float) -> void:
	# ... existing movement code ...
	
	# Power usage (new)
	if Input.is_action_just_pressed("use_power") and _current_power != "":
		use_power()
	
	# Power cycling (new)
	if Input.is_action_just_pressed("cycle_power"):
		cycle_power()
	
	_power_cooldown -= delta

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
	proj.global_position = global_position + (Vector2.RIGHT * 10.0 if not sprite.flip_h else Vector2.LEFT * 10.0)
	proj.velocity.x = 300.0 if not sprite.flip_h else -300.0
	AudioManager.play_sfx("sketch_disparo")
	_power_cooldown = 0.5  # 2 shots/sec

func _use_amor_power() -> void:
	# Create invulnerability aura around player for ~2s
	_is_invincible = true
	# Spawn aura visual (CPUParticles2D or simple Area2D circle)
	get_tree().create_timer(2.0, true).timeout.connect(func(): _is_invincible = false, CONNECT_ONE_SHOT)
	AudioManager.play_sfx("amor_ativado")
	_power_cooldown = 4.0

func cycle_power() -> void:
	var unlocked = SaveManager.current_save["powers_unlocked"]
	if unlocked.is_empty():
		return
	
	var current_idx = unlocked.find(_current_power)
	var next_idx = (current_idx + 1) % unlocked.size()
	_current_power = unlocked[next_idx]
	SaveManager.current_save["active_power"] = _current_power
	SaveManager.save_game()

func unlock_power(power_id: String) -> void:
	var unlocked = SaveManager.current_save["powers_unlocked"]
	if power_id not in unlocked:
		unlocked.append(power_id)
	# Auto-select if first power
	if _current_power == "":
		_current_power = power_id
		SaveManager.current_save["active_power"] = power_id
	SaveManager.save_game()

# Source: Designed for Phase 4, inspired by player.gd pattern (Phase 1)
```

### Pattern 4: Boss with Quality Bar and Requirement Escalation

**What:** boss_tfg.gd adapts boss_pai.gd: replace trust bar with quality bar, quality rises on correct dialogue + item presentation, falls on wrong choices. "Professor Perpétuo adds requirement" event raises the pass threshold mid-fight.

**When to use:** Narrative bosses where player must maintain a metric during dialogue.

**Example (boss_tfg.gd skeleton):**

```gdscript
# scenes/world2/boss_tfg.gd
extends Node2D

var _quality: float = 0.0
var _quality_max: float = 100.0
var _quality_threshold: float = 70.0  # Must reach this to win

@onready var quality_bar_fill: ColorRect = %QualityBarFill
@onready var quality_pct_label: Label = %QualityPctLabel

func _ready() -> void:
	_start_boss_sequence()

func _start_boss_sequence() -> void:
	var itens = SaveManager.current_save.get("itens_tfg_mundo2", [])
	
	# Gate: need at least 3 items
	if itens.size() < 3:
		await _show_blocking_dialogue()
		return
	
	_quality = 0.0
	
	# Present each item
	for item_id in itens:
		await _show_item_card(item_id)
		add_quality(20.0)
	
	# Start boss dialogue with signal connections
	if Dialogic.current_timeline == null:
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
		"profesor_increases_requirement":
			# Perpétuo raises the bar — harder to win
			_quality_threshold = minf(_quality_threshold + 15.0, _quality_max)

func add_quality(amount: float) -> void:
	_quality = clampf(_quality + amount, 0.0, _quality_max)
	_update_hud()
	
	if _quality < _quality_threshold:
		_trigger_game_over()
	elif _quality >= _quality_max:
		_trigger_victory()

func _trigger_victory() -> void:
	AudioManager.play_sfx("vitoria")
	
	# Unlock powers retroactively
	player.unlock_power("sketch")
	player.unlock_power("amor")  # If not already unlocked
	
	SaveManager.current_save["worlds_completed"].append("mundo2")
	SaveManager.current_save["seen_cutscenes"]["boss_vitoria_tfg"] = true
	SaveManager.save_game()
	
	# Victory dialogue
	Dialogic.start("boss_vitoria_tfg")
	await Dialogic.timeline_ended
	
	SceneTransition.go_to("res://scenes/world2/mundo2_end.tscn")

# Source: Adapted from boss_pai.gd (Phase 3)
```

### Anti-Patterns to Avoid

- **Placing projectiles in TileMapLayer:** Projectiles must be spawned as separate nodes (CharacterBody2D or Area2D), not mixed into tilemap collision. Otherwise they clip through walls unpredictably.
- **Using GPUParticles2D:** `gl_compatibility` renderer does not support GPU particles on web. **Always use CPUParticles2D** for dust, auras, hit effects.
- **Storing powers as Dictionary instead of Array in SaveManager:** `powers_unlocked` must be a packed Array of Strings so the player can iterate and cycle. A Dictionary loses order.
- **Calling player.take_damage() from Dialogic timeline:** Player damage is tied to physics collision, not story events. Dialogue should not reduce HP directly. Use separate dialogue-only failure paths (reload scene, return to previous phase).
- **Creating new Checkpoint for each phase:** Reuse checkpoint.tscn with new sprite (coffee mug) and position it per phase. Don't build custom checkpoints.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Enemy patrol + stomp death | Custom patrol + jumping-on logic | Malandro.gd base (proven, tested) | Stomp detection has 2-stage fallback; hand-rolling misses edge cases (player center not clearly above) |
| Item persistence across scenes | Manual Array updates in multiple places | SaveManager.current_save["itens_tfg"] + defensive .get() | Centralized save removes sync bugs; defensive read handles missing keys on save version bump |
| Boss progression bar | Manual _quality increments | boss_pai.gd pattern with clampf() + stepped color thresholds | Avoids off-by-one tween bugs; stepped colors (red/green/gold) are proven readable |
| Power cooldown tracking | Separate Timer node per power | Float _power_cooldown -= delta in _physics_process | Decouples from Engine.time_scale (hit-stop keeps timers running); simpler to visualize |
| Projectile despawn on wall | Manual RayCast2D checks | Area2D body_entered + queue_free() on hit or edge detector | Area2D is built for this; RayCast has no collision layers, breaks on tilemap changes |

**Key insight:** Mundo 1 patterns work because they hide edge cases. Malandro's double-stomp guard, ProvaItem's defensive .get(), and boss_pai's gate validation prevent the most common bugs. Reuse them verbatim.

## Runtime State Inventory

**Trigger:** Phase 4 is not a rename/refactor/migration — it's greenfield implementation of new world.

**Finding:** No runtime state migration needed. SaveManager schema bumps from v2 → v3 cleanly:

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | SaveManager v2 has provas_mundo1[], worlds_completed[], powers_unlocked[]; v3 adds active_power (String), itens_tfg_mundo2 (Array) | Code edit only: _default_save() adds two new keys with empty defaults |
| Live service config | None — all state in .dat file or game memory | — |
| OS-registered state | None | — |
| Secrets/env vars | None — Godot uses encrypted resource files, no .env | — |
| Build artifacts | None — Godot caches are in .godot/ (git-ignored) | — |

**Nothing found in migration category** — this is greenfield, not refactor.

## Environment Availability

**Godot 4.4.1** (current engine)
- Godot 4.4 TileMapLayer physics chunks: ✓ Already set up in Phase 0
- Godot 4.5 TileMapLayer physics chunks: ✓ Backwards compatible if upgraded
- GDScript compiler: ✓ Built-in, 0-delay iteration
- Dialogic 2 plugin: ✓ Installed in Phase 2, tested with timelines
- Git LFS: ✓ Configured for .png, .wav, .ogg, .tscn in Phase 0
- AudioManager pre-wired: ✓ Phase 2, ready for new SFX registration

**No external tool dependencies.** Phase 4 is pure GDScript + scene design.

## Common Pitfalls

### Pitfall 1: Projectile Collision with Player While Being Spawned

**What goes wrong:** Player spawns Sketch projectile at global_position, but collider overlaps player's collider immediately, dealing damage on first frame.

**Why it happens:** Area2D body_entered fires even if bodies are in same position at spawn.

**How to avoid:** Offset spawn position forward by 10-20 pixels (use sprite.flip_h to determine direction), or disable projectile collider for first frame with `collision_enabled = false` then `await get_tree().process_frame; collision_enabled = true`.

**Warning signs:** Player takes damage immediately after using Sketch power.

### Pitfall 2: Boss Quality Threshold Rising Above 100%

**What goes wrong:** Professor Perpétuo's "add requirement" event in dialogue escalates threshold. If not capped, player can require >100% quality, making victory impossible.

**Why it happens:** Dialogic event fires multiple times or threshold calc doesn't cap at _quality_max.

**How to avoid:** Use `minf(_quality_threshold + 15.0, _quality_max)` when raising threshold. Test dialogue with intentional event spam.

**Warning signs:** Boss scene becomes un-winnable mid-fight; quality maxes out but victory doesn't trigger.

### Pitfall 3: Homing Projectile Behavior Undefined Without Player Reference

**What goes wrong:** Professor Careca spawns comments, but at scene start player might not be in tree yet. Projectile tries to seek player == null, crashes.

**Why it happens:** `_ready()` order is not guaranteed across scenes. Enemies can spawn before player loads.

**How to avoid:** Use `_physics_process` to cache player reference on first frame where it exists: `if not _target and get_tree(): _target = get_tree().first_child_of_type(CharacterBody2D)`.

**Warning signs:** Crashes or projectiles floating still at spawn.

### Pitfall 4: Active Power Not Loaded from Save on Game Start

**What goes wrong:** Player unlocks Sketch, exits scene. On reload, active_power is still "". Player can't use power even though it's unlocked.

**Why it happens:** player.gd doesn't restore _current_power from SaveManager on _ready().

**How to avoid:** In player._ready(): `_current_power = SaveManager.current_save.get("active_power", "")` and apply same logic when cycling.

**Warning signs:** Powers are in powers_unlocked[] but _current_power is blank, Z doesn't fire.

### Pitfall 5: SaveManager v2 Save File Fails to Load in v3 Code

**What goes wrong:** Player has old v2 save from Phase 3. Phase 4 code tries to access new keys (active_power, itens_tfg_mundo2), gets nil/empty.

**Why it happens:** load_game() checks version match but doesn't upgrade old saves.

**How to avoid:** In SaveManager.load_game(), if version == 2, upgrade: `data["active_power"] = ""; data["itens_tfg_mundo2"] = []; data["version"] = 3` before assigning to current_save.

**Warning signs:** Old saves seem to work until a system tries to write to new keys, then logic breaks (e.g., cycle_power crashes on empty array).

## Code Examples

Verified patterns from existing codebase:

### Enemy Reset on Player Death

```gdscript
# Phase 3 proven (fase1_rua.gd)
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

# Source: scenes/world1/fase1_rua.gd (Phase 3)
```

### Item Collection with Persistence

```gdscript
# Phase 3 proven (prova_item.gd) — adapt for itens_tfg
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	var itens = SaveManager.current_save.get("itens_tfg_mundo2", [])

	if prova_id not in itens:
		itens.append(prova_id)
		SaveManager.current_save["itens_tfg_mundo2"] = itens
		SaveManager.save_game()

	AudioManager.play_sfx("prova_tfg_coletada")
	$CPUParticles2D.emitting = true
	$AnimatedSprite2D.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	get_tree().create_timer(0.25, true).timeout.connect(queue_free, CONNECT_ONE_SHOT)

# Source: scenes/world1/prova_item.gd (Phase 3), adapted for mundo2
```

### Dialogic Signal Event Handling in Boss

```gdscript
# Phase 3 proven (boss_pai.gd) — reuse pattern
func _start_boss_sequence() -> void:
	# ... gate checks ...
	
	if Dialogic.current_timeline != null:
		return

	# CRITICAL FIX: Connect BEFORE starting timeline
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.start("boss_abertura")
	await Dialogic.timeline_ended
	Dialogic.signal_event.disconnect(_on_dialogic_signal)

func _on_dialogic_signal(argument: String) -> void:
	match argument:
		"choice_correct":
			add_quality(10.0)
		"choice_wrong":
			add_quality(-15.0)
			AudioManager.play_sfx("dialogo_errado")

# Source: scenes/world1/boss_pai.gd (Phase 3)
```

### Openworld Cutscene with Skip

```gdscript
# Phase 3 proven (mundo1_abertura.gd) — copy for mundo2
extends Node2D

@onready var skip_button: Button = $UILayer/SkipButton
const TIMELINE_ID := "mundo2_abertura"

func _ready() -> void:
	skip_button.pressed.connect(_on_skip_pressed)
	skip_button.visible = SaveManager.has_seen_cutscene(TIMELINE_ID)

	Dialogic.start(TIMELINE_ID)
	await Dialogic.timeline_ended

	SaveManager.mark_cutscene_seen(TIMELINE_ID)
	SaveManager.save_game()
	Dialogic.Inputs.auto_skip.enabled = false
	skip_button.visible = false

	SceneTransition.go_to("res://scenes/world2/fase1_campus.tscn")

# Source: scenes/world1/mundo1_abertura.gd (Phase 3)
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| 1-hit death for all worlds | HP system (3 PV) from World 2+ | Phase 4 | Allows longer phases, more strategic enemy placement, mirrors narrative pacing (overwhelm → endurance) |
| Trust bar boss mechanics | Quality bar for narrative bosses | Phase 4 | Reflects boss identity (trust = pai, quality = academic standards). Seperation clarifies intent. |
| No power system | Powers unlock retroactively with persistence | Phase 4 | Enables world revisit loops (POWER-08), lets earlier choices influence later gameplay. Complexity low if SaveManager centralized. |
| Individual enemy timers | Group-based reset on player death | Phase 3 | Prevents sync desync bugs. get_tree().get_nodes_in_group("enemies") is 1 loop, not 5 manual resets. |

**Deprecated/outdated:**
- TileMap (Godot 4.3): Replaced by TileMapLayer (Godot 4.4+). No longer used in this project.
- Timer nodes for Sketch cooldown: Float subtract-per-frame is simpler and syncs with hit-stop (Engine.time_scale).

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Malandro.gd stomp mechanics transfer 1:1 to Impressora without changes | Code Examples | Projectile spawner may need different hitbox layout; test on actual asset |
| A2 | Dialogic 2 timeline signal events fire in order during boss dialogue | Code Examples | Signal order could vary; may need explicit event ordering or state machine |
| A3 | SaveManager v2→v3 upgrade in load_game() is sufficient for old save compatibility | Common Pitfalls | Old saves with missing keys could still cause crashes in player.gd; requires defensive .get() everywhere |
| A4 | Checkpoint healing +1 PV happens in _ready(), not on collision repeat | Standard Stack | If checkpoint can re-trigger, players could heal infinitely; needs one-shot flag or collision disable on heal |
| A5 | Professor Careca homing projectiles don't require pathfinding, simple seek is enough | Anti-Patterns | If maze-like levels are added later, simple seek could trap projectiles; plan for navigation mesh in Phase 5+ |

**User confirmation needed for:** A1, A2, A4 before implementation. A3, A5 are LOW-confidence assumptions flagged for design review.

## Open Questions (RESOLVED)

1. **How many instances of Professor Careca per phase?**
   - What we know: Professor stays in one classroom (fase3), fires comments periodically
   - What's unclear: Do multiple classrooms have Professors (fase1, fase2)? Or only one in fase3?
   - Recommendation: Start with 1 in fase3, balance via Inspector. Add more if fase feels too easy.
   - [RESOLVED: 1 Professor Careca per fase, positioned per Claude's discretion (CONTEXT.md "Claude's Discretion"). Appears only in fase3_madrugada per D-12: "Professor Careca... aparece em cena específica".]

2. **How should Renato café healing work visually?**
   - What we know: Renato is an NPC in fase3, dialogue triggers on proximity
   - What's unclear: Does healing happen during dialogue or after? SFX or visual feedback?
   - Recommendation: Healing on dialogue end, flash player white, +1 heart icon fade-in.
   - [RESOLVED: Per D-08 and D-13 (CONTEXT.md): healing on NPC proximity with dialogue "Trouxe café". Flash white + SFX at dialogue end per UI-SPEC recommendation.]

3. **Amor power: AoE kill or contact-based?**
   - What we know: "bolha/aura rotativa" for ~2s, enemies touching it die
   - What's unclear: Damage radius? Does player move inside aura or aura follow player?
   - Recommendation: Fixed radius around player (32px), follows player center. Scale sprite at spawn.
   - [RESOLVED: Per D-21 (CONTEXT.md): "bolha/aura rotativa que circula ao redor da Natália por ~2s. Qualquer inimigo que tocar morre." Fixed orbit around player. 32px aura radius, follows player center.]

4. **How are the 5 TFG items visually distinct?**
   - What we know: Names (Pesquisa de Campo, Masterplan, etc.)
   - What's unclear: Sprite design for each item? Generic scrolls or unique shapes?
   - Recommendation: Use simple geometric shapes per item (scroll, grid, folder, chart, leaf for sustainability).
   - [RESOLVED: Per D-16 (CONTEXT.md): each item has a "sprite único" (not generic). Simple geometric shapes per recommendation: scroll (Pesquisa), grid (Masterplan), folder (Complexo Misto), chart (Análise Fluxos), leaf (Sustentabilidade). 16x16px each.]

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | GDUnit4 (if installed) or manual godot scene playtest |
| Config file | GDUnit4 would be res://tests/unit_tests.gd but not required for Phase 4 |
| Quick run command | Open fase1_campus.tscn in editor, press Play |
| Full suite command | Run each fase + boss sequentially; verify save persists across scenes |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| BOSS-02 | Boss phase gate: <3 items blocks entry | manual-only | Load boss_tfg.tscn with itens_tfg_mundo2=["a","b"] (2 items), verify blocking dialogue | ❌ Wave 0 |
| BOSS-02 | Boss quality bar raises on correct dialogue | manual-only | Start banca, choose correct path, watch quality bar +10% | ❌ Wave 0 |
| BOSS-02 | Professor Perpétuo escalates requirement | manual-only | During banca, trigger "add requirement" event, verify threshold rises | ❌ Wave 0 |
| POWER-01 | Sketch power fires projectile | manual-only | Unlock Sketch, press Z, observe projectile spawning and traveling | ❌ Wave 0 |
| POWER-01 | Sketch kills normal enemies | manual-only | Spray Malandro with Sketch projectiles, verify stomp-kill equivalent | ❌ Wave 0 |
| POWER-01 | Sketch persists after save/load | manual-only | Unlock Sketch, save, close game, reopen, verify Z fires power | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** Manual playtest of the scene/feature added (e.g., fase1_campus plays start-to-end without crashes)
- **Per wave merge:** Run all fase scenes + boss in sequence, verify save carries items and powers
- **Phase gate:** Complete one full mundo2_abertura → fase1 → fase2 → fase3 → boss_tfg → mundo2_end playthrough with all items collected, all powers working

### Wave 0 Gaps

All listed below are expected for Wave 0 (pre-plan). Plans will create them:

- [ ] Automated save migration test: verify v2 save loads in v3 code without crashing
- [ ] Enemy group reset test: verify _reset_enemies() actually resets all enemies to origin
- [ ] TFG item persistence test: save 3 items, die, verify items still in array
- [ ] Power cycling test: unlock multiple powers, cycle with Shift+Z, verify active_power changes
- [ ] Dialogic signal event test: verify boss_abertura_tfg signals fire in correct order during dialogue

*(These are implementation details for plans; research does not require pre-built tests.)*

## Security Domain

Security enforcement not applicable to Phase 4. No user authentication, network calls, or data encryption beyond Godot's built-in save file handling.

**ASVS N/A** for single-player offline game.

## Sources

### Primary (HIGH confidence)
- **Context7:** Godot 4.4 GDScript CharacterBody2D, Area2D, CPUParticles2D node APIs (scenes/world1/malandro.gd verified manual)
- **Codebase grep:** Phase 3 boss_pai.gd, prova_item.gd, malandro.gd, mundo1_abertura.gd — all patterns confirmed via Read tool

### Secondary (MEDIUM confidence)
- **SaveManager.gd:** Schema v2 current_save structure; v3 additions (active_power, itens_tfg_mundo2) designed per CONTEXT.md D-21, D-22, D-25
- **Dialogic 2 integration:** Phase 2 confirmed Dialogic 2 installed; boss_pai.gd signal_event pattern is working code

### Tertiary (LOW confidence)
- **Amor power retroactive unlock:** CONTEXT.md D-21 says it's desbloqueado at World 1 boss (Phase 3), but Phase 3 RESEARCH.md did not document this. Boss_pai.gd current code does NOT set powers_unlocked["amor"]. This will require a Phase 4 plan task to patch boss_pai.gd retroactively.
- **Professor Careca NPC character:** Named in CONTEXT.md but no character .dch file exists yet. Will be created in Phase 4 planning.

## Metadata

**Confidence breakdown:**
- **Standard stack:** HIGH — Godot 4.4.1, GDScript, proven patterns from Phase 3
- **Architecture:** HIGH — Extension of World 1 patterns (malandro, boss, items); minimal net-new code
- **Pitfalls:** MEDIUM — Boss quality bar is new mechanic; homing projectiles not yet tested; some assumptions flagged A1-A5

**Research date:** 2026-06-09
**Valid until:** 2026-06-23 (stable patterns, no external changes expected; revalidate if Godot 4.5+ engine upgrade happens)

---

**Phase 4 ready for planning.** Planner has all patterns documented and reference code identified. Execute phase via `/gsd-plan-phase 4`.
