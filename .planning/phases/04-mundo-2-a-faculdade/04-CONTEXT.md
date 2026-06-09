# Phase 4: Mundo 2 — A Faculdade - Context

**Gathered:** 2026-06-09
**Status:** Ready for planning

<domain>
## Phase Boundary

Implementar o segundo mundo jogável completo: cutscene de abertura + 3 fases lineares do campus universitário de Arquitetura e Urbanismo + boss "Banca do TFG" com mecânica de qualidade progressiva. Introduzir sistema de HP (3 PV), 3 novos tipos de inimigos, itens coletáveis de TFG (partes do trabalho real da Natália), o poder Sketch (projétil retroativo) e o poder Amor (desbloqueado retroativamente pelo boss do Mundo 1). Sistema de poderes persistente com seleção por tecla única.

</domain>

<decisions>
## Implementation Decisions

### Estrutura das Fases (WORLD-01, WORLD-02)
- **D-01:** Mundo 2 tem 4 scenes conectadas via `SceneTransition.go_to()` (mesmo padrão do Mundo 1):
  1. `scenes/world2/mundo2_abertura.tscn` — cutscene de abertura (reutiliza padrão de mundo1_abertura.gd)
  2. `scenes/world2/fase1_campus.tscn` — campus externo, praça, corredores; Renato aparece como NPC
  3. `scenes/world2/fase2_atelie.tscn` — ateliê interno, bancadas, maquetes
  4. `scenes/world2/fase3_madrugada.tscn` — laboratório de madrugada, Prof. Careca + impressoras; Renato traz café
  5. `scenes/world2/boss_tfg.tscn` — banca do TFG com mecânica de qualidade
- **D-02:** Texto de abertura do Mundo 2: tom exaustão + esperança — noites sem dormir, maquetes que desabam, mas amizade e descoberta de talento.
- **D-03:** Paleta visual: bege/creme de ateliê, caótico mas colorido, papéis voando, projetos coloridos espalhados. Mais vivo e criativo que o Mundo 1 (cinza urbano).
- **D-04:** Trilha: loop OGG chiptune placeholder, BPM alto, agitado e caótico.
- **D-05:** Dificuldade: um pouco mais difícil que o Mundo 1.
- **D-06:** Checkpoint visual do Mundo 2: caneca de café (substitui o cartaz McFly do Mundo 1). Piscar/brilhar ao ativar.

### Sistema de HP (novo a partir do Mundo 2)
- **D-07:** Natália tem 3 PV. HUD simples de corações/ícones no topo da tela. Aplica a TODOS os mundos a partir do Mundo 2 em diante.
- **D-08:** Recuperação: ativar checkpoint (+1 PV) + itens de café/lanche coletáveis nas fases (+1 PV). Renato traz café na Fase 3 (NPC de cura).
- **D-09:** Mundo 1 mantém comportamento atual (1 hit = morte — sem retroatividade do sistema de HP).

### Inimigos do Campus
- **D-10:** Maquete Rústica: floor trap estático (base no StaticObstacle). Area2D no chão — pisando em cima = 1 dano. Sprite de maquete fragmentada (sem indicador especial de perigo — só design visual de "peça caindo"). Não patrulha, não morre.
- **D-11:** Impressora Raivosa: NPC estático, dispara 1 folha de papel horizontalmente de forma periódica (a cada ~2s). Projétil (Area2D) some ao bater na parede/borda da fase. Pode ser morta com stomp (base no Malandro — reskin).
- **D-12:** Professor Careca: NPC estático em posição fixa (plataforma ou chão elevado), lança "comentários" a cada ~2s que caem no chão e rastejam (homing simples) em direção à Natália. Intocável (não morre com stomp — é um obstáculo de cenário). Comentários desaparecem ao atingir a Natália ou ao sair da fase.
- **D-13:** Renato como NPC de cura na Fase 3: aparece fixo com sprite, ao se aproximar dá +1 PV com diálogo curto "trouxe café". Mesmo padrão de renato_npc.gd.

### Boss: Banca do TFG (BOSS-02)
- **D-14:** Boss puramente narrativo (sem dano físico à Natália durante a banca). Mesma arquitetura do boss_pai.gd com HUD customizado (barra de Qualidade em vez de barra de Confiança).
- **D-15:** Pré-requisito: mínimo 3 de 5 itens do TFG coletados nas fases 1-3. Sem os 3 itens, mensagem bloqueante + retorno à fase 3.
- **D-16:** 5 Itens coletáveis do TFG (partes do trabalho real da Natália — "Completing the Street: Urban Project for the Retail Commercial Hub of Oriente Street in Brás"):
  1. **Pesquisa de Campo** (fase 1 — campus)
  2. **Masterplan Urbano** (fase 1 — campus)
  3. **Complexo Misto** (fase 2 — ateliê)
  4. **Análise de Fluxos Humanos** (fase 2 — ateliê)
  5. **Princípios de Sustentabilidade** (fase 3 — madrugada)
  - Sprites únicos por item (não genérico). Coletados por contato (mesmo padrão de prova_item.gd). Salvos em `SaveManager.current_save["itens_tfg_mundo2"]`.
