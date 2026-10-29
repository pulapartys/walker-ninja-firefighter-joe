# walker-ninja-firefighter-joe

My CSYE 7270 game, built up one assignment at a time. Each assignment is a git tag: **`a2`** (generated art, sound and music; submitted from the class repo at commit `50a1797`), **`a3`** (three simple 3D props), **`a5`** (two hand-written shaders, their materials, and the Godot shading language).

## Assignment 5 — shaders, materials, and the Godot shading language

Two shaders I typed by hand, and the materials that use them. **Extinguisho glows pale blue while he hoses** (a `canvas_item` shader on his sprite, driven from the game's `player.hosing` state by a small script Claude Code wrote), and the **A3 hydrant gets a real surface** (a `spatial` shader that reads Poly Haven's rusty-metal colour, roughness and normal maps, with two materials: freshly painted and rusty). A third small shader is the **hint experiment** (one grey strip sampled as colour and as data), and a fourth is Godot's own, generated from a StandardMaterial3D, which I read and annotated.

**Docs:** [CHANGE-BRIEF](CHANGE-BRIEF.md) (v1 committed before any shader or prompt; Revisions 1–4) · [CLAUDE.md](CLAUDE.md) (agent draft, then my review) · [`a5/`](a5/): [TEST-REPORT](a5/TEST-REPORT.md) · [LANGUAGE-NOTES](a5/LANGUAGE-NOTES.md) · [STANDARD-GENERATED-ANNOTATED](a5/STANDARD-GENERATED-ANNOTATED.md) · [FRICTIONAL](a5/FRICTIONAL.md) · [SOURCES](a5/SOURCES.md) · evidence (captures, mutation logs, playtest screenshots) in `a5/evidence/`, prompts in `a5/prompts/`, `claude -p` transcripts in `a5/sessions/` · [`godot/MATERIALS.md`](godot/MATERIALS.md) (the audit) · texture credits in [`godot/art/textures/rusty_metal_sheet/ATTRIBUTION.md`](godot/art/textures/rusty_metal_sheet/ATTRIBUTION.md).

**Versions:** Godot 4.7.2 stable, GL Compatibility renderer · macOS 26.6.2 (Apple M1) · Claude Code 2.1.285 (`claude-fable-5-1`) for the driver, tests, audit and film.

### What this assignment added

| Path | What |
|---|---|
| `godot/shaders/hose_glow.gdshader` | **mine**, 8 lines: `glow` (float, `hint_range`) and `glow_color` (`source_color`); the colour line `COLOR.rgb = mix(COLOR.rgb, glow_color.rgb, glow);` |
| `godot/features/player/hose_glow.gd` (+ 2-line hook in `player.gd`) | the driver (agent): one `ShaderMaterial` on the sprite; `glow` ramps 0 → band in 0.25 s, breathes 0.4–0.8 at 1 s while hosing, ramps to 0 in 0.25 s after; scaled `delta`, never writes game state |
| `godot/shaders/hydrant_surface.gdshader` | **mine**, 25 lines: `albedo_tex : source_color`, `rough_tex : hint_default_white`, `normal_tex : hint_normal`; five dials in `paint` and `surface` groups |
| `godot/materials/hydrant_fresh.tres`, `hydrant_rusty.tres` | two materials, one shader: rust 0.1 / roughness 0.7 vs 0.9 / 1.4; fresh bound through the glb importer's Use External, rusty as a surface override on a second hydrant in `props_room.tscn` |
| `godot/art/textures/rusty_metal_sheet/` | Poly Haven *Rusty Metal Sheet* (Amal Kumar, CC0), `diff` / `rough` / `nor_gl` bound, `nor_dx` for calibration only; explicit `.import` settings; `ATTRIBUTION.md` |
| `godot/shaders/hint_experiment.gdshader`, `materials/hint_as_*.tres`, `scenes3d/hint_experiment.tscn`, `tests/write_grey_strip.gd`, `art/hint/grey_3x1.png` | **mine** (the shader): the hint experiment, Linear tonemap at exposure 1.0 |
| `godot/shaders/standard_generated.gdshader`, `scenes3d/scratch_standard.tscn` | Godot's generated shader from a converted StandardMaterial3D; nothing in the game uses it |
| `godot/tests/test_hose_glow.gd` | agent: 15 checks through real input events at 30 / 60 / 144 fps |
| `godot/tests/test_materials.gd`, `normal_map_check.gd`, `calibrate_normal_maps.gd` | agent audit test (35 checks), the assignment's curl check, its calibration on the GL / DX pair |
| `godot/tests/capture_glow.gd`, `capture_hint.gd`, `capture_hydrant.gd` | windowed in-engine captures (viewport reads) behind every pixel value in TEST-REPORT |
| `scripts/run-test.sh` | the test wrapper (timeout, pinned fps, log, fails on SHADER / SCRIPT ERROR) |

