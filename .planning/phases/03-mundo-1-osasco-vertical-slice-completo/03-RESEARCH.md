# Phase 3: Mundo 1 — Osasco (vertical slice completo) - Research

**Researched:** 2026-06-08
**Domain:** Godot 4 platformer level design, enemy AI, save/respawn, Dialogic 2 boss integration, AudioStreamPlayer SFX, TileMapLayer
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Estrutura das Fases (WORLD-01, WORLD-02)**
- D-01: 4 scenes separadas: `scenes/world1/fase1_rua.tscn`, `fase2_parque.tscn`, `fase3_restaurante.tscn`, `boss_pai.tscn`. Carregadas via `SceneTransition.go_to()`.
- D-02: Texto narrativo de abertura via Dialogic antes da Fase 1 (scene `mundo1_abertura.tscn`). Chamado a partir do menu principal após New Game / Continue.
- D-03: Paleta: base `#1A1A2E` com acentos laranja (`#E07020`) e vermelho quente (`#C83030`) para interativos, NPCs e checkpoints.

**Combate com Inimigos (WORLD-01, WORLD-02)**
- D-04: Pulo em cima = mata instantaneamente (Mario-style). Aproveita física existente de `player.gd`.
- D-05: Contato lateral com inimigo = toma dano + knockback via `take_damage()`. Sem dano de retorno ao inimigo no contato lateral.
- D-06: Malandro = CharacterBody2D patrulhando horizontal. Obstáculo estático = Area2D causando dano por contato.
- D-07: Ao morrer, inimigos resetam para posições originais junto com respawn no checkpoint.

**Checkpoints (WORLD-03, WORLD-05)**
- D-08: Visual: cartaz/logo McFly. Ao ativar (player passa), pulsa/brilha. Presente em todas as 4 cenas.
- D-09: 1 checkpoint por fase. Total: 4 checkpoints no Mundo 1.
- D-10: Respawn < 500ms via `SceneTransition` ou respawn direto. Provas já coletadas permanecem (salvas no SaveManager ao coletar).
- D-11: `checkpoint_id` format: `"mundo1_fase{N}_cp1"`.

**Sistema de Provas (BOSS-01)**
- D-12: Provas = Area2D coletáveis (foto, carta, presente) nas Fases 1-3. Player coleta por contato. Glow com CPUParticles2D.
- D-13: Mínimo 2 provas obrigatórias para boss. 1 extra opcional.
- D-14: Inventário de provas não aparece nas fases — só na cena do boss.
- D-15: Salvas em `SaveManager.current_save["provas_mundo1"]` (array de IDs). Não se perdem com morte.

**Boss: O Pai Desconfiante (BOSS-01)**
- D-16: Luis (nome real). Sprite 32x48 + Dialogic sobrepostos.
- D-17: Mecânica: provas (+20% cada) + respostas certas (+10%) / erradas (-15%) → barra de confiança.
- D-18: Fase de boss puramente narrativa — sem dano físico à Natália.
- D-19: Trust bar HUD (CanvasLayer layer=51, acima do Dialogic layer=50).
- D-20: Barra esvazia = game over → volta ao último checkpoint boss (provas mantidas).
- D-21: 100% = vitória. Renato entra em cena ~80%.
- D-22: Cenário: sala de estar, trilha própria placeholder.
- D-23: Luis foreshadowing em fase3_restaurante (background, sem interação).

**NPC Renato (NPC-01)**
- D-24: Renato em: Fase 2 (bg, sem diálogo), Fase 3 (diálogo ativo via Dialogic), Boss ~80% (prova definitiva).
- D-25: Reutiliza `assets/sprites/portraits/renato_portrait.png` (64×80).

**SFX (AUDIO-02)**
- D-26: Placeholder bfxr/sfxr (chiptune). SFX reais na Phase 12.
- D-27: SFX necessários: pulo (verificar existência), dano, checkpoint, morte, coleta de prova, stomp, beep de diálogo. Trilhas: placeholder .ogg silenciosos.

### Claude's Discretion
- Quantidade de malandros e obstáculos por fase (dificuldade)
- Posicionamento preciso de checkpoints, provas e inimigos
- Implementação do tileset (TileMapLayer com tiles placeholder geométricos)
- Duração e velocidade das animações do boss sprite
- Mecânica de apresentação de provas no boss (automático ao entrar na cena — conforme UI-SPEC)

### Deferred Ideas (OUT OF SCOPE)
- Fase da Casa com orçamento (Sims/Stardew) — mundo futuro pós-casamento
- Sprites definitivos de inimigos — Phase 12
- Trilha sonora temática — Phase 12
- SFX reais do Freesound.org — Phase 12
- Prompts de botão por marca (DualSense/Xbox) — Phase 12
- Tileset visual detalhado de Osasco — Phase 12

</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| WORLD-01 | 8 mundos com cenários temáticos únicos e paleta de cores própria | TileMapLayer com paleta `#1A1A2E`/laranja/vermelho; inimigos temáticos Malandro + Obstacle |
| WORLD-02 | Cada mundo tem 2-3 fases lineares + 1 fase de chefe | 4 scenes: fase1_rua, fase2_parque, fase3_restaurante, boss_pai; lineares via SceneTransition |
| WORLD-03 | Cada fase tem checkpoints visuais | Area2D checkpoint com AnimatedSprite2D McFly + SaveManager.set_checkpoint() |
| WORLD-05 | Respawn instantâneo (< 500ms) no checkpoint mais próximo | Respawn direto via `get_tree().reload_current_scene()` + posição gravada; sem fade = < 100ms |
| BOSS-01 | O Pai Desconfiante — chefe de diálogo com condição de vitória não-violenta | Trust bar CanvasLayer + Dialogic timelines; provas array verificado na entrada da scene |
| NPC-01 | Renato como NPC companheiro em pontos específicos | Sprite2D (Fase 2 bg), StaticBody2D + dialogue trigger (Fase 3), instância dinâmica (boss) |
| NARR-05 | Texto narrativo de abertura de cada mundo | mundo1_abertura.tscn com Dialogic.start("mundo1_abertura") → SceneTransition.go_to(fase1) |
| AUDIO-02 | SFX para pulo, dash, ataque, dano, checkpoint, morte, power-up, diálogo | AudioStreamPlayer em AudioManager autoload; WAV para SFX; OGG para música |
</phase_requirements>

