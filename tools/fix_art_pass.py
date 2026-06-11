#!/usr/bin/env python3
"""
Fix art pass completo:
1. Natalia - flip frame-por-frame (corrige "anda de costas" causado por flip de sheet inteira)
2. Inimigos - sprites reais (Graffiti_Artist_1/2/3 para malandro/resistente/coraza)
3. Plataforma movel - sprite de tabua de madeira
4. Prova item - sprite de documento
5. Checkpoint - sprite de bandeira/poste
6. Atualiza .tscn de inimigos, plataforma e itens com SpriteFrames inline
"""
from PIL import Image, ImageDraw
import os

ROOT = "/Users/renatojaf/jogo-natalia"
SRC  = f"{ROOT}/sprites_examples"
AST  = f"{ROOT}/assets"

# ── UTIL: flip cada frame individualmente (preserva ordem de animacao) ────────
def flip_frames(src_path, frame_size, dst_path, out_frame_size=None):
    """
    Carrega spritesheet, flipa cada frame horizontalmente (preserva ordem),
    redimensiona se out_frame_size != frame_size, salva.
    """
    img = Image.open(src_path).convert("RGBA")
    w, h = img.size
    if h != frame_size:
        raise ValueError(f"Altura {h} != frame_size {frame_size} em {src_path}")
    n_frames = w // frame_size
    out_fs = out_frame_size or frame_size
    result = Image.new("RGBA", (n_frames * out_fs, out_fs))
    for i in range(n_frames):
        frame = img.crop((i * frame_size, 0, (i + 1) * frame_size, frame_size))
        frame = frame.transpose(Image.FLIP_LEFT_RIGHT)
        if out_fs != frame_size:
            frame = frame.resize((out_fs, out_fs), Image.NEAREST)
        result.paste(frame, (i * out_fs, 0))
    result.save(dst_path)
    return n_frames


# ── 1. NATALIA - flip correto (frame por frame) ───────────────────────────────
def fix_natalia():
    girl2 = f"{SRC}/craftpix-net-242415-free-schoolgirls-anime-character-pixel-sprite-pack/Girl_2"
    dst   = f"{AST}/sprites/natalia"
    os.makedirs(dst, exist_ok=True)

    anims = [
        ("Idle.png",       "idle.png",    128, 64),
        ("Walk.png",       "run.png",     128, 64),
        ("Protection.png", "protect.png", 128, 64),
        ("Attack.png",     "attack.png",  128, 64),
    ]
    sizes = {}
    for src_name, dst_name, src_fs, out_fs in anims:
        src_path = os.path.join(girl2, src_name)
        if not os.path.exists(src_path):
            print(f"  SKIP: {src_name}")
            continue
        n = flip_frames(src_path, src_fs, os.path.join(dst, dst_name), out_fs)
        sizes[dst_name] = n
        print(f"  fix natalia/{dst_name}: {n} frames @ {out_fs}px (flip correto)")
    return sizes


# ── 2. INIMIGOS - sprites dos Graffiti Artists ────────────────────────────────
def make_enemy_sprites():
    ga_base = f"{SRC}/craftpix-net-404916-free-graffiti-artist-sprite-sheet-pixel-art-pack"
    dst     = f"{AST}/sprites/enemies"
    os.makedirs(dst, exist_ok=True)

    enemies = [
        ("Graffiti_Artist_1", "malandro"),
        ("Graffiti_Artist_2", "resistente"),
        ("Graffiti_Artist_3", "coraza"),
    ]
    sizes = {}
    for artist, name in enemies:
        artist_dir = f"{ga_base}/{artist}"
        for src_file, anim in [("Walk.png", "walk"), ("K.O..png", "death")]:
            src_path = os.path.join(artist_dir, src_file)
            if not os.path.exists(src_path):
                print(f"  SKIP: {artist}/{src_file}")
                continue
            dst_file = f"{name}_{anim}.png"
            dst_path = os.path.join(dst, dst_file)
            n = flip_frames(src_path, 256, dst_path, out_frame_size=32)
            sizes.setdefault(name, {})[anim] = n
            print(f"  enemies/{dst_file}: {n} frames @ 32px")
    return sizes


