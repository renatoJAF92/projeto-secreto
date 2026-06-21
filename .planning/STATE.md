---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: — Mundos 1 e 2
status: executing
last_updated: "2026-06-18T15:14:44.080Z"
progress:
  total_phases: 7
  completed_phases: 7
  total_plans: 29
  completed_plans: 29
  percent: 100
---

# STATE — Jogo da Natália

## Project Reference

**Core value:** Um jogo de plataforma 2D em pixel art que conta a história real de Natália — de Osasco à Espanha — como homenagem jogável, com mecânicas sólidas e narrativa emocional em 8 mundos.

**Stack:** Godot 4 (GDScript), pixel art 16x32, Git LFS, Dialogic 2, itch.io (HTML5)

---

## Current Position

Phase: 05 (level-design-overhaul) — EXECUTING
Plan: 1 of 4
**Phase:** 04 — Mundo 2 — A Faculdade — 5 plans ready for execution
**Status:** Executing Phase 05

```
Progress: [███████░░░] 38% (5 of 13 phases complete)
```

---

## Phase Checklist

| Phase | Name | Status |
|-------|------|--------|
| 0 | Fundação | ✅ Complete |
| 1 | Game Feel | ✅ Complete |
| 2 | Infraestrutura | ✅ Complete |
| 3 | Mundo 1 — Osasco | ✅ Complete (2026-06-09) |
| 4 | Mundo 2 — A Faculdade | Not started |
| 5 | Mundo 3 — O Corporativo | Not started |
| 6 | Mundo 4 — A Pandemia | Not started |
| 7 | Mundo 5 — Santiago e os Votos | Not started |
| 8 | Mundo 6 — Tossa de Mar | Not started |
| 9 | Mundo 7 — Vilanova i la Geltrú | Not started |
| 10 | Mundo 8 — Zaragoza | Not started |
| 11 | Overworld e NPCs Secundários | Not started |
| 12 | Polish, Acessibilidade e Release | Not started |

---

## Performance Metrics

**Phases complete:** 0/13
**Requirements mapped:** 44/44
**Plans complete:** 7/10 (phases 0-1 complete)
**Playtests documented:** 1 (Phase 1 human-verify approved 2026-06-04)

---

## Accumulated Context

### Decisions made

| Decision | Rationale | Phase |
|----------|-----------|-------|
| Renderer Compatibility desde Phase 0 | HTML5 export exige; custo zero se definido cedo | 0 |
| Game feel antes de level design | Movimento ruim invalida testes de fase | 1 |
| Frame counters > Timer nodes para coyote/buffer | Sync perfeito com _physics_process a 60Hz, sem overhead de nós | 01-001 |
| sprite_frames null-guard em _update_animation | AnimatedSprite2D sem SpriteFrames até Plan 02; guard evita crash no editor | 01-001 |
| CollisionShape2D 20x30 para sprite 32x32 | Margem pequena evita wall-sticking lateral | 01-001 |
| Dialogic 2 em infraestrutura (Phase 2) | Diálogos necessários em todos os mundos; instalar cedo evita refatoração | 2 |
| Overworld na Phase 11 | Conexão entre mundos só faz sentido após os mundos existirem | 11 |
| Assist Mode no polish final | Feature completa, não pode ser incompleta no release | 12 |
| Phase 01-game-feel P01-001 | 70min | 4 tasks | 6 files |

### Todos

- [ ] Obter foto real da Natália para sprite base (NPC-04, Phase 2)
- [ ] Obter foto real do Renato para sprite NPC (NPC-01, Phase 3)
- [ ] Definir paletas de cores dos 8 mundos antes de Phase 3
- [ ] Planejar SFX mínimos antes de Phase 3 (pulo, dano, checkpoint)
- [ ] Validar Dialogic 2 com Godot 4 LTS antes de Phase 2

### Blockers

*(Nenhum ainda)*

---

## Session Continuity

**Last updated:** 2026-06-09T01:34:00Z
**Next action:** `/gsd-plan-phase 4` — Mundo 2 A Faculdade

