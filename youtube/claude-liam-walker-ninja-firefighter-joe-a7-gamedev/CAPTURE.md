# CAPTURE

- **The take (B05, B13, B15; two frames in B02):** Godot 4.7.2 Movie Maker, `capture/film_capture.gd` on an isolated git worktree of the game at `7848c6e`, with `capture/override.cfg` (window 3840×2160; the 640×360 game is shown through its own `canvas_items` stretch), `--fixed-fps 30` and `--always-on-top`. 657 frames, 21.9 s, MJPEG 3840×2160; Movie Maker reported 657 frames recorded. The game's audio track is not used.
- **What the driver does:** scripted normal input through the player's test hooks (the level's route driver, `godot/tests/route_driver.gd`), and real `InputEventKey` events for Esc and R. No position or velocity edits.
  - the route up to B1's roof, W at the blocking fire, standing while the water runs (the person waves throughout);
  - the walk into the person's window: the touch on tick 961 (16.02 s);
  - **startup interrupt:** a jump pressed on toss frame 6, taking effect on frame 7; the toss keeps its cells in the air (throw and launch on frame 14, ready stance on 30);
  - the descent, the street jump, the climb to B2 and the walk into the dog's window: the touch on tick 1179 (19.65 s);
  - **active interrupt:** Esc during the dog's active phase; the game is paused on ticks 1201–1246 and the clip stays at 0.3667 s (cell 9); Esc again resumes it;
  - **recovery interrupt:** R on recovery frame 36 (PLAYING ticks): `respawn` at the spawn point on tick 1263, the person rig visible again;
  - the take ends 50 ticks later.
- **`game.test_mode = true`** is set by the driver. Its only effect in `session.gd` is to disable the pause on window-focus loss, which Movie Maker would otherwise trigger.
- **Logs** in `capture/logs/`: `play-inputs.jsonl` (every scripted press), `play-states.jsonl` (per tick: state, pose, Joe's clip, its position, `Sprite.frame`, `bag_pose`, rescued count, flight launch, position, hosing, the rig's visibility and shoulder rotation), `play-marks.jsonl` (event times), `play-framemd5.txt` (one md5 per frame).
- **Stale-frame check** (md5 of every frame, the A6 lesson): runs of three or more identical frames only at the title card (0–14), the start stance where only the HUD timer changes (17–27, runs of 3), frames 607–618 inside the Esc pause (the pause card covers the scene; the flight keeps moving under it, so the rest of the pause is not identical) and the end (654–656).
- **Edit:** B05 plays take 10.5–15.9 s; B13 plays 15.85–17.25 s, then a **SLOWED REPLAY** of 15.98–16.82 s at 0.25× (each frame repeated four times, nothing interpolated, labelled on screen); B15 plays 19.4–21.9 s. Where the narration is longer, the last frame is held and labelled **HELD FRAME**. Segments, replay and holds are listed in `evidence/edit-map.json` with the take's SHA-256 (`297b4a18…91edb3`).
- **Labels on screen:** "SCRIPTED-INPUT CAPTURE, NOT A HUMAN PLAYTEST"; the r0 strip in B09 is "FIXTURE CAPTURE".
- `capture/play.avi` is not in git (size).
