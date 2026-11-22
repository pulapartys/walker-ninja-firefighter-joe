# SCRIPT DRAFT v1 — Extinguisho's Wave and Toss

Brutalist `godot-gamedev`, `walker` mode. Liam (Kokoro `am_onyx`), in for Bear. Register as in A6, at Sreeja's earlier request: "very slightly technical ... layman technical". Target 4:30–5:30; the measured narration decides. Drafted by Claude Code from the A7 record (CHANGE-BRIEF, a7/TEST-REPORT, a7/TUNING, a7/FRICTIONAL, the logs) while Sreeja was away from the laptop; **not yet approved by her**. Every on-screen item is real engine output or a labelled reconstruction; labels are in **bold caps**. Beats marked **TODO-HUMAN** need her verdicts and are left out of the draft render.

## B00 — The prompt (Walker opening)
**On screen:** Claude composer with the prompt typed in (**ILLUSTRATIVE RECONSTRUCTION**).
**Narration:** Please use Walker to give my firefighter game two animations: a trapped survivor who waves for help, and a rescue toss that commits once it starts. This is Liam, in for Bear. Assignment Seven for C S Y E seventy-two seventy.

## B01 — What was built (Walker summary)
**On screen:** hesitant writer: "A passing test proves the motion." → "structure".
**Narration:** Two animations in a two-D Godot game: one loops, one commits. And one lesson. A test can prove a clip is built the way the plan says. Only real frames and human eyes can say whether the motion reads.

## B02 — The game, the two clips
**On screen:** **SCRIPTED-INPUT CAPTURE**: take frame 400 (the person waving while Joe hoses) and frame 488 (the throw).
**Narration:** Extinguisho is Sreeja's deadpan ninja firefighter. The cycle: the trapped person in the window waves, one arm turning on a shoulder pivot. The committing action: Joe grabs the survivor, flings them sky-high without looking, and settles back into his stance.

## B03 — The brief came first
**On screen:** CHANGE-BRIEF.md lines: both routes, both authorities, the phase table (Revision 2).
**Narration:** Before any clip existed, the brief, written from Sreeja's decisions, named both clips, the route each one takes, the single thing allowed to drive each, and the toss as a table of frames: grab, throw, settle. Behaviour pins came next: tests that record what the game already does, so the change can be checked against them.

## B04 — A clip is a list of keys (code)
**On screen:** **GODOT EDITOR RECONSTRUCTION**: `features/survivor/survivor_person.tscn` lines 5–17.
**Narration:** First idea: a clip is a list of keys, not a movie. The whole wave is three keys on one property, the shoulder's rotation: zero, nought point four five radians, zero, over twenty-four frames, looping. Nothing in it knows about the game.

## B05 — The wave in play (result)
**On screen:** **SCRIPTED-INPUT CAPTURE**, take 10.5–15.9 s at recorded speed.
**Narration:** In the running game, while Joe hoses the fire, the arm swings out and back. The first key and the last are equal, so the loop has no seam.

## B06 — The sheet and its slicing (code)
**On screen:** **GODOT EDITOR RECONSTRUCTION**: `features/player/joe_art.tscn` lines 10–21.
**Narration:** The toss uses a sprite sheet. Claude packed Sreeja's twelve Assignment Two poses into a four by three grid, each placed so his feet land on the same point in every cell. The sprite reads the grid by number.

## B07 — The real sheet (result)
**On screen:** `godot/art/character/joe_sheet.png` with its 4 × 3 slicing and cell numbers drawn on top.
**Narration:** This is the actual sheet, with its slicing drawn on top. Cell eight is the grab, nine the throw, one the ready stance. The grid decides which picture a number means, so a wrong grid would show the wrong pose without any error.

## B08 — Feel in frames (code)
**On screen:** **GODOT EDITOR RECONSTRUCTION**: `tools/bake_joe_clips.gd` lines 8–14.
**Narration:** Second idea: feel is designed in frames. At sixty frames a second, one per physics tick: grab on frame zero, throw from fourteen, settle from thirty, done at forty-six. This script builds the keys from that table; nobody types them by hand.

## B09 — The first strip (result)
**On screen:** **FIXTURE CAPTURE**: `captures/toss/r0/boundaries_r0.png`.
**Narration:** Godot recorded real frames of a preview, and the log names the tick in each one. Tick fourteen: the arm goes up and the survivor leaves his hand in the same frame. Tick thirty, the ready stance. Tick forty-six, standing again.

## B10 — A wrong name fails silently (code)
**On screen:** **GODOT EDITOR RECONSTRUCTION**: `tests/anim_checks.gd` lines 16–24.
**Narration:** Third idea: a track names a node and a property. Misspell the property and Godot stays silent: the clip plays, and nothing moves. So this helper walks every track and checks that its node and property really exist.