---

## Summary

Phase 3 constrói sobre a infraestrutura completa das Phases 0-2 para entregar o primeiro mundo jogável end-to-end. O desafio central é a **quantidade de sistemas novos que se integram simultaneamente**: inimigos com IA de patrulha, checkpoints com persistência de estado, sistema de provas coletáveis, boss com mecânica de confiança via Dialogic, e SFX em pontos específicos do gameplay.

A boa notícia é que o codebase existente já entrega o que seria mais difícil de implementar do zero. O `player.gd` tem `take_damage()` completo com knockback, `velocity.y` para detecção de stomp, e `die()` stub explicitamente comentado "Phase 3 will wire real death/respawn logic". O `SaveManager` tem `set_checkpoint()` e a estrutura do `current_save` dict precisa apenas de uma nova chave `"provas_mundo1"`. O `SceneTransition.go_to()` faz fade in/out em 0.6s total — para respawn < 500ms é necessário uma rota de respawn direta sem SceneTransition (reload de cena + posicionamento).

O único sistema de infraestrutura **ausente** que Phase 3 necessita é um **AudioManager** para tocar SFX e música. Deve ser criado como autoload simples antes ou junto com os primeiros tasks de gameplay.

**Primary recommendation:** Estruturar a fase em 4 waves: (1) AudioManager + estrutura de cenas/tileset, (2) inimigos + checkpoints + respawn + provas, (3) boss + NPC Renato + Dialogic timelines, (4) abertura narrativa + integração main_menu + SFX final.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Tilemap / Level geometry | Scene (TileMapLayer) | — | Cada fase tem seu próprio layout; TileMapLayer por fase, não compartilhado |
| Player physics / stomp detection | Player scene (player.gd) | Enemy (morte ao ser stompado) | player.gd já tem velocity.y; inimigo apenas reage à colisão pelo topo |
| Enemy patrol AI | Enemy scene (malandro.gd) | TileMapLayer (borda para virar) | Responsabilidade do nó inimigo; usa RayCast2D ou wall/floor detection |
| Checkpoint state | Autoload (SaveManager) | Checkpoint scene (trigger) | SaveManager persiste; checkpoint apenas dispara set_checkpoint() |
| Respawn logic | Scene script (fase_N.gd) | Autoload (SaveManager) | Cada cena sabe onde o checkpoint está; SaveManager guarda qual checkpoint está ativo |
| Prova collectible | Prova scene (prova_item.gd) | Autoload (SaveManager) | Prova remove a si mesma e notifica SaveManager; estado persiste no save |
| Boss trust mechanics | Boss scene (boss_pai.gd) | Dialogic (diálogo) | boss_pai.gd gerencia a barra; Dialogic gerencia o fluxo de texto e choices |
| SFX / Music | Autoload (AudioManager) | Game objects (trigger) | AudioStreamPlayer centralizado evita duplicação; objetos chamam AudioManager.play_sfx() |
| Narrative opening | Scene (mundo1_abertura.tscn) | Main menu (trigger) | Cena dedicada evita poluir a fase1; menu chama SceneTransition.go_to() para ela |
| NPC Renato in-scene | NPC scene / Node2D inline | Dialogic (diálogo) | Sprite simples inline nas cenas; diálogo disparado por Area2D de proximidade |

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Godot 4 CharacterBody2D | built-in (4.4.1) | Inimigo Malandro com física e colisão | Mesmo tipo do player; move_and_slide() integrado com paredes e chão |
| Godot 4 Area2D | built-in (4.4.1) | Checkpoint, prova coletável, obstáculo estático, trigger de NPC | body_entered sem física; leve e correto para detecção de sobreposição |
| Godot 4 TileMapLayer | built-in (4.4.1) | Level design das 4 cenas | Padrão do projeto (CLAUDE.md); cada layer é nó separado em 4.4+ |
| Godot 4 AudioStreamPlayer | built-in (4.4.1) | Tocar SFX (WAV) | Para sons não-posicionais (SFX de UI, stomp global); WAV = zero decode cost |
| Godot 4 AudioStreamPlayer2D | built-in (4.4.1) | SFX posicionais (dano do obstáculo) | Opcional para Phase 3; AudioStreamPlayer simples é suficiente para o MVP |
| Dialogic 2 | Alpha 19 (instalado) | Boss dialogue, NPC Renato Fase 3, abertura narrativa | Já instalado e verificado na Phase 2; API `Dialogic.start()` + `await Dialogic.timeline_ended` |
| Godot 4 CPUParticles2D | built-in (4.4.1) | Partículas do checkpoint, prova coletada, vitória do boss | Obrigatório — GPUParticles2D não funciona no renderer gl_compatibility |

