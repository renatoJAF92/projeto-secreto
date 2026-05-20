# Phase 0: Fundação - Pattern Map

**Mapped:** 2026-05-20
**Files analyzed:** 8 (arquivos novos + estrutura de pastas)
**Analogs found:** 0 / 8 — codebase vazio, todos os padrões vêm do RESEARCH.md

---

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `project.godot` | config | transform (engine reads at startup) | nenhum | sem análogo |
| `.gitattributes` | config | transform (git filter rules) | nenhum | sem análogo |
| `.gitignore` | config | transform (git exclude rules) | nenhum | sem análogo |
| `export_presets.cfg` | config | transform (engine + CI leem para export) | nenhum | sem análogo |
| `.github/workflows/export.yml` | config (CI/CD) | event-driven (tags `v*` + PRs) | nenhum | sem análogo |
| `scenes/main.tscn` | scene (Godot) | request-response (engine carrega na inicialização) | nenhum | sem análogo |
| `serve.py` | utility | request-response (HTTP server local) | nenhum | sem análogo |
| Estrutura de pastas | — | — | — | apenas pastas vazias |

> **Nota para o planner:** O repositório contém apenas `.git/`, `.planning/` e `CLAUDE.md`. Não existe nenhum arquivo de código fonte. Todos os padrões abaixo são derivados do RESEARCH.md e da documentação verificada. O planner deve referenciar estes padrões diretamente — não há linhas de código existentes para copiar.

---

## Pattern Assignments

### `project.godot` (config, transform)

**Analog:** nenhum — arquivo novo
**Fonte do padrão:** RESEARCH.md Pattern 1 + Godot 4.4 docs oficiais

**Conteúdo completo a ser criado:**

```ini
; project.godot — gerado pelo editor Godot 4.4.x e editado manualmente
; ATENÇÃO: criar via GUI do Godot (File > New Project com renderer Compatibility),
; depois editar para adicionar as settings de pixel art abaixo.
; Não criar manualmente do zero — o editor valida a estrutura interna.

[gd_version]
config_version=5

[application]
config/name="Destiny — Tales of Natalia"
config/features=PackedStringArray("4.4", "GL Compatibility")
config/icon="res://icon.svg"
run/main_scene="res://scenes/main.tscn"

[display]
window/size/viewport_width=320
window/size/viewport_height=180
window/size/window_width_override=1280
window/size/window_height_override=720
window/stretch/mode="canvas_items"
window/stretch/scale_mode="integer"

[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/canvas_textures/default_texture_filter=0
2d/snap/snap_2d_transforms_to_pixel=true
```

**Notas de implementação:**
- `default_texture_filter=0` = Nearest (enum interno do Godot). [ASSUMED — verificar no editor após criar]
- `window_width_override=1280` e `window_height_override=720` definem o tamanho inicial da janela do desktop (não o viewport de jogo).
- `renderer/rendering_method="gl_compatibility"` é **obrigatório** para web export. Verificar com `grep "gl_compatibility" project.godot` após criar.
- O editor pode adicionar campos extras ao arquivo — não remover.

**Verificação:**
```bash
grep "gl_compatibility" /Users/renatojaf/jogo-natalia/project.godot
# Deve retornar a linha acima
```

---

### `.gitattributes` (config, transform)

**Analog:** nenhum — arquivo novo
**Fonte do padrão:** RESEARCH.md Pattern 2 + decisão D-06

**Conteúdo completo a ser criado:**

```
# .gitattributes — Git LFS tracking rules
# DEVE ser o primeiro arquivo commitado, antes de qualquer asset binário

# Imagens
*.png filter=lfs diff=lfs merge=lfs -text
*.jpg filter=lfs diff=lfs merge=lfs -text
*.webp filter=lfs diff=lfs merge=lfs -text

# Áudio
*.wav filter=lfs diff=lfs merge=lfs -text
*.ogg filter=lfs diff=lfs merge=lfs -text
*.mp3 filter=lfs diff=lfs merge=lfs -text

# Godot binary resources
*.scn filter=lfs diff=lfs merge=lfs -text
*.res filter=lfs diff=lfs merge=lfs -text

# Fontes
*.ttf filter=lfs diff=lfs merge=lfs -text
*.otf filter=lfs diff=lfs merge=lfs -text
```

