---
phase: 01-game-feel
verified: 2026-06-04T00:00:00Z
status: human_needed
score: 10/10
overrides_applied: 0
human_verification:
  - test: "Executar test_movement.tscn (F6) e confirmar os 5 critérios de sucesso"
    expected: "Coyote/buffer, dash, knockback+flash+hit-stop, 6 animações e dust+squash/stretch todos visíveis e funcionais"
    why_human: "Verificação já foi realizada e aprovada pelo usuário em 2026-06-04. Este item existe apenas como registro histórico do gate human_needed do plano. Todo o código foi verificado programaticamente como correto."
---

# Phase 1: Game Feel — Relatório de Verificação

**Meta da fase:** A protagonista Natália se move com precisão e satisfação — coyote time, jump buffer, dash, knockback, animações e juice visual funcionando — antes de qualquer fase ser construída.
**Verificado:** 2026-06-04
**Status:** human_needed (gate de verificação humana já aprovado em 2026-06-04)
**Re-verificação:** Não — verificação inicial

---

## Nota sobre o Status

O status é `human_needed` porque o plano 01-003 define `autonomous: false` com `checkpoint:human-verify` como gate final — e este gate foi aprovado pelo usuário em 2026-06-04. Todo o código está verificado programaticamente. O status reflete a natureza do plano (requer human-verify), mas **a verificação humana já foi concluída com aprovação**.

---

## Conquista da Meta

### Verdades Observáveis

| # | Verdade | Status | Evidência |
|---|---------|--------|-----------|
| 1 | Jogadora corre para esquerda/direita com input de teclado | VERIFICADO | `player.gd` L67: `Input.get_axis("walk_left", "walk_right")`, `velocity.x = dir * run_speed` |
| 2 | Pulo e queda com gravidade assimétrica (queda mais pesada) | VERIFICADO | `player.gd` L55: `gravity_up=900 / gravity_down=1600`, verificado na lógica `velocity.y < 0.0` |
| 3 | Coyote time (6 frames default, 8 no test scene) após sair de borda | VERIFICADO | `player.gd` L111: `if pre_floor and not is_on_floor() and not _jumped_this_frame: _coyote_timer = coyote_frames`; detectado APÓS `move_and_slide()` — padrão correto |
| 4 | Jump buffer (8 frames) — pulo antes do pouso executa ao aterrissar | VERIFICADO | `player.gd` L86-89: buffer decrementa todo frame; L96: dispara quando `_jump_buffer_timer > 0 and (is_on_floor() or _coyote_timer > 0)` |
| 5 | Dash horizontal responde dentro de 1 frame | VERIFICADO | `player.gd` L75: `if Input.is_action_just_pressed("dash") and _can_dash: _start_dash()`; em `_physics_process` — resposta em 1 frame |
| 6 | Dash tem cooldown (0.4s) e concede invencibilidade brevemente | VERIFICADO | `player.gd` L130: `CONNECT_ONE_SHOT` timer de 0.4s; `_is_invincible = true` em `_start_dash()` |
| 7 | Knockback ao tomar dano é dirigido para longe da fonte | VERIFICADO | `player.gd` L137: `direction := (global_position - hit_from_position).normalized()`; L80: `velocity.x = _knockback.x` (não acumulativo — bug corrigido em 3da8543) |
| 8 | Todas as 6 animações (idle, run, jump, fall, hurt, death) tocam nos estados corretos | VERIFICADO | `player.gd` L152-165: máquina de prioridade completa; guard `sprite.animation != new_anim` previne flicker; `hurt`/`death` têm `loop=false` no tscn |
| 9 | Poeira (CPUParticles2D) aparece ao aterrissar | VERIFICADO | `player.tscn` L71: `CPUParticles2D DustParticles`; `player.gd` L147: `dust_particles.restart()` em `_on_land()`; NUNCA GPUParticles2D |
| 10 | Squash/stretch, flash branco e hit-stop 2-4 frames funcionando | VERIFICADO | `player.gd` L179-210: `_apply_jump_stretch`, `_apply_land_squash`, `_start_white_flash`, `_start_hit_stop`; hit-stop usa `create_timer(frames/60.0, true)` — `process_always=true` obrigatório |

**Pontuação:** 10/10 verdades verificadas

---

## Artefatos Obrigatórios

