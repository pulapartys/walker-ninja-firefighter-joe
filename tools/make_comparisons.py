"""Side-by-side evidence for TEST-REPORT.md (written by Claude Code).

    python3 tools/make_comparisons.py      # needs Pillow; run after godot/tests/capture_game.gd

Outputs (evidence/compare/):
  character-vs-sheet.jpg   each game state: the accepted character-sheet pose | the in-engine
                           screenshot cropped around the character, with the 20x40 collision box
                           drawn at the character's origin (cyan)
  storyboard-vs-slice.jpg  each storyboard panel | the in-engine screenshot of the same moment
"""
import json
import os

from PIL import Image, ImageDraw, ImageOps

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SHOTS = os.path.join(HERE, "evidence", "screens")
OUT = os.path.join(HERE, "evidence", "compare")
CHAR = os.path.join(HERE, "design", "character")
BOARD = os.path.join(HERE, "design", "storyboard")
K = 2                     # screenshot px per game px (640x360 game in a 1280x720 window)
BOX = (20, 40)            # player.gd BOX, game px

STATES = [  # (label, sheet image, screenshot, note)
    ("idle", "side-profile-game.png", "state-idle", ""),
    ("run", "poses/pose02-run.png", "state-run", ""),
    ("rising (whole jump)", "poses/pose04-rising.png", "state-rising", ""),
    ("falling (walked off)", "poses/pose05-falling.png", "07a-missed-jump-falling", ""),
    ("landing", "poses/pose06-landing.png", "state-landing", ""),
    ("hose", "poses/pose07-hose.png", "state-hose", ""),
    ("rescue grab", "poses/pose08-grab.png", "state-grab", ""),
    ("rescue toss", "poses/pose09-toss.png", "state-toss", ""),
    ("burned", "poses/pose11-burned.png", "state-burned", ""),
    ("respawn", "poses/pose01-respawn.png", "state-respawn", ""),
    ("celebrate (bow)", "poses/pose12-celebrate.png", "state-celebrate", ""),
    ("run, facing left", "poses/pose02-run.png", "facing-left-run", "sheet drawn facing right; mirrored at runtime"),
    ("idle, facing left", "side-profile-game.png", "facing-left-idle", "sheet drawn facing right; mirrored at runtime"),
    ("jump crouch", "poses/pose03-jump-crouch.png", None, "sheet only: not used in the game (playtest 1)"),
]

PANELS = [  # (storyboard image, screenshot, caption)
    ("01-first-look.png", "01-menu", "Panel 1 first look  |  slice: title card at the start"),
    ("02-core-action-hose.png", "09b-hose-half-way", "Panel 2 hosing  |  slice: hose pose, fire half out"),
    ("03a-grab.png", "10-rescue-1-person-a-grab", "Panel 3a grab  |  slice: grab pose at the window"),
    ("03b-throw.png", "10-rescue-1-person-c-flying-up", "Panel 3b toss  |  slice: survivor flung UP (design change)"),
    ("03c-in-bag.png", "10-rescue-1-person-e-in-the-bag", "Panel 3c in the bag  |  slice: head in the bag"),
    ("04-failure-burned.png", "02b-failure-held-1s", "Panel 4 burned (close-up)  |  slice: burned pose + DEVASTATED close-up"),
    ("05-retry.png", "02c-retry-respawn", "Panel 5 retry  |  slice: back at the start, ready stance"),
    ("06-end-escape.png", "04-complete", "Panel 6 end  |  slice: bow at the exit + close-up"),
]


def fit(im, h):
    return im.resize((max(1, round(im.width * h / im.height)), h), Image.LANCZOS)


def character_vs_sheet(positions):
    rows, H = [], 220
    for label, sheet, shot, note in STATES:
        left = fit(Image.open(os.path.join(CHAR, sheet)).convert("RGB"), H)
        if shot:
            p = positions[shot]
            im = Image.open(os.path.join(SHOTS, shot + ".png")).convert("RGB")
            x, y = p["x"], p["y"]
            d = ImageDraw.Draw(im)
            d.rectangle([x - BOX[0] * K / 2, y - BOX[1] * K, x + BOX[0] * K / 2 - 1, y - 1], outline=(0, 230, 255), width=2)
            right = fit(im.crop((int(x - 170), int(y - 190), int(x + 170), int(y + 30))), H)
        else:
            right = Image.new("RGB", (300, H), (235, 235, 235))
        row = Image.new("RGB", (left.width + right.width + 40, H + 26), "white")
        row.paste(left, (0, 26))
        row.paste(right, (left.width + 40, 26))
        ImageDraw.Draw(row).text((4, 6), f"{label}   ({sheet}  |  {shot or 'not in the game'})  {note}", fill="black")
        rows.append(row)
    W = max(r.width for r in rows)
    sheet = Image.new("RGB", (W, sum(r.height for r in rows)), "white")
    y = 0
    for r in rows:
        sheet.paste(r, (0, y))
        y += r.height
    sheet.save(os.path.join(OUT, "character-vs-sheet.jpg"), quality=85)


def storyboard_vs_slice():
    W, H = 640, 360
    out = Image.new("RGB", (2 * W + 20, len(PANELS) * (H + 30)), "white")
    d = ImageDraw.Draw(out)
    for i, (panel, shot, caption) in enumerate(PANELS):
        y = i * (H + 30)
        b = ImageOps.pad(Image.open(os.path.join(BOARD, panel)).convert("RGB"), (W, H), color="white")
        out.paste(b, (0, y + 26))
        out.paste(Image.open(os.path.join(SHOTS, shot + ".png")).convert("RGB").resize((W, H)), (W + 20, y + 26))
        d.text((4, y + 6), f"{caption}    [{panel}  |  {shot}]", fill="black")
    out.save(os.path.join(OUT, "storyboard-vs-slice.jpg"), quality=85)


def main():
    os.makedirs(OUT, exist_ok=True)
    positions = json.load(open(os.path.join(SHOTS, "positions.json")))
    character_vs_sheet(positions)
    storyboard_vs_slice()
    for f in sorted(os.listdir(OUT)):
        print(f, os.path.getsize(os.path.join(OUT, f)) // 1024, "KB")


if __name__ == "__main__":
    main()
