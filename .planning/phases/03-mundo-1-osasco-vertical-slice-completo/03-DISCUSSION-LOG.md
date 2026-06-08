# Phase 3: Mundo 1 — Osasco - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-08
**Phase:** 03-mundo-1-osasco-vertical-slice-completo
**Areas discussed:** Combate com inimigos, Boss: O Pai Desconfiante (Luis), Estrutura das fases, Checkpoint e respawn, SFX e visual

---

## Combate com Inimigos

| Option | Description | Selected |
|--------|-------------|----------|
| Pulo em cima (Mario-style) | Cair sobre o inimigo mata/atordoa. Sem novo input. | ✓ |
| Dash atravessa inimigos | Dash existente causa dano ao inimigo. | |
| Só evitar (sem combate) | Inimigos causam dano, Natália nunca os derrota. | |

**User's choice:** Pulo em cima (Mario-style)
**Notes:** —

| Option | Description | Selected |
|--------|-------------|----------|
| 1 tipo — malandro básico | Um inimigo simples para estabelecer o padrão. | |
| 2 tipos — malandro + obstáculo | Malandro móvel + obstáculo ambiental estático. | ✓ |

**User's choice:** 2 tipos — malandro + obstáculo

| Option | Description | Selected |
|--------|-------------|----------|
| Patrulha horizontal (vai e volta) | Anda em faixa fixa, vira ao bater na borda. | ✓ |
| Patrulha + percebe a Natália | Acelera em direção à Natália (aggro radius). | |

| Option | Description | Selected |
|--------|-------------|----------|
| Mata instantaneamente | 1 pulo = inimigo some. | ✓ |
| Atordoa temporariamente | Inimigo fica estuporado por 2-3s depois volta. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Toma dano + knockback | Contato lateral = dano e empurrão (já implementado). | ✓ |
| Toma dano + knockback + flash no inimigo | Feedback visual adicional no inimigo. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Zona de dano estática (buraco, lixo, cerca) | Não se move, causa dano ao tocar. Area2D. | ✓ |
| Projétil ambiental (pedra, lata) | Lançado periodicamente. Mais complexo. | |

---

## Boss: O Pai Desconfiante (Luis)

| Option | Description | Selected |
|--------|-------------|----------|
| Diálogo de múltipla escolha | Dialogic, respostas certas/erradas. | Mistura 1+2 |
| Coletar provas + apresentar | Itens nas fases, apresentar no boss. | Mistura 1+2 |
| Combinado: plataforma + diálogo | Boss lança obstáculos, janelas de diálogo. | |

**User's choice:** Mistura das opções 1 e 2 — provas coletadas nas fases + diálogo de múltipla escolha no boss.

| Option | Description | Selected |
|--------|-------------|----------|
| Sim — lança obstáculos | Papers voando, barreiras. Natália desvia. | |
| Não — puramente narrativo | Sem dano físico durante o boss. | ✓ |

| Option | Description | Selected |
|--------|-------------|----------|
| Provas coletadas nas fases anteriores | Itens das fases 1-3, apresentados no boss. | ✓ |
| Provas coletadas na própria sala do boss | Plataformas com itens dentro da cena do boss. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Reinicia diálogo (mantendo provas) | Volta ao início da conversa. | |
| Volta ao último checkpoint da fase de boss | Reseta a cena, provas mantidas, barra zera. | ✓ |

**User's choice:** Volta ao último checkpoint — barra reseta, provas mantidas.

| Option | Description | Selected |
|--------|-------------|----------|
| Retrato de diálogo apenas (Dialogic) | Sem sprite no cenário. | |
| Sprite de boss na cena + caixas de diálogo | Personagem grande no cenário + Dialogic. | ✓ |

| Option | Description | Selected |
|--------|-------------|----------|
| Apresentar prova = sobe, resposta certa = sobe mais | Provas enchem barra, respostas corretas dão bônus. | ✓ |
| Só respostas certas sobem (provas são pré-requisito) | Provas desbloqueiam diálogo, respostas sobem barra. | |

**Notes:** Mínimo 2 provas obrigatórias para completar o boss.

| Option | Description | Selected |
|--------|-------------|----------|
| 2 provas (mínimo) | 2 provas abrem o boss, extras dão margem. | ✓ |
| 2 obrigatórias + 1 bônus opcional | 2 necessárias + 1 que facilita. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Casa da Natália (sala de estar/varanda) | Ambiente doméstico, Pai barrou entrada do Renato. | ✓ |
| Rua de Osasco | Confronto na rua do bairro. | |
| Decidir depois | Deixar para planejamento visual. | |

**Notes:** Duas casas em Osasco: (1) casa dos pais da Natália = cena do boss; (2) apartamento do casal = cena futura pós-casamento.

| Option | Description | Selected |
|--------|-------------|----------|
| Só a Natália (Renato ausente — esse é o drama) | Natália convence o Pai sozinha. | |
| Renato aparece no final como prova final | Entra na cena ~80% da barra. | ✓ |

