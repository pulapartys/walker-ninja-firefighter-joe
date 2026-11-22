# CHANGE-BRIEF — Assignment 7: the survivor's wave and Joe's toss (animation)

> v1 · 2026-11-22 · committed before the first setup prompt of this assignment and before either clip exists. Later revisions go under **Revisions** with a date; the v1 text is not rewritten. The Assignment 6 brief is kept at tag `a6`.
>
> Game: **walker-ninja-firefighter-joe** (Extinguisho, a deadpan ninja firefighter; 2D, Godot 4.7.2, GL Compatibility, 640 × 360 viewport shown at 1280 × 720). Both clips play in the game itself, in `res://game/main.tscn`.
>
> How this brief was written: I chose the two clips, which one loops and which one commits, the routes, and that the run cycle waits until the basics are done (chat, 2026-11-20 and 2026-11-22). Claude Code read my game's code, measured the pose images, worked out the timings tick by tick, and typed this brief from those decisions at my instruction; I approved the plan before it was committed. The predicted failures and short answers are Claude's draft, which I accepted.

## What limits the choices (facts from my project)

- **Joe is one `Sprite2D`** built in `godot/features/player/player.gd` `_ready()`. Today `show_pose()` swaps a whole texture per pose (12 images in `godot/art/character/`, anchors in `anchors.json`). The images are painted ChatGPT poses from Assignment 2 with overlapping limbs, so they cannot be cut into a cutout rig without holes. The sprite clip is therefore Joe's, and the rig clip is on a code-drawn character.
- **The trapped person survivor is code-drawn** in `godot/game/session.gd` `_draw()` from rectangles and circles, with one arm already raised. Rebuilt from the same shapes as nodes, that arm can turn on a shoulder pivot.
- **The toss is visual only.** `session.gd` changes the game state (rescued, counts, bag) on the touch tick, then calls `player.play_actions([["grab", GRAB_TICKS], ["toss", TOSS_UP_TICKS]])` with `GRAB_TICKS = 15` and `TOSS_UP_TICKS = 30`. Movement is not locked during it.
- **Order inside one physics tick:** `session.gd` sets `process_physics_priority = 10`, so the player's `_physics_process` runs first and the session's runs after it. The session's rescue therefore starts the action at the end of tick T (the touch), and the player first counts it down on tick T + 1. With today's code the grab picture shows on ticks T … T + 15, the throw on T + 16 … T + 45, and locomotion returns on T + 46. The survivor's flight launches when its counter `fl.t` reaches `GRAB_TICKS`, which is tick T + 15: one tick before today's throw picture.
- **The game's pause is not a tree pause.** `set_paused()` sets `player.enabled = false`; the player's `_physics_process` returns at once while disabled. The survivor flights keep counting in `session.gd` during pause (their loop is outside the PLAYING branch).
- **No `default_texture_filter`** is set in `project.godot`, so canvas textures are filtered linearly. A packed sheet needs transparent padding between cells.

---

## The two clips

### Clip 1 — the person survivor's wave (the cycle)

- **What it says:** "I'm alive, come and get me." The trapped person in the window waves the raised arm. The HELP! bubble says it in words; the wave says it in motion and draws the eye to the window from across the level.
- **Object:** the person survivor at level position (1335, 240) (`godot/levels/first_steps.json` `survivors`). The dog is unchanged and still code-drawn.
- **Route: cutout rig keyed as resource text.** A new scene `godot/features/survivor/survivor_person.tscn` rebuilds the person from the same rectangles and circles as `Polygon2D` parts. The raised arm and hand sit under a `Node2D` pivot `Shoulder` at the shoulder. The clip `wave` is written in the scene file as keys on `Shoulder:rotation`. Why this route: the shapes already exist in code, a plain `Node2D` pivot needs no skeleton, and resource text makes every key reviewable in a diff.
- **Authority:** the scene's own `AnimationPlayer`, with `autoplay = "wave"`. Nothing else writes `Shoulder.rotation` or calls `play()` on it. `session.gd` instantiates one rig per person survivor in `_ready()` and writes only the rig root's `visible` (false once rescued, true again on `restart_attempt()`); the root is not animated.

### Clip 2 — Joe's survivor toss (the committing action)

