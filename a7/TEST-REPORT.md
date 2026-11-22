# TEST REPORT — Assignment 7 (animation)

- **Engine:** Godot 4.7.2 stable (`ed1daf0bf`), GL Compatibility renderer · macOS 26.6.2, Apple M1.
- **Runner:** every run goes through `scripts/run-test.sh` (the A7 wrapper: exit 1 on `SHADER ERROR`, `SCRIPT ERROR` or `Failed loading resource`). `scripts/run-all-tests.sh` runs every suite and prints one verdict per run.
- **Who did what:** directed and decided by me; Claude Code built and ran the tests and the captures and wrote the readings; the checks marked **HUMAN CHECK** are mine alone. Each row names the source revision it ran on.

## Results

| Check | Evidence | Result |
|---|---|---|
| **Baseline** | every earlier suite at `82fdeb2`, before any A7 change: [`../a7/evidence/baseline_run-all-tests_82fdeb2.txt`](evidence/baseline_run-all-tests_82fdeb2.txt) | ALL AS EXPECTED: test_game 41/41, keyboard 14/14, audio 12/14 pinned (the two known real-time-clock failures) and 14/14 realtime, check_props PASS, hose_glow 15/15 at 30, 60 and 144, materials 35/35, jump puff 94/94 and 30/30, hose steam 89/89 and 18/18, cost script exit 0. |
| **Baseline, after** | the same suites at `a01b6dd`, after the wiring: [`evidence/after_run-all-tests_a01b6dd.txt`](evidence/after_run-all-tests_a01b6dd.txt) | Identical counts. ALL AS EXPECTED. |
| **Pins** | `test_pins_a7.gd` at 60, committed before the wiring (`c643146`), measured on the game before any change; re-run after the wiring (`74363a6`) and in the full run (`a01b6dd`) | 8/8 before, three runs in a row; 8/8 after, unchanged. Pinned: the scripted run's state sequence (`respawn 30, idle 13, run 45, idle 55, rising 48, landing 19, idle 30, hose 299, idle 13, run 52, grab 16, toss 30, idle 35, respawn 1, grab 16, toss 26`), landing 19, grab shown 16 from the touch, toss 30, hand-back on tick 46, launch on tick 14. **Nothing changed that the brief did not predict.** Two pinned values differed from v1 of the brief (launch 14 not 15, landing 19 not 20): the brief was wrong, not the game, and Revision 2 corrected it before any clip existed. |
| **Read-back, the toss** | `test_toss_readback.gd` at 60 (`1bcc714`) | 66/66: art scene loads; sheet 568 × 435, `hframes` 4, `vframes` 3, Sprite at (−70, −133), not centred; manual callback, no autoplay; `track_problems()` empty; the clip list is exactly the nine holds plus `toss`; every clip one `Sprite:frame` value track, `UPDATE_DISCRETE`, every key inside the 12 cells, `step` 1/60; toss keys at frames 0 / 14 / 30 (within half a frame) with cells 8 / 9 / 1, length 46/60, `LOOP_NONE`; each hold one key on frame 0 with its cell, length 1/60, `LOOP_LINEAR`. |
| **Read-back, the wave** | `test_wave_readback.gd` at 60 (`03e9066`) | 13/13: rig loads; `Shoulder` at (4.7, −16); autoplay `wave`; idle callback; `track_problems()` empty; one `Shoulder:rotation` value track; keys at frames 0 / 12 / 24 of 30 fps with 0 / 0.45 / 0 rad; length 0.8 s; `step` 1/30; `LOOP_LINEAR`; continuous; seam (value at 0 = value at 0.8 s = 0.0). |
| **Mutations** | `a7/evidence/mutations/run_mutations.sh`, each in a fresh `git worktree` of `317835f`, removed afterwards; one result file per mutation in [`evidence/mutations/`](evidence/mutations/) | 1a: toss track `Sprite:frame` → `Sprite:frames` in the clip only: `test_toss_readback` **exit 1** (`track_problems`: "toss track 0: Sprite has no property frames"). 1b: wave `Shoulder:rotation` → `Shoulder:rotaton`: `test_wave_readback` **exit 1** ("Shoulder has no property rotaton"). 2: wave `loop_mode` → `LOOP_NONE`: **exit 1** (`wave-loops`). 3: toss throw key 9 → 12 (= `hframes × vframes`): **exit 1** (`frame-in-sheet:toss`). 5 (extra): a second writer, `sprite.frame = 0` in `show_pose()`: `test_anim_states` **exit 1** (`frame-is-the-clips-key`). |
| **Fresh cache** | mutation 4: `godot/.godot` deleted in a worktree, `--import`, both read-backs | Both pass (66/66, 13/13). Expected: the wave is keyed in the scene and Joe's clips are a committed `.tres`, so nothing lives in the import cache. An imported rig whose loop mode lived in the scene would lose it here; this project has no imported rig. |
| **State machine** | `test_anim_states.gd` at 60 (`74363a6`), real keys through `Input.parse_input_event` | 16/16. Structure: every state in the brief's table, and every state `player.gd` and `session.gd` request (read from the source text), maps to a clip in `joe.tres`. Play, read with `current_animation`: respawn on Enter, idle, run, rising then landing, hose, toss on the rescue (pose `grab`), respawn on R, burned, celebrate. The person's rig is in the level at (1335, 240), waving on its own clock, hidden on rescue, visible after R. One authority: over 1,340 ticks the sheet texture never changed and `Sprite.frame` always equalled the key the current clip holds at its position. |
| **Edges** | `test_toss_edges.gd` at 60 (`a01b6dd`) | 40/40. Baseline tick log: cells 8 on frames 0–13, 9 on 14–29, 1 on 30–45, `idle` on 46; the flight launches on frame 14 and the throw cell first shows on frame 14. Interrupts at frames 13, 14, 15, 29, 30, 31, 45, 46, 47: **R** plays `respawn` on the tick it is handled, and the pre-existing re-rescue then starts a fresh toss at frame 0 (never a continued one); **LEFT** (held 3 ticks) and **SPACE** (a jump) leave the table's cells unchanged; **Esc** freezes the clip on its cell and position while paused and resumes from it. |
| **Frame strips (fixture)** | `captures/toss/r0/`: Movie Maker, 30 fps, 90 frames, from `godot/previews/toss_preview.tscn` (`toss_preview.gd`), log `logs/toss_preview_r0.log`. Kept: the boundary frames and one wave cycle; `boundaries_r0.png` and `wave_cycle_r0.png` are labelled zoom sheets. **FIXTURE CAPTURES.** | Captured by Claude (I was away from the laptop). Log: touch on strip frame 30; cell 9 and `launched` both first on strip frame 37 (tick 14); cell 1 from strip frame 45 (tick 30); `idle` on strip frame 53 (tick 46). Claude's reading: [TUNING.md](TUNING.md), r0. |
| **The cycle seam (HUMAN CHECK)** | the wave played through at least five wraps at normal speed in the running game | **Not yet done by me.** |
| **The action in play (HUMAN CHECK)** | the toss triggered by normal play many times, including an interrupt in each phase | **Not yet done by me.** |
| **Registration (HUMAN CHECK)** | `captures/toss/r0/boundaries_r0.png`: do the feet stay planted across grab, throw and ready stance? | **Not yet done by me.** Claude's reading: the feet stay on the roof line in all three cells; the stance width changes with the pose, the anchor does not. |
| **Against the background (HUMAN CHECK)** | both clips over the darkest and lightest level art they appear on | **Not yet done by me.** |
| **Two clocks** | `test_toss_edges.gd` baseline log; `logs/toss_preview_r0.log` | The toss advances on the physics tick (manual callback, advanced by `player.gd` at the end of `_physics_process`, only while enabled); the game decides the launch on the physics tick. Measured: the throw cell and the launch on the same tick, **0 s** of disagreement, headless at 60 and in the 30 fps capture. Before this change the throw picture lagged the launch by 2 ticks (pins: grab shown through tick 15, launch on 14), **0.033 s**. The wave advances on the process tick; the game reads nothing from it. |
| **Claude against me** | Claude's strip readings beside my verdicts | **Not yet done** (needs my verdicts in TUNING.md). |

