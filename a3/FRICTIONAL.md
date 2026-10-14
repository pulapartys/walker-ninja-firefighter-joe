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

## GitHub pushes

| Date | Commit subject |
|---|---|
| 2026-10-14 | A3: log the push of my brief and Blender notes before building *(class repo fork, PR #15)* |
