# SCRIPT DRAFT v1 — Extinguisho's Puff and Steam

Brutalist `godot-gamedev`, `walker` mode. Liam (Kokoro `am_onyx`), in for Bear. Target about 6 minutes; the measured narration decides the final length. Drafted by Claude Code from the A6 record, for Sreeja's approval. Every on-screen item is real engine output or a labelled reconstruction; labels are in **bold caps**.

## B00 — The prompt (Walker opening)
**On screen:** Claude composer with the prompt typed in.
**Narration:** Please use Walker to add two particle effects to my firefighter game: a puff of dust when the ninja lands, and steam that follows the fire as he hoses it. This is Liam, in for Bear. Assignment Six for C S Y E seventy-two seventy.

## B01 — What was built (Walker summary)
**On screen:** the two effects side by side, one frame each from the in-game captures.
**Narration:** Two particle effects in a two-D Godot game, and a lesson in directing an agent that cannot see. A headless test can prove the effects fire at the right moment. It cannot prove anyone can see them. That took frames, eyes and a running game.

## B02 — The game, the two jobs
**On screen:** title cards over captures: Effect A, landing puff, signal `landed`; Effect B, hose steam, `player.hosing` and `fire_height()`.
**Narration:** Extinguisho is Sreeja's deadpan ninja firefighter, Godot four point seven, Compatibility renderer. Effect A is a one-shot: a puff of dust every time he lands. Effect B has a different job, a feedback loop: while he hoses the fire, steam rises, and the amount follows how much fire is left.

## B03 — The brief came first
**On screen:** CHANGE-BRIEF.md, the intent block for A and for B, with the timing phases and contrast numbers highlighted.
**Narration:** Before any prompt, Sreeja committed a brief. Not a list of settings: how each effect should read. Strong on frame one, gone in under a second. Measured contrast against her real walls and sky: white on the tan wall is only one point six to one, so the puff carries dark specks too. Rules a test can check. Her own predicted failures and a price budget.

## B04 — Three parts of a particle system
**On screen:** **GODOT EDITOR RECONSTRUCTION**: `jump_puff.tscn` lines for `amount`, `one_shot`, `explosiveness` (emission); `particles_generated.gdshader` line 408, `force = gravity;` (process); the `texture = SubResource("GradientTexture2D_disc")` line (draw).
**Narration:** A particle system is one node that spawns many short-lived dots, and it has three parts that fail separately. Emission decides when and how many: ten balls, all at once, once. Process decides how each one moves and changes: this line adds gravity to its velocity every frame. Draw decides what it looks like: a soft round disc, defined right in the scene file. No image, nothing to license.

## B05 — Effect A, built
**On screen:** the scene tree `JumpPuff` with `Flash`, `Puff`, `Specks`; then the driver `jump_puff_driver.gd`, the `landed.connect` line and `move_child` line.
**Narration:** Claude Code built it from the brief: three C P U emitters under one root. A flash for the first frame, ten soft balls, six dark specks. The driver never writes game state. On each landing it drops a new puff into the level, behind Extinguisho, and frees it when all three emitters finish. A second landing makes a second puff. That is the overlap rule.

## B06 — The first strip, and a first look that saw nothing
**On screen:** **FIXTURE CAPTURE**, r0 strip frames 10, 12, 15, 20, 30, 50, zoomed.
**Narration:** Claude cannot watch the game, so Godot's Movie Maker renders real frames of a preview scene for it to read. Sreeja looked first, and saw nothing: the agent's preview waited for exactly frame ten, and a live window skipped it. One character fixed it. Her verdict after: the size looks fine, test it in the game.

## B07 — Her decision from play: the landing
**On screen:** **SCRIPTED-INPUT CAPTURE, NOT A HUMAN PLAYTEST**: landings, including two in quick succession, two puffs alive.
**Narration:** In the running game the puff first fired on the jump. Sreeja played it and decided it belonged on the landing. So the player got one new signal, fired where the game already starts the landing pose, and the test moved with it. Here, two landings close together: two puffs, the first one not restarted.

## B08 — Tuning the puff: Claude's reading against her eyes
**On screen:** **FIXTURE CAPTURE**, r0 against r1, then r1 against r2, with Claude's predictions as captions.
**Narration:** One change at a time. Round one, a greyer fade: Claude predicted a clear grey cloud at frame twenty, and the zoomed frames agreed. In the game, Sreeja could not tell the difference. Her eyes, not the strip, decide, and that disagreement is on the record. Round two, bigger balls: she kept it, because the dark dots now read as granular dust.

