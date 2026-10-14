# FRICTIONAL — Assignment 3

> Assignment 2's log is in the class repo: `fall-2026/sreeja-p/assignment-2/FRICTIONAL.md` (nikbearbrown/csye-7270-building-virtual-environments).

## Entries

<!-- One entry per work session, newest last. Copy the block below. -->

### YYYY-MM-DD — <what I was working on>

- **Date and what I was working on:**
- **I tried / expected:**
- **What happened:**
- **What I did:**
- **What Claude or another person contributed:**
- **What I understand now / still do not understand:**
- **Evidence and next step:**

### 2026-10-08 — reading the assignment and choosing the three assets

- **Date and what I was working on:** 2026-10-08. I read Assignment 3 and chose what to build.
- **I tried / expected:** My professor suggested giving the assignment to Claude to see what it returns. I first asked Claude in chat; it said it needed my game, three assets, and a size reference.
- **What happened:**
  - In Claude Code, Claude found my Assignment 2 game in the repo (Extinguisho, a 2D game), so I did not have to describe it again.
  - Claude checked my Mac: Godot is installed, **Blender is not**.
  - Claude suggested four asset options from my game; it also found that the rescue bag already exists in my game, drawn in code (`player.gd`), 9 px wide next to a 64 px character.
- **What I did:**
  - Chose the first three: **fire hydrant, rescue bag, rooftop ledge**.
  - Told Claude to only edit files under `fall-2026/sreeja-p/`.
- **What Claude or another person contributed:** Claude suggested the asset options and their basic shapes, worked out the bag's pixel size from the code, and set up this folder and the CHANGE-BRIEF skeleton. The size scale and all predictions are left for me.
- **What I understand now / still do not understand:** Because my game is 2D, I still need a small 3D scene (floor, one light, camera). I still need to choose a pixel-to-metre scale.
- **Evidence and next step:** Install Blender, write BLENDER-NOTES.md, then fill in CHANGE-BRIEF.md before building.

### 2026-10-14 — learning the Blender window

- **Date and what I was working on:** 2026-10-14, 9:30–9:55. My "learn the window" session in Blender 5.2.2, before any prompting.
- **I tried / expected:** Orbit, pan, zoom, the axis gizmo, selecting in the Outliner, the Move tool, the sidebar (N), and Object vs Edit Mode.
- **What happened:**
  - Spotlight couldn't find Blender (it is installed in Applications), so Claude opened it.
  - Clicking Z on the gizmo gave the top view, so Z is up.
  - I grabbed the Move tool's white circle instead of the red arrow, and the cube went below the floor (Location Z -2.39). I found the axis lock myself; G then Z moves only up/down. Option+G put the cube back at 0.
  - I couldn't find "Confirm/Cancel": they are hints in the status bar, not buttons.
  - Sidebar: the default cube is 2 m on each side (Dimensions), even though Scale is 1.
  - In Edit Mode a corner was at Z = -1 m, so the default cube's origin is in its middle.
- **What I did:** Took my own screenshots (`a3/evidence/blender-session.png`, `blender-edit-mode.png`).
- **What Claude or another person contributed:** I did the Blender session and answered the questions; Claude Code guided the steps and helped write the notes up from my answers and screenshots.
- **What I understand now / still do not understand:** Blender is Z-up and Godot is Y-up; a new object's origin is in its middle, so it sinks halfway into the floor unless the origin goes to the base.
- **Evidence and next step:** BLENDER-NOTES.md; next, my CHANGE-BRIEF before building.

### 2026-10-14 — brief committed and pushed; connecting the MCP

- **What happened:**
  - I picked my sizes, colours, budgets and four predicted failures from options Claude laid out, and committed CHANGE-BRIEF v1 at 10:01 (`7578374`) before building anything. Pushed to my fork and opened PR #15 on the class repo.
  - `gh` was logged in as my other GitHub account; I switched it to pulapartys before pushing.
  - The assignment's `claude mcp add` line failed (see the MCP table); putting the server name before `-e` fixed it.
- **What Claude or another person contributed:** Claude laid out options for the brief, wrote it up from my choices, and ran the setup commands; I chose the values and predictions.
- **Evidence and next step:** MCP table below; next, enable the add-on in Blender and restart Claude Code.

### 2026-10-14 — moving to my own walker- repository

