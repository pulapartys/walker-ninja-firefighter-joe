# walker-ninja-firefighter-joe

My CSYE 7270 game, built up one assignment at a time. Each assignment is a git tag: **`a2`** (generated art, sound and music; submitted from the class repo at commit `50a1797`), **`a3`** (three simple 3D props).

## Assignment 3 — first 3D assets

Three props for my game, built in Blender by directing Claude Code through the Blender MCP, exported as `.glb`, and shown together in a small Godot 3D scene: a **fire hydrant**, the **rescue bag** (a backpack — it rides on Extinguisho's back), and a **flame** (the game's main hazard). My game is 2D, so the props live in their own 3D scene (`godot/scenes3d/props_room.tscn`), which Assignments 4 and 5 reuse; it is not connected to the 2D game yet.

**Docs** in [`a3/`](a3/): [CHANGE-BRIEF](a3/CHANGE-BRIEF.md) (v1 committed before building; Revisions 1–7) · [BLENDER-NOTES](a3/BLENDER-NOTES.md) · [TEST-REPORT](a3/TEST-REPORT.md) · [FRICTIONAL](a3/FRICTIONAL.md) · [SOURCES](a3/SOURCES.md) · evidence in `a3/evidence/`.

**Versions:** Blender 5.2.2 LTS · MCP for Blender server `mcp-for-blender` 2.1.9 / add-on 1.8 (MCP route for all three props) · Godot 4.7.2 stable · macOS 26.6.2 (Apple M1).

### What this assignment added

| Path | What |
|---|---|
| `blender/hydrant.blend`, `rescue_bag.blend`, `flame.blend` | the three props' Blender sources (dropped/earlier versions: `rooftop_ledge.blend`, `rescue_bag_v2_duffel.blend`, `flame_v8c_backup.blend`) |
| `tools/blender/build_*.py`, `export_props.py` | every piece of code Claude ran through the MCP, in order, with my prompt for each |
| `godot/props3d/*.glb` (+ `.import`) | the exported props (+Y Up, transforms applied) |
| `godot/scenes3d/props_room.tscn` | floor, one sun, camera, the three props side by side, a 1.8 m pole for Extinguisho's height |
| `godot/tests/check_props.gd`, `run_check_props.sh`, `capture_props.gd` | the headless check, its strict runner, and the screenshot capture |

| Prop | Size W × D × H (m) | Triangles (budget) | Result |
|---|---|---|---|
| Fire hydrant | 0.40 × 0.36 × 0.80 | 356 (≤ 400) | PASS: size = brief, scale 1, upright, on the floor |
| Rescue bag (backpack) | 0.36 × 0.31 × 0.61 | 296 (≤ 300) | PASS |
| Flame | 0.36 × 0.27 × 0.62 | 48 (≤ 400) | PASS |

**My hand edit** (by mouse, in Blender): moved the flame's tip 0.19 m along X — a straighter, more balanced flame.

### Run the check and open the scene

```
# from the repository root; Godot 4.7 (macOS: ~/Downloads/Godot.app/Contents/MacOS/Godot or /Applications/Godot.app/...)
godot --headless --path godot --import                                         # once, after cloning
timeout 120 godot --headless --path godot --script res://tests/check_props.gd --fixed-fps 60
GODOT=/path/to/Godot godot/tests/run_check_props.sh          # passes only if it prints "RESULT: PASS"
GODOT=/path/to/Godot godot/tests/run_check_props.sh mutate   # planted faults: must FAIL
```

`timeout` comes from Homebrew's coreutils on macOS. **Open the scene:** Godot → Import → `godot/project.godot` → double-click `scenes3d/props_room.tscn` (3D tab). The 2D game still runs as before (`res://game/main.tscn`); its A2 tests still pass.

### Known limitations

- The flame is **one shaped mesh** built from placed cross-sections, not a combination of Blender's basic shapes (eight primitive-based versions read as spikes or crystals).
- My human check in Godot: the hydrant is **basic**, the backpack's **shape and colours** could be better, and the backpack and flame could be **bigger** next to Extinguisho.
- My hand edit straightened the flame, a little against my own brief.
- The headless check proves size, scale, orientation, floor contact and triangle counts; it cannot judge looks or colours (TEST-REPORT §11).

### Film

Brutalist `godot-gamedev` explainer, `walker` mode, native 4K, 5 min 03 s, narrated by Liam: *Extinguisho's First 3D Props*. Source shown: revision `71a24c0` (no file under `godot/` changed after it).

