---
phase: 3
slug: mundo-1-osasco-vertical-slice-completo
status: draft
shadcn_initialized: false
preset: none
created: 2026-06-08
game_engine: Godot 4.4.1 (GDScript)
viewport: 320x180 (canvas_items stretch, integer scale)
extends: phases/02-infraestrutura/02-UI-SPEC.md
---

# Phase 3 — Mundo 1 (Osasco): UI Design Contract

> Visual and interaction contract for all new UI elements and in-world game objects
> delivered in Phase 3: Mundo 1 — Osasco (vertical slice completo).
>
> **Extends Phase 2 UI-SPEC** — all Phase 2 tokens (spacing, typography, color palette,
> node patterns) remain in force. This document specifies only what is NEW in Phase 3.
>
> This is a Godot 4 pixel art game. All measurements are in game pixels at the 320x180
> base resolution. No CSS, no web framework, no shadcn.

---

## Design System (inherited + Phase 3 additions)

| Property | Value |
|----------|-------|
| Tool | Godot 4 Control nodes + Node2D hierarchy (no CSS) |
| Preset | not applicable |
| Component library | Built-in: CharacterBody2D, Area2D, Sprite2D, AnimatedSprite2D, Control, CanvasLayer, ProgressBar, NinePatchRect, CPUParticles2D |
| Icon library | pixel art glyphs at 8x8 or 16x16 (no icon font) |
| Font | m5x7 bitmap font, 8px body, 16px titles (inherited from Phase 2) |
| Renderer | GL Compatibility (inherited — web export required) |
| Particles | CPUParticles2D only — never GPUParticles2D (Compatibility renderer constraint) |

**Design language:** retro JRPG / 16-bit platformer — dark urban Osasco palette. Warm
accent colours (laranja/vermelho) on interactive elements, NPCs, and checkpoints contrast
against cool dark backgrounds. Placeholder art (geometric coloured shapes) is acceptable
for all sprites in this phase. Real pixel art enters Phase 12.

---

## Pixel Grid & Spacing Scale (inherited from Phase 2)

All spacing values in game pixels (320x180 base). Use multiples of 4.

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4 px | Inline gaps, icon-label spacing |
| sm | 8 px | Padding inside Panel/NinePatchRect; gap between list items |
| md | 16 px | Default margin between UI elements |
| lg | 24 px | Section separation |
| xl | 32 px | Vertical centering margin at screen edges |
| 2xl | 48 px | Portrait container width offset |
| 3xl | 64 px | Portrait width (dialogue) |

Phase 3 exceptions:
- Boss trust bar height: 8 px (not a spacing token — it is a bar thickness).
- Boss trust bar width: 200 px (spans centre of screen, fixed).
- HUD top margin: 4 px from screen top edge.
- Checkpoint sprite: 16x24 px (cartaz poster, taller than tile standard, fits 1.5 tiles vertically).
- Prova collectible sprite: 16x16 px (same as small enemy/collectible standard).
- Malandro enemy sprite: 16x32 px (taller humanoid shape, placeholder rectangle).
- Luis boss sprite: 32x48 px (boss is larger than player sprite 32x32; portrait-style proportion).
- NPC Renato in-world sprite: 16x32 px (simplified, same dimensions as Malandro but different colour).
- Luis foreshadowing sprite: 16x32 px (same as NPC Renato; placed in background layer).

---

## Typography (inherited from Phase 2)

| Role | Size | Weight | Line Height | Usage |
|------|------|--------|-------------|-------|
| Dialogue body | 8 px | regular | 1.5 (12 px) | All Dialogic text, boss dialogue |
| UI label | 8 px | regular | 1.25 (10 px) | Trust bar label, prova count |
| Screen title | 16 px | bold | 1.2 (19 px) | Narrative opening title, boss victory overlay |
| Character name | 8 px | bold | 1.0 (8 px) | Speaker name in dialogue box |

No new type roles in Phase 3. All typography reuses Phase 2 definitions.

---

## Color Palette (Phase 2 base + Phase 3 world additions)

Phase 2 palette is fully inherited. Phase 3 adds three warm accent colours for the
Osasco world identity (D-03: "cinza urbano com acentos de cor quente").

| Role | Hex | Usage |
|------|-----|-------|
| Dominant (60%) — dark background | `#1A1A2E` | Scene background, all panel fills (inherited) |
| Secondary (30%) — mid surface | `#16213E` | Button bg, NinePatchRect panels (inherited) |
| Accent (10%) — electric blue | `#0F3460` | Boss HUD border, focused buttons (inherited) |
| Text primary | `#E8E8F0` | All labels, dialogue text (inherited) |
| Text secondary | `#8888AA` | Disabled text, hints (inherited) |
| Action green | `#4CAF50` | Trust bar fill 0–79% (inherited semantic; new usage) |
| Destructive red | `#E53935` | Trust bar fill when < 20%; game over flash (inherited semantic; new usage) |
| Prompt yellow | `#FFDD57` | Gamepad prompt glyphs (inherited) |
| **World accent — laranja** | `#E07020` | Checkpoint McFly cartaz inactive state; collectible prova glow; warm environmental highlights in Osasco |
| **World accent — vermelho quente** | `#C83030` | Malandro enemy placeholder fill; static obstacle placeholder fill |
| **Trust bar gold** | `#D4A017` | Trust bar fill 80–100% (Renato arrives; victory state) |