**Notas de implementação:**
- Git LFS deve estar instalado ANTES de criar este arquivo: `brew install git-lfs && git lfs install`
- Ordem de operações: instalar LFS → criar `.gitattributes` → commitar → adicionar assets
- Verificar com `git lfs ls-files` após adicionar um PNG de teste

---

### `.gitignore` (config, transform)

**Analog:** nenhum — arquivo novo
**Fonte do padrão:** RESEARCH.md + decisão D-07

**Conteúdo completo a ser criado:**

```
# .gitignore — Godot 4 project

# Cache da engine (regenerado ao abrir o projeto)
.godot/

# Traduções compiladas (geradas automaticamente)
*.translation

# Artifacts de export (gerados pelo CI/CD ou godot --export-release)
export/

# macOS
.DS_Store
```

**Notas de implementação:**
- `.godot/` é crítico — sem isso, cache de importação vai para o git (centenas de MB)
- `export/` já está no .gitignore mas `export_presets.cfg` (diferente) DEVE ser commitado (D-10)

---

### `export_presets.cfg` (config, transform)

**Analog:** nenhum — arquivo novo
**Fonte do padrão:** RESEARCH.md Pattern 3 + crystal-bit/godot-game-template

**Método de criação (preferido):** Criar via editor Godot — Project > Export — para cada plataforma (Web, Windows Desktop, macOS). O editor gera o arquivo correto e definitivo. Depois commitar.

**Padrão de referência (aproximação — o editor pode gerar campos adicionais):**

```ini
; export_presets.cfg — gerado pelo editor Godot 4.4.x
; NÃO criar manualmente do zero — usar Project > Export no editor

[preset.0]
name="Web"
platform="Web"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="export/web/index.html"
script_export_mode=1
script_encryption_key=""

[preset.0.options]
variant/export_type=0
vram_texture_compression/for_desktop=true
vram_texture_compression/for_mobile=false
html/export_icon=true
html/canvas_resize_policy=2
html/focus_canvas_on_start=true
html/experimental_virtual_keyboard=false
progressive_web_app/enabled=false

[preset.1]
name="Windows Desktop"
platform="Windows Desktop"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="export/windows/destiny-tales-of-natalia.exe"
script_export_mode=1
script_encryption_key=""

[preset.1.options]
binary_format/embed_pck=true
texture_format/s3tc_bptc=true
texture_format/etc2_astc=false
binary_format/architecture="x86_64"
codesign/enable=false

[preset.2]
name="macOS"
platform="macOS"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="export/mac/destiny-tales-of-natalia.zip"
script_export_mode=1
script_encryption_key=""

[preset.2.options]
binary_format/architecture="universal"
codesign/enable=false
notarization/enable=false
```

**Notas de implementação:**
- Nome do preset DEVE ser exatamente `"Web"` (não "HTML5") — Godot 4 renomeou a plataforma
- `export_path` deve apontar para pasta dentro de `export/` (que está no .gitignore)
- O arquivo `export_presets.cfg` em si DEVE ser commitado (D-10) — o CI/CD depende dele
- Verificar `export_presets.cfg` com `grep 'name=' export_presets.cfg` após criar

---

### `.github/workflows/export.yml` (config CI/CD, event-driven)

**Analog:** nenhum — arquivo novo
**Fonte do padrão:** RESEARCH.md Pattern 4 + abarichello/godot-ci docs + decisões D-14 a D-18

**Comportamento esperado:**
- Tags `v*` (ex: `v0.0`) → export Web + Windows + macOS + deploy itch.io
- Pull Requests para `main` → apenas export (sem deploy) — verifica que o projeto compila

**Conteúdo completo a ser criado:**

