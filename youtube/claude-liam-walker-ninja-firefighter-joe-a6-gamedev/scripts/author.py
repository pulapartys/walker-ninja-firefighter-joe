"""Author the A6 film: evidence stills from real repository files + beat_sheet.json (written by Claude Code).

    <brutalist .venv python> scripts/author.py stills sheet

Narration is SCRIPT-DRAFT.md v3, approved by Sreeja ("approved"), with one accuracy change in B11 recorded in
SCRIPT.md. Code excerpts are copied verbatim from the frozen source revision REV with `git show`, so they match the
hashed files in gamedev-evidence.json. Every still is built from a file in this repository: the frame strips
(fixture captures), frames of the scripted-input Movie Maker take, the committed logs and a6/TEST-REPORT.md, the
brief and TUNING.md. No value on a card is typed from memory: numbers are read from the files named on the card.
"""
import json
import re
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parents[1]
REV = "486bd48"
TITLE = "Extinguisho's Puff and Steam"
SLUG = ROOT.name
STILLS = ROOT / "media" / "stills"
SCREENS = ROOT / "media" / "screens"
TAKE = ROOT / "media" / "takeframes"
CAPS = REPO / "captures"
FONT = str(ROOT / "remotion/public/Inter-Regular.ttf")
MONO = str(ROOT / "remotion/public/PTMono-Regular.ttf")
INK, ACC = (61, 57, 41), (190, 89, 58)


def font(n, mono=False):
    return ImageFont.truetype(MONO if mono else FONT, n)


def src_lines(path, a, b):
    text = subprocess.check_output(["git", "show", f"{REV}:{path}"], cwd=REPO, text=True)
    return "\n".join(text.split("\n")[a - 1:b])


def log_lines(path, pattern):
    """Lines of a committed log that match `pattern` (recorded output; nothing is retyped)."""
    return [ln for ln in (REPO / path).read_text(errors="replace").splitlines() if re.search(pattern, ln)]


def text_card(name, title, lines, mono=False, w=1700, size=34, folder=None):
    lh = int(size * 1.45)
    f = font(size, mono)
    wrapped = []
    for ln in lines:
        cur = ""
        for wd in ln.split(" "):
            trial = (cur + " " + wd) if cur else wd
            if cur and f.getlength(trial) > w - 72:
                wrapped.append(cur)
                cur = wd
            else:
                cur = trial
        wrapped.append(cur)
    h = 90 + lh * len(wrapped) + 40
    im = Image.new("RGB", (w, h), (255, 253, 247))
    d = ImageDraw.Draw(im)
    d.text((36, 26), title, font=font(30), fill=ACC)
    for i, ln in enumerate(wrapped):
        d.text((36, 90 + i * lh), ln, font=f, fill=INK)
    im.save((folder or STILLS) / name)
    return (folder or STILLS) / name


def fit(im, h):
    return im.resize((max(1, round(im.width * h / im.height)), h), Image.LANCZOS)


def fit_box(im, w, h):
    s = min(w / im.width, h / im.height)
    return im.resize((max(1, round(im.width * s)), max(1, round(im.height * s))), Image.LANCZOS)


def crop(src, box, scale=1, name=None, nearest=False):
    """A crop of a real capture, optionally magnified (nearest keeps the engine's pixels as pixels)."""
    im = Image.open(src).convert("RGB").crop(box)
    if scale != 1:
        im = im.resize((im.width * scale, im.height * scale), Image.NEAREST if nearest else Image.LANCZOS)
    if name:
        im.save(STILLS / name)
    return im


