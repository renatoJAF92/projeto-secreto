# Phase 4: Mundo 2 — A Faculdade - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-09
**Phase:** 4-mundo-2-a-faculdade
**Areas discussed:** Inimigos do campus, Cenário, Boss TFG, Poder Sketch, Persistência de poderes, Narrativa/cutscenes, Transição para Mundo 3

---

## Inimigos do Campus

| Option | Description | Selected |
|--------|-------------|----------|
| Reskin do Malandro | Reutiliza malandro.gd, só troca sprites | |
| Comportamentos únicos por tipo | Maquete cai, Impressora lança projéteis | |
| Mix: 1 reskin + 1 novo | Maquete = reskin, Impressora = novo | ✓ |

**User's choice:** Mix — Maquete Rústica (floor trap, Area2D), Impressora (dispara folhas), Professor Careca (NPC estático, comentários homing)

**Notes:** Usuário expandiu para 3 inimigos distintos. Também adicionou sistema de 3 PV e itens de cura (café). Renato aparece na Fase 1 (campus) e Fase 3 (café da madrugada). Professor Careca é intocável — obstáculo de cenário, não morível por stomp.

---

## Sistema de HP

| Option | Description | Selected |
|--------|-------------|----------|
| Sim — 3 PV, HUD de corações | Global a partir do Mundo 2 | ✓ |
| Só para o Mundo 2 | Mecânica isolada | |
| Claude decide | Implementação mínima | |

**User's choice:** Sim — 3 PV com HUD, recuperação por checkpoint (+1) e itens de cura (+1)

---

## Comportamento dos Comentários (Professor Careca)

| Option | Description | Selected |
|--------|-------------|----------|
| Rasteja em direção à Natália (homing) | Desliza pelo chão em direção ao player | ✓ |
| Rasteja em direção fixa | Sempre para a esquerda/direção fixa | |

---

## Folha da Impressora (alcance)

| Option | Description | Selected |
|--------|-------------|----------|
| Some ao bater na parede/borda | Alcance total | ✓ |
| Some após distância fixa | Alcance curto | |

---

## Maquete — visual de perigo

| Option | Description | Selected |
|--------|-------------|----------|
| Cor/brilho + hitbox visível | Tonalidade avermelhada | |
| Só design de sprite | Maquete fragmentada visualmente | ✓ |

---

## Cenário Visual e Paleta

| Option | Description | Selected |
|--------|-------------|----------|
| Caótico mas colorido | Bege/creme, papéis, projetos coloridos | ✓ |
| Exaustivo e sombrio | Bege desbotado, madrugada azul-cinza | |

---

## Estrutura das Fases

| Option | Description | Selected |
|--------|-------------|----------|
| 3 fases + boss (igual Mundo 1) | Campus → Ateliê → Madrugada → Boss | ✓ |
| 2 fases + boss | Campus+Ateliê → Madrugada → Boss | |

---

## Renato no Mundo 2

| Option | Description | Selected |
|--------|-------------|----------|
| Ajudando nas maquetes (Fase 2) | NPC estático no ateliê | |
| Campus externo + madrugada | Fase 1 + Fase 3 (café) | ✓ |
| Só na cena do boss | Só na cutscene de vitória | |

---

## Trilha do Mundo 2

| Option | Description | Selected |
|--------|-------------|----------|
| Agitado e caótico (BPM alto) | Clima de prazo apertado | ✓ |
| Melancólico e cansado | BPM lento, madrugada | |

---

## Boss TFG — Mecânica Central

| Option | Description | Selected |
|--------|-------------|----------|
| Coleta de itens + banca examinadora | Items espalhados + apresentação | |
| Barra de qualidade progressiva | Items + diálogo aumentam a barra | |
| Claude combina | — | |

**User's choice:** Barra de qualidade com diálogos de banca + mínimo 3 itens coletados. Derrota: barra < 70% ou sem 3 itens.

**Notes:** Usuário forneceu o TFG real da Natália: "Completing the Street: Urban Project for the Retail Commercial Hub of Oriente Street in Brás". Os 5 itens devem referenciar partes deste trabalho real.

---

## Boss TFG — Prejudicar Natália

| Option | Description | Selected |
|--------|-------------|----------|
| Baixa a barra de qualidade | Perguntas difíceis/erradas diminuem % | ✓ |
| Diminui PV físico | Boss com plataformer | |

---

## Boss TFG — Condição de vitória/derrota

| Option | Description | Selected |
|--------|-------------|----------|
| Vitória 100%, derrota 0% | Igual ao Luis | |
| Vitória 100%, derrota < 70% ou sem itens | Gate de itens + barra mínima | ✓ |

---

## Boss TFG — Cutscene de vitória

| Option | Description | Selected |
|--------|-------------|----------|
| Colação + Sketch desbloqueado | Colegas, Renato, automático | ✓ |
| Renato entrega o poder | Cena emocional personalizada | |

---

## Itens TFG — onde ficam

| Option | Description | Selected |
|--------|-------------|----------|
| Espalhados nas Fases 1-3 | Igual às Provas do Mundo 1 | ✓ |
| Só na cena do boss | Boss com plataformer + banca | |

---

## Banca — composição