# ── 3. PLATAFORMA - tabua de madeira 48x10 ───────────────────────────────────
def make_platform_sprite():
    dst = f"{AST}/sprites/items"
    os.makedirs(dst, exist_ok=True)

    W, H = 48, 10
    img = Image.new("RGBA", (W, H))
    px  = img.load()

    # Paleta madeira
    TOP  = (180, 130, 70, 255)  # superficie clara
    MID  = (150, 100, 50, 255)  # corpo
    BOT  = (110,  75, 35, 255)  # fundo
    EDGE = ( 80,  55, 25, 255)  # borda
    GRAIN= (135,  90, 45, 255)  # grao

    for y in range(H):
        for x in range(W):
            if y == 0:
                c = TOP
            elif y == 1:
                c = TOP
            elif y == H-1:
                c = BOT
            elif x == 0 or x == W-1:
                c = EDGE
            else:
                c = MID

            # Graos horizontais (3 linhas de detalhe)
            if y in (3, 6) and x % 7 != 0 and x != 0 and x != W-1:
                c = GRAIN
            px[x, y] = c

    # Detalhes nas bordas laterais
    for y in range(2, H-1):
        px[0, y] = EDGE
        px[1, y] = (160, 115, 58, 255)
        px[W-2, y] = (160, 115, 58, 255)
        px[W-1, y] = EDGE

    out = f"{dst}/plataforma.png"
    img.save(out)
    print(f"  items/plataforma.png: {W}x{H}")


# ── 4. PROVA ITEM - documento 16x16 (2 frames para piscar) ───────────────────
def make_prova_sprite():
    dst = f"{AST}/sprites/items"
    os.makedirs(dst, exist_ok=True)

    FW, FH = 16, 16
    result = Image.new("RGBA", (FW * 2, FH))

    for frame_idx in range(2):
        frame = Image.new("RGBA", (FW, FH), (0, 0, 0, 0))
        px = frame.load()

        # Papel branco/amarelado com brilho diferente por frame
        if frame_idx == 0:
            PAPEL = (248, 240, 200, 255)
            BORD  = (160, 140,  80, 255)
            TEXT  = (100,  80,  40, 255)
            GLOW  = (255, 240, 100, 200)
        else:
            PAPEL = (255, 248, 220, 255)
            BORD  = (180, 160, 100, 255)
            TEXT  = (120, 100,  50, 255)
            GLOW  = (255, 220,  50, 200)

        # Fundo do papel (11x13 com margem de 2-3px)
        for y in range(2, 14):
            for x in range(2, 14):
                px[x, y] = PAPEL

        # Borda do papel
        for x in range(2, 14):
            px[x, 2]  = BORD
            px[x, 13] = BORD
        for y in range(2, 14):
            px[2, y]  = BORD
            px[13, y] = BORD

        # Dobra superior direita
        for i in range(3):
            px[13-i, 2+i] = BORD

        # Linhas de texto (3 linhas)
        for y in range(5, 12, 3):
            for x in range(4, 12):
                px[x, y] = TEXT

        # Glow ao redor
        for x in range(1, 15):
            px[x, 1]  = GLOW
            px[x, 14] = GLOW
        for y in range(1, 15):
            px[1, y]  = GLOW
            px[14, y] = GLOW

        result.paste(frame, (frame_idx * FW, 0))

    out = f"{dst}/prova_item.png"
    result.save(out)
    print(f"  items/prova_item.png: {FW*2}x{FH} (2 frames)")