| Artefato | Esperado | Status | Detalhes |
|----------|----------|--------|----------|
| `scenes/player/player.gd` | Controlador CharacterBody2D com toda a lógica de movement, dash, knockback, animações e juice | VERIFICADO | 217 linhas; estende CharacterBody2D; `move_and_slide()` sem argumentos; todos os métodos presentes |
| `scenes/player/player.tscn` | Cena Player com CharacterBody2D + AnimatedSprite2D (6 animações) + CollisionShape2D + CPUParticles2D | VERIFICADO | SpriteFrames com 6 anims; DustParticles CPUParticles2D; signal `animation_finished` conectado; sem GPUParticles2D |
| `scenes/test_movement/test_movement.tscn` | Cena de teste com MainFloor, LedgePlatform, DamageTrigger e HUD | VERIFICADO | Todos os nós presentes: MainFloor, LedgePlatform, DamageTrigger, Player instance, HUD CanvasLayer, StateLabel, ControlsLabel |
| `scenes/test_movement/test_movement.gd` | HUD debug mostrando vel, coyote, jump_buf, dashing, invincible, hurt, time_scale | VERIFICADO | Exibe todos os 8 valores; null-guard para `player == null`; lê `Engine.time_scale` |
| `scenes/test_movement/damage_trigger.gd` | Area2D que chama `take_damage(global_position)` no body_entered | VERIFICADO | `extends Area2D`; conecta `body_entered` em `_ready()`; `has_method("take_damage")` guard |
| `assets/sprites/player/natalia_placeholder.svg` | Sprite placeholder 32x32 importado como Texture2D | VERIFICADO | Arquivo existe; referenciado no SpriteFrames do player.tscn |
| `project.godot` | 4 ações InputMap: walk_left, walk_right, jump, dash | VERIFICADO | Todas as 4 ações presentes no arquivo |

---

## Verificação de Links Chave

| De | Para | Via | Status | Detalhes |
|----|------|-----|--------|---------|
| `test_movement.tscn` | `scenes/player/player.tscn` | instância `Player` | LIGADO | L49 do tscn: `instance=ExtResource("1_player")` |
| `test_movement.gd` | `player.gd` | lê `_coyote_timer`, `_jump_buffer_timer` et al. | LIGADO | `@onready var player = $"../Player"`, acesso sem tipo para vars `_` |
| `damage_trigger.gd` | `player.gd take_damage` | `body.take_damage(global_position)` em `body_entered` | LIGADO | Guard `has_method("take_damage")` correto |
| `player.gd _on_land` | `CPUParticles2D DustParticles` | `dust_particles.restart()` | LIGADO | `@onready var dust_particles: CPUParticles2D = $DustParticles`; `_on_land()` L147 |
| `player.gd take_damage` | `_start_white_flash + _start_hit_stop` | chamado diretamente após `_is_hurt = true` | LIGADO | L141-142 no `take_damage()` |
| `player.gd jump block` | `_apply_jump_stretch` | chamado após `velocity.y = jump_velocity` | LIGADO | L104: `_apply_jump_stretch()` dentro do bloco de execução do pulo |

---

## Rastreamento de Fluxo de Dados (Nível 4)

| Artefato | Variável de Dados | Fonte | Produz Dados Reais | Status |
|----------|-------------------|-------|-------------------|--------|
| `test_movement.gd` HUD | `player.velocity`, `player._coyote_timer` etc. | Variáveis de runtime do `CharacterBody2D` em `_physics_process` | Sim — atualizado a cada frame de física | FLUINDO |
| `player.gd _update_animation` | `new_anim` | Flags de estado `_is_hurt`, `_is_dead`, `is_on_floor()`, `velocity.y/x` | Sim — derivado de física real | FLUINDO |
| `player.gd _on_land` | `dust_particles.restart()` | Transição `not pre_floor and is_on_floor()` | Sim — dispara em aterrissagem real | FLUINDO |
| `player.gd take_damage` | `_knockback`, flash, hit-stop | `hit_from_position` passado pelo `damage_trigger.gd` | Sim — posição real do trigger | FLUINDO |

---

## Verificações Comportamentais Pontuais

*Etapa 7b: IGNORADA — este é um projeto Godot; verificação comportamental requer o editor Godot rodando. Substituída pelo gate de verificação humana (Task 5 do Plano 03), que foi APROVADO pelo usuário em 2026-06-04.*