[VERIFIED: project.godot — renderer/rendering_method="gl_compatibility"; CPUParticles2D confirmado em player.gd existente]
[VERIFIED: addons/dialogic/ existe; Dialogic.start() e await Dialogic.timeline_ended confirmados em test_dialogue.gd]
[VERIFIED: autoloads SaveManager + SceneTransition + ControlsManager registrados em project.godot]

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Godot 4 Tween | built-in | Animações de checkpoint (pulse), trust bar color change, ProvaCard fade | Preferível a AnimationPlayer para efeitos curtos e procedurais |
| Godot 4 AnimatedSprite2D | built-in | Animações de walk/death do Malandro, idle da prova coletável | 2-3 frames leves; usa SpriteFrames resource inline na scene |
| Godot 4 RayCast2D | built-in | Detecção de borda para virar o Malandro | Alternativa a wall check com is_on_wall(); mais preciso para plataformas com buracos |
| Godot 4 ProgressBar / ColorRect | built-in | Trust bar no boss HUD | ColorRect com custom_minimum_size.x é mais controlável que ProgressBar para step-color |
| Godot 4 NinePatchRect | built-in | Container da trust bar e ProvaCard | Bordas pixeladas sem distorção; padrão UI do projeto (Phase 2 DialogueBox) |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Respawn via get_tree().reload_current_scene() | SceneTransition.go_to() | SceneTransition tem fade 0.6s (300ms fade + 2 frames + 300ms fade) — violaria < 500ms. reload_current_scene() é instantâneo; desvanece apenas o flash vermelho de morte |
| Malandro com CharacterBody2D | KinematicBody2D (Godot 3) | KinematicBody2D não existe no Godot 4; CharacterBody2D é o correto |
| AudioManager autoload manual | Godot built-in AudioServer | AudioServer gerencia buses; AudioManager custom controla quais AudioStreamPlayer nodes tocar, volume individual de SFX |
| Provas salvas ao coletar | Provas salvas apenas no fim da fase | Morte antes do fim da fase perderia provas. SaveManager.save_game() imediato garante persistência conforme D-15 |
| RayCast2D para borda | wall check com is_on_wall() | is_on_wall() detecta paredes mas não buracos no chão. RayCast2D aponta para baixo-frente e detecta fim do chão com mais precisão |

**Installation:**
```bash
# Nenhuma instalação nova necessária para Phase 3
# Dialogic 2 Alpha 19 já instalado em addons/dialogic/
# Todos os autoloads (SaveManager, SceneTransition, ControlsManager) já registrados
# SFX placeholder: gerar com https://www.bfxr.net/ (web) ou sfxr local, exportar como WAV
```

---

## Architecture Patterns

### System Architecture Diagram

```
[Main Menu: New Game / Continue]
        │
        ▼
[SceneTransition.go_to("mundo1_abertura.tscn")]
        │
        ▼
[mundo1_abertura.tscn]
  CanvasLayer (Dialogic layer=50)
  Dialogic.start("mundo1_abertura") ──► await timeline_ended
        │
        ▼
[SceneTransition.go_to("fase1_rua.tscn")]
        │
        ▼
[fase1_rua.tscn / fase2_parque.tscn / fase3_restaurante.tscn]
  TileMapLayer_bg (z=-1)
  TileMapLayer_fg (z=1)
  Player (instância player.tscn)
  Malandro[] (CharacterBody2D — patrulha)
      │ stomp: velocity.y > 0 + colisão pelo topo
      ▼
    [Enemy.die() → reset na morte da Natália]
      │ contato lateral
      ▼
    [Player.take_damage(enemy.global_position)]
  StaticObstacle[] (Area2D — body_entered → take_damage)
  Checkpoint (Area2D — body_entered → SaveManager.set_checkpoint())
  ProvaItem[] (Area2D — body_entered → SaveManager adiciona prova + queue_free)

  [Player.die()]
       │
       ├─► _is_dead=true (animação death)
       │
       └─► fase_script: get_tree().reload_current_scene()
                        player.global_position = checkpoint_position
                        inimigos.reset_to_origin()

[fase3_restaurante.tscn] ──► [SceneTransition.go_to("boss_pai.tscn")]

[boss_pai.tscn]
  Checar: SaveManager.current_save["provas_mundo1"].size() >= 2?
      │ NO → Dialogic bloqueante + SceneTransition back to fase3
      │ YES ↓
  BossHUD (CanvasLayer layer=51)
    └── TrustBarFill (ColorRect)
  ProvaCardLayer (CanvasLayer layer=52)
  Dialogic (CanvasLayer layer=50) ──► Dialogic.start("boss_abertura")
    │
    │ [prova_apresentada event] → add_trust(+20) → show ProvaCard
    │ [choice_correct] → add_trust(+10)
    │ [choice_wrong] → add_trust(-15) → AudioManager.play_sfx("dialogo_errado")
    │
    ├─► trust <= 0 → game over boss → reload boss_pai.tscn (provas mantidas)
    │
    └─► trust >= 80 → RenatoEntrance.visible=true + Dialogic.start("boss_renato_entrada")
             │
             └─► trust >= 100 → Dialogic.start("boss_vitoria") → SceneTransition.go_to(world1_end)

[AudioManager (autoload)]
  AudioStreamPlayer nodes (SFX: WAV)
  AudioStreamPlayer nodes (Music: OGG)
  play_sfx(key: String) → tocar AudioStreamPlayer correspondente
  play_music(key: String) → tocar loop OGG
  stop_music() → parar trilha atual
```

### Recommended Project Structure
```
scenes/
└── world1/
    ├── mundo1_abertura.tscn    # Cutscene de abertura narrativa
    ├── fase1_rua.tscn          # Fase 1: Rua de Osasco
    ├── fase1_rua.gd
    ├── fase2_parque.tscn       # Fase 2: Parque
    ├── fase2_parque.gd
    ├── fase3_restaurante.tscn  # Fase 3: Restaurante
    ├── fase3_restaurante.gd
    ├── boss_pai.tscn           # Boss: Casa dos pais
    ├── boss_pai.gd
    ├── checkpoint.tscn         # Reutilizável nas 4 cenas
    ├── checkpoint.gd
    ├── prova_item.tscn         # Reutilizável nas Fases 1-3
    ├── prova_item.gd
    ├── malandro.tscn           # Inimigo patrulhador
    ├── malandro.gd
    └── static_obstacle.tscn   # Inimigo estático
autoloads/
├── save_manager.gd             # Existente; precisa de "provas_mundo1" no schema
├── scene_transition.gd         # Existente
├── controls_manager.gd         # Existente
└── audio_manager.gd            # NOVO — Phase 3 cria este autoload
assets/
├── audio/
│   ├── sfx/
│   │   ├── checkpoint.wav
│   │   ├── prova_coletada.wav
│   │   ├── prova_apresentada.wav
│   │   ├── dialogo_errado.wav
│   │   ├── stomp.wav
│   │   ├── dano.wav
│   │   └── vitoria.wav
│   └── music/
│       ├── mundo1_theme.ogg
│       └── boss_pai_theme.ogg
dialogic/
└── timelines/
    ├── mundo1_abertura.dtl
    ├── renato_restaurante.dtl
    ├── boss_abertura.dtl
    ├── boss_renato_entrada.dtl
    └── boss_vitoria.dtl
```

