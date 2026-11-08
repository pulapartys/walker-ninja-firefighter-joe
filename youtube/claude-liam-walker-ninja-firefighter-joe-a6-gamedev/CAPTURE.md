# CAPTURE

- **The take (B07, B11; two frames in B02):** Godot 4.7.2 Movie Maker, `capture/film_capture.gd` on an isolated copy of `godot/` (from `git archive 486bd48`) with `capture/override.cfg` (window 3840×2160; the 640×360 game is shown through its own `canvas_items` stretch), `--fixed-fps 30` and `--always-on-top`. 627 frames, 20.9 s, MJPEG 3840×2160, the game's own audio track (not used in the film). Movie Maker reported 627 of 627 frames drawn.
- **What the driver does:** scripted normal input through the player's test hooks, and real `InputEventKey` events for Esc:
  - two hops at the spawn (street level), the second pressed inside the game's 6-tick jump buffer, so its landing comes 0.83 s after the first and two puffs are alive together (61 ticks);
  - the level's route driver (`godot/tests/route_driver.gd`) up to B1's roof, with a puff on every landing (11 in all);
  - W at the blocking fire, then standing still while the water runs;
  - Esc after 2.0 s of hosing, Esc again 1.5 s later;
  - the take ends 1.25 s after the water stops.

  No position or velocity edits.
- **`game.test_mode = true`** is set by the capture driver. Its only effect in `session.gd` is to disable the pause on window-focus loss, which Movie Maker would otherwise trigger.
- **Logs** in `capture/logs/`:
  - `play-inputs.jsonl`: every scripted press.
  - `play-states.jsonl`: per tick, the state, pose, position, live JumpPuff count, landings, `hosing`, `water_ticks`, `fire_height()`, and the steam's `emitting` and `amount_ratio`.
  - `play-marks.jsonl`: event times. Landings at 1.82 s and 2.65 s, then 9 more; W at 13.13 s; Esc at 15.13 s and 16.65 s; water stops at 19.63 s.
- **Stale-frame check** (md5 of every frame, the A6 lesson): the only repeated frames are the title card (frames 0–14), the start stance (short runs up to 3), the end, where only the HUD timer changes every 3 frames, and frames 455–499, the Esc pause. During the pause the game's pause card covers the fire and the steam, and the timer stops, so nothing visible moves. The steam keeps simulating behind the card (`play-states.jsonl` shows `steam_emitting` true; the state test shows its emitters still processing), which is why B11's narration says "behind the pause card".
- **Edit:** B07 plays take 0.5–12.9 s and B11 plays 11.0–20.85 s, each at recorded speed, with no retiming. Where the narration is longer, the last frame is held and labelled "HELD FRAME" (B07 0.9 s, B11 7.9 s). The segments are listed in `evidence/edit-map.json` with the take's SHA-256.
- **On-screen label:** "SCRIPTED-INPUT CAPTURE, NOT A HUMAN PLAYTEST". The frame strips in B06, B08 and B10 are labelled "FIXTURE CAPTURE": preview scenes, not the game.
- `capture/play.avi` is not in git (size).
