# Phase 2: Infraestrutura - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-04
**Phase:** 02-infraestrutura
**Areas discussed:** Estrutura do save, Placeholder NPC-04 (Natália), Profundidade do Dialogic 2, Remapeamento de controles

---

## Estrutura do save

| Option | Description | Selected |
|--------|-------------|----------|
| Slot único | Um save, Continue/New Game na tela inicial, New Game sobrescreve | ✓ |
| Múltiplos slots (3) | 3 arquivos independentes, UI de seleção de slot | |
| Slot único + backup automático | Um slot + arquivo de backup da última sessão | |

**User's choice:** Slot único
**Notes:** Jogo de história linear, sem necessidade de múltiplos perfis.

---

| Option | Description | Selected |
|--------|-------------|----------|
| ID do checkpoint + mundos/poderes/cutscenes | Salva identificador do checkpoint, não posição X/Y exata | ✓ |
| Posição exata X/Y + estado completo | Coordenadas exatas, respawn no ponto exato | |
| Apenas progresso de fase (sem posição) | Começa do início da fase sempre | |

**User's choice:** ID do checkpoint + mundos/poderes/cutscenes
**Notes:** Mais robusto contra mudanças de fase entre versões.

---

| Option | Description | Selected |
|--------|-------------|----------|
| store_var() / load_var() Godot nativo | Binário Godot, zero dependência, dificulta trapaça | ✓ |
| ConfigFile (.cfg / .ini) | Texto legível, bom para settings, não ideal para progresso | |
| Resource customizado (.tres) | Mais OO, editável no editor | |

**User's choice:** store_var() / load_var()

---

| Option | Description | Selected |
|--------|-------------|----------|
| Ao tocar checkpoint + ao completar fase | Save nos dois eventos que importam | ✓ |
| Somente ao completar fase | Perde progresso dentro de fases longas | |
| Continuous save (a cada 30s) | Pode salvar em momentos ruins (meio de combate) | |

**User's choice:** Ao tocar checkpoint + ao completar fase

---

## Placeholder NPC-04 (Natália)

| Option | Description | Selected |
|--------|-------------|----------|
| Sprite sheet placeholder com todas as animações | Silhueta colorida 32x32 com 6 animações | |
| Retângulo colorido com hitbox correta | Shape simples sem arte | |
| Aguardar foto real | Bloquear Phase 2 até ter a foto | |

**User's choice:** [Free text] — "Após a fase de discussão, posso enviar algumas fotos da Natália para a criação do sprite sheet, se isso já for facilitar o trabalho da phase 2 e evitar retrabalho no futuro."
**Notes:** Renato vai fornecer fotos reais após esta discussão. Sprite será baseado na foto real desde o início.

---

| Option | Description | Selected |
|--------|-------------|----------|
| Sprite pixel art baseado na foto, todas as animações | 32x32 fiel à Natália, 6 animações completas | ✓ |
| Sprite base apenas (idle + run) | 2 animações iniciais, resto depois | |
| Foto como texture 2D sem pixelate | Foto direta, inconsistente com estilo | |

**User's choice:** Sprite pixel art baseado na foto, todas as animações

---

| Option | Description | Selected |
|--------|-------------|----------|
| Claude gera via script GDScript + cores definidas | Gerado programaticamente a partir das fotos | ✓ |
| Renato desenha em Aseprite / Libresprite | Desenho manual usando fotos como referência | |
| Gerar usando IA de imagem (ex: Midjourney) | IA externa para pixel art — resultado imprevisível | |

**User's choice:** Claude gera via script GDScript + cores definidas

---

## Profundidade do Dialogic 2

| Option | Description | Selected |
|--------|-------------|----------|
| Configuração completa de base | Instalar, criar personagens Natália+Renato, DialogueManager autoload, skip implementado | ✓ |
| Apenas instalação e prova de conceito | Instalar, caixa de texto funciona, sem personagens definidos | |
| Pular Dialogic 2, sistema próprio | Caixa customizada sem plugin | |

**User's choice:** Configuração completa de base

---

| Option | Description | Selected |
|--------|-------------|----------|
| Portrait do sprite pixel art (mesmo sprite do jogo) | Reutilizar sprite sheet como portrait | |
| Portrait separado (busto/rosto em maior resolução) | Arte de busto dedicada para diálogos | ✓ |
| Placeholder colorido por personagem | Cores distintas como placeholder | |

**User's choice:** Portrait separado (busto em maior resolução)
**Notes:** Estilo JRPG/narrative. Arte final criada quando AMBAS as fotos estiverem disponíveis.

---

| Option | Description | Selected |
|--------|-------------|----------|
| Placeholder colorido para Renato (azul) por enquanto | Renato entra com portrait placeholder, substituído na Phase 3 | |
| Criar portrait da Natália agora, Renato entra na Phase 3 | Apenas Natália com portrait real na Phase 2 | |
| Aguardar ambas as fotos antes de criar portraits | Nenhum portrait definitivo na Phase 2 | ✓ |

**User's choice:** Aguardar ambas as fotos antes de criar portraits
**Notes:** Placeholder colorido (Natália=roxo, Renato=azul) para os testes de diálogo.

---

## Remapeamento de Controles

| Option | Description | Selected |
|--------|-------------|----------|
| Todas as ações de gameplay | walk_left, walk_right, jump, dash + poderes futuros | ✓ |
| Ações principais apenas (move + jump) | Dash e poderes fixos | |
| Claude decide (padrão da indústria) | Mesmas ações que jogos de plataforma indie expõem | |

**User's choice:** Todas as ações de gameplay

---

| Option | Description | Selected |
|--------|-------------|----------|
| ConfigFile separado (user://controls.cfg) | Arquivo separado do save de progresso | ✓ |
| Dentro do arquivo de save principal | Mistura preferências com progresso | |
| Só persiste na sessão atual (sem save) | Sem persistência entre sessões | |

**User's choice:** ConfigFile separado (user://controls.cfg)

---

| Option | Description | Selected |
|--------|-------------|----------|
| Prompts genéricos por enquanto | Ícones genéricos sem detectar marca | ✓ |
| Detectar DualSense vs Xbox, mostrar botões corretos | Arte de ícones + lógica de detecção | |
| Apenas texto ("Botão A" / "Botão Pular") | Sem ícone, texto descritivo | |

**User's choice:** Prompts genéricos por enquanto
**Notes:** Prompts por marca entram no Polish (Phase 12).

---

## Claude's Discretion

- Arquitetura exata do SaveManager (Singleton vs estático)
- Estrutura do dicionário de save (nomes de chaves, versão do schema)
- Posicionamento visual da UI de remapeamento no menu de opções
- Sistema de detecção de conflito de teclas no remapeamento
- Versão exata do Dialogic 2 compatível com Godot 4.4.x

## Deferred Ideas

- **Prompts de botão por marca** — Phase 12 Polish
- **Portrait com foto real** — Aguarda fotos de Natália E Renato
- **Múltiplos slots de save** — Fora de escopo v1