### Pattern 1: Stomp Kill Detection (Mario-style)
**What:** Detectar quando player cai em cima do inimigo vs. colisão lateral
**When to use:** Em malandro.gd para decidir se morre ou causa dano

O player.gd já verifica `velocity.y` mas não notifica inimigos. A detecção acontece no script do inimigo via `body_entered` no topo do inimigo, ou via `get_slide_collision()` no player. O padrão mais limpo no Godot 4 é usar uma Area2D "StompZone" no TOPO do inimigo:

```gdscript
# malandro.gd
# Source: padrão codebase player.gd + Godot 4 Area2D body_entered
extends CharacterBody2D

@export var patrol_speed: float = 40.0
@export var patrol_distance: float = 80.0

var _origin: Vector2
var _direction: float = 1.0
const GRAVITY: float = 900.0

@onready var stomp_zone: Area2D = $StompZone  # Area2D no topo: largura inimigo, altura 4px
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
    _origin = global_position
    stomp_zone.body_entered.connect(_on_stomp_zone_body_entered)

func _physics_process(delta: float) -> void:
    if _is_dead:
        return
    velocity.y += GRAVITY * delta
    velocity.x = _direction * patrol_speed
    move_and_slide()
    # Virar ao bater na parede
    if is_on_wall():
        _direction *= -1.0
        sprite.flip_h = _direction < 0.0

func _on_stomp_zone_body_entered(body: Node2D) -> void:
    if body.is_in_group("player") and body.velocity.y > 0:
        die()
        # Bounce o player para cima
        body.velocity.y = body.jump_velocity * 0.6

func die() -> void:
    _is_dead = true
    sprite.play("death")
    $CollisionShape2D.set_deferred("disabled", true)
    AudioManager.play_sfx("stomp")
    get_tree().create_timer(0.3).timeout.connect(queue_free, CONNECT_ONE_SHOT)

func reset_to_origin() -> void:
    global_position = _origin
    _is_dead = false
    $CollisionShape2D.set_deferred("disabled", false)
    sprite.play("walk")
```

**Cuidado:** `set_deferred("disabled", true)` é obrigatório para CollisionShape2D — nunca alterar `disabled` diretamente durante `_physics_process`. [VERIFIED: Godot 4 docs — CollisionShape2D.disabled deve ser alterado via set_deferred]

### Pattern 2: Respawn < 500ms sem SceneTransition
**What:** Respawn instantâneo no checkpoint sem fade de 600ms
**When to use:** Ao confirmar death da Natália (animação "death" termina)

```gdscript
# fase1_rua.gd (e todas as fases do world1)
# Source: player.gd _on_animated_sprite_2d_animation_finished + padrão codebase
extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var checkpoint: Area2D = $Checkpoint

# Posição do checkpoint (definida no .tscn via @export ou posição do nó)
var _checkpoint_position: Vector2

func _ready() -> void:
    _checkpoint_position = checkpoint.global_position
    # Conectar ao sinal de death do player
    player.connect("died", _on_player_died)

func _on_player_died() -> void:
    # Respawn direto — sem SceneTransition para cumprir < 500ms
    player.global_position = _checkpoint_position
    player.velocity = Vector2.ZERO
    player._is_dead = false
    player._is_hurt = false
    # Reset inimigos
    _reset_enemies()

func _reset_enemies() -> void:
    for enemy in get_tree().get_nodes_in_group("enemies"):
        if enemy.has_method("reset_to_origin"):
            enemy.reset_to_origin()
```

**Nota:** player.gd linha 222 tem `print("Player death animation finished — respawn hooked in Phase 3")` — este é o gancho explicitamente criado. Adicionar um sinal `signal died` ao player.gd e emiti-lo em `_on_animated_sprite_2d_animation_finished` quando `animation == "death"`.

### Pattern 3: SaveManager — adicionar provas_mundo1
**What:** O schema do save atual não inclui `provas_mundo1`. Precisa ser adicionado.
**When to use:** Ao criar `_default_save()` em save_manager.gd

```gdscript
# save_manager.gd — modificar _default_save()
# Source: save_manager.gd existente (linhas 49-56)
func _default_save() -> Dictionary:
    return {
        "version": SCHEMA_VERSION,
        "checkpoint_id": "",
        "worlds_completed": [],
        "powers_unlocked": [],
        "seen_cutscenes": {},
        "provas_mundo1": [],  # NOVO — Phase 3
    }
```

**Cuidado de migração:** Se um save existente (Phase 2) não tem `"provas_mundo1"`, o acesso `current_save["provas_mundo1"]` causará erro. Usar `.get("provas_mundo1", [])` nas leituras OU incrementar `SCHEMA_VERSION` para forçar reset (mais seguro para desenvolvimento).

### Pattern 4: AudioManager Autoload
**What:** Autoload simples para centralizar SFX e música
**When to use:** Criado antes dos primeiros tasks que precisam de áudio

