---
phase: 02-infraestrutura
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - scripts/generate_sprites.py
  - assets/sprites/natalia_spritesheet.png
  - assets/sprites/portraits/natalia_portrait.png
  - assets/sprites/portraits/renato_portrait.png
  - scenes/player/player.tscn
autonomous: false
requirements: [NPC-04]
must_haves:
  truths:
    - "Sprite sheet 192x32 da Natália existe gerado a partir de foto real"
    - "Portraits 64x80 de Natália e Renato existem para uso em diálogos"
    - "player.tscn referencia natalia_spritesheet.png nas 6 animações (não o SVG placeholder)"
    - "godot --headless --check-only passa sem erro após a troca de SpriteFrames"
    - "generate_sprites.py trata foto ausente/corrompida com mensagem clara e exit code 1 (não crash com traceback PIL)"
  artifacts:
    - path: "scripts/generate_sprites.py"
      provides: "Pipeline offline Python/Pillow de geração de sprite sheet e portraits"
      contains: "def generate_natalia_spritesheet"
    - path: "assets/sprites/natalia_spritesheet.png"
      provides: "Sprite sheet 192x32 (6 frames x 32x32) da protagonista"
    - path: "assets/sprites/portraits/natalia_portrait.png"
      provides: "Portrait JRPG 64x80 da Natália"
    - path: "assets/sprites/portraits/renato_portrait.png"
      provides: "Portrait JRPG 64x80 do Renato"
    - path: "scenes/player/player.tscn"
      provides: "SpriteFrames apontando para o sprite sheet real da Natália"
      contains: "natalia_spritesheet.png"
  key_links:
    - from: "scripts/generate_sprites.py"
      to: "Photos/Natalia/*.jpg"
      via: "Image.open com fotos JPG"
      pattern: "Photos/Natalia"
    - from: "scenes/player/player.tscn"
      to: "assets/sprites/natalia_spritesheet.png"
      via: "ext_resource Texture2D referenciado nas 6 animações do SpriteFrames"
      pattern: "natalia_spritesheet"
---

<objective>
Gerar o sprite sheet pixel art 32x32 da Natália (NPC-04) e os portraits JRPG de Natália e Renato a partir das fotos reais, e fazer o wiring do sprite sheet no `player.tscn` substituindo o SVG placeholder.

Purpose: NPC-04 exige sprite da protagonista baseado em foto real; é o asset visual central reutilizado em todos os 8 mundos. Os portraits são pré-requisito para o plano de diálogos (Dialogic).
Output: `scripts/generate_sprites.py`, `assets/sprites/natalia_spritesheet.png`, dois portraits em `assets/sprites/portraits/`, e `player.tscn` atualizado.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/STATE.md
@.planning/phases/02-infraestrutura/02-CONTEXT.md
@.planning/phases/02-infraestrutura/02-RESEARCH.md
@.planning/phases/02-infraestrutura/02-PATTERNS.md

<interfaces>
<!-- Estrutura SpriteFrames existente em player.tscn — 6 animações já nomeadas. -->
<!-- A textura ExtResource id="2_sprite" aponta hoje para natalia_placeholder.svg. -->
<!-- Substituir o path dessa ExtResource (e o uid) por natalia_spritesheet.png. -->
<!-- Animações: death, fall, hurt (loop=false); idle, run (loop=true); jump (loop=false). -->
<!-- A foto principal a usar é Photos/Natalia/IMG_20260222_212225.jpg (JPG, alta resolução). -->
<!-- Para o portrait do Renato, usar uma das WhatsApp Image 2026-01-29*.jpeg (melhor frente/iluminação). -->
<!-- Características visuais a preservar estão em 02-CONTEXT.md §Referências Visuais. -->
</interfaces>
</context>

<tasks>

