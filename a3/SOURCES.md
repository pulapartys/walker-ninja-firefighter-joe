# SOURCES — Assignment 3

Assignment 2's sources (generative models, art and audio) are in [`../SOURCES.md`](../SOURCES.md).

## Started from

- **My Assignment 2 game** in this repository (tag `a2`, the version submitted from the class repo at commit `50a1797`). The A3 props are new; nothing from A2 was changed.

## Geometry

- **All three props were built in Blender from basic shapes** (cylinders, UV spheres, tori, boxes; the flame and the backpack reshape them by moving their vertices), by Python code that Claude Code ran through the Blender MCP. Every code body is in `tools/blender/build_<asset>.py`.
- **No downloaded models and no AI-generated meshes.** The add-on's Poly Haven, Sketchfab and Poly Pizza libraries and its Hyper3D Rodin, Hunyuan3D and Tripo generators were **off** the whole time (checked with `get_addon_status`; screenshot `evidence/mcp-panel-services-off.png`). `generate_3d`, `search_assets` and `import_asset` were never called.

## Reference image (not a mesh)

- `evidence/flame-reference.png`: a low-poly flame reference sheet (front/side/back/top views, colour zones, shape breakdown), **generated in ChatGPT** and given to Claude as a visual reference for the flame on 2026-10-14. Only used to describe the shape and colour layout; **no geometry was taken from it**: the flame is still built from reshaped basic shapes by code.

## Colours

| Colour | Hex | Where it comes from |
|---|---|---|
| Hydrant red | `#c0392b` | my choice |
| Hydrant grey caps | `#9aa3ab` | my choice |
| Bag orange | `#e67e22` | my A2 game: `godot/features/player/player.gd` (the code-drawn rescue bag) |
| Bag darker orange | `#b8621b` | same file (the bag's seam colour) |
| Bag straps / handle | `#1b2230` | my A2 game's dark outline colour (`player.gd`, `game/session.gd`) |
| Flame bright yellow | `#ffe14a` | final flame (v9); five fire colours chosen by Claude to my brief ("bright centre, darker outside, no muddy colours") |
| Flame golden yellow | `#f8bb2c` | same |
| Flame orange | `#f5901e` | same |
| Flame red-orange | `#eb5223` | same |
| Flame deep red | `#c62a1c` | same |
| *(earlier flame versions)* | `#f1c40f`, `#e67e22`, `#c0392b` | flame v1–v7 (replaced) |
| *(dropped)* Ledge concrete | `#b8b2a6` | my A2 game: `godot/game/session.gd` (how ledges are drawn) |
| *(dropped)* Ledge green top strip | `#438e7d` | same file |

## Tools and versions

| Tool | Version | Used for |
|---|---|---|
| Blender | 5.2.2 LTS (macOS, Apple Silicon; installed with Homebrew) | building the props, `.blend` sources, `.glb` export. The chapter used 5.1.2. |
| MCP for Blender — MCP server | `mcp-for-blender` 2.1.9, run with `uvx` | Claude Code's Blender tools (`get_addon_status`, `get_scene_info`, `execute_blender_code`, `look`) |
| MCP for Blender — Blender add-on | "MCP for Blender" 1.8 (Siddharth Ahuja; mcp-for-blender.com, github.com/ahujasid/blender-mcp), installed with `uvx mcp-for-blender install-addon` | the socket inside Blender (localhost:9876); telemetry off (`DISABLE_TELEMETRY=true`, "Allow Telemetry" unticked) |
| uv | Homebrew | runs the MCP server |
| GNU coreutils | 9.12 (Homebrew) | `timeout` for the headless check |
| Godot | 4.7.2 stable | the 3D scene and the headless check |
| Claude Code | Claude Opus 5.5 | plans, all Blender Python, setup commands, document drafting |

## Who did what

I chose the three props, the scale, every size, colour and budget, and the predicted failures; I approved each build plan, judged every version in my own Blender viewport, and decided on the changes (the bag: barrel → duffel → backpack; asset 3: ledge → flame; the flame through many versions to one curved flame, from two design briefs I wrote). Claude Code laid out options, wrote and ran all the Blender code through the MCP, and helped write these documents from my decisions and screenshots.
