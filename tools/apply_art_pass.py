#!/usr/bin/env python3
"""
Art pass: substitui placeholders por assets craftpix processados.
  - Girl_2 (128×128) → assets/sprites/natalia/ (64×64, flip=direita)
  - City 4 (576×324) → assets/backgrounds/world1/ (320×180)
  - Asfalto tileset → sobrescreve placeholder_tiles.png (48×16)
  - Reescreve player.tscn com sprites Girl_2
  - Atualiza parallax de fase1_rua.tscn
"""
from PIL import Image, ImageDraw
import os, textwrap

ROOT = "/Users/renatojaf/jogo-natalia"
SRC  = f"{ROOT}/sprites_examples"
AST  = f"{ROOT}/assets"

# ── 1. PROCESSAR GIRL_2 ────────────────────────────────────────────────────
def process_natalia():
    girl2 = f"{SRC}/craftpix-net-242415-free-schoolgirls-anime-character-pixel-sprite-pack/Girl_2"
    dst   = f"{AST}/sprites/natalia"
    os.makedirs(dst, exist_ok=True)

    # Mapa: arquivo fonte → nome destino, nº de frames esperados
    anims = {
        "Idle.png":       "idle.png",
        "Walk.png":       "run.png",
        "Protection.png": "protect.png",
        "Attack.png":     "attack.png",
    }
    sizes = {}
    for src_name, dst_name in anims.items():
        src_path = os.path.join(girl2, src_name)
        if not os.path.exists(src_path):
            print(f"  SKIP (não encontrado): {src_name}")
            continue
        img = Image.open(src_path).convert("RGBA")
        w, h = img.size
        # 2× downscale (128→64), preserva qualidade pixel art
        scaled = img.resize((w // 2, h // 2), Image.NEAREST)
        # Vira para a direita (Girl_2 olha para a esquerda por padrão)
        flipped = scaled.transpose(Image.FLIP_LEFT_RIGHT)
        out_path = os.path.join(dst, dst_name)
        flipped.save(out_path)
        frame_h = h // 2  # 64
        n_frames = (w // 2) // frame_h
        sizes[dst_name] = (w // 2, frame_h, n_frames)
        print(f"  ✓ natalia/{dst_name}: {flipped.size}  ({n_frames} frames @ {frame_h}px)")
    return sizes

# ── 2. PROCESSAR BACKGROUNDS CITY 4 ───────────────────────────────────────
def process_backgrounds():
    city4 = f"{SRC}/craftpix-net-322807-free-city-backgrounds-pixel-art/city 4"
    dst   = f"{AST}/backgrounds/world1"
    os.makedirs(dst, exist_ok=True)

    layers = [
        ("1.png", "sky.png"),
        ("2.png", "bg_far.png"),
        ("3.png", "bg_mid1.png"),
        ("4.png", "bg_mid2.png"),
        ("5.png", "bg_near.png"),
        ("7.png", "fg_street.png"),
    ]
    for src_file, dst_file in layers:
        src_path = os.path.join(city4, src_file)
        if not os.path.exists(src_path):
            print(f"  SKIP: {src_file}")
            continue
        img = Image.open(src_path).convert("RGBA")
        # 576×324 → 320×180 (mesma proporção 16:9, downscale ÷1.8)
        scaled = img.resize((320, 180), Image.NEAREST)
        out_path = os.path.join(dst, dst_file)
        scaled.save(out_path)
        print(f"  ✓ world1/{dst_file}: {scaled.size}")

# ── 3. TILESET ASFALTO ─────────────────────────────────────────────────────
def make_asphalt_tileset():
    """Cria tileset 48×16 (3 tiles 16×16) com textura de asfalto."""
    img = Image.new("RGBA", (48, 16), (0, 0, 0, 0))
    px  = img.load()

    # Paleta
    ASPH  = (45, 38, 38, 255)   # asfalto base
    ASPH2 = (55, 46, 46, 255)   # asfalto claro
    ASPH3 = (35, 28, 28, 255)   # asfalto escuro
    CRACK = (22, 16, 16, 255)   # rachadura
    LINE  = (200, 170, 50, 255) # faixa amarela

    def fill_tile(ox, pattern=None):
        import random
        rng = random.Random(ox)
        for y in range(16):
            for x in range(16):
                base = ASPH if rng.random() > 0.3 else (ASPH2 if rng.random() > 0.5 else ASPH3)
                px[ox + x, y] = base

    fill_tile(0)   # tile 0: asfalto liso
    fill_tile(16)  # tile 1: asfalto variante
    fill_tile(32)  # tile 2: asfalto com detalhe

    # Rachadura no tile 0
    for y in range(3, 13):
        px[0 + 7, y] = CRACK
    for y in range(6, 10):
        px[0 + 8, y] = CRACK
        px[0 + 6, y] = CRACK

    # Faixa amarela central no tile 1 (simula centro da rua)
    for y in range(6, 10):
        px[16 + 7, y] = LINE
        px[16 + 8, y] = LINE

    # Mancha escura no tile 2
    for y in range(4, 12):
        for x in range(5, 11):
            px[32 + x, y] = ASPH3

    out = f"{AST}/placeholder_tiles.png"
    img.save(out)
    print(f"  ✓ placeholder_tiles.png: {img.size} (asfalto)")

# ── 4. GERAR player.tscn ──────────────────────────────────────────────────
def make_player_tscn(natalia_sizes):
    idle_frames    = natalia_sizes.get("idle.png",    (448,  64, 7))[2]
    run_frames     = natalia_sizes.get("run.png",     (768,  64, 12))[2]
    protect_frames = natalia_sizes.get("protect.png", (128,  64, 2))[2]

    FRAME = 64  # px por frame

    lines = []
    n_sub = (idle_frames + run_frames + 2  # protect_0 e protect_1
             + 1  # RectangleShape2D
             + 1) # SpriteFrames
    load_steps = 4 + n_sub  # 3 textures + 1 script

    lines.append(f'[gd_scene load_steps={load_steps} format=3 uid="uid://b3kp7mjpv8n4"]')
    lines.append('')
    lines.append('[ext_resource type="Script" uid="uid://csfl12g5ata86" path="res://scenes/player/player.gd" id="1_player"]')
    lines.append('[ext_resource type="Texture2D" path="res://assets/sprites/natalia/idle.png" id="2_idle"]')
    lines.append('[ext_resource type="Texture2D" path="res://assets/sprites/natalia/run.png" id="3_run"]')
    lines.append('[ext_resource type="Texture2D" path="res://assets/sprites/natalia/protect.png" id="4_protect"]')
    lines.append('')

    # AtlasTextures para idle
    for i in range(idle_frames):
        lines.append(f'[sub_resource type="AtlasTexture" id="AT_idle_{i}"]')
        lines.append(f'atlas = ExtResource("2_idle")')
        lines.append(f'region = Rect2({i * FRAME}, 0, {FRAME}, {FRAME})')
        lines.append('')

    # AtlasTextures para run
    for i in range(run_frames):
        lines.append(f'[sub_resource type="AtlasTexture" id="AT_run_{i}"]')
        lines.append(f'atlas = ExtResource("3_run")')
        lines.append(f'region = Rect2({i * FRAME}, 0, {FRAME}, {FRAME})')
        lines.append('')

    # AtlasTextures para protect (2 frames; compartilhado entre jump/fall/hurt/death)
    for i in range(min(2, protect_frames)):
        lines.append(f'[sub_resource type="AtlasTexture" id="AT_prot_{i}"]')
        lines.append(f'atlas = ExtResource("4_protect")')
        lines.append(f'region = Rect2({i * FRAME}, 0, {FRAME}, {FRAME})')
        lines.append('')

    # CollisionShape
    lines.append('[sub_resource type="RectangleShape2D" id="RectangleShape2D_1"]')
    lines.append('size = Vector2(20, 52)')
    lines.append('')

    # Monta lista de frames para cada animação
    def frame_list(prefix, n):
        parts = []
        for i in range(n):
            parts.append(f'{{"duration": 1.0, "texture": SubResource("AT_{prefix}_{i}")}}')
        return ', '.join(parts)

    idle_list    = frame_list("idle", idle_frames)
    run_list     = frame_list("run",  run_frames)
    prot0 = 'SubResource("AT_prot_0")'
    prot1 = 'SubResource("AT_prot_1")' if protect_frames >= 2 else prot0

    lines.append('[sub_resource type="SpriteFrames" id="SpriteFrames_1"]')
    lines.append('animations = [{')
    lines.append(f'"frames": [{idle_list}],')
    lines.append('"loop": true,')
    lines.append('"name": &"idle",')
    lines.append('"speed": 8.0')
    lines.append('}, {')
    lines.append(f'"frames": [{run_list}],')
    lines.append('"loop": true,')
    lines.append('"name": &"run",')
    lines.append('"speed": 12.0')
    lines.append('}, {')
    lines.append(f'"frames": [{{"duration": 1.0, "texture": {prot0}}}],')
    lines.append('"loop": false,')
    lines.append('"name": &"jump",')
    lines.append('"speed": 5.0')
    lines.append('}, {')
    lines.append(f'"frames": [{{"duration": 1.0, "texture": {prot1}}}],')
    lines.append('"loop": false,')
    lines.append('"name": &"fall",')
    lines.append('"speed": 5.0')
    lines.append('}, {')
    lines.append(f'"frames": [{{"duration": 1.0, "texture": {prot0}}}, {{"duration": 1.0, "texture": {prot1}}}],')
    lines.append('"loop": false,')
    lines.append('"name": &"hurt",')
    lines.append('"speed": 8.0')
    lines.append('}, {')
    lines.append(f'"frames": [{{"duration": 1.0, "texture": {prot0}}}, {{"duration": 1.0, "texture": {prot1}}}],')
    lines.append('"loop": false,')
    lines.append('"name": &"death",')
    lines.append('"speed": 5.0')
    lines.append('}]')
    lines.append('')

    # Nodes
    lines += [
        '[node name="Player" type="CharacterBody2D" groups=["player"]]',
        'script = ExtResource("1_player")',
        '',
        '[node name="AnimatedSprite2D" type="AnimatedSprite2D" parent="."]',
        'sprite_frames = SubResource("SpriteFrames_1")',
        'animation = &"idle"',
        'autoplay = "idle"',
        '',
        '[node name="CollisionShape2D" type="CollisionShape2D" parent="."]',
        'shape = SubResource("RectangleShape2D_1")',
        '',
        '[node name="DustParticles" type="CPUParticles2D" parent="."]',
        'position = Vector2(0, 26)',
        'emitting = false',
        'lifetime = 0.3',
        'one_shot = true',
        'direction = Vector2(0, -1)',
        'spread = 80.0',
        'gravity = Vector2(0, 200)',
        'initial_velocity_min = 30.0',
        'initial_velocity_max = 80.0',
        'scale_amount_min = 2.0',
        'scale_amount_max = 2.0',
        'color = Color(0.7, 0.65, 0.55, 1)',
        '',
        '[node name="Camera2D" type="Camera2D" parent="."]',
        'enabled = true',
        'zoom = Vector2(1, 1)',
        'limit_left = 0',
        'limit_right = 6400',
        'limit_top = -500',
        'limit_bottom = 200',
        'drag_horizontal_enabled = true',
        'drag_horizontal_offset = 0.1',
        'position_smoothing_enabled = true',
        'position_smoothing_speed = 5.0',
        '',
        '[connection signal="animation_finished" from="AnimatedSprite2D" to="." method="_on_animated_sprite_2d_animation_finished"]',
    ]

    out = f"{ROOT}/scenes/player/player.tscn"
    with open(out, "w") as f:
        f.write('\n'.join(lines) + '\n')
    print(f"  ✓ player.tscn reescrito ({len(lines)} linhas, {idle_frames}+{run_frames}+2 frames)")

# ── 5. ATUALIZAR PARALLAX DE fase1_rua.tscn ───────────────────────────────
def update_fase1_parallax():
    scene_path = f"{ROOT}/scenes/world1/fase1_rua.tscn"
    with open(scene_path) as f:
        content = f.read()

    # Adiciona ext_resources para os backgrounds (antes da primeira linha [sub_resource])
    new_ext = (
        '[ext_resource type="Texture2D" path="res://assets/backgrounds/world1/sky.png" id="bg_sky"]\n'
        '[ext_resource type="Texture2D" path="res://assets/backgrounds/world1/bg_far.png" id="bg_far"]\n'
        '[ext_resource type="Texture2D" path="res://assets/backgrounds/world1/bg_mid1.png" id="bg_mid1"]\n'
        '[ext_resource type="Texture2D" path="res://assets/backgrounds/world1/bg_mid2.png" id="bg_mid2"]\n'
        '[ext_resource type="Texture2D" path="res://assets/backgrounds/world1/bg_near.png" id="bg_near"]\n'
        '[ext_resource type="Texture2D" path="res://assets/backgrounds/world1/fg_street.png" id="bg_street"]\n'
    )
    content = content.replace(
        '[sub_resource type="RectangleShape2D" id="RectangleShape2D_floor"]',
        new_ext + '[sub_resource type="RectangleShape2D" id="RectangleShape2D_floor"]'
    )

    # Substitui o bloco ParallaxBackground atual (ColorRects + Poles + Background)
    # pelo novo com imagens reais
    old_parallax_start = '[node name="ParallaxBackground" type="ParallaxBackground" parent="."]'
    old_background_end = '[node name="TileMapLayer"'

    new_parallax = (
        '[node name="ParallaxBackground" type="ParallaxBackground" parent="."]\n'
        'z_index = -10\n'
        '\n'
        '[node name="LayerSky" type="ParallaxLayer" parent="ParallaxBackground"]\n'
        'motion_scale = Vector2(0, 0)\n'
        'motion_mirroring = Vector2(320, 0)\n'
        '\n'
        '[node name="SkySprite" type="Sprite2D" parent="ParallaxBackground/LayerSky"]\n'
        'texture = ExtResource("bg_sky")\n'
        'centered = false\n'
        'position = Vector2(0, 0)\n'
        '\n'
        '[node name="LayerFar" type="ParallaxLayer" parent="ParallaxBackground"]\n'
        'motion_scale = Vector2(0.05, 0)\n'
        'motion_mirroring = Vector2(320, 0)\n'
        '\n'
        '[node name="FarSprite" type="Sprite2D" parent="ParallaxBackground/LayerFar"]\n'
        'texture = ExtResource("bg_far")\n'
        'centered = false\n'
        'position = Vector2(0, 0)\n'
        '\n'
        '[node name="LayerMid1" type="ParallaxLayer" parent="ParallaxBackground"]\n'
        'motion_scale = Vector2(0.15, 0)\n'
        'motion_mirroring = Vector2(320, 0)\n'
        '\n'
        '[node name="Mid1Sprite" type="Sprite2D" parent="ParallaxBackground/LayerMid1"]\n'
        'texture = ExtResource("bg_mid1")\n'
        'centered = false\n'
        'position = Vector2(0, 0)\n'
        '\n'
        '[node name="LayerMid2" type="ParallaxLayer" parent="ParallaxBackground"]\n'
        'motion_scale = Vector2(0.3, 0)\n'
        'motion_mirroring = Vector2(320, 0)\n'
        '\n'
        '[node name="Mid2Sprite" type="Sprite2D" parent="ParallaxBackground/LayerMid2"]\n'
        'texture = ExtResource("bg_mid2")\n'
        'centered = false\n'
        'position = Vector2(0, 0)\n'
        '\n'
        '[node name="LayerNear" type="ParallaxLayer" parent="ParallaxBackground"]\n'
        'motion_scale = Vector2(0.5, 0)\n'
        'motion_mirroring = Vector2(320, 0)\n'
        '\n'
        '[node name="NearSprite" type="Sprite2D" parent="ParallaxBackground/LayerNear"]\n'
        'texture = ExtResource("bg_near")\n'
        'centered = false\n'
        'position = Vector2(0, 0)\n'
        '\n'
        '[node name="LayerStreet" type="ParallaxLayer" parent="ParallaxBackground"]\n'
        'motion_scale = Vector2(0.7, 0)\n'
        'motion_mirroring = Vector2(320, 0)\n'
        '\n'
        '[node name="StreetSprite" type="Sprite2D" parent="ParallaxBackground/LayerStreet"]\n'
        'texture = ExtResource("bg_street")\n'
        'centered = false\n'
        'position = Vector2(0, 0)\n'
        '\n'
    )

    # Encontra e remove o bloco antigo (ParallaxBackground + Background ColorRect)
    import re
    # Remove tudo entre [node name="ParallaxBackground" ...] e [node name="TileMapLayer"
    # Inclui o Background ColorRect que vem antes de TileMapLayer
    pattern = re.compile(
        r'\[node name="ParallaxBackground".*?\n(?=\[node name="TileMapLayer")',
        re.DOTALL
    )
    # Também remove o Background ColorRect que está fora do parallax
    background_rect = re.compile(
        r'\[node name="Background" type="ColorRect".*?\n\n',
        re.DOTALL
    )

    content = pattern.sub(new_parallax, content)
    content = background_rect.sub('', content)

    # Atualiza load_steps no header
    def update_load_steps(text):
        import re
        m = re.search(r'load_steps=(\d+)', text)
        if m:
            old = int(m.group(1))
            # Adicionamos 6 ext_resources novos, removemos ~0 (parallax com ColorRects não tinha)
            new_val = old + 6
            text = text.replace(f'load_steps={old}', f'load_steps={new_val}')
        return text

    content = update_load_steps(content)

    with open(scene_path, 'w') as f:
        f.write(content)
    print(f"  ✓ fase1_rua.tscn: parallax atualizado com city4")

# ── MAIN ───────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("\n=== Art Pass: processando assets ===\n")

    print("1. Natália sprites (Girl_2 → 64px):")
    sizes = process_natalia()

    print("\n2. Backgrounds (city4 → 320×180):")
    process_backgrounds()

    print("\n3. Tileset asfalto:")
    make_asphalt_tileset()

    print("\n4. player.tscn:")
    make_player_tscn(sizes)

    print("\n5. fase1_rua.tscn parallax:")
    update_fase1_parallax()

    print("\n=== Concluído! Recarregue o projeto no Godot. ===\n")
