"""Author the A3 film: evidence stills from real repository files + beat_sheet.json (written by Claude Code).

    <brutalist .venv python> scripts/author.py stills sheet

Narration is SCRIPT-DRAFT.md v2, approved by Sreeja ("approved, voice it and render").
Code excerpts are copied verbatim from the frozen source revision REV with `git show`, so they match the hashed
files in gamedev-evidence.json. Every still is built from a file in this repository.
"""
import json
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parents[1]
REV = "71a24c0"
TITLE = "Extinguisho's First 3D Props"
SLUG = ROOT.name
STILLS = ROOT / "media" / "stills"
SCREENS = ROOT / "media" / "screens"          # full-frame stills of real app windows (Blender, Godot): SCREEN shots
EV = REPO / "a3" / "evidence"
FONT = str(ROOT / "remotion/public/Inter-Regular.ttf")
MONO = str(ROOT / "remotion/public/PTMono-Regular.ttf")
INK, BG, ACC = (61, 57, 41), (250, 249, 245), (190, 89, 58)


def font(n, mono=False):
    return ImageFont.truetype(MONO if mono else FONT, n)


def src_lines(path, a, b):
    text = subprocess.check_output(["git", "show", f"{REV}:{path}"], cwd=REPO, text=True)
    return "\n".join(text.split("\n")[a - 1:b])


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


def screen(name, images, card=None):
    """A full-frame 3840x2160 still of real app screenshots (side by side), optionally with a cream text card on the right.
    The bottom 280 px are left free for the provenance label added in build.py."""
    out = Image.new("RGB", (3840, 2160), (29, 29, 29))
    area_w = 3840 - (1300 if card else 0) - 160
    ims = [Image.open(i if isinstance(i, Path) else EV / i).convert("RGB") for i in images]
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