- **Link (Northeastern SharePoint):** https://northeastern-my.sharepoint.com/:f:/g/personal/pulaparty_s_northeastern_edu/IgCRRfU_jATkS6lt-3N-TiA9AWJaRIxoJsFlYlGGe0bTuFw?e=bZXYlw
- **File:** `claude-liam-walker-ninja-firefighter-joe-a3-gamedev.mp4`
- **SHA-256:** `166c184fe0a0663c884d82bac9a53a82f2db8294532a970affcfed98740593b1`
- **Film source** (approved script, beat sheet, evidence ledger, capture and build scripts): [`youtube/claude-liam-walker-ninja-firefighter-joe-a3-gamedev/`](youtube/claude-liam-walker-ninja-firefighter-joe-a3-gamedev/). The MP4 is not in git (course rule).

### Iteration history (every version, what I saw, what I changed)

Full detail in [FRICTIONAL](a3/FRICTIONAL.md) and [CHANGE-BRIEF](a3/CHANGE-BRIEF.md) revisions; pictures in `a3/evidence/`; every code call in `tools/blender/`.

| Asset | Version | What it was | What I saw / decided | Tris |
|---|---|---|---|---|
| Hydrant | v1 (final) | base, body, rounded cap, top nut, two side outlets | reads as a hydrant; accepted | 356 |
| Rescue bag | v1 | cylinder on its side + flap + one ring handle | numbers all passed, but it "looks like a barrel" and the handle was buried → Revision 1 | 264 |
| | v2 | oval body, two strap handles, zip line | looks like a bag — but in my game it rides **on his back**, so I decided on a backpack | 248 |
| | v3 | boxy backpack (body, pocket, lid, two straps, handle) | "more like a box"; also noticed how tiny 0.6 m is on a 1 m grid | 292 |
| | **v4 (final)** | rounded backpack: oval tapered body, rounded flap and pocket, straps, handle | "this one is better" → Revision 2 | 296 |
| Asset 3 | ledge | two boxes from the game's 90 × 16 px ledge, game colours | "fine but it's just a ledge, nothing interesting" → **I swapped it for a flame**, the game's main hazard → Revision 3 | 24 |
| Flame | v1 | stacked yellow / orange / red + two side spikes | "looks like a christmas tree with 2 spikes" → Revision 4 | 336 |
| | v2 | five uneven tongues with bent tips | "not a flame again" | 320 |
| | v3 | **my design:** symmetrical cone base, two bent side spikes, bent top flame on top, extended down to meet the spikes | "not the best", kept as a basic version → Revision 5 | 336 |
| | v4–v4b | three nested star layers from my ChatGPT reference sheet | bud / rocket shape, only red showing | ~360 |
| | v5–v5b | wide bowl + ring of side flames + main flame, colour zones | closer but angular | — |
| | v6 | **my idea:** rings of spikes rising round the centre cone, a star from the top | too thin and pointy | — |
| | v7 | fat, curved overlapping tongues | still crystals | 380 |
| | v8–v8c | rebuilt from scratch to **my written brief** (7 curved tongues, irregular, 100–150 tris) | still sharp crystals / blades | 169 |
| | single v1 | **my second brief:** one flame from placed cross-sections, grey first | "a bent horn" | 40 |
| | single v2–v2b | my changes: bulbous base, S-curve, gradual curl, more depth | shape approved; then my colour brief applied | 48 |
| | **final** | single flame + **my hand edit** (tip moved 0.19 m) | "this is good enough" → Revision 6 | 48 |

## Assignment 2 — asset slice

An asset slice for CSYE 7270 Assignment 2: **Extinguisho**, a deadpan ninja firefighter, has 40 seconds to rescue a person and a dog from two burning buildings: kung-fu jump over flames, hose the fire blocking the way, toss the survivors into his bag, and escape off the roof. The art (and, in progress, the sound and music) is generated with generative models and wired into a playable Godot scene.


## Started from

