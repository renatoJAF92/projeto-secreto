# Roadmap — Jogo da Natália

## Project

**Core value:** Um jogo de plataforma 2D em pixel art que conta a história real de Natália — de Osasco à Espanha — como homenagem jogável, com mecânicas sólidas e narrativa emocional em 8 mundos.

**Mode:** Vertical MVP — cada fase entrega uma fatia jogável e testável.

---

## Phases

### Milestone v1.0 — Mundos 1 e 2 (Release Inicial)

- [x] **Phase 0: Fundação** — Projeto Godot configurado, Git LFS ativo, renderer Compatibility definido, estrutura de pastas pronta.
- [x] **Phase 1: Game Feel** — Movimentação da protagonista polida e responsiva antes de qualquer level design.
- [x] **Phase 2: Infraestrutura** — Save system, transições de cena, signal bus, Dialogic 2 integrado, controles reconfiguráveis.
- [x] **Phase 3: Mundo 1 — Osasco (vertical slice completo)** — Fases jogáveis, chefe O Pai Desconfiante, diálogos, padrão de mundo estabelecido.
- [ ] **Phase 4: Mundo 2 — A Faculdade** — Mundo completo + poder Sketch desbloqueado. *(Planned — 5 plans, cross-AI reviewed 2026-06-09)*
- [ ] **Phase 5: Level Design Overhaul** — Fases dos Mundos 1 e 2 expandidas: 6400px, mecânicas ambientais, inimigos ricos e arte melhorada.
- [x] **Phase 6: Menu & UX Polish** — Menu principal com background, música e popup customizada; menu de opções com sliders de volume; pause menu em-jogo com ESC.
- [ ] **Phase 7: v1.0 Polish & Release** — Bug fixes finais, build HTML5 + Windows validada, publicação itch.io com Mundos 1 e 2 completos.

### Milestone v2.0+ — Mundos 3–8 (Expansões pós-release)

- [ ] **Phase 8: Mundo 3 — O Corporativo** — Mundo completo + poder Mapa Urbano desbloqueado.
- [ ] **Phase 9: Mundo 4 — A Pandemia** — Mundo completo + poder Escudo Blueprint + cachorra companheira.
- [ ] **Phase 10: Mundo 5 — Santiago e os Votos** — Mundo completo + poder Amor Power + cutscene da proposta.
- [ ] **Phase 11: Mundo 6 — Tossa de Mar** — Mundo completo + poder Cerâmica desbloqueado.
- [ ] **Phase 12: Mundo 7 — Vilanova i la Geltrú** — Mundo completo + poder UX Flow desbloqueado.
- [ ] **Phase 13: Mundo 8 — Zaragoza (finale)** — Mundo completo + Combo Final + ending com fotos reais.
- [ ] **Phase 14: Overworld e NPCs Secundários** — Mapa-mundo navegável, NPCs de suporte por mundo, experiência de progressão conectada.
- [ ] **Phase 15: Polish, Acessibilidade e Release Final** — Assist Mode, trilhas sonoras completas, builds PC/web de todos os 8 mundos.

---

## Phase Details

### Phase 0: Fundação
**Goal:** O projeto Godot 4 existe, compila sem erros, exporta para web com renderer Compatibility e está versionado com Git LFS configurado para assets binários.
**Mode:** mvp
**Depends on:** Nothing
**Requirements:** EXPORT-03
**Success Criteria:**
1. `godot --export-release "Web" ...` gera um build HTML5 que abre no navegador sem erro.
2. Git LFS está ativo e arquivos `.png`, `.wav`, `.ogg` são rastreados via LFS (confirmado com `git lfs ls-files`).
3. Estrutura de pastas (`scenes/`, `assets/sprites/`, `assets/audio/`, `scripts/`, `.planning/`) está criada e commitada.
4. Renderer Compatibility está definido em Project Settings e persiste após reabrir o projeto.
**Plans:** 4 planos (sequenciais)

**Wave 1**
- [x] 00-001-git-lfs-scaffold-PLAN.md — Git LFS + estrutura de pastas + .gitignore + .gitattributes + serve.py

**Wave 2** *(blocked on Wave 1 completion)*
- [x] 00-002-godot-project-PLAN.md — Instalação Godot 4.4.x + project.godot com Compatibility renderer + cena main.tscn

