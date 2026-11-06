"""Background luminance and contrast figures quoted in CHANGE-BRIEF.md v1.

Relative luminance from sRGB (WCAG formula); env_bg.png resized to the 640x360
viewport. Run from the repository root with Python 3 + Pillow + numpy.
"""
from PIL import Image
import numpy as np


def lin(c):
    c = np.asarray(c, float)
    return np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)


def lum(rgb):
    l = lin(rgb)
    return 0.2126 * l[..., 0] + 0.7152 * l[..., 1] + 0.0722 * l[..., 2]


def ratio(a, b):
    hi, lo = max(a, b), min(a, b)
    return (hi + 0.05) / (lo + 0.05)


a = np.asarray(Image.open("godot/art/env/env_bg.png").convert("RGB").resize((640, 360), Image.BILINEAR)).astype(float) / 255
L = lum(a)
sky = L[120:206, 240:320]
blocks = sorted((float(L[y:y + 40, x:x + 40].mean()), x, y) for y in range(120, 330, 10) for x in range(0, 600, 10))
wall = np.array([0xE0, 0xCD, 0xAF]) / 255 * 0.82 + np.array([0.96, 0.46, 0.16]) * 0.18
bgs = {"tan wall": float(lum(wall)), "ledge": float(lum(np.array([0xB8, 0xB2, 0xA6]) / 255)),
       "sky behind fire (mean)": float(sky.mean()), "sky behind fire (max)": float(sky.max()),
       "lightest sky block": blocks[-1][0], "darkest skyline block": blocks[0][0]}
for k, v in bgs.items():
    print(f"{k:24s} {v:.3f}")
cols = {"puff white": (0.97, 0.96, 0.94), "speck ink #25354a": (0x25 / 255, 0x35 / 255, 0x4A / 255),
        "steam white": (0.95, 0.95, 0.97), "haze grey": (0.42, 0.43, 0.47)}
for k, c in cols.items():
    l = float(lum(np.array(c)))
    print(f"{k:18s} L={l:.3f}  " + "  ".join(f"{b}={ratio(l, v):.1f}" for b, v in bgs.items()))
