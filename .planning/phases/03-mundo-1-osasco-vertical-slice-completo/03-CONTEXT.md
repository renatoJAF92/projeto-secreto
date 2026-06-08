# Phase 3: Mundo 1 — Osasco (vertical slice completo) - Context

**Gathered:** 2026-06-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Implementar o primeiro mundo jogável completo: 4 scenes sequenciais do Mundo 1 (Rua de Osasco → Parque → Restaurante → Boss na casa dos pais), com inimigos via pulo Mario-style, checkpoints visuais com cartaz McFly, sistema de provas coletáveis, chefe O Pai Desconfiante (Luis) com barra de confiança e diálogo via Dialogic, NPC Renato em cena, texto narrativo de abertura, e SFX placeholder (bfxr/sfxr).

</domain>

<decisions>
## Implementation Decisions

### Estrutura das Fases (WORLD-01, WORLD-02)
- **D-01:** Mundo 1 tem 4 scenes separadas no Godot, carregadas via `SceneTransition.go_to()`:
  1. `scenes/world1/fase1_rua.tscn` — Rua de Osasco
  2. `scenes/world1/fase2_parque.tscn` — Parque (Renato aparece no fundo como NPC)
  3. `scenes/world1/fase3_restaurante.tscn` — Restaurante (Renato presente + Luis escondido no cenário)
  4. `scenes/world1/boss_pai.tscn` — Casa dos pais da Natália (boss fight com Luis)
- **D-02:** Texto narrativo de abertura do Mundo 1 aparece como cutscene Dialogic antes da Fase 1 (Rua de Osasco), imediatamente após o New Game / Continue do menu.
- **D-03:** Paleta visual Mundo 1: cinza urbano com acentos de cor quente — base `#1A1A2E` (herdada do main menu) com laranja/vermelho para elementos interativos, NPCs e checkpoints.

### Combate com Inimigos (WORLD-01, WORLD-02)
- **D-04:** Mecânica de combate: pulo em cima do inimigo mata instantaneamente (Mario-style). Nenhum input novo — aproveita física já implementada em `player.gd`.
- **D-05:** Contato lateral com inimigo = toma dano + knockback (já implementado em `player.gd` via `_knockback`). Sem dano de retorno ao inimigo.
- **D-06:** Dois tipos de inimigos no Mundo 1:
  - **Malandro:** CharacterBody2D que patrulha horizontalmente (vai e volta, vira ao bater em parede/borda). Morre com 1 pulo em cima.
  - **Obstáculo estático:** Area2D que causa dano por contato (buracos, lixo, cercas). Não se move, não morre.
- **D-07:** Ao morrer, inimigos resetam para posições originais (junto com o respawn da Natália no checkpoint).

### Checkpoints (WORLD-03, WORLD-05, SAVE-01)
- **D-08:** Visual do checkpoint: cartaz/logo da banda McFly — presente em todas as 4 cenas do Mundo 1 com destaque no ambiente. Ao ativar (Natália passa por cima/toca), o cartaz pulsa/brilha.
- **D-09:** 1 checkpoint por fase (no meio). Total: 4 checkpoints no Mundo 1.
- **D-10:** Respawn: Natália reaparece no checkpoint ativo em < 500ms via `SceneTransition` ou respawn direto sem fade. Inimigos resetam. Provas já coletadas **permanecem** (salvas no `SaveManager` ao coletar).
- **D-11:** `checkpoint_id` format: `"mundo1_fase{N}_cp1"` — gravado via `SaveManager.set_checkpoint()` ao ativar.

### Sistema de Provas (BOSS-01)
- **D-12:** Provas são itens coletáveis espalhados nas Fases 1-3 (não na fase do boss). Aparecem como objetos brilhantes/piscando (foto, carta, presente). Natália coleta passando por cima — sem input especial.
- **D-13:** Mínimo de 2 provas obrigatórias para abrir o diálogo do boss. 1 prova extra opcional (facilita margem de erro).
- **D-14:** Inventário de provas **não aparece** durante as fases. Só revelado na cena do boss.
- **D-15:** Provas salvas em `SaveManager.current_save["provas_mundo1"]` (array de IDs) ao coletar. Não se perdem com morte.

