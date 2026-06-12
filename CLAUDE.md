<!-- GSD:project-start source:PROJECT.md -->
## Project

**Jogo da Natália — De Osasco à Espanha**
<!-- GSD:project-end -->

## Autonomy

You have full autonomy to make implementation decisions, run shell commands, edit files, commit, and push to GitHub without asking for confirmation.

Only pause for:
- `/gsd-discuss-phase` checkpoints (design decisions that require the user's input)
- `checkpoint:human-verify` tasks in PLAN.md files (game feel and UI validation that require a human in the Godot editor)

<!-- GSD:stack-start source:research/STACK.md -->
## Technology Stack

## Recommended Stack
### Core Engine
| Technology | Version | Purpose | Rationale |
|------------|---------|---------|-----------|
| Godot 4 | **4.4.x or 4.5.x** | Game engine | 4.4 (March 2025) and 4.5 (June 2025) are the stable production targets. 4.6.x exists but was very recent at research time; stay on 4.4 or 4.5 unless a specific feature demands upgrading. Avoid Godot 3.x — TileMapLayer, physics interpolation, and improved web exports are 4.x-only. |
| GDScript | built-in | Scripting language | **Use GDScript, not C#.** C# cannot export to HTML5/Web in Godot 4 (confirmed as of 4.6). Since web export is a stated requirement, C# is disqualified entirely. GDScript also has faster iteration (no compile step), tighter editor integration, and all successful indie Godot games (Brotato, Dome Keeper, Cassette Beasts) used it. |
### Language Decision Detail: GDScript vs C#
- `@export` variables appear instantly in the Inspector — critical for tweaking jump physics, enemy speeds, dialogue timing
- Hot-reload without compilation means faster level iteration
- All Godot 4 documentation, tutorials, and community answers default to GDScript
- For a project of this scope (8 worlds, 1 dev, narrative focus), GDScript is more than sufficient
### Pixel Art Rendering Configuration
| Setting | Path | Value | Why |
|---------|------|-------|-----|
| Texture filter | Rendering > Textures > Canvas Textures > Default Texture Filter | **Nearest** | Prevents Godot's default linear filter from blurring pixel art during scaling. Without this, sprites look smeared. |
| Stretch mode | Display > Window > Stretch > Mode | **canvas_items** | Renders at full window resolution while keeping sprites pixel-perfect. Allows smooth camera movement. Alternative: `viewport` mode gives authentic low-res look but black bars on non-integer window sizes. |
| Scale mode | Display > Window > Stretch > Scale Mode | **integer** | Only scales by whole numbers (2x, 3x, 4x — never 2.7x). Prevents uneven pixel sizes where some pixels look larger than others. Available since Godot 4.3. |
| Snap transforms | Rendering > 2D > Snap 2D Transforms to Pixel | **On** | Prevents camera movement from causing sub-pixel jitter on sprites. Essential for pixel art cameras. |
| Base viewport | Display > Window > Size | **320x180** (or 640x360) | 320x180 is the pixel art standard for 16:9 that scales perfectly to 1280x720, 1920x1080, 2560x1440, and 4K. With 32x32 sprites, this gives ~10 tiles of vertical space — enough for a platformer. Use 640x360 if you want more screen real estate. |
### Sprite Sizes
| Asset Type | Recommended Size | Rationale |
|-----------|-----------------|-----------|
| Player (Natália) | **32x32** | Sweet spot for expressiveness: can show emotions, equipment detail, and animate cleanly. SNES/GBA-era feel. Professional pixel artists call this the production-speed/quality optimum for indie games. |
| Major NPCs (Renato, boss characters) | **32x32** | Consistent with player scale. Bosses can be 64x64 or larger as special cases. |
| Small enemies / collectibles | **16x16** | Enemies that are environmental hazards (gremlins, email projectiles) work well at 16x16 and are fast to animate. |
| Tiles / environment | **16x16** | Standard tile size. A 16x16 tile grid on a 320x180 viewport = 20 tiles wide × ~11 tiles tall. This is the right density for a platformer. |
| Boss sprites | **64x64 – 128x128** | Bosses like the Virus Chefão (full-screen boss) should be oversized. Use multiples of 16 or 32. |
| UI elements | **match native** | UI can be at higher resolution since it doesn't scroll. Design at 640x360 or native window size, not at 320x180 game resolution. |
### Audio
| Technology | Purpose | Format | Rationale |
|------------|---------|--------|-----------|
| Godot built-in AudioStreamPlayer2D | All SFX | **WAV** | Native, zero dependency, perfect for short sounds. WAV has no CPU decode cost, ideal for high-frequency sounds (footsteps, coin pickups, hit effects). |
| Godot built-in AudioStreamPlayer | Music / ambient | **OGG Vorbis** | Compressed, supports loop points natively, reduces file size for long tracks. The correct format for background music in Godot. |
| Godot 4.3+ AudioStreamInteractive | Adaptive music (optional) | OGG | New in 4.3, allows music to transition between states (tense → relaxed) — useful for the emotional arc of this game. Use if music composer delivers stems. |
- Music composition: Reaper or LMMS (free) + any VST library with Latin/Spanish flavors for thematic worlds
- SFX: sfxr/bfxr for chip-style sounds, or Freesound.org for real-world sounds
- Master to OGG at 44100Hz, 192kbps for music; export SFX as 44100Hz WAV (mono for most effects)
### Level Design: TileMap vs External Tools
| Tool | Verdict | Reason |
|------|---------|--------|
| Godot TileMapLayer (Godot 4.4+) | **Recommended** | TileMapLayer (replacing TileMap in 4.4) gives each layer its own node, enabling per-layer collision, navigation, and scripting. No import pipeline, no sync issues, physics chunks merged in 4.5 for better performance. |
| LDtk | Optional for complex world maps only | LDtk is the best external 2D editor (made by the Dead Cells creator), supports auto-tiling, entity layers, and custom properties. Has a Godot importer plugin. Use only if TileMapLayer becomes limiting for the overworld map. |
| Tiled | Do not use | Older codebase, inferior to LDtk for any new project. If you need an external editor, use LDtk instead. |
### Save System
| Approach | Use Case | Format |
|----------|----------|--------|
| Godot Resource (.tres) | Complex save data (player progress, world completion, powers unlocked) | Binary/text resource |
| `FileAccess.store_var()` | Simple persistent flags | Binary (Godot-native) |
### Version Control
| Area | Recommendation |
|------|---------------|
| .gitignore | Add `.godot/` (cache) and `*.translation` (compiled binary translations). Godot's project manager generates this automatically when you choose Git at project creation. |
| Binary assets (PNG, WAV, OGG) | Use **Git LFS** (Large File Storage). Configure `.gitattributes` to track `*.png`, `*.wav`, `*.ogg`, `*.mp3`, `*.ttf`, `*.otf`, `*.scn`, `*.res` via LFS. Set this up before the first commit — migrating after is painful. |
| Text assets | Regular Git tracking. All `.gd`, `.tscn`, `.tres`, `.import` files are text-diff friendly. |
| Branch strategy | Match the project's own plan: one branch per world or major mechanic. Tag each testable milestone (`v0.1-prototype`, `v0.2-world1-complete`). |
| Commit frequency | Commit after each working state. Godot scene files are XML-based and diff well, but partial `.tscn` edits can corrupt scenes — commit complete, playable states. |
#### Minimal .gitignore
# Godot cache
# Compiled translations
# Export artifacts
#### Minimal .gitattributes (Git LFS)
# Images
# Audio
# Godot binary resources
# Fonts
### CI/CD — Export and Publish
| Tool | Role |
|------|------|
| GitHub Actions | CI/CD runner (free for public repos) |
| `abarichello/godot-ci` Docker image | Pre-built image with Godot headless + export templates |
| Itchio butler | Uploads build artifacts to itch.io channels |
# .github/workflows/export.yml
- Always use `--headless --export-release` (not `--export`) for Godot 4
- Set `lfs: true` on the checkout step or binary assets will be missing from the build
- Tag-triggered deploys only (not every push) — otherwise you'll deploy broken in-progress builds
- The `BUTLER_CREDENTIALS` secret is an itch.io API key, not your password — generate it at itch.io/user/settings/api-keys
### Project Folder Structure
- Keep `.tscn` and `.gd` files in the same folder (scene-centric organization)
- One scene per boss, per NPC, per world level segment
- `autoloads/` contains only global singletons: `GameManager`, `AudioManager`, `SaveManager`, `DialogueManager`
- Limit autoloads to 5-8 max — do not put everything there
- `export_presets.cfg` **must be committed** to the repository — it contains your export configuration and is required for CI/CD to work
## Alternatives Considered and Rejected
| Category | Recommended | Rejected | Reason Rejected |
|----------|-------------|----------|-----------------|
| Language | GDScript | C# | Cannot export to HTML5 in Godot 4. Hard blocker for this project. |
| Language | GDScript | C++ (GDExtension) | Massively increased complexity for no benefit at this scale |
| Level editor | Built-in TileMapLayer | Tiled | Old codebase, no active reasons to prefer over LDtk or built-in |
| Level editor | Built-in TileMapLayer | LDtk | Adds external tool dependency and import pipeline. Built-in is sufficient. |
| Audio middleware | Built-in AudioStream | FMOD | Licensing, integration complexity, overkill for solo indie project |
| Audio middleware | Built-in AudioStream | Wwise | Same as FMOD, plus Wwise has complex licensing tiers |
| Save format | Godot Resources | JSON | Type conversion overhead, no editor inspection, no benefit for offline game |
| CI image | abarichello/godot-ci | Custom Docker | Well-maintained community image with correct Godot versions pre-installed |
| Engine | Godot 4 | Unity | License changes (2023 runtime fee debacle), cost, closed-source |
| Engine | Godot 4 | GameMaker | Inferior scripting, weaker web exports, costs money |
## Installation / Setup Checklist
# 1. Download Godot 4.4.x or 4.5.x from godotengine.org
#    Use the standard build (not .NET/.mono) — GDScript does not need .NET
# 2. Initialize Git LFS before first commit
# 3. In Godot Project Settings, apply pixel art settings:
#    - Rendering > Textures > Canvas Textures > Default Texture Filter = Nearest
#    - Display > Window > Stretch > Mode = canvas_items
#    - Display > Window > Stretch > Scale Mode = integer
#    - Display > Window > Size = 320 x 180 (viewport width/height)
#    - Rendering > 2D > Snap 2D Transforms to Pixel = On
# 4. Create export presets for: Windows Desktop, macOS, Web, Android (future)
#    Then commit export_presets.cfg
## Sources
- Godot 4.4 release: https://godotengine.org/releases/4.4/ (current stable)
- Godot 4.5 release: https://godotengine.org/releases/4.5/ (current stable)
- Godot 4.6 release: https://godotengine.org/releases/4.6/ (latest)
- GDScript vs C#, web export blocker: https://chickensoft.games/blog/gdscript-vs-csharp
- GDQuest pixel art setup guide: https://www.gdquest.com/library/pixel_art_setup_godot4/
- Godot 4.4 pixel art settings: https://itch.io/blog/806788/godot-44-settings-for-pixel-art
- Pixel art sprite sizing guide: https://pixelartapp.com/resolutions-guide
- Godot 4.3 web export fix (SharedArrayBuffer): https://godotengine.org/article/progress-report-web-export-in-4-3/
- Godot version control official docs: https://docs.godotengine.org/en/stable/tutorials/best_practices/version_control_systems.html
- godot-ci Docker image: https://github.com/abarichello/godot-ci
- Godot 4 audio formats: https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_audio_samples.html
- Godot 4.3 new audio features: https://blog.blips.fm/articles/the-new-music-features-in-godot-43-explained
- GDQuest save system guide: https://www.gdquest.com/library/save_game_godot4/
- Godot project organization: https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html
- TileMapLayer in Godot 4.4: https://gamefromscratch.com/godot-tilemap-replaced-with-tilelayers/
- Godot 4.5 TileMapLayer physics chunks: https://godotengine.org/releases/4.5/
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

Conventions not yet established. Will populate as patterns emerge during development.
<!-- GSD:conventions-end -->

## Game Design — Decisões por Fase

### Mecânicas Ambientais (todas as fases)

- **Plataformas móveis com buraco:** Sempre que houver plataforma aérea móvel (lado a lado), DEVE existir um buraco no chão abaixo dela. Player que ignorar a plataforma e seguir reto cai e morre (KillZone Area2D abaixo).
- **Obstáculo temporizado (timed_gate):** Bloqueia passagem inteiramente (colisão 16×128px) — player não passa nem andando nem pulando. Ciclo padrão: 4s fechado → 2s aberto. Pisca laranja 0.6s antes de fechar como aviso.

### Fase 1 — Ruas de Osasco

**Inimigos:** Malandros (walk, 40px/s), Malandro Resistente (2 hits), Malandro Coraza (dash), Moto com Dois Homens (velocidade alta)

**Elementos visuais de Osasco:**
- Ponte metálica (viaduto/overpass) no fundo — ParallaxLayer far (0.05x)
- Shopping centers no mid-ground — ParallaxLayer mid2 (0.3x)
- Trânsito de carros/ônibus — ParallaxLayer near (0.5x)
- Carrinho de cachorro quente — elemento fixo no mundo

**Mecânicas:** 1 plataforma móvel + buraco (x=1440–1664), 1 timed gate (x=5300)

---

### Fase 2 — Parque Villa Lobos

**Inimigos:**
- **Coruja (owl):** Voa lateralmente em patrol. Quando avista player (alcance 160x100px), faz ataque em parábola Bezier (razante no chão e volta ao ar). Player pode pisotear durante o ataque. Cooldown 2s entre ataques.
- **Patinador:** Versão mais veloz do malandro (130px/s), anda de patins. Mesmo padrão de stomp.
- Malandros, Malandro Resistente, MalandroCoraza como inimigos de chão.

**Mecânica das 3 plataformas consecutivas:**
- 3 plataformas aéreas com `phase_offset` diferente (0.0, 0.33, 0.66)
- Velocidade ligeiramente maior (55px/s vs 40px/s da fase 1)
- Player deve pular na hora certa entre as plataformas; cair = morte
- Pit2 tem 496px de largura (x=1904–2400), cobrindo as 3 plataformas

**Acessibilidade — Modo Bicicleta:**
- Se o player morrer ≥5x sem avançar para fase 3: aparece diálogo "Você gostaria de aprender a andar de bicicleta?"
- "Sim" → Natália ganha bicicleta (sprite sobreposto), velocidade 350px/s, invencível para dano de inimigos. Exclusivo da fase 2.
- "Não" → respawn no checkpoint normalmente.
- Estado salvo em `SaveManager.current_save["bicycle_active"]`. Limpo ao entrar na fase 3.
- Contador de mortes em `SaveManager.current_save["fase2_deaths"]`.

---

### Fase 3 — Padoca do Anão

*(Aguardando próximo prompt do usuário para detalhes de inimigos e mecânicas específicas)*

---

### Padrões de Componentes Reutilizáveis

| Componente | Arquivo | Uso |
|-----------|---------|-----|
| KillZone | `scenes/shared/kill_zone.gd` | Pit abaixo de plataformas — chama `player.instant_kill()` |
| TimedGate | `scenes/shared/timed_obstacle.gd/.tscn` | Obstáculo 4s/2s com warning blink |
| MovingPlatform | `scenes/shared/moving_platform.gd` | Use `phase_offset` para desincronizar múltiplas plataformas |
| DamageZone | `scenes/shared/damage_zone.gd` | Dano periódico em área (barreiras de obra) |

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

Architecture not yet mapped. Follow existing patterns found in the codebase.
<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->
## Project Skills

No project skills found. Add skills to any of: `.claude/skills/`, `.agents/skills/`, `.cursor/skills/`, `.github/skills/`, or `.codex/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
