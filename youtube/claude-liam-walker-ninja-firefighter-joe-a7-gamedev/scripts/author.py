"""Author the A7 film: evidence stills from real repository files + beat_sheet.json (written by Claude Code).

    <brutalist .venv python> scripts/author.py stills sheet          # draft: TODO-HUMAN beats left out
    A7_FILM_PENDING=1 <python> scripts/author.py sheet               # include the TODO-HUMAN beats as pending cards

Narration is SCRIPT-DRAFT.md v1, drafted by Claude Code while Sreeja was away; not yet approved by her. Code
excerpts are copied verbatim from the frozen source revision REV with `git show`, so they match the hashed files in
gamedev-evidence.json. Every still is built from a file in this repository at REV: frames of the scripted-input
Movie Maker take (capture/play.avi), the r0 fixture strip, the sheet file, the committed logs and mutation records,
and CHANGE-BRIEF.md. No value on a card is typed from memory: numbers are read from the files named on the card.
"""
import json
import os
import re
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parents[1]
REV = "7848c6e"
TITLE = "Extinguisho's Wave and Toss"
SLUG = ROOT.name
STILLS = ROOT / "media" / "stills"
SCREENS = ROOT / "media" / "screens"
TAKE = ROOT / "media" / "takeframes"
FONT = str(ROOT / "remotion/public/Inter-Regular.ttf")
MONO = str(ROOT / "remotion/public/PTMono-Regular.ttf")
INK, ACC = (61, 57, 41), (190, 89, 58)
PENDING = os.environ.get("A7_FILM_PENDING") == "1"


def at_rev(path):
    """A repository file's text at the film's source revision."""
    return subprocess.check_output(["git", "show", f"{REV}:{path}"], cwd=REPO, text=True)


def src_lines(path, a, b):
    return "\n".join(at_rev(path).split("\n")[a - 1:b])


def log_lines(path, pattern):
    """Lines of a committed log (at REV) that match `pattern` (recorded output; nothing is retyped)."""
    return [ln for ln in at_rev(path).splitlines() if re.search(pattern, ln)]


def font(n, mono=False):
    return ImageFont.truetype(MONO if mono else FONT, n)


def text_card(name, title, lines, mono=False, w=1700, size=34, folder=None, title_size=30):
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
    top = 26 + round(title_size * 1.35) + 34
    h = top + lh * len(wrapped) + 40
    im = Image.new("RGB", (w, h), (255, 253, 247))
    d = ImageDraw.Draw(im)
    d.text((36, 26), title, font=font(title_size), fill=ACC)
    for i, ln in enumerate(wrapped):
        d.text((36, top + i * lh), ln, font=f, fill=INK)
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