- **What it says:** "Got them, and I couldn't care less." Joe grabs the survivor (startup), flings them sky-high without looking (active), then settles back into his ready stance while they are still in the air (recovery). It pays off the grab and the launch the game already draws, and it gives the throw a visible end.
- **Object:** Joe (the player, `godot/features/player/player.gd`).
- **Route: `Sprite2D` with an `AnimationPlayer` frame track.** All 12 poses are packed into one sheet. Each pose becomes a clip that keys `Sprite:frame`; the toss is the one clip with several keys. Why this route: one `AnimationPlayer` then owns everything Joe's sprite shows, the read-back test sees every key, and the state machine stays the single place that decides which clip plays.
- **Authority:** Joe's `AnimationPlayer` is the only writer of `Sprite:frame`. The only code that calls `play()`, `seek()` or `advance()` on it is the player's state machine in `player.gd` (`show_pose()` and the end of `_physics_process`). `session.gd` requests states only through `player.play_actions()` (the rescue) and `player.show_pose()` (burned, celebrate), as it does today. `show_pose()` no longer writes `sprite.texture`.

## The sheet

- **File:** `godot/art/character/joe_sheet.png`, packed by `tools/make_joe_sheet.py` (Pillow, committed) from the 12 pose images in `godot/art/character/` and their anchors in `anchors.json`. The pose images are not changed: each is pasted whole, unscaled, into its cell.
- **Source:** Assignment 2. Every pose was generated with ChatGPT image generation (chatgpt.com, Plus on OpenAI's free student offer, Instant mode); prompts verbatim in `CHARACTER-SHEET.md`, asset rows in `SOURCES.md`. Author: generated by me with ChatGPT, background removal and scaling by `tools/make_sprites.py`.
- **Licence:** OpenAI Terms of Use, effective 1 January 2026, **checked 2026-11-22** (openai.com/policies/terms-of-use): "you … own the Output. We hereby assign to you all our right, title, and interest, if any, in and to Output." No restriction on publishing Output, so the public repository and the film are allowed. Credit file: `godot/art/character/ATTRIBUTION.md`.
- **Originals:** the A2 downloads were committed resized (0.78 factor) in `design/character/poses/` (recorded in `CHARACTER-SHEET.md`); the in-game images in `godot/art/character/*.png` are the sheet's editable source.
- **Cell size 142 × 145 px, grid 4 × 3** (`hframes = 4`, `vframes = 3`), sheet 568 × 435 px. Every pose is placed so its anchor (the bottom centre of the collision box) lands on the same cell point (70, 133), rounded to whole pixels, so the feet stay put when the frame changes (registration by construction; the rounding is at most 0.5 texture px = 0.25 game px). Every pose keeps at least 4 px of transparent padding to its cell edge, against filter bleed.
- **Frame order** (cell index = row × 4 + column, `anchors.json` order): 0 idle, 1 respawn, 2 run, 3 jump_crouch, 4 rising, 5 falling, 6 landing, 7 hose, 8 grab, 9 toss, 10 burned, 11 celebrate.
- **The toss uses cells 8 (grab), 9 (toss) and 1 (respawn, the ready stance).**
- **Node:** `Sprite2D` `Sprite` in a new scene `godot/features/player/joe_art.tscn` (root `Node2D` `Art`), `centered = false`, `position = (-70, -133)`. `player.gd` instantiates it where it built the art holder and sprite before, and keeps writing `Art.scale = (0.5 × facing, 0.5)` (not animated).

## The cycle spec (the wave)

- **Clip:** `wave` in `survivor_person.tscn`, one value track `Shoulder:rotation`.
- **24 frames at 30 fps:** length 0.8 s, `step = 1/30` s.
- **Keys:** frame 0 → 0.0 rad, frame 12 → 0.45 rad, frame 24 → 0.0 rad (positive turns the hand outward, away from the head). Interpolation `INTERPOLATION_CUBIC_ANGLE`, update mode continuous.
- **Loop mode:** `Animation.LOOP_LINEAR`.
- **Seam rule (continuous track):** the value at time 0 equals the value at the clip length (0.0 rad at 0.0 s and at 0.8 s), so the wrap has no jump. Frame 0's pose is the old drawing exactly.

## The phase table (the toss)

Frame rate **60 fps**, the physics tick rate, so one frame is one tick. **`Animation.step = 1/60` s.** Frame 0 is tick T, the touch: the end of the physics tick on which `session.gd` rescues the survivor.

| Phase | Frames | Begins on | Cell shown | What the player may do | What the game reads |
|---|---|---|---|---|---|
| Startup (grab) | 0–14 (15) | 0 | 8 grab | Move, jump and pause as normal; the picture holds whatever he does (the action is not cancelled by moving). R restarts. | Rescue already counted on frame 0 (`rescued_count`, bag); the survivor is held at the window. |
| Active (throw) | 15–29 (15) | 15 | 9 toss | Same. | `session.gd` launches the survivor from his raised hand on frame 15 (`fl.t == GRAB_TICKS`), on the physics tick. |
| Recovery (settle) | 30–45 (16) | 30 | 1 respawn | Same. | The survivor is still rising (apex on frame 45). On frame 46 the state machine hands back to locomotion (the action queue ends, unchanged). |

- **Keys built from the table:** `Sprite:frame` = 8 at 0/60 s, 9 at 15/60 s (0.25 s), 1 at 30/60 s (0.5 s). Clip length 46/60 s (0.7667 s), so the last displayed frame (45) is still inside the clip. `Animation.LOOP_NONE`. Update mode `UPDATE_DISCRETE`.
- **What changes on screen, and why:** the throw picture now starts on frame 15, the same tick as the launch (it was frame 16). Frames 30–45 show the ready stance instead of holding the throw. The `pose` strings and the action timings (`GRAB_TICKS`, `TOSS_UP_TICKS`) do not change.
- **The other poses** each get a one-key hold clip named after the pose (`idle`, `run`, `rising`, `falling`, `landing`, `hose`, `respawn`, `burned`, `celebrate`): one key on frame 0, length 1/60 s, `LOOP_LINEAR` so `current_animation` keeps naming it, `UPDATE_DISCRETE`, `step = 1/60`.
- **How the keys are made:** `godot/tools/bake_joe_clips.gd`, a headless tool script, builds the `AnimationLibrary` from this table and the cell order and saves it with `ResourceSaver.save()` to `godot/animations/joe.tres` (committed). Clips are never built at runtime.

## The state machine

The existing state machine is `player.gd` `_update_pose()` plus `show_pose()`; `session.gd` triggers three states. It keeps its states, order and timings. What changes is the output: each state plays a clip instead of setting a texture.

| State (`pose`) | Clip | Entered when (checked in this order each tick) |
|---|---|---|
| `grab`, then `toss` | `toss` (started once, on entering `grab`) | `session.gd` rescue calls `play_actions([["grab", 15], ["toss", 30]])`; the queue holds until it ends (frame 46) |
| `respawn` | `respawn` | `reset_at()` (start, R, death timeout) calls `play_actions([["respawn", 30]], true)`; ends after 30 ticks or when he moves |
| `rising` / `falling` | `rising` / `falling` | in the air; `rising` if he jumped this air, else `falling` |
| `landing` | `landing` | on the floor within 20 ticks (`LAND_TICKS`) of landing after more than 10 ticks in the air |
| `run` | `run` | on the floor, `abs(velocity.x) > 8` |
| `hose` | `hose` | on the floor, standing, `hosing` |
| `idle` | `idle` | otherwise |
| `burned` | `burned` | `session.gd` `resolve_contacts()`, death by fire, calls `show_pose("burned")` |
| `celebrate` | `celebrate` | `session.gd` `resolve_contacts()`, level complete, calls `show_pose("celebrate")` |

- **Restart rule:** `show_pose(state)` starts the state's clip with `play(clip)` and `seek(0, true)` when the clip differs from the assigned one, and also when the state changes to `grab` (so a toss always starts from frame 0; `play()` alone does not restart a clip that is already playing). `grab` → `toss` keeps the clip running.
- **The rescue bag** follows the cell on screen, not the `pose` string: `player.gd` gains `bag_pose()` (the pose name of the current cell), used by `player.gd` `_draw()` and by `session.gd` `_draw_flights()` in place of `player.pose`. Without this the bag would sit at the throw's position during the ready-stance frames.
- No `AnimationTree` is used, so there is no `advance_expression_base_node` or `advance_mode` to set.

## The two clocks

- **Joe's `AnimationPlayer`:** `callback_mode_process = ANIMATION_CALLBACK_MODE_PROCESS_MANUAL`. `player.gd` advances it by the physics `delta` at the end of `_physics_process`, after `_update_pose()`, except on the tick a clip was (re)started (that tick shows frame 0). It therefore advances on the **physics tick**, only while `player.enabled` is true: pause, dying and complete freeze it, exactly as they freeze the action queue today.
- **The survivor's `AnimationPlayer`:** `ANIMATION_CALLBACK_MODE_PROCESS_IDLE`, the **process tick**. It keeps waving behind the pause card (the game's pause is not a tree pause). The game reads nothing from it.
- No `AnimatedSprite2D` is involved.
- **Keyed gameplay fact:** none of the game's logic reads a clip. The fact the toss's active window depends on, the survivor's launch, is decided by `session.gd` on the **physics tick**. Joe's clip shows the throw cell on the same tick, so the largest disagreement is **0 s by construction** (it was one tick, 1/60 s ≈ 0.017 s, before this change). A test measures it. Method tracks are not used.

