# TUNING — Assignment 6

Every strip here is a **fixture capture**: a preview scene (`godot/previews/`), not the running game, rendered by Godot's Movie Maker at 1280 × 720 and 30 fps on the GL Compatibility renderer (Apple M1), with fixed seeds on the preview's own instances. I run every capture. Verdicts are mine, in my words, from the running game or the preview window at the project's window size (1280 × 720). Claude's readings and predictions are claims; where we disagree, my verdict decides and the disagreement is written down.

## 2026-11-07 — Effect A, first strip r0 (before any tuning)

- **Strips:** `captures/jump_puff/r0/` (frames 10, 12, 15, 20, 30, 50; trigger on frame 10) and `captures/jump_puff/r0_retrigger/` (frames 10–55; triggers on 10 and 25). Commit `e3cad94`.
- **My first look (2026-11-06, preview window):** "idk i couldnt tell to small maybe". Afterwards we found the preview had not fired at all in most real-time runs (the agent's `frame == 10` check missed the frame in a live window); fixed in `6b5c613`, captures unaffected.
- **My first verdict (2026-11-07, preview window at 1280 × 720, `-- loop`, a puff every 1.2 s), before Claude read any frame:** "for now it looks fine i wanna test once its in the game, the size looks fine"
- **Claude's reading of r0:** _pending; read after the effect is in the game (Step 4)._

## 2026-11-07 — Effect A in the running game: the event moves from the jump to the landing

- **What I saw (running game, 1280 × 720, after `9a3b1f8` wired the puff to `jumped`), in my words (typos fixed):** "i checked the puff and it appearing at jumps looks good, but i think it doesnt make sense before, but makes sense to appear at the landing, so lets change that"
- **Change:** not a setting. The event moves from the jump to the landing, through a new `landed` signal in `player.gd` emitted when the game already switches him to the landing pose (CHANGE-BRIEF Revision 2, my decision; option chosen over a driver that watches `is_on_floor()` itself). Every effect setting stays the same, so the r0 strip still shows the puff's look.
- **This is a design change from play, not a tuning step:** the one-setting tuning loop (prediction, two strips, verdict) follows separately.