# ── 5. CHECKPOINT - poste de bandeira 16x40 (1 frame) ────────────────────────
def make_checkpoint_sprite():
    dst = f"{AST}/sprites/items"
    os.makedirs(dst, exist_ok=True)

    W, H = 16, 40
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    px  = img.load()

    POSTE = (160, 160, 170, 255)
    POSTE2= (200, 200, 210, 255)
    POSTE3= (120, 120, 130, 255)
    FLAG1 = (230,  50,  50, 255)  # bandeira vermelho
    FLAG2 = (200,  30,  30, 255)
    TOPO  = (255, 210,  50, 255)  # estrela no topo

    # Poste (2px largo, altura toda)
    for y in range(H):
        px[7, y]  = POSTE3
        px[8, y]  = POSTE2
        px[9, y]  = POSTE

    # Estrela no topo (3x3)
    for x in range(7, 11):
        for y in range(0, 3):
            px[x, y] = TOPO

    # Bandeira (10x8 a partir do topo)
    for y in range(3, 11):
        for x in range(10, 16):
            c = FLAG1 if (x + y) % 2 == 0 else FLAG2
            px[x, y] = c

    # Base do poste
    for y in range(H-4, H):
        for x in range(5, 12):
            px[x, y] = POSTE3

    out = f"{dst}/checkpoint.png"
    img.save(out)
    print(f"  items/checkpoint.png: {W}x{H}")


# ── 6. GERAR TSCN DOS INIMIGOS (inline SpriteFrames, sem .tres externo) ──────
def make_enemy_tscn(name, script_class, uid, walk_frames, death_frames, extra_nodes=""):
    """
    Gera .tscn completo para inimigo com AnimatedSprite2D real.
    Remove Visual Polygon2D (substituida pelo sprite).
    """
    n_walk  = walk_frames
    n_death = death_frames
    FW = 32

    # Conta sub_resources:
    # AT_walk (n_walk) + AT_death (n_death) + CapsuleShape + Stomp + Body + SpriteFrames = n_walk+n_death+4
    n_sub = n_walk + n_death + 4
    n_ext = 3  # script + walk.png + death.png
    load_steps = n_ext + n_sub + 1

    lines = []
    lines.append(f'[gd_scene load_steps={load_steps} format=3 uid="{uid}"]')
    lines.append('')
    lines.append(f'[ext_resource type="Script" path="res://scenes/world1/{name}.gd" id="1"]')
    lines.append(f'[ext_resource type="Texture2D" path="res://assets/sprites/enemies/{name}_walk.png" id="2_walk"]')
    lines.append(f'[ext_resource type="Texture2D" path="res://assets/sprites/enemies/{name}_death.png" id="3_death"]')
    lines.append('')

    for i in range(n_walk):
        lines.append(f'[sub_resource type="AtlasTexture" id="AT_walk_{i}"]')
        lines.append(f'atlas = ExtResource("2_walk")')
        lines.append(f'region = Rect2({i * FW}, 0, {FW}, {FW})')
        lines.append('')

    for i in range(n_death):
        lines.append(f'[sub_resource type="AtlasTexture" id="AT_death_{i}"]')
        lines.append(f'atlas = ExtResource("3_death")')
        lines.append(f'region = Rect2({i * FW}, 0, {FW}, {FW})')
        lines.append('')

    lines.append('[sub_resource type="CapsuleShape2D" id="CapsuleShape2D_enemy"]')
    lines.append('radius = 6.0')
    lines.append('height = 22.0')
    lines.append('')
    lines.append('[sub_resource type="RectangleShape2D" id="RectangleShape2D_stomp"]')
    lines.append('size = Vector2(16, 4)')
    lines.append('')
    lines.append('[sub_resource type="RectangleShape2D" id="RectangleShape2D_body"]')
    lines.append('size = Vector2(14, 28)')
    lines.append('')

    # SpriteFrames
    def frame_list(prefix, n):
        return ', '.join(f'{{"duration": 1.0, "texture": SubResource("AT_{prefix}_{i}")}}' for i in range(n))

    lines.append('[sub_resource type="SpriteFrames" id="SpriteFrames_1"]')
    lines.append('animations = [{')
    lines.append(f'"frames": [{frame_list("walk", n_walk)}],')
    lines.append('"loop": true,')
    lines.append('"name": &"walk",')
    lines.append('"speed": 8.0')
    lines.append('}, {')
    lines.append(f'"frames": [{frame_list("death", n_death)}],')
    lines.append('"loop": false,')
    lines.append('"name": &"death",')
    lines.append('"speed": 8.0')
    lines.append('}]')
    lines.append('')

    # Nodes
    lines.append(f'[node name="{script_class}" type="CharacterBody2D" groups=["enemies"]]')
    lines.append('script = ExtResource("1")')
    lines.append('')
    lines.append('[node name="CollisionShape2D" type="CollisionShape2D" parent="."]')
    lines.append('shape = SubResource("CapsuleShape2D_enemy")')
    lines.append('')
    lines.append('[node name="AnimatedSprite2D" type="AnimatedSprite2D" parent="."]')
    lines.append('sprite_frames = SubResource("SpriteFrames_1")')
    lines.append('animation = &"walk"')
    lines.append('autoplay = "walk"')
    lines.append('')

    if extra_nodes:
        lines.append(extra_nodes)

    lines.append('[node name="StompZone" type="Area2D" parent="."]')
    lines.append('position = Vector2(0, -16)')
    lines.append('monitoring = true')
    lines.append('monitorable = false')
    lines.append('')
    lines.append('[node name="CollisionShape2D" type="CollisionShape2D" parent="StompZone"]')
    lines.append('shape = SubResource("RectangleShape2D_stomp")')
    lines.append('')
    lines.append('[node name="BodyHitbox" type="Area2D" parent="."]')
    lines.append('monitoring = true')
    lines.append('monitorable = false')
    lines.append('')
    lines.append('[node name="CollisionShape2D" type="CollisionShape2D" parent="BodyHitbox"]')
    lines.append('shape = SubResource("RectangleShape2D_body")')
    lines.append('')
    lines.append('[node name="EdgeRayCast" type="RayCast2D" parent="."]')
    lines.append('position = Vector2(10, 0)')
    lines.append('target_position = Vector2(0, 20)')

    return '\n'.join(lines) + '\n'


