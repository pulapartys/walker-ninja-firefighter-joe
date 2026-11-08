# TEST REPORT — Assignment 6 (particle effects)

- **Engine:** Godot 4.7.2.stable.official (`ed1daf0bf`), GL Compatibility renderer (`godot/project.godot`). The GPU price alone runs under a launch override, `--rendering-method mobile --rendering-driver vulkan`.
- **Machine:** macOS 26.6.2, Apple M1 (7-core GPU). Windows report "OpenGL API 4.1 Metal – Compatibility – Apple M1"; the GPU run reports "Vulkan 1.2.334 – Forward Mobile – Apple M1".
- **How tests run:** every headless test through `./scripts/run-test.sh <test>.gd <fps|realtime> [timeout]` from the repository root (the assignment's wrapper, `78d926e`); logs in `logs/`. Frame strips are Movie Maker captures of the preview scenes (fixtures; see `a6/TUNING.md`).
- **Who did what:** I directed the work and decided every design and tuning choice; Claude implemented it (the `claude -p` sessions and the interactive session) and ran the measurements; I eye-tested and played the game many times. Each entry names its source revision. **HUMAN CHECK** marks what only my eyes judged.

## Baseline — before any A6 effect (2026-11-06)

Revision `78d926e` (wrapper replaced, nothing else changed); logs committed in `2be25da`.

| Test | Mode | Result |
|---|---|---|
| `test_game.gd` | 60 fps | 41 / 41 |
| `test_keyboard.gd` | 60 fps | 14 / 14 (no summary line; PASS lines counted) |
| `test_audio.gd` | 60 fps | 12 / 14, exit 1: `music-behaviour`, `music-loops`, the known pinned-fps failures (a5/TEST-REPORT.md) |
| `test_audio.gd` | realtime, timeout 300 | 14 / 14 in 138 s. At the default 120 s it stops after 13 checks with exit 124, because its last check waits for the 25.6 s music loop in real time. |
| `check_props.gd` | 60 fps | `RESULT: PASS` |
| `test_hose_glow.gd` | 30 / 60 / 144 fps | 15 / 15 at each |
| `test_materials.gd` | 60 fps | 35 / 35 |

No log contained `SHADER ERROR` or `SCRIPT ERROR`.

## After — every suite at revision `07d0f6e` (2026-11-08)

| Test | Mode | Result | Same as baseline? |
|---|---|---|---|
| `test_game.gd` | 60 fps | 41 / 41 | yes |
| `test_keyboard.gd` | 60 fps | 14 / 14 | yes |
| `test_audio.gd` | 60 fps | 12 / 14, the same two | yes |
| `test_audio.gd` | realtime 300 | 14 / 14 | yes |
| `check_props.gd` | 60 fps | PASS | yes |
| `test_hose_glow.gd` | 30 / 60 / 144 fps | 15 / 15 each | yes |
| `test_materials.gd` | 60 fps | 35 / 35 | yes |
| `test_jump_puff_config.gd` (new) | 60 fps | 94 / 94 | — |
| `test_jump_puff_state.gd` (new) | 60 fps | 30 / 30 | — |
| `test_hose_steam_config.gd` (new) | 60 fps | 89 / 89 | — |
| `test_hose_steam_state.gd` (new) | 60 fps | 18 / 18 | — |

No log contains `SHADER ERROR` or `SCRIPT ERROR`. `git diff --stat godot/shaders/` was empty after every agent session.

## Configuration tests

- **Effect A, `test_jump_puff_config.gd`, 94 checks:** every A3 setting on `Flash`, `Puff` and `Specks`, read back from the loaded scene, including both curves, all three colour ramps and the `GradientTexture2D` definition; no fixed seed and no `preprocess` in the effect scene. Expected values follow CHANGE-BRIEF Revisions 3 and 4 (the two kept tuning changes).
- **Effect B, `test_hose_steam_config.gd`, 89 checks:** every B3 setting on `Haze` and `Steam` and both `ParticleProcessMaterial`s. 15 of them are tagged as the features Effect A does not use: GPU nodes, `amount_ratio`, `turbulence_enabled` and its influence range, the box emission shape and extents, and `visibility_rect`. It also checks `emitting = false` in the scene, no trails, no collision and no fixed seed.
- **What they prove:** the scene files say what the brief says, with Godot 4.7.2 names, as Godot loads them. **What they cannot prove:** that anything looks right.

## Effect A mutations (2026-11-07, revision `bbe29fc`)

Performed by Claude at my request; logs in `a6/evidence/mutations/`; the scene was restored after each and the clean run is 94 / 0.

| Mutation | Test result | Note |
|---|---|---|
| **Godot 3 name:** `Puff`'s `initial_velocity_min` / `initial_velocity_max` replaced by `initial_velocity = 50.0` | **exit 1**, 2 failures (`Puff.initial_velocity_min` and `_max` read back 0.0) | Godot printed no warning: `CPUParticles2D` has no `initial_velocity`, and the line is silently dropped. |
| **Drift from the brief:** `Puff` `spread` 80 → 120, brief unchanged | **exit 1**, 1 failure (`Puff.spread` expected 80, read 120) | |

- **HUMAN CHECK, the Godot 3 name in play (2026-11-08):** with mutation 1 applied again (by Claude, not committed), I played and landed: the puff still fires on every landing, as a blob with no spread, and nothing reports an error. My words: "yes its right under him doesnt look natural looks bad". Restored afterwards; `git diff` empty and the config test back to 94 / 0.
- **Also observed:** the agent ran the same Godot 3 rename itself during session 2, and it failed the test the same way.

## State tests

Both run at `--fixed-fps 60` (neither waits on audio) and drive the game only through real key events and the real game loop.

- **Effect A, `test_jump_puff_state.gd`, 30 checks (CHANGE-BRIEF Revision 2: the landing).** Each landing gives one puff, at his feet, in the same tick. No puff appears:
  - on any of 12 jumps;
  - on load, start, R or respawn;
  - in MENU, PAUSED, DYING or COMPLETE.

  A walk-off landing after 11 ticks in the air gives one. Overlap: landings 0.833 s apart leave 2 alive, and the first is not restarted; at most 2 are ever alive. Each puff stays put, frees itself when its last emitter finishes, is frozen by a tree pause, finishes under Esc, and sits under `WalkerJumpman` below the player (A-R8).
  - **Cannot prove:** anything visible; a landing after 10 ticks or fewer (no drop in the level is that short); COMPLETE reached through play; other frame rates.
- **Effect B, `test_hose_steam_state.gd`, 18 checks.**
  - `emitting` follows `hosing` on all 1,466 recorded frames. It starts on the first hosing frame and stops on the first frame after; never on load, start, a W out of range, or a landing.
  - `amount_ratio` = `fire_height()` / 34, read at 0, 1, 2, 3 and 4 s (0.996, 0.746, 0.496, 0.246, 0), while `amount` stays 14 / 40.
  - The root follows the fire top, moving 33.9 px.
  - Esc holds the ratio while the steam keeps processing. A tree pause stops processing.
  - It is still driven while hidden.
  - R stops it on the next frame. A fire death holds it through the 2 s DYING hold.
  - The steam stays below the player in the child order on every frame.
  - **Cannot prove:** that any particle spawns or thins (no GPU process runs headless), that steam in the air finishes after the stop, or the frozen look.

## Frame strips (fixture captures)

| Strip | Commit | Notes |
|---|---|---|
| `captures/jump_puff/r0/`, `r0_retrigger/` | `e3cad94` | captured by me; 60 / 60 frames |
| `captures/jump_puff/r1/` | `a5a5ac3` | 45 frames drawn; checked against r0 (puff within 1 px in every kept frame), valid |
| `captures/jump_puff/r2/` | `5afb846` | two earlier attempts deleted (stale frames, see TUNING); third with `--always-on-top`, 60 / 60 |
| `captures/hose_steam/r0/` | recaptured after wiring | 210 / 210 frames; console: hosing on frame 10, fire out on 130, hosing off on 160 |

Readings, predictions, comparisons and my verdicts are in `a6/TUNING.md`.

## Headless CPU price (Step 7)

`./scripts/run-test.sh cost_effects.gd 60 300`: 10 repeats × 300 frames per case at `--fixed-fps 60`. The cases run in alternating rounds, with the empty scene as the control. Logs in `a6/evidence/cost/`.

| Case | Agent's run | My run 1 | My run 2 | My run 3 |
|---|---|---|---|---|
| empty scene (control) | 0.0036 ms | 0.0035 | 0.0036 | 0.0035 |
| game, effects off | 0.173 ms | 0.185 (one repeat 0.32) | 0.182 | 0.179 |
| Effect A, 2 puffs alive, vs off | +0.005 ms, 10 of 10 rounds higher | −0.011 | +0.002 | +0.003 |
| Effect B, ratio 1.0, vs off | +0.0002 ms | −0.016 | +0.0007 | +0.0002 |

- **The control works:** the game is about 50 times the empty scene, so the script measures the game, not itself.
- **Effect B** reads the same as "effects off" in every run. That is expected: headless runs no GPU particle process, so this number is the game and the script, not the steam.
- **Effect A** is not separable from the run-to-run noise in my three runs. The agent's single "+0.005 ms, different" did not reproduce.
- **Two caveats:**
  - The agent changed its "different" rule after its first run, from overlapping ranges to a paired per-round test, and said so.
  - My first re-run of the agent's script exited 1. Its own check found frames with only one puff alive, because its 0.43 s landing gap assumed a 0.88 s puff, but `lifetime_randomness` ends some puffs at 0.72 s. Claude fixed it to refill on the frame a puff ends (`db26889`). All three runs above are after the fix, and their setup checks passed.

## GPU price

- **Instrument (Claude's probe, `a6/evidence/probes/gpu_time_probe.log`):** on this M1, the viewport's measured GPU time is 0 under Compatibility, under Mobile on Metal and under Forward+ on Metal. Only Mobile on the Vulkan driver reports it: empty 0.087 ms, 20,000 GPU particles 0.687 ms. So the GPU price is taken under `--rendering-method mobile --rendering-driver vulkan`. That measures a different renderer from the one the game ships with (Compatibility), and this report says so wherever the number appears.
- **Claude's script, `godot/tests/gpu_price_effects.gd`** (a fixture: the effects are instanced on the B1 rooftop over the real level; 240 frames × 3):

| Case | Run 1 GPU ms | Run 2 GPU ms |
|---|---|---|
| level, effects off | 0.448 | 0.553 |
| Effect A, 2 puffs alive | 0.446 (not measurable) | 0.552 (not measurable) |
| Effect B, ratio 1.0, filled | 0.532 (+0.084) | 0.728 (+0.175) |

- **Run 3** (connected to the editor; the profiler could not attach to a `--script` run): off 0.525 ms, puff 0.529 ms, steam 0.619 ms (+0.094).
- **HUMAN CHECK, Visual Profiler (2026-11-08):**
  - **Setup:** the editor's Debugger > Visual Profiler, with "Keep Debug Server Open". The run was `godot/previews/gpu_price_preview.tscn`, a fixture that plays three phases by itself (effects off, two puffs, steam at ratio 1.0), launched by Claude with `--remote-debug tcp://127.0.0.1:6007 --rendering-method mobile --rendering-driver vulkan`. I could not play the game and work the profiler at once, so I pressed Start, the fixture played, and I read the frames.
  - **What it showed:** the profiler header read "GPU: Apple M1". The numbers below are the table rows I selected by clicking the GPU graph.

| Frame | Steam | Update GPU particles (GPU) | Render Viewport (GPU, total) |
|---|---|---|---|
| 6000 | off | 0.04 ms | 1.02 ms |
| 7182 | on, ratio 1.0 | 0.25 ms | 0.98 ms |
| 8830 | on, ratio 1.0 | 0.27 ms | 1.08 ms |

  - **Reading:** the steam's process step on the GPU ("Update GPU particles") is about +0.2 ms per frame, within its 0.5 ms budget and of the same order as the script's +0.08 to +0.18 ms. Single-frame totals vary by more than that, so the total frame time does not show it cleanly.
  - **The puff:** it is a CPU node, so it has no "Update GPU particles" entry, and these frames do not isolate it. I could not reliably place a frame in its phase: the run went faster than 60 fps under Vulkan, so the phases fell at other frame numbers than Claude estimated. The script's "not measurable" stands for it.
  - **Renderer:** this is Mobile on Vulkan, not the Compatibility renderer the game ships with.
- **FPS with vsync off (F9):** not done. The assignment makes the FPS comparison optional ("if you compare it"), and GPU time is the primary number; the F9 key is in the game (`godot/features/debug/vsync_key.gd`). I read nothing in Monitors.

## Budgets against prices

| | Budget | Headless CPU | GPU (script, Mobile + Vulkan) | Visual Profiler | Within budget? |
|---|---|---|---|---|---|
| Effect A (CPU node: compared on both) | 0.1 ms | not separable from noise (≤ 0.005 ms) | not measurable | not isolated (CPU node: no GPU-particles row) | yes, on both measured prices |
| Effect B (GPU node: compared on GPU time) | 0.5 ms | ≈ 0, as expected for a GPU node | +0.08 to +0.18 ms | Update GPU particles +0.21 to +0.23 ms | yes, on both GPU readings |

## My predictions against the results

| Prediction (CHANGE-BRIEF P and C) | Result |
|---|---|
| P1: a Godot 3 name leaves the speed at 0, caught by the config test | **right:** mutation 1, exit 1; the agent's own trial too |
| P2: the puff glued to the player, caught by the state test | did not happen; the state test's `stays-put` and `parent-is-level` checks would catch it |
| P3: steam before the hose, caught by my eyes | did not happen: `emitting = false` in the scene, `none-on-load` passes, and my eyes saw no steam at the start |
| Puff headless CPU "about 0" | **right** |
| Steam headless CPU "about 0, same as an empty scene" | **partly right:** the same as the game with effects off, which is about 0.18 ms, not the empty scene's 0.0035 |
| Puff GPU 0.05–0.5 ms | **wrong, lower:** not measurable |
| Steam GPU under 0.05 ms | **wrong, higher:** +0.08 to +0.18 ms (script), about +0.2 ms in the Visual Profiler's particle row |

## The process shader (Step 6)

- **What I did (2026-11-08):** in the editor I opened `godot/previews/scratch_process_material.tscn`, which holds a unique deep copy of the steam's `Steam` `ParticleProcessMaterial` (made by Claude's `make_scratch_process_material.gd`, so the real effect cannot change). I converted it with the Inspector's resource menu ("Convert to ShaderMaterial") and saved the shader as `godot/shaders/particles_generated.gdshader`, 486 lines, Godot 4.7.2's own code (`bf9bbfc`). Nothing in the game uses it; `hose_steam.tscn` is unchanged.
- **Line references.** Claude located and verified these with `grep` against the file; I chose the line tied to my brief (331).

| What | Line(s) |
|---|---|
| `shader_type particles;` | 3 |
| `void start()` / `void process()` | 319 / 374 |
| initial velocity from its minimum and maximum | 232: `params.initial_velocity_multiplier = mix(initial_linear_velocity_min, initial_linear_velocity_max, rand_from_seed(alt_seed));`, used at 361 to set the starting velocity along the spread direction |
| gravity changes velocity | 408: `force = gravity;`, then 421: `USERDATA1.xyz += force * DELTA;` (the particle's velocity), which becomes `VELOCITY` at 447–451 |
| colour over life sampled | 255: `parameters.color *= texture(color_ramp, vec2(lifetime));`, written to `COLOR` at 459 |
| scale over life applied | 254: `parameters.scale *= texture(scale_curve, vec2(lifetime)).rgb;`, applied to the particle's transform at 476–478 |
| **one line tied to a setting in my brief (my choice)** | **331:** `if (rand_from_seed(alt_seed) > AMOUNT_RATIO) { ACTIVE = false; }`. This is my feedback loop (B-R3): the driver writes `amount_ratio = fire_height() / 34`, from 1.0 when the water first hits down to 0 when the fire is out, and this line switches off that share of the particles that start. `amount` stays 40 (Steam) and 14 (Haze). |

- **Which of my brief's settings live in this shader, and which belong to the draw step (my answer, in my words, after Claude's "rulebook and costume department" explanation):**
  - Shader: starting speed (20–40 px/s), gravity (0, −15, 0), turbulence, the colour ramp, the scale curve, `amount_ratio`.
  - Draw: the texture (the soft round disc) and the blend mode (normal mix).
  - "The process shader controls how particles move, change size, and fade over time, while the draw step controls how they look on screen."


## In play — HUMAN CHECK

- **Effect A:** _done._ Triggered by normal play many times, including quick repeated landings. Kept at the landing ("looks good and makes sense"), r1 and r2 kept (`a6/TUNING.md`). Lightest background: the B1 tan wall, where all three tuning looks were made.
- **Effect B (2026-11-08, revision `2ee9203` and on):** first look in the preview: "i don't know if the steam is visible enough against the flashing of the firefighter the size is fine but idk if its that noticeable especially in the sky". After r1 (darker haze), in the running game: "its better now" (kept, Revision 6). Starting and stopping with the hose, Esc while hosing (keeps drifting) and the draw order behind Extinguisho: "all ok" (Revision 7). Size: "the size is fine".
- **Edge of screen** (the steam's `visibility_rect`), 2026-11-08: the steam preview with the camera held so the fire's centre sits 8 px inside each screen edge (`-- loop edge_left` / `edge_right`, a fixture). Left edge: "looks good ig". Right edge: "good". No pop seen at either edge.
- **Scene load** (no steam in the first frames), 2026-11-08, running game: no steam before hosing ("all ok").
- **Effect A on the darkest background**, 2026-11-08: landings at street level near the spawn, with the dark skyline behind him: "clearly visible".
- **Boundaries holding in play** (movement, hose, rescue, death, timer unchanged), 2026-11-08, in my words (typos fixed): "for the steam and everything I've played the game multiple times so that's good". The headless suites back this up (`test_game` 41/41 with the same 1268-tick scripted route, `test_keyboard`, `test_audio` unchanged).
- **Effect B hidden (`visible = false`):** checked headless only (`test_hose_steam_state.gd` `hidden-still-driven`: the driver keeps writing `emitting` and `amount_ratio`, the emitters are not visible in the tree). Nothing in the game hides the steam, and I did not hide it by eye, so what the screen shows when it is shown again is not checked.
- **Effect B against its backgrounds:** the steam only appears at the B1 fire, over the pale sky and the background's dark smoke clouds; I saw both in play and at both screen edges ("its better now", "looks good ig", "good").

## Claude against me

- **r1 (greyer puff):** Claude's reading of the zoomed strip called frame 20 a visible improvement; in the game I "couldnt tell the difference a lot". Kept anyway (`a6/TUNING.md`).
- **Effect B:** we agreed: my first look said the steam was hard to notice on the sky, and Claude's r0 reading found the haze layer invisible. Claude's r1 prediction was wrong at frame 16: the darker haze showed the first puff already there, which r0 had hidden.

## Agent mistakes caught

| Mistake | How it was caught |
|---|---|
| Session 1 wrote two scratch files under `/tmp` although told to change only CLAUDE.md; its draft dropped the Headless facts block two A5 tests cite | reading the session's tool calls; checking the tests' header comments |
| Session 2's preview fired on `frame == 10`, which a live window skips | my first look showed nothing; the console lacked the "added" line; 1 of 3 real-time runs fired |
| Session 2 deleted a file with `rm`, not on the allow list | reading the session's tool calls (accept-edits mode allowed it) |
| Session 3b's state test had a lower time bound stricter than `lifetime_randomness` allows | found by session 4 when it failed once |
| Session 7's cost script assumed a fixed puff life, so "2 alive" did not hold on every frame; it also changed its "different" rule after seeing a result | my re-run through the wrapper exited 1; the agent's own note |
| Stale Movie Maker frames from an occluded window (my own setup, not an agent) | md5 of consecutive frames; Godot's "N frames" count |
| Several sessions called the runner without `./` or Godot outside the wrapper | the result event's permission denials; each then used the allowed form |

## Open items

- The film, the `a6` tag, the fresh-clone check of the tag, the submission zip and SUBMISSION.md.
- Not done, recorded as such: Effect B hidden by eye; the puff's GPU time isolated in the Visual Profiler; the optional FPS comparison with vsync off.
