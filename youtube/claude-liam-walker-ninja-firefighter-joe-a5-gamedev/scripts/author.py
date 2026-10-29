"""Author the A5 film: evidence stills from real repository files + beat_sheet.json (written by Claude Code).

    <brutalist .venv python> scripts/author.py stills sheet

Narration is SCRIPT-DRAFT.md v4, approved by Sreeja ("approved"). Code excerpts are copied verbatim from the frozen
source revision REV with `git show`, so they match the hashed files in gamedev-evidence.json. Every still is built
from a file in this repository: in-engine captures (viewport reads), Sreeja's own screenshots, the committed logs,
the brief and the materials audit. No value on a card is typed from memory: numbers are read from the files named.
"""
import json
import re
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parents[1]
REV = "e8c2a30"
TITLE = "Extinguisho's Hand-Written Shaders"
SLUG = ROOT.name
STILLS = ROOT / "media" / "stills"
SCREENS = ROOT / "media" / "screens"
CAP = REPO / "a5" / "evidence" / "captures"
EV = REPO / "a5" / "evidence"
FONT = str(ROOT / "remotion/public/Inter-Regular.ttf")
MONO = str(ROOT / "remotion/public/PTMono-Regular.ttf")
INK, BG, ACC = (61, 57, 41), (250, 249, 245), (190, 89, 58)


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
        c = Image.open(card).convert("RGB")
        c = fit_box(c, 1220, 1760)
        out.paste(c, (3840 - 80 - c.width, 80 + (1760 - c.height) // 2))
    out.save(SCREENS / name)


def screen_stack(name, images, captions, card):
    """A full-frame 3840x2160 still: a row of real captures (captions under each) and a cream card below, full width.
    The bottom 280 px are left free for the provenance plate added in build.py. Used where a figure would mix
    captured game pixels with designed text: the capture stays a capture, the text stays on a cream card."""
    out = Image.new("RGB", (3840, 2160), (29, 29, 29))
    d = ImageDraw.Draw(out)
    ims = [Image.open(STILLS / i).convert("RGB") for i in images]
    each = (3680 - 60 * (len(ims) - 1)) // len(ims)
    x = 80
    for im, cap in zip(ims, captions):
        im = fit_box(im, each, 1060)
        out.paste(im, (x + (each - im.width) // 2, 80 + (1060 - im.height) // 2))
        d.text((x + (each - im.width) // 2, 1150), cap, font=font(40), fill=(255, 253, 247))
        x += each + 60
    c = fit_box(Image.open(card).convert("RGB"), 3680, 560)
    out.paste(c, (80, 1270))
    out.save(SCREENS / name)


# Window pixels of the named texels in the glow captures (a5/evidence/captures/capture_glow_output.jsonl): P1 (458, 445).
GLOW_BOX = (458 - 130, 445 - 165, 458 + 130, 445 + 95)          # 260 x 260 around Extinguisho
# The two hydrants in the hydrant captures (hydrant_output.jsonl): rusty body at (441, 344), fresh at (838, 344).
HYD_BOX = (250, 60, 1030, 640)                                     # both hydrants, 780 x 580
RUSTY_BOX = (250, 60, 640, 640)                                    # the rusty one alone, 390 x 580


def stills():
    STILLS.mkdir(parents=True, exist_ok=True)
    SCREENS.mkdir(parents=True, exist_ok=True)

    # B02 — the game, the state, the object (her screenshot + an engine capture + a card)
    state = text_card("state.png", "One game, one state, one object",
                      ["Game: Extinguisho (walker-ninja-firefighter-joe), Godot 4.7.2, GL Compatibility",
                       "State: player.hosing — set by godot/game/session.gd every physics tick while water_ticks > 0",
                       "The driver reads it; nothing writes back",
                       "3D object: the A3 hydrant in scenes3d/props_room.tscn (the game is 2D)",
                       "Left: my screenshot of the game while hosing · Right: engine capture of the two hydrants"],
                      size=42, w=1200, folder=SCREENS)
    # Her OS screenshot is a whole-desktop capture; only the game window is evidence, so the film shows that crop.
    game_win = crop(EV / "playtest-hosing.png", (557, 295, 1445, 840), 1, "playtest-game-window.png")
    screen("game.png", [STILLS / "playtest-game-window.png", CAP / "hydrant" / "side_by_side.png"], card=state)

    # B03 — the brief (CHANGE-BRIEF.md A2/A3, v1 committed 2026-10-28)
    text_card("brief.png", "CHANGE-BRIEF.md · v1 committed 2026-10-28, before any shader or prompt",
              ["The colour line:   COLOR.rgb = mix(COLOR.rgb, glow_color.rgb, glow);",
               "glow        float   hint_range(0.0, 1.0)   default 0.0   set by the driver from player.hosing",
               "glow_color  vec4    source_color           default vec4(0.6, 0.85, 1.0, 1.0)",
               "R3  0 → 1 in 0.25 s, 1 → 0 in 0.25 s, tolerance one frame     R4  same game time at 30 / 60 / 144 fps",
               "R5  state begins again mid-transition: ignore               R7  state ends mid-ramp: fade from the current value",
               "Evidence split: R1–R5, R7 by headless test · time scale and the look by eye · 3 pixels × 3 values predicted by hand"],
              mono=True, size=27, w=2300)

    # B05 — the colour line, measured (engine captures cropped on him, magnified 3x, pixels kept as pixels)
    for v in ("0.0", "0.5", "1.0", "2.0"):
        crop(CAP / f"glow_{v}.png", GLOW_BOX, 3, f"glow-{v}.png", nearest=True)
    text_card("glow-table.png", "Predicted by hand (CHANGE-BRIEF A4) vs measured in-engine (TEST-REPORT) · RGB",
              ["pixel         glow 0.0               glow 0.5               glow 1.0               glow 2.0 (from code)",
               "P1 chest      229, 29, 25 → 227, 29, 25     191,123,140 → 190,123,140   153,217,255 → 153,217,255   77,255,255 → 79,255,255",
               "P2 shadow     141, 14, 9  → 143, 15, 10     147,116,132 → 148,116,133   153,217,255 → 153,217,255   165,255,255 → 163,255,255",
               "largest difference: 2 levels (tolerance ±3 at P1, ±5 at P2) · glow 2.0 read back 2.0: hint_range did not clamp"],
              mono=True, size=26, w=2600)

    screen_stack("glow.png", ["glow-0.0.png", "glow-0.5.png", "glow-1.0.png", "glow-2.0.png"],
                 ["glow 0.0", "glow 0.5", "glow 1.0", "glow 2.0 (set from code)"], STILLS / "glow-table.png")

    # B08 — textures as information (the real files, downscaled; provenance and import settings from the repo)
    T = REPO / "godot/art/textures/rusty_metal_sheet"
    for k in ("diff", "rough", "nor_gl"):
        Image.open(T / f"rusty_metal_sheet_{k}_1k.png").convert("RGB").resize((700, 700), Image.LANCZOS).save(STILLS / f"tex-{k}.png")
    text_card("provenance.png", "Provenance · godot/art/textures/rusty_metal_sheet/ATTRIBUTION.md · import settings from the .import files",
              ["Poly Haven · Rusty Metal Sheet (rusty_metal_sheet) · Amal Kumar · CC0 1.0 · checked 2026-10-28 · 1K PNG",
               "diff  colour    sampled with source_color                 compress/mode=0 Lossless · normal_map=2 · mipmaps=true",
               "rough data      hint_default_white, no source_color       compress/mode=0 · normal_map=2 · mipmaps=true",
               "nor_gl data     hint_normal, no source_color              compress/mode=0 · normal_map=1 Enable · mipmaps=true",
               "all five .import files: detect_3d/compress_to=0 (set, not Detect) · the _nor_dx twin is bound to nothing (curl-check calibration only)"],
              mono=True, size=25, w=2500)

    # B10 — interface sweep (the rusty hydrant alone, cropped from the real captures) + her verdict
    for k in ("rust_amount_min", "rust_amount_default", "rust_amount_max", "uv_scale_min", "uv_scale_max",
              "roughness_scale_min", "roughness_scale_max", "normal_strength_min", "normal_strength_max"):
        crop(CAP / "hydrant" / f"sweep_{k}.png", RUSTY_BOX, 1, f"sweep-{k}.png")
    text_card("sweep-verdict.png", "Sampled body pixel (5×5 mean) per sweep · a5/TEST-REPORT.md · my verdict by eye",
              ["rust_amount        0 → (99, 29, 21)   0.3 → (109, 58, 47)   1 → (133, 131, 113)",
               "uv_scale           0.25 → (129, 108, 76) one big smear   ·   8 → (129, 118, 98) a fine tile",
               "roughness_scale    0 → (127, 117, 99)   2 → (128, 119, 101)      normal_strength    0 → (130, 120, 103)   2 → (130, 121, 104)",
               "My words: roughness and normal-strength sweeps showed \"no difference I could see\" under this one sun; the sampled pixel moved 1–3 levels.",
               "Wired (the test and the rust/uv sweeps prove the material reaches the shader); this lighting does not show them. Recorded, not hidden."],
              mono=True, size=25, w=2500)

    screen_stack("sweep.png", [f"sweep-{k}.png" for k in ("rust_amount_min", "rust_amount_default", "rust_amount_max", "uv_scale_min", "uv_scale_max", "roughness_scale_min", "roughness_scale_max")],
                 ["rust 0", "rust 0.3", "rust 1", "uv 0.25", "uv 8", "roughness 0", "roughness 2"], STILLS / "sweep-verdict.png")

    # B11 — two materials, one shader (real captures, both hydrants) + the .tres values
    for k in ("side_by_side", "material_edit_rust_0", "shader_edited"):
        crop(CAP / "hydrant" / f"{k}.png", HYD_BOX, 1, f"two-{k}.png")
    text_card("tres.png", "godot/materials/hydrant_fresh.tres · hydrant_rusty.tres · both: shader = res://shaders/hydrant_surface.gdshader",
              ["fresh   rust_amount = 0.1   roughness_scale = 0.7    bound through the glb importer's Use External (a reimport keeps it)",
               "rusty   rust_amount = 0.9   roughness_scale = 1.4    surface_material_override/0 on a second hydrant instance (x = −1.6)",
               "same three textures · paint_tint, normal_strength, uv_scale left at the shader's defaults",
               "edit one value (rusty rust_amount → 0): rusty body (130,121,103) → (99,29,21), fresh unchanged (115,43,33)",
               "edit one shader line (ALBEDO × vec3(0.5, 1.0, 1.5), then git checkout): fresh → (57,43,48), rusty → (63,121,157): both changed"],
              mono=True, size=25, w=2500)

    screen_stack("two.png", ["two-side_by_side.png", "two-material_edit_rust_0.png", "two-shader_edited.png"],
                 ["as saved", "one value in one material", "one shader line (then restored)"], STILLS / "tres.png")

    # B13 — the hint experiment, predicted and measured
    Image.open(CAP / "hint_experiment.png").convert("RGB").save(STILLS / "hint.png")
    text_card("hint-table.png", "Predicted (CHANGE-BRIEF Part B, assuming Forward+/Mobile) vs measured (capture_hint.gd, GL Compatibility)",
              ["band in file     colour quad (source_color)   predicted 64 / 128 / 192   measured 64 / 128 / 192",
               "                 data quad (no hint)           predicted 137 / 188 / 225  measured 64 / 128 / 192",
               "encode(x) = 1.055·x^(1/2.4) − 0.055 would lift 0.251 → 137, 0.502 → 188, 0.753 → 225 on a linear pipeline",
               "Compatibility shades 3D in sRGB space: no decode on sample, no encode on output → both quads show the file (brief F10, measured first)"],
              mono=True, size=25, w=2500)

    # B14 — Godot's own shader beside hers (lines copied from the two files at REV)
    g = lambda n: src_lines("godot/shaders/standard_generated.gdshader", n, n).strip()
    h = lambda n: src_lines("godot/shaders/hydrant_surface.gdshader", n, n).strip()
    text_card("generated-pairs.png", "godot/shaders/standard_generated.gdshader (Godot 4.7.2 wrote it)   ↔   godot/shaders/hydrant_surface.gdshader (Sreeja typed it)",
              [f"generated  3   {g(3)}",
               f"hers       1   {h(1)}",
               "",
               f"generated  7   {g(7)}",
               f"hers       3   {h(3)}",
               "               colour: source_color decodes the texels (on a linear renderer)",
               "",
               f"generated 19   {g(19)}",
               f"hers       5   {h(5)}",
               "               data: no source_color; hint_roughness_normal / hint_normal both say \"normal map, read as stored\"",
               "",
               f"generated 35   {g(35)}",
               f"hers      21   {h(21)}"],
              mono=True, size=25, w=2600)

    # B15 — what the tests proved (recorded lines from the committed logs; nothing retyped)
    rows = []
    for fps in (30, 60, 144):
        rows += [f"logs/test_hose_glow_{fps}fps.log:  " + ln for ln in log_lines(f"logs/test_hose_glow_{fps}fps.log", r"^HOSE GLOW TESTS")]
    rows += ["a5/evidence/mutations/mutation-1-semicolon_60fps.log:  " + ln[:150] for ln in log_lines("a5/evidence/mutations/mutation-1-semicolon_60fps.log", r"SHADER ERROR|^HOSE GLOW TESTS")][:2]
    rows += ["a5/evidence/mutations/mutation-2-rename_60fps.log:  " + ln[:150] for ln in log_lines("a5/evidence/mutations/mutation-2-rename_60fps.log", r"^HOSE GLOW TESTS")]
    rows += ["a5/evidence/mutations/test_materials_fresh_cache_60fps.log:  " + ln for ln in log_lines("a5/evidence/mutations/test_materials_fresh_cache_60fps.log", r"^MATERIALS TESTS")]
    rows += ["a5/evidence/mutations/mutation-3-source_color_60fps.log:  " + ln[:150] for ln in log_lines("a5/evidence/mutations/mutation-3-source_color_60fps.log", r"^FAIL sampler-hints|^MATERIALS TESTS")]
    rows += ["logs/calibrate_normal_maps_60fps.log:  " + ln for ln in log_lines("logs/calibrate_normal_maps_60fps.log", r"curl_ratio|^PASS calibration")]
    rows += ["each mutation: shader restored with git checkout; git diff --stat godot/shaders/ empty (TEST-REPORT)"]
    text_card("tests.png", f"RECORDED HEADLESS OUTPUT · scripts/run-test.sh · Godot 4.7.2 · revision {REV}", rows, mono=True, size=20, w=2700)

    # B16 — what Claude got wrong (as recorded)
    text_card("mistakes.png", "The agent's recorded mistakes, and where each is logged",
              ["1  capture_glow.gd sampled sky twice: W during the 30-tick respawn stance, then the 2× canvas_items stretch between game and window pixels forgotten · a5/FRICTIONAL.md",
               "2  the audit asserted a source_color linearisation the Compatibility renderer never performs (F-5) · godot/MATERIALS.md, review commit 35ef3ff",
               "3  the audit quoted VRAM megabyte figures that were computed, not measured (F-7): deleted · godot/MATERIALS.md",
               "4  the brief's pause rule (\"holds its value\") was unattainable with a _process-driven ramp; the test showed it · CHANGE-BRIEF Revision 4",
               "every agent session: git diff --stat godot/shaders/ → empty; the session's final result event read for max-turns and denials · a5/sessions/*.jsonl"],
              size=30, w=2500)


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

    def panel(heading, text, label, images, captions=None, note=None, row_h=900, **extra):
        """Brutalist GodotDesignFigure: one figure per beat; `images` is a row, or a list of rows stacked vertically."""
        bid = f"B{len(beats):02d}"
        name = f"{bid}-figure.png"
        rows = images if isinstance(images[0], list) else [images]
        caps = iter(captions or [])
        built = []
        for r in rows:
            ims = [fit(Image.open(STILLS / i).convert("RGB"), row_h) for i in r]
            W = sum(i.width for i in ims) + 60 * (len(ims) - 1)
            row_im = Image.new("RGB", (W, row_h + (90 if captions else 0)), (255, 253, 247))
            d = ImageDraw.Draw(row_im)
            x = 0
            for i in ims:
                row_im.paste(i, (x, 0))
                c = next(caps, None)
                if c:
                    d.text((x + 8, row_h + 20), c, font=font(40), fill=INK)
                x += i.width + 60
            built.append(row_im)
        W = max(r.width for r in built)
        built = [r.resize((W, round(r.height * W / r.width)), Image.LANCZOS) if r.width != W else r for r in built]
        fig = Image.new("RGB", (W, sum(r.height for r in built) + 50 * (len(built) - 1)), (255, 253, 247))
        y = 0
        for r in built:
            fig.paste(r, (0, y))
            y += r.height + 50
        fig.save(STILLS / name)
        cards = [{"label": f"{k + 1}", "text": c[:46]} for k, c in enumerate((captions or [])[:4])] or [{"label": "Source", "text": label.split(" · ")[0][:46]}]
        status = label
        while len(status) > 84 and " · " in status:          # the status pill truncates; cut at a separator, keep the full label below
            status = status.rsplit(" · ", 1)[0]
        props = {"title": heading, "status": status, "image": name, "imageLabel": note or "", "source": label, "cards": cards}
        return add(heading, text, "GodotDesignFigure", props, still=name, **extra)

    def screen_beat(heading, text, still, title, sub):
        bid = add(heading, text, take="screen", screen_still=still, screen_title=title, screen_sub=sub,
                  screen_card_below=still in ("glow.png", "sweep.png", "two.png"))
        beats[-1]["shot"]["type"] = "SCREEN"
        return bid

    def code(heading, text, path, a, b, notes):
        body = src_lines(path, a, b)
        bid = add(heading, text, "GodotDevWorkbench", {"mode": "code", "title": heading, "project": "walker-ninja-firefighter-joe",
                  "path": path.removeprefix("godot/"), "source": f"Godot editor reconstruction · exact source, revision {REV} · next: the visible result",
                  "code": body, "startLine": a, "codeFontSize": 30, "notes": notes, "output": [f"{path} lines {a}–{b}"], "cues": []})
        excerpts.append({"beat_id": bid, "path": path.removeprefix("godot/"), "start_line": a, "end_line": b, "text": body})
        return bid

    add("The prompt", "Please use Walker to turn my firefighter game's hosing state into a glow on the character, and give its hydrant a real surface. This is Liam, in for Bear. Assignment Five for C S Y E seventy-two seventy.",
        "ClaudeComposerAsk", {"command": "Please use Walker to convert my game design document\nabout a deadpan ninja firefighter into two hand-written shaders:\na glow while he hoses, and a textured hydrant.",
                              "topic": "Illustrative reconstruction, not a session transcript", "segment": TITLE, "greeting": "Hello", "runningText": "", "output": [],
                              "folderLabel": "walker-ninja-firefighter-joe", "modelLabel": "Claude Code", "effortLabel": "", "placeholder": ""})
    add("What was built", "Two hand-written shaders for a two-D Godot game. The idea underneath: a texture is not a picture the shader shows. It is a table of numbers the shader reads, and one word on the sampler decides whether those numbers are colour or data.",
        "BrutalistHesitantWriter", {"text": "Two hand-written shaders for a Godot game.\nA texture is a picture the shader shows.", "triggerWords": "picture shows", "replacementWords": "table reads",
                                    "fontSize": 72, "mistakeRate": 0, "hesitateWithin": 0, "hesitateBetween": 0, "charMs": 55, "jitter": 0, "seed": SLUG, "face": "serif", "align": "center"},
        lead_silence_s=0.8)
    screen_beat("The game, the state, the object", "Extinguisho is Sreeja's deadpan ninja firefighter, Godot four point seven, Compatibility renderer. One state drives the effect: player dot hosing, true while the water runs on the fire that blocks the first survivor. The shader only reads it. The three-D object is the Assignment Three hydrant in the props room, because the game itself is two-D.",
                "game.png", "My screenshot of the game while hosing · engine capture of the two hydrants (viewport read)", "a5/evidence/playtest-hosing.png · a5/evidence/captures/hydrant/side_by_side.png")
    panel("The brief came first", "Before any shader or any prompt, Sreeja committed a brief. It names the one line of shading language that makes the effect, two uniforms with type, hint and default, and rules a test can measure: a quarter-second ramp at any frame rate, a second W ignored, a fade from wherever the value is. Each rule says whether a test or her eyes will check it.",
          "CHANGE-BRIEF.md · v1 committed 2026-10-28 · before any shader or prompt", ["brief.png"])
    c1 = code("What a shader is", "A shader is a small program the G P U runs for every pixel at once, and it remembers nothing between pixels. Sreeja typed these eight lines herself. Line three declares a dial called glow, with a range and a default. Line seven is the whole effect: slide this pixel's colour toward pale blue by however far the dial is turned. Alpha is untouched, so his outline keeps its shape.",
              "godot/shaders/hose_glow.gdshader", 1, 8, [{"label": "Line 3", "value": "the dial: float, 0–1, default 0"}, {"label": "Line 7", "value": "the colour line from the brief"}])
    screen_beat("The colour line, measured", "From that one line, the brief worked out by hand what three named pixels should become. The engine captures, read from the viewport rather than screenshots, match within a few levels. Then glow set to two from code: the pixels overshoot to cyan. The range hint shapes the Inspector slider; it does not clamp what the game sets.",
                "glow.png", "Engine captures · viewport reads, driver frozen · magnified 3×, pixels kept · predicted vs measured", "a5/evidence/captures/glow_*.png · CHANGE-BRIEF A4 · a5/TEST-REPORT.md")
    c2 = code("The driver", "Claude Code wrote the driver, with the shader folder locked. One material per player, on the sprite only, so the rescue bag on his back stays orange. Each frame it reads hosing and picks a target: zero, or a gentle breath between point four and point eight, then moves toward it by the frame's delta, so the ramp takes the same game time at any frame rate. It never writes game state.",
              "godot/features/player/hose_glow.gd", 28, 36, [{"label": "Reads", "value": "player.hosing (never writes it)"}, {"label": "Line 35", "value": "move_toward by delta / 0.25 s"}])
    add("In play, and her revision", "The running game, recorded by Movie Maker with scripted key presses, labelled as such. W at the fire: the water starts and he brightens into a pale blue breath, the suit still visible at the low end. When the water stops, a quarter-second fade. The breath is her revision: at a held full glow she called him a block of ice blue, so revision three changed the number the game feeds the dial. The shader did not change.",
        take="hose")
    beats[-1]["shot"]["type"] = "VIDEO"      # raw engine video (Movie Maker), not designed typography
    panel("Textures as information", "Three textures from Poly Haven, C C zero, by Amal Kumar, with source, licence and date in a credits file beside them. The colour map is a photo of rusting steel. The roughness map and the normal map look like pictures too, but they are tables: how matte each spot is, which way it slopes. Import settings set by hand, not left on Detect, and the OpenGL normal map, the convention Godot expects.",
          "The real files · godot/art/textures/rusty_metal_sheet/ · ATTRIBUTION.md · .import files",
          [["tex-diff.png", "tex-rough.png", "tex-nor_gl.png"], ["provenance.png"]],
          ["diff: colour (source_color)", "rough: data, near white = matte", "nor_gl: data, slopes as colour"], row_h=700)
    c3 = code("The textured shader", "Her spatial shader. Line three samples the photo as colour, with source colour. Lines four and five have no such hint: the roughness and normal maps are read exactly as stored. That one word is the difference between a picture and information. Below, five dials with ranges and defaults in two Inspector groups, paint and surface; the fragment function below them mixes paint and rust and hands roughness and normal to Godot's lighting.",
              "godot/shaders/hydrant_surface.gdshader", 3, 16, [{"label": "Line 3", "value": "colour: source_color"}, {"label": "Lines 4–5", "value": "data: read as stored"}])
    screen_beat("The interface sweep", "Every dial at its minimum, default and maximum, captured in the engine under the scene's single sun. Rust amount walks the body from painted red to the raw photo. U V scale goes from one big smear to a fine tile. Roughness and bump strength barely moved the sampled pixel, and by eye she saw no difference: wired, the test shows that, but this lighting does not show them. Recorded as found.",
                "sweep.png", "Engine captures · the rusty hydrant at each dial's min / default / max · props_room Sun + ambient only", "a5/evidence/captures/hydrant/sweep_*.png · a5/TEST-REPORT.md")
    screen_beat("Two materials, one shader", "Here is how a material differs from a shader. One shader; two resource files, each holding its own dial values and textures. Fresh is mostly paint and slightly glossy; rusty is mostly photo and matte. Edit one value in one file: one hydrant changes. Edit one line of the shader: both change. Her verdict: the rusty one reads real, the red one reads cartoon.",
                "two.png", "Engine captures · rusty (left, x = −1.6) and fresh (right, x = −0.8) · one shader, two .tres files", "a5/evidence/captures/hydrant/ · godot/materials/hydrant_*.tres")
    c4 = code("The hint experiment", "The experiment, in its own scene. A committed script writes a three-pixel grey strip. Two samplers bind that same file, one marked as colour, one not, and a switch picks which paints the quad. Two unshaded quads, a linear tonemap at exposure one. The brief predicted the data quad would come out lighter, if the renderer does its maths in linear light.",
              "godot/shaders/hint_experiment.gdshader", 3, 12, [{"label": "Line 3 vs 4", "value": "same file, one hint apart"}, {"label": "Scene", "value": "Linear tonemap, exposure 1.0, unshaded"}])
    panel("Predicted, measured", "Measured: the two quads are identical. The prediction assumed Forward Plus. This project runs Compatibility, which shades in s R G B space: nothing is decoded going in or encoded coming out, so the hint changes nothing on screen here. The brief had this down as a predicted failure case: measure first, then explain.",
          "Engine capture · a5/evidence/captures/hint_experiment.png · samples in capture_hint_output.jsonl",
          [["hint.png"], ["hint-table.png"]], ["left: as colour (source_color) · right: as data · the 64 band matches the 0.25-grey background"])
    panel("Godot's own shader", "Godot can write a shader from a Standard Material; Sreeja converted one in the editor. Line seven: the albedo sampler, marked as colour, her line three. Line nineteen: the normal sampler, marked as data under a different hint name, her line five. This is what the Godot shading language is: G L S L with a shader type instead of main, named outputs like albedo and roughness, and hints that shape the Inspector.",
          f"Exact lines from both files at revision {REV} · standard_generated.gdshader (Godot) · hydrant_surface.gdshader (hers)", ["generated-pairs.png"])
    panel("What the tests proved", "The glow test presses W and R as real input and samples the dial every frame; fifteen checks at thirty, sixty and one forty-four. The material test, written after an audit she reviewed, pins shader paths, sampler hints and import settings, and passes from an empty cache. Three sabotages: a deleted semicolon, a renamed uniform, source colour removed. All three exit one. Proven: parse, names, timing, wiring. Not proven: a single pixel.",
          "Recorded headless output · logs/ and a5/evidence/mutations/ · nothing retyped", ["tests.png"])
    panel("What Claude got wrong", "The agent's mistakes, caught in review. The capture script sampled sky twice. The audit claimed a colour conversion this renderer never performs, and quoted memory figures nobody measured; both corrected. The brief's own pause rule turned out unattainable; the test showed it, revision four says so. After every session, the shader folder's diff was empty.",
          "As recorded · a5/FRICTIONAL.md · godot/MATERIALS.md · CHANGE-BRIEF.md Revision 4", ["mistakes.png"])
    add("Verdict", "The verdict. Verified: three hand-typed shaders parse and match their spec; the pixel predictions hold; the driver at three frame rates through real events; three mutations fail; the materials survive a reimport. Uncertain: whether roughness above one is clamped, and whether a source-colour uniform converts under Compatibility. Next, in her words: a better hydrant mesh. Sreeja specified, typed, looked and decided; Claude Code drafted, drove, tested and audited. Source revision on screen.",
        "ClaudeVerdictArtifact", {"artifactTitle": "Assignment 5 · verdict", "artifactHeading": "Two shaders, predicted and measured",
                                  "artifactLines": ["Verified: 3 shaders parse · colour line = spec · pixels within tolerance · 15/15 at 30/60/144 · 3 mutations exit 1 · materials survive reimport",
                                                    "Uncertain: ROUGHNESS > 1 clamped? · source_color uniform under Compatibility?",
                                                    "Claude got wrong: sky samples ×2 · unverified linearisation claim · computed VRAM figures",
                                                    "Next: a better hydrant mesh (my words)",
                                                    "Sreeja: specified, typed, looked, decided · Claude Code: drafted, drove, tested, audited",
                                                    f"Source revision {REV}"]})
    add("Your turn", "Your turn. Read my change brief. The roughness and normal-strength sliders showed nothing under one sun. Plan a second light for the props room, predict which hydrant pixel changes most, and name the assertion in test materials that must not change. One bounded change, one prediction, one test kept honest. This has been Liam, in for Bear.",
        "ClaudeComposerAsk", {"command": "Read my CHANGE-BRIEF. The roughness and normal-strength sliders showed\nnothing under one sun. Plan a second light for the props room, predict\nwhich hydrant pixel changes most, and name the assertion in\ntest_materials.gd that must not change.",
                              "topic": "Your turn · one bounded change, one prediction, one test kept honest", "segment": TITLE, "greeting": "Your turn",
                              "runningText": "", "output": [], "folderLabel": "walker-ninja-firefighter-joe", "modelLabel": "Claude Code", "effortLabel": "", "placeholder": ""})
    add("Outro", f"{TITLE}. At Nik Bear Brown.", "ClaudeTitleOutro", {"title": TITLE, "slug": SLUG}, kind="outro_voice", tail_hold_s=1.0)
    pairs = [(c, f"B{int(c[1:]) + 1:02d}") for c in (c1, c2, c3, c4)]
    sheet = {"metadata": {"slug": SLUG, "title": TITLE, "persona": "Liam", "palette": "claude", "engine": "kokoro", "voice": "am_onyx", "voice_kokoro": "am_onyx",
                          "fps": 30, "width": 3840, "height": 2160, "aspect_ratio": "16:9", "caption_policy": "no burned captions", "fit": "pad",
                          "skill": "godot-gamedev", "modifier": "walker", "source_revision": REV, "human_review_approved": False,
                          "authorization": "Student's Assignment 5 explainer; script v4 approved by Sreeja; local 4K master for course submission; no publication."},
             "beats": beats}
    (ROOT / "beat_sheet.json").write_text(json.dumps(sheet, indent=2) + "\n")
    (ROOT / "evidence").mkdir(exist_ok=True)
    (ROOT / "evidence/excerpts.json").write_text(json.dumps({"excerpts": excerpts, "pairs": pairs}, indent=2) + "\n")
    words = sum(len(b["narration_text"].split()) for b in beats)
    print(f"{len(beats)} beats, {words} narration words (~{words / 150:.1f} min at 150 wpm), pairs {pairs}")


if __name__ == "__main__":
    import sys
    if "stills" in sys.argv:
        stills()
    if "sheet" in sys.argv:
        build_sheet()
