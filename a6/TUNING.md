# TUNING — Assignment 6

Every strip here is a **fixture capture**: a preview scene (`godot/previews/`), not the running game, rendered by Godot's Movie Maker at 1280 × 720 and 30 fps on the GL Compatibility renderer (Apple M1), with fixed seeds on the preview's own instances. I run every capture. Verdicts are mine, in my words, from the running game or the preview window at the project's window size (1280 × 720). Claude's readings and predictions are claims; where we disagree, my verdict decides and the disagreement is written down.

## 2026-11-07 — Effect A, first strip r0 (before any tuning)

- **Strips:** `captures/jump_puff/r0/` (frames 10, 12, 15, 20, 30, 50; trigger on frame 10) and `captures/jump_puff/r0_retrigger/` (frames 10–55; triggers on 10 and 25). Commit `e3cad94`.
- **My first look (2026-11-06, preview window):** "idk i couldnt tell to small maybe". Afterwards we found the preview had not fired at all in most real-time runs (the agent's `frame == 10` check missed the frame in a live window); fixed in `6b5c613`, captures unaffected.
- **My first verdict (2026-11-07, preview window at 1280 × 720, `-- loop`, a puff every 1.2 s), before Claude read any frame:** "for now it looks fine i wanna test once its in the game, the size looks fine"
- **Claude's reading of r0:** in the r1 entry below.

## 2026-11-07 — Effect A in the running game: the event moves from the jump to the landing

- **What I saw (running game, 1280 × 720, after `9a3b1f8` wired the puff to `jumped`), in my words (typos fixed):** "i checked the puff and it appearing at jumps looks good, but i think it doesnt make sense before, but makes sense to appear at the landing, so lets change that"
- **Change:** not a setting. The event moves from the jump to the landing, through a new `landed` signal in `player.gd` emitted when the game already switches him to the landing pose (CHANGE-BRIEF Revision 2, my decision; option chosen over a driver that watches `is_on_floor()` itself). Every effect setting stays the same, so the r0 strip still shows the puff's look.
- **This is a design change from play, not a tuning step:** the one-setting tuning loop (prediction, two strips, verdict) follows separately.
- **My verdict on the landing version (running game, 1280 × 720, after `739da8b`), in my words (typo fixed):** "looks good and makes sense"

## 2026-11-07 — Effect A, revision r1: greyer puff (round 1 of 2)

- **What I saw (running game, 1280 × 720):** the landing puff "looks good and makes sense". Shown Claude's zoomed r0 strip, I chose to try both proposed changes, as two separate rounds; this is the first.
- **Claude's reading of r0** (zoomed 2× around the puff, over the B1 tan wall): frame 10 a white cluster about 12 game px with dark specks (as predicted); 12 about 20 px, specks spreading (as predicted); 15 about 25 px, already soft and see-through (brief: widest at 30–40 px, still bright); 20 a pale haze that nearly melts into the tan wall, specks gone (brief: larger, greyer, about 60 % opacity); 30 a very faint haze (as predicted); 50 nothing (as predicted). Timing matches; the puff is a little small and, from about 0.2 s, has almost no value contrast on the wall, because the dark specks that were meant to carry it there are tiny and gone by then.
- **Change (one setting), approved by me:** `Puff` `color_ramp`, middle stop (0.35) (0.85, 0.85, 0.88, α 0.7) → (0.62, 0.63, 0.68, α 0.7), end stop (1.0) (0.60, 0.62, 0.68, α 0) → (0.45, 0.47, 0.52, α 0). Alpha and the start stop unchanged. Configuration test expected value updated to match; 94/94 at 60.
- **Claude's prediction for r1:** frames 10 and 12 unchanged (the white start); 15 grey edges appear on the puff; 20 a clear grey cloud against the tan wall instead of a pale haze; 30 a faint grey, easier to see than r0's; 50 nothing. Size, position and timing unchanged.
- **Capture:** launched by Claude at my request (the window rendered on my screen); 30 fps, preview seeds unchanged, puff added on frame 10 (console).
- **Claude's comparison of r1 with its prediction:** frames 10 and 12 identical to r0, as predicted (same seeds). 15: slightly grey-blue edges, as predicted but subtler than "grey edges appear" implied. 20: a visible grey-blue cloud where r0 had a pale haze; matches the direction, but it is a soft medium grey rather than the "clear grey cloud" predicted. 30: a faint grey smudge, clearly more visible than r0, as predicted. 50: nothing, as predicted. Size, position and timing unchanged, as predicted. Not predicted: against the tan wall the new grey (0.62, 0.63, 0.68) reads slightly blue-violet, because it leans blue.
- **My verdict (running game, 1280 × 720): kept**, in my words (typos fixed): "yes this seems fine too its visible, grey shows and gradually gets lost its not that bad honestly i couldnt tell the difference a lot"
- **Claude against me:** Claude's reading of the zoomed strip called frame 20 a visible improvement; at game size and speed I could not see much difference. Kept because it does no harm and the strip shows more contrast on the wall, not because I saw it in play.
- **Strips:** `captures/jump_puff/r0/`, `captures/jump_puff/r1/`

## 2026-11-07 — Effect A, revision r2: bigger puff (round 2 of 2)

- **What I saw:** my very first look said "to small maybe"; later, in the loop preview and the game, the size looked fine to me. I asked to try this change anyway, as the second of the two rounds.
- **Claude's reading of r1:** at its widest (frame 15) the puff is about 25 game px across, below the brief's 30–40 px (1.5–2× his 20 px width).
- **Change (one setting), approved by me:** `Puff` `scale_amount_min` / `scale_amount_max` 0.35 / 0.55 → 0.5 / 0.8 (each ball about 45 % larger). Configuration test expected values updated to match; 94/94 at 60.
- **Claude's prediction for r2:** same seeds, so the same motion with bigger balls. 10: the cluster about 18 px instead of 12; 12: about 30 px; 15: the widest, about 35–40 px, the brief's target; 20: about 40 px and grey (r1's colour); 30: a larger faint grey haze; 50: nothing. Timing unchanged. Because the balls overlap more, the puff should also look denser, not only wider.
- **Capture:** launched by Claude at my request. The first two r2 captures were unusable: launched from Claude's session, the capture window opened behind my other windows (the first time also behind the game window left open from r1), macOS stopped redrawing it, and Movie Maker kept saving the last drawn frame (it reported 7, then 27 of 60 frames; md5 of consecutive files showed the repeats). Both deleted. The third capture used `--always-on-top`: 60 of 60 frames drawn; the only repeated files are 1–9 (before the trigger) and 37 on (after the puff has gone), as expected. Checked r1 the same way afterwards: its puff sits within 1 px of r0's in every kept frame, so r1 is valid. Captures launched from Claude's session now use `--always-on-top`.
- **Claude's comparison of r2 with its prediction:** 10: cluster about 17 px (predicted 18), match. 12: about 25–28 px (predicted 30), a little smaller. 15: about 30 px and denser (predicted 35–40), at the bottom of the brief's 30–40 range rather than the middle. 20: about 35 px, a bigger, denser grey cloud (predicted about 40), right direction, a little smaller. 30: about 32 px faint haze (r1 about 28), match. 50: nothing, match. Timing unchanged (gone by frame 37 in both), denser as predicted. Overall the change moved the puff the predicted way but about 5 px smaller than predicted; sizes are by eye on 2× crops, about ±3 px.
- **My verdict (running game, 1280 × 720): kept**, in my words: "i like this one better it shows those extra dots as more granular dust"
- **Strips:** `captures/jump_puff/r1/`, `captures/jump_puff/r2/`

## 2026-11-08 — Effect B, first strip r0

- **Strip:** `captures/hose_steam/r0/` (frames 10, 16, 40, 70, 100, 130, 165, 200; W on frame 10, fire out on 130, water off on 160), captured through the real driver with `--always-on-top`, 210 / 210 frames drawn.
- **My first look (preview window, `-- loop`, 1280 × 720), before Claude read any frame, in my words (typos fixed):** "i don't know if the steam is visible enough against the flashing of the firefighter the size is fine but idk if its that noticeable especially in the sky" (the "flashing" is my A5 hose glow breathing blue on Extinguisho while he hoses)

- **Claude's reading of r0** (the frames at game size, around the fire): 10 water starts, no steam (as predicted). 16 nothing visible yet (brief: first wisps), a slower start. 40 a faint pale-white cloud above the flames, mostly lost in the pale sky; the darker `Haze` layer does not show at all (brief: white steam over a darker haze, about 50 px). 70 a few faint wisps, hard to tell from 40 (brief: visibly thinner). 100 one faint wisp, a trickle (as predicted). 130 a faint remnant (as predicted). 165 and 200 nothing (as predicted). **Claude agrees with my look:** the steam barely reads on the sky, the risk the brief's contrast numbers predicted (white on that sky 1.8 : 1), and the `Haze` layer meant to carry it is invisible at α 0.5 in a mid grey.

## 2026-11-08 — Effect B, revision r1: a darker, more solid haze

- **What I saw:** my first look above: the steam is not that noticeable, especially in the sky.
- **Change (one setting), approved by me ("yes"):** `Haze` `color_ramp`: colour (0.42, 0.43, 0.47) → (0.30, 0.31, 0.35) at every stop; peak alpha at 0.2 of life 0.5 → 0.8; start and end alpha 0 unchanged. On paper the new grey (relative luminance 0.08) is about 4 : 1 against the sky's average and 2.3 : 1 against its darkest smoke clouds. Configuration test expected values updated to match.
- **Claude's prediction for r1:** 10 and 16 unchanged (still a slow start). 40 a clearly visible grey cloud above the flames with the white steam on top, readable against the sky. 70 a thinner grey column, visibly thinner than 40. 100 and 130 a faint grey trickle. 165 and 200 nothing. Risk: where the steam crosses the background's own dark smoke clouds it may blend in.
- **Claude's comparison of r1 with its prediction:** _pending._
- **My verdict (running game, 1280 × 720):** _pending._
- **Strips:** `captures/hose_steam/r0/`, `captures/hose_steam/r1/`