```yaml
# .github/workflows/export.yml
# Source pattern: abarichello/godot-ci + CONTEXT.md D-14 a D-18

name: Export and Deploy

on:
  push:
    tags:
      - 'v*'
  pull_request:
    branches:
      - main

env:
  GODOT_VERSION: "4.4.1"
  EXPORT_NAME: "destiny-tales-of-natalia"
  PROJECT_PATH: "."

jobs:
  export-web:
    name: Web Export
    runs-on: ubuntu-latest
    container:
      image: barichello/godot-ci:4.4.1
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          lfs: true              # D-17: obrigatório — sem isso, assets são ponteiros LFS de 130 bytes

      - name: Setup export templates
        run: |
          mkdir -p ~/.local/share/godot/export_templates/
          mv /root/.local/share/godot/export_templates/${GODOT_VERSION}.stable \
             ~/.local/share/godot/export_templates/${GODOT_VERSION}.stable

      - name: Import assets (necessário para CI headless)
        run: godot --headless --editor --quit --path ${{ env.PROJECT_PATH }}

      - name: Export Web
        run: |
          mkdir -p build/web
          godot --headless --verbose --export-release "Web" \
            build/web/index.html        # D-18: --headless --export-release

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: web
          path: build/web/

      - name: Deploy to itch.io
        if: startsWith(github.ref, 'refs/tags/v')   # D-14: apenas em tags v*
        uses: manleydev/butler-publish-itchio-action@master
        env:
          BUTLER_CREDENTIALS: ${{ secrets.BUTLER_CREDENTIALS }}  # D-16: secret, não senha
          CHANNEL: html5
          ITCH_GAME: destiny-tales-of-natalia
          ITCH_USER: ITCH_USER   # D-16: placeholder — atualizar quando página itch.io criada
          PACKAGE: build/web

  export-windows:
    name: Windows Export
    runs-on: ubuntu-latest
    container:
      image: barichello/godot-ci:4.4.1
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          lfs: true

      - name: Setup export templates
        run: |
          mkdir -p ~/.local/share/godot/export_templates/
          mv /root/.local/share/godot/export_templates/${GODOT_VERSION}.stable \
             ~/.local/share/godot/export_templates/${GODOT_VERSION}.stable

      - name: Import assets
        run: godot --headless --editor --quit --path ${{ env.PROJECT_PATH }}

      - name: Export Windows
        run: |
          mkdir -p build/windows
          godot --headless --verbose --export-release "Windows Desktop" \
            build/windows/${{ env.EXPORT_NAME }}.exe

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: windows
          path: build/windows/

      - name: Deploy to itch.io
        if: startsWith(github.ref, 'refs/tags/v')
        uses: manleydev/butler-publish-itchio-action@master
        env:
          BUTLER_CREDENTIALS: ${{ secrets.BUTLER_CREDENTIALS }}
          CHANNEL: windows
          ITCH_GAME: destiny-tales-of-natalia
          ITCH_USER: ITCH_USER
          PACKAGE: build/windows

  export-macos:
    name: macOS Export
    runs-on: ubuntu-latest
    container:
      image: barichello/godot-ci:4.4.1
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          lfs: true

      - name: Setup export templates
        run: |
          mkdir -p ~/.local/share/godot/export_templates/
          mv /root/.local/share/godot/export_templates/${GODOT_VERSION}.stable \
             ~/.local/share/godot/export_templates/${GODOT_VERSION}.stable

      - name: Import assets
        run: godot --headless --editor --quit --path ${{ env.PROJECT_PATH }}

      - name: Export macOS
        run: |
          mkdir -p build/mac
          godot --headless --verbose --export-release "macOS" \
            build/mac/${{ env.EXPORT_NAME }}.zip

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: macos
          path: build/mac/

      - name: Deploy to itch.io
        if: startsWith(github.ref, 'refs/tags/v')
        uses: manleydev/butler-publish-itchio-action@master
        env:
          BUTLER_CREDENTIALS: ${{ secrets.BUTLER_CREDENTIALS }}
          CHANNEL: osx
          ITCH_GAME: destiny-tales-of-natalia
          ITCH_USER: ITCH_USER
          PACKAGE: build/mac
```

**Notas de implementação:**
- O passo "Import assets" (`godot --headless --editor --quit`) resolve o Pitfall 2 do RESEARCH.md
- `lfs: true` no checkout é D-17 — nunca omitir
- `BUTLER_CREDENTIALS` é uma API key do itch.io (itch.io/user/settings/api-keys), não senha
- Substituir `ITCH_USER` quando a página itch.io for criada

---

### `scenes/main.tscn` (scene Godot, request-response)

**Analog:** nenhum — arquivo novo
**Fonte do padrão:** RESEARCH.md Pattern 5 + decisão D-13