- **What happened:** Re-reading Assignment 3, I saw it wants the game in a repository whose name begins `walker-`, with each assignment added to that same repository and tagged (`a3`). My A2 game was a folder inside the class repo (A2 allowed "repository or folder"), and I had started A3 in a separate `assignment-3/` folder there.
- **What I did:** Created `walker-ninja-firefighter-joe` from my submitted A2 game with its 15 commits of history (`git subtree split` of the A2 folder at class-repo commit `50a1797`; the file tree is identical to what I submitted, tree `10bf2f5`), tagged that version `a2`, and added the A3 work on top in `a3/`. A3 assets will go into the same Godot project (`godot/`).
- **Traceability:** CHANGE-BRIEF v1 and BLENDER-NOTES were first committed at 10:01 today in the class repo (`7578374` on my fork, branch `sreeja-p/assignment-3`, PR #15), before building; they are copied here unchanged.
- **What Claude or another person contributed:** Claude found the mismatch when I asked it to check the requirements, laid out the options, and moved the files; I chose to make the new repository.

### 2026-10-14 — building the fire hydrant (MCP)

- **Date and what I was working on:** 2026-10-14, about 12:15–12:35. Asset 1, through the Blender MCP in my open Blender.
- **I tried / expected:** Claude proposed a plan first (6 parts with sizes, segment counts and a triangle count of 356, colours, join + origin + apply, no export); I approved it with "ok". I expected the numbers to match the brief.
- **What happened:**
  - Claude built it in 8 MCP calls: one per part, then join / origin / apply, then save. It reported location, size, rotation and scale after each part; the two outlets carried a 90° rotation until it was applied in the join step.
  - Result: **356 triangles** (budget ≤ 400), **0.40 × 0.36 × 0.80 m**, origin (0, 0, 0), rotation 0, scale 1, 1, 1, bottom at Z 0, top at Z 0.8.
  - Claude pointed out before building that the bottom half of the cap sphere sits inside the body (~60 triangles that are never seen); I left it, since it is under budget.
- **What I did:** Orbited around it in my viewport and checked it: it reads as a hydrant (`a3/evidence/hydrant-my-viewport-check.png`).
- **What Claude or another person contributed:** Claude wrote the plan and all the Blender code; I approved the plan and did the visual check.
- **Evidence:** `tools/blender/build_hydrant.py` (every call, in order), `blender/hydrant.blend`, `a3/evidence/hydrant-angles-v1.png`; commit `0a2b161`.

### 2026-10-14 — the rescue bag: barrel → duffel → backpack (MCP)

- **Date and what I was working on:** 2026-10-14, about 12:36–12:56. Asset 2.
- **What happened, version by version:**
  - **v1** (cylinder on its side, a flap, one ring handle; my "ok"): every number passed (264 triangles, 0.60 × 0.28 × 0.30 m, scale 1, origin at the base). But Claude's `look` showed the handle was **almost entirely buried inside the body**, and when I looked in my viewport I said it **"doesn't look anything like a bag", it looks like a barrel**. Numbers can't catch that. → CHANGE-BRIEF Revision 1.
  - **v2** (oval body, two strap handles, a zip line; "ok build v2"): 248 triangles, 0.60 × 0.30 × 0.33 m. Looked like a bag. Then I asked what the bag is actually for: in my game it rides **on Extinguisho's back** and the survivors are tossed into it, so **I suggested a backpack** instead.
  - **v3** (boxy backpack; "lets try and see what we like"): 292 triangles, 0.38 × 0.35 × 0.59 m. It read as a backpack but **"more like a box"**. I also noticed it is **tiny in the viewport**: a grid square is 1 m and a 0.6 m bag is about half a square; I had to zoom in on every version.
  - **v4** (rounded backpack; "no i need you to make it look less boxy"): oval tapered body, rounded flap, rounded pocket, two shoulder straps, grab handle. **296 triangles** (budget ≤ 300), **0.36 × 0.31 × 0.61 m**, origin at the base, scale 1. **I chose this one** ("ok this one is better"). → CHANGE-BRIEF Revision 2.
- **What I learned:** a check that the numbers are right is not a check that the thing is right; v1 passed every number and was still wrong. And the object should match how the game uses it (worn, not carried).
- **What Claude or another person contributed:** Claude wrote every plan and all the Blender code, and spotted the buried handle in its own render. I judged each version in my viewport (barrel, boxy), asked what the bag is for, suggested the backpack, and chose the final version.
- **Still open:** from straight in front, the rounded flap looks a bit like a jar lid (Claude's observation); a candidate for my hand edit.
- **Evidence:** `tools/blender/build_rescue_bag.py` (all 21 calls, v1–v4), `blender/rescue_bag.blend` (v4), `blender/rescue_bag_v2_duffel.blend`, pictures `a3/evidence/bag-*`; commits `704f4e5`, `dad6bc4`.

### 2026-10-14 — the rooftop ledge, then swapping it for a flame (MCP)

- **Date and what I was working on:** 2026-10-14, about 12:58–13:10. Asset 3.
- **What happened:**
  - **Ledge** (plan approved: "build ledge"): 4 MCP calls, two boxes. 24 triangles, 2.5 × 1.0 × 0.45 m, the game's concrete `#b8b2a6` and green 4 px strip `#438e7d`, origin at the base, scale 1. It matched the brief exactly.
  - Looking at it in my viewport: "seems fine but it's just a ledge, nothing interesting". **I suggested making a flame instead.**
  - Claude checked how big flames are in my game: a small hazard is drawn 18 × 22 px, about 0.35 × 0.6 m. It laid out two options: swap the ledge for the flame (still three assets) or add the flame as a fourth. **I chose to swap**, because of the deadline.
  - **Flame**: Claude's first plan had nested layers; before building it changed the design to stacked layers (yellow bulb, orange middle, red tip) because nested opaque shapes would hide the inner colours. 5 MCP calls. **336 triangles** (budget ≤ 400), **0.43 × 0.34 × 0.62 m**, origin at the base, scale 1.
- **What Claude or another person contributed:** Claude wrote both plans and all the code, measured the game's flame size from `session.gd`, and laid out the swap/add options. The decision to drop the ledge and make a flame was mine. → CHANGE-BRIEF Revision 3.
- **Flame v1 → v2:** in my viewport the flame "doesn't look like a flame, looks like a christmas tree with 2 spikes". Claude named why (straight cones stacked on one axis, mirrored spikes) and rebuilt it as five uneven tongues with bent tips: 320 triangles, 0.41 × 0.35 × 0.62 m. → CHANGE-BRIEF Revision 4. Second time a version passed every number and failed my look (after the bag barrel).
- **Evidence:** `tools/blender/build_rooftop_ledge.py`, `blender/rooftop_ledge.blend` (dropped), `tools/blender/build_flame.py` (v1 and v2), `blender/flame.blend` (v2), `a3/evidence/ledge-*`, `a3/evidence/flame-*`.

## MCP connection attempts

<!-- Log every attempt and every error, verbatim. If it is not connected after ~2 hours of honest effort, switch to the script route and say so here. -->

| Date / time | Step tried | Exact error or result | What I changed next |
|---|---|---|---|
| 2026-10-14 10:10 | Removed an older blender-mcp `addon.py` left in Blender's add-ons folder from a demo run, so two add-ons would not compete for port 9876 | removed | — |
| 10:10 | `brew install coreutils` (for `timeout`) | `timeout (GNU coreutils) 9.12` | — |
| 10:11 | `claude mcp add -e DISABLE_TELEMETRY=true blender -- uvx mcp-for-blender` (the assignment's line) | `Invalid environment variable format: blender, environment variables should be added as: -e KEY1=value1 -e KEY2=value2` | `-e` takes several values and swallowed the server name; put the name first |
| 10:11 | `uvx mcp-for-blender install-addon` | `Installed MCP for Blender addon to …/Blender/5.2/scripts/addons/blender_mcp.py` (add-on `bl_info` version 1.8) | — |
| 10:12 | `claude mcp add blender -e DISABLE_TELEMETRY=true -- uvx mcp-for-blender` | `Added stdio MCP server blender …`; `claude mcp get blender`: Connected, `DISABLE_TELEMETRY=true`; server package mcp-for-blender 2.1.9 | enable the add-on in Blender |
| 10:13–10:15 | In Blender: Preferences → Add-ons → ticked "MCP for Blender" (1.8; Allow Telemetry left off); N panel → MCP for Blender tab | "Connected on port 9876"; Poly Haven, Sketchfab, Poly Pizza, Hyper3D Rodin, Tencent Hunyuan 3D all unticked; Tripo not shown (premium only). The server started on its own when I enabled the add-on; no Start button needed. Screenshots: `evidence/mcp-addon-enabled.png`, `evidence/mcp-panel-services-off.png` | restart Claude Code so it loads the server |
| ~10:40 | Restarted Claude Code (`/exit`, `claude --continue` in the same folder) so it loads the server | Claude's tools now include `get_addon_status`, `get_scene_info`, `execute_blender_code`, `look`. `get_addon_status`: Blender 5.2.2 LTS, add-on 1.8 up to date, protocol 13 = expected 13; polyhaven/sketchfab/polypizza off, hunyuan3d/hyper3d off, tripo off (Premium only); telemetry_consent false. `get_scene_info`: Cube, Light, Camera, mode EDIT_MESH | **Connected.** Prediction P4 (MCP won't connect) did not happen, after one fix to the `claude mcp add` line |

## GitHub pushes

| Date | Commit subject |
|---|---|
| 2026-10-14 | A3: log the push of my brief and Blender notes before building *(class repo fork, PR #15)* |
| 2026-10-14 | A3: log the first push of my walker- repository *(this repository)* |