**Wave 3** *(blocked on Wave 2 completion)*
- [x] 00-003-export-presets-PLAN.md — Export presets (Web/Windows/macOS) + teste de export local no navegador

**Wave 4** *(blocked on Wave 3 completion)*
- [x] 00-004-github-actions-PLAN.md — GitHub Actions CI/CD pipeline com export automático e deploy itch.io

**Cross-cutting constraints:**
- Git LFS deve estar instalado antes de qualquer commit de asset binário (todas as waves)
- Renderer Compatibility (`gl_compatibility`) deve persistir em project.godot (EXPORT-03)

### Phase 1: Game Feel
**Goal:** A protagonista Natália se move com precisão e satisfação — coyote time, jump buffer, dash, knockback, animações e juice visual funcionando — antes de qualquer fase ser construída.
**Mode:** mvp
**Depends on:** Phase 0
**Requirements:** MOVE-01, MOVE-02, MOVE-03, MOVE-04, MOVE-05
**Success Criteria:**
1. Jogadora corre, pula e cai com coyote time de 6 frames e jump buffer de 8 frames funcionando (testado em plataforma com borda).
2. Dash horizontal está disponível e controlável; o input responde dentro de 1 frame.
3. Ao tomar dano, a Natália recebe knockback visível e exibe flash branco; hit-stop de 2-4 frames congela a ação brevemente.
4. Todas as 6 animações (idle, run, jump, fall, hurt, death) tocam nos estados corretos sem artefatos de transição.
5. Poeira ao aterrissar e squash/stretch no pulo são visíveis em test scene sem outros elementos de gameplay.
**Plans:** 3/3 plans executed — **COMPLETE** (2026-06-04)

**Wave 1**
- [x] 01-001-core-movement-PLAN.md — Movimento base, gravidade assimétrica, coyote time, jump buffer, InputMap + test scene

**Wave 2** *(blocked on Wave 1)*
- [x] 01-002-dash-knockback-animations-PLAN.md — Dash horizontal, knockback ao tomar dano, máquina de 6 animações + SpriteFrames placeholder

**Wave 3** *(blocked on Wave 2)*
- [x] 01-003-juice-effects-PLAN.md — Poeira (CPUParticles2D), squash/stretch, flash branco, hit-stop + verificação final da fase
**UI hint:** yes

### Phase 2: Infraestrutura
**Goal:** O jogo salva progresso automaticamente, transita entre cenas sem tela preta travada, exibe diálogos via Dialogic 2, e permite ao jogador reconfigurar controles e usar gamepad.
**Mode:** mvp
**Depends on:** Phase 1
**Requirements:** SAVE-01, SAVE-02, SAVE-03, NARR-01, NARR-02, ACCESS-02, ACCESS-03, NPC-04
**Success Criteria:**
1. Fechar e reabrir o jogo após alcançar um checkpoint restaura a posição correta; poderes e cutscenes vistos persistem.
2. Tela inicial apresenta opções "Continue" e "New Game"; "Continue" está desativado sem save existente.
3. Uma caixa de diálogo Dialogic 2 exibe texto com retrato de personagem, avança com input do jogador e é pulável via botão dedicado.
4. Jogador pode remapear qualquer tecla no menu de opções; gamepad (DualSense/Xbox) controla a protagonista sem configuração extra.
5. Sprite placeholder da Natália (NPC-04) está definido como asset de referência no projeto (sprite sheet com animações).
**Plans:** TBD
**UI hint:** yes

### Phase 3: Mundo 1 — Osasco (vertical slice completo)
**Goal:** O jogador experimenta um mundo completo: 2-3 fases temáticas de Osasco, checkpoints funcionais, respawn instantâneo, chefe O Pai Desconfiante com condição de vitória não-violenta, diálogos de abertura e NPC Renato em cena.
**Mode:** mvp
**Depends on:** Phase 2
**Requirements:** WORLD-01, WORLD-02, WORLD-03, WORLD-05, BOSS-01, NPC-01, NARR-05, AUDIO-02
**Success Criteria:**
1. Mundo 1 tem 2-3 fases jogáveis com paleta cinza-urbana de Osasco e inimigos temáticos (malandros, obstáculos do bairro).
2. Checkpoints visuais salvam posição automaticamente; morte respawna em menos de 500ms no checkpoint mais próximo.
3. O Pai Desconfiante é derrotável apenas por diálogo/prova — dano direto não o mata; condição de vitória é verificável.
4. Texto narrativo de abertura do Mundo 1 é exibido antes da primeira fase.
5. SFX de pulo, dano, checkpoint e power-up tocam nos momentos corretos durante o gameplay do Mundo 1.
6. NPC Renato aparece em pelo menos um ponto do Mundo 1 com diálogo funcional.
**Plans:** 5 planos (sequenciais, 1 por wave)

