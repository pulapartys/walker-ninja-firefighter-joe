"""Lock measured narration audio, then cut the engine footage and the screen stills (written by Claude Code).

    python scripts/build.py lock       # audio/Bxx.wav from mp3/ (lead silence + 0.3 s tail, frame-aligned)
    python scripts/build.py footage    # media/Bxx.mp4: two segments of the one take (never retimed) and the screen stills

The take is Godot Movie Maker output of the real game (capture/film_capture.gd, scripted normal input through the
player's input hooks and real Esc and R key events, run on an isolated copy of godot/ at the source revision). Each video
beat plays one continuous segment of it at its recorded speed. A beat may follow its segment with a SLOWED REPLAY of a
named part of it (each frame repeated, nothing interpolated), labelled on screen as slowed. If narration is longer than
the footage, the last frame is HELD and labelled; footage is never slowed or retimed silently.
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
REV = "7848c6e"
TAKE = CAP / "play.avi"
# Continuous segments of the take (seconds = physics tick / 60), read from capture/logs/play-marks.jsonl and play-states.jsonl:
# W at 10.8 s; the person's touch 16.017 s, the jump on toss frame 7, the throw on frame 14 (16.25 s); the dog's touch
# 19.65 s, Esc 20.0-20.77 s, R 21.02 s. Each entry: (start, end, what, optional slowed replay (start, end, factor)).
SEGMENTS = {"wave": (10.5, 15.9, "W at the blocking fire; the person waves in the window while Joe hoses · water from 10.8 s", None),
            "toss1": (15.85, 17.25, "the person's rescue: grab on 16.02 s, a jump on toss frame 7, the throw on frame 14, ready stance on 30", (15.98, 16.82, 4)),
            "toss2": (19.4, 21.9, "the dog's rescue: Esc in the active phase (paused 20.02-20.78 s, the clip frozen), R in recovery (21.02 s): respawn", None)}


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
        seg = SEGMENTS.get(b.get("gameplay_take"))
        if seg:                                         # the beat lasts at least as long as its footage (never trimmed)
            d = max(d, frames(seg[1] - seg[0] + ((seg[3][1] - seg[3][0]) * seg[3][2] if seg[3] else 0)))
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
    """A composite of real images (media/screens/...), full frame, held for the narration, with one provenance plate."""
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
    b["qc"] = {"full_bleed": True, "full_bleed_reason": "Real images (frames of the scripted-input take, the fixture frame strip) fill the frame.",
               "contrast_regions": [{"label": "provenance plate", "box": [0.06, 0.871, 0.94, 0.977]}]
                                   + ([{"label": "cream card", "box": [0.03, 0.59, 0.97, 0.85]}] if b.get("screen_card_below") else []),
               "contrast_reason": "The game frames are captured evidence, not our typography; the designed text is on the cream card and plate."}
    return {"beat": bid, "take": "screen", "source": f"media/screens/{b['screen_still']}", "source_sha256": sha(src),
            "output_duration_s": total, "retimed": False, "output_sha256": sha(out)}


def segment(b, media):
    bid, total = b["beat_id"], b["actual_duration_s"]
    t0, t1, what, replay = SEGMENTS[b["gameplay_take"]]
    played = t1 - t0
    slow = (replay[1] - replay[0]) * replay[2] if replay else 0.0
    assert total + 1e-3 >= played + slow, "narration shorter than the footage; never trim silently"
    lab, hold, rlab = media / f"{bid}.label.png", media / f"{bid}.hold.png", media / f"{bid}.replay.png"
    plate(lab, 470, "Actual Godot 4.7.2 output · Movie Maker · SCRIPTED-INPUT CAPTURE, NOT A HUMAN PLAYTEST (capture/film_capture.gd)",
          f"game revision {REV} · {what} · take {t0:.2f}–{t1:.2f} s, recorded speed")
    plate(hold, 470, "HELD FRAME for the explanation", "the last frame of this footage; the recording was not slowed down")
    out = media / f"{bid}.mp4"
    if replay:
        r0, r1, k = replay
        plate(rlab, 470, f"SLOWED REPLAY · {1 / k:.2f}× · each recorded frame shown {k} times, nothing interpolated",
              f"take {r0:.2f}–{r1:.2f} s of the same capture · game revision {REV}")
        fc = (f"[0:v]fps=30,scale=3840:2160:flags=neighbor[a];[a][2:v]overlay=0:0[a2];"
              f"[1:v]fps=30,scale=3840:2160:flags=neighbor,setpts={k}*PTS,fps=30[r];[r][4:v]overlay=0:0[r2];"
              f"[a2][r2]concat=n=2:v=1:a=0,tpad=stop_mode=clone:stop_duration={total}[c];"
              f"[c][3:v]overlay=0:0:enable='gte(t,{played + slow})'[v]")
        run(["ffmpeg", "-v", "error", "-y", "-ss", t0, "-t", played, "-i", TAKE, "-ss", r0, "-t", r1 - r0, "-i", TAKE,
             "-i", lab, "-i", hold, "-i", rlab, "-filter_complex", fc,
             "-map", "[v]", "-t", total, "-an", "-c:v", "libx264", "-preset", "fast", "-crf", "16", "-pix_fmt", "yuv420p", out])
        rlab.unlink()
    else:
        run(["ffmpeg", "-v", "error", "-y", "-ss", t0, "-t", played, "-i", TAKE, "-i", lab, "-i", hold, "-filter_complex",
             f"[0:v]fps=30,scale=3840:2160:flags=neighbor,tpad=stop_mode=clone:stop_duration={total}[b];[b][1:v]overlay=0:0:enable='lt(t,{played})'[c];"
             f"[c][2:v]overlay=0:0:enable='gte(t,{played})'[v]",
             "-map", "[v]", "-t", total, "-an", "-c:v", "libx264", "-preset", "fast", "-crf", "16", "-pix_fmt", "yuv420p", out])
    lab.unlink(); hold.unlink()
    b["shot"]["evidence_media"] = f"media/{bid}.mp4"
    b["qc"] = {"full_bleed": True, "full_bleed_reason": "Actual native 4K Godot output fills the frame; not a slide.",
               "contrast_regions": [{"label": "capture / replay / held-frame plate", "box": [0.06, 0.217, 0.94, 0.324]}],
               "contrast_reason": "The game's sky and buildings are the captured scene; the designed text is the cream plate."}
    return {"beat": bid, "take": b["gameplay_take"], "source": "capture/play.avi", "segment_s": [t0, t1], "played_s": round(played, 3),
            "slowed_replay": {"segment_s": [replay[0], replay[1]], "factor": replay[2], "method": "frames repeated (setpts), labelled"} if replay else None,
            "tail_hold_s": round(total - played - slow, 3), "output_duration_s": total, "retimed": bool(replay), "retime_disclosed_on_screen": bool(replay), "source_sha256": sha(TAKE), "output_sha256": sha(out)}


def footage():
    sheet = json.loads(SHEET.read_text())
    media = ROOT / "media"
    edits = []
    for b in sheet["beats"]:
        take = b.get("gameplay_take")
        if take == "screen":
            edits.append(screen_still(b, media))
        elif take in SEGMENTS:
            edits.append(segment(b, media))
    save(sheet)
    (ROOT / "evidence" / "edit-map.json").write_text(json.dumps(edits, indent=2) + "\n")
    print("footage:", [(e["beat"], e["take"], e.get("tail_hold_s")) for e in edits])


if __name__ == "__main__":
    {"lock": lock, "footage": footage}[sys.argv[1]]()