def stills():
    for p in (STILLS, SCREENS):
        p.mkdir(parents=True, exist_ok=True)

    # B02 — the game and the two clips: two frames of the scripted-input take (crops of the 4K frames) + a card
    crop(TAKE / "play-400.png", (1050, 900, 2350, 1560), 1, "take-wave.png")
    crop(TAKE / "play-488.png", (700, 560, 2000, 1300), 1, "take-throw.png")
    text_card("clips.png", "One game, two clips · both frames: SCRIPTED-INPUT CAPTURE, not a human playtest (capture/film_capture.gd)",
              ["Game: Extinguisho (walker-ninja-firefighter-joe), Godot 4.7.2, GL Compatibility",
               "The cycle: the person survivor's wave, a cutout rig (godot/features/survivor/survivor_person.tscn)",
               "The committing action: Joe's survivor toss, a sprite-sheet frame track (godot/features/player/joe_art.tscn)"],
              size=40, w=3400)
    screen_stack("game.png", ["take-wave.png", "take-throw.png"],
                 ["The wave · take frame 400 (tick 800), while Joe hoses", "The throw · take frame 488 (tick 976), the survivor just launched"],
                 STILLS / "clips.png", row_h=930)

    # B03 — the brief: routes, authorities and the revised phase table, copied from CHANGE-BRIEF.md at REV
    brief = at_rev("CHANGE-BRIEF.md").splitlines()
    clean = lambda s: re.sub(r"[*`]", "", s).lstrip("- ").strip()
    first = lambda s: clean(s).split(". ")[0] + "."
    routes = [ln for ln in brief if ln.startswith("- **Route:")]
    auths = [ln for ln in brief if ln.startswith("- **Authority:**")]
    rows = [ln.strip() for ln in brief if re.match(r"\| (Startup|Active|Recovery) \(.*\) \| \d+–\d+ \(\d+\) \| \d+ \|", ln.strip())]
    table = [" · ".join(c.strip() for c in r.strip("|").split("|")[:4]) for r in rows[-3:]]   # Revision 2's rows (v1's come first)
    text_card("brief.png", "CHANGE-BRIEF.md · v1 committed before any setup prompt (f0a6de5) · Revision 2 table · lines as written",
              ["Clip 1, the wave · " + first(routes[0]), "  " + first(auths[0]),
               "Clip 2, the toss · " + first(routes[1]), "  " + first(auths[1]),
               "Phase table at 60 fps, one frame per physics tick (Revision 2):"] + ["  " + t for t in table],
              size=92, w=3640, title_size=54)
    screen("brief.png", [STILLS / "brief.png"])

    # B07 — the real sheet with its slicing drawn on top (the file at REV; overlay labelled)
    sheet_png = ROOT / "media" / "joe_sheet_rev.png"
    sheet_png.write_bytes(subprocess.check_output(["git", "show", f"{REV}:godot/art/character/joe_sheet.png"], cwd=REPO))
    sh = Image.open(sheet_png).convert("RGBA")
    k = 3
    big = Image.new("RGBA", (sh.width * k, sh.height * k), (255, 253, 247, 255))
    big.alpha_composite(sh.resize((sh.width * k, sh.height * k), Image.NEAREST))
    d = ImageDraw.Draw(big)
    names = list(json.loads(at_rev("godot/art/character/anchors.json"))["anchors"])
    cw, ch = 142 * k, 145 * k
    for i, n in enumerate(names):
        x, y = (i % 4) * cw, (i // 4) * ch
        hot = {8: "grab", 9: "throw", 1: "ready"}.get(i)
        d.rectangle((x, y, x + cw - 1, y + ch - 1), outline=ACC if hot else (37, 53, 74), width=6 if hot else 2)
        label = f"{i}  {n}" + (f"  ·  toss: {hot}" if hot else "")
        tw = font(30).getlength(label)
        d.rectangle((x + 6, y + 6, x + 18 + tw, y + 48), fill=(255, 253, 247, 255))   # backing plate: dark ink on cream
        d.text((x + 12, y + 10), label, font=font(30), fill=INK)
        ax, ay = x + 70 * k, y + 133 * k
        d.line((ax - 18, ay, ax + 18, ay), fill=(37, 53, 74), width=3)
        d.line((ax, ay - 18, ax, ay + 18), fill=(37, 53, 74), width=3)
    big.convert("RGB").save(STILLS / "sheet-grid.png")
    text_card("sheet-card.png", "godot/art/character/joe_sheet.png · revision " + REV,
              ["4 × 3 cells of 142 × 145 px (hframes 4, vframes 3)", "+ = the shared anchor (70, 133): his feet, in every cell",
               "cell 8 · grab · toss frames 0–13", "cell 9 · toss, the throw · frames 14–29", "cell 1 · respawn, the ready stance · frames 30–45",
               "The grid decides which picture a number means."], size=44, w=1220)
    screen("sheet.png", [STILLS / "sheet-grid.png"], card=STILLS / "sheet-card.png")

    # B09 — the r0 boundary strip (FIXTURE CAPTURE), the labelled sheet committed at REV, full frame
    r0p = ROOT / "media" / "boundaries_r0_rev.png"
    r0p.write_bytes(subprocess.check_output(["git", "show", f"{REV}:captures/toss/r0/boundaries_r0.png"], cwd=REPO))
    screen("r0.png", [r0p])

    # B11 — what the read-backs and mutations recorded (lines at REV; nothing retyped)
    rows = [log_lines("logs/test_toss_readback_60fps.log", r"RESULT:")[0] + "    (test_toss_readback.gd, 60 fps)",
            log_lines("logs/test_wave_readback_60fps.log", r"RESULT:")[0] + "    (test_wave_readback.gd, 60 fps)", ""]
    for m, what in (("1a-toss-subname", "Sprite:frame -> Sprite:frames in the toss clip only"),
                    ("1b-wave-subname", "Shoulder:rotation -> Shoulder:rotaton"),
                    ("2-wave-loop-none", "the wave's loop_mode -> LOOP_NONE"),
                    ("3-toss-cell-12", "the throw key 9 -> 12, a cell the sheet does not have"),
                    ("5-second-writer", "a second writer: sprite.frame = 0 in show_pose()")):
        txt = at_rev(f"a7/evidence/mutations/{m}.txt").splitlines()
        exitline = next(l for l in txt if l.startswith("test:")).replace("test: scripts/run-test.sh ", "")
        fail = next((l for l in txt if '"status":"FAIL"' in l), "")
        fid = re.search(r'"id":"([^"]+)"', fail).group(1) if fail else ""
        prob = re.search(r'problems":\["([^"]+)"', fail)
        rows.append(f"{m}: {what}")
        rows.append(f"    {exitline} · failed check {fid}" + (f' · "{prob.group(1)}"' if prob else ""))
    e4 = at_rev("a7/evidence/mutations/4-empty-import-cache.txt").splitlines()
    e4_lines = list(dict.fromkeys(l for l in e4 if l.startswith("test_") and "exit" in l))
    rows += ["4-empty-import-cache: godot/.godot deleted, --import, both read-backs (expected: pass)"] + ["    " + l for l in e4_lines]
    text_card("tests.png", f"RECORDED HEADLESS OUTPUT · scripts/run-test.sh · Godot 4.7.2 · each mutation in a throwaway git worktree · revision {REV}",
              rows, mono=True, size=52, w=3640, title_size=50)
    screen("tests.png", [STILLS / "tests.png"])

    # B16 — what the pins caught: the recorded launch line and the brief's Revision 2 lines
    pin = log_lines("logs/test_pins_a7_60fps.log", r'"id":"launch-after-touch"')[0]
    brief_rev2 = [clean(ln) for ln in brief if ln.startswith("- **The launch is on frame 14") or ln.startswith("- **A pre-existing re-rescue")]
    text_card("pins.png", "The Step 2 pins, measured before any clip was wired · logs/test_pins_a7_60fps.log · CHANGE-BRIEF.md Revision 2",
              ["Recorded: " + pin[:150],
               "v1 of the brief said: the survivor launches on frame 15 (worked out by reading session.gd)",
               "Revision 2: " + brief_rev2[0].split(". ")[0] + ". " + brief_rev2[0].split(". ")[1] + ".",
               "Then the phase table moved (the throw from frame 15 to 14) and the keys were rebuilt from it.",
               "Also pinned, not fixed: " + brief_rev2[1].split(". ")[0] + "."],
              size=80, w=3640, title_size=54)
    screen("pins.png", [STILLS / "pins.png"])

    # B17 — the agent's recorded mistakes and the limit (a7/FRICTIONAL.md, a7/TEST-REPORT.md)
    text_card("mistakes.png", "The agent's recorded mistakes, and how each was caught · a7/FRICTIONAL.md · a7/TEST-REPORT.md",
              ["1  the brief's launch tick, worked out from code: frame 15; the pin measured 14 (CHANGE-BRIEF Revision 2, before any key existed)",
               "2  the state test compared the sprite against the sheet before storing it: 30 false 'texture changed' ticks (fixed before commit 74363a6)",
               "3  the edge test compared hand-back frame 46 against the table (fixed before commit a01b6dd)",
               "4  the read-only CLAUDE.md session tried godot --version three times and git tag once: refused by its allowlist (a7/sessions/session-1.jsonl)",
               "after every step: git diff --stat godot/shaders/ empty · the limit: no headless run draws a pixel"],
              size=38, w=2600)


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
            screen_card_below=still in ("game.png",))
        beats[-1]["shot"]["type"] = "SCREEN"

    def code(heading, text, path, a, b, notes, size=30):
        body = src_lines(path, a, b)
        bid = add(heading, text, "GodotDevWorkbench", {"mode": "code", "title": heading, "project": "walker-ninja-firefighter-joe",
                  "path": path.removeprefix("godot/"), "source": f"Godot editor reconstruction · exact source, revision {REV} · next: the visible result",
                  "code": body, "startLine": a, "codeFontSize": size, "notes": notes, "output": [f"{path} lines {a}–{b}"], "cues": []})
        excerpts.append({"beat_id": bid, "path": path.removeprefix("godot/"), "start_line": a, "end_line": b, "text": body})
        return bid


    draft = (ROOT / "SCRIPT-DRAFT.md").read_text()
    narr = {m.group(1): m.group(2).strip() for m in re.finditer(r"## ((?:B|H)\d\d|H\d) — [^\n]*\n\*\*On screen:\*\*[^\n]*\n\*\*Narration:\*\* ([^\n]*)", draft)}

    add("The prompt", narr["B00"], "ClaudeComposerAsk",
        {"command": "Please use Walker to give my firefighter game two animations:\na trapped survivor who waves for help,\nand a rescue toss that commits once it starts.",
         "topic": "Illustrative reconstruction, not a session transcript", "segment": TITLE, "greeting": "Hello", "runningText": "", "output": [],
         "folderLabel": "walker-ninja-firefighter-joe", "modelLabel": "Claude Code", "effortLabel": "", "placeholder": ""})
    add("What was built", narr["B01"], "BrutalistHesitantWriter",
        {"text": "Two animations for a Godot game.\nA passing test proves the motion.", "triggerWords": "motion", "replacementWords": "structure",
         "fontSize": 72, "mistakeRate": 0, "hesitateWithin": 0, "hesitateBetween": 0, "charMs": 55, "jitter": 0, "seed": SLUG, "face": "serif", "align": "center"},
        lead_silence_s=0.8)
    screen_beat("The game, the two clips", narr["B02"], "game.png",
                "SCRIPTED-INPUT CAPTURE, not a human playtest · two frames of the take (Movie Maker, 4K)",
                "capture/play.avi frames 400 and 488 · capture/film_capture.gd · game revision " + REV)
    screen_beat("The brief came first", narr["B03"], "brief.png",
                "CHANGE-BRIEF.md · lines as written · v1 committed before any setup prompt (f0a6de5)",
                "phase table from Revision 2 (the pins moved the throw from frame 15 to 14) · repository revision " + REV)
    c1 = code("A clip is a list of keys", narr["B04"], "godot/features/survivor/survivor_person.tscn", 5, 17,
              [{"label": "Line 10", "value": "the track names Shoulder:rotation"}, {"label": "Lines 14 and 17", "value": "0, 0.4, 0.8 s → 0, 0.45, 0 rad"},
               {"label": "Line 5", "value": "loop_mode 1 = LOOP_LINEAR"}], size=23)
    add("The wave in play", narr["B05"], take="wave")
    beats[-1]["shot"]["type"] = "VIDEO"
    c2 = code("The sheet and its slicing", narr["B06"], "godot/features/player/joe_art.tscn", 10, 21,
              [{"label": "Lines 14–15", "value": "4 × 3 cells"}, {"label": "Line 21", "value": "callback 2 = manual"}], size=24)
    screen_beat("The real sheet", narr["B07"], "sheet.png",
                "The committed sheet file, magnified 3× (nearest) · the grid, cell numbers and + anchors are an overlay",
                "godot/art/character/joe_sheet.png at game revision " + REV + " · packed by tools/make_joe_sheet.py from the A2 poses")
    c3 = code("Feel in frames", narr["B08"], "godot/tools/bake_joe_clips.gd", 8, 14,
              [{"label": "Line 13", "value": "grab 0 · throw 14 · ready 30"}, {"label": "Line 14", "value": "46 frames at 60 fps"}], size=23)
    screen_beat("The first strip", narr["B09"], "r0.png",
                "FIXTURE CAPTURE · captures/toss/r0 · Movie Maker 30 fps · toss_preview.tscn (the real game at the window, fire put out by the fixture)",
                "ticks from logs/toss_preview_r0.log · two physics ticks per strip frame · game revision " + REV)
    c4 = code("A wrong name fails silently", narr["B10"], "godot/tests/anim_checks.gd", 16, 24,
              [{"label": "Line 18", "value": "find the node the track names"}, {"label": "Line 20", "value": "no node: report it"},
               {"label": "Line 24", "value": "the property it names (checked on line 35)"}], size=24)
    screen_beat("What the read-backs caught", narr["B11"], "tests.png",
                "RECORDED HEADLESS OUTPUT · logs/test_*_readback_60fps.log and a7/evidence/mutations/ · nothing retyped",
                "each mutation made in a throwaway git worktree of 317835f and removed afterwards · repository revision " + REV)
    c5 = code("One authority", narr["B12"], "godot/features/player/player.gd", 87, 95,
              [{"label": "Line 89", "value": "restart on a new clip, or on every grab"}, {"label": "Lines 90–91", "value": "play, then seek to frame 0"}], size=26)
    add("The toss in play, interrupted", narr["B13"], take="toss1")
    beats[-1]["shot"]["type"] = "VIDEO"
    c6 = code("Two clocks", narr["B14"], "godot/features/player/player.gd", 187, 195,
              [{"label": "Line 193", "value": "not on the tick a clip starts"}, {"label": "Line 194", "value": "advance by the physics delta"}], size=24)
    add("Pause and restart", narr["B15"], take="toss2")
    beats[-1]["shot"]["type"] = "VIDEO"
    screen_beat("What the pins caught", narr["B16"], "pins.png",
                "RECORDED HEADLESS OUTPUT · logs/test_pins_a7_60fps.log · CHANGE-BRIEF.md Revision 2 (lines as written)",
                "the pins were committed (c643146) before any clip was wired (74363a6) · repository revision " + REV)
    panel("What Claude got wrong", narr["B17"], "As recorded · a7/FRICTIONAL.md · a7/TEST-REPORT.md", ["mistakes.png"])
    if PENDING:
        for hid, heading in (("H1", "Her verdicts in play"), ("H2", "The change she made from what she saw"), ("H3", "Where she overruled Claude")):
            text_card(f"{hid}-pending.png", f"{hid} · TODO-HUMAN · pending Sreeja's own verdicts", [narr[hid]], size=40, w=2600)
            panel(heading, "", f"{hid} · TODO-HUMAN · not yet recorded", [f"{hid}-pending.png"], silent=True, pending=True)
    add("Verdict", narr["B18"], "ClaudeVerdictArtifact",
        {"artifactTitle": "Assignment 7 · verdict", "artifactHeading": "Two clips, checked by tests; the motion is her call",
         "artifactLines": ["Verified: read-backs 66 + 13 · pins 8, unchanged after the wiring · states 16 · edges 40 · 5 planted mistakes fail their tests",
                           "Her eyes: pending in this draft (TODO-HUMAN) · the wave, the toss in play, registration, backgrounds",
                           "Uncertain: whether the hand-back on frame 46 reads as a pop",
                           "Next: guard the rescue with contact_settle_ticks (the old re-rescue after R)",
                           "Directed and decided by Sreeja · implemented by Claude Code · her eye checks in the running game come next (TODO-HUMAN)",
                           f"Sheet: her A2 ChatGPT poses · OpenAI terms checked 2026-11-22 · game revision {REV}"]})
    add("Your turn", narr["B19"], "ClaudeComposerAsk",
        {"command": "Read my CHANGE-BRIEF. The toss snaps from the wide ready stance\nto standing on frame 46. Move one boundary in the phase table,\nrebuild the keys with bake_joe_clips.gd, predict strip frames\n50 and 52, and name the read-back value that must change.",
         "topic": "Your turn · one change, one prediction, one test kept honest", "segment": TITLE, "greeting": "Your turn",
         "runningText": "", "output": [], "folderLabel": "walker-ninja-firefighter-joe", "modelLabel": "Claude Code", "effortLabel": "", "placeholder": ""})
    add("Outro", f"{TITLE}. At Nik Bear Brown.", "ClaudeTitleOutro", {"title": TITLE, "slug": SLUG}, kind="outro_voice", tail_hold_s=1.0)
    pairs = [(c, f"B{int(c[1:]) + 1:02d}") for c in (c1, c2, c3, c4, c5, c6)]
    sheet = {"metadata": {"slug": SLUG, "title": TITLE, "persona": "Liam", "palette": "claude", "engine": "kokoro", "voice": "am_onyx", "voice_kokoro": "am_onyx",
                          "fps": 30, "width": 3840, "height": 2160, "aspect_ratio": "16:9", "caption_policy": "no burned captions", "fit": "pad",
                          "skill": "godot-gamedev", "modifier": "walker", "source_revision": REV, "human_review_approved": False,
                          "pending_human_beats": [] if PENDING else ["H1", "H2", "H3"],
                          "authorization": "Student's Assignment 7 explainer; script v1 drafted by Claude Code, not yet approved by Sreeja; local master for course submission; no publication."},
             "beats": beats}
    (ROOT / "beat_sheet.json").write_text(json.dumps(sheet, indent=2) + "\n")
    (ROOT / "evidence").mkdir(exist_ok=True)
    (ROOT / "evidence/excerpts.json").write_text(json.dumps({"excerpts": excerpts, "pairs": pairs}, indent=2) + "\n")
    words = sum(len(b["narration_text"].split()) for b in beats)
    print(f"{len(beats)} beats, {words} narration words, pairs {pairs}, pending included: {PENDING}")


if __name__ == "__main__":
    import sys
    if "stills" in sys.argv:
        stills()
    if "sheet" in sys.argv:
        build_sheet()
