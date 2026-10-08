"""Author the film recipe: evidence stills from real project files + beat_sheet.json (written by Claude Code).

    python scripts/author.py        # Pillow, numpy, soundfile; git; run from anywhere

Code excerpts are copied verbatim from the frozen source commit (REV) with `git show`, so they
match the hashed files in gamedev-evidence.json. Stills are built only from files in this
repository (design images, accepted/rejected generations, screenshots, audio files).
"""
import json
import subprocess
from pathlib import Path

import numpy as np
import soundfile as sf
from PIL import Image, ImageDraw, ImageFont, ImageOps

ROOT = Path(__file__).resolve().parents[1]
GAME = ROOT.parents[1]                      # walker-ninja-firefighter-joe/
REPO = GAME.parents[3]
REV = "241c3f2"
GPATH = "fall-2026/sreeja-p/assignment-2/walker-ninja-firefighter-joe/godot"
TITLE = "Extinguisho: Generated Art, Sound, and Music in Godot"
SLUG = ROOT.name
STILLS = ROOT / "media" / "stills"
FONT = str(ROOT / "remotion/public/Inter-Regular.ttf")
MONO = str(ROOT / "remotion/public/PTMono-Regular.ttf")
INK, BG, ACC = (61, 57, 41), (250, 249, 245), (190, 89, 58)


def font(n, mono=False):
    return ImageFont.truetype(MONO if mono else FONT, n)


def src_lines(path, a, b):
    text = subprocess.check_output(["git", "show", f"{REV}:{GPATH}/{path}"], cwd=REPO, text=True)
    return "\n".join(text.split("\n")[a - 1:b])


def text_card(name, title, lines, mono=False, w=1700, size=34):
    lh = int(size * 1.45)
    wrapped = []
    for ln in lines:
        words, cur = ln.split(" "), ""
        maxc = int(w / (size * (0.6 if mono else 0.52)))
        for wd in words:
            if len(cur) + len(wd) + 1 > maxc:
                wrapped.append(cur)
                cur = wd
            else:
                cur = (cur + " " + wd).strip()
        wrapped.append(cur)
    h = 90 + lh * len(wrapped) + 40
    im = Image.new("RGB", (w, h), (255, 253, 247))
    d = ImageDraw.Draw(im)
    d.text((36, 26), title, font=font(30), fill=ACC)
    for i, ln in enumerate(wrapped):
        d.text((36, 90 + i * lh), ln, font=font(size, mono), fill=INK)
    im.save(STILLS / name)


def fit(im, h):
    return im.resize((max(1, round(im.width * h / im.height)), h), Image.LANCZOS)