```gdscript
# autoloads/audio_manager.gd
# Source: padrão autoload codebase (save_manager.gd)
extends Node

# Nodes filhos são AudioStreamPlayer para cada SFX (adicionados no .tscn ou criados em _ready)
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

func play_music(stream: AudioStream, loop: bool = true) -> void:
    _music_player.stream = stream
    _music_player.play()

func stop_music() -> void:
    _music_player.stop()
```

**Alternativa MVP:** Para Phase 3, AudioManager pode simplesmente ter métodos stub (`play_sfx(key)` que imprime no console) e os WAV reais são conectados em tasks posteriores de SFX. Isso desacopla a implementação das mecânicas.

### Pattern 5: Dialogic Boss — custom event para apresentar prova
**What:** Disparar lógica do boss durante um timeline Dialogic (apresentar prova, aumentar confiança)
**When to use:** boss_pai.tscn quando Dialogic atinge um ponto de apresentação de prova

A abordagem mais simples (sem custom events do Dialogic) é usar **sinais do Dialogic + variáveis do timeline**:

```gdscript
# boss_pai.gd — integração com Dialogic
# Source: test_dialogue.gd (Dialogic.start + await) + CONTEXT.md D-17

func _start_boss_sequence() -> void:
    # Mostrar provas coletadas e iniciar confiança baseada nelas
    var provas: Array = SaveManager.current_save.get("provas_mundo1", [])
    _trust = 0.0
    # Apresentar provas automaticamente antes do diálogo
    for prova_id in provas:
        await _show_prova_card(prova_id)
        add_trust(20.0)
    # Iniciar diálogo do boss
    Dialogic.start("boss_abertura")
    # Conectar sinais de choice do Dialogic para modificar trust
    Dialogic.signal_event.connect(_on_dialogic_signal)
    await Dialogic.timeline_ended
    Dialogic.signal_event.disconnect(_on_dialogic_signal)

func _on_dialogic_signal(argument: String) -> void:
    match argument:
        "choice_correct": add_trust(10.0)
        "choice_wrong": add_trust(-15.0)
        "renato_entrada": _trigger_renato_entrance()
```

**Dialogic signal_event:** Eventos de sinal no timeline disparam `Dialogic.signal_event` com um argumento string. Usar no timeline com o evento "Signal" do Dialogic. [ASSUMED — baseado em Dialogic 2 Alpha 19 API; verificar na documentação do Dialogic ao implementar]

### Anti-Patterns to Avoid
- **GPUParticles2D:** Nunca usar — quebra no renderer gl_compatibility (web export). Sempre CPUParticles2D.
- **`velocity.x +=` com knockback:** Causa acumulação infinita. Usar `velocity.x = _knockback.x` (padrão player.gd linha 80).
- **SceneTransition para respawn:** SceneTransition tem fade 600ms total, violando a constraint < 500ms de WORLD-05. Usar reload direto de posição.
- **Alterar CollisionShape2D.disabled diretamente em _physics_process:** Causa crash no Godot 4. Sempre usar `set_deferred("disabled", true/false)`.
- **`create_timer(duration)` sem `true`:** Para timers que devem rodar durante Engine.time_scale=0 (hit-stop), usar `create_timer(duration, true)` — `process_always=true` obrigatório.
- **Variant implícito com `:=` para tipos críticos:** Warnings-as-errors ativo no projeto. Usar tipos explícitos: `var x: String = ""`, não `var x := ""` quando o tipo importa para signals ou dicts.
- **Acessar `current_save["provas_mundo1"]` diretamente:** Save pode ser do schema antigo (Phase 2) sem essa chave. Usar `.get("provas_mundo1", [])` ou incrementar SCHEMA_VERSION.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Diálogo de boss com choices | Parser de texto customizado | Dialogic 2 (já instalado) | Dialogic tem editor visual, choices, sinais, skip, portraits |
| Fade de transição entre fases | Timer + ColorRect manual | SceneTransition.go_to() (autoload existente) | Já implementado e testado; reutilizar |
| Persistência de provas entre mortes | Array em memória | SaveManager (já implementado) | save_game() já existe; apenas adicionar "provas_mundo1" ao schema |
| Skip de cutscenes | Lógica customizada | SaveManager.has_seen_cutscene() + Dialogic.Inputs.auto_skip | Padrão já estabelecido em test_dialogue.gd |
| SFX de chiptune | Código gerador de áudio | bfxr.net (online) | Gera WAV chiptune em segundos; zero código |
| Partículas de glitter/glow | Shader customizado | CPUParticles2D (built-in) | Funciona no gl_compatibility; configurável via Inspector |

**Key insight:** Quase tudo em Phase 3 é composição de sistemas existentes. O risco de hand-roll está principalmente no sistema de detecção de stomp (usar StompZone Area2D no topo do inimigo, não parser de colisão manual) e no boss trust system (usar Dialogic signal_event, não parser de texto custom).

---

## Common Pitfalls

### Pitfall 1: SceneTransition para respawn viola < 500ms (WORLD-05)
**What goes wrong:** Usar `SceneTransition.go_to("fase1_rua.tscn")` para respawn faz fade de 300ms + 2 frames + fade de 300ms = ~620ms, violando o critério de sucesso de WORLD-05.
**Why it happens:** É tentador reutilizar SceneTransition para tudo, mas o fade foi projetado para transições de cena completas.
**How to avoid:** Para respawn, usar respawn direto: `player.global_position = _checkpoint_position`, reset de velocity, reset de inimigos. Sem fade. O flash branco/vermelho de morte já é feedback visual suficiente.
**Warning signs:** Critério de sucesso 2 falha no human-verify: "morte respawna em menos de 500ms".