**Accent (`#0F3460`) reserved for:** boss HUD CanvasLayer border, trust bar container
NinePatchRect border, focused button outlines (same as Phase 2 — no expansion).

**Laranja (`#E07020`) reserved for:** checkpoint inactive glyph tint, prova collectible
outer glow particle tint, McFly cartaz sprite modulate when inactive. Not used on non-
interactive elements or any UI chrome.

**Trust bar gold (`#D4A017`) reserved for:** trust bar fill colour ONLY when bar value is
between 80% and 100%. Signals Renato's arrival and imminent victory. No other use.

---

## Element Contracts

### 1. Checkpoint Node — McFly Cartaz

**Requirement:** WORLD-03, WORLD-05, D-08, D-09, D-11

**Godot node type:** Area2D (with CollisionShape2D + AnimatedSprite2D)

**Scene file:** `scenes/world1/checkpoint.tscn` (instanced into each world1 scene)

**Sprite dimensions:** 16 px wide, 24 px tall (placeholder: laranja `#E07020` rectangle
with a thin white horizontal stripe across the top 4 px to suggest a band logo/poster).

**Visual states:**

| State | Modulate | Animation | Condition |
|-------|----------|-----------|-----------|
| `inactive` | `#888888` (grayscale wash — 50% brightness) | static frame | Default on scene load; checkpoint not yet reached |
| `activating` | `#E07020` (laranja) + `#FFFFFF` flash | pulse: scale 1.0 → 1.25 → 1.0 over 12 frames via Tween | Triggered once when player body_entered; plays once |
| `active` | `#E07020` (laranja) tint | idle loop: alpha 0.8 → 1.0 at 1 Hz via Tween | Remains after activation until scene reload |

**Collision:** CollisionShape2D RectangleShape2D, 16x24 px, same as sprite. No physics
layer — monitoring only (Area2D signal `body_entered`).

**Activation signal flow:**
```
checkpoint.body_entered(body) →
  if body.is_in_group("player") and not _activated:
    _activated = true
    SaveManager.set_checkpoint(checkpoint_id)  # e.g. "mundo1_fase1_cp1"
    SaveManager.save_game()
    _play_activate_animation()
    AudioManager.play_sfx("checkpoint")
```

**SFX:** `checkpoint` (bfxr/sfxr chiptune placeholder — bright ascending tone).

**CanvasLayer:** none (world-space node — not in UI layer).

---

### 2. Prova Collectible — Foto / Carta / Presente

**Requirement:** BOSS-01, D-12, D-13, D-14, D-15

**Godot node type:** Area2D (with CollisionShape2D + AnimatedSprite2D + CPUParticles2D)

**Scene file:** `scenes/world1/prova_item.tscn` (instanced into fase1, fase2, fase3)

**Sprite dimensions:** 16x16 px.

Placeholder sprite per prova type (in Phase 3, geometric shapes only):

| Prova ID | Placeholder | Description |
|----------|-------------|-------------|
| `prova_foto` | 16x16 white square with `#E8E8F0` fill | Represents a photo |
| `prova_carta` | 16x16 light blue `#2980B9` envelope shape (rectangle + triangle top) | Represents a letter |
| `prova_presente` | 16x16 `#4CAF50` green square with `#E07020` bow stripe across top | Represents a gift |

**Animation:** idle loop — AnimatedSprite2D cycles between 2 frames (frame 1: normal,
frame 2: 1 px shift up) at 4 FPS. Creates a gentle floating/bobbing effect.

**Glow particles:** CPUParticles2D child node.

| Particle property | Value |
|-------------------|-------|
| Amount | 6 |
| Lifetime | 1.2 s |
| Speed min/max | 4 / 8 px/s |
| Direction | upward (angle 90° ± 20°) |
| Color | `#E07020` (laranja) |
| Scale | 1 px point particles |
| Emission shape | Box, 16x4 px (base of sprite) |

**Collection feedback:**
1. `body_entered` fires → prova ID added to `SaveManager.current_save["provas_mundo1"]` → `SaveManager.save_game()`.
2. Sprite and particles: `queue_free()` immediately (item disappears).
3. Juice: CPUParticles2D burst (one-shot emission, 12 particles in 0.2 s, scatter outward 30 px) plays at collection position before node removal — use `SceneTreeTimer` to delay `queue_free` by 0.25 s.
4. SFX: `AudioManager.play_sfx("prova_coletada")` — bright chime bfxr tone.