## B09 — Effect B: a feedback loop
**On screen:** `hose_steam_driver.gd`, the line `var ratio := clampf(session.fire_height() / ...)` and `emitter.amount_ratio = ratio`; a graph of the ratio from 1.0 to 0 over four seconds.
**Narration:** Effect B follows a value. Each frame the driver reads the fire's height, divides by its full height, and writes that to amount ratio: one when the water hits, zero when the fire is out. Not amount. Changing amount restarts the system and the steam would blink. Amount ratio only switches particles on or off. It also uses three things the puff does not: G P U particles, turbulence, and a box-shaped emitter as wide as the fire.

## B10 — Steam: her look, one change
**On screen:** **FIXTURE CAPTURE**, steam r0 against r1, frames 16 and 40.
**Narration:** Her first look: the steam is hard to notice, especially on the sky. Claude's reading agreed: the darker haze meant to carry it was invisible. One change, a darker, more solid haze. Claude predicted frame sixteen would not change. It did: the first grey puff was already there. The slow start was really invisible steam. Her verdict in the game: better now.

## B11 — Steam in play: start, stop, pause
**On screen:** **SCRIPTED-INPUT CAPTURE**: W at the fire, steam thinning, the fire out, the water stopping; then Esc.
**Narration:** In play: W starts the water and the steam. The column thins as the flames shrink and stops when the water stops, while the steam already in the air finishes. Esc is not a tree pause in this game, so the steam keeps drifting at the frozen strength, which Sreeja chose to match her glow. A real tree pause freezes it in place. She checked both screen edges: no pop.

## B12 — The process step is a shader
**On screen:** **GODOT EDITOR RECONSTRUCTION**: `particles_generated.gdshader` line 331, `if (rand_from_seed(alt_seed) > AMOUNT_RATIO) { ACTIVE = false; }`, beside the brief's B-R3; then line 232, `mix(initial_linear_velocity_min, initial_linear_velocity_max, ...)`, beside Steam's 20 to 40 pixels a second.
**Narration:** Sreeja converted a copy of the steam's process material into the shader Godot writes for it. Line three thirty-one is her feedback loop: when a particle starts, if its random number is above amount ratio, it is switched off. Line two thirty-two picks each particle's speed between her twenty and forty. Her answer: the shader decides how particles move, grow and fade; the draw step decides how they look.

## B13 — What the tests proved
**On screen:** test output lines: config 94 / 94 and 89 / 89; state 30 / 30 and 18 / 18; the two mutation failures; her own run, ALL AS EXPECTED.
**Narration:** Config tests read every setting back from the scene files. State tests press real keys: one puff per landing and never otherwise, steam on and off with the water, amount ratio changing while amount stays fixed. Rename one property to its Godot three name: no warning anywhere, the speed is zero, the test exits one, and in the game the puff is a blob right under him. Proven: configuration and state. Not proven: a single visible pixel.

## B14 — The price, twice
**On screen:** the cost table with the empty-scene control; the GPU probe table (0 under Metal, numbers under Vulkan); the Visual Profiler frames, labelled with the renderer.
**Narration:** Headless, the C P U price of the puff is lost in the noise, under its budget. The steam costs nothing headless, because a headless run has no G P U and never runs its process step. That is the instrument, not the effect. To see the G P U, this Mac had to run Mobile on Vulkan; Metal reports zero. There, the steam's particle work is about a fifth of a millisecond, under its half-millisecond budget. A different renderer from the one the game ships with, and said so.

## B15 — What Claude got wrong
**On screen:** a list, each with how it was caught.
**Narration:** The agent's mistakes, caught by checking. A preview that skipped its trigger frame. A cost script that assumed every puff lives the same time, then changed its rule after seeing the answer; a re-run caught both. And one of our own: capture windows hidden behind others, which macOS stopped drawing, caught by finding identical frames.

## B16 — Verdict
**On screen:** verdict panel; source revision.
**Narration:** The verdict. Verified: both effects configured as the brief says, firing and stopping on the right game states, under budget. Judged by Sreeja's eyes: the landing, two tuning rounds kept, the darker steam. Uncertain: how the steam looks when shown after being hidden, and what the puff costs the G P U. Next, from her first look: her blue hose glow pulls the eye from the steam. Directed and decided by Sreeja, implemented by Claude Code, eye-tested and played by Sreeja. No sourced textures. Source revision on screen.

## B17 — Your turn
**On screen:** the Walker prompt, read aloud.
**Narration:** Your turn. Read my change brief. Between one and two seconds the steam should visibly thin, and it is hard to see. Plan one change to the haze, predict frames forty and seventy, and name the state-test check that must not change. One change, one prediction, one test kept honest. This has been Liam, in for Bear.

## B18 — Outro
**On screen:** the locked `ClaudeTitleOutro`.
**Narration:** Extinguisho's Puff and Steam. At Nik Bear Brown.