def screen(name, images, card=None):
    """A full-frame 3840x2160 still of real images side by side, optionally with a cream text card on the right.
    The bottom 280 px are left free for the provenance label added in build.py."""
    out = Image.new("RGB", (3840, 2160), (29, 29, 29))
    area_w = 3840 - (1300 if card else 0) - 160
    ims = [Image.open(i).convert("RGB") for i in images]
    each = (area_w - 60 * (len(ims) - 1)) // len(ims)
    x = 80
    for im in ims:
        im = fit_box(im, each, 1760)
        out.paste(im, (x, 80 + (1760 - im.height) // 2))
        x += each + 60
    if card:
        c = fit_box(Image.open(card).convert("RGB"), 1220, 1760)
        out.paste(c, (3840 - 80 - c.width, 80 + (1760 - c.height) // 2))
    out.save(SCREENS / name)


def screen_stack(name, images, captions, card, row_h=1060):
    """A full-frame 3840x2160 still: a row of real captures (captions under each) and a cream card below, full width.
    The bottom 280 px are left free for the provenance plate added in build.py."""
    out = Image.new("RGB", (3840, 2160), (29, 29, 29))
    d = ImageDraw.Draw(out)
    ims = [Image.open(STILLS / i).convert("RGB") for i in images]
    each = (3680 - 60 * (len(ims) - 1)) // len(ims)
    x = 80
    for im, cap in zip(ims, captions):
        im = fit_box(im, each, row_h)
        out.paste(im, (x + (each - im.width) // 2, 80 + (row_h - im.height) // 2))
        d.text((x + (each - im.width) // 2, row_h + 90), cap, font=font(40), fill=(255, 253, 247))
        x += each + 60
    top = row_h + 190
    c = fit_box(Image.open(card).convert("RGB"), 3680, 1880 - top)
    out.paste(c, (80, top))
    out.save(SCREENS / name)


# The puff in the r0-r2 strips sits at window pixel (440, 560) (jump_puff_preview.gd: (1105, 280), camera x 1205).
PUFF_BOX = (440 - 90, 560 - 80, 440 + 90, 560 + 25)
# The steam in the steam strips: the blocking fire's top centre at window (566, 412), steam rising above it.
STEAM_BOX = (446, 250, 766, 490)


def strip_crop(effect, rev, frame, box, scale, name):
    return crop(CAPS / effect / rev / f"frame{frame:08d}.png", box, scale, name, nearest=True)


def stills():
    for p in (STILLS, SCREENS):
        p.mkdir(parents=True, exist_ok=True)

    # B02 — the game and the two jobs: two frames of the scripted-input take (crops of the 4K frames) + a card
    crop(TAKE / "play-82.png", (0, 1300, 1400, 2010), 1, "take-puff.png")
    crop(TAKE / "play-430.png", (1000, 1000, 2400, 1710), 1, "take-steam.png")
    text_card("jobs.png", "One game, two effects, two jobs · both frames: SCRIPTED-INPUT CAPTURE, not a human playtest (capture/film_capture.gd)",
              ["Game: Extinguisho (walker-ninja-firefighter-joe), Godot 4.7.2, GL Compatibility",
               "Effect A, landing puff: a one-shot burst on the `landed` signal (godot/features/player/player.gd)",
               "Effect B, hose steam: a feedback loop; condition player.hosing, value session.fire_height()"],
              size=40, w=3400)
    screen_stack("game.png", ["take-puff.png", "take-steam.png"],
                 ["Effect A · the puff at his feet, street level", "Effect B · the steam over the blocking fire, B1 roof"],
                 STILLS / "jobs.png", row_h=930)

    # B03 — the brief: the intent lines, copied from CHANGE-BRIEF.md (v1, committed before the first prompt)
    brief = (REPO / "CHANGE-BRIEF.md").read_text().splitlines()
    pick = lambda prefix, n=0: [ln for ln in brief if ln.startswith(prefix)][n].replace("**", "").lstrip("- ")
    text_card("brief.png", "CHANGE-BRIEF.md · v1 committed 2026-11-06, before the first prompt (45c4398) · intent lines, verbatim",
              ["A2 " + pick("- **Timing phases:**", 0),
               "A2 " + pick("- **Contrast against the real background:**", 0),
               "B1 " + pick("- **Job: a feedback loop"),
               "Also in the brief: rules a test can check (A-R1 to A-R8, B-R1 to B-R8), three predicted failures, price guesses and a budget"],
              size=38, w=2200)

    # B04 — three parts: exact lines of the puff's scene file (emission, process, draw)
    L = lambda n: src_lines("godot/effects/jump_puff.tscn", n, n)
    text_card("parts.png", f"godot/effects/jump_puff.tscn · node Puff · exact lines at revision {REV}",
              ["EMISSION — when, and how many",
               f"  64  {L(64)}", f"  65  {L(65)}", f"  66  {L(66)}",
               "PROCESS — how each dot moves and changes",
               f"  75  {L(75)}", f"  77  {L(77)}", f"  78  {L(78)}",
               "DRAW — what each dot looks like",
               f"  70  {L(70)}",
               f"   7  {L(7)}   (a soft radial disc, defined in the scene file)"],
              mono=True, size=40, w=2300)

    # B06 — first strip r0 (fixture), zoomed
    for f in (10, 12, 15, 20, 30, 50):
        strip_crop("jump_puff", "r0", f, PUFF_BOX, 3, f"puff-r0-{f}.png")

    # B08 — tuning the puff: r0 / r1 / r2 at frames 15 and 20 (fixture), and the round record from a6/TUNING.md
    for rv in ("r0", "r1", "r2"):
        for f in (15, 20):
            strip_crop("jump_puff", rv, f, PUFF_BOX, 3, f"puff-{rv}-{f}.png")
    text_card("puff-rounds.png", "a6/TUNING.md · Effect A · one change per round · strips are FIXTURE CAPTURES",
              ["r1  Puff colour ramp greyer · Claude predicted: frame 20 a clear grey cloud on the tan wall · zoomed strip: a visible grey-blue cloud",
               "    Sreeja in the running game: \"honestly i couldnt tell the difference a lot\" · kept · Claude against her eyes: on the record",
               "r2  Puff scale 0.35/0.55 → 0.5/0.8 · Claude predicted: widest 35–40 px · strip: about 30 px, denser",
               "    Sreeja in the running game: \"i like this one better it shows those extra dots as more granular dust\" · kept"],
              size=40, w=3400)
    screen_stack("puff-tuning.png", ["puff-r0-20.png", "puff-r1-20.png", "puff-r2-20.png", "puff-r2-15.png"],
                 ["r0 · frame 20", "r1 · frame 20 (greyer)", "r2 · frame 20 (bigger)", "r2 · frame 15"], STILLS / "puff-rounds.png", row_h=900)

    # B10 — steam: r0 against r1 at frames 16 and 40 (fixture) + the round record
    for rv in ("r0", "r1"):
        for f in (16, 40):
            strip_crop("hose_steam", rv, f, STEAM_BOX, 2, f"steam-{rv}-{f}.png")
    text_card("steam-round.png", "a6/TUNING.md · Effect B · strips are FIXTURE CAPTURES",
              ["Her first look: \"i don't know if the steam is visible enough ... idk if its that noticeable especially in the sky\"",
               "r1  Haze colour ramp grey 0.42 → 0.30, peak alpha 0.5 → 0.8 · Claude predicted frame 16 unchanged · it was not: the first grey puff showed",
               "    Sreeja in the running game: \"its better now\" · kept (CHANGE-BRIEF Revision 6)"],
              size=40, w=3400)
    screen_stack("steam-tuning.png", ["steam-r0-16.png", "steam-r1-16.png", "steam-r0-40.png", "steam-r1-40.png"],
                 ["r0 · frame 16", "r1 · frame 16", "r0 · frame 40", "r1 · frame 40"], STILLS / "steam-round.png", row_h=900)

    # B12 — the process shader: exact generated lines beside the brief settings they implement, and her answer
    g = lambda n: src_lines("godot/shaders/particles_generated.gdshader", n, n).strip()
    text_card("shader-lines.png", f"godot/shaders/particles_generated.gdshader · Godot 4.7.2 wrote it from a copy of Steam's material (Step 6) · revision {REV}",
              [f"331  {g(331)}",
               f"332  {g(332)}",
               "     ↔ CHANGE-BRIEF B-R3: amount_ratio = fire_height() / 34, from 1.0 down to 0; amount stays 40 (Steam), 14 (Haze)",
               "",
               f"232  {g(232)}",
               "     ↔ CHANGE-BRIEF B3: Steam initial_velocity_min / _max = 20 / 40",
               "",
               f"408  {g(408)}        421  {g(421)}",
               "",
               "Her answer (a6/TEST-REPORT.md): \"The process shader controls how particles move, change size, and fade over time,",
               "while the draw step controls how they look on screen.\" Texture and blend mode: draw. Not in this file."],
              mono=True, size=34, w=2600)

    # B13 — what the tests proved (recorded lines; nothing retyped)
    rows = []
    for log in ("logs/test_jump_puff_config_60fps.log", "logs/test_jump_puff_state_60fps.log",
                "logs/test_hose_steam_config_60fps.log", "logs/test_hose_steam_state_60fps.log"):
        rows += [ln.split(" (physics")[0] + f"    ({Path(log).name})" for ln in log_lines(log, r"^(JUMP PUFF|HOSE STEAM) (CONFIG|STATE): \d")]
    rows += ["", "Mutation 1, the Godot 3 name initial_velocity on Puff (a6/evidence/mutations/):"]
    rows += ["  " + ln[:96] for ln in log_lines("a6/evidence/mutations/mutation-1-godot3-initial_velocity_60fps.log", r'"status":"FAIL"|^JUMP PUFF CONFIG')]
    rows += ["Mutation 2, spread 80 → 120 without the brief:", "  " + log_lines("a6/evidence/mutations/mutation-2-spread-drift_60fps.log", r"^JUMP PUFF CONFIG")[0]]
    rows += ["", "Her own run of every suite (a6/evidence/run-all-tests_by-me_68967ee.txt):  " + log_lines("a6/evidence/run-all-tests_by-me_68967ee.txt", r"^ALL AS EXPECTED")[0],
             "Mutation 1 in the running game, her words: \"yes its right under him doesnt look natural looks bad\""]
    text_card("tests.png", f"RECORDED HEADLESS OUTPUT · scripts/run-test.sh · Godot 4.7.2 · game revision {REV}", rows, mono=True, size=32, w=2600)

    # B14 — the price, twice (logs + a6/TEST-REPORT.md)
    probe = log_lines("a6/evidence/probes/gpu_time_probe.log", r"rendering method|mean GPU")
    cost = log_lines("a6/evidence/cost/cost_effects_after_fix_run3_60fps.log", r"^(empty scene|game, effects off|Effect A, 2 puffs alive|Effect B, ratio 1.0) +mean")
    text_card("price.png", "The price, twice · a6/evidence/ logs and a6/TEST-REPORT.md · Apple M1",
              ["HEADLESS CPU (cost_effects.gd, --fixed-fps 60, run 3 after the fix), per frame:"]
              + ["  " + re.sub(r"\s*\|\s*per frame.*", "", ln)[:120] for ln in cost]
              + ["  puff vs off: within the spread in all three runs · steam vs off: the same (no GPU process runs headless)",
                 "GPU TIME — which renderer can report it (gpu_time_probe.log):"]
              + ["  " + ln for ln in probe]
              + ["VISUAL PROFILER (Mobile + Vulkan), her frames: steam off 'Update GPU particles' 0.04 ms · steam on 0.25 / 0.27 ms",
                 "BUDGETS: puff 0.1 ms (both prices): not measurable on either · steam 0.5 ms (GPU time): about +0.2 ms"],
              mono=True, size=30, w=2700)

    # B15 — what Claude got wrong (as recorded)
    text_card("mistakes.png", "The agent's recorded mistakes, and how each was caught · a6/FRICTIONAL.md · a6/TEST-REPORT.md",
              ["1  the preview fired on frame == 10, which a live window skips: her first look saw nothing; 1 of 3 real-time runs fired (fix 6b5c613)",
               "2  the cost script assumed every puff lives 0.88 s, so \"two alive\" failed, and changed its \"different\" rule after a result: a re-run exited 1 (fix db26889)",
               "3  session 1 wrote scratch files under /tmp and dropped the Headless facts block; session 2 deleted a file with rm (not on the allow list)",
               "4  ours: capture windows hidden behind other windows, which macOS stopped drawing: caught by md5 runs of identical frames (fix: --always-on-top)",
               "after every agent session: git diff --stat godot/shaders/ empty; the session's result event read for denials"],
              size=38, w=2400)


def build_sheet():
    beats, excerpts = [], []

    def add(heading, text, pattern=None, props=None, take=None, still=None, **extra):
        bid = f"B{len(beats):02d}"
        shot = {"type": "FOOTAGE" if take else "REMOTION", "source": "own", "classification": "SHOW",
                "visual_intent": heading, "show": [{"at": "beat", "event": heading}]}
        if pattern:
            shot["remotion"] = {"pattern": pattern, "props": props or {}}
        if take:
            shot["evidence_media"] = f"media/{bid}.mp4"
        if still:
            shot["evidence_media"] = f"media/stills/{still}"
        b = {"beat_id": bid, "heading": heading, "narration_text": text, "engine": "kokoro", "voice": "am_onyx", "shot": shot}
        if take:
            b["gameplay_take"] = take
        b.update(extra)
        beats.append(b)
        return bid

    def panel(heading, text, label, images, captions=None, note=None, row_h=900, bg=(255, 253, 247), **extra):
        """Brutalist GodotDesignFigure: one figure per beat; `images` is a row, or a list of rows stacked vertically."""
        bid = f"B{len(beats):02d}"
        name = f"{bid}-figure.png"
        rows = images if isinstance(images[0], list) else [images]
        caps = iter(captions or [])
        built = []
        for r in rows:
            ims = [fit(Image.open(STILLS / i).convert("RGB"), row_h) for i in r]
            W = sum(i.width for i in ims) + 60 * (len(ims) - 1)
            row_im = Image.new("RGB", (W, row_h + (90 if captions else 0)), bg)
            d = ImageDraw.Draw(row_im)
            x = 0
            for i in ims:
                row_im.paste(i, (x, 0))
                c = next(caps, None)
                if c:
                    d.text((x + 8, row_h + 20), c, font=font(40), fill=INK if bg == (255, 253, 247) else (255, 253, 247))
                x += i.width + 60
            built.append(row_im)
        W = max(r.width for r in built)
        built = [r.resize((W, round(r.height * W / r.width)), Image.LANCZOS) if r.width != W else r for r in built]
        fig = Image.new("RGB", (W, sum(r.height for r in built) + 50 * (len(built) - 1)), bg)
        y = 0
        for r in built:
            fig.paste(r, (0, y))
            y += r.height + 50
        fig.save(STILLS / name)
        cards = [{"label": f"{k + 1}", "text": c[:46]} for k, c in enumerate((captions or [])[:4])] or [{"label": "Source", "text": label.split(" · ")[0][:46]}]
        status = label
        while len(status) > 84 and " · " in status:
            status = status.rsplit(" · ", 1)[0]
        props = {"title": heading, "status": status, "image": name, "imageLabel": note or "", "source": label, "cards": cards}
        return add(heading, text, "GodotDesignFigure", props, still=name, **extra)

    def screen_beat(heading, text, still, title, sub):
        add(heading, text, take="screen", screen_still=still, screen_title=title, screen_sub=sub,
            screen_card_below=still in ("game.png", "puff-tuning.png", "steam-tuning.png"))
        beats[-1]["shot"]["type"] = "SCREEN"

    def code(heading, text, path, a, b, notes):
        body = src_lines(path, a, b)
        bid = add(heading, text, "GodotDevWorkbench", {"mode": "code", "title": heading, "project": "walker-ninja-firefighter-joe",
                  "path": path.removeprefix("godot/"), "source": f"Godot editor reconstruction · exact source, revision {REV} · next: the visible result",
                  "code": body, "startLine": a, "codeFontSize": 30, "notes": notes, "output": [f"{path} lines {a}–{b}"], "cues": []})
        excerpts.append({"beat_id": bid, "path": path.removeprefix("godot/"), "start_line": a, "end_line": b, "text": body})
        return bid

    draft = (ROOT / "SCRIPT-DRAFT.md").read_text()
    narr = {m.group(1): m.group(2).strip() for m in re.finditer(r"## (B\d\d) — [^\n]*\n\*\*On screen:\*\*[^\n]*\n\*\*Narration:\*\* ([^\n]*)", draft)}
    # One accuracy change to the approved text: the take shows the game's pause card covering the steam (SCRIPT.md).
    narr["B11"] = narr["B11"].replace("so the steam keeps drifting, which Sreeja chose.",
                                      "so the steam keeps drifting behind the pause card, which Sreeja chose.")
    assert "behind the pause card" in narr["B11"]

    add("The prompt", narr["B00"], "ClaudeComposerAsk",
        {"command": "Please use Walker to convert my game design document\nabout a deadpan ninja firefighter into two particle effects:\na puff of dust when he lands, and steam that follows the fire.",
         "topic": "Illustrative reconstruction, not a session transcript", "segment": TITLE, "greeting": "Hello", "runningText": "", "output": [],
         "folderLabel": "walker-ninja-firefighter-joe", "modelLabel": "Claude Code", "effortLabel": "", "placeholder": ""})
    add("What was built", narr["B01"], "BrutalistHesitantWriter",
        {"text": "Two particle effects for a Godot game.\nA passing test proves the look.", "triggerWords": "look", "replacementWords": "timing",
         "fontSize": 72, "mistakeRate": 0, "hesitateWithin": 0, "hesitateBetween": 0, "charMs": 55, "jitter": 0, "seed": SLUG, "face": "serif", "align": "center"},
        lead_silence_s=0.8)
    screen_beat("The game, the two jobs", narr["B02"], "game.png",
                "SCRIPTED-INPUT CAPTURE, not a human playtest · two frames of the take (Movie Maker, 4K)",
                "capture/play.avi frames 82 and 430 · capture/film_capture.gd · game revision " + REV)
    panel("The brief came first", narr["B03"], "CHANGE-BRIEF.md · v1 committed before the first prompt · 45c4398", ["brief.png"])
    panel("Three parts of a particle system", narr["B04"],
          f"Godot editor reconstruction · exact lines of godot/effects/jump_puff.tscn at revision {REV}", ["parts.png"])
    c1 = code("Effect A, built", narr["B05"], "godot/features/player/jump_puff_driver.gd", 12, 27,
              [{"label": "Line 12", "value": "on each landed signal"}, {"label": "Line 27", "value": "drawn just behind Extinguisho"}])
    panel("The first strip", narr["B06"],
          "FIXTURE CAPTURE · captures/jump_puff/r0 · Movie Maker 30 fps · preview scene, not the game · zoomed 3×",
          [[f"puff-r0-{f}.png" for f in (10, 12, 15)], [f"puff-r0-{f}.png" for f in (20, 30, 50)]],
          ["frame 10 · trigger", "frame 12", "frame 15", "frame 20", "frame 30", "frame 50 · gone"], row_h=520,
          qc={"contrast_regions": [{"label": "title", "box": [0.05, 0.04, 0.30, 0.11]}, {"label": "status pill", "box": [0.05, 0.13, 0.49, 0.19]},
                                   {"label": "cards", "box": [0.05, 0.79, 0.95, 0.89]}, {"label": "footer", "box": [0.05, 0.925, 0.62, 0.965]}],
              "contrast_reason": "The figure is fixture-capture frames of the game's tan wall (captured evidence, not typography); the designed text is the title, status pill, cards and footer."})
    add("Her decision from play: the landing", narr["B07"], take="landings")
    beats[-1]["shot"]["type"] = "VIDEO"
    screen_beat("Tuning the puff", narr["B08"], "puff-tuning.png",
                "FIXTURE CAPTURES · captures/jump_puff/r0, r1, r2 · zoomed 3× · Claude's predictions and her verdicts from a6/TUNING.md",
                "her eyes in the running game decide each round; the strip is the reviewable record")
    c2 = code("Effect B: a feedback loop", narr["B09"], "godot/features/player/hose_steam_driver.gd", 30, 39,
              [{"label": "Line 33", "value": "share = fire height ÷ full height"}, {"label": "Line 35", "value": "amount_ratio, not amount"}])
    screen_beat("Steam: her look, one change", narr["B10"], "steam-tuning.png",
                "FIXTURE CAPTURES · captures/hose_steam/r0 and r1 · zoomed 2× · her words and Claude's prediction from a6/TUNING.md",
                "r1: a darker, more solid haze (one setting) · kept after her check in the running game")
    add("Steam in play", narr["B11"], take="hosing")
    beats[-1]["shot"]["type"] = "VIDEO"
    panel("The process step is a shader", narr["B12"],
          f"Exact lines · godot/shaders/particles_generated.gdshader (Godot wrote it) · CHANGE-BRIEF.md · revision {REV}", ["shader-lines.png"])
    panel("What the tests proved", narr["B13"], "Recorded headless output · logs/ and a6/evidence/ · nothing retyped", ["tests.png"])
    panel("The price, twice", narr["B14"], "a6/evidence/ cost, probe and GPU logs · a6/TEST-REPORT.md · Apple M1", ["price.png"])
    panel("What Claude got wrong", narr["B15"], "As recorded · a6/FRICTIONAL.md · a6/TEST-REPORT.md", ["mistakes.png"])
    add("Verdict", narr["B16"], "ClaudeVerdictArtifact",
        {"artifactTitle": "Assignment 6 · verdict", "artifactHeading": "Two particle effects, checked by tests and by eye",
         "artifactLines": ["Verified: settings read back (94 + 89) · state through real keys (30 + 18) · Godot 3 name fails the test · within budget",
                           "Her eyes: the landing · puff r1 + r2 kept · darker steam kept · both screen edges · no steam at the start",
                           "Uncertain: the steam shown again after hiding · the puff's GPU cost",
                           "Next: her blue hose glow pulls the eye from the steam",
                           "Directed and decided by Sreeja · built by Claude Code · tested by eye and played by Sreeja",
                           f"No downloaded images · game revision {REV}"]})
    add("Your turn", narr["B17"], "ClaudeComposerAsk",
        {"command": "Read my CHANGE-BRIEF. Between one and two seconds the steam should\nvisibly thin, and it is hard to see. Plan one change to the Haze,\npredict frames 40 and 70, and name the test in\ntest_hose_steam_state.gd that must keep passing.",
         "topic": "Your turn · one change, one prediction, one test kept honest", "segment": TITLE, "greeting": "Your turn",
         "runningText": "", "output": [], "folderLabel": "walker-ninja-firefighter-joe", "modelLabel": "Claude Code", "effortLabel": "", "placeholder": ""})
    add("Outro", f"{TITLE}. At Nik Bear Brown.", "ClaudeTitleOutro", {"title": TITLE, "slug": SLUG}, kind="outro_voice", tail_hold_s=1.0)
    pairs = [(c, f"B{int(c[1:]) + 1:02d}") for c in (c1, c2)]
    sheet = {"metadata": {"slug": SLUG, "title": TITLE, "persona": "Liam", "palette": "claude", "engine": "kokoro", "voice": "am_onyx", "voice_kokoro": "am_onyx",
                          "fps": 30, "width": 3840, "height": 2160, "aspect_ratio": "16:9", "caption_policy": "no burned captions", "fit": "pad",
                          "skill": "godot-gamedev", "modifier": "walker", "source_revision": REV, "human_review_approved": False,
                          "authorization": "Student's Assignment 6 explainer; script v3 approved by Sreeja; local 4K master for course submission; no publication."},
             "beats": beats}
    (ROOT / "beat_sheet.json").write_text(json.dumps(sheet, indent=2) + "\n")
    (ROOT / "evidence").mkdir(exist_ok=True)
    (ROOT / "evidence/excerpts.json").write_text(json.dumps({"excerpts": excerpts, "pairs": pairs}, indent=2) + "\n")
    words = sum(len(b["narration_text"].split()) for b in beats)
    print(f"{len(beats)} beats, {words} narration words, pairs {pairs}")


if __name__ == "__main__":
    import sys
    if "stills" in sys.argv:
        stills()
    if "sheet" in sys.argv:
        build_sheet()