**Wave 1**
- [x] 03-01-PLAN.md — Foundation: AudioManager autoload, player `signal died` + "player" group, save schema `provas_mundo1`

**Wave 2** *(blocked on Wave 1)*
- [x] 03-02-PLAN.md — Reusable game objects: Malandro, StaticObstacle, Checkpoint (McFly), ProvaItem

**Wave 3** *(blocked on Waves 1-2)*
- [x] 03-03-PLAN.md — Playable phases fase1/fase2/fase3 + Osasco tileset + instant respawn + Renato/Luis NPCs

**Wave 4** *(blocked on Waves 1, 3)*
- [x] 03-04-PLAN.md — Boss O Pai Desconfiante: trust-bar HUD + Dialogic timelines + Renato entrance + win/lose

**Wave 5** *(blocked on Waves 1, 3, 4)*
- [x] 03-05-PLAN.md — Opening narrative + main_menu wiring + SFX registration + world1_end + human-verify
**UI hint:** yes

### Phase 4: Mundo 2 — A Faculdade
**Goal:** O jogador percorre o campus caótico da faculdade, enfrenta o Professor Perpétuo e desbloqueia o poder Sketch — que persiste e pode ser usado nos mundos seguintes.
**Mode:** mvp
**Depends on:** Phase 3
**Requirements:** BOSS-02, POWER-01
**Success Criteria:**
1. Mundo 2 tem fases com cenário de campus/ateliê e inimigos temáticos (maquetes animadas, impressoras trancadas).
2. O Professor Perpétuo adiciona requisitos extras à fase durante o combate; o jogador pode completar o chefe mesmo com requisitos acumulados.
3. Após derrotar o chefe, poder Sketch é desbloqueado: projétil de esboços dispara corretamente e causa dano aos inimigos.
4. Sketch permanece disponível ao carregar save e pode ser usado em fases anteriores revisitadas.
**Plans:** TBD
**UI hint:** yes

### Phase 5: Level Design Overhaul
**Goal:** Expandir e aprofundar as 6 fases dos Mundos 1 e 2 com tamanho quadruplicado (6400px), mecânicas ambientais, variantes de inimigos e arte melhorada com silhuetas reconhecíveis e fundos com paralaxe — antes de construir qualquer mundo novo.
**Mode:** mvp
**Depends on:** Phase 4
**Requirements:** (quality overhaul — sem req-id formal)
**Success Criteria:**
1. Todas as 6 fases dos Mundos 1 e 2 têm 6400px de largura com 1 checkpoint no meio (3200px).
2. Cada fase tem pelo menos 2 seções temáticas distintas com composições de inimigos diferentes.
3. Inimigo Moto com Dois Homens funciona nas 3 fases do Mundo 1 com comportamento de 2 fases (passageiro → piloto).
4. Variantes de inimigos presentes: pelo menos 1 variante 2-hit e 1 variante dash-only por mundo.
5. Todas as 4 mecânicas ambientais (plataformas móveis, zonas de dano passivo, objetos empurráveis, obstáculos temporizados) aparecem em pelo menos 1 fase cada.
6. Arte melhorada: inimigos com silhuetas reconhecíveis (Polygon2D multi-peça); cada fase tem pelo menos 1 camada de paralaxe no fundo.
**Plans:** TBD
**UI hint:** yes

### Phase 6: Mundo 3 — O Corporativo
**Goal:** O jogador navega pelas torres opressivas de SP, derrota o Gestor Tóxico sem perder HP de saúde mental e desbloqueia Mapa Urbano para revelar caminhos ocultos.
**Mode:** mvp
**Depends on:** Phase 5
**Requirements:** BOSS-03, POWER-02
**Success Criteria:**
1. Mundo 3 tem fases com cenário corporativo (torres, e-mails voadores, reuniões-fantasma) e paleta opressiva de cinza.
2. Gestor Tóxico drena uma barra de HP de saúde mental separada da vida normal; condição de derrota é perder esse HP — testável em playthrough.
3. Após derrotar o chefe, poder Mapa Urbano revela visualmente caminhos ocultos já presentes na geometria das fases.
4. Mapa Urbano persiste no save e funciona em fases dos mundos 1-3 revisitadas.
**Plans:** TBD
**UI hint:** yes

