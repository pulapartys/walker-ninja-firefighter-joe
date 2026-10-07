"""Character-sheet images from the in-game state images (written by Claude Code).

Uses exactly what the game draws: godot/art/character/<state>.png at the game's 0.5 scale,
placed by anchors.json, with the 20x40 collision box from player.gd.

    python3 tools/make_sheet_extras.py      # needs Pillow, numpy

Outputs (design/character/):
  silhouette.png          every state, solid black, 1x game size (64 px tall idle), on plain light gray
  silhouette-x4.png       the same, enlarged 4x (nearest neighbour) to inspect
  collision.png           every state with the 20x40 box drawn at the same scale, enlarged 4x
  palette.png             the 5 palette colors with contrast against the backdrop and the flames
Also writes evidence/screens-web/*.jpg: the in-engine screenshots, shrunk for the repo.
"""
import glob
import json
import os

import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART = os.path.join(HERE, "godot", "art", "character")
OUT = os.path.join(HERE, "design", "character")
BOX = (20, 40)          # player.gd BOX
ZOOM = 4
ORDER = ["idle", "run", "jump_crouch", "rising", "falling", "landing", "hose",
         "grab", "toss", "burned", "respawn", "celebrate"]
PALETTE = [("suit red", "be1a16"), ("suit shadow", "77110c"), ("helmet yellow", "f1bc27"),
           ("outline / mask", "0e0a08"), ("gear brown", "705340")]
# Backdrop colours sampled in his play band of ENV-BG v2 (darkest / typical / lightest, 2026-10-07).
AGAINST = [("backdrop dark", "4e5b71"), ("backdrop mid", "798aa2"), ("backdrop light", "dbd3cd"),
           ("flame red", "d0341a"), ("flame orange", "f39a1e"), ("flame core", "ffe95a"),
           ("ledge", "b8b2a6"), ("building wall", "e0cdaf")]


def lum(hexc):
    c = [int(hexc[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    c = [x / 12.92 if x <= 0.03928 else ((x + 0.055) / 1.055) ** 2.4 for x in c]
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]


def contrast(a, b):
    la, lb = sorted([lum(a), lum(b)], reverse=True)
    return (la + 0.05) / (lb + 0.05)


def game_size(state, anchors):
    """The state image at in-game scale, and the origin (feet / box bottom-center) inside it."""
    im = Image.open(os.path.join(ART, state + ".png"))
    small = im.resize((round(im.width / 2), round(im.height / 2)), Image.LANCZOS)
    ax, ay = anchors[state]
    return small, (ax / 2, ay / 2)


def strip(anchors, silhouette, box):
    pad, base_y, cell = 8, 76, []
    for s in ORDER:
        small, (ox, oy) = game_size(s, anchors)
        cell.append((s, small, ox, oy))
    width = sum(max(c[1].width, BOX[0] + 4) + pad for c in cell) + pad
    out = Image.new("RGB", (width, base_y + 16), "#f6f3ec")
    d = ImageDraw.Draw(out)
    x = pad
    for s, small, ox, oy in cell:
        px, py = round(x + ox), base_y           # origin of this state on the shared baseline
        top_left = (round(px - ox), round(py - oy))
        if silhouette:
            mask = small.getchannel("A").point(lambda v: 255 if v > 128 else 0)
            out.paste(Image.new("RGB", small.size, (0, 0, 0)), top_left, mask)
        else:
            out.paste(small, top_left, small)
        if box:
            d.rectangle([px - BOX[0] // 2, py - BOX[1], px + BOX[0] // 2 - 1, py - 1], outline=(0, 230, 255))
        x += max(small.width, BOX[0] + 4) + pad
    return out


def labelled(img, names):
    big = img.resize((img.width * ZOOM, img.height * ZOOM), Image.NEAREST)
    canvas = Image.new("RGB", (big.width, big.height + 22), "white")
    canvas.paste(big, (0, 0))
    d = ImageDraw.Draw(canvas)
    d.text((6, big.height + 5), "  ·  ".join(names), fill="black")
    return canvas


def main():
    anchors = json.load(open(os.path.join(ART, "anchors.json")))["anchors"]
    sil = strip(anchors, True, False)   # plain background: the test is about shape
    sil.save(os.path.join(OUT, "silhouette.png"))
    labelled(sil, ORDER).save(os.path.join(OUT, "silhouette-x4.png"))
    col = strip(anchors, False, True)
    labelled(col, ORDER).save(os.path.join(OUT, "collision.png"))

    sw, rows = 120, []
    pal = Image.new("RGB", (sw * len(PALETTE), 60 + 18 * len(AGAINST)), "white")
    d = ImageDraw.Draw(pal)
    for i, (name, hx) in enumerate(PALETTE):
        d.rectangle([i * sw, 0, (i + 1) * sw - 4, 40], fill="#" + hx)
        d.text((i * sw + 2, 44), f"{name} #{hx}", fill="black")
        for j, (oname, ohx) in enumerate(AGAINST):
            cr = contrast(hx, ohx)
            d.text((i * sw + 2, 60 + 18 * j), f"{oname[:13]}: {cr:.1f}", fill="black" if cr >= 1.5 else "red")
            rows.append((name, hx, oname, ohx, cr))
    pal.save(os.path.join(OUT, "palette.png"))
    for name, hx, oname, ohx, cr in rows:
        print(f"{name:15s} #{hx} vs {oname:13s} #{ohx}: {cr:4.1f}")

    shots = sorted(glob.glob(os.path.join(HERE, "evidence", "screens", "*.png")))
    web = os.path.join(HERE, "evidence", "screens-web")
    os.makedirs(web, exist_ok=True)
    for f in shots:
        Image.open(f).convert("RGB").save(os.path.join(web, os.path.basename(f)[:-4] + ".jpg"), quality=85)
    print(len(shots), "screenshots ->", web)


if __name__ == "__main__":
    main()