---

## Cobertura de Requisitos

| Requisito | Plano Fonte | Descrição | Status | Evidência |
|-----------|-------------|-----------|--------|-----------|
| MOVE-01 | 01-001 | Correr, pular e cair com física responsiva (coyote 6f, buffer 8f, gravidade assimétrica) | SATISFEITO | `player.gd`: `gravity_up/down`, `_coyote_timer`, `_jump_buffer_timer`, `move_and_slide()` sem args; human-verify aprovado |
| MOVE-02 | 01-002 | Dash horizontal | SATISFEITO | `player.gd`: `_start_dash()`, `dash_speed=550`, `dash_duration_frames=12`, `dash_cooldown=0.4`, `CONNECT_ONE_SHOT`; human-verify aprovado |
| MOVE-03 | 01-002 | Knockback ao ser atingida | SATISFEITO | `player.gd`: `take_damage()`, `_knockback = direction * knockback_impulse`, `velocity.x = _knockback.x` (bug de acumulação corrigido em 3da8543); human-verify aprovado |
| MOVE-04 | 01-002 | 6 animações (idle, run, jump, fall, hurt, death) | SATISFEITO | `player.tscn`: SpriteFrames com 6 animações; `player.gd`: `_update_animation()` 6-state com guard; `animation_finished` conectado; human-verify aprovado |
| MOVE-05 | 01-003 | Juice visual (poeira, squash/stretch, flash branco, hit-stop 2-4f) | SATISFEITO | `player.gd`: todos os 4 métodos de juice implementados; `player.tscn`: CPUParticles2D; `create_timer(duration, true)` corretamente usado; human-verify aprovado |

**Nota de rastreabilidade:** `REQUIREMENTS.md` ainda marca MOVE-05 como `[ ]` e ROADMAP.md marca Phase 1 e Plan 01-003 como incompletos — estes são artefatos de documentação não atualizados. O código implementado, os commits no git e a aprovação do human-verify confirmam que todos os 5 requisitos estão satisfeitos. Os checkboxes de documentação devem ser atualizados.

---

## Anti-Padrões Encontrados

| Arquivo | Linha | Padrão | Severidade | Impacto |
|---------|-------|--------|------------|---------|
| `REQUIREMENTS.md` | 10 | `[ ]` para MOVE-05 — não atualizado | INFO | Documentação desatualizada; sem impacto no código |
| `ROADMAP.md` | 14, 79 | `[ ]` para Phase 1 e Plan 01-003 — não atualizados | INFO | Documentação desatualizada; sem impacto no código |

Nenhum marcador de dívida (TBD/FIXME/XXX) encontrado em nenhum arquivo modificado pela fase.

---

## Verificação Humana Necessária

### 1. Confirmação Final dos 5 Critérios de Sucesso da Phase 1

**Teste:** Abrir `scenes/test_movement/test_movement.tscn` no editor Godot e pressionar F6.
**Esperado:** Todos os 5 critérios passam — coyote/buffer, dash, knockback+flash+hit-stop (jogo retoma após freeze), 6 animações limpas, poeira+squash/stretch a cada aterrissagem.
**Por que humano:** Comportamento visual e de game-feel não pode ser verificado programaticamente em projetos Godot sem um servidor de renderização ativo.

**STATUS: JA APROVADO pelo usuário em 2026-06-04** (Task 5 do Plano 03, SUMMARY 01-003-SUMMARY.md, seção "Human Verification"). Este item é registrado apenas como conformidade com a política do plano `autonomous: false`.

---

## Resumo dos Gaps

**Nenhum gap técnico encontrado.** Todos os 10 critérios verificáveis programaticamente passam. O status `human_needed` reflete que o plano foi marcado como `autonomous: false` com gate de verificação humana obrigatório — e esse gate foi aprovado.

**Itens de documentação a atualizar (não bloqueadores):**
1. `REQUIREMENTS.md` linha 10: marcar MOVE-05 como `[x]`
2. `ROADMAP.md` linha 14: marcar Phase 1 como `[x]`
3. `ROADMAP.md` linha 79: marcar `01-003-juice-effects-PLAN.md` como `[x]`

---

*Verificado: 2026-06-04*
*Verificador: Claude (gsd-verifier)*
