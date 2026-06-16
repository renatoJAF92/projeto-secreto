#!/usr/bin/env python3
"""Generates menu_background.png (320x180 pixel art cityscape) and menu_theme.wav (simple melody).
Run from the project root: python3 tools/gen_menu_assets.py
"""
import struct, math, os, random, io, wave

# ---------------------------------------------------------------------------
# menu_background.png — night cityscape pixel art
# ---------------------------------------------------------------------------

def write_png(path, width, height, pixels):
    import zlib
    def u32(n): return struct.pack('>I', n)
    def chunk(tag, data):
        c = zlib.crc32(tag + data) & 0xFFFFFFFF
        return u32(len(data)) + tag + data + u32(c)
    raw = b''
    for row in pixels:
        raw += b'\x00' + bytes(row)
    compressed = zlib.compress(raw, 9)
    ihdr = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
    with open(path, 'wb') as f:
        f.write(b'\x89PNG\r\n\x1a\n')
        f.write(chunk(b'IHDR', ihdr))
        f.write(chunk(b'IDAT', compressed))
        f.write(chunk(b'IEND', b''))

W, H = 320, 180
rng = random.Random(42)

pixels = []
for y in range(H):
    row = []
    t = y / H
    r = int(10 * (1-t) + 20 * t)
    g = int(10 * (1-t) + 20 * t)
    b = int(35 * (1-t) + 60 * t)
    for x in range(W):
        row.extend([r, g, b])
    pixels.append(row)

# Stars
for _ in range(100):
    sx, sy = rng.randint(0, W-1), rng.randint(0, H//2 - 10)
    bright = rng.randint(150, 255)
    pixels[sy][sx*3:sx*3+3] = [bright, bright, min(255, bright + 40)]

def draw_rect(x0, y0, x1, y1, color):
    for y in range(y0, y1):
        for x in range(x0, x1):
            if 0 <= x < W and 0 <= y < H:
                pixels[y][x*3:x*3+3] = list(color)

def draw_building(bx, bw, bh, color, win_on, win_off):
    by = H - bh
    draw_rect(bx, by, bx + bw, H, color)
    for wy in range(by + 4, H - 4, 7):
        for wx in range(bx + 3, bx + bw - 3, 5):
            wc = win_on if rng.random() > 0.35 else win_off
            if 0 <= wx < W and 0 <= wy < H:
                pixels[wy][wx*3:wx*3+3] = list(wc)

BLDG_FAR  = (18, 18, 48)
BLDG_MID  = (28, 28, 70)
BLDG_NEAR = (12, 12, 32)
WIN_ON    = (255, 220, 100)
WIN_OFF   = (20, 20, 52)
WIN_BLUE  = (100, 160, 255)

# Far layer
for i in range(9):
    bx = i * 36 + rng.randint(-4, 4)
    bw = rng.randint(26, 38)
    bh = rng.randint(65, 110)
    draw_building(bx, bw, bh, BLDG_FAR, WIN_ON, WIN_OFF)

# Mid layer
for i in range(6):
    bx = i * 54 + rng.randint(0, 8)
    bw = rng.randint(38, 54)
    bh = rng.randint(40, 85)
    draw_building(bx, bw, bh, BLDG_MID, WIN_BLUE, WIN_OFF)

# Near silhouette
for i in range(4):
    bx = i * 82 + rng.randint(-8, 8)
    bw = rng.randint(62, 76)
    bh = rng.randint(22, 42)
    draw_rect(bx, H - bh, bx + bw, H, BLDG_NEAR)

# Ground strip
draw_rect(0, H - 8, W, H, (10, 10, 25))

# Moon
moon_x, moon_y = 270, 20
for dy in range(-6, 7):
    for dx in range(-6, 7):
        if dx*dx + dy*dy <= 36:
            px, py = moon_x + dx, moon_y + dy
            if 0 <= px < W and 0 <= py < H:
                pixels[py][px*3:px*3+3] = [240, 240, 200]

os.makedirs('assets/sprites/ui', exist_ok=True)
write_png('assets/sprites/ui/menu_background.png', W, H, pixels)
print("Generated assets/sprites/ui/menu_background.png")

# ---------------------------------------------------------------------------
# menu_theme.wav — simple pentatonic melody
# ---------------------------------------------------------------------------

SAMPLE_RATE = 44100
DURATION = 30  # seconds

BPM = 108
BEAT = 60.0 / BPM

# (beat_offset, duration_beats, freq_hz)
NOTES = [
    (0.0, 0.5, 523.25), (0.5, 0.5, 587.33), (1.0, 0.5, 659.25), (1.5, 0.5, 783.99),
    (2.0, 1.0, 880.00), (3.0, 0.5, 783.99), (3.5, 0.5, 659.25),
    (4.0, 0.5, 587.33), (4.5, 0.5, 523.25), (5.0, 1.5, 440.00),
    (6.5, 0.5, 523.25), (7.0, 0.5, 659.25), (7.5, 0.5, 783.99),
    (8.0, 0.5, 880.00), (8.5, 0.5, 1046.5), (9.0, 1.0, 880.00),
    (10.0, 0.5, 783.99), (10.5, 0.5, 659.25), (11.0, 2.0, 523.25),
]

samples = [0.0] * (SAMPLE_RATE * DURATION)

def add_note(buf, start_sec, dur_sec, freq, amp=0.22):
    s0 = int(start_sec * SAMPLE_RATE)
    s1 = int((start_sec + dur_sec) * SAMPLE_RATE)
    atk = int(0.015 * SAMPLE_RATE)
    rel = int(0.06 * SAMPLE_RATE)
    length = s1 - s0
    for i in range(length):
        t = i / SAMPLE_RATE
        env = 1.0
        if i < atk:
            env = i / atk
        elif i > length - rel:
            env = (length - i) / rel
        idx = s0 + i
        if idx < len(buf):
            buf[idx] += amp * env * (
                math.sin(2 * math.pi * freq * t) +
                0.3 * math.sin(4 * math.pi * freq * t) +
                0.1 * math.sin(6 * math.pi * freq * t)
            )

phrase_beats = 13.0
repeats = int(DURATION / (phrase_beats * BEAT)) + 1
for rep in range(repeats):
    off = rep * phrase_beats * BEAT
    for (b, d, f) in NOTES:
        add_note(samples, off + b * BEAT, d * BEAT, f)

# Normalize
peak = max(abs(s) for s in samples) or 1.0
pcm = bytearray()
for s in samples:
    v = max(-32768, min(32767, int(s / peak * 28000)))
    pcm += struct.pack('<h', v)

os.makedirs('assets/audio/music', exist_ok=True)
wav_path = 'assets/audio/music/menu_theme.wav'
with wave.open(wav_path, 'wb') as wf:
    wf.setnchannels(1)
    wf.setsampwidth(2)
    wf.setframerate(SAMPLE_RATE)
    wf.writeframes(bytes(pcm))
print(f"Generated {wav_path}")

# Try converting to OGG with ffmpeg
import subprocess
ogg_path = 'assets/audio/music/menu_theme.ogg'
try:
    result = subprocess.run(
        ['ffmpeg', '-y', '-i', wav_path, '-c:a', 'libvorbis', '-q:a', '4', ogg_path],
        capture_output=True, timeout=30
    )
    if result.returncode == 0:
        print(f"Converted to {ogg_path}")
    else:
        print(f"ffmpeg failed — using .wav directly (reference menu_theme.wav in main_menu.gd)")
except (FileNotFoundError, subprocess.TimeoutExpired):
    print("ffmpeg not found — using .wav directly (reference menu_theme.wav in main_menu.gd)")