<task type="auto">
  <name>Task 1: Script Python/Pillow de geração de sprite sheet e portraits</name>
  <files>scripts/generate_sprites.py, assets/sprites/natalia_spritesheet.png, assets/sprites/portraits/natalia_portrait.png, assets/sprites/portraits/renato_portrait.png</files>
  <read_first>
    - scripts/generate_sprites.py (não existe ainda — confirmar)
    - serve.py (convenções Python do projeto: shebang, docstring com bloco Uso, constantes UPPER_CASE, guard __name__)
    - .planning/phases/02-infraestrutura/02-RESEARCH.md §Pattern 5 (pipeline Pillow verificado: photo_to_pixel_art, generate_natalia_spritesheet, generate_portrait)
    - .planning/phases/02-infraestrutura/02-CONTEXT.md §Referências Visuais (cabelo escuro volumoso, óculos retangular, pele #C49A6C para Natália; barba cheia, óculos redondo, pele #D4A574 para Renato)
  </read_first>
  <action>
    Criar `scripts/generate_sprites.py` seguindo as convenções de `serve.py`: shebang `#!/usr/bin/env python3`, docstring com bloco `Uso:` (`python3 scripts/generate_sprites.py` a partir da raiz do projeto), `from PIL import Image`, `import os`, `import sys`, constantes `PHOTOS_DIR = "Photos"` e `OUTPUT_DIR = "assets/sprites"` (atenção à capitalização `Photos` — confirmada no filesystem), guard `if __name__ == '__main__':`.
    Implementar três funções tipadas conforme RESEARCH.md Pattern 5:
    (a) `photo_to_pixel_art(img_path, target_size, palette_colors=16)` — `Image.open().convert("RGB")`, `resize(target_size, Image.LANCZOS)`, `quantize(colors=palette_colors, method=Image.Quantize.MEDIANCUT)`.
    (b) `generate_natalia_spritesheet(photo_path)` — crop corpo (crop_h = 0.85*h, crop_w = 0.5*crop_h, centralizado), resize 32x32 LANCZOS, quantize 16 cores MEDIANCUT, montar sheet RGBA 192x32 com os 6 frames na ordem `["idle", "run", "jump", "fall", "hurt", "death"]` colando o mesmo frame base em cada slot (placeholder funcional desta fase — animação frame-a-frame fica para Phase 3, ver RESEARCH.md Open Question 2), salvar em `assets/sprites/natalia_spritesheet.png`. Para evitar flickering de paleta entre frames (Pitfall 6), usar o MESMO frame quantizado em todos os 6 slots.
    (c) `generate_portrait(photo_path, output_name)` — crop busto (crop_h = 0.55*h, cabeça+ombros), resize 64x80 LANCZOS, quantize 16 cores, salvar RGBA em `assets/sprites/portraits/{output_name}.png`.
    ERROR HANDLING (Addresses review concern: Python script missing error handling — HIGH, Ollama): cada função que abre uma foto DEVE envolver a chamada `Image.open(photo_path)` em `try/except (FileNotFoundError, OSError, Exception) as e`. No except: imprimir em stderr (`print(..., file=sys.stderr)`) uma mensagem clara incluindo o caminho exato do arquivo (ex: `f"ERRO: nao foi possivel abrir a foto '{photo_path}': {e}"`) e chamar `sys.exit(1)`. Isto evita o traceback PIL bruto e garante exit code 1 quando uma foto está ausente ou corrompida.
    No `__main__`: chamar `generate_natalia_spritesheet("Photos/Natalia/IMG_20260222_212225.jpg")`, `generate_portrait("Photos/Natalia/IMG_20260222_212225.jpg", "natalia_portrait")`, `generate_portrait("Photos/Renato/WhatsApp Image 2026-01-29 at 14.52.08.jpeg", "renato_portrait")`. Criar `os.makedirs(OUTPUT_DIR + "/portraits", exist_ok=True)` antes de salvar. O bloco `__main__` herda o tratamento de erro das funções (foto ausente → mensagem clara + exit 1, sem traceback PIL).
    Executar o script: `cd /Users/renatojaf/jogo-natalia && python3 scripts/generate_sprites.py`. Verificar os 3 PNGs gerados com dimensões corretas via Pillow ou `file`.
  </action>
  <acceptance_criteria>
    - `scripts/generate_sprites.py` contém `def generate_natalia_spritesheet`, `def generate_portrait`, `def photo_to_pixel_art`
    - `scripts/generate_sprites.py` contém `if __name__ == '__main__':` e `Image.Quantize.MEDIANCUT`
    - `scripts/generate_sprites.py` contém `except` e `FileNotFoundError` (tratamento de erro presente) e `sys.exit(1)`
    - Rodar o script com um caminho de foto inexistente sai com código 1 e imprime uma mensagem de erro clara contendo o caminho do arquivo (não um traceback PIL bruto)
    - Comando `python3 scripts/generate_sprites.py` na raiz (com as fotos reais presentes) sai com código 0
    - `assets/sprites/natalia_spritesheet.png` existe e tem 192x32 px (verificável: `python3 -c "from PIL import Image; print(Image.open('assets/sprites/natalia_spritesheet.png').size)"` imprime `(192, 32)`)
    - `assets/sprites/portraits/natalia_portrait.png` existe e tem 64x80 px
    - `assets/sprites/portraits/renato_portrait.png` existe e tem 64x80 px
  </acceptance_criteria>
  <verify>
    <automated>cd /Users/renatojaf/jogo-natalia && grep -q "FileNotFoundError" scripts/generate_sprites.py && grep -q "except" scripts/generate_sprites.py && python3 scripts/generate_sprites.py && python3 -c "from PIL import Image; assert Image.open('assets/sprites/natalia_spritesheet.png').size==(192,32); assert Image.open('assets/sprites/portraits/natalia_portrait.png').size==(64,80); assert Image.open('assets/sprites/portraits/renato_portrait.png').size==(64,80); print('OK')"</automated>
  </verify>
  <done>Script gera os 3 PNGs com dimensões corretas a partir das fotos reais; trata foto ausente/corrompida com mensagem clara e exit 1; exit 0 no caminho feliz.</done>
</task>

<task type="auto">
  <name>Task 2: Wiring do sprite sheet no player.tscn (substituir SVG placeholder)</name>
  <files>scenes/player/player.tscn</files>
  <read_first>
    - scenes/player/player.tscn (estado atual: ExtResource id="2_sprite" aponta para natalia_placeholder.svg; SpriteFrames com 6 animações de 1 frame cada)
    - scenes/player/player.gd (função _update_animation — depende dos nomes idle/run/jump/fall/hurt/death; null-guard `if sprite.sprite_frames`)
    - assets/sprites/natalia_spritesheet.png (gerado na Task 1 — fonte da nova textura)
  </read_first>
  <action>
    O sprite sheet é 192x32 com 6 frames horizontais (32x32 cada). Importar como AtlasTexture por frame OU usar uma única textura recortada. Abordagem: criar 6 sub_resources `AtlasTexture` em `player.tscn`, cada um com `atlas` = ExtResource do `natalia_spritesheet.png` e `region = Rect2(i*32, 0, 32, 32)` para i=0..5, mapeando idle(0), run(1), jump(2), fall(3), hurt(4), death(5). Substituir, em cada uma das 6 animações do SpriteFrames existente, a `texture` de `ExtResource("2_sprite")` (SVG) pelo AtlasTexture correspondente.
    Atualizar o `ext_resource` de id `2_sprite`: trocar `path="res://assets/sprites/player/natalia_placeholder.svg"` por `path="res://assets/sprites/natalia_spritesheet.png"` e `type="Texture2D"`. Remover/regerar o `uid` do ext_resource (deixar o Godot reimportar — ou rodar o import headless). Incrementar `load_steps` no header conforme os novos sub_resources AtlasTexture.
    NÃO alterar `player.gd`, a CollisionShape2D (20x30), nem o DustParticles. As 6 animações DEVEM manter exatamente os nomes e flags de loop atuais (idle/run loop=true; jump/fall/hurt/death loop=false).
    Garantir que o `.png` é rastreado por Git LFS (já configurado na Phase 0 via .gitattributes) — confirmar com `git check-attr filter assets/sprites/natalia_spritesheet.png`.
    Rodar import + check headless: `godot --headless --path . --import` (se necessário gerar .import) seguido de `godot --headless --path . --check-only`.
  </action>
  <acceptance_criteria>
    - `scenes/player/player.tscn` contém a string `natalia_spritesheet.png`
    - `scenes/player/player.tscn` NÃO contém mais `natalia_placeholder.svg`
    - As 6 animações idle/run/jump/fall/hurt/death continuam presentes no SpriteFrames (grep por cada nome retorna match)
    - `git check-attr filter assets/sprites/natalia_spritesheet.png` reporta `filter: lfs`
    - `godot --headless --path . --check-only` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>cd /Users/renatojaf/jogo-natalia && grep -q natalia_spritesheet scenes/player/player.tscn && ! grep -q natalia_placeholder scenes/player/player.tscn && for a in idle run jump fall hurt death; do grep -q "\"$a\"" scenes/player/player.tscn || (echo "missing anim $a" && exit 1); done && godot --headless --path . --check-only</automated>
  </verify>
  <done>player.tscn usa o sprite sheet real da Natália nas 6 animações; check headless passa; PNG sob LFS.</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>Sprite sheet 32x32 da Natália gerado da foto real e ligado ao player.tscn; portraits 64x80 de Natália e Renato gerados.</what-built>
  <how-to-verify>
    1. Abrir o Godot editor no projeto.
    2. Abrir `scenes/test_movement/test_movement.tscn` e pressionar F6.
    3. Confirmar que a Natália agora aparece com o novo sprite (não o quadrado/silhueta placeholder); o cabelo escuro volumoso deve ser perceptível.
    4. Mover (A/D), pular (Space), tomar dano (caixa vermelha) — confirmar que idle/run/jump/fall/hurt animam sem erro no Output.
    5. Abrir `assets/sprites/portraits/natalia_portrait.png` e `renato_portrait.png` no editor e confirmar que são bustos reconhecíveis (Natália: cabelo+óculos; Renato: barba+óculos).
  </how-to-verify>
  <resume-signal>Digite "approved" ou descreva ajustes necessários no sprite/portrait.</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| Foto JPG → pipeline Pillow | Input de arquivo de imagem local; processado offline, não em runtime do jogo |
| PNG gerado → import Godot | Asset binário importado; sem execução de código |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-02-01 | Tampering | natalia_spritesheet.png ausente/corrompido no import | mitigate | `--check-only` falha se a textura referenciada não resolver; gate no verify |
| T-02-02 | Information Disclosure | Fotos reais pessoais em Photos/ | accept | Fotos já no repositório local sob controle do dono; sprite gerado é derivado de baixa resolução |
| T-02-03 | Denial of Service | Foto de entrada ausente/corrompida trava o pipeline | mitigate | `try/except (FileNotFoundError, OSError, Exception)` ao redor de `Image.open`; mensagem clara com o caminho + `sys.exit(1)` |
</threat_model>

<verification>
- `python3 scripts/generate_sprites.py` gera 3 PNGs com dimensões exatas (192x32, 64x80, 64x80).
- Foto ausente → mensagem clara + exit 1 (sem traceback PIL bruto).
- `godot --headless --path . --check-only` passa com player.tscn usando o sprite sheet.
- Human-verify confirma sprite reconhecível em test_movement.tscn.
</verification>

<success_criteria>
NPC-04 atendido: sprite placeholder da Natália baseado em foto real definido como asset de referência (sprite sheet com 6 slots de animação), e portraits prontos para o plano de diálogos.
</success_criteria>

<output>
Após completar, criar `.planning/phases/02-infraestrutura/02-001-SUMMARY.md`.
</output>
</content>
</invoke>