def row(name, paths, h=520, gap=30, arrows=False):
    ims = [fit(Image.open(p).convert("RGB"), h) for p in paths]
    w = sum(i.width for i in ims) + gap * (len(ims) - 1) + (60 * (len(ims) - 1) if arrows else 0)
    out = Image.new("RGB", (w, h), BG)
    x = 0
    d = ImageDraw.Draw(out)
    for k, i in enumerate(ims):
        out.paste(i, (x, 0))
        x += i.width + gap
        if arrows and k < len(ims) - 1:
            d.text((x + 4, h // 2 - 30), "→", font=font(56), fill=ACC)
            x += 60
    out.save(STILLS / name)


def waveform(name, files, labels, h=170, w=1700, highlight=None):
    out = Image.new("RGB", (w, h * len(files) + 10), BG)
    d = ImageDraw.Draw(out)
    for k, (f, lab) in enumerate(zip(files, labels)):
        data, rate = sf.read(f)
        mono = data.mean(axis=1) if data.ndim > 1 else data
        dur = len(mono) / rate
        y0 = k * h + 10
        if highlight:
            a, b = highlight
            d.rectangle([int(a / dur * (w - 300)) + 300, y0, int(b / dur * (w - 300)) + 300, y0 + h - 20], fill=(244, 222, 206))
        cols = w - 300
        step = max(1, len(mono) // cols)
        for x in range(cols):
            seg = mono[x * step:(x + 1) * step]
            if len(seg):
                m = float(np.abs(seg).max())
                d.line([(300 + x, y0 + (h - 20) / 2 - m * (h - 30) / 2), (300 + x, y0 + (h - 20) / 2 + m * (h - 30) / 2)], fill=INK)
        d.text((10, y0 + h / 2 - 34), lab, font=font(26), fill=INK)
        d.text((10, y0 + h / 2 + 2), f"{dur:.2f} s", font=font(22), fill=ACC)
    out.save(STILLS / name)


def stills():
    STILLS.mkdir(parents=True, exist_ok=True)
    D, C, R, S, E = GAME / "design", GAME / "design/character", GAME / "rejected", GAME / "evidence/screens", GAME / "evidence/compare"
    # Design first: storyboard grid and the sheet strips.
    sb = sorted((D / "storyboard").glob("*.png"))
    thumbs = [fit(Image.open(p).convert("RGB"), 300) for p in sb]
    grid = Image.new("RGB", (4 * 540, 2 * 320), BG)
    for i, t in enumerate(thumbs):
        grid.paste(t, ((i % 4) * 540, (i // 4) * 320))
    grid.save(STILLS / "storyboard-grid.png")
    Image.open(C / "silhouette-x4.png").convert("RGB").save(STILLS / "silhouette.png")
    # One reference → poses → game texture.
    row("pipeline.png", [C / "side-profile-game.png", C / "poses/pose09-toss.png", GAME / "godot/art/character/toss.png"], h=560, arrows=True)
    # The traced asset.
    Image.open(D / "storyboard/03b-throw.png").convert("RGB").save(STILLS / "panel-3b.png")
    Image.open(R / "CHAR-TOSS-pose09-sideways.png").convert("RGB").save(STILLS / "toss-raw.png")
    Image.open(C / "poses/pose09-toss.png").convert("RGB").save(STILLS / "toss-9b.png")
    text_card("toss-prompt.png", "Pose 9 prompt, try 1 (with side-profile-game.png attached) · CHARACTER-SHEET.md",
              ["Pose: Standing, his right arm flung back over his shoulder with an open hand, as if he just tossed something behind him without looking. His other hand covers his mouth mid-yawn, eyes squeezed shut, completely bored. Nobody else in the image, just him."], size=32)
    text_card("toss-edit.png", "Edit 9b (attached: the try-1 image) · CHARACTER-SHEET.md",
              ["Change only these:", "1. His throwing arm: flung straight UP above his head, fully extended toward the sky, open hand with fingers spread, as if he just launched someone very high into the air with one careless toss.",
               "2. Remove the second pouch on his thigh; keep only the one pouch on his belt, like the reference."], size=32)
    # Collision on real screenshots: the first rows of the comparison.
    cmp = Image.open(E / "character-vs-sheet.jpg").convert("RGB")
    cmp.crop((0, 0, cmp.width, 246 * 6)).save(STILLS / "collision-rows.png")
    # Background v1 vs v2 (v1 screenshot from the 2026-10-06 build, kept in the evidence log).
    v1 = Image.open(ROOT / "evidence/env-bg-v1-screenshot.png").convert("RGB")
    v2 = Image.open(S / "state-idle.png").convert("RGB").resize(v1.size)
    v1.save(STILLS / "bg-v1.png")
    v2.save(STILLS / "bg-v2.png")
    row("flames.png", [GAME / "godot/art/env/fire_single.png", GAME / "godot/art/env/fire_wide.png", GAME / "godot/art/env/fire_tall.png"], h=300)
    # Sound and music.
    A = GAME / "godot/audio"
    waveform("sounds.png", [A / f"sfx_{n}.ogg" for n in ["jump", "hose", "rescue", "burn", "win"]], ["jump", "hose", "rescue toss", "fire death", "win"])
    waveform("music-raw.png", [ROOT / "evidence/music_raw.wav"], ["recording (raw)"], h=260, highlight=(14.10, 39.70))
    waveform("music-loop.png", [A / "music_loop.ogg"], ["loop: 16 bars"], h=260)
    # Test output (recorded run of the frozen source).
    log = (ROOT / "evidence/test-output.txt").read_text().strip().split("\n")
    text_card("tests.png", "Recorded output · fresh copy of 241c3f2 · Godot 4.7.2", log, mono=True, size=26)


def build_sheet():
    beats = []
    excerpts = []

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

    def panel(heading, text, label, images, captions=None, note=None, step=None, **extra):
        # Brutalist's GodotDesignFigure: one figure (real captures, generations, diagrams) per beat.
        # Several images are composed side by side into one figure with their captions.
        bid = f"B{len(beats):02d}"
        name = f"{bid}-figure.png"
        ims = [Image.open(STILLS / i).convert("RGB") for i in images]
        H = 900
        ims = [fit(i, H) for i in ims]
        W = sum(i.width for i in ims) + 60 * (len(ims) - 1)
        fig = Image.new("RGB", (W, H + (90 if captions else 0)), (255, 253, 247))
        d = ImageDraw.Draw(fig)
        x = 0
        for k, i in enumerate(ims):
            fig.paste(i, (x, 0))
            if captions and k < len(captions):
                d.text((x + 8, H + 20), captions[k], font=font(44), fill=INK)
            x += i.width + 60
        fig.save(STILLS / name)
        cards = [{"label": f"{k + 1}", "text": c[:46]} for k, c in enumerate((captions or [])[:4])] or [{"label": "Source", "text": label[:46]}]
        props = {"title": heading, "status": label[:90], "image": name, "imageLabel": note or "", "source": label, "cards": cards}
        return add(heading, text, "GodotDesignFigure", props, still=name, **extra)

    def code(heading, text, path, a, b, notes):
        body = src_lines(path, a, b)
        bid = add(heading, text, "GodotDevWorkbench", {"mode": "code", "title": heading, "project": "walker-ninja-firefighter-joe",
                  "path": path, "source": f"Godot editor reconstruction · exact source, revision {REV} · next: the visible result",
                  "code": body, "startLine": a, "codeFontSize": 30, "notes": notes, "output": [f"{path} lines {a}–{b}"], "cues": []})
        excerpts.append({"beat_id": bid, "path": path, "start_line": a, "end_line": b, "text": body})
        return bid

    add("The prompt", "Please use Walker to turn a game design into a playable Godot slice, with generated art, sound, and music. I'm Liam, the narrator voice of the Brutalist toolkit. This is Assignment Two for C S Y E seventy-two seventy, and the game is called Extinguisho.",
        "ClaudeComposerAsk", {"command": "Please use Walker to convert my game design document\nabout a deadpan ninja firefighter racing a forty-second clock\ninto a playable Godot asset slice with generated art, sound, and music.",
                              "topic": "Illustrative reconstruction, not a session transcript", "segment": TITLE, "greeting": "Hello", "runningText": "", "output": [],
                              "folderLabel": "walker-ninja-firefighter-joe", "modelLabel": "Claude Code", "effortLabel": "", "placeholder": ""})
    add("What was built", "Extinguisho is Sreeja's game. It grew out of her Assignment One firefighter platformer: one level, two burning buildings, a forty-second clock, now played by a generated ninja firefighter, with a generated skyline and flames, five generated sound effects, and a looping track. This is an asset slice, not the full game.",
        "BrutalistHesitantWriter", {"text": "A coded character, now generated.", "triggerWords": "coded", "replacementWords": "painted",
                                    "fontSize": 80, "mistakeRate": 0, "hesitateWithin": 0, "hesitateBetween": 0, "charMs": 55, "jitter": 0, "seed": SLUG, "face": "serif", "align": "center"},
        lead_silence_s=0.8)
    panel("Four pillars, designed first", "Extinguisho is grumpy, unimpressed, and fast. Four pillars set the bar for every asset: race the flames, too cool to care, every move is a kata, and failure is a punchline. The storyboard came first, as the specification for every prompt. Its text was committed two minutes after the first sketch; the log says so.",
          "CONCEPT.md · STORYBOARD.md · design before generation", ["storyboard-grid.png"], ["The six storyboard panels (3a–3c: the rescue beats)"])
    panel("The character sheet as a contract", "The character sheet is the contract: twelve labeled poses, a silhouette at real game size, a collision overlay, a five-colour palette, and consistency rules. Every pose came from one reference image, attached to each prompt, so proportions held.",
          "CHARACTER-SHEET.md · silhouette at game size (64 px), enlarged", ["silhouette.png"], ["Every state in solid black at its game size, enlarged four times"])
    panel("One asset, traced: the design", "Let's trace one asset. Storyboard panel three-b is the rescue: he tosses the survivor into his bag without looking, mid-yawn. The first generation did exactly that, sideways. Looking at it, Sreeja changed the idea: the toss should go straight up, sky-high.",
          "Storyboard sketch → prompt → raw generation (rejected)", ["panel-3b.png", "toss-prompt.png", "toss-raw.png"],
          ["Panel 3b (ChatGPT sketch)", "The pose prompt", "Raw output, try 1 (rejected)"])
    panel("The edit, then the texture", "So the next step was an edit, not a new prompt: keep the character and the view, change only the throwing arm. Then a script removes the cream background with a flood fill, scales every pose by one shared factor, and records an anchor at the feet. A hundred and twenty-eight pixel texture, drawn at half size.",
          "Edit prompt → edited generation (accepted) → game texture (tools/make_sprites.py)", ["toss-edit.png", "pipeline.png"],
          ["Edit 9b: change only the arm", "Reference → accepted 9b → background removed, game texture"])
    c1 = code("One image per state", "In Godot, a state is one static image. Show pose swaps the texture, places it by its feet anchor, and flips the holder's scale when he faces left. No animation: the state change is the image change.",
              "features/player/player.gd", 71, 77, [{"label": "State", "value": "one texture per pose"}, {"label": "Facing", "value": "negative x scale"}])
    add("The toss, in the running game", "And here is that toss in play: the grab, the arm flung up, the survivor spinning skyward and dropping into the bag. The rescue counts the instant he touches the survivor; the arc is drawn afterwards, so it can never change what happens.",
        take="rescue")
    c2 = code("Choosing the state", "Update pose decides which image shows. Timed action poses come first, then air, then ground. A jump is one kick from takeoff to touchdown, then a landing held for a third of a second. That rule came from a playtest where three poses flashed in one jump.",
              "features/player/player.gd", 85, 112, [{"label": "Air", "value": "kick, or the fall if no jump"}, {"label": "Ground", "value": "landing → run → hose → idle"}])
    add("Every state in play", "Every state, in real play: the respawn stance, idle, run, the flying kick, the landing, the hose, the grab and the toss, the bow, facing left, the meditating fall after a missed jump, and burned. The crane crouch stayed on the sheet; in play it flashed by too fast to read.",
        take="montage")
    c3 = code("The collision box", "Collision is a separate object from the art. The box is twenty by forty game units, centred twenty above the feet, sized from the crouching poses so it never floats above his head while he runs.",
              "features/player/player.gd", 48, 56, [{"label": "Box", "value": "20 × 40, feet at the origin"}, {"label": "Not the art", "value": "a separate shape"}])
    panel("Art against the box", "Drawn on real screenshots, the helmet, the kick, and the hose reach past the box. That only forgives the player. Art smaller than the box would kill without visible contact; there is none.",
          "Diagnostic overlay on in-engine screenshots (cyan = collision box) · evidence/compare", ["collision-rows.png"])
    panel("A background that hid him", "The environment is generated too: a skyline behind the level and three flame images keyed out from flat green. One change shows cause and effect. The first background's orange glow sat at his height and hid his red suit. Regenerated as a cool blue-grey haze, the colour difference at the worst spot rose from thirty-one to eighty-five.",
          "Screenshots: ENV-BG v1 (2026-10-06 build) → ENV-BG v2 (revision 241c3f2)", ["bg-v1.png", "bg-v2.png"],
          ["v1: suit vs background, worst spot ΔE 31", "v2: ΔE 85, same character"])
    panel("Five sounds, cleaned the same way", "Five sound events: jump, hose, rescue, the fire death, and the win. Each was trimmed to start instantly, brought to minus fourteen L U F S with a limiter just under full scale, and saved as Ogg Vorbis.",
          "ElevenLabs Sound Effects (elevenlabs.io) → tools/make_audio.sh → godot/audio", ["sounds.png"])
    c4 = code("A sound follows its event", "Each sound plays from the code that already represents its event, after the state changes: the burn plays once the game is already dying. The guards that stop a double death also stop a double sound, and nothing in the game reads a sound back.",
              "game/session.gd", 194, 211, [{"label": "Order", "value": "state first, then the sound"}, {"label": "Guard", "value": "only while PLAYING"}])
    add("Burned, then back", "Here is that branch in play: the fire touches him, the burned pose and the devastated close-up hold for two seconds, and he is back at the start in his ready stance.",
        take="fire")
    add("Game audio, no narration", "", take="audio", clock="source", audio_policy="preserve")
    panel("Sixteen bars that loop", "For the music, Sreeja kept the second version, with the taiko drums and plucked strings the ninja idea needed. At a hundred and fifty beats per minute one bar is one point six seconds; sixteen bars were cut where the last bar best matches the first, with a ten millisecond crossfade at the seam.",
          "Eleven Music recording → loop 14.10–39.70 s → godot/audio/music_loop.ogg", ["music-raw.png", "music-loop.png"],
          ["The recording; the highlighted window becomes the loop", "The loop: 25.6 s, crossfaded seam"])
    c5 = code("The music follows the game", "Music and effects run on two separate audio buses. The music plays while you play, pauses in place, dips under the burn, carries on after a retry without restarting, and stops at the win. N mutes the music, B the effects.",
              "game/session.gd", 561, 575, [{"label": "Buses", "value": "Music and SFX, muted separately"}, {"label": "Keys", "value": "N music · B effects"}])
    add("Readable with the sound off", "With both muted, the game still reads: music off and sound off in the corner, a help bubble at the window, saved when he grabs someone, and every death names its reason on screen.",
        take="muted")
    panel("What the tests prove", "Verification ran from a fresh copy. The added sound test steps the game one physics tick at a time: thirteen jumps make thirteen jump sounds, one hose, two rescues, one win. Muted, or with every sound file removed, the route ends the same, tick for tick. Whether the sounds feel right took a human listen.",
          "Recorded test output, not a reconstruction", ["tests.png"])
    add("Verdict", "The verdict. Working: eleven generated states on real events, a generated environment, five sounds that each fire once, a seamless loop, and separate mutes. Limits: his face doesn't read at sixty-four pixels, so the punchlines live in two close-ups, and the level and survivors are still drawn in code. ChatGPT made the images, ElevenLabs the sounds and music, Claude Code the code and tests. The choices were Sreeja's. Revision two-four-one-c-three-f-two.",
        "ClaudeVerdictArtifact", {"artifactTitle": "Assignment 2 · verdict", "artifactHeading": "Generated, wired, tested",
                                  "artifactLines": ["11 generated states · ENV-BG v2 · 3 flames", "5 sounds, one per event · 16-bar loop · N/B mutes",
                                                    "Limits: face unreadable at 64 px; level drawn in code", "Images: ChatGPT · Sound: elevenlabs.io · Music: created in collaboration with ElevenLabs",
                                                    "Code, prompts, tests: Claude Code · Film: Brutalist", "Source revision 241c3f2"]})
    add("Your turn", "Your turn, one step toward the full game: falling deaths are silent today. Ask Walker for a fall pose and its own sound, wired into the state that already exists. Predict what could fire twice, and let the sound test prove it. This has been Liam, from Brutalist.",
        "ClaudeComposerAsk", {"command": "Read my CHANGE-BRIEF and add a fall state and sound for 'You fell.':\ngenerate the pose from my side-profile reference, wire the sound\nto the existing DYING branch, and predict which test catches a double sound.",
                              "topic": "Your turn · one bounded change plus a prediction", "segment": TITLE, "greeting": "Your turn", "runningText": "", "output": [],
                              "folderLabel": "walker-ninja-firefighter-joe", "modelLabel": "Claude Code", "effortLabel": "", "placeholder": ""})
    add("Outro", f"{TITLE}. At Nik Bear Brown.", "ClaudeTitleOutro", {"title": TITLE, "slug": SLUG}, kind="outro_voice", tail_hold_s=1.0)
    pairs = [(c, f"B{int(c[1:]) + 1:02d}") for c in (c1, c2, c3, c4, c5)]   # each code beat → the next beat
    sheet = {"metadata": {"slug": SLUG, "title": TITLE, "persona": "Liam", "palette": "claude", "engine": "kokoro", "voice": "am_onyx", "voice_kokoro": "am_onyx",
                          "fps": 30, "width": 3840, "height": 2160, "aspect_ratio": "16:9", "caption_policy": "no burned captions", "fit": "pad",
                          "skill": "godot-gamedev", "modifier": "walker", "source_revision": REV, "human_review_approved": False,
                          "authorization": "Student's Assignment 2 explainer; local 4K master for course submission; no publication."},
              "beats": beats}
    (ROOT / "beat_sheet.json").write_text(json.dumps(sheet, indent=2) + "\n")
    (ROOT / "evidence/excerpts.json").write_text(json.dumps({"excerpts": excerpts, "pairs": pairs}, indent=2) + "\n")
    words = sum(len(b["narration_text"].split()) for b in beats)
    print(f"{len(beats)} beats, {words} narration words (~{words / 150:.1f} min at 150 wpm), pairs {pairs}")


if __name__ == "__main__":
    import sys
    if "stills" in sys.argv:
        stills()
    if "sheet" in sys.argv:
        build_sheet()
