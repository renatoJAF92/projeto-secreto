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

from PIL import Image, ImageEnhance, ImageFilter
import os
import sys

PHOTOS_DIR = "Photos"
OUTPUT_DIR = "assets/sprites"

# Source photos — chosen for best frontal angle and face visibility.
NATALIA_PHOTO = "Photos/Natalia/IMG-20260527-WA0015.jpg"   # mirror selfie, frontal view
RENATO_PHOTO  = "Photos/Renato/WhatsApp Image 2026-01-29 at 14.52.18.jpeg"  # close frontal

# Crop parameters — (y_start_fraction, y_end_fraction, x_start_fraction, x_end_fraction)
# Verified visually against preview crops (2304x4096).
NATALIA_BUST_CROP = (0.15, 0.60, 0.05, 0.75)   # face centered, hair+glasses+smile
NATALIA_BODY_CROP = (0.12, 0.88, 0.03, 0.90)    # full visible body for sprite
RENATO_BUST_CROP  = (0.25, 0.62, 0.15, 0.85)    # face centered, avoids sky


def _pixel_art_resize(img: Image.Image, target_size: tuple) -> Image.Image:
    """Convert to JRPG pixel art look.

    Pipeline: contrast boost → LANCZOS downscale → 16-color quantize.
    Uses LANCZOS throughout for smooth SNES/GBA portrait style (not chunky NEAREST).
    """
    img = img.convert("RGB")

    # Moderate contrast boost so face features survive downscale
    img = ImageEnhance.Contrast(img).enhance(1.3)
    img = ImageEnhance.Color(img).enhance(1.2)

    # Single LANCZOS resize — smooth, portrait-style
    img = img.resize(target_size, Image.LANCZOS)

    # 16-color quantize → RGBA
    img = img.quantize(colors=16, method=Image.Quantize.MEDIANCUT).convert("RGBA")
    return img


def _open_photo(path: str) -> Image.Image:
    try:
        return Image.open(path).convert("RGB")
    except FileNotFoundError as e:
        print(f"ERRO: nao foi possivel abrir a foto '{path}': {e}", file=sys.stderr)
        sys.exit(1)
    except OSError as e:
        print(f"ERRO: nao foi possivel abrir a foto '{path}': {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"ERRO: nao foi possivel abrir a foto '{path}': {e}", file=sys.stderr)
        sys.exit(1)


def _crop(img: Image.Image, fractions: tuple) -> Image.Image:
    """Crop image by fractions (y0, y1, x0, x1) of total dimensions."""
    w, h = img.size
    y0, y1, x0, x1 = fractions
    return img.crop((int(w * x0), int(h * y0), int(w * x1), int(h * y1)))


def generate_natalia_spritesheet(photo_path: str) -> None:
    """Gera sprite sheet 192x32 (6 frames x 32x32) a partir de foto real.

    Todas as 6 animacoes usam o mesmo frame base como placeholder funcional.
    Animacoes frame-a-frame ficam para a Phase 3 (RESEARCH.md Open Question 2).
    Mesmo frame em todos os slots evita flickering de paleta (Pitfall 6).
    """
    img = _open_photo(photo_path)
    body = _crop(img, NATALIA_BODY_CROP)

    frame = _pixel_art_resize(body, (32, 32))

    frames = ["idle", "run", "jump", "fall", "hurt", "death"]
    sheet = Image.new("RGBA", (32 * len(frames), 32), (0, 0, 0, 0))
    for i in range(len(frames)):
        sheet.paste(frame, (i * 32, 0))

    output_path = os.path.join(OUTPUT_DIR, "natalia_spritesheet.png")
    sheet.save(output_path)
    print(f"Sprite sheet gerado: {output_path} ({sheet.size[0]}x{sheet.size[1]})")


def generate_portrait(photo_path: str, output_name: str, crop_fractions: tuple) -> None:
    """Gera portrait 64x80 (busto JRPG) a partir de foto real.

    Args:
        photo_path: Caminho para a foto de entrada.
        output_name: Nome do arquivo de saida (sem extensao).
        crop_fractions: (y0, y1, x0, x1) fractions for the bust region.
    """
    img = _open_photo(photo_path)
    bust = _crop(img, crop_fractions)

    portrait = _pixel_art_resize(bust, (64, 80))

    output_path = os.path.join(OUTPUT_DIR, "portraits", f"{output_name}.png")
    portrait.save(output_path)
    print(f"Portrait gerado: {output_path} ({portrait.size[0]}x{portrait.size[1]})")


if __name__ == '__main__':
    os.makedirs(os.path.join(OUTPUT_DIR, "portraits"), exist_ok=True)

    generate_natalia_spritesheet(NATALIA_PHOTO)
    generate_portrait(NATALIA_PHOTO, "natalia_portrait", NATALIA_BUST_CROP)
    generate_portrait(RENATO_PHOTO,  "renato_portrait",  RENATO_BUST_CROP)
