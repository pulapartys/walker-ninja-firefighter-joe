"""Turn the accepted pose images into in-game state images (written by Claude Code).

For each pose: remove the flat cream background, scale every pose by ONE factor
(so the idle is TEX_H px tall), and record the anchor: the pixel that sits on the
player's origin (the bottom-center of the collision box).

    python3 tools/make_sprites.py          # needs Pillow, numpy, scipy

Inputs:  design/character/side-profile-game.png, design/character/poses/*.png
Outputs: godot/art/character/<state>.png and godot/art/character/anchors.json
"""
import json
import os

import numpy as np
from PIL import Image
from scipy import ndimage

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(HERE, "godot", "art", "character")
TEX_H = 128          # idle height in texture px; drawn at 0.5 scale = 64 px in the 640x360 game
TOL, SOFT, MIN_HOLE = 14, 40, 600   # background color tolerance, soft-edge range, enclosed-gap size
BOX_H_TEX = 80       # collision box height (40 game px) in texture px, for airborne anchors

STATES = {           # game state -> accepted pose image
    "idle": "side-profile-game.png",
    "respawn": "poses/pose01-respawn.png",
    "run": "poses/pose02-run.png",
    "jump_crouch": "poses/pose03-jump-crouch.png",
    "rising": "poses/pose04-rising.png",
    "falling": "poses/pose05-falling.png",
    "landing": "poses/pose06-landing.png",
    "hose": "poses/pose07-hose.png",
    "grab": "poses/pose08-grab.png",
    "toss": "poses/pose09-toss.png",
    "burned": "poses/pose11-burned.png",
    "celebrate": "poses/pose12-celebrate.png",
}
AIRBORNE = {"rising", "falling"}   # no feet on the ground: center the box on the body


def cut_out(path):
    """RGBA image with the border-connected cream background (and big enclosed gaps) made transparent."""
    a = np.asarray(Image.open(path).convert("RGB")).astype(int)
    bg = np.median(np.concatenate([a[:4].reshape(-1, 3), a[-4:].reshape(-1, 3)]), axis=0)
    d = np.abs(a - bg).max(axis=2)
    near = d < TOL
    lab, n = ndimage.label(near)
    border = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
    sizes = ndimage.sum(near, lab, range(n + 1))
    is_bg = np.isin(lab, list(border)) | ((sizes[lab] > MIN_HOLE) & (d < 8) & (lab > 0))
    edge = ndimage.binary_dilation(is_bg, iterations=2) & ~is_bg
    alpha = np.full(d.shape, 255.0)
    alpha[is_bg] = 0
    alpha[edge] = np.clip((d[edge] - TOL) / (SOFT - TOL), 0, 1) * 255
    im = Image.fromarray(np.dstack([a, alpha]).astype(np.uint8), "RGBA")
    return im.crop(im.getchannel("A").point(lambda v: 255 if v > 40 else 0).getbbox())


def main():
    os.makedirs(OUT, exist_ok=True)
    src = os.path.join(HERE, "design", "character")
    cut = {s: cut_out(os.path.join(src, f)) for s, f in STATES.items()}
    k = TEX_H / cut["idle"].height            # one scale for every pose keeps proportions identical
    anchors = {}
    for state, im in cut.items():
        im = im.resize((max(1, round(im.width * k)), max(1, round(im.height * k))), Image.LANCZOS)
        im.save(os.path.join(OUT, state + ".png"))
        solid = np.asarray(im.getchannel("A")) > 128
        top = int(solid.shape[0] * 0.4)
        _, xs = np.nonzero(solid[top:])         # lower 60% = legs and torso, not the headband tails
        ax = float(xs.mean())
        if state in AIRBORNE:
            ys, _ = np.nonzero(solid)
            ay = float(ys.mean()) + BOX_H_TEX / 2
        else:
            ay = float(np.nonzero(solid.any(axis=1))[0].max() + 1)   # feet
        anchors[state] = [round(ax, 1), round(ay, 1)]
        print(f"{state:12s} {im.width:4d}x{im.height:<4d} anchor {anchors[state]}")
    with open(os.path.join(OUT, "anchors.json"), "w") as f:
        json.dump({"tex_h": TEX_H, "scale": 0.5, "anchors": anchors}, f, indent=1)


if __name__ == "__main__":
    main()
