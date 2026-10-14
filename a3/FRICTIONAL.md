# FRICTIONAL — Assignment 3

> Assignment 2's log is in the class repo: `fall-2026/sreeja-p/assignment-2/FRICTIONAL.md` (nikbearbrown/csye-7270-building-virtual-environments).
>
> **How I worked:** I directed the work in Claude Code: I chose the assets, the scale and the sizes, approved every plan before anything was built, judged every version in my own Blender viewport, and decided every change. Claude proposed options when I asked, implemented my decisions in Blender through the MCP, and helped write these notes from my decisions and screenshots; I reviewed them all.

## Entries

### 2026-10-08 — reading the assignment and choosing the three assets

- **Date and what I was working on:** 2026-10-08. I read Assignment 3 and chose what to build.
- **I tried / expected:** I asked Claude what it needed from me; it needed my game, three assets and a size reference.
- **What happened:**
  - Claude found my Assignment 2 game in the repo (Extinguisho, a 2D game), so I did not have to describe it again.
  - Blender was not installed on my Mac yet; Godot was.
  - I asked for asset ideas that fit my game; Claude listed four and pointed out that the rescue bag already exists in my game, drawn in code (`player.gd`), 9 px wide next to a 64 px character.
- **What I did:**
  - Chose three: **fire hydrant, rescue bag, rooftop ledge**.
  - Set the rule that only my own folder may be edited (then the class-repo folder; the work later moved to this repository, see "moving to my own walker- repository").
- **What I understand now / still do not understand:** because my game is 2D, I still need a small 3D scene (floor, one light, camera), and I need a pixel-to-metre scale.
- **Evidence and next step:** install Blender, write BLENDER-NOTES.md, then CHANGE-BRIEF.md before building.

### 2026-10-14 — learning the Blender window

- **Date and what I was working on:** 2026-10-14, 9:30–9:55. My "learn the window" session in Blender 5.2.2, before any prompting.
- **I tried / expected:** orbit, pan, zoom, the axis gizmo, selecting in the Outliner, the Move tool, the sidebar (N), and Object vs Edit Mode.
- **What happened:**
  - Spotlight couldn't find Blender (it is installed in Applications), so I had Claude open it.
  - Clicking Z on the gizmo gave the top view, so Z is up.
  - I grabbed the Move tool's white circle instead of the red arrow, and the cube went below the floor (Location Z -2.39). I found the axis lock myself; G then Z moves only up/down. Option+G put the cube back at 0.
  - I couldn't find "Confirm/Cancel": they are hints in the status bar, not buttons.
  - Sidebar: the default cube is 2 m on each side (Dimensions), even though Scale is 1.
  - In Edit Mode a corner was at Z = -1 m, so the default cube's origin is in its middle.
- **What I did:** explored the window step by step and took my own screenshots (`a3/evidence/blender-session.png`, `blender-edit-mode.png`).
- **Who did what:** the session, the observations and the screenshots are mine; Claude gave me the steps and questions and helped write BLENDER-NOTES up from my answers and screenshots, which I reviewed.
- **What I understand now:** Blender is Z-up and Godot is Y-up; a new object's origin is in its middle, so it sinks halfway into the floor unless the origin goes to the base.
- **Evidence and next step:** BLENDER-NOTES.md; next, my CHANGE-BRIEF before building.

### 2026-10-14 — the brief, then connecting the MCP

- **What happened:**
  - I set the scale (Extinguisho = 1.8 m), the size, origin, colours and triangle budget of each asset, and the predicted failures. I asked Claude to propose options and approved the ones in the brief, including the four predicted failures (P1–P4) from the six Claude listed. CHANGE-BRIEF v1 was committed at 10:01 (`7578374`) **before anything was built**, pushed to my fork, and opened as PR #15 on the class repo.
  - `gh` was logged in as my other GitHub account; I switched it to pulapartys before pushing.
  - I followed the assignment's manual MCP setup. Its `claude mcp add` line failed (see the MCP table); putting the server name before `-e` fixed it.
- **Who did what:** the brief's decisions are mine; Claude proposed options when I asked, wrote the brief up from my choices, and ran the setup commands I approved.
- **Evidence and next step:** MCP table below; next, enable the add-on in Blender and restart Claude Code.

### 2026-10-14 — moving to my own walker- repository