## Boundaries

Unchanged unless named above: collision, movement, input, the state machine's states, order and timings (`GRAB_TICKS`, `TOSS_UP_TICKS`, `LAND_TICKS`, the 30-tick respawn), the survivor flights' timing, every existing test and its expected values, my Assignment 5 shaders in `godot/shaders/` (no agent edits them), my Assignment 6 effects, the dog, the fires, the HUD and the level. Presentation code may read game state; it never writes it.

**Named changes:** Joe's art becomes `joe_art.tscn` (one sheet, one `AnimationPlayer`); `show_pose()` plays clips instead of swapping textures; the toss picture follows the phase table; the bag follows the visible cell (`bag_pose()`, one call site in `session.gd`); the person survivor is drawn by `survivor_person.tscn` instead of `session.gd` `_draw()`, which keeps drawing the window, its glow and the HELP! bubble.

## The evidence split

| Rule | Checked by | How |
|---|---|---|
| Every track resolves to a real node and property | read-back | `track_problems()` over both `AnimationPlayer`s, each in its real scene |
| Toss keys at frames 0, 15, 30; length 46; cells 8, 9, 1 | read-back | key times within half a frame period (1/120 s); values equal |
| Wave keys at frames 0, 12, 24; values 0.0, 0.45, 0.0 | read-back | same tolerance (1/60 s) |
| `step` = 1/60 (toss and holds), 1/30 (wave) | read-back | `is_equal_approx` |
| Loop modes: toss `LOOP_NONE`, holds and wave `LOOP_LINEAR` | read-back | named constants |
| Frame tracks discrete; every frame key inside the sheet | read-back | `UPDATE_DISCRETE`; key value < `hframes × vframes` (12) |
| Wave seam: value at 0 = value at length | read-back | equal within 1e-6 |
| Sheet grid: 568 × 435, 4 × 3, Sprite at (−70, −133) | read-back | texture size and node properties |
| Today's states, order and timings unchanged | pins | Step 2 pins, before and after |
| Every clip the state machine requests exists | structure test | every state name maps to a clip in the library |
| States play their clips in real play | state test | real keys through `Input.parse_input_event`; reads `current_animation` |
| One authority over Joe's sprite | state test | the sprite's texture never changes from the sheet; `frame` only ever equals the current clip's key |
| Throw cell on the launch tick, grab cell the tick before; 0-tick disagreement | edge test | per-tick log around frames 14–16, 29–31, 45–47 |
| Interrupts (R, move, jump, Esc) before, on and after each boundary do what this brief says | edge test | real keys at frame boundary − 1, = and + 1 |
| The wave reads, wraps with no hitch, and the person looks as before at rest | my eyes | running game, five wraps at normal speed |
| The toss's three phases read as distinct; feet do not drift between cells | frame strip + my eyes | Movie Maker strip at the phase boundaries, then play |
| Both clips over the darkest and lightest level art they appear on | my eyes | the person's window (dark interior), Joe at the window and on the lit roof |

