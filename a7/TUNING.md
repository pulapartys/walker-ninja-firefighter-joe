# TUNING — Assignment 7, Joe's survivor toss

Each revision records: what I saw, Claude's reading of the strip, the change, Claude's prediction, the comparison, and my verdict. **Frame strips are fixture captures** from `godot/previews/toss_preview.tscn` (the real game scene over the real level art at the person's window; the fixture starts the session, puts the fire out and places Joe, and a real D key walks him into the survivor). The per-frame log for each strip is `logs/toss_preview_r<N>.log`. When play says the timing is wrong, the phase table in CHANGE-BRIEF.md changes first and the keys follow (`godot/tools/bake_joe_clips.gd`, then the read-back's expected values).

## The phase table being tuned

From CHANGE-BRIEF.md Revision 2, at 60 fps (one frame per physics tick), frame 0 = the touch:

| Phase | Frames | Cell |
|---|---|---|
| Startup (grab) | 0–13 | 8 grab |
| Active (throw) | 14–29 | 9 toss (the survivor launches on frame 14) |
| Recovery (settle) | 30–45 | 1 respawn (ready stance) |
| Hand-back | 46 | locomotion |

Revision 2's change (the throw from 15 to 14) came from a measurement, the Step 2 pin, not from tuning; it is recorded in CHANGE-BRIEF.md and FRICTIONAL.md, not here.

## r0 — the first strip (fixture capture)

- **Capture:** `captures/toss/r0/`, Movie Maker at 30 fps (two physics ticks per strip frame), 90 frames, by Claude on 2026-11-22 while I was away from the laptop. Kept: strip frames 29, 30, 36, 37, 44, 45, 52, 53 (the boundaries) and one wave cycle; [`boundaries_r0.png`](../captures/toss/r0/boundaries_r0.png) and [`wave_cycle_r0.png`](../captures/toss/r0/wave_cycle_r0.png) are labelled zoom sheets. Log: `logs/toss_preview_r0.log`.
- **My first verdict (before reading Claude's):** *not yet written. I watch the preview windowed (`godot --path godot res://previews/toss_preview.tscn -- r0`) and play the game first, then write it here in my own words.*
- **Claude's reading of the strip and the log** (a claim, not a check):
  - Strip 30 (tick 0): the grab cell; the survivor drawn at his reaching hand; the bag and SAVED! appear. Strip 36 (tick 12): still the grab.
  - Strip 37 (tick 14): the throw cell, arm straight up, and the survivor just above the hand on the same frame (`launched` is true on that log line). The motion and the table agree at the active boundary.
  - Strip 44 (tick 28): the throw held, the survivor high above. Strip 45 (tick 30): the ready stance; the bag moves to that pose's back (`bag_pose` = respawn). Strip 52 (tick 44): still the ready stance.
  - Strip 53 (tick 46): idle, the narrow standing pose.
  - Registration: the feet stay on the roof line in all three cells; only the stance width changes.
  - **Where the motion and the table might disagree:** nowhere in timing. The one visual risk is the hand-back: the wide, low ready stance snaps to the tall, narrow idle on tick 46 with nothing in between, which may read as a pop. That is a question for play, not for the strip.
  - The wave (`wave_cycle_r0.png`): the arm swings out to about 26° at 0.4 s and back at 0.8 s; at rest the rebuilt person matches the old drawing.
- **Proposed change (not made):** none until my verdict. If play confirms the pop, Claude's candidate is a phase-table change, not a key edit: end the recovery on the idle cell for its last few frames (for example frames 40–45 on cell 0), so the stance settles before the hand-back. Its prediction: strip 50–52 would show idle instead of the ready stance, and tick 46 would no longer change the outline.