- **What happened:** I asked Claude to check my setup against the A3 requirements. A3 wants the game in a repository whose name begins `walker-`, with each assignment added to that same repository and tagged (`a3`). My A2 game was a folder inside the class repo (A2 allowed "repository or folder"), and I had started A3 in a separate `assignment-3/` folder there.
- **What I decided:** to create my own repository, `walker-ninja-firefighter-joe`, from my submitted A2 game with its 15 commits of history (`git subtree split` of the A2 folder at class-repo commit `50a1797`; the file tree is identical to what I submitted, tree `10bf2f5`), tag that version `a2`, and add A3 on top in `a3/`. A3 assets go into the same Godot project (`godot/`).
- **Traceability:** CHANGE-BRIEF v1 and BLENDER-NOTES were first committed at 10:01 in the class repo (`7578374` on my fork, branch `sreeja-p/assignment-3`, PR #15, since closed), before building; they are copied here unchanged.
- **Who did what:** the decision was mine; Claude laid out the options and moved the files as I asked.

### 2026-10-14 — building the fire hydrant (MCP)

- **Date and what I was working on:** 2026-10-14, about 12:15–12:35. Asset 1, through the Blender MCP in my open Blender.
- **I tried / expected:** I asked for a plan first. Claude proposed 6 parts with sizes, segment counts (356 triangles), colours, then join + origin + apply, no export. I reviewed and approved it ("ok") and expected the numbers to match my brief.
- **What happened:**
  - Claude implemented it in 8 MCP calls (one per part, then join / origin / apply, then save), reporting location, size, rotation and scale after each part. The two outlets carried a 90° rotation until it was applied in the join step.
  - Result: **356 triangles** (budget ≤ 400), **0.40 × 0.36 × 0.80 m**, origin (0, 0, 0), rotation 0, scale 1, 1, 1, bottom at Z 0, top at Z 0.8.
  - About 60 triangles of the cap sphere sit hidden inside the body; I accepted that, since it is under budget.
- **What I did:** orbited around it in my viewport and confirmed it reads as a hydrant (`a3/evidence/hydrant-my-viewport-check.png`).
- **Evidence:** `tools/blender/build_hydrant.py` (every call, in order), `blender/hydrant.blend`, `a3/evidence/hydrant-angles-v1.png`; commit `0a2b161`.

### 2026-10-14 — the rescue bag: barrel → duffel → backpack (MCP)

- **Date and what I was working on:** 2026-10-14, about 12:36–12:56. Asset 2.
- **What happened, version by version:**
  - **v1** (cylinder on its side, a flap, one ring handle; I approved the plan): every number passed (264 triangles, 0.60 × 0.28 × 0.30 m, scale 1, origin at the base). The `look` render showed the handle was almost entirely buried in the body, and when I checked it in my viewport it **"doesn't look anything like a bag", it looks like a barrel**. Numbers can't catch that. → CHANGE-BRIEF Revision 1.
  - **v2** (oval body, two strap handles, a zip line; I approved: "ok build v2"): 248 triangles, 0.60 × 0.30 × 0.33 m. It looked like a bag. Then I asked myself what the bag is actually for: in my game it rides **on Extinguisho's back** and the survivors are tossed into it, so **I decided to try a backpack**.
  - **v3** (boxy backpack; "lets try and see what we like"): 292 triangles, 0.38 × 0.35 × 0.59 m. It read as a backpack but **"more like a box"**. I also noticed it is **tiny in the viewport**: a grid square is 1 m and a 0.6 m bag is about half a square.
  - **v4** (rounded backpack; I asked: "make it look less boxy"): oval tapered body, rounded flap, rounded pocket, two shoulder straps, grab handle. **296 triangles** (budget ≤ 300), **0.36 × 0.31 × 0.61 m**, origin at the base, scale 1. **I chose this one** ("ok this one is better"). → CHANGE-BRIEF Revision 2.
- **What I learned:** a check that the numbers are right is not a check that the thing is right; v1 passed every number and was still wrong. And the object should match how the game uses it (worn, not carried).
- **Who did what:** I judged every version, decided on the backpack, asked for the rounder version and chose the final one; Claude proposed each build plan and implemented it in Blender.
- **Still open:** from straight in front, the rounded flap looks a bit like a jar lid.
- **Evidence:** `tools/blender/build_rescue_bag.py` (all 21 calls, v1–v4), `blender/rescue_bag.blend` (v4), `blender/rescue_bag_v2_duffel.blend`, pictures `a3/evidence/bag-*`; commits `704f4e5`, `dad6bc4`.

### 2026-10-14 — the rooftop ledge, then swapping it for a flame (MCP)

- **Date and what I was working on:** 2026-10-14, about 12:58–13:16. Asset 3.
- **What happened:**
  - **Ledge** (I approved the plan: "build ledge"): two boxes, 24 triangles, 2.5 × 1.0 × 0.45 m, the game's concrete `#b8b2a6` and green 4 px strip `#438e7d`, origin at the base, scale 1. It matched the brief exactly.
  - Looking at it in my viewport: "seems fine but it's just a ledge, nothing interesting". **I decided to make a flame instead** — the main hazard in my game. I asked Claude for the flame size in my game (a small hazard is drawn 18 × 22 px, about 0.35 × 0.6 m) and **chose to swap** the ledge rather than add a fourth asset, because of the deadline. → CHANGE-BRIEF Revision 3.
  - **Flame v1** (stacked yellow / orange / red, two side spikes; 336 triangles, 0.43 × 0.34 × 0.62 m): in my viewport it "doesn't look like a flame, looks like a christmas tree with 2 spikes". → v2 (five uneven tongues with bent tips, 320 triangles). → CHANGE-BRIEF Revision 4.
  - **Flame v2** was "not a flame again too", so **I designed it myself**: symmetrical, a cone base layer, the two bent side spikes, and the bent top flame directly on top of the cone. When the top flame sat on the cone like a hat, **I asked to extend it down to meet the side spikes halfway**. Result v3: 336 triangles, 0.40 × 0.34 × 0.62 m. My verdict: "not the best but we can keep it as a basic version and improve on it later". → CHANGE-BRIEF Revision 5.
- **What I learned:** describing the shape I wanted in my own words (base, spikes, where the top goes) worked better than leaving "a flame" open. Flames are hard to make from a few low-poly shapes.
- **Who did what:** dropping the ledge, making a flame, and the v3 design were my decisions; Claude proposed the v1–v2 builds and implemented every version.
- **Evidence:** `tools/blender/build_rooftop_ledge.py`, `blender/rooftop_ledge.blend` (dropped), `tools/blender/build_flame.py`, `a3/evidence/ledge-*`, `a3/evidence/flame-*`.

### 2026-10-14 — the flame, part 2: from spikes to one curved flame (MCP)

- **Date and what I was working on:** 2026-10-14, about 15:20–15:56. Improving the flame before my hand edit.
- **I tried / expected:** I generated a low-poly flame reference sheet in ChatGPT (`a3/evidence/flame-reference.png`) and gave it to Claude to follow.
- **What happened:**
  - v4 / v4b (three nested star layers, twisted): looked like a closed bud or a rocket; only red showed. I told Claude it was doing something wrong; it identified the causes (everything twisted into one tip, base too narrow, nested shells hide the inner colours in 3D).
  - v5 / v5b (wide bowl + 6 side flames + main flame): closer, but angular. **My idea:** "layer more spikes until the top around the main centre cone like a star from the top view" → v6 (rings of spikes). Too thin and pointy; I asked for curvier, fuller tongues that fill around the main cone → v7. Still crystals.
  - **I wrote a full design brief** (7–8 broad curved tongues, irregular, red outside / yellow inside, 100–150 triangles). Claude rebuilt it from scratch to that brief (v8 → v8c, 169 triangles); in my viewport it still looked like **sharp crystals / triangular blades**. Along the way Claude also found and fixed its own bug: the centre flame curled towards the back, so from the front it looked straight.
  - **I changed the method with a second brief:** back up and delete, build **only one** flame from deliberately placed cross-sections, show it in grey, and stop for my approval. v1 looked like "a bent horn"; I gave specific changes (bulbous base, S-shaped asymmetric middle, gradual curl, more depth, widest at the lower third). I approved v2b's shape, then asked for the colours (bright yellow centre, darker red outside, no flat horizontal bands, as in my brief), then accepted it: "this is good enough".
- **What I did:** judged every version in my own viewport (screenshots in `a3/evidence/flame-*my*`), wrote both design briefs, chose the method change, the colours and the final version.
- **Who did what:** the reference image, both briefs, the method change and every accept/reject decision are mine; Claude implemented each version (calls 14–29 in `tools/blender/build_flame.py`), including the colour assignment that follows my brief (by height and by which way a face points). ChatGPT generated the reference image for me.
- **What I understand now / still do not understand:** asking for "more" (more spikes, more layers) kept making it worse; asking for **one** shape with specific curves, approved before adding anything, worked. With few triangles, the outline matters more than the number of parts. Still open: whether a single flame reads as "fire" at game size next to the other props (to check in Godot). The final flame is one hand-shaped mesh rather than combined primitives — a deliberate choice after the primitive-based versions failed.
- **Evidence:** `blender/flame.blend` (final), `blender/flame_v8c_backup.blend`, `a3/evidence/flame-*`; CHANGE-BRIEF Revision 6.

### 2026-10-14 — my hand edit 1: the flame tip (by mouse, in Blender)

- **What I changed:** in Edit Mode, vertex select, I clicked the single tip point and moved it with **G then X** (dragging), about **0.19 m along X towards the centre**: the tip went from X −0.15 to X +0.04. The flame got straighter and more balanced, and I liked it better than the strongly hooked tip, so I kept it and saved (`blender/flame.blend`, Save As → Overwrite).
- **What it taught me / what was hard:** it was pretty easy once I knew how (Edit Mode → vertex select → G + an axis). The drag went a different way than I first expected: in a 3D view the screen direction of an axis depends on where you look from, so the header readout ("D: 0.188830 m along global X") is what tells you what really happened. Typing a number (G, X, -0.06) would have been exact. The move only locks in when you click; the "Move" box then appears at the bottom left.
- **Checked afterwards (through the MCP):** still 48 triangles, 0.36 × 0.27 × 0.62 m (the tip stays inside the width), bottom at Z 0, scale 1. This edit goes a little against my own brief ("a tip that curls noticeably sideways"); I chose the look over the brief.
- **Evidence:** `a3/evidence/hand-edit-flame-1-tip-selected.png`, `…-2-moving-along-x.png`, `…-3-saved.png`.

## MCP connection attempts

| Date / time | Step tried | Exact error or result | What I changed next |
|---|---|---|---|
| 2026-10-14 10:10 | Removed an older blender-mcp `addon.py` left in Blender's add-ons folder from a demo run, so two add-ons would not compete for port 9876 | removed | — |
| 10:10 | `brew install coreutils` (for `timeout`) | `timeout (GNU coreutils) 9.12` | — |
| 10:11 | `claude mcp add -e DISABLE_TELEMETRY=true blender -- uvx mcp-for-blender` (the assignment's line) | `Invalid environment variable format: blender, environment variables should be added as: -e KEY1=value1 -e KEY2=value2` | `-e` takes several values and swallowed the server name; put the name first |
| 10:11 | `uvx mcp-for-blender install-addon` | `Installed MCP for Blender addon to …/Blender/5.2/scripts/addons/blender_mcp.py` (add-on `bl_info` version 1.8) | — |
| 10:12 | `claude mcp add blender -e DISABLE_TELEMETRY=true -- uvx mcp-for-blender` | `Added stdio MCP server blender …`; `claude mcp get blender`: Connected, `DISABLE_TELEMETRY=true`; server package mcp-for-blender 2.1.9 | enable the add-on in Blender |
| 10:13–10:15 | In Blender: Preferences → Add-ons → ticked "MCP for Blender" (1.8; Allow Telemetry left off); N panel → MCP for Blender tab | "Connected on port 9876"; Poly Haven, Sketchfab, Poly Pizza, Hyper3D Rodin, Tencent Hunyuan 3D all unticked; Tripo not shown (premium only). The server started on its own when I enabled the add-on; no Start button needed. Screenshots: `evidence/mcp-addon-enabled.png`, `evidence/mcp-panel-services-off.png` | restart Claude Code so it loads the server |
| ~10:40 | Restarted Claude Code (`/exit`, `claude --continue` in the same folder) | Tools available: `get_addon_status`, `get_scene_info`, `execute_blender_code`, `look`. `get_addon_status`: Blender 5.2.2 LTS, add-on 1.8 up to date, protocol 13 = expected 13; polyhaven/sketchfab/polypizza off, hunyuan3d/hyper3d off, tripo off (Premium only); telemetry_consent false. `get_scene_info`: Cube, Light, Camera | **Connected.** Prediction P4 (MCP won't connect) did not happen, after one fix to the `claude mcp add` line |

## GitHub pushes

| Date | Commit subject |
|---|---|
| 2026-10-14 | A3: log the push of my brief and Blender notes before building *(class repo fork, PR #15)* |
| 2026-10-14 | A3: log the first push of my walker- repository *(this repository)* |
| 2026-10-14 | A3: log the push of the three built props and my first hand edit (PR) *(this repository, branch a3-build, PR #1)* |