**Interrupts the edge test asserts:** R on any frame cuts the toss: the next tick plays `respawn` (restart). Holding a move key or pressing Space does not cut it: the clip keeps the table's cells while he moves or jumps. Esc freezes the clip on the frame it is on; Esc again resumes from that frame.

## The frame strip

- **Preview:** `godot/previews/toss_preview.tscn`, the real game scene with Joe standing next to the person's window with the fire out, over the real level art at x ≈ 1300 (B1's roof, the window, the skyline). It walks him into the survivor with a real key, so the rescue happens in the game loop. It logs one line per captured frame (frame number, tick since the touch, clip, clip time, `Sprite.frame`) to `logs/`.
- **Capture** (I run it; it needs a window):
  `godot --path godot res://previews/toss_preview.tscn --write-movie "$PWD/captures/toss/r0/frame.png" --fixed-fps 30 --quit-after 90`
- **At 30 fps each strip frame covers two ticks.** The per-frame log names the tick each image shows. Frames to read: the trigger (frame 0 of the action, grab), the last startup frame (tick 14), the first active frame (tick 15 or 16, throw), the last active frame (tick 28 or 29), the first recovery frame (tick 30, ready stance), the last recovery frame (tick 44 or 45) and the hand-back (tick 46, locomotion). The boundary at tick 15 falls between two strip frames; the log says which side each is on.

