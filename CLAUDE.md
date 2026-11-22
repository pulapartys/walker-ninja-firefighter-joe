# CLAUDE.md

There is no AGENTS.md in this repository.

## Project context

- **Engine:** Godot 4.7.2 stable. Every log in `logs/` starts `Godot Engine v4.7.2.stable.official.ed1daf0bf` (e.g. `logs/test_game_60fps.log` line 1); `godot/project.godot` declares `config/features=PackedStringArray("4.7", "GL Compatibility")`.
- **Renderer:** GL Compatibility (`godot/project.godot` `[rendering]` `renderer/rendering_method="gl_compatibility"`, `.mobile` the same). No `default_texture_filter` key, so canvas textures filter linearly and the sheet needs padded cells (CHANGE-BRIEF.md "What limits the choices").
- **Viewport:** 640 × 360, window 1280 × 720, stretch `canvas_items` (`godot/project.godot` `[display]`). No physics key, so physics runs at the default 60 ticks per second (`session.gd:25`: "4 s @ 60 Hz").
- **Scene both clips play in:** `res://game/main.tscn` (`project.godot` `run/main_scene`): one `Node2D` `WalkerJumpman` with `godot/game/session.gd`. Its `_ready()` builds everything in code: solids, hazard and survivor areas, `Player.new()`, camera, background and HUD layers (`session.gd:54–93`). Its `_draw()` paints buildings, fires, survivors, flights and labels on `WalkerJumpman` itself (`session.gd:328–479`), so every child node draws over that. The A6 drivers place their nodes just before the player with `move_child(node, player.get_index())` (`jump_puff_driver.gd:27`, `hose_steam_driver.gd:25`).
- **Clip 1, the person survivor's wave** (cycle; CHANGE-BRIEF.md "Clip 1", "The cycle spec"). Route: cutout rig keyed as resource text. Node: new scene `godot/features/survivor/survivor_person.tscn`, the person rebuilt from `Polygon2D` parts, the raised arm and hand under a `Node2D` pivot `Shoulder`, and an `AnimationPlayer` (`autoplay = "wave"`, idle-process callback). Clip `wave` keys `Shoulder:rotation` 0 / 0.45 / 0 rad at frames 0 / 12 / 24 of 30 fps: cubic angle, continuous, `LOOP_LINEAR`, `step` 1/30. Today the person at (1335, 240) (`godot/levels/first_steps.json` `survivors`) is drawn in `session.gd` `_draw()` (`:425–446`, raised arm `:437–440`). The window and its glow (`:405–407`) and the HELP! bubble (`:447–454`) stay drawn there.
- **Clip 2, Joe's survivor toss** (committing action; "Clip 2", "The sheet", "The phase table"). Route: `Sprite2D` frame track. Node: new scene `godot/features/player/joe_art.tscn`: root `Node2D` `Art`, `Sprite2D` `Sprite` (`hframes` 4, `vframes` 3, `centered = false`, `position (-70, -133)`) and one `AnimationPlayer` (manual callback) with the library `godot/animations/joe.tres`, baked by `godot/tools/bake_joe_clips.gd`. Clip `toss` keys `Sprite:frame` 8 / 9 / 1 at frames 0 / 15 / 30 of 60 fps: length 46/60 s, `LOOP_NONE`, `UPDATE_DISCRETE`, `step` 1/60. Every other pose has a one-key hold clip. The sheet `godot/art/character/joe_sheet.png` is packed by `tools/make_joe_sheet.py` from the 12 PNGs and `anchors.json` in `godot/art/character/`.
- **No A7 file exists yet** (listed 2026-11-22): no `godot/animations/`, `godot/features/survivor/`, `godot/tools/`, `joe_art.tscn`, `joe_sheet.png`, `tools/make_joe_sheet.py`, `godot/art/character/ATTRIBUTION.md` or `godot/previews/toss_preview.tscn`. Their names come from CHANGE-BRIEF.md only.
- **State machine owner: `godot/features/player/player.gd`.** `_update_pose()` (`:94–124`, the last call in `_physics_process`, `:175`) picks one state per tick in this order: action queue, air (`rising` if he jumped, else `falling`), `landing` (`LAND_TICKS` 20), `run` (`abs(velocity.x) > 8`), `hose`, `idle`. `show_pose()` (`:80–86`) sets `pose` and today writes `sprite.texture`, `sprite.position` and `art.scale`. `play_actions()` (`:89–92`) loads the timed queue. Callers outside it: the rescue's `play_actions([["grab", GRAB_TICKS], ["toss", TOSS_UP_TICKS]])` (`session.gd:267`; 15 and 30 at `:32–33`), `show_pose("burned")` and `show_pose("celebrate")` (`session.gd:201`, `:209`). `reset_at()` queues `[["respawn", 30]]`, which moving cancels (`player.gd:107`, `:143`). `_physics_process` returns at once while `enabled` is false (`:147`).
- **Tick order and the launch:** `session.gd` sets `process_physics_priority = 10` (`:55`), so the player's tick runs before the session's. A flight launches when `fl.t == GRAB_TICKS` (`:291`), in a loop outside the PLAYING branch (`:289–297`), so flights keep counting while paused.
- **Today's art:** `player.gd` `_ready()` (`:62–72`) loads one texture per `anchors.json` state and builds `art` (`Node2D`, `show_behind_parent = true` so the code-drawn bag stays on top) holding `sprite` (`Sprite2D`). The bag sits at `BAG[pose]` in `player.gd` `_draw()` (`:186`) and `session.gd` `_draw_flights()` (`:490`). No state ever shows `jump_crouch` (cell 3).
- **Code that reaches into Joe's art:** `hose_glow.gd:21` writes `get_parent().sprite.material` in its `_ready()` (added at `player.gd:73`, after the sprite). `test_hose_glow.gd` reads `player.sprite.material` and `player.art.material` (`:31–33`, `:161–164`). `capture_game.gd` and `capture_glow.gd` read `player.pose`. So `player.sprite` and `player.art` must name the new `Sprite` and `Art`, and both must exist before `HoseGlow` is added.
- **Pause:** Esc/P call `session.gd` `set_paused()` (`:177–185`), which changes only `state` and `player.enabled`. No game script sets `get_tree().paused` or `process_mode`; only a sampler in `test_hose_steam_state.gd:153` sets `PROCESS_MODE_ALWAYS`.
- **Tests** (`godot/tests/test_*.gd`, `extends SceneTree`): `_initialize()` defers to `run()`, `steps(n)` awaits `physics_frame` then `process_frame`, `check()` prints one JSON line, and the run ends with `quit(1 if failures else 0)` (`test_game.gd:8–20`, `:241`). Real keys go in through `Input.parse_input_event` (`test_keyboard.gd:20`, `test_hose_glow.gd:52`, `test_jump_puff_state.gd:64`, `test_hose_steam_state.gd:57`); `test_game.gd` uses the player's `test_*` hooks (`player.gd:22–26`). No `test_*.gd` reads `pose`, the toss timings or a sprite frame.
- **Headless:** a dummy renderer, so node state is observable and the look is not (`a6/evidence/probes/headless_probe_60fps.log`: empty `get_video_adapter_name()`). `--fixed-fps 30` runs two physics ticks per frame (a5/TEST-REPORT.md). Frame strips come from a windowed Movie Maker run that the human starts (CHANGE-BRIEF.md "The frame strip").
- **Runner:** `scripts/run-test.sh <test-file.gd> <fps|realtime> [timeout-seconds]` runs `godot --headless [--fixed-fps <fps>] --path godot --script res://tests/<file>` under `timeout` (default 120 s) and tees to `logs/<name>_<fps>fps.log` or `logs/<name>_realtime.log`. It exits with Godot's status (124 = hung), or 1 if the log has `SHADER ERROR`, `SCRIPT ERROR` or `Failed loading resource` (`scripts/run-test.sh:5–14`). `realtime` drops `--fixed-fps`. `godot` comes from PATH; no other arguments are forwarded.
- **Exact commands** (repository root; results from `a7/evidence/baseline_run-all-tests_82fdeb2.txt`, "ALL AS EXPECTED"):

  ```
  scripts/run-test.sh test_game.gd 60               # 41/41
  scripts/run-test.sh test_keyboard.gd 60           # 14/14 (no summary line: count the PASS lines)
  scripts/run-test.sh test_audio.gd 60              # 12/14, exit 1: expected (see below)
  scripts/run-test.sh test_audio.gd realtime 300    # 14/14; needs 300 s (waits on the 25.6 s music loop)
  scripts/run-test.sh check_props.gd 60             # RESULT: PASS
  scripts/run-test.sh test_hose_glow.gd 30          # 15/15; also run at 60 and 144
  scripts/run-test.sh test_materials.gd 60          # 35/35
  scripts/run-test.sh test_jump_puff_config.gd 60   # 94/94
  scripts/run-test.sh test_jump_puff_state.gd 60    # 30/30
  scripts/run-test.sh test_hose_steam_config.gd 60  # 89/89
  scripts/run-test.sh test_hose_steam_state.gd 60   # 18/18
  scripts/run-test.sh cost_effects.gd 60 300        # COST EFFECTS line, exit 0
  ```

  `scripts/run-all-tests.sh` runs exactly these lines (`:24–37`) and prints one verdict per run.
  - `test_audio` at a pinned 60 fails `music-behaviour` and `music-loops`, which read the real-time audio clock (a5/TEST-REPORT.md Baseline). This is pre-existing: leave it.
  - New A7 tests run as `scripts/run-test.sh <file>.gd 60` (one frame = one physics tick). Use `realtime` only for a test that waits on audio.

