# FACTCHECK

Every narrated claim in the draft, with its source in this repository (game source revision `7848c6e`). Checked by Claude Code against the files. Sreeja reviews the final film. The TODO-HUMAN beats (H1–H3) carry no claims yet.

| Beat | Claim | Source |
|---|---|---|
| B00 | two animations: a survivor who waves, a toss that commits | CHANGE-BRIEF.md "The two clips" |
| B01 | a test proves a clip's structure; frames and eyes judge the motion | CLAUDE.md "Headless facts"; a7/TEST-REPORT.md HUMAN CHECK rows |
| B02 | the wave turns one arm on a shoulder pivot; the toss grabs, throws, settles | `godot/features/survivor/survivor_person.tscn` (Shoulder); CHANGE-BRIEF Revision 2 phase table |
| B03 | the brief, written from her decisions, named both clips, routes, one authority each, the toss as a frame table, before any clip | CHANGE-BRIEF v1 `f0a6de5`, before Step 3 `1bcc714`; pins committed `c643146` before the wiring `74363a6` |
| B04 | the wave is three keys on Shoulder:rotation, 0 / 0.45 / 0 rad, 24 frames, looping | `survivor_person.tscn` lines 4–17 (`length = 0.8`, `loop_mode = 1`, `step = 0.0333333`, keys at 0, 0.4, 0.8) |
| B05 | the arm swings out and back while Joe hoses; first and last key equal, no seam | take 10.5–15.9 s; `play-states.jsonl` `shoulder`; `test_wave_readback.gd` `seam` (logs/test_wave_readback_60fps.log) |
| B06 | twelve A2 poses packed into a 4 × 3 grid, feet on one point in every cell | `tools/make_joe_sheet.py`; `joe_art.tscn` lines 13–15; `godot/art/character/ATTRIBUTION.md` |
| B07 | cell 8 grab, 9 throw, 1 ready stance; a wrong grid shows the wrong pose with no error | `godot/animations/joe.tres` toss values [8, 9, 1]; `test_toss_readback.gd` `sheet-grid`, `frame-in-sheet` |
| B08 | 60 frames a second, one per tick; grab 0, throw 14, settle 30, done at 46; keys built by the script | `godot/tools/bake_joe_clips.gd` lines 8–14; CHANGE-BRIEF Revision 2 |
| B09 | tick 14: arm up and the survivor leaves the hand in the same frame; 30 ready stance; 46 standing | `logs/toss_preview_r0.log` strip frames 37, 45, 53; `captures/toss/r0/boundaries_r0.png` |
| B10 | a misspelled property is silent; the helper checks node and property | CLAUDE.md "Headless facts"; `godot/tests/anim_checks.gd` lines 16–24 (the property check itself is line 35) |
| B11 | read-backs 66 and 13; one letter added, the test failed and named it; four other planted mistakes failed | logs at `7848c6e`; `a7/evidence/mutations/1a…, 1b, 2, 3, 5` (exit 1 each); `4-empty-import-cache` passes by design |
| B12 | only Joe's animation player writes his picture; restart from frame zero on every grab | `godot/features/player/player.gd` lines 87–95; CHANGE-BRIEF "Clip 2" authority |
| B13 | a jump interrupts the grab on frame seven; the toss carries on in the air; a planted second writer failed the state test | `play-states.jsonl` ticks 961–1007 (jump takes effect on 968); `a7/evidence/mutations/5-second-writer.txt` |
| B14 | the launch is decided on the physics tick; the clip advances by hand on that tick, only while enabled | `player.gd` lines 187–195; `session.gd` `fl.t == GRAB_TICKS`; CHANGE-BRIEF "The two clocks" |
| B15 | pause freezes the toss and resumes it; R cuts it with respawn; throw on the launch tick; before, two ticks late (~0.033 s) | `play-states.jsonl` ticks 1201–1263; `test_toss_edges.gd` baseline and ESC/R checks; a7/TEST-REPORT.md "Two clocks" |
| B16 | brief said launch on 15, pin measured 14; Claude read code and was off by one, the predicted failure; table moved, keys followed; R at a rescued window re-rescues, recorded not fixed | `logs/test_pins_a7_60fps.log` `launch-after-touch`; CHANGE-BRIEF Revision 2 and predicted failure 3 |
| B17 | that off-by-one, two test bugs caught before commit, four refused commands; no headless run draws a pixel | a7/FRICTIONAL.md sections 4–6; `a7/sessions/session-1.jsonl` (4 permission denials); CLAUDE.md "Headless facts" |
| B18 | verified by tests: clips as the brief says, pins unchanged, every state and interrupt, every planted mistake caught; her eye checks in the running game still to come; next: guard the re-rescue; directed and decided by Sreeja, implemented by Claude; the sheet is her A2 art, OpenAI terms give her the rights | a7/TEST-REPORT.md (HUMAN CHECK rows "Not yet done by me"); CHANGE-BRIEF header (her decisions); `godot/art/character/ATTRIBUTION.md` (terms checked 2026-11-22). The draft makes no claim that she has played; "eye-tested and played by Sreeja" is restored only after she plays (TODO-HUMAN note in SCRIPT-DRAFT.md B18). |
| B19 | the suggested next change | suggestion, not a claim |