**No HUD indicator during platforming phases (D-14).** Prova count is NOT shown during
fase1, fase2, fase3. Count revealed only in boss_pai.tscn.

**CanvasLayer:** none (world-space node).

---

### 3. Enemy Visual Contracts

#### 3a. Malandro (patrolling humanoid enemy)

**Requirement:** WORLD-01, D-06

**Godot node type:** CharacterBody2D

**Scene file:** `scenes/world1/malandro.tscn`

**Sprite dimensions:** 16 px wide, 32 px tall.

**Placeholder art:** Solid `#C83030` (vermelho quente) rectangle 16x32 px. White pixel
eyes (2x1 px each, at y=6 from top, x=4 and x=10) to convey direction.

**CollisionShape2D:** CapsuleShape2D, radius=6 px, height=22 px (centered; leaves 2 px
margins on each side of 16 px width to avoid wall-sticking — consistent with player
CollisionShape2D design rationale from Phase 1).

**Animations (AnimatedSprite2D, 2-frame each at 8 FPS):**

| State | Frames | Description |
|-------|--------|-------------|
| `walk` | 2 frames: body shift left/right 1 px | Default patrol state |
| `death` | 1 frame: flattened rectangle 16x4 px, `#888888` modulate | Triggered on stomp; plays once then queue_free |