- **D-17:** Banca: Professor Perpétuo (com diálogo) + 2 NPCs genéricos sem linha.
- **D-18:** Mecânica da barra de Qualidade:
  - Sobe: cada item do TFG apresentado (+15-20%), cada escolha correta no diálogo (+10%)
  - Desce: escolhas erradas no diálogo (-15%)
  - Professor Perpétuo "adiciona requisito": sobe o alvo mínimo (ex: 70% → 85%) durante a banca
  - Derrota: barra < 70% ao fim da banca
  - Vitória: barra ≥ 100%
- **D-19:** Cutscene de vitória: banca aprova, colegas comemoram, Renato aparece. Sketch desbloqueado automaticamente após a cena (save atualizado).
- **D-20:** Itens do TFG salvos em `SaveManager.current_save["itens_tfg_mundo2"]` (array de IDs). Não se perdem com morte.

### Poderes (POWER-01, POWER-08)
- **D-21:** Poder Amor (desbloqueado ao derrotar o boss do Mundo 1 — implementado retroativamente nesta fase):
  - Tecla: Z (mesma que Sketch — usa sistema de poder ativo)
  - Mecânica: bolha/aura rotativa que circula ao redor da Natália por ~2s. Qualquer inimigo que tocar morre.
  - Cooldown: 3-4s. Sem munição.
  - Desbloqueado: boss_pai.gd atualizado para registrar `"amor"` em `powers_unlocked[]` na vitória.
- **D-22:** Poder Sketch (desbloqueado após boss TFG):
  - Tecla: Z (poder ativo)
  - Input: nova ação `use_power` no InputMap — Z (teclado), X (gamepad)
  - Projétil: folha de papel dobrada (sprite 12x12px), voa horizontalmente na direção que a Natália está virada
  - Dano: 1 hit kill em qualquer inimigo normal
  - Alcance: linear até bater em parede/borda da fase (some ao colidir)
  - Cooldown: 0.5s entre disparos. Sem munição.
  - Retroativo: disponível em todos os mundos após desbloqueado (POWER-08).
- **D-23:** Troca de poder ativo: Shift+Z cicla entre poderes desbloqueados.
- **D-24:** HUD de poderes: ícone do poder ativo no canto da tela. Cinza durante cooldown, colorido quando disponível. Sem barra de cooldown visual (só estado pronto/não pronto).
- **D-25:** Persistência: `SaveManager.current_save["active_power"]` (string ID do poder ativo) + `powers_unlocked[]` (já existe). SCHEMA_VERSION bump de 2 → 3.

### Progressão e Save
- **D-26:** Ao completar o Mundo 2: `worlds_completed[]` adiciona `"mundo2"`, `powers_unlocked[]` adiciona `"sketch"` e `"amor"` (se não estiver), `itens_tfg_mundo2` persiste.
- **D-27:** Após vitória do boss TFG → world2_end.tscn placeholder (igual ao world1_end.tscn do Mundo 1). Overworld vem na Phase 11.

### Claude's Discretion
- Posicionamento exato de inimigos, itens e checkpoints em cada fase
- Número exato de Professor Careca e Impressoras por fase (Claude escolhe balanceamento)
- Timing exato dos ataques dos inimigos
- Animações dos inimigos novos (sprites placeholder geométricos OK)
- Diálogos exatos da banca (Claude cria linhas temáticas baseadas no TFG real da Natália)
- Quantidade e posição de itens de café/cura por fase

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Projeto e Requisitos
- `.planning/REQUIREMENTS.md` — BOSS-02, POWER-01, POWER-08 com success criteria
- `.planning/ROADMAP.md` §Phase 4 — Goal, success criteria, dependências
- `.planning/PROJECT.md` — narrativa do Mundo 2, personagens, descrição do TFG real

