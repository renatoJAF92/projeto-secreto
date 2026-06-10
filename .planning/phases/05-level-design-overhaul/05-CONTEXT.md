# Phase 5 Context — Level Design Overhaul (Mundos 1 e 2)

**Decided:** 2026-06-10
**Discussed by:** Renato (game owner)
**Status:** Ready for planning

---

## Why this phase exists

The user played Mundos 1 and 2 and found them too short, too easy, and visually too plain (colored squares). Before building Mundo 3, the decision was made to overhaul the existing worlds first. This phase runs the overhaul for **all 6 fases** of Worlds 1 and 2 before any new world is built.

---

## Decisions

### 1. Tamanho e estrutura

| Decision | Value |
|----------|-------|
| New fase width | **6400px** (4× current 1600px) |
| Checkpoints per fase | **1** — at the exact midpoint (x = 3200px) |
| Internal structure | Each fase divided into **2+ themed sections** with distinct enemy compositions |
| Walls | Existing left/right wall barriers stay; extended to match new width |
| Exit trigger | Moved to x ≈ 6355px |
| Floor | Extended to 6400px width |

### 2. Inimigos — design e comportamento

Three principles combined (all selected by user):

**a) Composição em grupo (flanqueamento)**
- Inimigos spawnados em pares ou trios posicionados para flanquear o player
- Exemplo: um malandro na frente, um atrás, player forçado a decidir direção de ataque
- Grupos com papéis distintos: um que avança, um que recua para atrair

**b) Variantes de HP e comportamento**
- Inimigos padrão: 1 hit para matar (mesmo de antes)
- Variante resistente: 2 hits para matar; recebe knockback mais curto (visualmente diferente por cor/tamanho)
- Variante especial: só pode ser morta com dash (colisão normal não causa dano); avisa visual com brilho/borda distinta

**c) Posicionamento estratégico**
- Inimigos em plataformas elevadas forçando o player a subir para alcançá-los
- Inimigos bloqueando passagens estreitas (bottleneck design)
- Mix: inimigo no chão + inimigo na plataforma ao mesmo tempo

**Inimigo novo — Moto com Dois Homens (exclusivo Mundo 1 / Osasco)**
- Um veículo moto com 2 inimigos: piloto + passageiro
- Move-se horizontalmente mais rápido que os malandros normais
- Passageiro pode ser derrubado com 1 hit (moto fica mais lenta); piloto precisa de 2 hits após passageiro cair
- Só aparece nas fases de Osasco (Mundo 1)

### 3. Mecânicas ambientais

Todas as 4 mecânicas selecionadas:

| Mecânica | Descrição | Onde aplicar |
|----------|-----------|-------------|
| **Plataformas móveis** | Plataformas que se movem horizontal ou verticalmente com velocidade constante; o player precisa usar timing para atravessar ou alcançar inimigos | Seções intermediárias das fases, especialmente em alturas mais variadas |
| **Zonas de dano passivo** | Áreas que causam dano contínuo enquanto o player está nelas (ex: poça de lama/tinta no ateliê, calçada superaquecida na rua de Osasco, madrugada com névoa ácida) | 1-2 zonas por fase, sempre visíveis com coloração distinta |
| **Objetos empurráveis** | Caixas ou maquetes que o player pode empurrar para bloquear inimigos temporariamente ou criar degraus para alcançar plataformas | Pelo menos 1 por fase no Mundo 2 (ateliê); opcional no Mundo 1 |
| **Obstáculos temporizados** | Elementos que entram e saem com período fixo: portões automáticos, sprinklers, ventiladores industriais, relógios de ponto (Mundo 2). Criam janelas de passagem de ~2 segundos | Seções de "gauntlet" — 2-4 obstáculos em sequência |

### 4. Arte melhorada

**Prioridade:** inimigos E cenários com igual prioridade (ambos devem melhorar nesta phase).

**Inimigos — silhuetas reconhecíveis:**
- Malandro: boné, calça larga, camiseta; não mais um retângulo genérico
- Impressora raivosa: braço mecânico lateral, ranhuras de papel, olhos pixelados vermelhos
- Professor careca: terno, pasta, carequinha; postura de "cruzar os braços"
- Maquete rústica: base irregular, estruturas geométricas saindo, instável visualmente
- Moto com dois homens: silhueta reconhecível de moto + 2 figuras humanoides em cima

Implementação: Polygon2D multi-peça (cabeça + corpo + membros separados) com animações de loop simples. Não precisa ser sprite sheet final, mas deve ser reconhecível como o personagem.

**Cenários — camadas de fundo:**
- Paralaxe simples: 2 camadas no mínimo (fundo distante + elementos médios)
- Mundo 1 Osasco: prédios ao fundo (cinza), postes na camada média, calçada no chão
- Mundo 2 Faculdade: biblioteca desfocada ao fundo, mesas no meio, corredores laterais
- Cada fase tem background ColorRect + 2 ColorRect/Polygon2D de paralaxe (sem TextureRect — arte geométrica aceitável)

---

## Scope boundaries

**Dentro do escopo (Phase 5):**
- Reescrever as 6 fases do Mundo 1 e Mundo 2 com o novo design
- Criar o inimigo Moto com Dois Homens
- Variantes de inimigos existentes (2-hit, dash-only killable)
- Todas as 4 mecânicas ambientais
- Arte melhorada para inimigos e fundos das 6 fases

**Fora do escopo (deferir):**
- Mundo 3+ (começa na Phase 6)
- Sistema de overworld
- Áudio/música das fases
- Arte final (sprites pixel art profissionais) — isso é Phase 12 Polish

---

## Success criteria

1. Todas as 6 fases dos Mundos 1 e 2 têm **6400px de largura** com 1 checkpoint no meio (3200px).
2. Cada fase tem pelo menos **2 seções temáticas distintas** com composições de inimigos diferentes entre si.
3. Inimigo Moto com Dois Homens funciona nas 3 fases do Mundo 1 com comportamento de 2 fases (passageiro → piloto).
4. Variantes de inimigos presentes: pelo menos 1 variante 2-hit e 1 variante dash-only por mundo.
5. Todas as 4 mecânicas ambientais aparecem em pelo menos 1 fase cada.
6. Arte melhorada: inimigos têm silhuetas reconhecíveis (Polygon2D multi-peça); cada fase tem pelo menos 1 camada de paralaxe no fundo.