**Método de criação (preferido):** Criar via editor Godot (Scene > New Scene), adicionar Node2D como raiz, renomear para "Main", adicionar Label filho com o texto abaixo. Salvar em `scenes/main.tscn`. O editor gera o UID correto automaticamente.

**Padrão de referência (o editor gera com UID real):**

```
; scenes/main.tscn
[gd_scene load_steps=1 format=3 uid="uid://XXXXXXXXXXXXXXX"]

[node name="Main" type="Node2D"]

[node name="Label" type="Label" parent="."]
text = "v0.0 — Destiny: Tales of Natalia"
```

**Notas de implementação:**
- O UID (`uid://...`) é gerado automaticamente pelo editor — não inventar manualmente
- Esta cena é referenciada em `project.godot` como `run/main_scene="res://scenes/main.tscn"`
- O texto "v0.0" estabelece o padrão de build versioning visual para todas as fases seguintes
- Não adicionar scripts à cena de teste — Phase 0 não tem código GDScript (D-09)

---

### `serve.py` (utility, request-response)

**Analog:** nenhum — arquivo novo
**Fonte do padrão:** RESEARCH.md Pitfall 3 (solução opção B)

**Conteúdo completo a ser criado:**

```python
#!/usr/bin/env python3
"""
serve.py — Servidor HTTP local com CORS headers para testar web export do Godot.

SharedArrayBuffer requer Cross-Origin-Opener-Policy e Cross-Origin-Embedder-Policy.
http.server padrão do Python não envia esses headers — este script adiciona.

Uso:
    cd export/web
    python3 /Users/renatojaf/jogo-natalia/serve.py
    # Acessar: http://localhost:8000

    # Porta customizada:
    python3 serve.py 9000
"""

from http.server import HTTPServer, SimpleHTTPRequestHandler, test
import sys


class CORSRequestHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        SimpleHTTPRequestHandler.end_headers(self)


if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8000
    test(CORSRequestHandler, HTTPServer, port=port)
```

**Notas de implementação:**
- Rodar de dentro da pasta `export/web/` (onde o `index.html` gerado pelo export está)
- Alternativa mais simples (D-12): exportar com "Use Threads" desativado no preset Web — nesse caso `python3 -m http.server 8000` funciona sem CORS headers
- Verificar: se o console do browser mostrar `ReferenceError: SharedArrayBuffer is not defined`, usar este script

---

### Estrutura de Pastas (apenas diretórios)

**Analog:** nenhum
**Fonte do padrão:** RESEARCH.md Estrutura de Pastas + decisão D-08

**Pastas a criar (todas vazias):**

```
jogo-natalia/
├── .github/
│   └── workflows/
├── scenes/
├── assets/
│   ├── sprites/
│   │   ├── player/
│   │   ├── enemies/
│   │   └── ui/
│   └── audio/
│       ├── sfx/
│       └── music/
├── scripts/
├── autoloads/          # D-09: vazio — scripts entram na Phase 2
└── export/             # Ignorado pelo .gitignore — apenas para export local
```

**Notas de implementação:**
- Git não versiona pastas vazias — adicionar `.gitkeep` em cada pasta que deve ser commitada vazia
- `export/` NÃO precisa de `.gitkeep` pois está no `.gitignore`
- `autoloads/` precisa de `.gitkeep` para manter a convenção de estrutura

**Comando para criar todas as pastas de uma vez:**

```bash
cd /Users/renatojaf/jogo-natalia
mkdir -p scenes assets/sprites/player assets/sprites/enemies assets/sprites/ui
mkdir -p assets/audio/sfx assets/audio/music scripts autoloads export
mkdir -p .github/workflows
touch scenes/.gitkeep assets/sprites/player/.gitkeep assets/sprites/enemies/.gitkeep
touch assets/sprites/ui/.gitkeep assets/audio/sfx/.gitkeep assets/audio/music/.gitkeep
touch scripts/.gitkeep autoloads/.gitkeep
```

---

## Shared Patterns

### Padrão: Pixel Art — configurações obrigatórias (D-05)

**Aplica a:** `project.godot`
**Fonte:** RESEARCH.md Pattern 1 + CLAUDE.md

