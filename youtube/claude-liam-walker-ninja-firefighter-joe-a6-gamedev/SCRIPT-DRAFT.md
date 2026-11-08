# SCRIPT DRAFT v3 — Extinguisho's Puff and Steam

Brutalist `godot-gamedev`, `walker` mode. Liam (Kokoro `am_onyx`), in for Bear. Target 5:00–5:30 (Sreeja: "lets make it 5-5:30"); the measured narration decides the final length. v1 was about 6:07. v3 is layman-technical at Sreeja's request ("very slightly technical ... layman technical"): plain words for each required idea; the code stays on screen. Drafted by Claude Code from the A6 record, for Sreeja's approval. Every on-screen item is real engine output or a labelled reconstruction; labels are in **bold caps**.

## B00 — The prompt (Walker opening)
**On screen:** Claude composer with the prompt typed in.
**Narration:** Please use Walker to add two particle effects to my firefighter game: a puff of dust when the ninja lands, and steam that follows the fire while he hoses it. This is Liam, in for Bear. Assignment Six for C S Y E seventy-two seventy.

## B01 — What was built (Walker summary)
**On screen:** the two effects side by side, one frame each from the in-game captures.
**Narration:** Two small visual effects in a two-D Godot game, and a lesson in working with an AI that cannot see the screen. An automatic test can prove an effect starts at the right moment. It cannot prove anyone can see it. That took real frames, human eyes and a running game.

## B02 — The game, the two jobs
**On screen:** title cards over captures: Effect A, landing puff, signal `landed`; Effect B, hose steam, `player.hosing` and `fire_height()`.
**Narration:** Extinguisho is Sreeja's deadpan ninja firefighter. Effect A is a quick burst: a puff of dust every time he lands. Effect B has a different job. While he sprays the fire, steam rises, and how much steam there is follows how much fire is left.

## B03 — The brief came first
**On screen:** CHANGE-BRIEF.md, the intent block for A and for B, with the timing phases and contrast numbers highlighted.
**Narration:** Before Claude wrote anything, Sreeja wrote a plan: not just numbers, but how each effect should look. Bright for an instant, gone in under a second, big enough to notice next to him. White dust nearly disappears on her tan walls, so the puff also throws dark specks. She also wrote down what might go wrong, and a cost budget.

## B04 — Three parts of a particle system
**On screen:** **GODOT EDITOR RECONSTRUCTION**: `jump_puff.tscn` lines for `amount`, `one_shot`, `explosiveness` (emission); `particles_generated.gdshader` line 408, `force = gravity;` (process); the `texture = SubResource("GradientTexture2D_disc")` line (draw).
**Narration:** A particle effect is one object that spawns lots of tiny, short-lived dots. It has three parts, and each can go wrong on its own. Emission: when, and how many. Here, ten puffs, all at once. Process: how each dot moves and changes. This line pulls every dot with gravity. Draw: what each dot looks like: a soft round blob, made in the scene file itself.

## B05 — Effect A, built
**On screen:** the scene tree `JumpPuff` with `Flash`, `Puff`, `Specks`; then the driver `jump_puff_driver.gd`, the `landed.connect` line and `move_child` line.
**Narration:** Claude built the puff from the plan, on the computer's main processor: a quick flash, ten soft puffs and six dark specks. Each landing drops a fresh puff where he landed, behind him, and it cleans itself up when done. Land twice quickly and you get two puffs, the first one left to finish.

## B06 — The first strip, and a first look that saw nothing
**On screen:** **FIXTURE CAPTURE**, r0 strip frames 10, 12, 15, 20, 30, 50, zoomed.
**Narration:** The AI cannot watch the game, so Godot records real frames of a test scene, and Claude reads those pictures. Sreeja looked first, and saw nothing. The test scene waited for exactly frame ten, and a live window skipped right past it. A one-character fix.

## B07 — Her decision from play: the landing
**On screen:** **SCRIPTED-INPUT CAPTURE, NOT A HUMAN PLAYTEST**: landings, including two in quick succession, two puffs alive.
**Narration:** In the game, the puff first appeared on the jump. Sreeja played it and decided it made more sense on the landing. So the game got one new message, he landed, sent at the moment it already switches to the landing pose. Two quick landings: two puffs.

## B08 — Tuning the puff: Claude's reading against her eyes
**On screen:** **FIXTURE CAPTURE**, r0 against r1, then r1 against r2, with Claude's predictions as captions.
**Narration:** Tuning, one change at a time. First, a greyer fade. Claude predicted a clear grey cloud, and the zoomed frames agreed. In the game, Sreeja could not tell the difference. Her eyes are the judge, and that disagreement is on the record. Second, bigger puffs. She kept them: the dark dots now read like real dust.

