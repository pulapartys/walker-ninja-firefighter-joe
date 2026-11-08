# SOURCES — Assignment 6

Earlier assignments' sources: [`../SOURCES.md`](../SOURCES.md) (A2: generative models, art, audio), [`../a3/SOURCES.md`](../a3/SOURCES.md), [`../a5/SOURCES.md`](../a5/SOURCES.md).

## Started from

- **My Assignment 5 game** in this repository (tag `a5`, commit `b3f457b`). It is the game I chose in Assignment 2, `walker-ninja-firefighter-joe` (Extinguisho, a deadpan ninja firefighter), which grew from my Assignment 1 project `walker-jumpman-joe` (a fork of [nikbearbrown/walker-jumpman](https://github.com/nikbearbrown/walker-jumpman)). I have not changed games since Assignment 2.
- A6 adds two particle effects, their drivers, tests, previews, captures and docs. Collision, movement, input, the state machine and its timings, the existing tests and their expectations, and my A5 shaders are unchanged. `player.gd` gains presentation hooks and one `landed` signal (CHANGE-BRIEF Revision 2).

## Textures

- **None sourced, downloaded or generated.** Both effects draw a `GradientTexture2D` defined inside their own scene file. Provenance: [`../godot/effects/ATTRIBUTION.md`](../godot/effects/ATTRIBUTION.md).
- No generative model was used for any asset in this assignment.

## Course material used

| What | From | How |
|---|---|---|
| `scripts/run-test.sh` | the Assignment 6 text | copied verbatim (`78d926e`) |
| Example 09's cost script `particle_cost.gd` | [nikbearbrown/csye-7270-building-virtual-environments](https://github.com/nikbearbrown/csye-7270-building-virtual-environments), `examples/09-particle-effects/tests/` | copied unchanged to `a6/evidence/probes/particle_cost_example09.gd` to confirm the headless facts on my machine; `godot/tests/cost_effects.gd` is the agent's adaptation of it |
| Chapter 9 facts (renderer limits, Visual Profiler note, the 6.9 ms headless sleep) | the same repository, `chapters/09-particle-effects.md` | cited in CHANGE-BRIEF.md and CLAUDE.md; checked on my machine where it could be |
| The reference game `walker-jumpman-clawd` | course repository | not used; none of its art or code is copied |

## Generated code

| File | Written by |
|---|---|
| `godot/shaders/particles_generated.gdshader` | Godot 4.7.2, by my converting a copy of the steam's `ParticleProcessMaterial` to a `ShaderMaterial` in the editor (Step 6, `bf9bbfc`) |

## Tools and versions

| Tool | Version | Used for |
|---|---|---|
| Godot | 4.7.2 stable (`ed1daf0bf`), GL Compatibility; Mobile + Vulkan only for the GPU price | the game, headless tests, Movie Maker captures, GPU timing |
| Claude Code | 2.1.285, model `claude-opus-5-5` (from the session transcripts' init events) | one interactive session that explained, measured, organised and committed; nine non-interactive `claude -p` runs with scoped tools (`a6/prompts/`, transcripts in `a6/sessions/`) |
| GNU `timeout` (coreutils, Homebrew) | — | `scripts/run-test.sh` |
| Python 3 (Anaconda) + Pillow + numpy | — | the background contrast measurement (`a6/evidence/probes/measure_contrast.py`) and the zoomed comparison sheets of the strips |
| macOS `md5` | — | finding stale (repeated) frames in Movie Maker captures |
| A local `godot` shim in `~/.local/bin` | — | lets the course wrapper and the allow lists call plain `godot`; not in the repository |
| Brutalist `godot-gamedev` skill, walker mode | checkout `6a8380a` of github.com/nikbearbrown/brutalist.art | the explainer film (built by a background copy of the interactive Claude Code session) |
| Kokoro (`kokoro-onnx`, voice `am_onyx`, "Liam") | local, free, Apache-2.0 model | the film's narration |
| QuickTime Player, Godot editor (Visual Profiler, Convert to ShaderMaterial) | macOS / Godot 4.7.2 | watching the film; my Step 6 conversion and GPU reading |

The Claude account used for every session was the one logged in on this Mac; commits and pushes are all from my Northeastern GitHub identity `pulapartys`.

## Collaborators

None. No other person played or reviewed the game for this assignment.

## How the work was split

Directed and decided by me; implemented by Claude; eye-tested and played many times by me. The details follow.

## What AI contributed

- **Explanation and facts:** what each part of a particle system decides, CPU versus GPU particles, why a headless price of a GPU effect is near zero; the measurements behind the brief (background luminance and contrast, jump timing); the Godot 4.7.2 property-name probes; the GPU-timing probe that found only the Vulkan driver reports GPU time on this Mac.
- **CHANGE-BRIEF.md sections A and B and Revisions 1–5:** typed from my decisions. Revision 5 (steam draw order) was decided by Claude under my "finish all" instruction and is marked for my confirmation.
- **CLAUDE.md:** the draft (`claude -p` session 1, read-only tools) and the review edits (interactive session).
- **Effects, drivers, previews and tests:** `jump_puff.tscn`, `hose_steam.tscn`, `jump_puff_driver.gd`, `hose_steam_driver.gd`, the `player.gd` hooks and `landed` signal, both preview scenes, both configuration tests and both state tests, all by `claude -p` sessions from the assignment's prompts or prompts I approved. The interactive session fixed one preview bug (`6b5c613`) and two stale comments (`739da8b`).
- **Tuning:** the strip readings, the proposed changes, the predictions and the comparisons in `a6/TUNING.md`; the edits for the two kept puff revisions.
- **Measurement helpers:** `gpu_price_effects.gd`, `gpu_price_preview.tscn` (the self-playing GPU fixture for the Visual Profiler), `make_scratch_process_material.gd`, the scratch scene for Step 6, the steam preview's loop and edge modes, the cost script (`claude -p`) and its fix.
- **Captures:** the r1 and r2 puff strips and the steam strips were launched from Claude's session at my request; the windows rendered on my screen.
- **Docs:** TEST-REPORT, FRICTIONAL (organised from the session; my experience is in my words), TUNING's readings and comparisons, the README section and this file.
- **Narration and film:** the film's script (v3, from the A6 record, revised at my request), its beat sheet, captures, code panels, render and QC (Brutalist `godot-gamedev` walker, checkout `6a8380a` of github.com/nikbearbrown/brutalist.art); narration by Liam, Kokoro `am_onyx` (local, free, Apache-2.0), an AI voice, not mine. Details: `youtube/claude-liam-walker-ninja-firefighter-joe-a6-gamedev/SOURCES.md`.

## What I did

- Chose both effects, their jobs, the node types, the layers and the pause behaviour; wrote the predicted failures (by choosing them and their checks), the price guesses and budgets, and the six short answers in my own words.
- Decided, from playing the game, that the puff belongs on the landing, not the jump (Revision 2), and that the puff draws behind Extinguisho (Revision 1).
- Ran the first capture, looked at the puff before Claude read any frame, judged every tuning change in the running game and kept both, in my words.
- Delegated the remaining build work with "finish all", then eye-tested the results and played the game many times (see FRICTIONAL).
- In my feedback session: the steam's first look, the r1 choice and verdict, both screen edges, the scene-load and Esc checks, confirming Revision 5, the puff on the dark street, the Godot 3 rename in play, the Step 6 conversion and my answers, and reading the Visual Profiler.
- Asked for the film's length and register, approved script v3, and uploaded the film to my Northeastern SharePoint.