### Código Existente (base de reutilização)
- `scenes/world1/malandro.gd` — padrão de inimigo patrulheiro (base para Impressora com reskin + lógica de disparo)
- `scenes/world1/static_obstacle.gd` — padrão de obstáculo estático (base para Maquete Rústica)
- `scenes/world1/boss_pai.gd` — padrão de boss com HUD + Dialogic + barra de progresso + gate de itens mínimos
- `scenes/world1/prova_item.gd` + `prova_item.tscn` — padrão de item coletável (base para itens do TFG)
- `scenes/world1/checkpoint.gd` + `checkpoint.tscn` — padrão de checkpoint com SpriteFrames
- `scenes/world1/renato_npc.gd` — padrão de NPC com zona de diálogo
- `scenes/world1/fase1_rua.gd` — template de fase (checkpoint, enemy reset, exit trigger, respawn)
- `scenes/world1/mundo1_abertura.gd` + `mundo1_abertura.tscn` — padrão de cutscene de abertura de mundo
- `scenes/world1/world1_end.gd` + `world1_end.tscn` — padrão de tela de fim de mundo
- `autoloads/save_manager.gd` — `powers_unlocked[]`, `worlds_completed[]`, `set_checkpoint()`, `mark_cutscene_seen()`. Schema version a bumpar de 2 → 3.
- `autoloads/audio_manager.gd` — `register_sfx()`, `play_sfx()`. Novos SFX do Mundo 2 a registrar.
- `autoloads/scene_transition.gd` — `go_to()` para transições entre fases

### Contexto de Fases Anteriores
- `.planning/phases/03-mundo-1-osasco-vertical-slice-completo/03-CONTEXT.md` — decisões de padrão de mundo (phases, checkpoints, provas, boss, SFX)
- `.planning/STATE.md` — decisões acumuladas do projeto (CPUParticles2D, create_timer(true), etc.)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `malandro.gd`: patrol enemy base — reutilizar para Impressora (trocar lógica de patrol por lógica de disparo periódico)
- `static_obstacle.gd`: Area2D damage — reutilizar para Maquete Rústica (sem mudança de script, só novo sprite)
- `prova_item.gd`: collectible item — reutilizar para itens TFG (mesmo padrão, sprites únicos)
- `boss_pai.gd`: boss com barra de progresso, gate mínimo, Dialogic timelines — base direta para boss_tfg.gd
- `mundo1_abertura.gd`: auto-start Dialogic + has_seen_cutscene + SceneTransition — copiar para mundo2_abertura.gd

### Established Patterns
- `StaticBody2D` como piso (não TileMapLayer physics) — obrigatório no Godot 4.4
- `sub_resource` ANTES de qualquer `[node]` em .tscn — regra crítica do formato 3
- `CPUParticles2D` (nunca GPUParticles2D) — renderer gl_compatibility
- `create_timer(duration, true)` com `process_always=true` para hit-stop
- `set_deferred("disabled", true)` para CollisionShape2D — physics safety
- `_stomped_this_frame` flag para evitar double-hit no stomp

### Integration Points
- `player.gd` precisa de: variável `_current_power: String`, `_power_cooldown_timer`, método `use_power()` e `unlock_power(id)`
- `save_manager.gd` precisa de: `active_power: ""` e `itens_tfg_mundo2: []` no `_default_save()`, SCHEMA_VERSION 3
- `project.godot` InputMap precisa de: nova ação `use_power` (Z + gamepad X) e `cycle_power` (Shift+Z)
- `boss_pai.gd` precisa de: linha `SaveManager.current_save["powers_unlocked"].append("amor")` na `_trigger_victory()`

</code_context>

<specifics>
## Specific Ideas

- **TFG real da Natália**: "Completing the Street: Urban Project for the Retail Commercial Hub of Oriente Street in Brás, SP". Foco em escala humana, acessibilidade, walkability, Masterplan urbano com diretrizes de design, Complexo Misto, análise de fluxos humanos, sustentabilidade, inclusão. Os 5 itens coletáveis devem referenciar aspectos reais deste trabalho.
- **Checkpoint = caneca de café**: sprite de caneca que brilha/piscas ao ativar. Mais afetuoso que o McFly, reflete as madrugadas no ateliê.
- **Renato traz café na Fase 3**: NPC estático que ao se aproximar dá +1 PV com linha de diálogo "Trouxe café pra te ajudar a terminar 💛" (ou similar).
- **Professor Perpétuo aumenta o alvo da barra**: não retira itens — apenas move o goalpost de "passar" mais alto durante a banca.

</specifics>

<deferred>
## Deferred Ideas

- Sistema de HP para o Mundo 1 retroativo — decidido manter 1 hit = morte no Mundo 1 para manter o padrão original.
- Overworld (mapa-mundo) — Phase 11.
- Cenas de revisita dos mundos anteriores com Sketch disponível — funcionará automaticamente após POWER-08 implementado.
- Sons reais (não chiptune) para o Mundo 2 — Phase 12 Polish.
- Sprites reais baseados em fotos de Natália, Renato, etc. — aguardando fotos do usuário.

</deferred>

---

*Phase: 4-mundo-2-a-faculdade*
*Context gathered: 2026-06-09*