## B09 — Effect B: a feedback loop
**On screen:** `hose_steam_driver.gd`, the line `var ratio := clampf(session.fire_height() / ...)` and `emitter.amount_ratio = ratio`; a graph of the ratio from 1.0 to 0 over four seconds.
**Narration:** The steam follows a number. Every frame, the code checks how tall the fire still is and turns that into a share of the steam: all of it when the water first hits, none when the fire is out. It changes the share of dots, not the total, because changing the total restarts the effect and the steam would blink. Unlike the puff, the steam runs on the graphics card, swirls, and rises from the whole width of the fire.

## B10 — Steam: her look, one change
**On screen:** **FIXTURE CAPTURE**, steam r0 against r1, frames 16 and 40.
**Narration:** Her first look: the steam was hard to see against the sky. Claude's reading agreed: the darker layer meant to make it stand out was invisible. One change: make that layer darker and more solid. Claude predicted the start would look the same. It did not: the first wisps showed up right away. Her verdict in the game: better now.

## B11 — Steam in play: start, stop, pause
**On screen:** **SCRIPTED-INPUT CAPTURE**: W at the fire, steam thinning, the fire out, the water stopping; then Esc.
**Narration:** In play, the water starts and the steam rises. It thins as the flames shrink and stops when the water stops, while the last wisps drift away. Pressing Escape pauses the game but not the particles, so the steam keeps drifting, which Sreeja chose. At both edges of the screen it does not suddenly vanish.

## B12 — The process step is a shader
**On screen:** **GODOT EDITOR RECONSTRUCTION**: `particles_generated.gdshader` line 331, `if (rand_from_seed(alt_seed) > AMOUNT_RATIO) { ACTIVE = false; }`, beside the brief's B-R3; then line 232, `mix(initial_linear_velocity_min, initial_linear_velocity_max, ...)`, beside Steam's 20 to 40 pixels a second.
**Narration:** Godot can show the hidden program behind the steam's movement. Sreeja converted a copy and found her own settings inside. Line three thirty-one skips a new dot if it falls outside the current share: her steam-follows-the-fire idea. Line two thirty-two picks each dot's speed between her twenty and forty. In her words: this program decides how dots move, grow and fade; drawing decides how they look.

## B13 — What the tests proved
**On screen:** test output lines: config 94 / 94 and 89 / 89; state 30 / 30 and 18 / 18; the two mutation failures; her own run, ALL AS EXPECTED.
**Narration:** The tests read every setting back from the files, and press real keys to check both effects start and stop at the right moments. Then a deliberate mistake: rename one setting to its old Godot three name. No warning, the test fails, and in the game the puff collapses into a blob. Tests prove settings and timing, not that anyone sees a thing.

## B14 — The price, twice
**On screen:** the cost table with the empty-scene control; the GPU probe table (0 under Metal, numbers under Vulkan); the Visual Profiler frames, labelled with the renderer.
**Narration:** Cost, measured twice. On the processor, the puff is too small to measure, inside its budget. The steam shows almost nothing there: it runs on the graphics card, and a test with no screen never uses the card. On this Mac only one graphics mode reports the card's time. There, the steam costs about a fifth of a millisecond per frame, under its half-millisecond budget.

## B15 — What Claude got wrong
**On screen:** a list, each with how it was caught.
**Narration:** What Claude got wrong, caught by checking: a test scene that skipped its own trigger, and a cost script that assumed every puff lasts equally long, then changed its rules after seeing the answer. And one of ours: recording windows hidden behind others, caught by spotting identical frames.

## B16 — Verdict
**On screen:** verdict panel; source revision.
**Narration:** The verdict. Verified: both effects set up as planned, starting and stopping at the right moments, within budget. Judged by Sreeja's eyes: the landing, the tuning, the darker steam. Still uncertain: the steam right after being hidden, and the puff's graphics-card cost. Next: her blue hose glow pulls the eye from the steam. Directed and decided by Sreeja, built by Claude Code, tested by eye and played by Sreeja. No downloaded images. Source version on screen.

## B17 — Your turn
**On screen:** the Walker prompt, read aloud.
**Narration:** Your turn. Read my change plan. The steam should visibly thin in its second second, and it is hard to see. Plan one change to the darker layer, predict what the frames will show, and name the test that must keep passing. This has been Liam, in for Bear.

## B18 — Outro
**On screen:** the locked `ClaudeTitleOutro`.
**Narration:** Extinguisho's Puff and Steam. At Nik Bear Brown.
