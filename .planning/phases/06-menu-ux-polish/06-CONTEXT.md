---
phase: 6
name: Menu & UX Polish
slug: menu-ux-polish
status: planning
depends_on: [5]
requirements: [ACCESS-03, AUDIO-01, AUDIO-03]
---

# Phase 6: Menu & UX Polish — Context

## Phase Goal

Corrigir bugs de escala do menu principal, adicionar background animado e música, melhorar o menu de opções com sliders de volume, e adicionar um menu de pause em-jogo acessível com ESC.

## Deliverables

1. **Custom popup** substituindo `ConfirmationDialog` no main_menu — escala com viewport 320×180
2. **Menu background** — imagem ou animação de fundo no main_menu
3. **Música do menu** — OGG gerada via Python, tocando em loop no main_menu
4. **Audio buses** — dois buses ("Music" e "SFX") separados do Master, em `res://assets/audio/default_bus_layout.tres`
5. **Volume sliders** no options_menu — HSliders para Music e SFX separados, persistidos em save
6. **AudioManager** com métodos `set_music_volume(linear)` e `set_sfx_volume(linear)` usando AudioServer
7. **In-game ESC pause menu** — `scenes/ui/pause_menu.tscn` + `.gd`, CanvasLayer z=99, process_mode=ALWAYS, botões: Retomar / Opções / Menu Principal

## Codebase State

### main_menu.tscn / main_menu.gd
- `ConfirmationDialog` node `$ConfirmNewGame` — OS-level, ignora viewport scaling → botões não aparecem
- Fix: remover ConfirmationDialog, adicionar `Panel` customizado inline na cena com dois botões (APAGAR / CANCELAR)
- Background atual: `ColorRect` sólida cor `#1A1A2E`
- Botões em `VBoxContainer` com layout_mode=0 (offset fixo) dentro de 320×180

### options_menu.tscn / options_menu.gd
- Tem `ActionList` VBoxContainer com 4 ações (walk_left, walk_right, jump, dash)
- `ActionList` ocupa y=36 a y=132 (96px) com separação de 4px
- `BottomButtons` HBoxContainer em y=144-160 com RESETAR e VOLTAR
- **Sem nenhum controle de volume**
- Precisa de seção de áudio acima ou abaixo das ações, com HSliders

### audio_manager.gd
- `_music_player: AudioStreamPlayer` no bus "Master"
- SFX players também no bus "Master"
- **Sem métodos de volume, sem separação Music/SFX**
- Precisa de: AudioBus "Music" para `_music_player` e bus "SFX" para SFX players
- `set_music_volume(v: float)` → `AudioServer.set_bus_volume_db(1, linear_to_db(v))`
- `set_sfx_volume(v: float)` → `AudioServer.set_bus_volume_db(2, linear_to_db(v))`
- Volume 0.0 = silêncio, 1.0 = 100%

### save_manager.gd
- `current_save` Dictionary com campos conhecidos: checkpoint_id, provas_mundo1, bicycle_active, etc.
- Volume deve ser persistido como `current_save["music_volume"]` (float 0.0-1.0, default 0.8)
- e `current_save["sfx_volume"]` (float 0.0-1.0, default 1.0)
- SaveManager já tem `save()` que persiste o dicionário

### project.godot / audio
- Buses configurados em `AudioServer` via `.tres` resource
- Path padrão: `res://assets/audio/default_bus_layout.tres`
- Formato: `[gd_resource type="AudioBusLayout"]` com 3 buses: Master (idx 0), Music (idx 1), SFX (idx 2)

### Viewport
- 320×180 base resolution, `stretch/mode="canvas_items"`, `scale_mode="integer"`
- Todos os nodes UI devem usar posições dentro de 0-320 x 0-180
- CanvasLayer com z=99 funciona corretamente para pause overlay

## Constraints

- `gl_compatibility` renderer — sem GPUParticles2D, sem shaders complexos
- SFX existentes precisam migrar para bus "SFX" sem quebrar o código atual
- Pause menu deve funcionar em QUALQUER cena de jogo (fases 1-3 dos mundos 1 e 2)
- O ESC não pode conflitar com o sistema de remap de teclas do ControlsManager
- AudioManager é autoload — mudanças nele afetam todo o projeto
- Música do menu: OGG gerado via Python (síntese PCM), ~30s em loop, tema melódico simples

## Technical Approach