### Context for next session

- Phase 0 COMPLETA: Godot 4.4.1 configurado, Git LFS ativo, 3 export presets, CI verde.
- Phase 1 COMPLETA (2026-06-04): player.gd com coyote 6f, jump buffer 8f, dash, knockback, 6 animações
- Phase 2 COMPLETA: SaveManager, AudioManager, ControlsManager autoloads; Dialogic 2 integration
- **Phase 3 Plan 01 COMPLETA (2026-06-08):** AudioManager autoload, player.died signal, provas_mundo1 schema
- **Phase 3 Plan 02 COMPLETA (2026-06-08):** Malandro (stomp + lateral damage), StaticObstacle, Checkpoint, ProvaItem
  - Todos os 4 objetos são reusáveis e can be instanced múltiplas vezes
  - Stomp-kill com bounce guarded by _stomped_this_frame flag (previne double-hit)
  - Prova persistence com defensive .get() e dedup guard
  - All collision disables use set_deferred() (physics safety)
  - No GPUParticles2D anywhere (gl_compatibility constraint)
- **Phase 3 Plan 03 COMPLETA (2026-06-08):** Vertical slice assembly + NPCs
  - fase1_rua.tscn + fase1_rua.gd: playable linear phase com respawn <500ms + enemy reset
  - fase2_parque.tscn + fase2_parque.gd: playable linear phase + Renato background NPC (z_index=-1, alpha 0.8)
  - fase3_restaurante.tscn + fase3_restaurante.gd: playable linear phase + Luis foreshadow (z_index=-2, occluded) + Renato dialogue NPC
  - renato_npc.gd: StaticBody2D com DialogueZone + Prompt label, guarded Dialogic.start()
  - Control substitution: 'jump' action used as interact trigger (no dedicated 'interact' action exists)
- CPUParticles2D obrigatório (nunca GPUParticles2D) — renderer gl_compatibility não suporta GPU particles na web
- Hit-stop uses `create_timer(duration, true)` — argumento process_always=true é obrigatório
- **Phase 3 Plan 04 COMPLETA (2026-06-08):** Boss fight + Dialogic timelines
  - boss_abertura.dtl: 3 question choices with signal events (choice_correct/wrong), renato_entrada cue
  - boss_renato_entrada.dtl: Renato's commitment speech
  - boss_vitoria.dtl: Luis relents + accepts couple
  - renato_restaurante.dtl: fase3 restaurant dialogue (forward-ref from Plan 03 closed)
  - boss_abertura_bloqueado.dtl: blocking message for <2 provas
  - boss_pai.tscn + boss_pai.gd: trust HUD (CanvasLayer 51), provas gate (≥2), trust mechanics (+20 prova, +10 correct, -15 wrong)
  - HUD color steps: red <20%, green <80%, gold ≥80% (stepped)
  - Renato entrance at ~80% trust via signal event
  - Victory at 100%, game-over at 0% (reload preserves provas)
  - CRITICAL FIXES: Signal connect before Dialogic.start, Dialogic.end_timeline before transition
  - Luis character definition (Luis.dch)
- **Phase 3 Plan 05 COMPLETA (2026-06-09):** Opening narrative + SFX + world1_end + human-verify
  - mundo1_abertura.dtl/.tscn/.gd: cutscene com skip-on-seen, auto-start Dialogic, SceneTransition para fase1_rua
  - 8 SFX registrados no AudioManager (jump, checkpoint, prova_coletada, prova_apresentada, dialogo_errado, stomp, dano, vitoria)
  - jump SFX wire em player.gd jump-execution branch
  - world1_end.tscn/.gd placeholder criado (retorno ao menu)
  - main_menu.gd roteado para mundo1_abertura.tscn (New Game + Continue)
  - AUDIO-02 FULL PASS: 8 WAVs audíveis com tons distintos gerados via Python PCM synthesis
- **PHASE 3 COMPLETA ✅ (2026-06-09):** Mundo 1 Osasco vertical slice completo e jogável
