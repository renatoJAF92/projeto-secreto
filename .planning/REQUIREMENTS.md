# Requisitos — Jogo da Natália

## v1 Requirements

### MOVE — Movimentação e Game Feel
- [x] **MOVE-01**: Jogadora pode correr, pular e cair com física responsiva (coyote time 6 frames, jump buffer 8 frames, gravidade assimétrica)
- [x] **MOVE-02**: Jogadora pode dar dash horizontal (desbloqueado no Mundo 2)
- [x] **MOVE-03**: Jogadora recebe knockback ao ser atingida
- [x] **MOVE-04**: Animações de idle, run, jump, fall, hurt e death para a Natália
- [x] **MOVE-05**: Juice visual: poeira ao aterrissar, squash/stretch no pulo, flash branco ao tomar dano, hit-stop de 2-4 frames nos chefes

### WORLD — Mundos e Level Design
- [ ] **WORLD-01**: 8 mundos jogáveis com cenários temáticos únicos e paleta de cores própria
- [ ] **WORLD-02**: Cada mundo tem 2-3 fases lineares + 1 fase de chefe
- [ ] **WORLD-03**: Cada fase tem checkpoints visuais (não há sistema de vidas)
- [ ] **WORLD-04**: Overworld (mapa-mundo) navegável com mundos desbloqueáveis sequencialmente
- [ ] **WORLD-05**: Respawn instantâneo (< 500ms) no checkpoint mais próximo ao morrer

### BOSS — Chefes de Fase
- [ ] **BOSS-01**: O Pai Desconfiante (Mundo 1) — chefe de diálogo com condição de vitória não-violenta
- [ ] **BOSS-02**: Professor Perpétuo (Mundo 2) — chefe que adiciona requisitos à fase enquanto o jogador tenta completá-la
- [ ] **BOSS-03**: Gestor Tóxico (Mundo 3) — chefe que drena HP de saúde mental; vencido sem perder esse HP
- [ ] **BOSS-04**: Vírus Chefão (Mundo 4) — chefe de tela inteira com partículas que se multiplicam
- [ ] **BOSS-05**: A Burocracia (Mundo 5) — múltiplas fases com formulários e carimbos voadores
- [ ] **BOSS-06**: Barreira do Idioma (Mundo 6) — mini-game de vocabulário espanhol integrado ao combate
- [ ] **BOSS-07**: Mercado Fechado (Mundo 7) — portas que fecham antes do jogador chegar; caminhos alternativos
- [ ] **BOSS-08**: O Medo da Mudança (Mundo 8) — chefe final que combina mecânicas de todos os poderes

### POWER — Sistema de Poderes
- [ ] **POWER-01**: Sketch (Mundo 2) — projétil de esboços de arquitetura
- [ ] **POWER-02**: Mapa Urbano (Mundo 3) — revela caminhos ocultos nas fases
- [ ] **POWER-03**: Escudo Blueprint (Mundo 4) — planta arquitetônica como escudo temporário
- [ ] **POWER-04**: Amor Power (Mundo 5) — invencibilidade breve quando Renato está presente
- [ ] **POWER-05**: Cerâmica (Mundo 6) — projéteis de cerâmica com variações de tipo
- [ ] **POWER-06**: UX Flow (Mundo 7) — altera padrão de movimento dos inimigos temporariamente
- [ ] **POWER-07**: Combo Final (Mundo 8) — combina todos os poderes anteriores em uma habilidade única
- [ ] **POWER-08**: Poderes são salvos e persistem entre sessões; powers de mundos anteriores podem ser usados nos seguintes

### NPC — Personagens
- [ ] **NPC-01**: Renato aparece como NPC companheiro em pontos específicos de cada mundo (sprite baseado em foto real)
- [ ] **NPC-02**: A cachorra acompanha a Natália a partir do Mundo 4 (invencível, nunca é um fardo para o jogador)
- [ ] **NPC-03**: NPCs secundários por mundo (amigas da faculdade, colegas da Urbanova, amigos de Vilanova e Zaragoza)
- [ ] **NPC-04**: Sprite da protagonista Natália baseado em foto real

### NARRATIVE — Narrativa e Diálogos
- [ ] **NARR-01**: Sistema de diálogo com caixas de texto, retratos de personagem e branching básico (via Dialogic 2)
- [ ] **NARR-02**: Todos os diálogos e cutscenes são puláveis (com `seen_cutscenes` salvo para não exibir novamente)
- [ ] **NARR-03**: Cutscene de proposta em Santiago (Mundo 5) — cinemática em pixel art
- [ ] **NARR-04**: Ending com créditos e fotos reais de Renato e Natália
- [ ] **NARR-05**: Texto narrativo de abertura de cada mundo (introdução da fase emocional)

### SAVE — Progresso e Save
- [ ] **SAVE-01**: Save automático ao completar cada fase e ao chegar em checkpoints
- [ ] **SAVE-02**: Progresso de mundos, poderes desbloqueados e cutscenes vistas são persistidos
- [ ] **SAVE-03**: Menu de continue / new game na tela inicial

### AUDIO — Som
- [ ] **AUDIO-01**: Trilha sonora temática por mundo (8 temas com tonalidade emocional distinta)
- [ ] **AUDIO-02**: SFX para: pulo, dash, ataque, dano, checkpoint, morte, power-up, diálogo
- [ ] **AUDIO-03**: Controles de volume (música / SFX) no menu de opções