def stills():
    STILLS.mkdir(parents=True, exist_ok=True)
    SCREENS.mkdir(parents=True, exist_ok=True)
    Image.open(REPO / "evidence/screens-web/03-jump.jpg").convert("RGB").save(STILLS / "game-2d.png")
    Image.open(EV / "godot-props-scene-camera.png").convert("RGB").save(STILLS / "props-scene.png")
    text_card("brief.png", "CHANGE-BRIEF v1 · committed 10:01, before any building",
              ["Scale: Extinguisho 64 px → 1.8 m → 0.028 m per px",
               "Hydrant 0.4 × 0.4 × 0.8 m · ≤ 400 tris · red + grey",
               "Rescue bag 0.6 × 0.3 × 0.3 m · ≤ 300 tris · game orange (Rev 2: backpack 0.36 × 0.31 × 0.61)",
               "Rooftop ledge 2.5 × 1.0 × 0.45 m (Rev 3: replaced by a flame 0.36 × 0.27 × 0.62, ≤ 400)",
               "Origin: bottom centre, at Blender's world origin",
               "P1 lies on its side · P2 sinks into the floor · P3 colours lost in export · P4 MCP won't connect"],
              mono=True, size=29, w=1900)
    text_card("mcp-error.png", "MCP setup · my FRICTIONAL log",
              ["$ claude mcp add -e DISABLE_TELEMETRY=true blender -- uvx mcp-for-blender",
               "→ Invalid environment variable format: blender",
               "$ claude mcp add blender -e DISABLE_TELEMETRY=true -- uvx mcp-for-blender",
               "Added stdio MCP server blender ✓",
               "get_addon_status: polyhaven off · sketchfab off · polypizza off · hyper3d off · hunyuan3d off · tripo off · telemetry false"],
              mono=True, size=36, w=1200, folder=SCREENS)
    text_card("hydrant-plan.png", "Claude's plan for the hydrant · approved: \"ok\"",
              ["base   cylinder 16 sides   60 tris", "body   cylinder 16 sides   60 tris", "cap    UV sphere 12×6     120 tris",
               "nut    cylinder 8 sides    28 tris", "2 × outlet cylinder 12    88 tris", "total 356 (default UV sphere alone: 960)",
               "join → origin to world origin → apply rotation & scale"], mono=True, size=30, w=1100)
    for k in ("hydrant-angles-v1", "hydrant-my-viewport-check", "bag-angles-v1", "bag-angles-v2", "bag-angles-v3-backpack",
              "bag-angles-v4-rounded-backpack", "ledge-angles-v1", "flame-angles-v1", "flame-angles-v6", "flame-angles-v8c",
              "flame-single-v2b-grey", "flame-single-v2b-coloured"):
        Image.open(EV / f"{k}.png").convert("RGB").save(STILLS / f"{k}.png")
    text_card("flame-brief.png", "My second flame brief (excerpt)",
              ["Start with ONLY ONE flame shape.", "A wide, rounded, bulbous bottom.", "An asymmetric S-shaped curve.",
               "One tip that curls sideways.", "Do NOT extrude and scale a circle to a point.", "Show it in solid gray. STOP and wait for my approval."],
              size=34, w=1000)
    hand_card = text_card("hand-edit.png", "My hand edit · Edit Mode, by mouse",
                          ["Vertex select → the tip vertex", "G, X: move along global X", "D: 0.188830 m along global X",
                           "tip X −0.15 → +0.04", "still 48 tris, on the floor"], mono=True, size=44, w=1200, folder=SCREENS)
    my_words = text_card("my-look.png", "My human check in Godot (my words)",
                         ["\"I like the different shades of colours in the fire, it looks more realistic.\"",
                          "\"The hydrant is basic.\"", "\"The bag can be better in shape and colours.\"",
                          "\"The backpack and flame can be bigger.\"", "Colours survived the export (P3 did not happen)."], size=46, w=1200, folder=SCREENS)
    # SCREEN stills (real Blender / Godot windows, full frame)
    screen("blender-session.png", ["blender-session.png"])
    screen("mcp.png", ["mcp-panel-services-off.png"], card=SCREENS / "mcp-error.png")
    screen("hand-edit.png", ["hand-edit-flame-2-moving-along-x.png"], card=hand_card)
    screen("godot-look.png", ["godot-my-human-check.png"], card=my_words)
    why = text_card("why.png", "Why these three", ["Left: my 2D game (A2 screenshot)", "Right: the three props in Godot (A3)",
                    "Flame: the game's main hazard", "Backpack: the rescue bag on his back", "Hydrant: the burning street"], size=46, w=1200, folder=SCREENS)
    screen("why.png", [REPO / "evidence/screens-web/03-jump.jpg", EV / "godot-props-scene-camera.png"], card=why)
    screen("hydrant.png", [EV / "hydrant-angles-v1.png", EV / "hydrant-my-viewport-check.png"], card=STILLS / "hydrant-plan.png")
    bag = text_card("bag.png", "Rescue bag, left to right", ["v1: a barrel (handle buried)", "v2: a duffel", "v3: a boxy backpack",
                    "v4: rounded backpack — final, 296 tris", "Claude's renders (MCP look)"], size=46, w=1200, folder=SCREENS)
    screen("bag.png", [EV / f"{k}.png" for k in ("bag-angles-v1", "bag-angles-v2", "bag-angles-v3-backpack", "bag-angles-v4-rounded-backpack")], card=bag)
    out = (REPO / "a3/evidence/check-props-output.txt").read_text().strip().split("\n")
    text_card("check-output.png", f"HEADLESS · godot/tests/run_check_props.sh · Godot 4.7.2 · revision {REV}", out, mono=True, size=21, w=2300)
    mut = (REPO / "a3/evidence/check-props-mutate.txt").read_text().strip().split("\n")
    text_card("check-mutate.png", "HEADLESS · planted faults (mutate mode): must FAIL", mut, mono=True, size=21, w=2300)


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

    def panel(heading, text, label, images, captions=None, note=None, **extra):
        """Brutalist GodotDesignFigure: one figure per beat; `images` is a row, or a list of rows stacked vertically."""
        bid = f"B{len(beats):02d}"
        name = f"{bid}-figure.png"
        rows = images if isinstance(images[0], list) else [images]
        caps = iter(captions or [])
        built = []
        for r in rows:
            ims = [fit(Image.open(STILLS / i).convert("RGB"), 900) for i in r]
            W = sum(i.width for i in ims) + 60 * (len(ims) - 1)
            row_im = Image.new("RGB", (W, 900 + (90 if captions else 0)), (255, 253, 247))
            d = ImageDraw.Draw(row_im)
            x = 0
            for i in ims:
                row_im.paste(i, (x, 0))
                c = next(caps, None)
                if c:
                    d.text((x + 8, 920), c, font=font(44), fill=INK)
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
        props = {"title": heading, "status": label[:90], "image": name, "imageLabel": note or "", "source": label, "cards": cards}
        return add(heading, text, "GodotDesignFigure", props, still=name, **extra)

    def screen_beat(heading, text, still, title, sub):
        bid = add(heading, text, take="screen", screen_still=still, screen_title=title, screen_sub=sub)
        beats[-1]["shot"]["type"] = "SCREEN"
        return bid

    def code(heading, text, path, a, b, notes):
        body = src_lines(path, a, b)
        bid = add(heading, text, "GodotDevWorkbench", {"mode": "code", "title": heading, "project": "walker-ninja-firefighter-joe",
                  "path": path.removeprefix("godot/"), "source": f"Godot editor reconstruction · exact source, revision {REV} · next: the visible result",
                  "code": body, "startLine": a, "codeFontSize": 30, "notes": notes, "output": [f"{path} lines {a}–{b}"], "cues": []})
        excerpts.append({"beat_id": bid, "path": path.removeprefix("godot/"), "start_line": a, "end_line": b, "text": body})
        return bid

    add("The prompt", "Please use Walker to turn a 2D firefighter game into its first three 3D props. I'm Liam, the narrator voice of the Brutalist toolkit. This is Assignment Three for C S Y E seventy-two seventy.",
        "ClaudeComposerAsk", {"command": "Please use Walker to convert my game design document\nabout a deadpan ninja firefighter into three simple 3D props:\na fire hydrant, a rescue backpack and a flame.",
                              "topic": "Illustrative reconstruction, not a session transcript", "segment": TITLE, "greeting": "Hello", "runningText": "", "output": [],
                              "folderLabel": "walker-ninja-firefighter-joe", "modelLabel": "Claude Code", "effortLabel": "", "placeholder": ""})
    add("What was built", "Extinguisho is Sreeja's Godot game. For this assignment she directed Claude Code through the Blender M C P server, driving a live Blender five point two session, to model three low-poly props: a fire hydrant, a rescue backpack and a flame. Each was exported as binary glTF and verified in a Godot four point seven 3D scene.",
        "BrutalistHesitantWriter", {"text": "Three props, sketched in 2D.", "triggerWords": "sketched in 2D", "replacementWords": "built in 3D",
                                    "fontSize": 80, "mistakeRate": 0, "hesitateWithin": 0, "hesitateBetween": 0, "charMs": 55, "jitter": 0, "seed": SLUG, "face": "serif", "align": "center"},
        lead_silence_s=0.8)
    screen_beat("Why these three", "Each prop maps to something in the game. The flame is the core hazard. The backpack is the rescue bag drawn on his back, where survivors land. The hydrant belongs on the burning street. The game is 2D, so the props live in a separate 3D scene for now.",
                "why.png", "My screenshot of the 2D game (A2) · the three props rendered in Godot (A3)", "evidence/screens-web/03-jump.jpg · a3/evidence/godot-props-scene-camera.png")
    panel("The brief came first", "Before any geometry, Sreeja committed a brief. Extinguisho is sixty-four pixels tall; she fixed him at one point eight metres, about two point eight centimetres per pixel. Each prop got dimensions in metres, a bottom-centre origin, flat colours and a triangle budget under five hundred, plus four predicted failures, each with a check.",
          "a3/CHANGE-BRIEF.md · v1 commit 7578374, 10:01, before building", ["brief.png"])
    screen_beat("Learning the window", "First she explored Blender by hand. Blender is Z-up; Godot is Y-up. And the default cube's origin sits at its centre, so its base is one metre below the grid. That observation became prediction two: a prop that sinks into the floor.",
                "blender-session.png", "My screenshot · my own Blender 5.2.2 session, before any prompting", "a3/BLENDER-NOTES.md · a3/evidence/blender-session.png")
    screen_beat("Connecting the M C P", "The setup line in the assignment failed: Claude Code's dash e option accepts several values, and swallowed the server name. Putting the name first fixed it. The add-on listened on localhost, port nine eight seven six, with every asset library and generator disabled.",
                "mcp.png", "My screenshot · MCP for Blender 1.8 panel: services off", "a3/FRICTIONAL.md, MCP table · server mcp-for-blender 2.1.9")
    screen_beat("A prompt and what it built", "One asset per request, plan first. For the hydrant Claude proposed six primitives with reduced segment counts: three hundred fifty-six triangles, against a default sphere's nine hundred sixty. After her approval, each part was one execute blender code call, then a join, an origin set to the world origin, and transform apply, leaving scale at one.",
                "hydrant.png", "Claude's render (MCP look) · my viewport check (my screenshot) · the plan I approved", "tools/blender/build_hydrant.py · a3/evidence/hydrant-*.png")
    screen_beat("Barrel to backpack", "The bag shows the limit of numbers. Version one matched its brief dimensions within two centimetres, yet read as a barrel, with the handle torus buried inside the body. Sreeja asked what the bag is for: it rides on his back. Three revisions later it is a rounded backpack, two hundred ninety-six triangles.",
                "bag.png", "Claude's renders (MCP look) · rescue bag v1 → v4", "tools/blender/build_rescue_bag.py · CHANGE-BRIEF Revisions 1–2")
    panel("Ledge to flame", "Her third prop began as a ledge derived from the level data, ninety by sixteen pixels. It matched the brief, and was, in her words, nothing interesting, so she swapped it for a flame. Built from stacked primitives, version after version read as a Christmas tree, crystals or spikes.",
          "Claude's renders (MCP look) · CHANGE-BRIEF Revisions 3–5", [["ledge-angles-v1.png", "flame-angles-v1.png"], ["flame-angles-v6.png", "flame-angles-v8c.png"]],
          ["The ledge (swapped)", "Flame v1: a tree", "v6: spikes", "v8c: crystals"])
    panel("One flame first", "So she changed the method. One mesh, built in bmesh from hexagonal cross-sections with independent left and right widths, approved in grey before colour. Faces were coloured by height and by normal direction, brighter in the centre. Forty-eight triangles.",
          "My brief → grey shape I approved → colours · CHANGE-BRIEF Revision 6", ["flame-brief.png", "flame-single-v2b-grey.png", "flame-single-v2b-coloured.png"],
          ["My brief", "Approved in grey", "Final colours"])
    screen_beat("Her hand edit", "Then her own edit, in the viewport. Edit mode, vertex select, the tip vertex, G then X: a constrained move along global X of nought point one nine metres. On screen the drag ran toward the centre, because an axis's screen direction depends on the view. She kept the straighter flame.",
                "hand-edit.png", "My screenshots · my hand edit in Blender, by mouse", "a3/evidence/hand-edit-flame-*.png · CHANGE-BRIEF Revision 7")
    c1 = code("Three props in one scene", "Export used the glTF exporter with plus Y up and transforms applied. In the scene file each prop is an instanced dot G L B with an identity basis; only the origin column moves. No rotation, no scale. A one point eight metre cylinder stands in for Extinguisho.",
              "godot/scenes3d/props_room.tscn", 48, 55, [{"label": "Basis", "value": "identity: no rotation, scale 1"}, {"label": "Origin", "value": "x −0.8 / 0 / 0.8, y 0"}])
    add("In the engine", "This is the running engine, recorded by Movie Maker at a fixed thirty frames per second. Upright, grounded, at game scale beside the pole. Blender's Z-up became Godot's Y-up, so prediction one did not happen.", take="orbit")
    c2 = code("The headless check", "The headless check pushes every mesh's bounding box through its global transform, so a rotated or scaled node can't hide behind a correct mesh. Then it tests size within a centimetre of the brief, every scale at one, height along Y, the bottom against the floor surface, and the triangle count.",
              "godot/tests/check_props.gd", 51, 58, [{"label": "Pass if", "value": "size, scale, upright, on floor, tris"}, {"label": "Tolerance", "value": "0.01 m"}])
    panel("The numbers, labelled headless", "Headless, all three pass, matching the brief to the millimetre. Mutation mode plants three faults: a hydrant rotated ninety degrees, a bag scaled two times, a flame lowered twenty centimetres. All three fail. And one trap: Godot exited with code zero when the script failed to parse, so the runner now requires a printed pass.",
          "Recorded headless output · a3/evidence/check-props-output.txt, check-props-mutate.txt", [["check-output.png"], ["check-mutate.png"]],
          ["Real scene: RESULT PASS", "Planted faults: all three FAIL"])
    screen_beat("What the check can't see", "The check proves geometry, not appearance. Sreeja's own review in the editor: the fire's colour shades read as realistic, the hydrant is basic, the backpack's shape and colours could improve, and the backpack and flame could be larger. Materials survived the export, so prediction three did not happen.",
                "godot-look.png", "My screenshot · my human check in the Godot 4.7.2 editor", "a3/TEST-REPORT.md §7 · a3/evidence/godot-my-human-check.png")
    add("Verdict", f"The verdict. Verified in Blender and headless Godot: dimensions, unit scale, Y-up orientation, grounded origins and triangle budgets. Uncertain: whether the props suit the game's art style. Claude's errors: a buried handle, spiky flames, a camera basis written in the wrong order, and a check that passed without running. Sreeja directed, decided and reviewed; Claude Code proposed and implemented. Source revision on screen.",
        "ClaudeVerdictArtifact", {"artifactTitle": "Assignment 3 · verdict", "artifactHeading": "Three props, measured and reviewed",
                                  "artifactLines": ["Verified: size · scale 1 · Y-up · origin on floor · tris 356 / 296 / 48",
                                                    "Uncertain: does it suit the game's art style?",
                                                    "Claude got wrong: buried handle · spiky flames · camera basis · exit-0 check",
                                                    "Next: bigger, better backpack (my Godot check)",
                                                    "Sreeja: directed, decided, reviewed · Claude Code: proposed, implemented",
                                                    f"Source revision {REV}"]})
    add("Your turn", "Your turn. Take the backpack Sreeja flagged. Ask Walker for a plan that improves its shape and colours and scales it up, then update the brief and predict which assertion in the headless check would catch a mistake. This has been Liam, from Brutalist.",
        "ClaudeComposerAsk", {"command": "Read my CHANGE-BRIEF and plan a better backpack: rounder shape,\na second colour band, scaled up. Update the brief first, then predict\nwhich assertion in check_props.gd would catch a mistake.",
                              "topic": "Your turn · one prop, one brief revision, one prediction", "segment": TITLE, "greeting": "Your turn",
                              "runningText": "", "output": [], "folderLabel": "walker-ninja-firefighter-joe", "modelLabel": "Claude Code", "effortLabel": "", "placeholder": ""})
    add("Outro", f"{TITLE}. At Nik Bear Brown.", "ClaudeTitleOutro", {"title": TITLE, "slug": SLUG}, kind="outro_voice", tail_hold_s=1.0)
    pairs = [(c, f"B{int(c[1:]) + 1:02d}") for c in (c1, c2)]
    sheet = {"metadata": {"slug": SLUG, "title": TITLE, "persona": "Liam", "palette": "claude", "engine": "kokoro", "voice": "am_onyx", "voice_kokoro": "am_onyx",
                          "fps": 30, "width": 3840, "height": 2160, "aspect_ratio": "16:9", "caption_policy": "no burned captions", "fit": "pad",
                          "skill": "godot-gamedev", "modifier": "walker", "source_revision": REV, "human_review_approved": False,
                          "authorization": "Student's Assignment 3 explainer; script approved by Sreeja; local 4K master for course submission; no publication."},
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