### Phase 7: Mundo 4 — A Pandemia
**Goal:** O jogador atravessa ruas vazias e enfrenta o Vírus Chefão de tela inteira, desbloqueia o Escudo Blueprint e ganha a cachorra como companheira permanente a partir deste mundo.
**Mode:** mvp
**Depends on:** Phase 6
**Requirements:** BOSS-04, POWER-03, NPC-02
**Success Criteria:**
1. Mundo 4 tem fases com cenário de isolamento (ruas vazias, apartamento, máscaras) e paleta escura.
2. Vírus Chefão ocupa tela inteira e suas partículas se multiplicam se não eliminadas a tempo — mecânica funcionando.
3. Fase de adoção da cachorra é jogável: tutorial completa e a cachorra passa a acompanhar a Natália como NPC invencível.
4. A cachorra corre à frente alertando inimigos e pode atacar inimigos pequenos — comportamento observável em gameplay.
5. Poder Escudo Blueprint cria escudo temporário visível que bloqueia projéteis por sua duração.
**Plans:** TBD
**UI hint:** yes

### Phase 8: Mundo 5 — Santiago e os Votos
**Goal:** O jogador navega burocracia e romance, assiste à cutscene da proposta em Santiago, derrota A Burocracia e desbloqueia Amor Power — invencibilidade conjunta com Renato.
**Mode:** mvp
**Depends on:** Phase 7
**Requirements:** BOSS-05, POWER-04, NARR-03
**Success Criteria:**
1. Mundo 5 tem fases com cenário de cartório/aeroporto/Santiago e inimigos de burocracia (carimbos, formulários voadores).
2. Chefe A Burocracia tem múltiplas fases com formulários voadores e carimbos inimigos; derrota requer completar todas as fases do chefe.
3. Cutscene de proposta em Santiago toca automaticamente na posição correta da narrativa, é pulável após primeira exibição e `seen_cutscenes` regista que foi vista.
4. Poder Amor Power ativa invencibilidade breve quando Renato está próximo na cena — testável em combat encounter específico.
**Plans:** TBD
**UI hint:** yes

### Phase 9: Mundo 6 — Tossa de Mar
**Goal:** O jogador experimenta o primeiro respiro da jornada na costa catalã, derrota a Barreira do Idioma via mini-game de vocabulário e desbloqueia poder Cerâmica.
**Mode:** mvp
**Depends on:** Phase 8
**Requirements:** BOSS-06, POWER-05
**Success Criteria:**
1. Mundo 6 tem fases com paleta colorida de mar e sol (contraste visual claro em relação aos mundos anteriores).
2. Chefe Barreira do Idioma integra mini-game de vocabulário espanhol: resposta errada penaliza, resposta correta causa dano ao chefe.
3. Poder Cerâmica dispara projéteis de cerâmica com pelo menos 2 variações de tipo que causam efeitos distintos.
4. Cerâmica persiste no save e funciona nos mundos seguintes.
**Plans:** TBD
**UI hint:** yes

### Phase 10: Mundo 7 — Vilanova i la Geltrú
**Goal:** O jogador enfrenta a frustração do mercado fechado, derrota O Mercado Fechado encontrando caminhos alternativos e desbloqueia UX Flow para alterar padrões de inimigos.
**Mode:** mvp
**Depends on:** Phase 9
**Requirements:** BOSS-07, POWER-06
**Success Criteria:**
1. Mundo 7 tem fases mistas (belas amizades vs. frustração profissional) refletidas no level design com seções de contraste.
2. Chefe O Mercado Fechado fecha portas antes do jogador chegar; solução exige encontrar caminhos alternativos já presentes na fase.
3. Poder UX Flow altera visualmente e funcionalmente o padrão de movimento dos inimigos por sua duração — observável em encounter de teste.
4. UX Flow persiste no save.
**Plans:** TBD
**UI hint:** yes