## Current change

@CHANGE-BRIEF.md

## Ownership

- Files in `godot/shaders/` are hand-written by the human and are never edited by an agent. That covers `hose_glow.gdshader`, `hint_experiment.gdshader`, `hydrant_surface.gdshader`, `standard_generated.gdshader` and `particles_generated.gdshader`. An agent may read them, write drivers, tests and scenes that use them, and report what it observes; it does not create, edit, rename or delete anything under `godot/shaders/`.
- Clips live as resources: in `godot/animations/` (Joe's `AnimationLibrary` `joe.tres`, saved once by the headless tool `godot/tools/bake_joe_clips.gd` and committed) or in the scene that owns them (`wave` in `survivor_person.tscn`). No clip, track or key is ever built, added or changed in code at runtime. Game, driver, test and preview scripts only play and read clips.
- The v1 text of CHANGE-BRIEF.md is the human's and is never rewritten; new findings go under Revisions, with a date.

## One authority

Each animated node has exactly one writer of what is animated on it. Never add a second writer to a node that already has one: no other script, test, preview or tool sets these properties or calls `play()`, `stop()`, `seek()` or `advance()` on these players.

- **Joe's `Sprite` (`joe_art.tscn`), `frame`:** written only by Joe's `AnimationPlayer` in `joe_art.tscn`. Only `player.gd`'s state machine drives that player: `show_pose()` (`play()` and `seek(0, true)`) and the end of `_physics_process` (`advance(delta)`). `session.gd` asks for states only through `player.play_actions()` and `player.show_pose()`. `show_pose()` no longer writes the sprite's texture; the sheet and `position (-70, -133)` come from the scene and never change at runtime. The one other writer on this node stays as it is and is not animated: `hose_glow.gd` sets `Sprite.material` once and its `glow` parameter each frame.
- **Joe's `Art` (root of `joe_art.tscn`):** not animated. Only `player.gd` writes it: `scale = (0.5 × facing, 0.5)`.
- **The person's `Shoulder` (`survivor_person.tscn`), `rotation`:** written only by the rig's own `AnimationPlayer`, started by its `autoplay = "wave"`. No script calls `play()` on it or writes `Shoulder`.
- **The rig's root:** not animated. `session.gd` instances it in `_ready()` and then writes only `visible` (false on rescue, true in `restart_attempt()`).
- Tests and previews press real keys and read (`current_animation`, `current_animation_position`, `Sprite.frame`, `Shoulder.rotation`); they never set a frame or a rotation and never drive a player. No game logic reads a clip, and there are no method tracks (CHANGE-BRIEF.md "The two clocks").

## Godot 4 names

Use Godot 4 names for the pinned 4.7.2, never Godot 3 names. **No animation name below has been probed on 4.7.2 in this repository** (`a6/evidence/probes/names_probe.gd` covers particles only). They are the Godot 4.2+ names the brief also uses; where I am unsure, it says so. Probe a name (`ClassDB.class_has_method()`, `ClassDB.class_get_property_list()`, `ClassDB.class_has_integer_constant()`) before relying on it.

- **Never these Godot 3 names:** a boolean `loop` on `Animation`, `playback_speed`, `playback_process_mode` / `ANIMATION_PROCESS_*`, `playback_active`, `UPDATE_TRIGGER`, `AnimatedSprite`, `Sprite`, `instance()`, `yield`, `pause_mode`.
- **Classes:** `AnimationPlayer` (extends `AnimationMixer` since 4.2), `Animation`, `AnimationLibrary`, `Sprite2D`, `Polygon2D`, `Node2D`. Not used here: `AnimatedSprite2D` / `SpriteFrames`, `AnimationTree`, `Skeleton2D`.
- **Loop:** `Animation.loop_mode` = `Animation.LOOP_NONE` / `Animation.LOOP_LINEAR` (prediction 2: a boolean `loop` loads silently and the holds stop after one frame).
- **Speed:** `speed_scale`. This change sets no speed.
- **Clock:** `callback_mode_process` with `AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL` (Joe) or `_PROCESS_IDLE` (the wave, the default). Unsure whether 4.7.2 GDScript also accepts these constants through `AnimationPlayer.`; write `AnimationMixer.` or probe.
- **Tracks:** `add_track(Animation.TYPE_VALUE)`, `track_set_path()`, `track_insert_key(track, time, value)`, `value_track_set_update_mode(track, Animation.UPDATE_DISCRETE)` (`UPDATE_CONTINUOUS` for the wave), `track_set_interpolation_type(track, Animation.INTERPOLATION_CUBIC_ANGLE)`, `Animation.step`, `Animation.length`. Paths resolve from the player's `root_node` (default `..`, the player's parent): `Sprite:frame`, not `Art/Sprite:frame`, when the player is a child of `Art` (prediction 4).
- **Libraries and saving:** `AnimationLibrary.add_animation(name, anim)`, then `add_animation_library("", lib)` on the player (Godot 3 had `add_animation()` on the player). `ResourceSaver.save(resource, path)`: resource first (Godot 3 put the path first).
- **Playing and reading:** `play(name)`, `seek(seconds, update)`, `advance(delta)`, `autoplay`, `current_animation`, `assigned_animation`, `current_animation_position`, `get_animation(name)`, `has_animation(name)`. Unsure on 4.7.2: whether `play()` plus `seek(0, true)` under the manual callback sets `Sprite.frame` on that same tick without an `advance()`. The edge test's per-tick log settles it.
- **Sprite:** `Sprite2D.hframes`, `vframes`, `frame`, `frame_coords`, `centered`, `texture`.
- **GDScript 4 and scenes:** `PackedScene.instantiate()`, `await`, `signal.connect(callable)`, `process_mode`, `Engine.physics_ticks_per_second` (Godot 3: `iterations_per_second`). Scene files use `format=3` (`godot/game/main.tscn`). Unsure: the exact 4.7.2 text form of an `Animation` / `AnimationLibrary` sub-resource (`tracks/0/keys`, `libraries = {…}`). Copy it from a file Godot itself saved rather than guess.

