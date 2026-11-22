# SOURCES — Assignment 7

Earlier assignments' sources: [`../SOURCES.md`](../SOURCES.md) (A2: generative models, art, audio), [`../a3/SOURCES.md`](../a3/SOURCES.md), [`../a5/SOURCES.md`](../a5/SOURCES.md), [`../a6/SOURCES.md`](../a6/SOURCES.md).

## Started from

- **My Assignment 6 game** in this repository (tag `a6`, commit `ae4fc03`). It is the game I chose in Assignment 2, `walker-ninja-firefighter-joe` (Extinguisho, a deadpan ninja firefighter). I have not changed games.
- A7 adds two animations: the person survivor's wave (a cutout rig, the cycle) and Joe's survivor toss (a sprite-sheet frame track, the committing action), their state-machine wiring, read-back, pin, state and edge tests, a frame-strip preview, captures and docs. Collision, movement, input, the state machine's states and timings, the existing tests and their expectations, my A5 shaders and my A6 effects are unchanged (CHANGE-BRIEF.md "Boundaries").

## The sprite sheet

- **`godot/art/character/joe_sheet.png`** is packed by `tools/make_joe_sheet.py` from the 12 pose images I generated with ChatGPT in Assignment 2. No new image was generated for the required work. Provenance and licence: [`../godot/art/character/ATTRIBUTION.md`](../godot/art/character/ATTRIBUTION.md) (OpenAI Terms of Use, effective 2026-01-01, checked 2026-11-22: the user owns the output).
- **The rig** (`godot/features/survivor/survivor_person.tscn`) is built from the same rectangles and circles `session.gd` drew the person with since Assignment 1; no image is involved.

## Run-cycle attempt (parked, not in the game)

Before the required work I tried to make a running cycle for Joe in ChatGPT (chat "Create Run Cycle Sprite Sheet", ChatGPT Plus on the free student offer, Instant mode, 2026-11-20 and 2026-11-22). Claude Code wrote the prompts; I sent them and judged the results. None of these images is committed or used; the run cycle waits until the basics are done (CHANGE-BRIEF.md header).

| Try | Prompt (attached image) | Outcome |
|---|---|---|
| 1 | four-frame sheet, legs only change (`design/character/poses/pose02-run.png`) | Rejected by me: only two distinct poses, the same leg folds every time, and the head drifts about 30 px between frames (measured). |
| 2 | one frame edit, "the OTHER leg folds" (frame 2 of try 1) | The fold was right, but in the cycle the legs still did not read as alternating (my verdict). |
| 3 | eight-frame sheet, two rows, far leg darker (frame 1 of try 1) | Top row usable; the bottom row was a copy of the top (93–97% the same outline) and no leg was darker. |
| 4 | per-frame two-step edits: shade the far leg, then swap the shading (frames 1 and 2 of try 3) | Frame 1 worked (same outline 98.8%, colours swapped). Frame 2 worked in a new chat (an attempt in the old chat edited the previous image instead). Frames 3 and 4 not done. |

## Course material used

| What | From | How |
|---|---|---|
| `scripts/run-test.sh` | the Assignment 7 text | copied verbatim (`82fdeb2`); `scripts/run-all-tests.sh` counts the same error strings |
| `track_problems()` and the read-back checks | the Assignment 7 text | copied into `godot/tests/anim_checks.gd`, unchanged apart from the comment |
| The Step 1, 3, 4 and 5 prompts | the Assignment 7 text | `a7/prompts/`, placeholders filled |
| Chapters 10–11 and Examples 10–11 | [nikbearbrown/csye-7270-building-virtual-environments](https://github.com/nikbearbrown/csye-7270-building-virtual-environments) | read for the pin, edge and mutation patterns; no code copied |
| The reference game `walker-jumpman-clawd` | course repository | not used; none of its art or code is copied |

## Tools and versions

| Tool | Version | Used for |
|---|---|---|
| Godot | 4.7.2 stable (`ed1daf0bf`), GL Compatibility | the game, headless tests, the probe, Movie Maker captures |
| Claude Code | 2.1.285, model `claude-opus-5-5` | one interactive session that explained, measured, built, tested, organised and committed; one non-interactive `claude -p` run with read-only tools for the CLAUDE.md draft (`a7/prompts/prompt-1.txt`, transcript `a7/sessions/session-1.jsonl`) |
| Python 3 + Pillow | — | `tools/make_joe_sheet.py`; measuring the run-cycle tries |
| GNU `timeout` (coreutils, Homebrew) | — | `scripts/run-test.sh` |
| ChatGPT image generation | Plus, Instant mode | the parked run-cycle tries only (table above) |
