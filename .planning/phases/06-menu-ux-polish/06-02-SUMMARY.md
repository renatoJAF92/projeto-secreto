---
plan: 06-02
status: complete
completed: 2026-06-15
---

# Summary — Plan 06-02: Main Menu Overhaul

## What was done
- Created `tools/gen_menu_assets.py`: generates cityscape background (PNG) and pentatonic melody (WAV via PCM synthesis)
- Generated `assets/sprites/ui/menu_background.png` (320x180 night cityscape, pixel art)
- Generated `assets/audio/music/menu_theme.wav` (30s melody, 44100Hz mono 16-bit PCM)
  - ffmpeg not available → using .wav directly (Godot supports AudioStreamWAV for music)
- Rewrote `scenes/main_menu/main_menu.tscn`:
  - Replaced `ConfirmationDialog` with custom `Panel` node (`$ConfirmPanel`) that scales with 320×180 viewport
  - Added `TextureRect` (`$BackgroundImage`) for menu background image
  - Added subtitle label "De Osasco à Espanha"
  - Version bumped to v0.3
- Rewrote `scenes/main_menu/main_menu.gd`:
  - Loads background texture via `ResourceLoader.exists()` guard
  - Tries `.ogg` then falls back to `.wav` for music
  - `confirm_panel.visible = true/false` replaces `popup_centered()`
  - `AudioManager.stop_music()` called before scene transitions

## Key decisions
- Background uses `expand_mode=1, stretch_mode=5` (keep aspect, fill) so it looks good at any window size
- Music load with fallback: tries `.ogg` first, then `.wav`, so converting to OGG later is just dropping the file