## Out of scope

The clips are presentation: they read game state and never write it.

- Game logic stays as it is: `session.gd`'s state machine, rescue, counts and bag contents, the flights and their timing (`GRAB_TICKS`, `TOSS_UP_TICKS`, `TOSS_DOWN_TICKS`, `TOSS_HEIGHT`), death, timer, audio and input. Esc stays a game pause, not a tree pause.
- The player keeps its states, their order and their timings: the `pose` strings, the action queue, `LAND_TICKS`, the 30-tick respawn and its cancel-on-move. Collision, movement, jumping, the input map, `tuning.gd` and `first_steps.json` do not change. What changes is only what `show_pose()` outputs, plus `bag_pose()` and its one call site in `session.gd` (CHANGE-BRIEF.md "Named changes").
- The 12 pose PNGs and `anchors.json` are not edited, rescaled or repainted; the sheet is a new file built from them.
- Left alone: the shaders (see Ownership), the A5 `hose_glow.gd` driver and materials, the A6 effects, drivers and previews, the 3D props, the dog, the fires, the window, its glow, the HELP! bubble, the HUD, the background and the level.
- Existing tests and their expected values, including the pinned `test_audio` failures, and `scripts/run-test.sh` stay as they are.
- `project.godot` stays as it is: no renderer switch and no texture-filter key (the sheet's padding handles bleed).
- Not in this change: a run cycle (the human deferred it), `AnimationTree`, `AnimatedSprite2D`, an imported or skeleton rig, method tracks, and any clip built at runtime.

## Unconfirmed

- The animation names in "Godot 4 names" have not been probed on 4.7.2 here, and no run in this repository has yet shown an `AnimationPlayer` advancing headless.
- `track_problems()` (CHANGE-BRIEF.md "The evidence split") is defined nowhere in the repository and is not a Godot method I know of. It reads as a test helper still to be written.
- The brief names no files for the A7 tests or the Step 2 pins, and no existing test pins today's pose order or toss timings. It also doesn't say whether the A7 tests get lines in `scripts/run-all-tests.sh`.
- Where the rig sits among `WalkerJumpman`'s children is not given. The old person was drawn in `session.gd` `_draw()`, under every child including Joe, so a rig added after the player would cover him. The A6 `move_child(..., player.get_index())` pattern would keep it behind him.
- Placing the rig: the brief says `session.gd` writes only the root's `visible`, yet the rig must be put at the survivor's (x, y) once, when it is instanced. The brief doesn't say how.
- The `Shoulder` pivot point is not given. The old raised arm is a 3 × 11 rect from (x + 3.2, y − 27), with the hand at (x + 4.7, y − 27.5) (`session.gd:437–440`). With the hand above the pivot, a positive (clockwise in Godot 2D) rotation moves it outward, as the brief says. I worked that out; I have not run it.
- The brief doesn't say whether `show_behind_parent = true` (the bag on top, `player.gd:67`) moves into `joe_art.tscn` or stays in `player.gd`. Either way it must still hold.
