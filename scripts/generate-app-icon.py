#!/usr/bin/env python3
"""Generate the TinyKeyboard 1024×1024 App Store icon.

Spec: Plans/app-icon-spec.md
- Opaque 1024×1024 PNG (no alpha), sRGB
- No rounded corners baked in
- Minimal 3-row keyboard silhouette in the lower two-thirds
- Rows fade into the deep-indigo background by the top third
"""

from __future__ import annotations

import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageChops

SIZE = 1024
SUPERSAMPLE = 2
CANVAS = SIZE * SUPERSAMPLE

# Deep indigo (graphite-indigo, not pure black)
BG_TOP = (16, 16, 34)
BG_BOT = (32, 34, 58)
KEY_FILL = (214, 226, 244)
KEY_HI = (232, 240, 252)

# Fade: full key color at the bottom edge, gone by the top third of the frame
FADE_FULL_Y = 0.92  # below this, keys are fully visible
FADE_GONE_Y = 1.0 / 3.0  # top third — fully background


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def background(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size))
    px = img.load()
    cx = cy = size / 2.0
    for y in range(size):
        t = y / (size - 1)
        base = (
            lerp(BG_TOP[0], BG_BOT[0], t),
            lerp(BG_TOP[1], BG_BOT[1], t),
            lerp(BG_TOP[2], BG_BOT[2], t),
        )
        for x in range(size):
            dx = (x - cx) / cx
            dy = (y - cy) / cy
            vignette = 1.0 - 0.16 * (dx * dx + dy * dy)
            px[x, y] = (
                int(base[0] * vignette),
                int(base[1] * vignette),
                int(base[2] * vignette),
            )
    return img


def rounded_key(
    draw: ImageDraw.ImageDraw,
    box: tuple[float, float, float, float],
    radius: float,
    fill: tuple[int, int, int, int],
) -> None:
    draw.rounded_rectangle(box, radius=radius, fill=fill)


def keyboard_layer(size: int) -> Image.Image:
    """Draw the abstracted 3-row keyboard into an RGBA layer."""
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)

    # Keyboard occupies the lower two-thirds, inset from the sides.
    left = int(size * 0.14)
    right = int(size * 0.86)
    width = right - left
    key_h = int(size * 0.078)
    gap = int(size * 0.016)
    radius = int(size * 0.016)
    # Bottom of the lowest row sits near the bottom edge (with a small margin).
    bottom = int(size * 0.90)
    row3_y = bottom - key_h
    row2_y = row3_y - gap - key_h
    row1_y = row2_y - gap - key_h

    def equal_row(n: int, y: int, inset: float = 0.0) -> list[tuple[float, float, float, float]]:
        inner_left = left + inset
        inner_right = right - inset
        usable = inner_right - inner_left
        total_gap = gap * (n - 1)
        w = (usable - total_gap) / n
        boxes = []
        x = inner_left
        for _ in range(n):
            boxes.append((x, y, x + w, y + key_h))
            x += w + gap
        return boxes

    # Row 1: 10 keys. Row 2: 9 keys, slightly inset (keyboard stagger).
    row1 = equal_row(10, row1_y)
    row2 = equal_row(9, row2_y, inset=size * 0.035)

    # Row 3: modifier, wide spacebar, modifier — reads as a keyboard at 60pt.
    side = width * 0.16
    space_gap = gap
    r3_left = (left, row3_y, left + side, row3_y + key_h)
    r3_right = (right - side, row3_y, right, row3_y + key_h)
    r3_space = (left + side + space_gap, row3_y, right - side - space_gap, row3_y + key_h)
    row3 = [r3_left, r3_space, r3_right]

    fill = (*KEY_FILL, 255)
    for box in row1 + row2 + row3:
        rounded_key(draw, box, radius=radius, fill=fill)

    return layer


def fade_mask(size: int) -> Image.Image:
    """Vertical dissolve: opaque at the bottom, gone by the top third."""
    full = FADE_FULL_Y * (size - 1)
    gone = FADE_GONE_Y * (size - 1)
    # Build a 1-pixel-wide gradient and resize — smoother than per-row Python.
    col = Image.new("L", (1, size))
    cp = col.load()
    for y in range(size):
        if y >= full:
            a = 255
        elif y <= gone:
            a = 0
        else:
            t = (y - gone) / (full - gone)
            # Smoothstep so the dissolve doesn't look like a hard wipe.
            t = t * t * (3 - 2 * t)
            a = int(255 * t)
        cp[0, y] = a
    return col.resize((size, size), Image.Resampling.BILINEAR)


def main() -> None:
    repo = Path(__file__).resolve().parents[1]
    out_dir = repo / "TinyKeyboard" / "Assets.xcassets" / "AppIcon.appiconset"
    out_path = out_dir / "AppIcon.png"
    srgb_path = Path("/System/Library/ColorSync/Profiles/sRGB Profile.icc")

    bg = background(CANVAS)
    keys = keyboard_layer(CANVAS)
    # Soften key edges slightly before the dissolve so small-size rendering stays clean.
    keys = keys.filter(ImageFilter.GaussianBlur(radius=SUPERSAMPLE * 0.4))
    mask = fade_mask(CANVAS)
    # Apply dissolve to the keyboard's own alpha.
    key_a = keys.split()[-1]
    faded_a = ImageChops.multiply(key_a, mask)
    keys.putalpha(faded_a)
    composed = bg.convert("RGBA")
    composed.alpha_composite(keys)
    composed = composed.resize((SIZE, SIZE), Image.Resampling.LANCZOS)

    rgb = composed.convert("RGB")
    if srgb_path.exists():
        profile = srgb_path.read_bytes()
        rgb.save(out_path, "PNG", icc_profile=profile, optimize=True)
    else:
        rgb.save(out_path, "PNG", optimize=True)

    # Guardrails: size, mode, no alpha.
    saved = Image.open(out_path)
    assert saved.size == (SIZE, SIZE), saved.size
    assert saved.mode == "RGB", saved.mode
    extrema = saved.getextrema()
    print(f"wrote {out_path}")
    print(f"  size={saved.size} mode={saved.mode} extrema={extrema}")
    print(f"  bytes={out_path.stat().st_size}")


if __name__ == "__main__":
    os.chdir(Path(__file__).resolve().parents[1])
    main()