def update_enemy_scenes(enemy_sizes):
    scene_specs = [
        ("malandro",            "Malandro",           "uid://wj8twxy6wvmx", "malandro"),
        ("malandro_resistente", "MalandroResistente",  "uid://c4fwyj7vvqqq0", "resistente"),
        ("malandro_coraza",     "MalandroCoraza",      "uid://cv42m1ucdx7nx", "coraza"),
    ]

    for scene_name, node_name, uid, enemy_key in scene_specs:
        walk_n  = enemy_sizes.get(enemy_key, {}).get("walk",  10)
        death_n = enemy_sizes.get(enemy_key, {}).get("death",  9)
        content = make_enemy_tscn(scene_name, node_name, uid, walk_n, death_n)
        path = f"{ROOT}/scenes/world1/{scene_name}.tscn"
        with open(path, 'w') as f:
            f.write(content)
        print(f"  {scene_name}.tscn: {walk_n} walk + {death_n} death frames")


# ── 7. MOVING PLATFORM .tscn ─────────────────────────────────────────────────
def update_platform_tscn():
    content = '''[gd_scene load_steps=3 format=3 uid="uid://moving_platform"]

[ext_resource type="Script" path="res://scenes/shared/moving_platform.gd" id="1"]
[ext_resource type="Texture2D" path="res://assets/sprites/items/plataforma.png" id="2_tex"]

[sub_resource type="RectangleShape2D" id="RectangleShape2D_1"]
size = Vector2(40, 8)

[node name="MovingPlatform" type="AnimatableBody2D"]
script = ExtResource("1")
sync_to_physics = true

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("RectangleShape2D_1")

[node name="Sprite2D" type="Sprite2D" parent="."]
texture = ExtResource("2_tex")
centered = true
position = Vector2(0, 0)
'''
    path = f"{ROOT}/scenes/shared/moving_platform.tscn"
    with open(path, 'w') as f:
        f.write(content)
    print("  moving_platform.tscn: sprite de tabua adicionado")


