---
phase: 2
slug: infraestrutura
status: draft
shadcn_initialized: false
preset: none
created: 2026-06-04
game_engine: Godot 4.4.1 (GDScript)
viewport: 320x180 (canvas_items stretch, integer scale)
---

# Phase 2 — Infraestrutura: UI Design Contract

> Visual and interaction contract for the three UI screens delivered in Phase 2:
> MainMenu, OptionsMenu (control remapping), and DialogueBox (Dialogic 2 layout).
> This is a Godot 4 pixel art game — not a web application.
> All measurements are in game pixels at the 320x180 base resolution.

---

## Design System

| Property | Value |
|----------|-------|
| Tool | Godot 4 Control nodes (no CSS, no web framework) |
| Preset | not applicable |
| Component library | Godot built-in: Control, Button, Label, VBoxContainer, HBoxContainer, Panel, NinePatchRect |
| Icon library | pixel art glyphs, hand-drawn at 8x8 or 16x16 (no icon font) |
| Font | pixel bitmap font — m5x7 or similar (8px height at 1x scale); fallback: Godot default theme font until pixel font is sourced |
| Renderer | GL Compatibility (confirmed in project.godot — gl_compatibility enforced since Phase 0) |

**Design language:** retro JRPG / 16-bit platformer. Dark background, light text, coloured accents for interactive states. NinePatchRect panels for all bordered UI containers. No rounded corners — squared edges only to preserve pixel art fidelity. Texture filter: Nearest (confirmed in project.godot: `default_texture_filter=0`).

---

## Pixel Grid & Spacing Scale

All spacing values are in game pixels (320x180 base resolution). Use multiples of 4.

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4 px | Between label and icon; inline gap inside a button |
| sm | 8 px | Padding inside Panel / NinePatchRect borders; gap between list items |
| md | 16 px | Default margin between UI elements; gap between title and button group |
| lg | 24 px | Section separation inside Options screen |
| xl | 32 px | Vertical centering margin at screen edges |
| 2xl | 48 px | Reserved for portrait container width offset |
| 3xl | 64 px | Portrait width (dialogue portrait = 64 px wide) |

Exceptions:
- Dialogue box height: 56 px (fixed, allows 3 lines of text + portrait); not a multiple of 4 but derived from portrait height 80 px cropped to box.
- Touch target minimum: 24 px tall for any Button (accessibility floor at 320x180 resolution — equates to ~134 px at 1920x1080 after 5.3x integer upscale).

---

## Typography

All sizes in game pixels (at 320x180 base resolution, pixel bitmap font).

| Role | Size | Weight | Line Height | Usage |
|------|------|--------|-------------|-------|
| Dialogue body | 8 px | regular | 1.5 (12 px) | Dialogue box text, options list labels |
| UI label | 8 px | regular | 1.25 (10 px) | Button labels, action names in remap list |
| Screen title | 16 px | bold (or double-size glyph) | 1.2 (19 px) | "CONTINUAR" / "NOVO JOGO" on MainMenu; "OPCOES" header |
| Character name | 8 px | bold | 1.0 (8 px) | Speaker name above dialogue text |

Font rules:
- Use the same pixel bitmap font for all roles — size differentiation only by px size, not by weight variation in the traditional sense. Bold = thicker glyph variant if the font provides one; otherwise draw the title glyph at 2x.
- No anti-aliasing, no subpixel rendering. Texture filter = Nearest enforced project-wide.
- If m5x7 (free, itch.io) is not available at implementation time, use Godot's built-in theme font as a strictly temporary placeholder — the pixel font must be wired before human-verify.

---

## Color Palette

16-color UI palette. Drawn from the game's dark urban world aesthetic (Osasco palette serves as reference for Phase 2; world-specific palettes for Phases 3-10).

| Role | Hex | Usage |
|------|-----|-------|
| Dominant (60%) — dark background | `#1A1A2E` | Screen background, panel backgrounds, dialogue box fill |
| Secondary (30%) — mid surface | `#16213E` | Button unfocused state background, NinePatchRect panel fill |
| Accent (10%) — electric blue | `#0F3460` | Button focused/hover border, active remap slot highlight, Dialogic portrait border |
| Text primary | `#E8E8F0` | All label text, dialogue text |
| Text secondary | `#8888AA` | Disabled state text (e.g. "CONTINUAR" when no save exists), hint copy |
| Action green | `#4CAF50` | "NOVO JOGO" button — primary positive action only |
| Destructive red | `#E53935` | "New Game" confirmation flash / overwrite warning only; no other use |
| Gamepad prompt | `#FFDD57` | Generic button-prompt glyph colour (keyboard: white; gamepad: yellow) |
| Portrait border | `#0F3460` | NinePatchRect border around dialogue portrait (same as accent) |
| Disabled wash | `#888888` | "CONTINUAR" button when `save_exists() == false` — entire button including border |

