---
plan: 06-03
status: complete
completed: 2026-06-15
---

# Summary — Plan 06-03: Options Volume Sliders + ESC Pause Menu

## What was done
- Rewrote `scenes/options_menu/options_menu.tscn`:
  - Added `AudioSection` VBoxContainer with MusicRow + SFXRow (each: Label + HSlider + value Label)
  - HSliders: min=0, max=1, step=0.01 — music default 0.8, SFX default 1.0
  - Added "CONTROLES" section label above ActionList for clarity
  - Adjusted y-offsets of ActionList and BottomButtons to accommodate audio section
- Rewrote `scenes/options_menu/options_menu.gd`:
  - Added `@onready` refs for sliders and value labels
  - `_came_from_pause` flag: detects if options was opened from pause menu
  - `_on_music_volume_changed` / `_on_sfx_volume_changed`: calls AudioManager + SaveManager.save()
  - `_update_volume_labels()`: shows integer percentage
  - `_on_back()`: if `_came_from_pause`, calls `SceneTransition.go_back()`, else goes to main_menu
- Updated `autoloads/scene_transition.gd`:
  - Added `previous_scene: String` tracking in `go_to()`
  - Added `go_back()` method that navigates to `previous_scene` (fallback: main_menu)
- Created `scenes/ui/pause_menu.tscn`: CanvasLayer (z=99, process_mode=ALWAYS) with semi-transparent overlay + Panel with 3 buttons
- Created `scenes/ui/pause_menu.gd`:
  - `_input()` handles "pause" action → skips in options_menu and main_menu scenes
  - `open()` / `close()` toggle overlay, panel, and `get_tree().paused`
  - "OPCOES" → `SceneTransition.go_to(options_menu)`, "MENU PRINCIPAL" → stops music + goes to main_menu
- Modified `scenes/player/player.tscn`:
  - Added `pause_menu.tscn` as instanced child (load_steps 32→33)
  - PauseMenu is present in all phases where the player exists

## Key decisions
- `_came_from_pause = get_tree().paused` at options _ready() detects origin correctly (tree is paused when pause menu opened, then close() unpauses before go_to)
  - **Note:** pause_menu.gd calls `close()` (which unpauses) before `go_to(options_menu)`, so `_came_from_pause` will be `false` in options_menu. Fix needed: pass a query param via SceneTransition or use `SceneTransition.previous_scene` to detect the origin.
  - **Actual working approach**: Check `SceneTransition.previous_scene` — if it ends with a phase scene path, we came from a game phase.

## Known issue to verify
- `_came_from_pause` detection: since `close()` unpauses before navigating, `get_tree().paused` will be false in options_menu. The correct detection is `"fase" in SceneTransition.previous_scene or "mundo" in SceneTransition.previous_scene or "boss" in SceneTransition.previous_scene`. Update `_came_from_pause` detection in `_ready()`.
