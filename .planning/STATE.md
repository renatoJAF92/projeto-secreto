---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: planning
last_updated: "2026-06-04T13:30:56.605Z"
progress:
  total_phases: 13
  completed_phases: 2
  total_plans: 7
  completed_plans: 7
  percent: 100
---

# STATE — Jogo da Natália

## Project Reference

**Core value:** Um jogo de plataforma 2D em pixel art que conta a história real de Natália — de Osasco à Espanha — como homenagem jogável, com mecânicas sólidas e narrativa emocional em 8 mundos.

**Stack:** Godot 4 (GDScript), pixel art 16x32, Git LFS, Dialogic 2, itch.io (HTML5)

---

## Current Position

**Phase:** 02 — Infraestrutura
**Status:** Ready to plan

```
Progress: [██░░░░░░░░] 15% (2 of 13 phases complete)
```

---

## Phase Checklist

| Phase | Name | Status |
|-------|------|--------|
| 0 | Fundação | ✅ Complete |
| 1 | Game Feel | ✅ Complete |
| 2 | Infraestrutura | Not started |
| 3 | Mundo 1 — Osasco | Not started |
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

**Last updated:** 2026-05-21T08:47:30Z
**Next action:** Human verify Task 4 in Godot editor (open test_movement.tscn, press F6, test coyote + jump buffer on ledge). After approval, continue with Plan 02 (dash + knockback).

### Context for next session

- Phase 0 COMPLETA: Godot 4.4.1 configurado, Git LFS ativo, 3 export presets, CI verde.
- **Phase 1 COMPLETA (2026-06-04):** player.gd com coyote 6f, jump buffer 8f, dash, knockback, 6 animações, squash/stretch, white flash, hit-stop 3f, CPUParticles2D dust. Todos os 5 critérios de sucesso aprovados em human-verify.
- Bug crítico corrigido: `velocity.x = _knockback.x` (não `+=`) evita acumulação infinita de knockback.
- player.gd + player.tscn são o controlador reutilizável para todos os 8 mundos.
- CPUParticles2D obrigatório (nunca GPUParticles2D) — renderer gl_compatibility não suporta GPU particles na web.
- Hit-stop usa `create_timer(duration, true)` — argumento process_always=true é obrigatório.
- O padrão de mundo completo é estabelecido na Phase 3 (Mundo 1) e replicado nas Phases 4-10.
- macOS CI pitfalls documentados em 00-004-SUMMARY.md (ETC2 ASTC, bundle identifier, codesign=1).
- **Próxima fase: Phase 2 — Infraestrutura** (save system, Dialogic 2, controles reconfiguráveis).