## B11 — What the read-backs caught (result)
**On screen:** **RECORDED HEADLESS OUTPUT**: the read-back result lines and the mutation files.
**Narration:** Both read-backs pass, sixty-six checks on Joe's clips and thirteen on the wave. Then one letter was added to a property name, in a throwaway copy. The test failed and named it. Four other planted mistakes failed their tests too.

## B12 — One authority (code)
**On screen:** **GODOT EDITOR RECONSTRUCTION**: `features/player/player.gd` lines 87–95.
**Narration:** Fourth idea: one authority. Only Joe's animation player writes his picture. The state machine just asks it to play a clip, and restarts the toss from frame zero on every grab.

## B13 — The toss in play, interrupted (result)
**On screen:** **SCRIPTED-INPUT CAPTURE**, take 15.9–17.2 s at recorded speed, then a **SLOWED REPLAY** (0.25×, frames repeated, nothing interpolated).
**Narration:** Here, a jump interrupts the grab on frame seven. The toss carries on in the air: moving never cancels it. Had a second writer touched the frame, the last one to run would win. A planted one failed the state test.

## B14 — Two clocks (code)
**On screen:** **GODOT EDITOR RECONSTRUCTION**: `features/player/player.gd` lines 187–195.
**Narration:** And two clocks. The game launches the survivor on the physics tick, so Joe's clip advances by hand on that same tick, and only while he's enabled.

## B15 — Pause and restart (result)
**On screen:** **SCRIPTED-INPUT CAPTURE**, take 19.4–21.9 s at recorded speed: the dog's toss, Esc in the active phase, R in recovery.
**Narration:** So pause freezes the toss on its frame and resumes it from there, and R cuts it with the respawn stance. The throw now lands exactly on the launch tick. Before, the picture was two ticks late, about three hundredths of a second.

## B16 — What the pins caught
**On screen:** **RECORDED HEADLESS OUTPUT**: the pin's launch line; CHANGE-BRIEF Revision 2.
**Narration:** The pins paid off before a single key existed. The brief said the launch came on frame fifteen. The pin measured fourteen. Claude had read the code and was off by one, the exact failure the brief predicted. The table moved; the keys followed. The pins also caught an old bug: R at a rescued window rescues them again. Recorded, not fixed.

## B17 — What Claude got wrong, and the limit
**On screen:** the agent's recorded mistakes (a7/FRICTIONAL.md, a7/TEST-REPORT.md).
**Narration:** The agent's recorded mistakes: that off-by-one, two bugs in its own tests caught before commit, and four commands its read-only session tried and was refused. And the limit stays: no headless run draws a pixel. Whether the motion reads is Sreeja's call, in the running game.

## H1 — TODO-HUMAN: her verdicts in play
**On screen:** her words from a7/TEST-REPORT.md HUMAN CHECK rows (the wave over five wraps, the toss in play with an interrupt in each phase, registration, darkest and lightest background).
**Narration:** TODO-HUMAN: written from her recorded verdicts once she has played; never invented.

## H2 — TODO-HUMAN: the change she made from what she saw
**On screen:** **FIXTURE CAPTURES** r0 against r1 at the changed boundary; Claude's prediction and her verdict from a7/TUNING.md.
**Narration:** TODO-HUMAN: the observation-driven revision (her observation, the phase-table change, Claude's prediction, the comparison, her verdict).

## H3 — TODO-HUMAN: where she overruled Claude
**On screen:** Claude's strip readings beside her verdicts (a7/TUNING.md, a7/TEST-REPORT.md "Claude against me").
**Narration:** TODO-HUMAN: at least one point where she disagreed with Claude's reading, or that there was none.

## B18 — Verdict
**On screen:** verdict artifact (verified / her eyes / uncertain / next / who did what / sources / revision).
**Narration:** The verdict. Verified by tests: both clips built as the brief says, the pins unchanged, every state, every interrupt, and every planted mistake caught. Still to come: Sreeja's own eye checks in the running game. Next step: guard the rescue against that old re-rescue. Directed and decided by Sreeja, implemented by Claude. The sheet is her own Assignment Two art; OpenAI's terms give her the rights.
**TODO-HUMAN (restore after she plays):** replace "Still to come: Sreeja's own eye checks in the running game." with one sentence from her recorded verdicts, and end the credit line "Directed and decided by Sreeja, implemented by Claude, eye-tested and played by Sreeja." Do the same on the verdict card (author.py, the ClaudeVerdictArtifact lines "Her eyes: …" and "Directed and decided by Sreeja · …").

## B19 — Your turn
**On screen:** Claude composer with the suggested prompt.
**Narration:** Your turn. Move one boundary in the phase table, rebuild the keys from it, predict what two frames of the strip will show, and name the read-back value that must change with it. Then go and look for yourself. This was Liam, in for Bear.

## B20 — Outro
**Narration:** Extinguisho's Wave and Toss. At Nik Bear Brown.
