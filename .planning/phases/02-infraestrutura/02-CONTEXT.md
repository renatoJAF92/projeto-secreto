# Phase 2: Infraestrutura - Context

**Gathered:** 2026-06-04
**Status:** Ready for planning

<domain>
## Phase Boundary

Implementar os quatro sistemas de suporte que todos os 8 mundos dependerão: (1) save automático com persistência de checkpoint/poderes/cutscenes, (2) sprite sheet pixel art da Natália baseado em foto real, (3) Dialogic 2 integrado com personagens configurados, (4) controles reconfiguráveis com suporte a gamepad. Nenhum gameplay novo é adicionado — apenas infraestrutura reutilizável.

</domain>

<decisions>
## Implementation Decisions

### Save System (SAVE-01, SAVE-02, SAVE-03)
- **D-01:** Slot único de save — sem seleção de múltiplos saves. Tela inicial com "Continue" (desativado sem save existente) e "New Game" (sobrescreve o save atual).
- **D-02:** O save persiste: ID do checkpoint (ex: `mundo1_fase2_cp3`), mundos completados, poderes desbloqueados, cutscenes já vistas. **Não** salva posição X/Y exata — respawn no início do checkpoint. Evita posições inválidas se fases mudarem entre versões.
- **D-03:** Formato: `FileAccess.store_var()` / `FileAccess.load_var()` — binário Godot nativo. Zero dependência extra, dificulta trapaça, suficiente para o escopo.
- **D-04:** Auto-save dispara em dois momentos: (a) ao jogador tocar em um checkpoint visual na fase, (b) ao completar uma fase. Não por timer contínuo.
- **D-05:** SaveManager implementado como autoload em `autoloads/save_manager.gd`. Padrão definido na Phase 0 (pasta `autoloads/` criada vazia para exatamente esse uso).

### Sprite NPC-04 — Natália (NPC-04)
- **D-06:** Renato fornecerá fotos reais da Natália imediatamente após essa discussão. O sprite sheet é criado a partir dessas fotos — não é placeholder genérico.
- **D-07:** Sprite sheet 32x32 com todas as 6 animações existentes no `player.gd`: idle, run, jump, fall, hurt, death (+ dash). Animações adicionais de poderes entram nas fases respectivas.
- **D-08:** Claude gera o sprite sheet programaticamente (GDScript Image API ou Python/Pillow) usando as fotos como referência de cor, proporção e traços. Resultado importado como SpriteFrames no AnimatedSprite2D do `player.tscn`.
- **D-09:** Portraits para Dialogic 2 aguardam tanto a foto da Natália quanto a do Renato antes de serem criados. Phase 2 usa placeholder colorido (Natália = roxo, Renato = azul) para o portrait nos diálogos de teste.

### Dialogic 2 (NARR-01, NARR-02)
- **D-10:** Instalar Dialogic 2 via AssetLib, configurar `DialogicGameHandler` como autoload em `autoloads/`. Validar compatibilidade com Godot 4.4.x antes de prosseguir (TODO aberto no STATE.md).
- **D-11:** Criar personagens `Natalia` e `Renato` no editor Dialogic 2 com portraits placeholder coloridos (roxo/azul). Estrutura pronta para receber portraits reais quando as fotos chegarem.
- **D-12:** Portrait style: **busto separado em maior resolução** — não o sprite de jogo. Consistente com o estilo JRPG/narrative; arte final criada quando as fotos de ambos estiverem disponíveis.
- **D-13:** Skip de cutscene (NARR-02): implementado via sinal Dialogic + dict `seen_cutscenes` no save. Cutscenes já vistas têm botão "Pular" visível desde o início; as não-vistas ainda podem ser puladas mas sem o botão proeminente.
- **D-14:** Um diálogo de teste demonstrável (Natália fala 2 linhas, Renato responde) deve passar no success criterion 3 da fase.

### Remapeamento de Controles (ACCESS-02, ACCESS-03)
- **D-15:** Expor **todas as ações de gameplay** ao remapeamento: `walk_left`, `walk_right`, `jump`, `dash`. Ações de poder adicionadas à lista à medida que forem desbloqueadas nas fases seguintes.
- **D-16:** Remapeamentos persistidos em arquivo **separado** do save de progresso: `user://controls.cfg` via Godot ConfigFile API. Resetar controles não afeta o save do jogo.
- **D-17:** Gamepad (DualSense/Xbox) funcional sem configuração extra. Prompts de botão **genéricos** por enquanto (ícone de botão simples, não por marca). Prompts por marca (DualSense vs Xbox) entram na Phase 12 — Polish.
- **D-18:** UI de remapeamento implementada como tela dentro do menu de opções. Padrão de inputs base: WASD/Setas + Space (pulo) + Shift (dash).