### EXPORT — Plataformas
- [ ] **EXPORT-01**: Build para Windows e macOS
- [ ] **EXPORT-02**: Build para web (HTML5) via itch.io — testada e funcional no navegador
- [ ] **EXPORT-03**: Renderer Compatibility configurado desde o início do projeto

### ACCESS — Acessibilidade
- [ ] **ACCESS-01**: Assist Mode — velocidade do jogo (0.5x), invencibilidade, poderes infinitos (sem julgamento)
- [ ] **ACCESS-02**: Teclas reconfiguráveis
- [ ] **ACCESS-03**: Suporte a controle (gamepad) além do teclado

---

## v2 Requirements (Deferred)

- Localização para inglês e espanhol
- Conquistas / achievements
- Leaderboard de tempo por fase
- Mobile (iOS/Android) — exportação futura
- Co-op local (Renato jogável)
- Editor de fases interno
- Modo foto/galeria para ver sprites evoluindo ao longo do desenvolvimento

---

## Fora do Escopo (v1)

- **Multiplayer online** — projeto pessoal, foco na história solo
- **Microtransações** — presente para a Natália, nunca monetizado dessa forma
- **Procedural generation** — a narrativa é linear e intencional
- **Voice acting** — orçamento e escopo fora de v1
- **3D** — pixel art 2D é identidade do projeto

---

## Rastreabilidade

| REQ-ID | Fase | Status |
|--------|------|--------|
| EXPORT-03 | Phase 0 — Fundação | Pending |
| MOVE-01 | Phase 1 — Game Feel | Complete |
| MOVE-02 | Phase 1 — Game Feel | Complete |
| MOVE-03 | Phase 1 — Game Feel | Complete |
| MOVE-04 | Phase 1 — Game Feel | Complete |
| MOVE-05 | Phase 1 — Game Feel | Complete |
| SAVE-01 | Phase 2 — Infraestrutura | Pending |
| SAVE-02 | Phase 2 — Infraestrutura | Pending |
| SAVE-03 | Phase 2 — Infraestrutura | Pending |
| NARR-01 | Phase 2 — Infraestrutura | Pending |
| NARR-02 | Phase 2 — Infraestrutura | Pending |
| ACCESS-02 | Phase 2 — Infraestrutura | Pending |
| ACCESS-03 | Phase 2 — Infraestrutura | Pending |
| NPC-04 | Phase 2 — Infraestrutura | Pending |
| WORLD-01 | Phase 3 — Mundo 1 Osasco | Pending |
| WORLD-02 | Phase 3 — Mundo 1 Osasco | Pending |
| WORLD-03 | Phase 3 — Mundo 1 Osasco | Pending |
| WORLD-05 | Phase 3 — Mundo 1 Osasco | Pending |
| BOSS-01 | Phase 3 — Mundo 1 Osasco | Pending |
| NPC-01 | Phase 3 — Mundo 1 Osasco | Pending |
| NARR-05 | Phase 3 — Mundo 1 Osasco | Pending |
| AUDIO-02 | Phase 3 — Mundo 1 Osasco | Pending |
| BOSS-02 | Phase 4 — Mundo 2 A Faculdade | Pending |
| POWER-01 | Phase 4 — Mundo 2 A Faculdade | Pending |
| BOSS-03 | Phase 5 — Mundo 3 O Corporativo | Pending |
| POWER-02 | Phase 5 — Mundo 3 O Corporativo | Pending |
| BOSS-04 | Phase 6 — Mundo 4 A Pandemia | Pending |
| POWER-03 | Phase 6 — Mundo 4 A Pandemia | Pending |
| NPC-02 | Phase 6 — Mundo 4 A Pandemia | Pending |
| BOSS-05 | Phase 7 — Mundo 5 Santiago | Pending |
| POWER-04 | Phase 7 — Mundo 5 Santiago | Pending |
| NARR-03 | Phase 7 — Mundo 5 Santiago | Pending |
| BOSS-06 | Phase 8 — Mundo 6 Tossa de Mar | Pending |
| POWER-05 | Phase 8 — Mundo 6 Tossa de Mar | Pending |
| BOSS-07 | Phase 9 — Mundo 7 Vilanova | Pending |
| POWER-06 | Phase 9 — Mundo 7 Vilanova | Pending |
| BOSS-08 | Phase 10 — Mundo 8 Zaragoza | Pending |
| POWER-07 | Phase 10 — Mundo 8 Zaragoza | Pending |
| POWER-08 | Phase 10 — Mundo 8 Zaragoza | Pending |
| NARR-04 | Phase 10 — Mundo 8 Zaragoza | Pending |
| WORLD-04 | Phase 11 — Overworld e NPCs | Pending |
| NPC-03 | Phase 11 — Overworld e NPCs | Pending |
| ACCESS-01 | Phase 12 — Polish e Release | Pending |
| AUDIO-01 | Phase 12 — Polish e Release | Pending |
| AUDIO-03 | Phase 12 — Polish e Release | Pending |
| EXPORT-01 | Phase 12 — Polish e Release | Pending |
| EXPORT-02 | Phase 12 — Polish e Release | Pending |
