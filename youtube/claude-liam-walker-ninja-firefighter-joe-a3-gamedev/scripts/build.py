"""Lock measured narration audio, then cut the engine footage and the screen stills (written by Claude Code).

    python scripts/build.py lock       # audio/Bxx.wav from mp3/ (lead silence + 0.3 s tail, frame-aligned)
    python scripts/build.py footage    # media/Bxx.mp4: the Godot orbit (never retimed) and the full-frame screen stills

The orbit is Godot Movie Maker output of scenes3d/props_room.tscn, unchanged except the camera path
(scripts/orbit_capture.gd, run on an isolated copy of godot/). If narration is longer than the orbit, the last frame
is HELD and labelled; the footage is never slowed or trimmed to fit.
"""
import hashlib
import json
import math
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
SHEET = ROOT / "beat_sheet.json"
CAP = ROOT / "capture"
FPS = 30
REV = "71a24c0"


def run(args):
    subprocess.run(list(map(str, args)), check=True)


def probe(p):
    return float(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", str(p)], text=True))


def sha(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def frames(s):
    return math.ceil(s * FPS - 1e-6) / FPS


def save(sheet):
    SHEET.write_text(json.dumps(sheet, indent=2) + "\n")


def lock():
    sheet = json.loads(SHEET.read_text())
    for b in sheet["beats"]:
        if not b["narration_text"]:
            continue
        src = ROOT / "mp3" / f"beat-{b['beat_id']}.mp3"
        lead = b.get("lead_silence_s", 0)
        tail = b.get("tail_hold_s", 0.3)
        d = frames(probe(src) + lead + tail)
        if b.get("gameplay_take") == "orbit":          # the beat lasts at least as long as the real footage (never trimmed)
            d = max(d, frames(probe(CAP / "orbit.avi")))
        dest = ROOT / "audio" / f"{b['beat_id']}.wav"
        dest.parent.mkdir(exist_ok=True)
        run(["ffmpeg", "-v", "error", "-y", "-i", src, "-af", f"adelay={round(lead * 1000)}:all=1,apad", "-t", d, "-ar", "48000", "-ac", "2", "-c:a", "pcm_s16le", dest])
        b.update(audio_file=dest.relative_to(ROOT).as_posix(), actual_duration_s=d, render_duration_s=d)
        if b["shot"].get("remotion"):
            b["shot"]["remotion"]["props"]["durationSeconds"] = d
    save(sheet)
    print("locked narration:", round(sum(b.get("actual_duration_s", 0) for b in sheet["beats"]), 2), "s")


def font(n):
    return ImageFont.truetype(str(ROOT / "remotion/public/Inter-Regular.ttf"), n)


def plate(path, y, title, sub):
    im = Image.new("RGBA", (3840, 2160))
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((230, y, 3610, y + 230), radius=14, fill="#fffdf7")
    d.text((262, y + 14), title, font=font(56), fill="#25354a")
    d.text((262, y + 104), sub, font=font(46), fill="#25354a")
    im.save(path)


def screen_still(b, media):
    """A real app screenshot composite (media/screens/...), full frame, held for the narration, with one provenance plate."""
    bid, total = b["beat_id"], b["actual_duration_s"]
    src = ROOT / "media" / "screens" / b["screen_still"]
    lab = media / f"{bid}.label.png"
    plate(lab, 1880, b["screen_title"], b["screen_sub"])
    out = media / f"{bid}.mp4"
    run(["ffmpeg", "-v", "error", "-y", "-loop", "1", "-framerate", "30", "-i", src, "-i", lab, "-filter_complex",
         "[0:v]scale=3840:2160[b];[b][1:v]overlay=0:0[v]", "-map", "[v]", "-t", total, "-an",
         "-c:v", "libx264", "-preset", "fast", "-crf", "16", "-pix_fmt", "yuv420p", out])
    lab.unlink()
    b["shot"]["evidence_media"] = f"media/{bid}.mp4"
    b["qc"] = {"full_bleed": True, "full_bleed_reason": "A real screenshot of Blender's / Godot's own UI fills the frame.",
               "contrast_regions": [{"label": "provenance plate", "box": [0.06, 0.871, 0.94, 0.977]}],
               "contrast_reason": "The app's dark UI is captured evidence, not our typography; the designed text is the cream plate."}
    return {"beat": bid, "take": "screen", "source": f"media/screens/{b['screen_still']}", "source_sha256": sha(src),
            "output_duration_s": total, "retimed": False, "output_sha256": sha(out)}


def orbit(b, media):
    bid, total = b["beat_id"], b["actual_duration_s"]
    src = CAP / "orbit.avi"
    played = probe(src)
    assert total + 1e-3 >= played, "narration shorter than the orbit; never trim silently"
    lab, hold = media / f"{bid}.label.png", media / f"{bid}.hold.png"
    plate(lab, 120, "Actual Godot 4.7.2 output · Movie Maker · scenes3d/props_room.tscn as saved, only the camera orbits",
          f"hydrant · rescue backpack · flame · 1.8 m pole (Extinguisho's height) · revision {REV}")
    plate(hold, 120, "HELD FRAME for the explanation", "the recorded orbit was not slowed down")
    out = media / f"{bid}.mp4"
    run(["ffmpeg", "-v", "error", "-y", "-i", src, "-i", lab, "-i", hold, "-filter_complex",
         f"[0:v]fps=30,tpad=stop_mode=clone:stop_duration={total}[b];[b][1:v]overlay=0:0:enable='lt(t,{played})'[c];"
         f"[c][2:v]overlay=0:0:enable='gte(t,{played})'[v]",
         "-map", "[v]", "-t", total, "-an", "-c:v", "libx264", "-preset", "fast", "-crf", "16", "-pix_fmt", "yuv420p", out])
    lab.unlink(); hold.unlink()
    b["shot"]["evidence_media"] = f"media/{bid}.mp4"
    b["qc"] = {"full_bleed": True, "full_bleed_reason": "Actual native 4K Godot output fills the frame; not a slide.",
               "contrast_regions": [{"label": "capture / held-frame plate", "box": [0.06, 0.056, 0.94, 0.162]}],
               "contrast_reason": "Godot's dark background and grey floor are the captured scene; the designed text is the cream plate."}
    return {"beat": bid, "take": "orbit", "played_s": round(played, 3), "tail_hold_s": round(total - played, 3),
            "output_duration_s": total, "retimed": False, "source_sha256": sha(src), "output_sha256": sha(out)}


def footage():
    sheet = json.loads(SHEET.read_text())
    media = ROOT / "media"
    edits = []
    for b in sheet["beats"]:
        take = b.get("gameplay_take")
        if take == "screen":
            edits.append(screen_still(b, media))
        elif take == "orbit":
            edits.append(orbit(b, media))
    save(sheet)
    (ROOT / "evidence" / "edit-map.json").write_text(json.dumps(edits, indent=2) + "\n")
    print("footage:", [(e["beat"], e["take"], e.get("tail_hold_s")) for e in edits])


if __name__ == "__main__":
    {"lock": lock, "footage": footage}[sys.argv[1]]()
