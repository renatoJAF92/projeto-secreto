---
phase: 3
slug: mundo-1-osasco-vertical-slice-completo
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-06-08
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Godot 4 built-in — F5 (run scene) + human-verify |
| **Config file** | none — teste por cena individual |
| **Quick run command** | F5 na cena modificada no Godot editor |
| **Full suite command** | F5 em cada cena world1 + playthrough menu→abertura→fase1→fase2→fase3→boss |
| **Estimated runtime** | ~10-15 minutos (playthrough completo do Mundo 1) |

---

## Sampling Rate

- **After every task commit:** F5 na cena modificada — verificar sem crash no editor
- **After every plan wave:** Jogar do menu → abertura → fase1 → fase2 → fase3 → boss completo
- **Before `/gsd-verify-work`:** Todos os 6 critérios de sucesso da fase aprovados em human-verify
- **Max feedback latency:** ~15 minutos (playthrough completo)

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------------|-----------|-------------------|-------------|--------|
| 03-W0-01 | infra | W0 | AUDIO-02 | AudioManager stub não crasha | manual | F5 em qualquer cena com AudioManager.play_sfx() | ❌ W0 | ⬜ pending |
| 03-W0-02 | infra | W0 | WORLD-05 | player.gd emite `died` após animação death | manual | F5 test_movement.tscn: fazer player morrer e verificar respawn | ❌ W0 | ⬜ pending |
| 03-W0-03 | infra | W0 | BOSS-01 | save_manager aceita provas_mundo1 sem crash | manual | F5 qualquer cena que chame SaveManager.current_save.get("provas_mundo1", []) | ❌ W0 | ⬜ pending |
| 03-W1-01 | enemies | W1 | WORLD-01 | Malandro patrulha e não cai em buracos | manual | F5 fase1_rua.tscn: verificar patrulha horizontal + virada em borda | ❌ W1 | ⬜ pending |
| 03-W1-02 | enemies | W1 | WORLD-01 | Stomp mata malandro; contato lateral causa dano | manual | F5 fase1_rua.tscn: testar stomp e contato lateral | ❌ W1 | ⬜ pending |
| 03-W1-03 | checkpoints | W1 | WORLD-03 | Checkpoint salva checkpoint_id no SaveManager | manual | Ativar checkpoint, fechar Godot, reabrir e verificar current_save["checkpoint_id"] | ❌ W1 | ⬜ pending |
| 03-W1-04 | checkpoints | W1 | WORLD-05 | Respawn < 500ms (sem fade) | manual | Morrer e cronometrar com timer externo | ❌ W1 | ⬜ pending |
| 03-W1-05 | provas | W1 | BOSS-01 | Prova coletada persiste após morte | manual | Coletar prova, morrer, verificar que prova está em current_save | ❌ W1 | ⬜ pending |
| 03-W2-01 | boss | W2 | BOSS-01 | Barra de confiança sobe com provas | manual | Entrar boss com 2+ provas coletadas, verificar trust > 0 inicial | ❌ W2 | ⬜ pending |
| 03-W2-02 | boss | W2 | BOSS-01 | Choices corretas sobem, erradas baixam confiança | manual | Escolher resposta errada e verificar barra diminui | ❌ W2 | ⬜ pending |
| 03-W2-03 | boss | W2 | BOSS-01 | Dano direto não mata Luis (fase narrativa) | manual | Verificar que player não causa dano físico ao boss | ❌ W2 | ⬜ pending |
| 03-W2-04 | boss | W2 | BOSS-01 | Vitória com barra 100% → world1_end | manual | Completar boss e verificar transição para world1_end | ❌ W2 | ⬜ pending |
| 03-W2-05 | npc | W2 | NPC-01 | Renato visível em Fase 2 (bg) | manual | F5 fase2_parque.tscn: verificar sprite Renato no fundo | ❌ W2 | ⬜ pending |
| 03-W2-06 | npc | W2 | NPC-01 | Renato com diálogo funcional em Fase 3 | manual | F5 fase3_restaurante.tscn: aproximar e triggar diálogo Renato | ❌ W2 | ⬜ pending |
| 03-W3-01 | narrative | W3 | NARR-05 | mundo1_abertura exibe texto antes da Fase 1 | manual | Novo jogo → verificar cutscene Dialogic antes de fase1_rua | ❌ W3 | ⬜ pending |
| 03-W3-02 | audio | W3 | AUDIO-02 | SFX tocam: checkpoint, stomp, prova, dano | manual | Jogar Mundo 1 e verificar áudio em cada evento | ❌ W3 | ⬜ pending |
| 03-W3-03 | integration | W3 | WORLD-02 | Sequência completa: menu→fase1→fase2→fase3→boss | manual | Playthrough completo do Mundo 1 sem crashes | ❌ W3 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `autoloads/audio_manager.gd` — AudioManager stub com play_sfx(key) e play_music(stream)
- [ ] `autoloads/audio_manager.tscn` — nó AudioManager registrado em project.godot
- [ ] `player.gd` — adicionar `signal died` + emit em `_on_animated_sprite_2d_animation_finished` quando `animation == "death"`
- [ ] `save_manager.gd` — adicionar `"provas_mundo1": []` ao `_default_save()`; usar SCHEMA_VERSION ou .get() defensivo
- [ ] `scenes/world1/` — criar diretório base

*Bloqueia toda execução de mechanics até estar completo.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Paleta cinza-urbana Osasco correta | WORLD-01 | Avaliação visual subjetiva | Abrir fase1_rua.tscn no editor; verificar TileMapLayer com paleta #1A1A2E + acentos laranja/vermelho |
| Respawn < 500ms | WORLD-05 | Requer medição de tempo em tempo real | Morrer e cronometrar com timer externo (telefone); aceitável: respawn instantâneo visível |
| NPC Renato foreshadowing no restaurante | NPC-01 | Avaliação narrativa | Jogar fase3_restaurante.tscn; verificar Luis no fundo sem interação |
| Renato entra ao atingir ~80% trust bar | BOSS-01 | Verificação de gatilho narrativo em gameplay | Jogar boss até ~80% confiança; verificar entrada do Renato |
| SFX chiptune audíveis nos momentos corretos | AUDIO-02 | Verificação auditiva | Jogar Mundo 1 completo com som ligado |
| Cutscene mundo1_abertura pulável | NARR-05 | Teste de UX interativo | Apertar botão skip durante cutscene; verificar que pula corretamente |

---

## Validation Sign-Off

- [ ] Todos os Wave 0 requirements criados
- [ ] AudioManager registrado em project.godot sem erro de autoload
- [ ] player.gd tem `signal died` funcionando (respawn ativado)
- [ ] save_manager.gd tem `"provas_mundo1"` no schema sem crash
- [ ] Malandro patrulha corretamente, morre com stomp, não cai em buracos
- [ ] Checkpoint ativa SaveManager.set_checkpoint(); respawn < 500ms verificado
- [ ] Prova coletável persiste após morte
- [ ] Boss trust bar: provas +20%, correto +10%, errado -15%; vitória a 100%, derrota a 0%
- [ ] Boss puramente narrativo — sem dano físico à Natália
- [ ] NPC Renato em Fase 2 (bg) e Fase 3 (diálogo); entra no boss a ~80%
- [ ] mundo1_abertura.tscn exibe Dialogic antes da Fase 1
- [ ] Sequência completa menu→abertura→fase1→fase2→fase3→boss sem crash
- [ ] SFX placeholder tocam nos momentos corretos
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