# ── 8. PROVA_ITEM .tscn ───────────────────────────────────────────────────────
def update_prova_item_tscn():
    content = '''[gd_scene load_steps=7 format=3 uid="uid://c5ry6yf73"]

[ext_resource type="Script" path="res://scenes/world1/prova_item.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/sprites/items/prova_item.png" id="2_tex"]

[sub_resource type="AtlasTexture" id="AT_idle_0"]
atlas = ExtResource("2_tex")
region = Rect2(0, 0, 16, 16)

[sub_resource type="AtlasTexture" id="AT_idle_1"]
atlas = ExtResource("2_tex")
region = Rect2(16, 0, 16, 16)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_collision"]
size = Vector2(16, 16)

[sub_resource type="SpriteFrames" id="SpriteFrames_1"]
animations = [{
"frames": [{"duration": 1.0, "texture": SubResource("AT_idle_0")}, {"duration": 1.0, "texture": SubResource("AT_idle_1")}],
"loop": true,
"name": &"idle",
"speed": 4.0
}]

[node name="ProvaItem" type="Area2D"]
monitoring = true
monitorable = false
script = ExtResource("1_script")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("RectangleShape2D_collision")

[node name="AnimatedSprite2D" type="AnimatedSprite2D" parent="."]
sprite_frames = SubResource("SpriteFrames_1")
animation = &"idle"
autoplay = "idle"

[node name="CPUParticles2D" type="CPUParticles2D" parent="."]
position = Vector2(0, 4)
emitting = false
amount = 6
lifetime = 1.2
one_shot = true
direction = Vector2(0, -1)
spread = 60.0
gravity = Vector2(0, 100)
initial_velocity_min = 20.0
initial_velocity_max = 50.0
scale_amount_min = 1.0
scale_amount_max = 2.0
color = Color(1.0, 0.9, 0.3, 1)
'''
    path = f"{ROOT}/scenes/world1/prova_item.tscn"
    with open(path, 'w') as f:
        f.write(content)
    print("  prova_item.tscn: sprite de documento adicionado")


# ── 9. CHECKPOINT .tscn ───────────────────────────────────────────────────────
def update_checkpoint_tscn():
    content = '''[gd_scene load_steps=5 format=3 uid="uid://dfcwyz8qpq"]

[ext_resource type="Script" path="res://scenes/world1/checkpoint.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/sprites/items/checkpoint.png" id="2_tex"]

[sub_resource type="AtlasTexture" id="AT_idle_0"]
atlas = ExtResource("2_tex")
region = Rect2(0, 0, 16, 40)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_collision"]
size = Vector2(24, 80)

[sub_resource type="SpriteFrames" id="SpriteFrames_1"]
animations = [{
"frames": [{"duration": 1.0, "texture": SubResource("AT_idle_0")}],
"loop": true,
"name": &"idle",
"speed": 5.0
}]

[node name="Checkpoint" type="Area2D"]
monitoring = true
monitorable = false
script = ExtResource("1_script")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("RectangleShape2D_collision")

[node name="AnimatedSprite2D" type="AnimatedSprite2D" parent="."]
sprite_frames = SubResource("SpriteFrames_1")
animation = &"idle"
autoplay = "idle"
position = Vector2(0, -20)
'''
    path = f"{ROOT}/scenes/world1/checkpoint.tscn"
    with open(path, 'w') as f:
        f.write(content)
    print("  checkpoint.tscn: sprite de bandeira adicionado")


# ── MAIN ──────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("\n=== Fix art pass ===\n")

    print("1. Natalia (flip frame-por-frame):")
    natalia_sizes = fix_natalia()

    print("\n2. Sprites dos inimigos (Graffiti Artists):")
    enemy_sizes = make_enemy_sprites()

    print("\n3. Sprite da plataforma:")
    make_platform_sprite()

    print("\n4. Sprite prova item:")
    make_prova_sprite()

    print("\n5. Sprite checkpoint:")
    make_checkpoint_sprite()

    print("\n6. .tscn dos inimigos:")
    update_enemy_scenes(enemy_sizes)

    print("\n7. moving_platform.tscn:")
    update_platform_tscn()

    print("\n8. prova_item.tscn:")
    update_prova_item_tscn()

    print("\n9. checkpoint.tscn:")
    update_checkpoint_tscn()

    print("\n=== Concluido! Recarregue o projeto no Godot. ===\n")