As quatro configurações abaixo devem coexistir no `project.godot` para pixel art correto:

| Setting | Chave INI | Valor | Efeito |
|---------|-----------|-------|--------|
| Renderer | `rendering/renderer/rendering_method` | `"gl_compatibility"` | Habilita web export |
| Texture filter | `textures/canvas_textures/default_texture_filter` | `0` (Nearest) | Sem blur em sprites |
| Stretch mode | `window/stretch/mode` | `"canvas_items"` | Escala limpa |
| Scale mode | `window/stretch/scale_mode` | `"integer"` | Somente múltiplos inteiros |
| Snap transforms | `2d/snap/snap_2d_transforms_to_pixel` | `true` | Sem jitter de câmera |

### Padrão: CI/CD — `lfs: true` obrigatório (D-17)

**Aplica a:** `.github/workflows/export.yml` (todos os jobs)
**Fonte:** RESEARCH.md Pitfall "Esquecer lfs: true"

Todo step de `actions/checkout@v4` no workflow DEVE incluir:

```yaml
- uses: actions/checkout@v4
  with:
    lfs: true
```

Sem isso, assets `.png`, `.wav`, `.ogg` chegam ao CI como ponteiros LFS de 130 bytes. O export gera um jogo sem sprites ou áudio e falha silenciosamente.

### Padrão: Deploy condicional em tags (D-14)

**Aplica a:** Todos os steps de deploy no `export.yml`
**Fonte:** RESEARCH.md Pattern 4 + decisão D-14

```yaml
- name: Deploy to itch.io
  if: startsWith(github.ref, 'refs/tags/v')
  # ... resto do step
```

Sem esta condição `if`, o deploy roda em todo PR — publicando builds incompletas no itch.io.

### Padrão: Comando de export correto (D-18)

**Aplica a:** Todos os steps de export no `export.yml`
**Fonte:** RESEARCH.md State of the Art + decisão D-18

```bash
# CORRETO (Godot 4):
godot --headless --verbose --export-release "Web" build/web/index.html

# INCORRETO (alias não explícito, evitar):
godot --export "Web" build/web/index.html
```

### Padrão: Credenciais como secrets (D-16)

**Aplica a:** `.github/workflows/export.yml`
**Fonte:** RESEARCH.md Security Domain

```yaml
# CORRETO:
BUTLER_CREDENTIALS: ${{ secrets.BUTLER_CREDENTIALS }}

# NUNCA:
BUTLER_CREDENTIALS: "abc123minha-api-key"  # hardcoded — nunca fazer
```

`BUTLER_CREDENTIALS` é uma API key do itch.io (itch.io/user/settings/api-keys), não a senha da conta.

---

## No Analog Found (todos os arquivos desta fase)

Todos os 8 arquivos desta fase não têm análogo no codebase — o repositório está vazio.

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `project.godot` | config | transform | Primeiro arquivo Godot do projeto |
| `.gitattributes` | config | transform | Primeiro repositório sem LFS configurado |
| `.gitignore` | config | transform | Nenhum .gitignore existe ainda |
| `export_presets.cfg` | config | transform | Primeiro preset de export |
| `.github/workflows/export.yml` | config CI/CD | event-driven | Nenhum workflow CI existe |
| `scenes/main.tscn` | scene | request-response | Primeira cena Godot |
| `serve.py` | utility | request-response | Nenhum utilitário existe |
| Estrutura de pastas | — | — | Repositório vazio |

**Estratégia para o planner:** Usar os padrões documentados acima (derivados do RESEARCH.md e fontes verificadas) como especificações diretas de implementação. Os padrões são completos e concretos — o planner pode referenciar este arquivo para cada task sem buscar análogos adicionais.

---

## Metadata

**Analog search scope:** `/Users/renatojaf/jogo-natalia/` (exceto `.git/` e `.planning/`)
**Files scanned:** 2 (apenas `CLAUDE.md` e `.DS_Store` existem fora das pastas de sistema)
**Pattern extraction date:** 2026-05-20
**Godot version locked:** 4.4.1 (paridade com `barichello/godot-ci:4.4.1`)
**Sources primárias:** RESEARCH.md Pattern 1-5, CONTEXT.md D-01 a D-18, CLAUDE.md stack section