### Pitfall 2: `current_save["provas_mundo1"]` em save antigo (schema sem a chave)
**What goes wrong:** Phase 2 deixou saves em `user://save.dat` sem a chave `"provas_mundo1"`. Acessar `current_save["provas_mundo1"]` diretamente causa erro de "Invalid get index".
**Why it happens:** O `_default_save()` atual não inclui `"provas_mundo1"`.
**How to avoid:** Duas opções: (a) incrementar `SCHEMA_VERSION` de 1 para 2 em save_manager.gd — saves antigos são detectados como incompatíveis e resetados para o novo default. (b) Usar `.get("provas_mundo1", [])` em todos os acessos. Opção (a) é mais segura para desenvolvimento; opção (b) é mais gentil com saves de QA.
**Warning signs:** Crash com "Invalid get index 'provas_mundo1'" ao entrar na boss scene.

### Pitfall 3: Alterar CollisionShape2D.disabled direto em _physics_process
**What goes wrong:** Godot 4 proíbe alterar a física durante o processo de física. Causa erro "Cannot change this property while physics is running."
**Why it happens:** Natural querer fazer `$CollisionShape2D.disabled = true` ao morrer dentro de `_physics_process`.
**How to avoid:** Sempre usar `$CollisionShape2D.set_deferred("disabled", true)`. O `set_deferred` agenda a mudança para depois do frame de física.
**Warning signs:** Erro "Cannot change CollisionShape2D properties during physics update."

### Pitfall 4: Dialogic signal_event não conectado — modificações de trust não disparam
**What goes wrong:** `Dialogic.signal_event` é um sinal do Dialogic que só dispara quando o event "Signal" está no timeline. Se o timeline não tiver esse event, as choices não modificam a trust bar.
**Why it happens:** Confundir "choice" event com "signal" event no Dialogic.
**How to avoid:** No timeline do Dialogic, APÓS cada choice branch (correto/errado), adicionar um evento "Signal" com o argumento `"choice_correct"` ou `"choice_wrong"`. O boss_pai.gd então conecta ao `Dialogic.signal_event`.
**Warning signs:** Trust bar nunca muda durante o diálogo do boss.

### Pitfall 5: Malandro "vira" em buracos no chão ao usar apenas is_on_wall()
**What goes wrong:** Malandro cai em buracos quando o chão acaba, pois is_on_wall() só detecta paredes verticais, não a ausência de chão.
**Why it happens:** Patrulha simples com `velocity.x *= -1 if is_on_wall()` não verifica borda.
**How to avoid:** Adicionar RayCast2D apontando para baixo na frente do Malandro (ex: x=+12, y=+4, length=16 px). Se o RayCast não colidir com o chão, virar. Alternativamente, limitar o Malandro a plataformas fechadas no level design de Phase 3.
**Warning signs:** Malandro desaparece da tela ao cair em buracos.

### Pitfall 6: AudioManager não existe ainda — calls para play_sfx() crasham
**What goes wrong:** UI-SPEC e CONTEXT.md referenciam `AudioManager.play_sfx()` em muitos lugares, mas AudioManager não é um autoload existente no projeto (confirmado: project.godot não o lista).
**Why it happens:** Phase 2 não criou AudioManager.
**How to avoid:** AudioManager DEVE ser o primeiro task de Phase 3. Criar como autoload mínimo com métodos stub antes de implementar inimigos ou checkpoints. Registrar em project.godot.
**Warning signs:** Erro "Identifier 'AudioManager' is not declared in the current scope" em qualquer script que chame play_sfx().

### Pitfall 7: ProvaCard e BossHUD CanvasLayer ordering conflitando com Dialogic
**What goes wrong:** Dialogic usa CanvasLayer com layer padrão. Se BossHUD usar layer menor que o Dialogic, o HUD fica ABAIXO do diálogo e invisível.
**Why it happens:** Dialogic 2 usa layer=50 por padrão (conforme UI-SPEC Phase 3).
**How to avoid:** BossHUD = layer 51, ProvaCardLayer = layer 52, GameOverFlash = layer 99, SceneTransition = layer 100 (já configurado). Verificar no editor que os CanvasLayers estão na ordem correta.
**Warning signs:** Trust bar invisível durante o diálogo do boss.

---

## Code Examples

### Checkpoint activation (Area2D pattern)
```gdscript
# checkpoint.gd
# Source: patterns estabelecidos em test_save.gd + save_manager.gd
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

### Prova collectible
```gdscript
# prova_item.gd
# Source: damage_trigger.gd padrão + save_manager.gd
extends Area2D

@export var prova_id: String = "prova_foto"

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if not body.is_in_group("player"):
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
    get_tree().create_timer(0.25).timeout.connect(queue_free, CONNECT_ONE_SHOT)
```

### Player death signal (adicionar a player.gd)
```gdscript
# player.gd — acrescentar ao arquivo existente
# Source: player.gd linha 222 (stub existente)
signal died

# Modificar _on_animated_sprite_2d_animation_finished:
func _on_animated_sprite_2d_animation_finished() -> void:
    if sprite.animation == "hurt":
        _is_hurt = false
    elif sprite.animation == "death":
        died.emit()  # Phase 3 hook
```

### Main menu wiring para mundo1_abertura
```gdscript
# main_menu.gd — substituir SceneTransition.go_to("test_movement") por:
# Source: main_menu.gd existente (linhas 28-43)

func _on_continue_pressed() -> void:
    SceneTransition.go_to("res://scenes/world1/mundo1_abertura.tscn")

func _on_new_game_confirmed() -> void:
    SaveManager.new_game()
    SceneTransition.go_to("res://scenes/world1/mundo1_abertura.tscn")
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| TileMap (Godot 4.3) | TileMapLayer (Godot 4.4+) | Godot 4.4 | Cada layer é nó separado; colidir, navegar e scriptar por layer. CLAUDE.md e CONTEXT.md confirmam uso de TileMapLayer |
| GPUParticles2D | CPUParticles2D | Phase 0 (renderer gl_compatibility) | GPUParticles2D não funciona na web; CPUParticles2D funcional em todos os targets |
| KinematicBody2D (Godot 3) | CharacterBody2D (Godot 4) | Godot 4.0 | Renomeado + API melhorada; move_and_slide() não exige delta como argumento |