### Run the tests

```
# from the repository root; Godot 4.7 on PATH as `godot` (macOS: ~/Downloads/Godot.app/Contents/MacOS/Godot)
godot --headless --path godot --import                      # once, after cloning
./scripts/run-test.sh test_hose_glow.gd 30                  # 15 checks; also at 60 and 144
./scripts/run-test.sh test_hose_glow.gd 60
./scripts/run-test.sh test_hose_glow.gd 144
./scripts/run-test.sh test_materials.gd 60                  # 35 checks
./scripts/run-test.sh test_game.gd 60                       # A2 baseline: 41 checks
./scripts/run-test.sh test_keyboard.gd 60                   # 14
./scripts/run-test.sh test_audio.gd 60                      # 12 / 14 with the fps pin (TEST-REPORT baseline explains the two)
./scripts/run-test.sh check_props.gd 60                     # A3: RESULT: PASS
```

Logs land in `logs/`. **Play it:** `godot --path godot`; W next to the big fire starts the water and the glow. **See the hydrants:** open `godot/project.godot` in the editor and run `scenes3d/props_room.tscn`; the hint experiment is `scenes3d/hint_experiment.tscn`.

### Known limitations

- Under this project's **GL Compatibility** renderer the hint experiment's two quads are identical: 3D is shaded in sRGB space, so `source_color` changes nothing on screen here. The hint is still required and the prediction for Forward+/Mobile stands (TEST-REPORT).
- The **roughness and normal-strength sliders show no visible difference** under the props room's single sun; the sampled pixel moves 1–3 levels. A second light would be the next experiment.
- The hydrant mesh is the basic A3 one; "improve the structure of the hydrant" is my next step, outside this assignment (the A3 model files must not change).
- The glow is on the sprite only; the code-drawn rescue bag stays orange (checked by a controlled capture, since rescues come after the hose in play).
- `Engine.time_scale = 0.5` by eye is an **open** human check (TEST-REPORT Open items).
- Headless tests prove parse, uniform names and types, timing and material wiring; every look is a human check in TEST-REPORT.

### Film

Brutalist `godot-gamedev` explainer, `walker` mode, native 4K, 6 min 22 s, 32 MB, narrated by Liam: *Extinguisho's Hand-Written Shaders*. Source shown: revision `e8c2a30` (no file under `godot/` changed after it).

- **Link (Northeastern SharePoint, course media storage):** https://northeastern-my.sharepoint.com/:f:/g/personal/pulaparty_s_northeastern_edu/IgCzqn1JsKZORIVL8gL8oe0KAUD2cXE4KHod2yt1IJlg6G8?e=DaGz30
- **File:** `claude-liam-walker-ninja-firefighter-joe-a5-gamedev.mp4`
- **SHA-256:** `67d77d0a7632e78b341f2ee3e997df2f2e7bcf3e902dea5f263ee1bfc45a52da`
- **Film source** (approved script, beat sheet, evidence ledger, capture and build scripts): [`youtube/claude-liam-walker-ninja-firefighter-joe-a5-gamedev/`](youtube/claude-liam-walker-ninja-firefighter-joe-a5-gamedev/). The MP4 and the Movie Maker AVI are not in git (course rule).

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
- **Design and evidence:** CONCEPT.md, STORYBOARD.md, CHARACTER-SHEET.md, a2/CHANGE-BRIEF.md (plan and predictions; moved from the root for Assignment 5, which needs its own brief at that path), SOURCES.md (models and asset log), TEST-REPORT.md, ../FRICTIONAL.md (design log), rejected outputs in `rejected/`, in-engine screenshots in `evidence/screens-web/`.

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