### Claude's Discretion
- Arquitetura exata do SaveManager (padrão Singleton vs. estático)
- Estrutura do dicionário de save (nomes de chaves, versão do schema)
- Posicionamento visual da UI de remapeamento no menu de opções
- Sistema de detecção de conflito de teclas no remapeamento
- Ordem exata de instalação do Dialogic 2 e compatibilidade de versão

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Projeto e Requisitos
- `.planning/REQUIREMENTS.md` — Requisitos SAVE-01, SAVE-02, SAVE-03, NARR-01, NARR-02, ACCESS-02, ACCESS-03, NPC-04 com success criteria completos.
- `.planning/ROADMAP.md` §Phase 2 — Goal, success criteria e dependências desta fase.
- `.planning/PROJECT.md` — Stack técnico, decisões-chave, sprites e referências visuais do projeto.

### Decisões de Fases Anteriores
- `.planning/phases/00-funda-o/00-CONTEXT.md` — Decisões de configuração do projeto (renderer Compatibility, pixel art settings, estrutura de pastas, autoloads/).
- `.planning/STATE.md` — Accumulated context com decisões técnicas (CPUParticles2D, hit-stop com process_always=true, CollisionShape2D 20x30).

### Código Existente
- `scenes/player/player.gd` — Controlador existente: animações definidas (idle, run, jump, fall, hurt, death, dash), inputs configurados (walk_left, walk_right, jump, dash), lógica de knockback e hit-stop.
- `scenes/player/player.tscn` — Cena do player com AnimatedSprite2D sem SpriteFrames (aguardando sprite sheet NPC-04).
- `autoloads/` — Pasta criada vazia na Phase 0; SaveManager e DialogueManager entram aqui.

### Dialogic 2
- Validar compatibilidade com Godot 4.4.x antes de instalar (TODO no STATE.md).
- AssetLib: buscar "Dialogic" na versão compatível com Godot 4.4.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `scenes/player/player.gd`: Já define 7 animações (idle, run, jump, fall, hurt, death + dash implícito) — sprite sheet deve cobrir exatamente essas animações.
- `scenes/player/player.gd`: Input actions já configuradas: `walk_left`, `walk_right`, `jump`, `dash` — mesmas ações que o menu de remapeamento deve expor.
- `autoloads/` (vazio): Pasta pronta para SaveManager, DialogueManager, AudioManager.

### Established Patterns
- **CPUParticles2D** (nunca GPUParticles2D): renderer gl_compatibility não suporta GPU particles na web.
- **`create_timer(duration, true)`**: argumento `process_always=true` obrigatório para hit-stop.
- **`velocity.x = _knockback.x`** (não `+=`): padrão de knockback sem acumulação, estabelecido na Phase 1.
- **`_physics_process` a 60Hz com frame counters**: padrão do projeto para timing (coyote, jump buffer, dash).

### Integration Points
- SaveManager deve ser chamado pelo player e pelos checkpoints de fase; o GameManager (ou equivalente) orquestra save-on-checkpoint.
- Dialogic 2 DialogicGameHandler como autoload; cenas de fase chamam `Dialogic.start("dialogue_name")`.
- Menu de opções (nova cena) conecta ao InputMap do Godot via `InputMap.action_get_events()` / `InputMap.action_add_event()`.

</code_context>

<specifics>
## Specific Ideas

- Renato fornecerá fotos reais da Natália após esta discussão — sprite sheet deve ser baseado na foto real, não em placeholder genérico.
- Portrait de diálogo: estilo busto (JRPG), resolução maior que o sprite de jogo, criado quando AMBAS as fotos (Natália + Renato) estiverem disponíveis.
- ConfigFile separado (`user://controls.cfg`) para controles — usuário pode resetar controles sem apagar o save do jogo.
- Save em `user://save.dat` via store_var() binário — caminho padrão Godot para dados persistentes cross-platform.

</specifics>

<deferred>
## Deferred Ideas

- **Prompts de botão por marca (DualSense vs Xbox)** — Entrada no Polish (Phase 12). Requer arte de ícones e lógica de detecção por Input.get_joy_name().
- **Portrait com foto real** — Aguarda fotos de Natália E Renato. Placeholder colorido por ora; portrait definitivo entra quando ambas as fotos estiverem disponíveis.
- **Múltiplos slots de save** — Fora de escopo para v1. Projeto pessoal/presente, sem necessidade de múltiplos perfis.
- **Voice acting** — Fora de escopo v1 (documentado em REQUIREMENTS.md).

</deferred>

---

*Phase: 2-Infraestrutura*
*Context gathered: 2026-06-04*