| Option | Description | Selected |
|--------|-------------|----------|
| Cutscene: o Pai cede, Renato é aceito | Diálogo final, mudança de expressão. | ✓ |
| Fade out + texto narrativo | Tela escurece, texto descreve resultado. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Só "O Pai" ou "Pai da Natália" | Nome genérico. | |
| Nome real | Personaliza; é baseado em pessoa real. | ✓ |

**Notes:** Nome real do Pai é **Luis**.

| Option | Description | Selected |
|--------|-------------|----------|
| Dialogic (já configurado) | Aproveita infraestrutura da Phase 2. | |
| UI customizada (barra de confiança visível) | Dialogic + ProgressBar customizada sobreposta. | ✓ |

| Option | Description | Selected |
|--------|-------------|----------|
| HUD com ícones de provas durante fases | Jogador vê o que coletou. | |
| Só aparece na cena do boss | Mais limpo durante as fases. | ✓ |

| Option | Description | Selected |
|--------|-------------|----------|
| Trilha própria (tensa, emocional) | Música distinta para o boss. | ✓ |
| Tema do Mundo 1 (mesma trilha) | Consistência, menos trabalho. | |

**Detalhe extra (freeform):** Luis aparece escondido no cenário da Fase 3 (Restaurante) espiando o encontro de Natália e Renato — foreshadowing visual antes do boss fight.

---

## Estrutura das Fases

**User's choice (freeform):** 3 fases + boss:
1. Rua de Osasco
2. Parque (Renato no fundo)
3. Restaurante (Renato presente + Luis escondido)
4. Boss — Casa dos pais da Natália

Renato aparece em: parque (fundo), restaurante (ativo), boss finale (~80% barra).

**Narrativa expandida compartilhada:** Após Mundo 1 — praia → parque Chile (pedido de casamento) → casamento → apartamento Osasco → emprego (clientes e gerentes como inimigos) → Espanha. Mapeia para Mundos 2-8 do roadmap.

| Option | Description | Selected |
|--------|-------------|----------|
| 4 scenes separadas | Cada fase = nova scene via SceneTransition. | ✓ |
| 1 scene grande contínua | Sem loading entre fases. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Itens coletáveis (foto, carta, presente) | Objetos brilhantes no cenário. | ✓ |
| NPCs que dão depoimentos | Amigos/conhecidos dão prova ao falar com eles. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Antes da Fase 1 (Rua de Osasco) | Cutscene de abertura antes do primeiro controle. | ✓ |
| Logo após o Continue / New Game | Transição entre menu e primeira fase. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Casa do casal (após casamento) | Natália e Renato decoram o apartamento juntos. | ✓ |
| Casa dos pais da Natália | Explorar memórias + coletar provas. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Após o boss — epílogo do Mundo 1 | Fecha o arco antes do próximo mundo. | |
| Fase separada fora do Mundo 1 | Pertence a outro mundo, fora do Phase 3. | ✓ |

---

## Checkpoint e Respawn

**User's choice (freeform):** Checkpoint visual = cartaz/logo da banda McFly. Presente em todas as 4 cenas do Mundo 1 com destaque no ambiente.

| Option | Description | Selected |
|--------|-------------|----------|
| Inimigos resetam | Fase volta ao estado inicial no segmento. | ✓ |
| Inimigos permanecem mortos | Malandros derrotados não voltam. | |

| Option | Description | Selected |
|--------|-------------|----------|
| 1 checkpoint por fase | No meio da fase. | ✓ |
| 2 checkpoints por fase | Início + meio. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Provas permanecem (salvas ao coletar) | Progresso de provas não se perde. | ✓ |
| Perdem se morrer antes do checkpoint | Mais risco/recompensa. | |

---

## SFX e Visual

| Option | Description | Selected |
|--------|-------------|----------|
| Placeholder (bfxr/sfxr — chiptune) | Rápido de gerar, suficiente para testar. | ✓ |
| Sons reais desde já | Freesound.org ou gravação própria. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Cinza urbano + acentos quentes (#1A1A2E + laranja/vermelho) | Tom de periferia paulistana. | ✓ |
| Cinza frio + pontos saturados | Mais desaturado, cores só em interativos. | |

---

## Claude's Discretion

- Quantidade de malandros e obstáculos por fase (nível de dificuldade)
- Posicionamento preciso de checkpoints, provas e inimigos no level design
- Implementação do tileset de Osasco (tiles placeholder geométricos)
- Duração/velocidade das animações do sprite do Luis (boss)
- Mecânica exata de apresentação de provas (tecla dedicada ou automático ao entrar na cena)

## Deferred Ideas

- Fase da Casa com orçamento (mecânica Sims/Stardew) — apartamento do casal, fase futura pós-casamento
- Sprites definitivos de inimigos — placeholder na Phase 3, arte real na Phase 12
- Trilha sonora temática do Mundo 1 — placeholder na Phase 3, composição real na Phase 12
- SFX reais — bfxr/sfxr na Phase 3, Freesound.org na Phase 12
- Detalhes do roteiro do boss (perguntas/respostas específicas do diálogo com Luis) — discutir separadamente
