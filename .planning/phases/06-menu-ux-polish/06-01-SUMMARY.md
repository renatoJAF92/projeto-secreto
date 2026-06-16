---
plan: 06-01
status: complete
completed: 2026-06-15
---

# Summary — Plan 06-01: Audio Infrastructure

## What was done
- Created `assets/audio/default_bus_layout.tres` with 3 buses: Master (idx 0), Music (idx 1), SFX (idx 2)
- Added `[audio] buses/default_bus_layout` reference to `project.godot`
- Updated `audio_manager.gd`: music player now on "Music" bus, SFX players on "SFX" bus; added `set_music_volume()`, `set_sfx_volume()`, `get_music_volume()`, `get_sfx_volume()` methods; `_apply_saved_volumes()` called in `_ready()`
- Added `music_volume: 0.8` and `sfx_volume: 1.0` fields to `SaveManager._default_save()`
- Added `SaveManager.save()` alias for `save_game()` (used by options_menu.gd)
- Added `pause` input action (KEY_ESCAPE, physical_keycode=4194305) to `project.godot [input]`

## Key decisions
- Bus indices hardcoded as constants (_MUSIC_BUS=1, _SFX_BUS=2) — bus layout file is authoritative
- `linear_to_db(0.0)` guard: uses -80dB instead of -inf to avoid GDScript crash
- Volume defaults applied via `.get()` so old saves without volume keys work correctly