### Boss: O Pai Desconfiante (BOSS-01)
- **D-16:** Nome do boss: **Luis** (pai real da Natália). Sprite de boss na cena (personagem grande no cenário) + caixas de diálogo Dialogic sobrepostas.
- **D-17:** Mecânica: misto de provas + diálogo de múltipla escolha. Natália apresenta provas coletadas → cada prova sobe a barra de confiança. Respostas certas no diálogo também sobem. Respostas erradas diminuem %.
- **D-18:** A fase do boss é **puramente narrativa** — sem dano físico à Natália durante a conversa.
- **D-19:** UI customizada sobreposta ao Dialogic: barra de confiança visível durante o diálogo. HUD simples no topo da tela.
- **D-20:** Se a barra de confiança esvaziar = game over do boss → volta ao último checkpoint da fase do boss (barra reseta, provas mantidas).
- **D-21:** Vitória (barra 100%): cutscene Dialogic — Luis cede, aceita Renato na família. Renato aparece na cena como "prova final" (~80% da barra).
- **D-22:** Cenário do boss: casa dos pais da Natália em Osasco (sala de estar). Trilha sonora própria para a cena do boss (tensa/emocional — placeholder por enquanto).
- **D-23:** Luis aparece **escondido no cenário da Fase 3** (Restaurante) como foreshadowing — um NPC no fundo espiando enquanto Natália e Renato estão no encontro.

### NPC Renato (NPC-01)
- **D-24:** Renato aparece em:
  - Fase 2 (Parque): sprite de NPC no fundo do cenário, sem diálogo ou com linha simples.
  - Fase 3 (Restaurante): NPC ativo com diálogo (encontro amoroso). Dialogic timeline própria.
  - Boss finale (~80% barra): entra na cena como prova definitiva com diálogo via Dialogic.
- **D-25:** Sprite do Renato: reutiliza o portrait já criado na Phase 2 (`assets/sprites/portraits/renato_portrait.png`). Sprite de NPC no cenário será versão simplificada.

### SFX (AUDIO-02)
- **D-26:** Abordagem Phase 3: SFX placeholder gerados com bfxr/sfxr (chiptune). Sons reais entram na Phase 12 (Polish).
- **D-27:** SFX necessários para Mundo 1: pulo (verificar se existe da Phase 1), dano recebido, ativação de checkpoint, morte da Natália, coleta de prova, morte de inimigo (stomp), diálogo (beep de texto). Trilha do Mundo 1 e trilha do boss: placeholders .ogg silenciosos ou loop simples.

### Claude's Discretion
- Quantidade exata de malandros e obstáculos por fase (nível de dificuldade)
- Posicionamento preciso de checkpoints, provas e inimigos no level design
- Implementação do tileset de Osasco (TileMapLayer com tiles placeholder geométricos)
- Duração e velocidade das animações do boss sprite
- Exata mecânica de apresentação de provas no boss (tecla dedicada ou automático ao entrar na cena)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Projeto e Requisitos
- `.planning/REQUIREMENTS.md` — WORLD-01, WORLD-02, WORLD-03, WORLD-05, BOSS-01, NPC-01, NARR-05, AUDIO-02 com success criteria.
- `.planning/ROADMAP.md` §Phase 3 — Goal, success criteria e dependências.
- `.planning/PROJECT.md` — Stack técnico, referências visuais, descrição narrativa do Mundo 1 e personagens.

### Código Existente (Phase 1 + Phase 2)
- `scenes/player/player.gd` — Física completa: pulo, dash, knockback, animações. A mecânica de "pulo em cima = matar inimigo" deve detectar colisão pelo topo do player.
- `autoloads/save_manager.gd` — `set_checkpoint(id)`, `save_game()`, `current_save` dict. Provas salvas em `current_save["provas_mundo1"]`.
- `autoloads/scene_transition.gd` — `go_to(scene_path)` para transições entre fases.
- `scenes/main_menu/main_menu.gd` — Fluxo New Game / Continue → deve redirecionar para cutscene de abertura do Mundo 1 após Phase 3.
- `dialogic/characters/Natalia.dch` e `dialogic/characters/Renato.dch` — Personagens já configurados com portraits.
- `scenes/test_dialogue/test_dialogue.tscn` — Referência de como integrar Dialogic com StartButton.

### Referências Visuais
- `assets/sprites/portraits/natalia_portrait.png` (64×80) e `assets/sprites/portraits/renato_portrait.png` (64×80) — reutilizar nos diálogos.
- `assets/sprites/natalia_spritesheet.png` (192×32, 6 frames) — sprite da jogável.

### Contexto de Fases Anteriores
- `.planning/phases/02-infraestrutura/02-CONTEXT.md` — Decisões de SaveManager, Dialogic, controles e padrões de código (CPUParticles2D, `create_timer(true)`, knockback).
- `.planning/STATE.md` — Stack e decisões acumuladas do projeto.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `player.gd`: Detecção de "pulo em cima de inimigo" = verificar `velocity.y > 0` + colisão com inimigo pelo `get_slide_collision()`. Bounce após stomp via `velocity.y = jump_velocity * 0.6`.
- `SaveManager`: `current_save["provas_mundo1"]` (array) + `SaveManager.save_game()` para persistir provas ao coletar.
- `SceneTransition.go_to()`: já suporta fade in/out — usar para transições entre as 4 cenas do Mundo 1.
- Dialogic 2 com `Dialogic.start("timeline_name")`: usar para texto de abertura, diálogos do Renato e boss.
- `autoloads/controls_manager.gd`: bindings `walk_left`, `walk_right`, `jump`, `dash` — nenhuma nova ação de input para combate.