Accent (`#0F3460`) reserved for: focused button border, active remap slot outline, dialogue portrait NinePatchRect border, and cursor/selection indicator in the remap list. Not used on non-interactive elements.

Destructive (`#E53935`) reserved for: the brief 1-frame flash on the "Novo Jogo" button when a save exists (warning before overwrite). No other use in Phase 2.

---

## Screen Contracts

### Screen 1: MainMenu (`scenes/main_menu/main_menu.tscn`)

**Purpose:** Entry point. Continue or start fresh. Satisfies SAVE-03.

**Layout (320x180):**
```
┌──────────────────────────────────────────┐
│                                          │
│   [GAME TITLE — 16px, centred, top 40px] │
│                                          │
│        [ CONTINUAR   ]   ← 128x20 px    │
│        [ NOVO JOGO   ]   ← 128x20 px    │
│        [ OPCOES      ]   ← 128x20 px    │
│                                          │
│              [version string, 8px, dim]  │
└──────────────────────────────────────────┘
```

**Button group:** VBoxContainer, centred horizontally. 8 px gap between buttons. Each button: 128 px wide, 20 px tall, NinePatchRect border 1 px.

**States:**
- "CONTINUAR" — `disabled = not SaveManager.save_exists()`. When disabled: text colour `#888888`, border colour `#888888`, not focusable.
- "NOVO JOGO" — always enabled. When a save exists and player presses it: button flashes `#E53935` border for 1 frame (visual warning), then immediately starts new game (no modal confirmation — D-01 specifies single slot, overwrite is intentional).
- "OPCOES" — always enabled. Opens OptionsMenu via `SceneTransition.go_to()`.

**Focus navigation:** Up/Down arrows and D-pad navigate between enabled buttons. First enabled button is focused on scene enter. If save exists, "CONTINUAR" is focused first; otherwise "NOVO JOGO".

**Scene transition:** All transitions use `SceneTransition.go_to()` with 300ms fade to black and 300ms fade in.

---

### Screen 2: OptionsMenu (`scenes/options_menu/options_menu.tscn`)

**Purpose:** Control remapping for all gameplay actions. Satisfies ACCESS-02 and ACCESS-03.

**Layout (320x180):**
```
┌──────────────────────────────────────────┐
│  [OPCOES — 16px title, left-aligned]     │
│  ────────────────────────────────────    │
│  walk_left    [  ← / A   ]  [remap btn] │
│  walk_right   [  → / D   ]  [remap btn] │
│  jump         [ Space/W  ]  [remap btn] │
│  dash         [ Shift/K  ]  [remap btn] │
│  ────────────────────────────────────    │
│  [ RESETAR CONTROLES ]   [ VOLTAR ]      │
└──────────────────────────────────────────┘
```

**Action list:** VBoxContainer. Each row = HBoxContainer with:
- Action label (Label, 8px, 96 px wide, left-aligned)
- Current binding display (Label, 8px, 96 px wide, centred, shows key name or gamepad button glyph)
- "REMAP" button (Button, 8px, 48 px wide, 16 px tall)

**Remap flow:**
1. Player presses "REMAP" on an action row.
2. That row's binding label changes to "Pressione..." (italic or dim `#8888AA`).
3. `_waiting_for_input` is set; the next `InputEventKey` or `InputEventJoypadButton` captured via `_input()` replaces the binding.
4. Conflict detection: if the new key already maps another action, that other action's binding is silently cleared (no error modal — silent resolution per ControlsManager.remap_action() pattern from RESEARCH.md).
5. On successful remap: binding label updates, `ControlsManager.save_controls()` fires immediately.
6. Escape key or gamepad B during "Pressione..." cancels the remap without change.

**Gamepad display:** When last input was from a gamepad, binding labels show a yellow (`#FFDD57`) generic glyph (circle for confirm, X for cancel, arrows for DPAD) — not brand-specific (D-17 defers branded prompts to Phase 12).

**RESETAR CONTROLES:** Restores all bindings to project.godot defaults (erases `user://controls.cfg`). No confirmation required — controls file is separate from save (D-16).

**VOLTAR:** Returns to MainMenu via `SceneTransition.go_to()`.

**Focus:** Vertical navigation through the 4 action rows then to the bottom buttons. No horizontal navigation within rows (REMAP button reached by pressing Enter/A on its row).

---

### Screen 3: DialogueBox (Dialogic 2 layout)

**Purpose:** Display character dialogue with portrait, advance on input, skip seen cutscenes. Satisfies NARR-01 and NARR-02.