My Assignment 1 project, `walker-jumpman-joe` (a firefighter rescue platformer), which extended [nikbearbrown/walker-jumpman](https://github.com/nikbearbrown/walker-jumpman) ("First Steps" starter). The Godot project in `godot/` was copied on 2026-10-01 (control and retry engine, state machine, level, hose and rescue mechanics, timer, tests). See SOURCES.md.

## Engine

Godot **4.7.2** stable (GL Compatibility renderer), macOS.

## Run it

1. Install Godot 4.7 or newer.
2. Open `godot/project.godot` in Godot and press Play, **or** from a terminal:
   ```
   <path-to-Godot> --path godot
   ```
   On macOS with Godot in Applications, double-click `walker-jumpman.command`.

Automated tests (from `godot/`):
```
<path-to-Godot> --headless --path . -s tests/test_game.gd       # 41 checks
<path-to-Godot> --headless --path . -s tests/test_keyboard.gd
<path-to-Godot> --headless --path . -s tests/test_audio.gd      # one sound per event; mute changes nothing
<path-to-Godot> --path . -s tests/capture_game.gd               # screenshots of every state -> evidence/screens/
```

## Controls

| Key | Action |
|---|---|
| A / D or ← / → | move |
| Space | jump |
| W | hose the blocking fire (when close) |
| R | retry |
| Esc or P | pause |
| Enter | start / resume / play again |
| M | main menu (from pause or the end card) |
| N | mute / unmute music |
| B | mute / unmute sound effects |

## What the slice demonstrates

- **Character:** 11 generated state images swapped by game state: idle, run, flying-kick jump, meditating fall, landing, hose, rescue grab, upward toss, burned, respawn stance, and a bow at the end. Facing left mirrors the art. Collision box 20×40 (CHARACTER-SHEET.md, collision overlay).
- **Environment:** a generated smoky city skyline (ENV-BG v2) behind the level, and generated flames (ENV-FIRE) on every fire hazard; the fire blocking the person shrinks as it's hosed.
- **Failure punchline and win:** on a fire death (held 2 s; R retries at once) the generated DEVASTATED close-up pops up next to "The fire got you."; on the win, the bow close-up pops up.
- **Sound:** generated sound effects on real game events: jump, hose, rescue toss, fire death, level complete. Each fires exactly once per event (`tests/test_audio.gd`). Muting changes nothing in play.
- **Music:** a 16-bar, 150 BPM generated loop (ElevenLabs Music) that pauses on pause, dips on a fire death, continues on retry, and stops on the win (`tests/test_audio.gd`).
- **Design and evidence:** CONCEPT.md, STORYBOARD.md, CHARACTER-SHEET.md, CHANGE-BRIEF.md (plan and predictions), SOURCES.md (models and asset log), TEST-REPORT.md, ../FRICTIONAL.md (design log), rejected outputs in `rejected/`, in-engine screenshots in `evidence/screens-web/`.

## Known limitations

- The character's face doesn't read at game size (64 px); attitude comes through the poses. The burned pose is dark and subtle on the dark background.
- The level, survivors, rescue bag, and HUD are code-drawn (from A1), not generated.
- Muted, the fire death is understood mainly through its on-screen text ("The fire got you."); the burn sound carries part of that moment (muted playtest).
- The run is slower and the jump floatier than A1 (changed after playtest 2); a fire death holds 2 s (playtest 3), longer than A1's 1 s retry.
- The background was regenerated (ENV-BG v2, cool blue-gray) after playtest 3 so the red-and-yellow character stands out; the burning city now reads through smoke columns and the game's flames rather than an orange sky.
- ChatGPT does not expose seeds, so regenerating an image from its logged prompt gives a similar, not identical, result.
- *(to update after sound, playtest 3, and the film)*

## Film

Brutalist `godot-gamedev` explainer, `walker` mode, native 4K: *Extinguisho: Generated Art, Sound, and Music in Godot*. Source shown: revision `241c3f2`. Film source (script, beat sheet, evidence, capture driver): [`youtube/claude-liam-walker-ninja-firefighter-joe-gamedev/`](youtube/claude-liam-walker-ninja-firefighter-joe-gamedev/).

- **Link (Northeastern SharePoint, course media storage):** https://northeastern-my.sharepoint.com/:f:/g/personal/pulaparty_s_northeastern_edu/IgAIP7WoCQfYQqLBHNgRfXv8ATHXvgLoeUTGjfj3LlelU8w?e=g5m7aQ
- **Filename:** `claude-liam-walker-ninja-firefighter-joe-gamedev.mp4` (3840×2160, 30 fps, 6 min 3 s, 54 MB)
- **SHA-256:** `7c0d484b7aba9e780f0f04dbb1f24b2f9f0551a38210db6a8458ac846c296230`
- The folder name `youtube/` is just Brutalist's name for a film project folder: the film is **not** on YouTube, and the MP4 is not in git (course rule).

## Credits

- Images: generated with ChatGPT (OpenAI).
- Sound effects: generated with ElevenLabs Sound Effects, free plan — **elevenlabs.io**.
- Music: **Created in collaboration with ElevenLabs (Eleven Music)**, free plan; recorded from playback in Audacity, approved by the course staff.
- Details, prompts, and the terms of each model: SOURCES.md.