## Predicted failures

1. **A frame track left on continuous updates.** Between cell 9 (toss) and cell 1 (respawn) the sprite would sweep through cells 8, 7, 6 … 2 (grab, hose, landing, falling …), a flicker of other poses. Caught by the read-back's `UPDATE_DISCRETE` check, and visible in the strip.
2. **A Godot 3 name in the bake script** (`loop = true` instead of `loop_mode`). It loads without complaint and the hold clips end after one frame, so `current_animation` goes empty. Caught by the read-back's loop-mode check.
3. **An off-by-one against the launch.** The session runs after the player in each tick, so a clip started on the session's call and advanced on that same tick would show the throw one tick early. Caught by the edge test's per-tick log (grab on tick 14, throw on tick 15, the launch on tick 15).
4. **A track path that resolves to nothing** (for example `Art/Sprite:frame` when the player's root node is already `Art`). The clip "plays" and nothing moves. Caught by `track_problems()`, and by mutation 1.
5. **A second writer left behind:** `show_pose()` still setting `sprite.texture`, or a test helper setting `frame`. Caught by the state test (texture never changes; `frame` always equals the clip's key).
6. **The clip keeps running while paused** if it were left on the physics or idle callback. Caught by the edge test's Esc interrupt.
7. **The rebuilt person doesn't match the old drawing** (arm drawn over the head, pivot in the wrong place). Caught by my eyes in the running game.

## Short answers

1. **Routes, and what each read-back sees.** The toss is a `Sprite2D` frame track: its read-back sees each key's time and cell index, the update mode and the sheet's grid. An `AnimatedSprite2D` read-back would see only the `SpriteFrames` (frame count, speed, loop), never per-key times. The wave is a cutout rig keyed as resource text: its read-back sees that `Shoulder:rotation` resolves to a `Node2D` property, plus its key times, values and seam. An imported rig's read-back would see bone subnames instead and must run from an empty import cache.
2. **A frame track on continuous updates** interpolates the integer between keys, so from 9 to 1 the sprite shows every cell in between, one after another. `frame` is an integer, so each in-between value lands on a real cell, which is why nothing complains.
3. **`Animation.step` is 1/60 s for the toss** (1/30 s for the wave). Step governs where the editor snaps keys. The baked keys sit at exact frame times, but left at the default 1/30, any key nudged in the editor snaps to an even tick: frame 15 would move to 14 or 16 and the throw would show a tick early or late against the launch.
4. **One authority.** Joe's `Sprite.frame`: his `AnimationPlayer` only, driven only by `player.gd`'s state machine. What else could write to it: the old texture swap in `show_pose()` (removed), a test or preview that sets the sprite directly, and `hose_glow.gd`, which writes the sprite's `material` (a different property, not animated). The person's `Shoulder.rotation`: the rig's `AnimationPlayer` only; `session.gd` writes only the rig root's `visible`.
5. **Ticks.** The toss advances on the physics tick, from `player.gd`, only while he is enabled; the wave advances on the process tick. Gameplay reads the launch on the physics tick. They agree, so the largest disagreement is 0 s. Had the toss run on the process tick at 30 fps, one drawn frame covers two ticks, so it could lag the launch by up to 1/60 s.
6. **Seam rule for the wave** (a continuous track): `Shoulder:rotation` is 0.0 rad at 0 s and at 0.8 s. A duplicated frame at the wrap would look like a hitch: the arm would hang for one extra frame at the bottom of every wave, once every 0.8 s.
7. **Imported rig:** not used. The wave is keyed in the scene, so its loop mode lives in the `.tscn`. The read-back still runs after deleting `godot/.godot` and reimporting (mutation 4), to prove nothing depends on the import cache.

---

## Revisions

*(none yet)*