| Option | Description | Selected |
|--------|-------------|----------|
| 1 Professor + 2 NPCs genéricos | Só Perpétuo tem diálogo | ✓ |
| 3 professores com diálogos | Mais trabalho de Dialogic | |

---

## Mecânica "adiciona requisito"

| Option | Description | Selected |
|--------|-------------|----------|
| Sobe o alvo da barra | Ex: 70% → 85% durante a banca | ✓ |
| Remove 1 item do TFG | Item vira insuficiente | |

---

## Fase de plataforma no boss?

| Option | Description | Selected |
|--------|-------------|----------|
| Não — só narrativo | Igual Mundo 1 | ✓ |
| Sim — coleta + banca | Dois momentos | |

---

## Cutscene de abertura do Mundo 2

| Option | Description | Selected |
|--------|-------------|----------|
| Sim — mesmo padrão do Mundo 1 | mundo2_abertura.tscn | ✓ |
| Não | Começa na Fase 1 | |

---

## Poder Sketch — Input

| Option | Description | Selected |
|--------|-------------|----------|
| Tecla dedicada Z | Nova ação use_power no InputMap | ✓ |
| Combinação Baixo + Pulo | Sem tecla nova | |

---

## Poder Sketch — Limite de uso

| Option | Description | Selected |
|--------|-------------|----------|
| Cooldown simples (0.5s) | Sem munição | ✓ |
| Munição limitada + recarga | 5 esboços, recarga no checkpoint | |

---

## Poder Sketch — Dano e alcance

| Option | Description | Selected |
|--------|-------------|----------|
| 1 hit kill + alcance linear até parede | Mata tudo em 1 hit | ✓ |
| 2 hits + atravessa inimigos | Penetrante | |

---

## Poder Sketch — Visual do projétil

| Option | Description | Selected |
|--------|-------------|----------|
| Linha de esboço/lápis | Retângulo fino creme/amarelo | |
| Folha de papel dobrada | Sprite 12x12px | ✓ |

---

## Poder Sketch — Retroativo

| Option | Description | Selected |
|--------|-------------|----------|
| Sim — persiste retroativamente (POWER-08) | Funciona em todos os mundos | ✓ |
| Não — só do Mundo 2 | Ignorar POWER-08 | |

---

## Poder Sketch — Quando disponível

| Option | Description | Selected |
|--------|-------------|----------|
| Após vitória do Boss TFG | Recompensa clara | ✓ |
| Durante as fases 1-3 | Disponível imediatamente | |

---

## Poder Amor (Mundo 1 — retroativo)

**User's choice (free text):** Adicionar poder do Amor ao Mundo 1, desbloqueado após derrotar o boss Luis. Bolha rotativa que circula ao redor da Natália por ~2s e mata inimigos por contato. Cooldown 3-4s. Implementar junto com o sistema de poderes da Phase 4.

---

## Persistência de Poderes — Seleção

| Option | Description | Selected |
|--------|-------------|----------|
| Tecla única Z + Shift+Z para ciclar | 1 poder ativo por vez | ✓ |
| Teclas numéricas 1,2,3... | Cada poder com tecla fixa | |

---

## HUD de Poderes

| Option | Description | Selected |
|--------|-------------|----------|
| Ícone + barra de cooldown | Completo | |
| Só pronto/não pronto | Ícone cinza/colorido | ✓ |

---

## Persistência no SaveManager

| Option | Description | Selected |
|--------|-------------|----------|
| active_power + powers_unlocked (Recomendado) | Restaura poder ativo ao carregar | ✓ |
| Sempre começa com primeiro poder | Sem save de poder ativo | |

---

## Transição Mundo 2 → Mundo 3

| Option | Description | Selected |
|--------|-------------|----------|
| world2_end.tscn placeholder | Igual world1_end.tscn | ✓ |
| Menu principal direto | SceneTransition para main_menu | |

---

## Checkpoint Visual do Mundo 2

| Option | Description | Selected |
|--------|-------------|----------|
| Pranchão de arquitetura | Visual técnico de ARQ | |
| Caneca de café | Símbolo das madrugadas | ✓ |

---

## Texto de abertura

| Option | Description | Selected |
|--------|-------------|----------|
| Exaustão + esperança | Noites sem dormir, mas amizade e talento | ✓ |
| Celebração da faculdade | Tom mais leve | |

---

## Itens TFG — visual

| Option | Description | Selected |
|--------|-------------|----------|
| Rolo de papel/pasta genérico | Mesmo sprite do prova_item | |
| Sprites únicos por item | 5 sprites distintos | ✓ |

---

## Claude's Discretion

- Posicionamento exato de inimigos e itens nas fases
- Número de inimigos por fase (balanceamento)
- Timing dos ataques dos inimigos
- Animações placeholder dos novos inimigos
- Diálogos exatos da banca (temáticos ao TFG real)
- Quantidade e posição de itens de café por fase

## Deferred Ideas

- Sistema de HP retroativo para o Mundo 1 (decidido manter 1 hit = morte)
- Overworld (Phase 11)
- Sons reais para o Mundo 2 (Phase 12)
- Sprites baseados em fotos reais de Natália, Renato (aguardando fotos)