### Phase 11: Mundo 8 — Zaragoza (finale)
**Goal:** O jogador completa a jornada em Zaragoza, derrota O Medo da Mudança usando todos os poderes combinados no Combo Final e assiste ao ending com fotos reais de Renato e Natália.
**Mode:** mvp
**Depends on:** Phase 10
**Requirements:** BOSS-08, POWER-07, POWER-08, NARR-04
**Success Criteria:**
1. Chefe O Medo da Mudança exige uso de pelo menos 3 poderes anteriores em mecânicas combinadas para ser derrotado.
2. Combo Final ativa uma habilidade única que combina visualmente e funcionalmente os poderes anteriores — distinguível dos poderes individuais.
3. Todos os poderes (Sketch, Mapa Urbano, Blueprint, Amor Power, Cerâmica, UX Flow, Combo Final) persistem entre sessões após save (POWER-08 verificado em ciclo de fechar/reabrir).
4. Ending toca após derrota do chefe final: créditos exibem fotos reais de Renato e Natália integradas à cinemática pixel art.
**Plans:** TBD
**UI hint:** yes

### Phase 12: Overworld e NPCs Secundários
**Goal:** A progressão entre mundos acontece via mapa-mundo navegável com mundos desbloqueáveis, e cada mundo tem NPCs secundários com diálogos que enriquecem a narrativa.
**Mode:** mvp
**Depends on:** Phase 11
**Requirements:** WORLD-04, NPC-03
**Success Criteria:**
1. Mapa-mundo (overworld) é navegável; mundos desbloqueados aparecem acessíveis e mundos futuros aparecem bloqueados visualmente.
2. Entrar em um mundo a partir do overworld carrega a cena correta e retornar ao overworld preserva o estado de progresso.
3. Cada um dos 8 mundos tem pelo menos 1 NPC secundário com diálogo contextual (amiga da faculdade, colega da Urbanova, etc.).
4. NPCs secundários não bloqueiam o progresso — diálogos são opcionais e puláveis.
**Plans:** TBD
**UI hint:** yes

### Phase 13: Mundo 8 — Zaragoza (finale) *(renumbered from 11)*
*(ver "Phase 11" acima — numbers will be realigned when v2.0 planning starts)*
**Plans:** TBD

### Phase 14: Overworld e NPCs Secundários *(renumbered from 12)*
*(ver "Phase 12" acima)*
**Plans:** TBD

### Phase 15: Polish, Acessibilidade e Release Final *(renumbered from 13)*
**Goal:** O jogo completo (todos os 8 mundos) é jogável com Assist Mode, trilha sonora completa, e builds PC/web validadas.
**Mode:** mvp
**Depends on:** Phase 14
**Requirements:** ACCESS-01, AUDIO-01, EXPORT-01, EXPORT-02
**Success Criteria:**
1. Assist Mode acessível no menu de pause: velocidade 0.5x, invencibilidade e poderes infinitos.
2. Cada um dos 8 mundos tem trilha sonora temática distinta.
3. Build HTML5 carrega via itch.io sem crash em Chrome e Firefox.
**Plans:** TBD
**UI hint:** yes

---

### Phase 6: Menu & UX Polish
**Goal:** O menu principal funciona dentro do viewport 320×180 com popup customizado, background visual e música. Menu de opções tem controles de volume independentes para música e SFX. Qualquer fase do jogo pode ser pausada com ESC.
**Mode:** mvp
**Depends on:** Phase 5
**Requirements:** ACCESS-03, AUDIO-01, AUDIO-03
**Success Criteria:**
1. Clicar "NOVO JOGO" com save existente exibe popup in-game (não ConfirmationDialog OS) que escala corretamente com a janela.
2. Menu principal tem imagem de fundo e música em loop.
3. Menu de opções tem sliders separados de Música e SFX que alteram o volume em tempo real.
4. Volumes são salvos e restaurados ao reabrir o jogo.
5. Pressionar ESC em qualquer fase abre pause menu com overlay, "RETOMAR" e "MENU PRINCIPAL".
**Plans:** 3 planos (sequenciais)

**Wave 1**
- [x] 06-01-PLAN.md — Audio buses (Music/SFX), AudioManager volume methods, SaveManager volume persistence

**Wave 2** *(blocked on Wave 1)*
- [x] 06-02-PLAN.md — Main menu: replace ConfirmationDialog, add background image + music

**Wave 3** *(blocked on Waves 1-2)*
- [x] 06-03-PLAN.md — Options menu volume sliders + in-game ESC pause menu + SceneTransition.previous_scene

