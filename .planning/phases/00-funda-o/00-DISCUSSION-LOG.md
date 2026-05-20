# Phase 0: Fundação - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-20
**Phase:** 00-Fundação
**Areas discussed:** Versão do Godot, Viewport, CI/CD scope, Estrutura de pastas, Nome do projeto, Export presets, Cena de teste, Autoload stubs, Android

---

## Versão do Godot

| Option | Description | Selected |
|--------|-------------|----------|
| 4.4.x | Estável, TileMapLayer, godot-ci Docker disponível | ✓ |
| 4.5.x | Mais recente, physics chunks melhorado, alguns plugins não atualizados | |
| 4.3.x | Ainda estável, integer scale disponível, mais antigo | |

**User's choice:** 4.4.x (Recomendado)
**Notes:** Escolha pela estabilidade e suporte maduro do ecossistema.

---

## Viewport Resolution

| Option | Description | Selected |
|--------|-------------|----------|
| 320×180 | Padrão pixel art 16:9, escala para 720p/1080p/1440p/4K com integer scale | ✓ |
| 640×360 | Mais espaço na tela, menos retro, o dobro de tiles visíveis | |

**User's choice:** 320×180 (Recomendado)
**Notes:** Decisão permanente confirmada. Consistente com feel retro do projeto.

---

## CI/CD Scope

| Option | Description | Selected |
|--------|-------------|----------|
| Phase 0 — configurar agora | Export automático para itch.io em cada tag | ✓ |
| Deferir para Phase 12 | Phase 0 mais simples, CI/CD no polish final | |
| Estrutura agora, deploy manual depois | Workflow criado, secret configurado depois | |

**User's choice:** Phase 0 — configurar agora
**Notes:** Pipeline de CI desde o início garante builds testáveis a cada fase.

---

## CI Trigger

| Option | Description | Selected |
|--------|-------------|----------|
| Tags de versão | Deploy só em tags v* | |
| Cada push em main | Deploy contínuo, pode publicar estados quebrados | |
| Tags + PR checks | Tags deployam, PRs verificam build sem deployar | ✓ |

**User's choice:** Tags + PR checks
**Notes:** Combinação mais robusta — proteção contra deploys quebrados + validação em PRs.

---

## Target itch.io

| Option | Description | Selected |
|--------|-------------|----------|
| Placeholder agora | Workflow criado com placeholder, atualiza quando tiver a página | ✓ |
| Já tenho conta/página | Configura diretamente com username/slug | |

**User's choice:** Configurar placeholder agora
**Notes:** Página no itch.io ainda não criada. Actualizar BUTLER_CREDENTIALS quando pronto.

---

## Estrutura de Pastas

| Option | Description | Selected |
|--------|-------------|----------|
| Mínimo agora, organizar depois | Só top-level, sub-pastas surgem com assets | |
| Estrutura completa desde já | assets/sprites/player/, audio/sfx/, etc. desde o início | ✓ |

**User's choice:** Estrutura completa desde já (Recomendado)
**Notes:** Evita reorganização futura, planner e executor seguem estrutura clara.

---

## Nome do Projeto

| Option | Description | Selected |
|--------|-------------|----------|
| Jogo da Natália | Nome simples em português | |
| Jogo da Natália — De Osasco à Espanha | Nome completo do PROJECT.md | |
| natalia-journey | Slug técnico ASCII | |
| Destiny — Tales of Natalia | Nome em inglês, escolha do usuário | ✓ |

**User's choice:** "Destiny — Tales of Natalia" (digitado como "Destiny - Tales of Natalia")
**Notes:** Nome definitivo. Diferente do PROJECT.md original — o usuário optou por um título em inglês com apelo mais universal.

---

## Export Presets

| Option | Description | Selected |
|--------|-------------|----------|
| Web apenas | Só o que está nos success criteria | |
| Web + Windows + macOS | Tudo de uma vez, custo único | ✓ |
| Web + Windows | macOS tem complexidade de code signing | |

**User's choice:** Web + Windows + macOS (opção 2)
**Notes:** Usuário mencionou interesse em Android para tablet no futuro — deferido para v2.

---

## Android

| Option | Description | Selected |
|--------|-------------|----------|
| Deferir para v2 | Já mapeado nos v2 deferred requirements | ✓ |
| Incluir na Phase 0 | Requer Android SDK e keystore | |

**User's choice:** Deferir para v2
**Notes:** Complexidade não justifica na Phase 0. Usuário confirmou.

---

## Cena de Teste

| Option | Description | Selected |
|--------|-------------|----------|
| Label simples em fundo preto | Valida carregamento e canvas_items | |
| Sprite placeholder 32×32 | Valida também rendering de sprites | |
| Hello World com versão do jogo | Label "v0.0 — foundation", estabelece hábito de versioning | ✓ |

**User's choice:** Cena de 'Hello World' com versão do jogo
**Notes:** Versão explícita no build serve como referência visual para todas as fases futuras.

---

## Autoload Stubs

| Option | Description | Selected |
|--------|-------------|----------|
| Só a pasta autoloads/ | Phase 0 é configuração, não código | ✓ |
| Criar stubs vazios agora | Arquitetura visível desde o início | |

**User's choice:** Só a pasta autoloads/ (Recomendado)
**Notes:** GameManager, SaveManager, AudioManager entram na Phase 2. Phase 0 mantém escopo mínimo.

---

## Claude's Discretion

- Ordem exata das seções no `export.yml` (jobs, steps, artifacts) — seguir convenções do `abarichello/godot-ci`.
- Versão patch exata do Godot 4.4 — usar a mais recente disponível no godot-ci no momento da execução.

## Deferred Ideas

- **Android export** — v2 requirements (já mapeado). Requer Android SDK + keystore; complexidade não justificada na Phase 0.
- **macOS code signing** — distribuição fora do itch.io exige assinatura Apple. Junto com fase de release/polish.