**Patrol behaviour (defined in code contract, not UI, but visual implications):**
- Sprite flips `flip_h` when turning direction.
- Patrol speed: 40 px/s (Claude's discretion default — adjustable per instance via `@export`).

**Stomp kill visual:**
1. Velocity.y check in player.gd (player falling + collide top of enemy).
2. Enemy: plays `death` animation, freezes collision, then `queue_free()` after 0.3 s.
3. SFX: `AudioManager.play_sfx("stomp")` — percussion thud bfxr tone.
4. No score or kill counter displayed.

**Contact damage to player:** uses existing `player.gd` knockback system. No new visual
on the Malandro itself — player receives white flash + knockback (Phase 1 system).

#### 3b. Static Obstacle (environmental hazard)

**Requirement:** WORLD-01, D-06

**Godot node type:** Area2D (static — no movement)

**Scene file:** `scenes/world1/static_obstacle.tscn`

**Sprite dimensions:** 16x16 px (can be instanced in a row to create wider hazards).

**Placeholder art:** `#C83030` (vermelho quente) rectangle with a 2x2 px `#FFDD57`
(yellow) corner marker to distinguish it from enemy fill.

**Collision:** CollisionShape2D RectangleShape2D, 14x14 px (1 px inset per side). Area2D
monitoring only — no physics body, never moves.

**States:** single static frame. No animation. Not destroyed by player actions.

**Contact damage:** `body_entered` with player → calls player's `take_damage()` method
same as Malandro contact. SFX: `AudioManager.play_sfx("dano")` — buzzer bfxr tone.

**CanvasLayer:** none (world-space node).

---

### 4. Boss HUD — Barra de Confiança

**Requirement:** BOSS-01, D-17, D-19, D-20, D-21

**Godot node type:** CanvasLayer (layer=2) containing a Control HUD

**Scene file:** part of `scenes/world1/boss_pai.tscn` scene tree (not a separate scene)

**CanvasLayer ordering:**
| Layer | Node | Reason |
|-------|------|--------|
| 100 | SceneTransition | Full-screen fade (inherited from Phase 2) |
| 50 | Dialogic layout | Dialogue box (inherited from Phase 2) |
| **2** | **BossHUD** | Above Dialogic (50 would be below), below SceneTransition |

Wait — Dialogic is at layer=50. BossHUD must be above Dialogic (visible over it) so
trust bar shows while dialogue plays. Therefore BossHUD = layer **51**.

**Corrected CanvasLayer ordering:**
| Layer | Node | Reason |
|-------|------|--------|
| 100 | SceneTransition | Full-screen fade |
| 51 | BossHUD | Trust bar — above Dialogic, below SceneTransition |
| 50 | Dialogic layout | Dialogue box |

**HUD layout (top of 320x180 screen):**

```
┌──────────────────────────────────────────┐  ← y=0 (screen top)
│  4px margin                              │  ← xs token
│  [CONFIANÇA] [████████████████░░░░░] 75% │  ← y=4
│  label 8px   bar 200px wide, 8px tall    │
│              x=56 to x=256               │
│  12px bottom margin to scene content     │  ← y=20
└──────────────────────────────────────────┘
```

**Label "CONFIANÇA":**
- Font: 8px m5x7, colour `#E8E8F0`.
- Position: x=8, y=6 (vertically centred with bar).
- Width: 48 px (fits "CONFIANÇA" in m5x7 at 8 px).

**Trust bar container (NinePatchRect):**
- Position: x=56, y=4.
- Dimensions: 200 px wide, 8 px tall.
- Border: 1 px, colour `#0F3460` (accent).
- Background fill: `#16213E` (secondary).

**Trust bar fill (ProgressBar or TextureRect animated via code):**
- Fills left-to-right proportional to value 0–100.
- Fill colour transitions:

| Value range | Fill colour | Meaning |
|-------------|-------------|---------|
| 0–19% | `#E53935` (destructive red) | Critical — near game over |
| 20–79% | `#4CAF50` (action green) | Normal progress |
| 80–100% | `#D4A017` (trust bar gold) | Renato entered; victory near |

Fill colour changes immediately on value update (no gradient — pixel art, step change).

**Percentage label:**
- Font: 8px m5x7, colour `#E8E8F0`.
- Position: x=260, y=6 (right of bar, 4 px gap after bar ends at x=256).
- Text: `"75%"` (format: integer percentage, no decimal).
- Width: 24 px.

**Visibility:** BossHUD is visible only during `boss_pai.tscn`. Hidden in all other scenes
(node not present — it's part of boss scene only, not a global autoload HUD).

**Value update signal:**
```
func update_trust(new_value: float) -> void:
    _trust_bar.value = new_value
    _pct_label.text = str(int(new_value)) + "%"
    _update_bar_color(new_value)

func _update_bar_color(v: float) -> void:
    if v < 20.0:
        _bar_fill.modulate = Color("#E53935")
    elif v < 80.0:
        _bar_fill.modulate = Color("#4CAF50")
    else:
        _bar_fill.modulate = Color("#D4A017")
```

---

### 5. Boss Proof Presentation — Provas no Boss Dialogue

**Requirement:** BOSS-01, D-13, D-17, D-18

**Presentation approach (automatic on boss scene enter — Claude's discretion):**

When `boss_pai.tscn` loads:
1. Boss scene reads `SaveManager.current_save["provas_mundo1"]` (array of IDs).
2. If array has < 2 entries: show blocking dialogue "Preciso de mais provas antes de
   encarar o pai" → scene transitions back to last checkpoint in fase3_restaurante.
3. If array has >= 2 entries: BossHUD appears, Dialogic timeline `boss_abertura` starts
   automatically.

**In-dialogue prova presentation (visual contract):**
- When Dialogic timeline reaches a `[present_prova: prova_foto]` custom event, the boss
  script pauses Dialogic, shows a **ProvaCard** overlay, then resumes.
- **ProvaCard:** CanvasLayer layer=52 (above BossHUD at 51, below SceneTransition at 100).
  - Size: 80x64 px, centred at screen position x=120, y=58 (screen centre).
  - Background: NinePatchRect, `#16213E` fill, `#0F3460` (accent) 1px border.
  - Prova sprite: centred within card, 32x32 px (2x upscale of the 16x16 collectible).
  - Prova name label: 8px m5x7, `#E8E8F0`, centred below sprite, 4 px gap.
  - Display duration: 1.5 s, then ProvaCard fades out (alpha 1.0 → 0.0 in 0.3 s via Tween) and Dialogic resumes.
  - SFX: `AudioManager.play_sfx("prova_apresentada")` — confident ding tone.
- Trust bar increases by `+20` per prova presented (20% per prova; 3 provas = +60% from provas alone — remainder filled by correct dialogue choices).

**Correct dialogue choice:** +10% trust per correct choice.
**Wrong dialogue choice:** -15% trust. SFX: `AudioManager.play_sfx("dialogo_errado")` — low buzzer.

---

### 6. Boss Game Over / Victory Visual Feedback

**Requirement:** BOSS-01, D-20, D-21

#### 6a. Game Over (trust bar reaches 0%)

**Trigger:** `trust_value <= 0.0`

**Visual sequence:**
1. Trust bar fill snaps to `#E53935` and the bar container shakes (Tween: x offset -2 → +2 → -2 → 0 over 0.3 s, 3 cycles).
2. Dialogic stops.
3. BossHUD label changes to `"CONFIANÇA PERDIDA"` (8px, colour `#E53935`), visible for 1.5 s.
4. Full-screen flash: ColorRect CanvasLayer layer=99 (just below SceneTransition at 100), colour `#E53935`, alpha 0.0 → 0.5 → 0.0 in 0.5 s.
5. `SceneTransition.go_to("scenes/world1/boss_pai.tscn")` — reloads boss scene.
6. On reload: trust bar resets to 0% (start value), provas array preserved in SaveManager.

#### 6b. Victory (trust bar reaches 100%)

**Trigger:** `trust_value >= 100.0`

**Renato arrival at ~80%:**
- At `trust_value >= 80.0`, script calls `Dialogic.start("boss_renato_entrada")`.
- Renato NPC sprite (32x32 placeholder, `#2980B9` blue) is instantiated at the door
  position of the boss scene (x=270, y=100, entering from right edge).
- Tween: x slides from 290 to 270 over 0.5 s (walking in).
- Dialogic timeline `boss_renato_entrada` plays Renato's commitment lines.
- After timeline ends: trust bar receives final +20 (bringing it to 100%).

**Victory sequence:**
1. Trust bar fill changes to `#D4A017` (gold) — full width.
2. CPUParticles2D burst from bar position: 20 gold particles (`#D4A017`), scatter upward, 0.8 s lifetime.
3. Dialogic starts `boss_vitoria` timeline (Luis accepts Renato, conclusion lines).
4. After `boss_vitoria` ends: full-screen white flash (CanvasLayer 99, `#FFFFFF`, alpha 0.0 → 1.0 in 0.5 s).
5. `SceneTransition.go_to("scenes/world1/world1_credits.tscn")` — or a placeholder end scene for Phase 3.
6. SFX: `AudioManager.play_sfx("vitoria")` — ascending fanfare bfxr tone.

---

### 7. NPC Renato — In-Scene (Parque + Restaurante + Boss)

**Requirement:** NPC-01, D-24, D-25

#### 7a. Fase 2 — Parque (background NPC, no dialogue)

**Godot node type:** Node2D containing Sprite2D (static — no CharacterBody2D needed)

**Position:** background parallax layer (behind midground elements). Specific placement:
x=220, y=110 (right-side background, partially obscured by a tree or bush tile from the
TileMapLayer). Depth illusion via `CanvasLayer` or Node2D z_index = -1.

**Sprite:** 16x32 px placeholder. `#2980B9` (blue) rectangle with lighter blue `#5DADE2`
2x2 px eyes at y=6. Represents Renato at a distance — simplified, smaller than player.

**Modulate:** `Color(1, 1, 1, 0.8)` — slightly transparent to reinforce background depth.

**No interaction, no collision.** Static sprite only.

#### 7b. Fase 3 — Restaurante (foreground NPC, dialogue trigger)

**Godot node type:** CharacterBody2D (for consistency with player collision interaction)
or StaticBody2D if no movement needed. Use StaticBody2D for Phase 3 (MVP — Renato
doesn't move in this scene).

**Position:** x=200, y=120 (mid-scene, at a "table" implied by environment tiles).
z_index = 0 (same plane as player).

**Sprite:** 16x32 px placeholder, same as Parque version (`#2980B9` blue).

**Dialogue trigger:** Area2D child with CollisionShape2D (32x16 px, centred at Renato's
feet) — zone extending 16 px in front of Renato. When player enters zone:
- Show input prompt: `[E]` or `[A]` glyph (8x8 px, `#FFDD57` yellow) floating 8 px above
  Renato's head. Tween: alpha pulse 1.0 → 0.5 → 1.0 at 2 Hz.
- On `interact` input press: `Dialogic.start("renato_restaurante")`.
- After dialogue ends: prompt reappears (dialogue is repeatable in Phase 3; skip button
  handles seen state per Phase 2 DialogueBox contract).

**Input glyph prompt:** Label node as child of Renato, position x=4, y=-12 (above sprite
head). Text: keyboard `"[E]"` or gamepad glyph `"[A]"` (same detection as Phase 2
OptionsMenu gamepad glyph logic). Font: 8px m5x7, colour `#FFDD57`.

#### 7c. Boss Scene — Prova Definitiva (~80% trust)

Specified in Section 6b (Victory) above. Renato instantiated dynamically by boss script.
**Sprite:** 32x32 px (2x scale versus in-world NPC; boss scene is closer/larger framing).
Placeholder: `#2980B9` blue square 32x32 with `#5DADE2` eye dots at y=12.

---

### 8. Luis Foreshadowing Sprite — Fase 3 Restaurante (D-23)

**Requirement:** D-23 (foreshadowing — no gameplay interaction)

**Godot node type:** Node2D containing Sprite2D

**Position:** background layer, z_index = -2 (behind foreground and midground tiles).
Placement: x=60, y=115 (left-side background, partially occluded by a foreground tile
or pillar from TileMapLayer). Seated posture implied by y placement (low on screen).

**Sprite:** 16x32 px placeholder. `#8B0000` (dark red — distinct from Malandro vermelho
quente, signals menace) rectangle. No eyes visible — face partially turned away or
occluded. Modulate: `Color(0.5, 0.5, 0.5, 0.7)` (dark, slightly transparent — "hiding
in the shadows" effect).

**No interaction, no collision, no label.** Players who notice it see a mysterious figure.
No tooltip, no name display. Identity revealed only in boss_pai.tscn.

**TileMapLayer interaction:** a foreground tile (pillar or doorframe, z_index=1) must
overlap Luis sprite to create the partial-occlusion effect. Tileset placement is Claude's
discretion for Phase 3.

---

### 9. Opening Narrative Screen — Texto de Abertura (NARR-05)

**Requirement:** NARR-05, D-02

**Approach:** REUSE Phase 2 DialogueBox layout without changes.

`Dialogic.start("mundo1_abertura")` is called from `main_menu.gd` after "NOVO JOGO" or
"CONTINUAR" selects Mundo 1 as the next scene. The Dialogic timeline plays the opening
narrative text over a static background before `SceneTransition.go_to("scenes/world1/fase1_rua.tscn")`.

**Background during opening narrative:**
- Node2D scene `scenes/world1/mundo1_abertura.tscn` with:
  - ColorRect 320x180, colour `#1A1A2E` (dominant — black fade-in effect).
  - No gameplay elements — narrative only.
  - Dialogic CanvasLayer at layer=50 (Phase 2 standard).
  - After Dialogic `timeline_ended` signal: `SceneTransition.go_to("scenes/world1/fase1_rua.tscn")`.

**No speaker portrait** during the opening narrative text (it is a narrator voice, not a
character). Portrait container hidden (`visible = false`) for narrator lines in Dialogic
character settings. This is consistent with Phase 2 DialogueBox contract (portrait slot
is optional).

**Skip button:** visible = `SaveManager.has_seen_cutscene("mundo1_abertura")` — same
logic as Phase 2. First playthrough: no skip. Subsequent: skip available.

**Phase 3 opening narrative copy (Portuguese):**
```
Dialogic timeline: mundo1_abertura
Speaker: [narrator — no portrait]
Line 1: "Osasco. Uma cidade que não pede licença."
Line 2: "É aqui que a história de Natália começa —"
Line 3: "e é aqui que ela precisará provar tudo."
[auto-advance after 2 s or player input]
```

---

## Copywriting Contract (Phase 3 — Portuguese)

| Element | Copy |
|---------|------|
| Opening narrative line 1 | `Osasco. Uma cidade que não pede licença.` |
| Opening narrative line 2 | `É aqui que a história de Natália começa —` |
| Opening narrative line 3 | `e é aqui que ela precisará provar tudo.` |
| Boss HUD label | `CONFIANÇA` |
| Boss HUD percentage format | `{N}%` (integer, e.g. `75%`) |
| Boss game-over label | `CONFIANÇA PERDIDA` |
| Boss scene — insufficient provas | `Preciso de mais provas antes de encarar o pai.` |
| ProvaCard — foto | `Foto` |
| ProvaCard — carta | `Carta` |
| ProvaCard — presente | `Presente` |
| Renato interaction prompt (keyboard) | `[E]` |
| Renato interaction prompt (gamepad) | `[A]` |
| Boss defeat (no vitória) | (no dedicated copy — handled by Dialogic `boss_vitoria` timeline) |
| Checkpoint activation | (no on-screen copy — visual feedback only via cartaz animation) |
| Prova collection | (no on-screen copy — visual feedback via particle burst only) |
| Malandro death | (no copy — visual death animation only) |

**Empty state:** if player enters boss_pai.tscn without enough provas (< 2), they see:
`Preciso de mais provas antes de encarar o pai.` (Dialogic line, Natália speaker,
portrait visible). Then `SceneTransition.go_to()` back to fase3_restaurante checkpoint.

**Destructive state:** boss game over. Text: `CONFIANÇA PERDIDA` (8px, red `#E53935`).
No "are you sure?" confirmation — game over is immediate, reload is automatic.

---

## Godot Node Specification — Boss HUD (most complex new UI element)

### Boss scene tree snippet (`boss_pai.tscn`)

```
BossPai (Node2D — root of boss_pai.tscn)
│
├── TileMapLayer_bg (TileMapLayer, z_index=-1)   ← sala de estar background tiles
├── TileMapLayer_fg (TileMapLayer, z_index=1)    ← foreground tiles (furniture overlap)
│
├── LuisSprite (AnimatedSprite2D, 32x48 px, x=200, y=90)
│   └── LuisCollision (CollisionShape2D — static obstacle, no physics)
│
├── RenatoEntrance (Node2D, x=270, y=100, visible=false)
│   └── RenatoSprite (Sprite2D, 32x32 px, placeholder blue)
│
├── Player (instanced player.tscn, x=60, y=120)  ← player starts left side
│
├── ProvaCardLayer (CanvasLayer, layer=52)        ← above BossHUD, below SceneTransition
│   └── ProvaCard (NinePatchRect, 80x64, visible=false)
│       ├── ProvaSprite (TextureRect, 32x32, anchor=center)
│       └── ProvaNameLabel (Label, 8px, anchor=bottom-center)
│
├── BossHUD (CanvasLayer, layer=51)               ← above Dialogic (50), below SceneTransition (100)
│   └── HUDContainer (Control, anchor=top full-rect)
│       ├── TrustLabel (Label, text="CONFIANÇA", 8px, x=8, y=6, color=#E8E8F0)
│       ├── TrustBarContainer (NinePatchRect, 200x8, x=56, y=4, border=1px #0F3460)
│       │   └── TrustBarFill (ColorRect, width=200*pct, height=8, color=#4CAF50)
│       └── TrustPctLabel (Label, text="0%", 8px, x=260, y=6, color=#E8E8F0)
│
├── GameOverFlash (CanvasLayer, layer=99)         ← red flash on game over
│   └── FlashRect (ColorRect, 320x180, color=#E53935, alpha=0, visible=false)
│
└── DialogicLayer ← Dialogic 2 auto-instantiates at layer=50
```

### Trust bar GDScript update method

```gdscript
# boss_pai.gd
var _trust: float = 0.0

func add_trust(amount: float) -> void:
    _trust = clampf(_trust + amount, 0.0, 100.0)
    _update_hud()
    if _trust >= 100.0:
        _trigger_victory()
    elif _trust <= 0.0:
        _trigger_game_over()

func _update_hud() -> void:
    var fill_width: float = 200.0 * (_trust / 100.0)
    %TrustBarFill.custom_minimum_size.x = fill_width
    %TrustPctLabel.text = str(int(_trust)) + "%"
    if _trust < 20.0:
        %TrustBarFill.color = Color("#E53935")
    elif _trust < 80.0:
        %TrustBarFill.color = Color("#4CAF50")
    else:
        %TrustBarFill.color = Color("#D4A017")
```

---

## Scene File Paths — Phase 3

| Scene | Path |
|-------|------|
| Rua de Osasco | `scenes/world1/fase1_rua.tscn` |
| Parque | `scenes/world1/fase2_parque.tscn` |
| Restaurante | `scenes/world1/fase3_restaurante.tscn` |
| Boss — Casa dos Pais | `scenes/world1/boss_pai.tscn` |
| Opening narrative | `scenes/world1/mundo1_abertura.tscn` |
| Checkpoint (instanced) | `scenes/world1/checkpoint.tscn` |
| Prova item (instanced) | `scenes/world1/prova_item.tscn` |
| Malandro enemy (instanced) | `scenes/world1/malandro.tscn` |
| Static obstacle (instanced) | `scenes/world1/static_obstacle.tscn` |

---

## CanvasLayer Ordering — Complete Stack (Phase 3)

| Layer | Node | Phase introduced |
|-------|------|-----------------|
| 100 | SceneTransition (full-screen fade) | Phase 2 |
| 99 | GameOverFlash (boss only — red/white flash) | Phase 3 |
| 52 | ProvaCardLayer (boss only — proof display overlay) | Phase 3 |
| 51 | BossHUD (boss only — trust bar) | Phase 3 |
| 50 | Dialogic layout (all dialogue scenes) | Phase 2 |
| 0 | World-space nodes (game objects, TileMapLayer, player, enemies, checkpoints, provas, NPCs) | Phase 1–3 |

---

## Audio Contract (Phase 3 — bfxr/sfxr placeholders)

| SFX key | Trigger | Tone direction |
|---------|---------|----------------|
| `checkpoint` | Checkpoint activated | Bright ascending 2-note chime |
| `prova_coletada` | Prova item collected | Bright single chime (higher pitch than checkpoint) |
| `prova_apresentada` | Prova shown in boss ProvaCard | Confident mid-range ding |
| `dialogo_errado` | Wrong dialogue choice | Low buzz/descending tone |
| `stomp` | Malandro killed by player stomp | Short percussion thud |
| `dano` | Player takes contact damage (Malandro or obstacle) | Buzzer (reuse existing from Phase 1 if available) |
| `vitoria` | Trust bar reaches 100% | Ascending fanfare, 3 notes |
| `dialogo_beep` | Each character of typewriter effect | Low soft tick (Dialogic built-in or custom) |

Music tracks (placeholder .ogg silent loops or single-bar loops for Phase 3):

| Track | Scene | Description |
|-------|-------|-------------|
| `mundo1_theme` | fase1_rua, fase2_parque, fase3_restaurante | Upbeat urban — placeholder silent loop |
| `boss_pai_theme` | boss_pai | Tense/emotional — placeholder silent loop |

---

## Interaction Contract Summary (Phase 3 additions)

| Element | Primary input | Result |
|---------|--------------|--------|
| Checkpoint | Player walks into Area2D | Activation animation + save |
| Prova collectible | Player walks into Area2D | Collect + particle burst + save |
| Malandro stomp | Player falls on top (velocity.y > 0) | Enemy death animation + bounce |
| Malandro contact | Player touches side | Player knockback + white flash |
| Static obstacle contact | Player touches Area2D | Player knockback + white flash |
| Renato (Restaurante) | Walk into dialogue zone + press [E]/[A] | Dialogic starts |
| Luis (foreshadowing) | No input — visual only | No interaction |
| Boss — dialogue choice | D-pad/arrows + Enter/A in Dialogic | Trust +10 or -15 |
| Boss — prova presented | Automatic (scripted at dialogue marker) | Trust +20 per prova |
| Boss game over | Trust reaches 0 | Red flash + scene reload |
| Boss victory | Trust reaches 100 | Gold particles + victory timeline |

---

## Registry Safety

| Registry | Blocks Used | Safety Gate |
|----------|-------------|-------------|
| Godot AssetLib | Dialogic 2 (inherited from Phase 2) | Verified in Phase 2 — no re-vetting needed |
| None (Phase 3 adds no new plugins) | — | Not applicable |

No shadcn registry. No third-party Godot plugins added in Phase 3.

---

## Checker Sign-Off

- [ ] Dimension 1 Copywriting: PASS
- [ ] Dimension 2 Visuals: PASS
- [ ] Dimension 3 Color: PASS
- [ ] Dimension 4 Typography: PASS
- [ ] Dimension 5 Spacing: PASS
- [ ] Dimension 6 Registry Safety: PASS

**Approval:** pending

---

## Source Traceability

| Decision | Source |
|----------|--------|
| 4 scenes: fase1_rua, fase2_parque, fase3_restaurante, boss_pai | CONTEXT.md D-01 |
| Opening narrative before fase1 | CONTEXT.md D-02 |
| Osasco palette: cinza urbano + warm accents (laranja/vermelho) | CONTEXT.md D-03 |
| Mario-style stomp kill on Malandro | CONTEXT.md D-04 |
| Lateral contact = knockback (existing system) | CONTEXT.md D-05 |
| Two enemy types: Malandro (patrol) + Static Obstacle (Area2D) | CONTEXT.md D-06 |
| Enemy reset on respawn | CONTEXT.md D-07 |
| Checkpoint visual: McFly cartaz, pulse on activate | CONTEXT.md D-08 |
| 1 checkpoint per fase; 4 total | CONTEXT.md D-09 |
| Respawn < 500ms; provas persist across death | CONTEXT.md D-10 |
| Checkpoint ID format: mundo1_faseN_cp1 | CONTEXT.md D-11 |
| Provas: brilhante/piscando, 3 types (foto, carta, presente) | CONTEXT.md D-12 |
| Minimum 2 provas to enter boss; 1 optional | CONTEXT.md D-13 |
| Prova inventory hidden during platforming phases | CONTEXT.md D-14 |
| Provas saved in SaveManager.current_save["provas_mundo1"] | CONTEXT.md D-15 |
| Boss: Luis, sprite + Dialogic overlay | CONTEXT.md D-16 |
| Boss mechanic: provas + dialogue choices → trust bar | CONTEXT.md D-17 |
| Boss is purely narrative — no physical damage to player | CONTEXT.md D-18 |
| Trust bar HUD visible during dialogue, top of screen, CanvasLayer above Dialogic | CONTEXT.md D-19 |
| Trust bar empties = game over boss → last checkpoint | CONTEXT.md D-20 |
| 100% bar = victory cutscene; Renato at ~80% as prova definitiva | CONTEXT.md D-21 |
| Boss cenário: sala de estar casa dos pais (Osasco) | CONTEXT.md D-22 |
| Luis foreshadowing in fase3_restaurante background | CONTEXT.md D-23 |
| Renato in fase2 (bg), fase3 (dialogue), boss finale | CONTEXT.md D-24 |
| Renato portrait from Phase 2 assets/sprites/portraits/renato_portrait.png | CONTEXT.md D-25 |
| SFX placeholder bfxr/sfxr Phase 3; real SFX Phase 12 | CONTEXT.md D-26 |
| SFX list for Mundo 1 | CONTEXT.md D-27 |
| CPUParticles2D only (never GPU) | STATE.md accumulated context; CONTEXT.md code_context |
| CanvasLayer ordering: SceneTransition=100, Dialogic=50 | Phase 2 UI-SPEC + CONTEXT.md code_context |
| BossHUD at CanvasLayer=51 (above Dialogic at 50, below SceneTransition at 100) | Phase 3 UI-SPEC reasoning from D-19 |
| Sprite sizes: player 32x32, small enemies 16x16/16x32, boss 32x48 | CLAUDE.md tech stack (sprite sizes table) |
| TileMapLayer for level design (not TileMap) | CLAUDE.md tech stack |
| Placeholder art acceptable; real pixel art in Phase 12 | CONTEXT.md deferred section |
| Prova card at CanvasLayer=52 (above BossHUD at 51) | Phase 3 UI-SPEC reasoning — card must overlay trust bar |
| Opening narrative: reuse Phase 2 DialogueBox layout | Phase 2 UI-SPEC DialogueBox contract |
| Trust bar colour steps: red <20%, green 20–79%, gold 80–100% | Discretion — communicates urgency and milestone |
| Renato NPC 16x32 (in-world), 32x32 (boss scene) | CLAUDE.md sprite sizes + scene framing intent |
| Luis foreshadowing modulate 0.5 alpha + dark colour | Discretion — "hiding in shadows" visual metaphor (D-23 specifics) |
| Prova auto-present on boss scene entry (not manual) | Discretion — CONTEXT.md Claude's Discretion section |
