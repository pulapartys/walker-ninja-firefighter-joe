# SUBMISSION — Assignment 7

> Draft while the human checks, the tuning revision and the film are still to do. The items marked *pending* are filled in before the `a7` tag.

- **Assignment:** Assignment 7 - Doing Animation with Claude and Godot
- **Student:** Sreeja P
- **Project name:** walker-ninja-firefighter-joe (Extinguisho)
- **GitHub repository URL:** https://github.com/pulapartys/walker-ninja-firefighter-joe
- **Git tag and submitted commit SHA:** tag `a7`. The submitted commit is the one this file is in; its SHA is given in the Canvas note, because a commit cannot contain its own SHA. *Revision chain pending.*
- **Game-source revision shown in the film:** *pending.*
- **Godot version, renderer, and operating system:** Godot 4.7.2 stable (`ed1daf0bf`) · GL Compatibility · macOS 26.6.2, Apple M1.
- **Sprite clip: route, node, scene, frame rate:** Joe's survivor toss. Route: `Sprite2D` with an `AnimationPlayer` frame track. Node: `Sprite` (under `Art`) in `godot/features/player/joe_art.tscn`, clips in `godot/animations/joe.tres` (baked by `godot/tools/bake_joe_clips.gd`). Frame rate: 60 fps, one frame per physics tick, `step` 1/60. Keys: cell 8 (grab) on frame 0, 9 (throw) on 14, 1 (ready stance) on 30; 46 frames; `LOOP_NONE`; discrete.
- **Rig clip: route, rig source, node, scene, frame rate:** the person survivor's wave. Route: cutout rig keyed as resource text. Rig source: the person's own rectangles and circles from `session.gd` (Assignment 1), rebuilt as `Polygon2D` parts. Node: the `Node2D` pivot `Shoulder` in `godot/features/survivor/survivor_person.tscn`, placed by `godot/game/session.gd`. Frame rate: 30 fps, `step` 1/30; keys 0 / 0.45 / 0 rad on frames 0 / 12 / 24; `LOOP_LINEAR`.
- **Which clip loops and which commits:** the wave loops (cycle); the toss commits (startup 0–13, active 14–29, recovery 30–45).
- **The one authority over each animated node:** Joe's `Sprite.frame` is written only by Joe's `AnimationPlayer`, which only `player.gd`'s state machine drives (`show_pose()` and the end of `_physics_process`). The person's `Shoulder.rotation` is written only by the rig's own `AnimationPlayer` (autoplay); `session.gd` writes only the rig root's `visible`.
- **Sprite sheet source and licence (or model, version, and terms):** packed by `tools/make_joe_sheet.py` from my 12 Assignment 2 poses, generated with ChatGPT image generation (Plus on the free student offer, Instant mode; prompts in `CHARACTER-SHEET.md`). OpenAI Terms of Use, effective 2026-01-01, checked 2026-11-22: the user owns the output; no restriction on publishing. Credits: `godot/art/character/ATTRIBUTION.md`.
- **Final film URL and filename:** *pending.*
- **Final film SHA-256:** *pending.*
- **Summary of my work:**
  - **Directed and decided:** both clips, which loops and which commits, the routes, and doing the basics before the run cycle. I approved the plan before the brief was committed.
  - **Run cycle (parked):** I sent every ChatGPT prompt, downloaded and judged every result, and spotted that the legs didn't alternate (FRICTIONAL §2).
  - **Human checks, tuning verdict and the observation-driven revision:** *pending.*
  - **Claude Code implemented:** the brief's text from my decisions and its revisions; the CLAUDE.md draft (`claude -p`, read-only) and review; the sheet packer, clip baker, scenes and wiring; the pins, read-backs, state, edge and mutation tests; the probe; the captures and their readings; the docs and the film.
- **Checks run (command and result):** `./scripts/run-all-tests.sh` at `a01b6dd`: ALL AS EXPECTED.
  - **New suites:** `test_pins_a7` 8/8 (committed before the wiring, unchanged after), `test_toss_readback` 66/66, `test_wave_readback` 13/13, `test_anim_states` 16/16, `test_toss_edges` 40/40.
  - **Earlier suites, unchanged:** `test_game` 41/41, `test_keyboard` 14/14, `test_audio` 12/14 pinned (two known failures) and 14/14 realtime, `check_props` PASS, `test_hose_glow` 15/15 at 30, 60 and 144, `test_materials` 35/35, jump puff 94/94 and 30/30, hose steam 89/89 and 18/18.
  - **Mutations** (each in a worktree): toss subname, wave subname, wave `LOOP_NONE`, a key on cell 12, a second writer on Joe's sprite: all exit 1. Empty import cache: both read-backs pass.
  - **Fresh-clone rerun of tag `a7`:** *pending (runs after the tag exists).*
- **Known limitations:**
  - The run cycle is parked: two of four frames made, not in the game.
  - R while still standing on a rescued survivor's window rescues them again at once. This is pre-existing game logic, recorded in CHANGE-BRIEF Revision 2 and not fixed.
  - The wave keeps playing behind the pause card, because the game's pause is not a tree pause.
  - The tests run at 60 fps only; the strip is read at 30 fps.
- **Changed games since Assignment 2 (yes/no; if yes, FRICTIONAL.md entry):** no.