## Findings

- **The brief's launch tick was wrong by one** (v1: frame 15; measured: frame 14). Caught by the Step 2 pin before anything was built; corrected in CHANGE-BRIEF Revision 2 by moving the phase table, then the keys.
- **Pre-existing re-rescue after R** (game logic in `session.gd`, not changed): R while still on a rescued survivor's area restores the survivor while the area still reports the overlap, so the next tick rescues them again. Pinned as it is; recorded in CHANGE-BRIEF Revision 2. A next step outside this assignment's boundary: guard the rescue with the same `contact_settle_ticks` the death and finish checks already use.
- **The wave keeps playing behind the pause card**, because the game's pause is not a tree pause (as the A6 steam did). By design in the brief ("The two clocks").

## Commands

```
godot --headless --path godot --import
./scripts/run-all-tests.sh
./scripts/run-test.sh test_pins_a7.gd 60
./scripts/run-test.sh test_toss_readback.gd 60
./scripts/run-test.sh test_wave_readback.gd 60
./scripts/run-test.sh test_anim_states.gd 60
./scripts/run-test.sh test_toss_edges.gd 60 180
a7/evidence/mutations/run_mutations.sh
godot --path godot --always-on-top res://previews/toss_preview.tscn --write-movie "$PWD/captures/toss/r0/frame.png" --fixed-fps 30 --quit-after 90 -- r0
```
