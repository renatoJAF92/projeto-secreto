#!/usr/bin/env python3
"""
generate_sprites.py — Pipeline offline Python/Pillow para gerar sprite sheet e portraits.

Processa fotos reais de Natalia e Renato para criar assets pixel art usados no jogo.
Gera:
  - assets/sprites/natalia_spritesheet.png  (192x32, 6 frames x 32x32)
  - assets/sprites/portraits/natalia_portrait.png  (64x80, busto JRPG)
  - assets/sprites/portraits/renato_portrait.png   (64x80, busto JRPG)

Uso:
    python3 scripts/generate_sprites.py

Executar a partir da raiz do projeto (/Users/renatojaf/jogo-natalia).
"""

from PIL import Image
import os
import sys

PHOTOS_DIR = "Photos"
OUTPUT_DIR = "assets/sprites"


def photo_to_pixel_art(img_path: str, target_size: tuple, palette_colors: int = 16) -> Image.Image:
    """Redimensiona foto para pixel art com paleta limitada.

    Args:
        img_path: Caminho para a foto de entrada (JPG/JPEG).
        target_size: Tupla (largura, altura) do resultado.
        palette_colors: Numero de cores na paleta (padrao 16).

    Returns:
        Imagem quantizada convertida para RGB.
    """
    try:
        img = Image.open(img_path).convert("RGB")
    except FileNotFoundError as e:
        print(f"ERRO: nao foi possivel abrir a foto '{img_path}': {e}", file=sys.stderr)
        sys.exit(1)
    except OSError as e:
        print(f"ERRO: nao foi possivel abrir a foto '{img_path}': {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"ERRO: nao foi possivel abrir a foto '{img_path}': {e}", file=sys.stderr)
        sys.exit(1)

    small = img.resize(target_size, Image.LANCZOS)
    quantized = small.quantize(colors=palette_colors, method=Image.Quantize.MEDIANCUT)
    return quantized.convert("RGB")


def generate_natalia_spritesheet(photo_path: str) -> None:
    """Gera sprite sheet 192x32 (6 frames x 32x32) a partir de foto real.

    Todas as 6 animacoes (idle, run, jump, fall, hurt, death) usam o mesmo
    frame base nesta fase - placeholder funcional. Animacoes frame-a-frame
    ficam para a Phase 3 (ver RESEARCH.md Open Question 2).

    Usando o MESMO frame quantizado em todos os 6 slots evita flickering
    de paleta entre frames (Pitfall 6 do RESEARCH.md).

    Args:
        photo_path: Caminho para a foto da Natalia.
    """
    try:
        img = Image.open(photo_path).convert("RGB")
    except FileNotFoundError as e:
        print(f"ERRO: nao foi possivel abrir a foto '{photo_path}': {e}", file=sys.stderr)
        sys.exit(1)
    except OSError as e:
        print(f"ERRO: nao foi possivel abrir a foto '{photo_path}': {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"ERRO: nao foi possivel abrir a foto '{photo_path}': {e}", file=sys.stderr)
        sys.exit(1)

    w, h = img.size

    # Crop corpo inteiro: centralizado, proporcao slim
    crop_h = int(h * 0.85)
    crop_w = int(crop_h * 0.5)
    left = (w - crop_w) // 2
    body = img.crop((left, int(h * 0.02), left + crop_w, int(h * 0.02) + crop_h))

    # Resize para 32x32 e quantizar
    sprite = body.resize((32, 32), Image.LANCZOS)
    quantized_frame = sprite.quantize(colors=16, method=Image.Quantize.MEDIANCUT).convert("RGBA")

    # 6 frames: idle(0), run(1), jump(2), fall(3), hurt(4), death(5)
    # Mesmo frame quantizado em todos os slots para evitar flickering de paleta
    frames = ["idle", "run", "jump", "fall", "hurt", "death"]
    sheet = Image.new("RGBA", (32 * len(frames), 32), (0, 0, 0, 0))
    for i in range(len(frames)):
        sheet.paste(quantized_frame, (i * 32, 0))

    output_path = os.path.join(OUTPUT_DIR, "natalia_spritesheet.png")
    sheet.save(output_path)
    print(f"Sprite sheet gerado: {output_path} ({sheet.size[0]}x{sheet.size[1]})")


def generate_portrait(photo_path: str, output_name: str) -> None:
    """Gera portrait 64x80 (busto JRPG) a partir de foto real.

    Args:
        photo_path: Caminho para a foto de entrada.
        output_name: Nome do arquivo de saida (sem extensao), salvo em
                     assets/sprites/portraits/{output_name}.png
    """
    try:
        img = Image.open(photo_path).convert("RGB")
    except FileNotFoundError as e:
        print(f"ERRO: nao foi possivel abrir a foto '{photo_path}': {e}", file=sys.stderr)
        sys.exit(1)
    except OSError as e:
        print(f"ERRO: nao foi possivel abrir a foto '{photo_path}': {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"ERRO: nao foi possivel abrir a foto '{photo_path}': {e}", file=sys.stderr)
        sys.exit(1)

    w, h = img.size

    # Crop busto: cabeca + ombros (55% superior da foto)
    crop_h = int(h * 0.55)
    crop_w = min(w, int(crop_h * 0.8))
    left = (w - crop_w) // 2
    bust = img.crop((left, 0, left + crop_w, crop_h))

    portrait = bust.resize((64, 80), Image.LANCZOS)
    quantized = portrait.quantize(colors=16, method=Image.Quantize.MEDIANCUT).convert("RGBA")

    output_path = os.path.join(OUTPUT_DIR, "portraits", f"{output_name}.png")
    quantized.save(output_path)
    print(f"Portrait gerado: {output_path} ({quantized.size[0]}x{quantized.size[1]})")


if __name__ == '__main__':
    # Criar diretorios de saida se nao existirem
    os.makedirs(os.path.join(OUTPUT_DIR, "portraits"), exist_ok=True)

    # Gerar sprite sheet da Natalia
    generate_natalia_spritesheet(
        os.path.join(PHOTOS_DIR, "Natalia", "IMG_20260222_212225.jpg")
    )

    # Gerar portrait da Natalia
    generate_portrait(
        os.path.join(PHOTOS_DIR, "Natalia", "IMG_20260222_212225.jpg"),
        "natalia_portrait"
    )

    # Gerar portrait do Renato
    generate_portrait(
        os.path.join(PHOTOS_DIR, "Renato", "WhatsApp Image 2026-01-29 at 14.52.08.jpeg"),
        "renato_portrait"
    )