**Layout within CanvasLayer (anchored bottom of screen):**
```
320 px wide ─────────────────────────────────
[ portrait  │ [SPEAKER NAME — 8px bold]       ]
[ 64x80 px  │ Dialogue text line 1            ]
[ NinePatch │ Dialogue text line 2            ]
[  border   │ Dialogue text line 3            ]
[           │              [►] [PULAR] prompt ]
─────────────────────────────────────────────
56 px tall (text area); portrait overflows upward to 80 px
```

**Portrait container:**
- 64 px wide, 80 px tall (busto JRPG — head + shoulders, from D-12).
- NinePatchRect border 1 px, colour `#0F3460` (accent).
- Anchored bottom-left of dialogue box. Overflows 24 px above the box top edge.
- Phase 2 delivers placeholder portraits (coloured silhouette per D-11): Natália = `#9B59B6` (purple fill), Renato = `#2980B9` (blue fill). Real portraits generated via Python/Pillow from `Photos/` in same phase (D-09).

**Text area:**
- Begins 72 px from left edge (portrait 64 px + 8 px gap).
- Width: 320 - 72 - 8 = 240 px.
- Max 3 lines at 8px font, line-height 12 px.
- Typewriter effect: 1 character per frame at 60 FPS (≈ 16ms/char). Speed is configurable in Dialogic character settings.
- Speaker name: bold 8px label, 1 line, above text block with 4 px gap.

**Advance prompt:**
- `[►]` glyph (8x8 px) at bottom-right of text area, visible only when typewriter is complete.
- Animates: fade in/out at 1 Hz (Tween alpha 1.0 → 0.3 → 1.0).
- Accepts: Space, Enter, gamepad A/South.

**"PULAR" button:**
- 8px label, right-aligned, 4 px above bottom edge of dialogue box.
- `visible = SaveManager.has_seen_cutscene(timeline_name)` — hidden for first-time cutscenes, visible for replays (D-13 confirmed via RESEARCH.md open question resolution).
- When pressed: `Dialogic.Inputs.auto_skip.enabled = true`, `time_per_event = 0.05`.

**Dialogue box panel:**
- Full 320 px wide, 56 px tall (text area), anchored to bottom of screen.
- Background: `#1A1A2E` fill (dominant).
- Top border: 1 px solid line `#0F3460` (accent).
- No side or bottom borders — box bleeds to screen edges.

---

## Interaction Contract Summary

| Screen | Primary Input | Secondary Input | Gamepad |
|--------|--------------|-----------------|---------|
| MainMenu | Enter / A to confirm | Up/Down to navigate | D-pad + A |
| OptionsMenu | Enter / A to select REMAP; any key to capture | Escape / B to cancel remap | D-pad + A + B |
| DialogueBox | Space / Enter / A to advance | — | A (advance), skip button via mouse or mapped action |

---

## Copywriting Contract