**Deprecated/outdated:**
- `KinematicBody2D`: Não existe no Godot 4. Usar CharacterBody2D.
- `yield()`: Não existe no Godot 4. Usar `await`.
- `connect(signal, self, "_method")`: Sintaxe Godot 3. Usar `signal.connect(callable)` ou `signal.connect(_method)`.

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Dialogic 2 Alpha 19 tem sinal `Dialogic.signal_event` com argumento string para comunicar eventos customizados do timeline para o jogo | Pattern 5, Pitfall 4 | Boss trust bar não recebe updates de choices; precisaria de outro mecanismo (ex: Dialogic variables) |
| A2 | `get_tree().reload_current_scene()` + reposicionamento manual do player é suficiente para respawn < 500ms sem flicker visível | Pattern 2, Pitfall 1 | Pode haver frame de flash do estado anterior da cena antes da posição ser aplicada; alternativa: carregar cena nova com posição no `_ready()` |
| A3 | SceneTransition.go_to() existente (0.3s fade + change + 0.3s fade-in) não é adequado para respawn; confirmado pelos 0.6s totais | Don't Hand-Roll, Pitfall 1 | Se SceneTransition for mais rápido do que calculado, poderia ser usado |
| A4 | Dialogic 2 Alpha 19 usa layer=50 para o CanvasLayer do diálogo (conforme UI-SPEC Phase 3) | Pattern 5, Pitfall 7 | Se Dialogic usar layer diferente, o BossHUD pode ficar com ordering errado |

**Se A1 estiver errado:** Alternativa são as variáveis do Dialogic (Dialogic.VAR.set/get) — a fase de boss define variáveis globais do Dialogic para rastrear estado, e boss_pai.gd as lê via timer ou a cada frame.

---

## Open Questions (RESOLVED)

1. **Phase 2 precisa estar 100% completa antes de iniciar Phase 3?**
   - What we know: STATE.md diz "Phase: 02 — EXECUTING"; plans 02-001 a 02-005 existem com SUMMARY.md = executados.
   - What's unclear: Se os critérios de sucesso da Phase 2 (SaveManager funcionando, Dialogic funcionando com personagens, main_menu completo) foram validados em human-verify.
   - **RESOLVED (Phase 2 completion gate):** Phase 3 depende diretamente de SceneTransition, SaveManager e Dialogic — todos entregues na Phase 2. Antes de executar qualquer plano da Phase 3, confirmar a conclusão da Phase 2 por UMA das condições: **(a)** `02-VERIFICATION.md` mostra `Phase Goal: ACHIEVED`, OU **(b)** todos os 5 arquivos `02-00{1..5}-PLAN.md` possuem o `SUMMARY.md` correspondente confirmando execução. Se nenhuma condição for satisfeita, NÃO iniciar a Phase 3 — é um bloqueador de runtime real (AudioManager, SaveManager schema e Dialogic dependem da base da Phase 2). Esta verificação é o gate de entrada da Phase 3; sem ela, a cadeia menu → abertura → fase1 quebra na primeira chamada a SceneTransition/SaveManager.

2. **AudioManager.play_sfx() deve aceitar falha silenciosa (chave não encontrada)?**
   - What we know: SFX WAV files não existem ainda; serão criados com bfxr.
   - What's unclear: Se tasks de mechanics e de audio devem ser waves separadas ou se AudioManager stub (sem WAV reais) é suficiente para não bloquear mechanics.
   - **RESOLVED:** Sim — `AudioManager.play_sfx()` aceita falha silenciosa. Se a chave não está em `_sfx_players`, o método não faz nada (o guarda `if _sfx_players.has(key):` em Pattern 4 já implementa isso). Plano **03-01 Task 1** implementa o AudioManager com esse `has(key)` guard, e o registro de cada SFX em **03-05 Task 2** é protegido por `ResourceLoader.exists(path)`. Mechanics (Waves 2-4) podem chamar `play_sfx` sem bloquear, mesmo antes dos WAV reais existirem — calls para chaves não registradas são no-ops, não crashes.

3. **A cena de fim do Mundo 1 (`world1_end` / `world1_credits`) existe ou é placeholder?**
   - What we know: UI-SPEC menciona `SceneTransition.go_to("scenes/world1/world1_credits.tscn")` na vitória do boss.
   - What's unclear: Essa cena não está no scope explícito de Phase 3; DEFERRED section não a menciona.
   - **RESOLVED:** É um placeholder criado nesta fase. **Plano 03-05 Task 1** cria `scenes/world1/world1_end.tscn` mínima (ColorRect `#1A1A2E` + Label "Fim do Mundo 1" + botão "Menu" que volta ao main_menu). A vitória do boss (Plano 03-04 Task 2) aponta para `world1_end.tscn` com guarda `ResourceLoader.exists` e fallback para `main_menu.tscn`. A cena real de créditos com fotos é Phase 10.

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Godot 4.4.x | Engine inteiro | ✓ | 4.4.1.stable | — |
| Dialogic 2 plugin | Boss, diálogos, abertura | ✓ | Alpha 19 | — |
| SaveManager autoload | Checkpoints, provas | ✓ | — (custom) | — |
| SceneTransition autoload | Transições entre fases | ✓ | — (custom) | — |
| ControlsManager autoload | Input actions | ✓ | — (custom) | — |
| AudioManager autoload | SFX em todo Mundo 1 | ✗ | — | Criar em Wave 1 de Phase 3 |
| bfxr/sfxr (SFX generation) | Assets WAV placeholder | ✓ (web) | — | https://www.bfxr.net/ |
| WAV SFX files | AudioManager.play_sfx() | ✗ | — | Stub com print() nas waves iniciais |
| OGG music files | AudioManager.play_music() | ✗ | — | Silent .ogg (arquivo vazio válido) |
| player.gd `signal died` | Respawn logic | ✗ | — | Adicionar em primeiro task de Phase 3 |
| `provas_mundo1` no save schema | ProvaItem, boss scene | ✗ | — | Adicionar ao save_manager.gd |

