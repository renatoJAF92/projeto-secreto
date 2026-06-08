---
status: complete
phase: 02-infraestrutura
source: [02-001-SUMMARY.md, 02-002-SUMMARY.md, 02-003-SUMMARY.md, 02-004-SUMMARY.md, 02-005-SUMMARY.md]
started: 2026-06-08T00:00:00Z
updated: 2026-06-08T10:49:00Z
---

## Current Test

[testing complete]

## Tests

### 1. Tela inicial carrega
expected: Abra o projeto no Godot e pressione F5. A tela do Main Menu deve aparecer com fundo escuro (#1A1A2E), título "Destiny — Tales de Natalia", e 3 botões: CONTINUAR, NOVO JOGO, OPCOES.
result: issue
reported: "A tela não está com a melhor resolução, pois a versão está sendo cortada na parte de baixo"
severity: cosmetic

### 2. CONTINUAR desabilitado sem save
expected: Com o jogo recém-aberto (sem save existente), o botão CONTINUAR deve estar em cinza (#888888) e não responder a cliques. Remova manualmente o save se necessário: ~/Library/Application Support/Godot/app_userdata/Destiny — Tales of Natalia/save.dat
result: pass

### 3. NOVO JOGO sem save transita direto
expected: Sem save existente, clicar NOVO JOGO deve transitar direto para a cena de teste de movimento (sem nenhum popup ou diálogo de confirmação aparecer).
result: pass

### 4. CONTINUAR habilitado após criar save
expected: Após ter iniciado um jogo (save criado pelo passo anterior), reiniciar o jogo (F5). O botão CONTINUAR agora deve estar ativo e clicável.
result: pass

### 5. NOVO JOGO com save exige confirmação
expected: Com um save existente, clicar NOVO JOGO deve abrir um ConfirmationDialog perguntando "Apagar progresso? Esta acao nao pode ser desfeita." com botões APAGAR e CANCELAR. Clicar CANCELAR não deve fazer nada. Clicar APAGAR deve sobrescrever o save e transitar para a cena de teste.
result: pass

### 6. Options Menu — remapeamento persiste
expected: No Main Menu, clicar OPCOES. Na tela de opções, remap a ação "Pular" para a tecla J. Fechar o Godot e reabrir. A tela de opções deve mostrar J como binding do Pular. Testar em test_movement.tscn — pular com J deve funcionar.
result: pass

### 7. Options Menu — RESETAR CONTROLES
expected: Na tela de opções, após ter remapeado alguma ação, clicar o botão RESETAR CONTROLES. O binding de Pular deve voltar para Space, e os outros controles padrão devem ser restaurados.
result: pass

### 8. Dialogic — caixa de diálogo com retratos
expected: Abrir a cena scenes/test_dialogue/test_dialogue.tscn no Godot (clique duplo no FileSystem). Pressionar F6 para rodar só essa cena. Clicar INICIAR. Deve aparecer caixa de diálogo com: texto de Natália e retrato à esquerda, depois texto de Renato com retrato à direita. O diálogo avança com Enter ou Space.
result: pass

### 9. Dialogic — botão PULAR aparece na segunda vez
expected: Na cena test_dialogue.tscn, ao rodar pela segunda vez (clicar INICIAR novamente após o diálogo terminar), o botão PULAR deve aparecer visível. Clicar PULAR deve acelerar o diálogo (auto_skip). Na primeira vez não deve aparecer.
result: pass

### 10. Sprites — player usa spritesheet
expected: Abrir scenes/player/player.tscn no editor Godot. Selecionar o nó AnimatedSprite2D (ou equivalente). O sprite deve mostrar uma imagem da Natália (gerada por foto) em vez do SVG placeholder anterior. O arquivo referenciado deve ser assets/sprites/natalia_spritesheet.png.
result: pass

## Summary

total: 10
passed: 9
issues: 1
pending: 0
skipped: 0
blocked: 0

## Gaps

- truth: "Label 'v0.2' visível no canto inferior direito da tela inicial"
  status: failed
  reason: "User reported: A tela não está com a melhor resolução, pois a versão está sendo cortada na parte de baixo"
  severity: cosmetic
  test: 1
  root_cause: ""
  artifacts: []
  missing: []
  debug_session: ""