### Phase 7: v1.0 Polish & Release
**Goal:** Mundos 1 e 2 polidos e publicados no itch.io como v1.0 jogável — o primeiro release real do jogo.
**Mode:** mvp
**Depends on:** Phase 6
**Requirements:** EXPORT-01, EXPORT-02
**Success Criteria:**
1. Build HTML5 abre no navegador via itch.io sem crash ou tela preta.
2. Build Windows executa sem erros e o jogo completo (Mundos 1 e 2) é jogável do início ao fim.
3. Cheklist de bugs jogado por um playtest humano (Mundo 1 + Mundo 2 + Boss 1 + Boss 2) sem blocker.
4. Página itch.io publicada com descrição, capturas de tela e tag "demo / early access".
**Plans:** TBD
**UI hint:** yes

---

## Progress Table

### Milestone v1.0 — Mundos 1 e 2

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 0. Fundação | 4/4 | ✅ Complete | 2026-06-04 |
| 1. Game Feel | 3/3 | ✅ Complete | 2026-06-04 |
| 2. Infraestrutura | -/- | ✅ Complete | - |
| 3. Mundo 1 — Osasco | 5/5 | ✅ Complete | 2026-06-09 |
| 4. Mundo 2 — A Faculdade | 5/5 | ✅ Complete | - |
| 5. Level Design Overhaul (M1+M2) | 4/4 | ✅ Complete | - |
| 6. Menu & UX Polish | 3/3 | ✅ Complete | 2026-06-15 |
| 7. v1.0 Polish & Release | 0/0 | Not started | - |

### Milestone v2.0+ — Mundos 3–8

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 8. Mundo 3 — O Corporativo | 0/0 | Not started | - |
| 9. Mundo 4 — A Pandemia | 0/0 | Not started | - |
| 10. Mundo 5 — Santiago e os Votos | 0/0 | Not started | - |
| 11. Mundo 6 — Tossa de Mar | 0/0 | Not started | - |
| 12. Mundo 7 — Vilanova i la Geltrú | 0/0 | Not started | - |
| 13. Mundo 8 — Zaragoza | 0/0 | Not started | - |
| 14. Overworld e NPCs Secundários | 0/0 | Not started | - |
| 15. Polish, Acessibilidade e Release Final | 0/0 | Not started | - |

---

## Coverage Validation

**Total v1 requirements:** 44
**Mapped:** 44/44

| REQ-ID | Phase |
|--------|-------|
| EXPORT-03 | Phase 0 |
| MOVE-01 | Phase 1 |
| MOVE-02 | Phase 1 |
| MOVE-03 | Phase 1 |
| MOVE-04 | Phase 1 |
| MOVE-05 | Phase 1 |
| SAVE-01 | Phase 2 |
| SAVE-02 | Phase 2 |
| SAVE-03 | Phase 2 |
| NARR-01 | Phase 2 |
| NARR-02 | Phase 2 |
| ACCESS-02 | Phase 2 |
| ACCESS-03 | Phase 2 |
| NPC-04 | Phase 2 |
| WORLD-01 | Phase 3 |
| WORLD-02 | Phase 3 |
| WORLD-03 | Phase 3 |
| WORLD-05 | Phase 3 |
| BOSS-01 | Phase 3 |
| NPC-01 | Phase 3 |
| NARR-05 | Phase 3 |
| AUDIO-02 | Phase 3 |
| BOSS-02 | Phase 4 |
| POWER-01 | Phase 4 |
| BOSS-03 | Phase 6 |
| POWER-02 | Phase 6 |
| BOSS-04 | Phase 7 |
| POWER-03 | Phase 7 |
| NPC-02 | Phase 7 |
| BOSS-05 | Phase 8 |
| POWER-04 | Phase 8 |
| NARR-03 | Phase 8 |
| BOSS-06 | Phase 9 |
| POWER-05 | Phase 9 |
| BOSS-07 | Phase 10 |
| POWER-06 | Phase 10 |
| BOSS-08 | Phase 11 |
| POWER-07 | Phase 11 |
| POWER-08 | Phase 11 |
| NARR-04 | Phase 11 |
| WORLD-04 | Phase 12 |
| NPC-03 | Phase 12 |
| ACCESS-01 | Phase 13 |
| AUDIO-01 | Phase 13 |
| AUDIO-03 | Phase 13 |
| EXPORT-01 | Phase 13 |
| EXPORT-02 | Phase 13 |