[VERIFIED: project.godot — SaveManager, SceneTransition, ControlsManager registrados]
[VERIFIED: addons/dialogic/ existe com Natalia.dch e Renato.dch]
[VERIFIED: assets/audio/sfx/ e assets/audio/music/ existem mas estão vazios]
[VERIFIED: player.gd linha 222 — stub "respawn hooked in Phase 3" existe]

**Missing dependencies that block execution (must be created in Wave 1):**
- AudioManager autoload — referenciado em checkpoint.gd, prova_item.gd, malandro.gd, boss_pai.gd
- `signal died` em player.gd — requerido para respawn loop
- `"provas_mundo1"` em SaveManager schema — requerido para ProvaItem e boss

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Godot 4 built-in test scene + human-verify |
| Config file | none — teste por cena individual |
| Quick run command | Godot editor: F5 (run current scene) |
| Full suite command | F5 em test_movement.tscn + teste de cada fase do world1 |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| WORLD-01 | Mundo 1 tem fases com paleta cinza-urbana e inimigos | manual | Abrir fase1_rua.tscn e verificar visualmente | ❌ Wave 0 |
| WORLD-02 | 3 fases lineares + 1 boss acessíveis sequencialmente | manual | Completar fase1→2→3→boss via SceneTransition | ❌ Wave 0 |
| WORLD-03 | Checkpoint salva posição; reabre cena com player no CP | manual | Tocar checkpoint, fechar+abrir jogo, verificar posição | ❌ Wave 0 |
| WORLD-05 | Respawn < 500ms | manual | Morrer e cronometrar com timer externo | ❌ Wave 0 |
| BOSS-01 | Boss derrotável apenas por diálogo; dano direto não mata | manual | Testar choices e provas; verificar vitória/derrota | ❌ Wave 0 |
| NPC-01 | Renato visível em pelo menos 1 ponto com diálogo | manual | Entrar em Fase 2 (bg) e Fase 3 (diálogo) | ❌ Wave 0 |
| NARR-05 | Texto de abertura antes da Fase 1 | manual | Novo jogo → verificar tela mundo1_abertura | ❌ Wave 0 |
| AUDIO-02 | SFX tocam nos momentos corretos | manual | Jogar world1 completo e ouvir SFX | ❌ Wave 0 |

### Sampling Rate
- **Por task commit:** F5 na cena modificada — verificar sem crash no editor
- **Por wave merge:** Jogar do menu → abertura → fase1 → fase2 → fase3 → boss completo
- **Phase gate:** Human-verify com checklist dos 6 critérios de sucesso antes de `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `autoloads/audio_manager.gd` — AudioManager stub (play_sfx com print)
- [ ] `player.gd` — adicionar `signal died` + emit em `_on_animated_sprite_2d_animation_finished`
- [ ] `save_manager.gd` — adicionar `"provas_mundo1": []` ao `_default_save()`; incrementar SCHEMA_VERSION ou usar `.get()` defensivo
- [ ] `scenes/world1/` — criar diretório

---

## Security Domain

> `security_enforcement` não configurado explicitamente em config.json — tratado como habilitado.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | Jogo offline, sem autenticação |
| V3 Session Management | no | Sem sessions; save local em user:// |
| V4 Access Control | no | Sem multi-usuário |
| V5 Input Validation | yes (low risk) | Checkpoint IDs e prova IDs são strings internas — não user input |
| V6 Cryptography | no | Save em binário Godot nativo; sem criptografia necessária para jogo offline |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Save tampering (editar user://save.dat) | Tampering | Não aplicável para jogo pessoal/presente; sem ranking online |
| Infinite respawn loop (player morrer em respawn position) | DoS | Posicionar checkpoint acima de qualquer hazard; testar no level design |
| Prova duplicada no array (coleta concorrente) | Tampering | Verificar `if prova_id not in provas` antes de append |

---

## Sources

### Primary (HIGH confidence)
- Codebase: `scenes/player/player.gd` — física existente, velocity.y, take_damage(), die() stub
- Codebase: `autoloads/save_manager.gd` — save_game(), set_checkpoint(), current_save schema
- Codebase: `autoloads/scene_transition.gd` — go_to() com fade 0.3s por lado
- Codebase: `scenes/test_dialogue/test_dialogue.gd` — Dialogic.start(), await timeline_ended, skip pattern
- Codebase: `project.godot` — autoloads registrados, renderer gl_compatibility confirmado
- `CLAUDE.md` — CPUParticles2D obrigatório, TileMapLayer, GDScript conventions
- `03-CONTEXT.md` — 27 decisões locked
- `03-UI-SPEC.md` — node specifications, CanvasLayer ordering, copy

### Secondary (MEDIUM confidence)
- `02-PATTERNS.md` — padrões GDScript estabelecidos (tween, signal connection, autoload)
- `02-RESEARCH.md` — Dialogic Alpha 19 API, save patterns

### Tertiary (LOW confidence)
- A1 (ASSUMED): Dialogic `Dialogic.signal_event` API para comunicação com boss script — não verificado via Context7 nesta sessão
- A4 (ASSUMED): Dialogic usa layer=50 por padrão — inferido da UI-SPEC Phase 3 mas não verificado no código do plugin

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — Godot 4 built-ins verificados; Dialogic instalado verificado; autoloads existentes verificados
- Architecture: HIGH — baseada em código real do projeto; patterns diretos de player.gd e save_manager.gd
- Pitfalls: HIGH para 1-3 (verificados via código), MEDIUM para 4-7 (baseados em padrões conhecidos do Godot 4)

**Research date:** 2026-06-08
**Valid until:** 2026-08-08 (Godot 4 estável; Dialogic Alpha 19 instalado e fixo)
