# Extinguisho's Puff and Steam

Final narration as voiced by Liam (Kokoro am_onyx), generated from beat_sheet.json. Script v3 (layman-technical, 5:00–5:30 at Sreeja's request), drafted by Claude Code from the A6 record and approved by Sreeja (SCRIPT-DRAFT.md).

**One change to the approved text, for accuracy (B11):** "so the steam keeps drifting, which Sreeja chose" is voiced as "so the steam keeps drifting behind the pause card, which Sreeja chose". The scripted-input take shows the game's pause card covering the fire and the steam while Esc is down; the steam keeps simulating (the state test shows it) but cannot be seen. Nothing was trimmed: the measured narration is 5:06 and the film 5:13.

## B00 — The prompt

Please use Walker to add two particle effects to my firefighter game: a puff of dust when the ninja lands, and steam that follows the fire while he hoses it. This is Liam, in for Bear. Assignment Six for C S Y E seventy-two seventy.

## B01 — What was built

Two small visual effects in a two-D Godot game, and a lesson in working with an AI that cannot see the screen. An automatic test can prove an effect starts at the right moment. It cannot prove anyone can see it. That took real frames, human eyes and a running game.

## B02 — The game, the two jobs

Extinguisho is Sreeja's deadpan ninja firefighter. Effect A is a quick burst: a puff of dust every time he lands. Effect B has a different job. While he sprays the fire, steam rises, and how much steam there is follows how much fire is left.

## B03 — The brief came first

Before Claude wrote anything, Sreeja wrote a plan: not just numbers, but how each effect should look. Bright for an instant, gone in under a second, big enough to notice next to him. White dust nearly disappears on her tan walls, so the puff also throws dark specks. She also wrote down what might go wrong, and a cost budget.

## B04 — Three parts of a particle system

A particle effect is one object that spawns lots of tiny, short-lived dots. It has three parts, and each can go wrong on its own. Emission: when, and how many. Here, ten puffs, all at once. Process: how each dot moves and changes. This line pulls every dot with gravity. Draw: what each dot looks like: a soft round blob, made in the scene file itself.

## B05 — Effect A, built

Claude built the puff from the plan, on the computer's main processor: a quick flash, ten soft puffs and six dark specks. Each landing drops a fresh puff where he landed, behind him, and it cleans itself up when done. Land twice quickly and you get two puffs, the first one left to finish.

## B06 — The first strip

The AI cannot watch the game, so Godot records real frames of a test scene, and Claude reads those pictures. Sreeja looked first, and saw nothing. The test scene waited for exactly frame ten, and a live window skipped right past it. A one-character fix.

## B07 — Her decision from play: the landing

In the game, the puff first appeared on the jump. Sreeja played it and decided it made more sense on the landing. So the game got one new message, he landed, sent at the moment it already switches to the landing pose. Two quick landings: two puffs.

## B08 — Tuning the puff

Tuning, one change at a time. First, a greyer fade. Claude predicted a clear grey cloud, and the zoomed frames agreed. In the game, Sreeja could not tell the difference. Her eyes are the judge, and that disagreement is on the record. Second, bigger puffs. She kept them: the dark dots now read like real dust.

## B09 — Effect B: a feedback loop

The steam follows a number. Every frame, the code checks how tall the fire still is and turns that into a share of the steam: all of it when the water first hits, none when the fire is out. It changes the share of dots, not the total, because changing the total restarts the effect and the steam would blink. Unlike the puff, the steam runs on the graphics card, swirls, and rises from the whole width of the fire.

## B10 — Steam: her look, one change

Her first look: the steam was hard to see against the sky. Claude's reading agreed: the darker layer meant to make it stand out was invisible. One change: make that layer darker and more solid. Claude predicted the start would look the same. It did not: the first wisps showed up right away. Her verdict in the game: better now.

## B11 — Steam in play

In play, the water starts and the steam rises. It thins as the flames shrink and stops when the water stops, while the last wisps drift away. Pressing Escape pauses the game but not the particles, so the steam keeps drifting behind the pause card, which Sreeja chose. At both edges of the screen it does not suddenly vanish.

## B12 — The process step is a shader

Godot can show the hidden program behind the steam's movement. Sreeja converted a copy and found her own settings inside. Line three thirty-one skips a new dot if it falls outside the current share: her steam-follows-the-fire idea. Line two thirty-two picks each dot's speed between her twenty and forty. In her words: this program decides how dots move, grow and fade; drawing decides how they look.

## B13 — What the tests proved

The tests read every setting back from the files, and press real keys to check both effects start and stop at the right moments. Then a deliberate mistake: rename one setting to its old Godot three name. No warning, the test fails, and in the game the puff collapses into a blob. Tests prove settings and timing, not that anyone sees a thing.

## B14 — The price, twice

Cost, measured twice. On the processor, the puff is too small to measure, inside its budget. The steam shows almost nothing there: it runs on the graphics card, and a test with no screen never uses the card. On this Mac only one graphics mode reports the card's time. There, the steam costs about a fifth of a millisecond per frame, under its half-millisecond budget.

## B15 — What Claude got wrong

What Claude got wrong, caught by checking: a test scene that skipped its own trigger, and a cost script that assumed every puff lasts equally long, then changed its rules after seeing the answer. And one of ours: recording windows hidden behind others, caught by spotting identical frames.

## B16 — Verdict

The verdict. Verified: both effects set up as planned, starting and stopping at the right moments, within budget. Judged by Sreeja's eyes: the landing, the tuning, the darker steam. Still uncertain: the steam right after being hidden, and the puff's graphics-card cost. Next: her blue hose glow pulls the eye from the steam. Directed and decided by Sreeja, built by Claude Code, tested by eye and played by Sreeja. No downloaded images. Source version on screen.

## B17 — Your turn

Your turn. Read my change plan. The steam should visibly thin in its second second, and it is hard to see. Plan one change to the darker layer, predict what the frames will show, and name the test that must keep passing. This has been Liam, in for Bear.

## B18 — Outro

Extinguisho's Puff and Steam. At Nik Bear Brown.

