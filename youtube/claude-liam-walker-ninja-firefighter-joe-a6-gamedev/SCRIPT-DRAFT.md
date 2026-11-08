# SCRIPT DRAFT v2 — Extinguisho's Puff and Steam

Brutalist `godot-gamedev`, `walker` mode. Liam (Kokoro `am_onyx`), in for Bear. Target 5:00–5:30 (Sreeja: "lets make it 5-5:30"); the measured narration decides the final length. v1 was about 6:07. Drafted by Claude Code from the A6 record, for Sreeja's approval. Every on-screen item is real engine output or a labelled reconstruction; labels are in **bold caps**.

## B00 — The prompt (Walker opening)
**On screen:** Claude composer with the prompt typed in.
**Narration:** Please use Walker to add two particle effects to my firefighter game: a puff of dust when the ninja lands, and steam that follows the fire as he hoses it. This is Liam, in for Bear. Assignment Six for C S Y E seventy-two seventy.

## B01 — What was built (Walker summary)
**On screen:** the two effects side by side, one frame each from the in-game captures.
**Narration:** Two particle effects in a two-D Godot game, and a lesson in directing an agent that cannot see. A headless test proves an effect fires at the right moment. It cannot prove anyone can see it. That took frames, eyes and a running game.

## B02 — The game, the two jobs
**On screen:** title cards over captures: Effect A, landing puff, signal `landed`; Effect B, hose steam, `player.hosing` and `fire_height()`.
**Narration:** Extinguisho is Sreeja's deadpan ninja firefighter, Godot four point seven, Compatibility renderer. Effect A is a one-shot: a puff of dust every time he lands. Effect B is a feedback loop: while he hoses the fire, steam rises, and the amount follows how much fire is left.

## B03 — The brief came first
**On screen:** CHANGE-BRIEF.md, the intent block for A and for B, with the timing phases and contrast numbers highlighted.
**Narration:** Before any prompt, Sreeja committed a brief: not a list of settings, but how each effect should read. Strong on frame one, gone in under a second. Contrast measured against her real walls: white on the tan wall is only one point six to one, so the puff carries dark specks too. Plus testable rules, her predicted failures and a price budget.

## B04 — Three parts of a particle system
**On screen:** **GODOT EDITOR RECONSTRUCTION**: `jump_puff.tscn` lines for `amount`, `one_shot`, `explosiveness` (emission); `particles_generated.gdshader` line 408, `force = gravity;` (process); the `texture = SubResource("GradientTexture2D_disc")` line (draw).
**Narration:** A particle system is one node that spawns many short-lived dots, in three parts that fail separately. Emission decides when and how many: ten balls, all at once, once. Process decides how each moves and changes: this line adds gravity to its velocity every frame. Draw decides what it looks like: a soft disc defined in the scene file. No image, nothing to license.

## B05 — Effect A, built
**On screen:** the scene tree `JumpPuff` with `Flash`, `Puff`, `Specks`; then the driver `jump_puff_driver.gd`, the `landed.connect` line and `move_child` line.
**Narration:** Claude Code built it from the brief: three C P U emitters under one root. A flash, ten soft balls, six dark specks. The driver never writes game state. On each landing it drops a new puff into the level, behind Extinguisho, and frees it when it finishes. A second landing makes a second puff: the overlap rule.

## B06 — The first strip, and a first look that saw nothing
**On screen:** **FIXTURE CAPTURE**, r0 strip frames 10, 12, 15, 20, 30, 50, zoomed.
**Narration:** Claude cannot watch the game, so Movie Maker renders real frames of a preview scene for it to read. Sreeja looked first, and saw nothing: the agent's preview waited for exactly frame ten, and a live window skipped it. One character fixed it.

## B07 — Her decision from play: the landing
**On screen:** **SCRIPTED-INPUT CAPTURE, NOT A HUMAN PLAYTEST**: landings, including two in quick succession, two puffs alive.
**Narration:** In the running game the puff first fired on the jump. Sreeja played it and decided it belonged on the landing, so the player got one new signal, fired where the game already starts the landing pose. Here, two landings close together: two puffs, the first not restarted.

## B08 — Tuning the puff: Claude's reading against her eyes
**On screen:** **FIXTURE CAPTURE**, r0 against r1, then r1 against r2, with Claude's predictions as captions.
**Narration:** One change at a time. Round one, a greyer fade: Claude predicted a clear grey cloud at frame twenty, and the zoomed frames agreed. In the game, Sreeja could not tell the difference. Her eyes decide, and that disagreement is on the record. Round two, bigger balls: kept, because the dark dots now read as granular dust.