### Established Patterns
- **CPUParticles2D** obrigatório (nunca GPUParticles2D) — renderer Compatibility para web.
- **`create_timer(duration, true)`** — `process_always=true` obrigatório para hit-stop.
- **`velocity.x = _knockback.x`** (não `+=`) — padrão de knockback sem acumulação.
- **`_physics_process` a 60Hz com frame counters** — padrão do projeto para timing.
- **Warnings-as-errors ativo** — tipos explícitos obrigatórios (ex: `var x: String =`, não `var x :=` com Variant).
- **TileMapLayer** (Godot 4.4+) para level design — cada layer tem seu próprio nó. Tiles placeholder geométricos aceitáveis para Phase 3.

### Integration Points
- `main_menu.gd` `_on_new_game_confirmed` / `_on_continue_pressed`: devem apontar para a cutscene de abertura do Mundo 1 ou `fase1_rua.tscn` após Phase 3.
- Checkpoint node: Area2D com sinal `body_entered` → chama `SaveManager.set_checkpoint(id)` + animação.
- Prova coletável: Area2D com sinal `body_entered` → adiciona ao array de provas + `SaveManager.save_game()` + remove do cenário.
- Boss scene: CanvasLayer com barra de confiança (Control/ProgressBar) sobre Dialogic (CanvasLayer 1) — usar CanvasLayer 2 para não ser bloqueado (padrão estabelecido com SkipButton na Phase 2).

</code_context>

<specifics>
## Specific Ideas

### Checkpoint Visual — McFly
- Checkpoints são cartazes/logos da banda McFly espalhados nos cenários com destaque visual (maior que elementos de fundo, cor diferenciada). Ao ativar, o cartaz pulsa ou acende. Referência pessoal do desenvolvedor — deve aparecer em todas as 4 cenas do Mundo 1.

### Luis (O Pai Desconfiante) — foreshadowing
- Na Fase 3 (Restaurante), Luis aparece **escondido no fundo do cenário** (sentado a uma mesa distante, parcialmente oculto) enquanto Natália e Renato estão no encontro. Não interage — apenas aparece visualmente. Jogadores atentos o verão antes do boss fight.

### Duas casas de Osasco
- **Casa dos pais da Natália** (usada no boss fight com Luis): cenário da fase 4/boss — sala de estar, ambiente doméstico.
- **Casa/apartamento do casal** (após casamento): cena futura, fora do escopo da Phase 3. Será usada na mecânica de "decorar com orçamento" em fase futura.

### Renato no Boss
- Renato entra na cena do boss como "prova definitiva" quando a barra de confiança chega ~80%. Aparece pela porta/janela com sprite de NPC + diálogo de comprometimento via Dialogic.

### Narrativa expandida pós-Mundo 1
- Após o boss, a jornada da Natália continua: praia → parque no Chile (pedido de casamento por Renato) → casamento → apartamento em Osasco → emprego (inimigos: clientes chatos e gerentes horríveis) → Espanha. Esses arcos mapeiam para os Mundos 2-8 do roadmap. Não são escopo da Phase 3.

</specifics>

<deferred>
## Deferred Ideas

- **Fase da Casa com orçamento (Sims/Stardew)** — Natália e Renato decoram o apartamento do casal com orçamento limitado. Mecânica de colocação de móveis/objetos. Pertence a um mundo futuro (pós-casamento), fora do escopo do Phase 3.
- **Sprites definitivos dos inimigos** — Malandros e obstáculos usarão placeholder geométrico/colorido na Phase 3. Arte pixel art real entra na Phase 12.
- **Trilha sonora temática do Mundo 1** — Placeholder .ogg na Phase 3. Composição real entra na Phase 12.
- **SFX reais** — bfxr/sfxr chiptune para Phase 3. Sons reais do Freesound.org na Phase 12.
- **Prompts de botão por marca (DualSense/Xbox)** — Phase 12 Polish (herdado da Phase 2).
- **Tileset visual detalhado de Osasco** — Tiles com arte pixel art elaborada ficam para Polish. Phase 3 usa tiles geométricos com paleta correta.
- **Nome real do Pai (Luis) e sensibilidade** — Usando nome real conforme decisão do desenvolvedor (baseado em pessoa real). Revisar antes do release público.

</deferred>

---

*Phase: 3-mundo-1-osasco-vertical-slice-completo*
*Context gathered: 2026-06-08*
