# Phase 0: Fundação - Context

**Gathered:** 2026-05-20
**Status:** Ready for planning

<domain>
## Phase Boundary

Criar e configurar o projeto Godot 4 do zero: Git LFS ativo, renderer Compatibility definido, estrutura de pastas completa, cena mínima de teste e CI/CD com GitHub Actions para export automático. Nenhum gameplay é implementado nesta fase.

</domain>

<decisions>
## Implementation Decisions

### Engine e Versão
- **D-01:** Godot 4.4.x — versão estável com TileMapLayer, melhor suporte pixel art e imagem Docker godot-ci disponível. Não usar 4.5.x ou 4.6.x nesta fase.
- **D-02:** GDScript (não C#). C# bloqueia export HTML5 — decisão irrevogável para este projeto.

### Identidade do Projeto
- **D-03:** Nome do projeto no project.godot: `"Destiny — Tales of Natalia"`. Este nome aparece na janela do jogo, builds e itch.io.

### Viewport e Pixel Art
- **D-04:** Resolução base do viewport: **320×180**. Decisão permanente — não mudar depois sem quebrar todo o level design. Escala perfeitamente para 720p, 1080p, 1440p e 4K com integer scale.
- **D-05:** Configurações pixel art obrigatórias em Project Settings:
  - Rendering > Textures > Canvas Textures > Default Texture Filter = **Nearest**
  - Display > Window > Stretch > Mode = **canvas_items**
  - Display > Window > Stretch > Scale Mode = **integer**
  - Display > Window > Size = **320 × 180**
  - Rendering > 2D > Snap 2D Transforms to Pixel = **On**
  - Rendering > Renderer = **Compatibility** (obrigatório para web export)

### Git LFS
- **D-06:** Inicializar Git LFS antes do primeiro commit de asset binário. `.gitattributes` rastreia via LFS:
  `*.png`, `*.jpg`, `*.wav`, `*.ogg`, `*.mp3`, `*.ttf`, `*.otf`, `*.scn`, `*.res`
- **D-07:** `.gitignore` mínimo: `.godot/` (cache), `*.translation` (traduções compiladas), `export/` (artifacts de export).

### Estrutura de Pastas
- **D-08:** Criar estrutura de pastas completa desde o início (não crescer conforme necessário):
  ```
  scenes/
  assets/
    sprites/
      player/
      enemies/
      ui/
    audio/
      sfx/
      music/
  scripts/
  autoloads/
  export/
  .github/
    workflows/
  ```
- **D-09:** `autoloads/` é criada como pasta vazia — scripts de GameManager, SaveManager, AudioManager entram na Phase 2. Phase 0 não cria stubs de código.
- **D-10:** `export_presets.cfg` deve ser commitado no repositório (obrigatório para CI/CD funcionar).

### Export Presets
- **D-11:** Configurar 3 export presets na Phase 0: **Web (HTML5)**, **Windows Desktop**, **macOS**. Android é defeito para v2 (já mapeado nos v2 requirements).
- **D-12:** Web export usa renderer Compatibility (definido em D-05). Testar localmente com `godot --export-release "Web" ...` antes de declarar fase completa.

### Cena de Teste
- **D-13:** Criar uma cena mínima `scenes/main.tscn` com: Node2D raiz + Label "v0.0 — Destiny: Tales of Natalia". Esta cena valida que o export web abre no navegador sem erro e estabelece o hábito de versionar visualmente.

### CI/CD — GitHub Actions
- **D-14:** CI/CD entra na Phase 0 com dois comportamentos:
  - **Tags `v*`** (ex: `v0.0`, `v0.1`): export completo (Web + Windows + macOS) + upload para itch.io via butler.
  - **Pull Requests**: build sem deploy — apenas verifica que o projeto compila.
- **D-15:** Docker image: `abarichello/godot-ci` com tag correspondente ao Godot 4.4.x.
- **D-16:** Target itch.io: placeholder `ITCH_USER/destiny-tales-of-natalia` no workflow. Atualizar quando a página for criada no itch.io e adicionar secret `BUTLER_CREDENTIALS` (API key do itch.io, não senha).
- **D-17:** Checkout step deve ter `lfs: true` — sem isso, assets binários ficam como ponteiros LFS no build e o export falha.
- **D-18:** Usar `--headless --export-release` (não `--export`) no comando godot do CI.

### Claude's Discretion
- Ordem exata das seções no `export.yml` (jobs, steps, artefatos) — seguir convenções do `abarichello/godot-ci`.
- Versão patch exata do Godot 4.4 (4.4.0, 4.4.1, 4.4.2...) — usar a mais recente disponível no godot-ci no momento da execução.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Stack e Configuração
- `.planning/research/STACK.md` — Referência completa de stack: configurações pixel art, formatos de áudio, estrutura de pastas, save system, CI/CD setup. **Leitura obrigatória antes de planejar.**
- `.planning/REQUIREMENTS.md` — Tabela de rastreabilidade REQ-ID ↔ Phase. Phase 0 responde por EXPORT-03.
- `.planning/ROADMAP.md` §Phase 0 — Goal, success criteria e dependências desta fase.

### CI/CD
- `abarichello/godot-ci` (GitHub): imagem Docker pré-configurada com Godot headless + export templates. Verificar tag disponível para Godot 4.4.x.

### Sem specs externas adicionais
- Todas as decisões de implementação desta fase estão capturadas nas decisões acima e no STACK.md.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- Nenhum — codebase está vazio. Phase 0 cria toda a estrutura do zero.

### Established Patterns
- Nenhum padrão estabelecido ainda. Phase 0 define os padrões base de organização.

### Integration Points
- `export_presets.cfg` deve ser versionado no root do projeto Godot (não na raiz do repo git se forem diferentes).
- `.gitattributes` e `.gitignore` ficam na raiz do repositório git.

</code_context>

<specifics>
## Specific Ideas

- Nome do jogo: **"Destiny — Tales of Natalia"** (inglês, escolha definitiva do usuário).
- Cena de teste com versão explícita (`v0.0`) estabelece o padrão de build versioning para todas as fases seguintes.
- CI/CD configurado na Phase 0 garante que cada fase entrega um build testável no itch.io desde o início — sem ter que configurar pipeline depois.

</specifics>

<deferred>
## Deferred Ideas

- **Android export** — para v2 (já mapeado nos v2 deferred requirements do REQUIREMENTS.md). Requer Android SDK e keystore; complexidade não justifica na Phase 0.
- **macOS code signing** — Apple exige assinatura para distribuição fora do itch.io. Deferred junto com fase de release/polish.

</deferred>

---

*Phase: 0-Fundação*
*Context gathered: 2026-05-20*
