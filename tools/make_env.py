"""Environment art for the game from the accepted generations (written by Claude Code).

ENV-BG:   resized with macOS sips to 1280x720 (see SOURCES.md); not handled here.
ENV-FIRE: three flame images generated on a flat green background. This removes the green
          (chroma key with a soft edge and green spill removal), crops to the flames, and
          scales them down for the game.

    python3 tools/make_env.py "<ENV-FIRE-A.png>" "<ENV-FIRE-B.png>" "<ENV-FIRE-Bb.png>"
    # needs Pillow, numpy

Outputs: godot/art/env/fire_single.png (A), fire_wide.png (B), fire_tall.png (Bb)
"""
import os
import sys

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(HERE, "godot", "art", "env")
TARGET_H = {"fire_single": 96, "fire_wide": 64, "fire_tall": 128}   # texture px; drawn much smaller


def key_out_green(path):
    a = np.asarray(Image.open(path).convert("RGB")).astype(float)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    greenness = g - np.maximum(r, b)              # ~240 on the background, <= 0 on the flames
    alpha = np.clip((120.0 - greenness) / 80.0, 0.0, 1.0)   # soft edge between 40 and 120
    g2 = np.minimum(g, np.maximum(r, b))          # spill removal: no pixel greener than red/blue
    rgba = np.dstack([r, g2, b, alpha * 255]).astype(np.uint8)
    im = Image.fromarray(rgba, "RGBA")
    return im.crop(im.getchannel("A").point(lambda v: 255 if v > 40 else 0).getbbox())


def main():
    os.makedirs(OUT, exist_ok=True)
    for name, src in zip(["fire_single", "fire_wide", "fire_tall"], sys.argv[1:4]):
        im = key_out_green(src)
        h = TARGET_H[name]
        im = im.resize((round(im.width * h / im.height), h), Image.LANCZOS)
        im.save(os.path.join(OUT, name + ".png"))
        print(f"{name}: {im.size} from {os.path.basename(src)!r}")


if __name__ == "__main__":
    main()
