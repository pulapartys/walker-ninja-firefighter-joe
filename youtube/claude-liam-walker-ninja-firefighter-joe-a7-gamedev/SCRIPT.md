# Extinguisho's Wave and Toss

Narration as voiced by Liam (Kokoro am_onyx), generated from beat_sheet.json. Script v1, drafted by Claude Code from the A7 record while Sreeja was away from the laptop (SCRIPT-DRAFT.md). **Not yet approved by her.**

**Draft cut:** the TODO-HUMAN beats H1, H2, H3 (her verdicts in play, the change she made from what she saw, where she overruled Claude) are not in this sheet; they are written in SCRIPT-DRAFT.md and go between B17 and the verdict once her verdicts exist.

## B00 — The prompt

Please use Walker to give my firefighter game two animations: a trapped survivor who waves for help, and a rescue toss that commits once it starts. This is Liam, in for Bear. Assignment Seven for C S Y E seventy-two seventy.

## B01 — What was built

Two animations in a two-D Godot game: one loops, one commits. And one lesson. A test can prove a clip is built the way the plan says. Only real frames and human eyes can say whether the motion reads.

## B02 — The game, the two clips

Extinguisho is Sreeja's deadpan ninja firefighter. The cycle: the trapped person in the window waves, one arm turning on a shoulder pivot. The committing action: Joe grabs the survivor, flings them sky-high without looking, and settles back into his stance.

## B03 — The brief came first

Before any clip existed, the brief, written from Sreeja's decisions, named both clips, the route each one takes, the single thing allowed to drive each, and the toss as a table of frames: grab, throw, settle. Behaviour pins came next: tests that record what the game already does, so the change can be checked against them.

## B04 — A clip is a list of keys

First idea: a clip is a list of keys, not a movie. The whole wave is three keys on one property, the shoulder's rotation: zero, nought point four five radians, zero, over twenty-four frames, looping. Nothing in it knows about the game.

## B05 — The wave in play

In the running game, while Joe hoses the fire, the arm swings out and back. The first key and the last are equal, so the loop has no seam.

## B06 — The sheet and its slicing

The toss uses a sprite sheet. Claude packed Sreeja's twelve Assignment Two poses into a four by three grid, each placed so his feet land on the same point in every cell. The sprite reads the grid by number.

## B07 — The real sheet

This is the actual sheet, with its slicing drawn on top. Cell eight is the grab, nine the throw, one the ready stance. The grid decides which picture a number means, so a wrong grid would show the wrong pose without any error.

## B08 — Feel in frames

Second idea: feel is designed in frames. At sixty frames a second, one per physics tick: grab on frame zero, throw from fourteen, settle from thirty, done at forty-six. This script builds the keys from that table; nobody types them by hand.

## B09 — The first strip

Godot recorded real frames of a preview, and the log names the tick in each one. Tick fourteen: the arm goes up and the survivor leaves his hand in the same frame. Tick thirty, the ready stance. Tick forty-six, standing again.

## B10 — A wrong name fails silently

Third idea: a track names a node and a property. Misspell the property and Godot stays silent: the clip plays, and nothing moves. So this helper walks every track and checks that its node and property really exist.

## B11 — What the read-backs caught

Both read-backs pass, sixty-six checks on Joe's clips and thirteen on the wave. Then one letter was added to a property name, in a throwaway copy. The test failed and named it. Four other planted mistakes failed their tests too.

## B12 — One authority

Fourth idea: one authority. Only Joe's animation player writes his picture. The state machine just asks it to play a clip, and restarts the toss from frame zero on every grab.

## B13 — The toss in play, interrupted

Here, a jump interrupts the grab on frame seven. The toss carries on in the air: moving never cancels it. Had a second writer touched the frame, the last one to run would win. A planted one failed the state test.

## B14 — Two clocks

And two clocks. The game launches the survivor on the physics tick, so Joe's clip advances by hand on that same tick, and only while he's enabled.

## B15 — Pause and restart

So pause freezes the toss on its frame and resumes it from there, and R cuts it with the respawn stance. The throw now lands exactly on the launch tick. Before, the picture was two ticks late, about three hundredths of a second.

## B16 — What the pins caught

The pins paid off before a single key existed. The brief said the launch came on frame fifteen. The pin measured fourteen. Claude had read the code and was off by one, the exact failure the brief predicted. The table moved; the keys followed. The pins also caught an old bug: R at a rescued window rescues them again. Recorded, not fixed.

## B17 — What Claude got wrong

The agent's recorded mistakes: that off-by-one, two bugs in its own tests caught before commit, and four commands its read-only session tried and was refused. And the limit stays: no headless run draws a pixel. Whether the motion reads is Sreeja's call, in the running game.

## B18 — Verdict

The verdict. Verified by tests: both clips built as the brief says, the pins unchanged, every state, every interrupt, and every planted mistake caught. Still to come: Sreeja's own eye checks in the running game. Next step: guard the rescue against that old re-rescue. Directed and decided by Sreeja, implemented by Claude. The sheet is her own Assignment Two art; OpenAI's terms give her the rights.

## B19 — Your turn

Your turn. Move one boundary in the phase table, rebuild the keys from it, predict what two frames of the strip will show, and name the read-back value that must change with it. Then go and look for yourself. This was Liam, in for Bear.

## B20 — Outro

Extinguisho's Wave and Toss. At Nik Bear Brown.

