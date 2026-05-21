---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: executing
last_updated: "2026-05-21"
progress:
  total_phases: 13
  completed_phases: 1
  total_plans: 4
  completed_plans: 4
  percent: 8
---

# STATE — Jogo da Natália

## Project Reference

**Core value:** Um jogo de plataforma 2D em pixel art que conta a história real de Natália — de Osasco à Espanha — como homenagem jogável, com mecânicas sólidas e narrativa emocional em 8 mundos.

**Stack:** Godot 4 (GDScript), pixel art 16x32, Git LFS, Dialogic 2, itch.io (HTML5)

---

## Current Position

Phase: 01 (Game Feel) — NOT STARTED
**Phase:** 1 — Game Feel
**Status:** Phase 0 complete — ready to plan Phase 1

```
Progress: [█░░░░░░░░░░░░░░░░░░░] 1/13 phases complete
```

---

## Phase Checklist

| Phase | Name | Status |
|-------|------|--------|
| 0 | Fundação | ✅ Complete |
| 1 | Game Feel | Not started |
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
**Plans complete:** 0
**Playtests documented:** 0

---

## Accumulated Context

### Decisions made

| Decision | Rationale | Phase |
|----------|-----------|-------|
| Renderer Compatibility desde Phase 0 | HTML5 export exige; custo zero se definido cedo | 0 |
| Game feel antes de level design | Movimento ruim invalida testes de fase | 1 |
| Dialogic 2 em infraestrutura (Phase 2) | Diálogos necessários em todos os mundos; instalar cedo evita refatoração | 2 |
| Overworld na Phase 11 | Conexão entre mundos só faz sentido após os mundos existirem | 11 |
| Assist Mode no polish final | Feature completa, não pode ser incompleta no release | 12 |

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

**Last updated:** 2026-05-21
**Next action:** Run `/gsd-plan-phase 1` to plan Phase 1 (Game Feel).

### Context for next session

- Phase 0 COMPLETA: Godot 4.4.1 configurado, Git LFS ativo, 3 export presets, CI verde (Web ✓ Windows ✓ macOS ✓).
- Deploy itch.io: `continue-on-error: true` — funciona quando BUTLER_CREDENTIALS for configurado.
- Phase 1 foca exclusivamente em game feel — sem level design até movement estar polido.
- O padrão de mundo completo é estabelecido na Phase 3 (Mundo 1) e replicado nas Phases 4-10.
- POWER-08 (persistência de poderes) foi mapeado para Phase 10 pois só é verificável quando todos os poderes existem.
- macOS CI pitfalls documentados em 00-004-SUMMARY.md (ETC2 ASTC, bundle identifier, codesign=1).
