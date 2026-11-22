#!/usr/bin/env python3
"""Packs Joe's 12 in-game pose images into one sprite sheet (CHANGE-BRIEF "The sheet").

Each pose from godot/art/character/<pose>.png is pasted whole and unscaled into its own cell, so
that its anchor (the bottom centre of the collision box, from anchors.json) lands on one shared
cell point. That keeps his feet in place whenever the frame changes. Cell order is anchors.json
order. Run from the repository root: python3 tools/make_joe_sheet.py
"""
import json
import math
from pathlib import Path

from PIL import Image

ART = Path("godot/art/character")
OUT = ART / "joe_sheet.png"
COLUMNS = 4
PAD = 4  # transparent pixels kept between every pose and its cell edge (linear-filter bleed)
# The numbers CHANGE-BRIEF.md states; the script stops if the poses no longer produce them.
BRIEF_CELL = (142, 145)
BRIEF_ANCHOR = (70, 133)
BRIEF_GRID = (4, 3)


def main() -> None:
    """Writes joe_sheet.png and prints the cell table.

    Raises SystemExit when the computed cell size, anchor or grid differs from the brief, or when
    a pose would come closer than PAD pixels to its cell edge.
    """
    anchors = json.loads((ART / "anchors.json").read_text())["anchors"]
    poses = []
    for name, (ax, ay) in anchors.items():
        image = Image.open(ART / f"{name}.png").convert("RGBA")
        poses.append((name, image, ax, ay))
    left = math.ceil(max(ax for _, _, ax, _ in poses))
    right = math.ceil(max(im.width - ax for _, im, ax, _ in poses))
    top = math.ceil(max(ay for _, _, _, ay in poses))
    below = math.ceil(max(im.height - ay for _, im, _, ay in poses))
    cell = (PAD + left + right + PAD, PAD + top + below + PAD)
    anchor = (PAD + left, PAD + top)
    grid = (COLUMNS, math.ceil(len(poses) / COLUMNS))
    if (cell, anchor, grid) != (BRIEF_CELL, BRIEF_ANCHOR, BRIEF_GRID):
        raise SystemExit(f"sheet geometry {cell} {anchor} {grid} differs from the brief "
                         f"{BRIEF_CELL} {BRIEF_ANCHOR} {BRIEF_GRID}; update CHANGE-BRIEF.md first")
    sheet = Image.new("RGBA", (cell[0] * grid[0], cell[1] * grid[1]), (0, 0, 0, 0))
    for index, (name, image, ax, ay) in enumerate(poses):
        cx, cy = (index % COLUMNS) * cell[0], (index // COLUMNS) * cell[1]
        ox, oy = round(anchor[0] - ax), round(anchor[1] - ay)
        if ox < PAD or oy < PAD or ox + image.width > cell[0] - PAD or oy + image.height > cell[1] - PAD:
            raise SystemExit(f"{name} would come closer than {PAD} px to its cell edge")
        sheet.alpha_composite(image, (cx + ox, cy + oy))
        print(f"cell {index:2d} {name:12s} pasted at ({ox}, {oy}); anchor error "
              f"({ox + ax - anchor[0]:+.2f}, {oy + ay - anchor[1]:+.2f}) px")
    sheet.save(OUT)
    print(f"wrote {OUT}: {sheet.width} x {sheet.height}, cells {cell[0]} x {cell[1]}, "
          f"grid {grid[0]} x {grid[1]}, anchor {anchor}")


if __name__ == "__main__":
    main()
