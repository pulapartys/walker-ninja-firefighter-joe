# SOURCES — Assignment 5

Assignment 2's sources (generative models, art and audio) are in [`../SOURCES.md`](../SOURCES.md); Assignment 3's in [`../a3/SOURCES.md`](../a3/SOURCES.md).

## Started from

- **My Assignment 3 game** in this repository (tag `a3`, commit `5813e15`): the 2D game from A2 and the 3D props room from A3. A5 adds shaders, materials, textures, a driver, tests and docs on top; collision, movement, input, the state machine and its timings, the existing tests and the prop meshes are unchanged.

## Textures

| Asset | Source | Author | Licence | Date checked | Files used |
|---|---|---|---|---|---|
| Rusty Metal Sheet (`rusty_metal_sheet`) | https://polyhaven.com/a/rusty_metal_sheet | Amal Kumar (creator) | CC0 1.0 | 2026-10-28 | `diff`, `rough`, `nor_gl` (bound), `nor_dx` (curl-check calibration only), 1K PNG |

Full provenance beside the files: [`../godot/art/textures/rusty_metal_sheet/ATTRIBUTION.md`](../godot/art/textures/rusty_metal_sheet/ATTRIBUTION.md). Godot expects the OpenGL green convention; the `_nor_gl` file is the one in the materials.

**Texture written by code:** `godot/art/hint/grey_3x1.png`, 3 × 1 texels of grey 64, 128, 192, written by `godot/tests/write_grey_strip.gd`.

No generated textures. No models from any generator. Nothing downloaded besides the four Poly Haven PNGs.

## Shaders (hand-written)

| File | Written by | From |
|---|---|---|
| `godot/shaders/hose_glow.gdshader` | me, typed in TextEdit | CHANGE-BRIEF A2 (uniform table and colour line), with Claude's line-by-line explanation |
| `godot/shaders/hint_experiment.gdshader` | me, typed in TextEdit | CHANGE-BRIEF Part B |
| `godot/shaders/hydrant_surface.gdshader` | me, typed in TextEdit | CHANGE-BRIEF C3 |
| `godot/shaders/standard_generated.gdshader` | Godot (StandardMaterial3D → ShaderMaterial conversion); annotated by me | Step 4 |

No agent session edited any file under `godot/shaders/` (`git diff --stat godot/shaders/` empty after each session; the two temporary mutations and the one-line shader-edit observation were made from the shell and restored with `git checkout`).

## Tools and versions

| Tool | Version | Used for |
|---|---|---|
| Godot | 4.7.2 stable, GL Compatibility | the game, headless tests, windowed captures |
| Claude Code | 2.1.285, model `claude-fable-5-1` (from the session transcripts) | the interactive session; three non-interactive `claude -p` runs with scoped tools (`a5/prompts/`, transcripts in `a5/sessions/`) |
| GNU `timeout` (coreutils, Homebrew) | — | `scripts/run-test.sh` |
| TextEdit (macOS) | — | typing the shaders |
| Brutalist `godot-gamedev` skill, walker modifier | (version recorded in the film folder's SOURCES) | the explainer film |

## What AI contributed

- **Explanation:** what a shader, material, texture and the shading language are, with my game as the example; the line-by-line meaning of the three shaders; the pixel and sRGB arithmetic shown step by step.
- **CLAUDE.md:** the draft (`claude -p`, read-only tools, `a5/sessions/session-1.jsonl`).
- **Driver and tests:** `godot/features/player/hose_glow.gd`, the 2-line hook in `player.gd`, `godot/tests/test_hose_glow.gd` (`session-2a-plan.jsonl`, `session-2b-implement.jsonl`).
- **Audit:** `godot/MATERIALS.md` and `godot/tests/test_materials.gd` (`session-3-audit.jsonl`).
- **Capture and helper scripts:** `capture_glow.gd`, `capture_hint.gd`, `capture_hydrant.gd`, `write_grey_strip.gd`, `calibrate_normal_maps.gd`; `normal_map_check.gd` is the assignment's code, copied.
- **Materials and scenes:** the four `.tres` materials, `hint_experiment.tscn`, the second hydrant and the Use External import setting.
- **Docs:** drafts of CHANGE-BRIEF (from my decisions), TEST-REPORT, FRICTIONAL, this file, the film script and narration.

## What I did

- Chose the state, the colour, the timing, the textures and the two materials; approved the driver plan; typed the three shaders; reviewed the brief, CLAUDE.md, the driver, the test and the audit; ran the mutations and watched them fail; looked at every capture and recorded what I saw (TEST-REPORT human-check lines); wrote the language notes.
