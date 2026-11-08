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