### Audio Buses
1. Criar `assets/audio/default_bus_layout.tres` com buses Master / Music / SFX
2. Referenciar em `project.godot` como `audio/buses/default_bus_layout`
3. Em `audio_manager.gd`: mudar `_music_player.bus = "Music"`, SFX players para `bus = "SFX"`
4. Adicionar métodos `set_music_volume` e `set_sfx_volume` usando `AudioServer.set_bus_volume_db()`
5. Aplicar volumes salvos em `_ready()` do AudioManager

### Custom Popup (substituir ConfirmationDialog)
1. Remover `[node name="ConfirmNewGame" type="ConfirmationDialog"]` do main_menu.tscn
2. Adicionar `Panel` node (320×180 coords) com 2 labels e 2 buttons, `visible = false` inicialmente
3. Em `main_menu.gd`: em vez de `confirm_new_game.popup_centered()`, fazer `$ConfirmPanel.visible = true`

### Menu Background
- Adicionar `TextureRect` ou `AnimatedSprite2D` como fundo da cidade/Osasco
- Gerar `menu_background.png` via Python (cityscape simples, pixel art 320×180)
- Colocar em `assets/sprites/ui/menu_background.png`

### Menu Music
- Gerar `menu_theme.ogg` via Python (síntese simples, ~30s, tom melódico)
- Colocar em `assets/audio/music/menu_theme.ogg`
- Em `main_menu.gd._ready()`: `AudioManager.play_music(load("res://assets/audio/music/menu_theme.ogg"))`

### Volume Sliders em Options Menu
- Adicionar seção "AUDIO" antes de `ActionList` com 2 `HBoxContainer` (Label + HSlider)
- Music: min=0, max=1, step=0.01, value=saved music_volume
- SFX: min=0, max=1, step=0.01, value=saved sfx_volume
- On value_changed: `AudioManager.set_music_volume(v)`, `SaveManager.current_save["music_volume"] = v`, `SaveManager.save()`

### In-Game ESC Pause Menu
- `scenes/ui/pause_menu.tscn`: CanvasLayer (z=99, process_mode=Node.PROCESS_MODE_ALWAYS)
- `pause_menu.gd`: `_input(event)` intercepta ESC → toggle pause
- `get_tree().paused = true` quando aberto, `false` quando fechado
- 3 botões: RETOMAR / OPCOES / MENU PRINCIPAL
- OPCOES: abre options_menu inline OU navega para a cena options_menu
- Precisa ser adicionado como autoload OU instanciado via player.tscn / cada fase
- Melhor abordagem: adicionar como filho do player.tscn (sempre presente nas fases)

## Files to Create/Modify

| File | Action |
|------|--------|
| `assets/audio/default_bus_layout.tres` | CREATE — 3 buses |
| `assets/audio/music/menu_theme.ogg` | CREATE — Python-generated |
| `assets/sprites/ui/menu_background.png` | CREATE — Python-generated |
| `autoloads/audio_manager.gd` | MODIFY — bus names + volume methods |
| `project.godot` | MODIFY — bus layout path |
| `scenes/main_menu/main_menu.tscn` | MODIFY — remove ConfirmationDialog + add ConfirmPanel + TextureRect background |
| `scenes/main_menu/main_menu.gd` | MODIFY — popup logic + load music |
| `scenes/options_menu/options_menu.tscn` | MODIFY — add volume section |
| `scenes/options_menu/options_menu.gd` | MODIFY — slider wiring + save/load volume |
| `scenes/ui/pause_menu.tscn` | CREATE — pause overlay |
| `scenes/ui/pause_menu.gd` | CREATE — pause logic + ESC toggle |
| `scenes/player/player.tscn` | MODIFY — add PauseMenu as child |

## Success Criteria

1. Main menu abre e botões "NOVO JOGO" e "CONTINUAR" funcionam; popup de confirmação escala corretamente com a janela.
2. Menu tem imagem de fundo e música tocando (não o ColorRect sólido).
3. Options menu mostra sliders de Music e SFX; mover os sliders altera o volume em tempo real.
4. Volumes são salvos entre sessões (fechar e reabrir o jogo → sliders na última posição).
5. Em qualquer fase do jogo, pressionar ESC abre o pause menu e para o jogo; "RETOMAR" fecha e retoma.
6. "MENU PRINCIPAL" no pause menu navega para main_menu.tscn.
