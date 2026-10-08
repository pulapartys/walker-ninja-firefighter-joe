"""Lock measured narration audio, then cut the gameplay beats (written by Claude Code).

    python scripts/build.py lock       # audio/Bxx.wav from mp3/ (lead silence + 0.3 s tail, frame-aligned)
    python scripts/build.py footage    # media/Bxx.mp4 from capture/*.avi, labeled, never retimed

Gameplay is cut from the Movie Maker captures at normal speed. If narration is longer than the
played action, the last frame is HELD and labeled "HELD FRAME"; action is never slowed or
trimmed to fit. Boundaries come from the capture state logs (evidence/capture/*-states.jsonl).
The "audio" beat keeps the game's own sound (clock: source, audio_policy: preserve).
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
LOGS = ROOT / "evidence" / "capture"
FPS = 30
REV = "241c3f2"


def run(args):
    subprocess.run(list(map(str, args)), check=True)


def probe(p):
    return float(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", str(p)], text=True))


def sha(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def frames(s):
    return math.ceil(s * FPS - 1e-6) / FPS


def states(take):
    return [json.loads(l) for l in (LOGS / f"{take}-states.jsonl").read_text().splitlines()]


def first(take, cond):
    for r in states(take):
        if cond(r):
            return r["t"]
    raise ValueError(f"no matching state in {take}")


def lock():
    sheet = json.loads(SHEET.read_text())
    for b in sheet["beats"]:
        if not b["narration_text"]:
            continue
        src = ROOT / "mp3" / f"beat-{b['beat_id']}.mp3"
        lead = b.get("lead_silence_s", 0)
        tail = b.get("tail_hold_s", 0.3)
        d = frames(probe(src) + lead + tail)
        dest = ROOT / "audio" / f"{b['beat_id']}.wav"
        dest.parent.mkdir(exist_ok=True)
        run(["ffmpeg", "-v", "error", "-y", "-i", src, "-af", f"adelay={round(lead * 1000)}:all=1,apad", "-t", d, "-ar", "48000", "-ac", "2", "-c:a", "pcm_s16le", dest])
        b.update(audio_file=dest.relative_to(ROOT).as_posix(), actual_duration_s=d, render_duration_s=d)
        if b["shot"].get("remotion"):
            b["shot"]["remotion"]["props"]["durationSeconds"] = d
    save(sheet)
    print("locked narration:", round(sum(b.get("actual_duration_s", 0) for b in sheet["beats"]), 2), "s")


def save(sheet):
    SHEET.write_text(json.dumps(sheet, indent=2) + "\n")


def label_png(path, title, sub):
    im = Image.new("RGBA", (3840, 2160))
    d = ImageDraw.Draw(im)
    f = lambda n: ImageFont.truetype(str(ROOT / "remotion/public/Inter-Regular.ttf"), n)
    d.rounded_rectangle((230, 470, 3400, 650), radius=14, fill="#fffdf7")
    d.text((262, 482), title, font=f(56), fill="#25354a")
    d.text((262, 566), sub, font=f(46), fill="#25354a")
    im.save(path)


def segment(out, take, start, end, title, sub, keep_audio=False):
    """Cut [start, end) of a take at normal speed with a label; optionally keep its audio."""
    lab = out.with_suffix(".label.png")
    label_png(lab, title, sub)
    args = ["ffmpeg", "-v", "error", "-y", "-ss", start, "-t", end - start, "-i", CAP / f"{take}.avi", "-i", lab,
            "-filter_complex", "[0:v]fps=30[b];[b][1:v]overlay=0:0[v]", "-map", "[v]"]
    args += (["-map", "0:a", "-c:a", "aac", "-b:a", "256k"] if keep_audio else ["-an"])
    args += ["-c:v", "libx264", "-preset", "fast", "-crf", "16", "-pix_fmt", "yuv420p", out]
    run(args)
    lab.unlink()
    return {"take": take, "start_s": round(start, 3), "end_s": round(end, 3), "label": title}


def hold(out, parts, total, title):
    """Concatenate parts; if shorter than total, hold the last frame labeled HELD FRAME."""
    lst = out.with_suffix(".txt")
    lst.write_text("".join(f"file '{p.name}'\n" for p in parts))
    joined = out.with_suffix(".joined.mp4")
    run(["ffmpeg", "-v", "error", "-y", "-f", "concat", "-safe", "0", "-i", lst, "-c", "copy", joined])
    played = probe(joined)
    assert total + 1e-3 >= played, f"{out.name}: narration {total}s shorter than played action {played}s; never trim silently"
    lab = out.with_suffix(".hold.png")
    label_png(lab, title, "HELD FRAME for the explanation · the played action was not slowed down")
    run(["ffmpeg", "-v", "error", "-y", "-i", joined, "-i", lab, "-filter_complex",
         f"[0:v]tpad=stop_mode=clone:stop_duration={total}[b];[b][1:v]overlay=0:0:enable='gte(t,{played})'[v]",
         "-map", "[v]", "-t", total, "-an", "-c:v", "libx264", "-preset", "fast", "-crf", "16", "-pix_fmt", "yuv420p", out])
    for p in [lst, joined, lab, *parts]:
        p.unlink()
    return played


def footage():
    sheet = json.loads(SHEET.read_text())
    media = ROOT / "media"
    sub = f"Actual Godot output · scripted normal input · Movie Maker · revision {REV}"
    edits = []
    t_rescue = first("route", lambda r: r["rescued"] >= 1)
    t_hose = first("route", lambda r: r["pose"] == "hose")
    t_done = first("route", lambda r: r["state"] == 4)
    t_left = first("fall", lambda r: r["facing"] < 0)
    t_fall = first("fall", lambda r: r["pose"] == "falling")
    t_burn = first("fire", lambda r: r["pose"] == "burned")
    for b in sheet["beats"]:
        take, bid = b.get("gameplay_take"), b["beat_id"]
        if not take:
            continue
        out = media / f"{bid}.mp4"
        total = b.get("actual_duration_s")
        if take == "rescue":
            segs = [("route", t_rescue - 6.5, t_rescue + 3.0, "Hose, jump to the window, grab, toss up, into the bag")]
        elif take == "montage":
            segs = [("route", 0.6, 1.6, "Respawn stance → idle"), ("route", 1.6, 4.4, "Run · flying kick · landing"),
                    ("route", t_hose, t_hose + 1.5, "Hose"), ("route", t_rescue - 0.1, t_rescue + 1.4, "Grab → toss"),
                    ("route", t_done, t_done + 1.4, "Bow (level complete)"), ("fall", t_left, t_left + 1.2, "Facing left (mirrored)"),
                    ("fall", t_fall - 0.3, t_fall + 1.3, "Missed jump: meditating fall"), ("fire", t_burn - 0.1, t_burn + 1.6, "Burned")]
        elif take == "fire":
            segs = [("fire", 0.0, probe(CAP / "fire.avi"), "Fire death: burned + close-up, 2 s hold, then the retry")]
        elif take == "muted":
            segs = [("muted", 1.5, 11.0, "Muted: MUSIC OFF · SOUND OFF")]
        elif take == "audio":
            parts, rows = [], []
            for i, (tk, title) in enumerate([("route", "GAME AUDIO — no narration · full run: jumps, hose, rescues, music, win"),
                                             ("fire", "GAME AUDIO — no narration · fire death: the burn")]):
                p = media / f"{bid}.part{i}.mp4"
                rows.append(segment(p, tk, 0.0, probe(CAP / f"{tk}.avi"), title, sub, keep_audio=True))
                parts.append(p)
            lst = media / f"{bid}.txt"
            lst.write_text("".join(f"file '{p.name}'\n" for p in parts))
            run(["ffmpeg", "-v", "error", "-y", "-f", "concat", "-safe", "0", "-i", lst, "-c", "copy", out])
            for p in [lst, *parts]:
                p.unlink()
            d = frames(probe(out))
            b.update(actual_duration_s=d, render_duration_s=d, kind="game_audio")
            b.pop("audio_file", None)
            edits.append({"beat": bid, "segments": rows, "audio": "the game's own sound, preserved; no narration", "retimed": False, "output_sha256": sha(out)})
            continue
        parts, rows = [], []
        for i, (tk, a, z, title) in enumerate(segs):
            p = media / f"{bid}.part{i}.mp4"
            rows.append(segment(p, tk, max(0.0, a), z, title, sub))
            parts.append(p)
        played = hold(out, parts, total, b["heading"])
        b["shot"]["evidence_media"] = f"media/{bid}.mp4"
        b["qc"] = {"full_bleed": True, "full_bleed_reason": "Actual native 4K Godot gameplay fills the frame; not a slide with title-safe margins."}
        edits.append({"beat": bid, "segments": rows, "played_s": round(played, 3), "tail_hold_s": round(total - played, 3), "output_duration_s": total, "retimed": False, "output_sha256": sha(out)})
    save(sheet)
    (ROOT / "evidence" / "edit-map.json").write_text(json.dumps(edits, indent=2) + "\n")
    print("footage:", [(e["beat"], e.get("played_s"), e.get("tail_hold_s")) for e in edits])


if __name__ == "__main__":
    {"lock": lock, "footage": footage}[sys.argv[1]]()