## B09 — Effect B: a feedback loop
**On screen:** `hose_steam_driver.gd`, the line `var ratio := clampf(session.fire_height() / ...)` and `emitter.amount_ratio = ratio`; a graph of the ratio from 1.0 to 0 over four seconds.
**Narration:** Effect B follows a value. Each frame the driver divides the fire's height by its full height and writes it to amount ratio: one when the water hits, zero when the fire is out. Not amount: changing amount restarts the system and the steam would blink. It also uses three things the puff does not: G P U particles, turbulence, and a box emitter as wide as the fire.

## B10 — Steam: her look, one change
**On screen:** **FIXTURE CAPTURE**, steam r0 against r1, frames 16 and 40.
**Narration:** Her first look: the steam is hard to notice on the sky. Claude's reading agreed: the darker haze meant to carry it was invisible. One change, a darker, more solid haze. Claude predicted frame sixteen would not change. It did: the slow start was really invisible steam. Her verdict in the game: better now.

## B11 — Steam in play: start, stop, pause
**On screen:** **SCRIPTED-INPUT CAPTURE**: W at the fire, steam thinning, the fire out, the water stopping; then Esc.
**Narration:** In play: W starts the water and the steam. The column thins as the flames shrink and stops with the water, while steam already in the air finishes. Esc is not a tree pause here, so the steam keeps drifting, as Sreeja chose. She checked both screen edges: no pop.

## B12 — The process step is a shader
**On screen:** **GODOT EDITOR RECONSTRUCTION**: `particles_generated.gdshader` line 331, `if (rand_from_seed(alt_seed) > AMOUNT_RATIO) { ACTIVE = false; }`, beside the brief's B-R3; then line 232, `mix(initial_linear_velocity_min, initial_linear_velocity_max, ...)`, beside Steam's 20 to 40 pixels a second.
**Narration:** Sreeja converted a copy of the steam's process material into the shader Godot writes for it. Line three thirty-one is her feedback loop: a starting particle whose random number is above amount ratio is switched off. Line two thirty-two picks each speed between her twenty and forty. Her answer: the shader decides how particles move, grow and fade; the draw step decides how they look.

## B13 — What the tests proved
**On screen:** test output lines: config 94 / 94 and 89 / 89; state 30 / 30 and 18 / 18; the two mutation failures; her own run, ALL AS EXPECTED.
**Narration:** Config tests read every setting back from the scene files. State tests press real keys: one puff per landing and never otherwise, steam on and off with the water, amount ratio changing while amount stays fixed. Rename one property to its Godot three name: no warning, the test exits one, and in the game the puff is a blob right under him. Proven: configuration and state. Not proven: a single visible pixel.

## B14 — The price, twice
**On screen:** the cost table with the empty-scene control; the GPU probe table (0 under Metal, numbers under Vulkan); the Visual Profiler frames, labelled with the renderer.
**Narration:** Headless, the puff's C P U price is lost in the noise, under budget. The steam costs nothing headless, because a headless run has no G P U and never runs its process step: that is the instrument, not the effect. To see the G P U, this Mac needed Mobile on Vulkan. There, the steam's particle work is about a fifth of a millisecond, under its half-millisecond budget, on a different renderer from the one the game ships with.

## B15 — What Claude got wrong
**On screen:** a list, each with how it was caught.
**Narration:** The agent's mistakes, caught by checking: a preview that skipped its trigger frame, and a cost script that assumed every puff lives equally long, then changed its rule after seeing the answer. And one of ours: capture windows hidden behind others, caught by finding identical frames.

## B16 — Verdict
**On screen:** verdict panel; source revision.
**Narration:** The verdict. Verified: both effects configured as the brief says, firing and stopping on the right states, under budget. Judged by Sreeja's eyes: the landing, the tuning rounds, the darker steam. Uncertain: the steam shown again after being hidden, and the puff's G P U cost. Next, from her first look: her blue hose glow pulls the eye from the steam. Directed and decided by Sreeja, implemented by Claude Code, eye-tested and played by Sreeja. No sourced textures. Source revision on screen.

## B17 — Your turn
**On screen:** the Walker prompt, read aloud.
**Narration:** Your turn. Read my change brief. Between one and two seconds the steam should visibly thin, and it is hard to see. Plan one change to the haze, predict frames forty and seventy, and name the state-test check that must not change. This has been Liam, in for Bear.

## B18 — Outro
**On screen:** the locked `ClaudeTitleOutro`.
**Narration:** Extinguisho's Puff and Steam. At Nik Bear Brown.