| Element | Copy (Portuguese) |
|---------|------------------|
| MainMenu — Continue CTA | `CONTINUAR` |
| MainMenu — New Game CTA | `NOVO JOGO` |
| MainMenu — Options CTA | `OPCOES` |
| MainMenu — no-save state | `CONTINUAR` (button label unchanged; just disabled + dimmed — no explanatory text in Phase 2) |
| OptionsMenu — title | `OPCOES` |
| OptionsMenu — reset button | `RESETAR CONTROLES` |
| OptionsMenu — back button | `VOLTAR` |
| OptionsMenu — waiting for key | `Pressione uma tecla...` |
| OptionsMenu — no conflict copy | silent (no error message for key conflict — other action's binding is silently cleared) |
| DialogueBox — skip button | `PULAR` |
| DialogueBox — advance prompt | `►` (glyph only, no text) |
| Test dialogue line 1 (Natália) | `Eu sei onde quero chegar.` |
| Test dialogue line 2 (Natália) | `E vou chegar lá do meu jeito.` |
| Test dialogue response (Renato) | `Eu sei que vai. Eu estou aqui.` |

Empty state: no traditional "empty state" concept — game always has a starting state. "No save" is communicated by the disabled CONTINUAR button (no separate empty-state screen).

Destructive action: "NOVO JOGO" when save exists. Confirmation approach: single-frame red border flash on the button; no modal dialog. The action fires immediately. This is intentional (single-save, personal gift game — losing progress is recoverable by playing again).

---

## Godot Node Specification

### MainMenu scene tree
```
MainMenu (Control, full-rect anchor)
├── Background (ColorRect, 320x180, color #1A1A2E)
├── TitleLabel (Label, text="Destiny — Tales of Natália", 16px, centered, y=40)
├── ButtonGroup (VBoxContainer, centered H, y=80, separation=8)
│   ├── ContinueButton (Button, 128x20, text="CONTINUAR")
│   ├── NewGameButton  (Button, 128x20, text="NOVO JOGO")
│   └── OptionsButton  (Button, 128x20, text="OPCOES")
└── VersionLabel (Label, text="v0.2", 8px, color=#8888AA, bottom-right, y=172)
```

### OptionsMenu scene tree
```
OptionsMenu (Control, full-rect anchor)
├── Background (ColorRect, 320x180, color #1A1A2E)
├── TitleLabel (Label, text="OPCOES", 16px, left-aligned, x=8, y=8)
├── Divider (ColorRect, 304x1, color=#0F3460, y=28)
├── ActionList (VBoxContainer, x=8, y=36, separation=4)
│   ├── ActionRow_WalkLeft  (HBoxContainer) → [Label "Andar Esq."][Label binding][Button "REMAP"]
│   ├── ActionRow_WalkRight (HBoxContainer) → [Label "Andar Dir."][Label binding][Button "REMAP"]
│   ├── ActionRow_Jump      (HBoxContainer) → [Label "Pular"     ][Label binding][Button "REMAP"]
│   └── ActionRow_Dash      (HBoxContainer) → [Label "Dash"      ][Label binding][Button "REMAP"]
├── Divider2 (ColorRect, 304x1, color=#0F3460, y=136)
└── BottomButtons (HBoxContainer, x=8, y=144, separation=8)
    ├── ResetButton  (Button, 144x16, text="RESETAR CONTROLES")
    └── BackButton   (Button, 64x16, text="VOLTAR")
```

### DialogueBox Dialogic layout
```
DialogicLayout (CanvasLayer, layer=50)  ← below SceneTransition (layer=100)
└── DialogBox (Panel/NinePatchRect, 320x56, anchor=bottom)
    ├── PortraitContainer (NinePatchRect, 64x80, anchor=bottom-left, y_offset=-24)
    │   └── PortraitSprite (TextureRect, 62x78, texture=character portrait PNG)
    ├── SpeakerLabel (Label, 8px bold, x=72, y=4)
    ├── TextLabel (RichTextLabel, 8px, x=72, w=240, y=16, max_lines=3, bbcode=true)
    ├── AdvancePrompt (Label, text="►", 8px, x=304, y=44, animated alpha)
    └── SkipButton (Button, text="PULAR", 8px, x=256, y=44, visible=false by default)
```

---

## Registry Safety

| Registry | Blocks Used | Safety Gate |
|----------|-------------|-------------|
| Godot AssetLib | Dialogic 2 Alpha 19 | Not a third-party shadcn registry. Dialogic is an open-source Godot plugin. Source verified at https://github.com/dialogic-godot/dialogic — no vetting gate required under shadcn registry rules. |
| Python PyPI (Pillow) | Pillow 12.2.0 | Offline build tool only, never ships in game binary. VERIFIED installed (pip3 list confirms 12.2.0). |

No shadcn registry used — game project. Registry safety gate not applicable.

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
| Single save slot, Continue disabled without save | CONTEXT.md D-01 |
| Save data schema (checkpoint_id, worlds, powers, seen_cutscenes) | CONTEXT.md D-02 |
| Portrait size 64x80 px, busto JRPG style | CONTEXT.md D-12 |
| Skip button visible=true only for seen cutscenes | CONTEXT.md D-13, RESEARCH.md Open Question 3 resolved |
| Generic gamepad prompts (not brand-specific) | CONTEXT.md D-17 |
| Remap screen inside Options menu; WASD/Setas + Space + Shift defaults | CONTEXT.md D-18 |
| All 4 actions exposed: walk_left, walk_right, jump, dash | CONTEXT.md D-15 |
| Controls persisted to user://controls.cfg separately | CONTEXT.md D-16 |
| Viewport 320x180, stretch=canvas_items, scale=integer, filter=Nearest | project.godot confirmed |
| GL Compatibility renderer | project.godot confirmed (CONTEXT.md Phase 0) |
| CPUParticles2D pattern (never GPU) | STATE.md accumulated context |
| SceneTransition CanvasLayer must be layer > 100 | RESEARCH.md Pattern 2 |
| Dialogic CanvasLayer layer=50 (below SceneTransition) | RESEARCH.md architectural decision |
| Test dialogue copy | CONTEXT.md D-14 (2 Natália lines + Renato response) |
| Colour palette dark urban aesthetic | Discretion — consistent with Osasco world palette direction noted in STATE.md todos |
| Font choice m5x7 | Discretion — canonical pixel art font for 8px legibility at 320x180 |
| New Game overwrites silently (red flash only) | Discretion — single-slot game, no modal needed; D-01 |
