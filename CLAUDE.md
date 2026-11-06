# CLAUDE.md

There is no AGENTS.md in this repository.

## Project context

- **Engine:** Godot 4.7.2 stable. `godot/project.godot` declares `config/features=PackedStringArray("4.7", "GL Compatibility")`; every log in `logs/` starts `Godot Engine v4.7.2.stable.official.ed1daf0bf`.
- **Renderer:** GL Compatibility. `godot/project.godot` `[rendering]` sets `renderer/rendering_method="gl_compatibility"` and `renderer/rendering_method.mobile="gl_compatibility"`; no `hdr_2d` key. The brief rules out particle trails and 2D particle collision under it (CHANGE-BRIEF.md "What limits the choices").
- **Viewport:** 640 × 360, window 1280 × 720, stretch `canvas_items` (`godot/project.godot` `[display]`).
- **Effect node types** (CHANGE-BRIEF.md A3, B3; neither scene exists yet):
  - Jump puff: `godot/effects/jump_puff.tscn`, `Node2D` root `JumpPuff` with three `CPUParticles2D` children `Flash`, `Puff`, `Specks`, all `one_shot`.
  - Hose steam: `godot/effects/hose_steam.tscn`, `Node2D` root `HoseSteam` with two `GPUParticles2D` children `Haze` (drawn first) and `Steam`, each with a `ParticleProcessMaterial`.
  - Both draw a `GradientTexture2D` defined inside the scene; no image file, no draw material (mix blend).
- **Jump puff event, signal `jumped`:** declared at the top of `godot/features/player/player.gd`, emitted in its `_physics_process` after `velocity.y = tuning.jump_velocity` and before `move_and_slide()`. `_physics_process` returns at once while `enabled` is false. `godot/game/session.gd` sets `player.enabled = false` in `set_paused()`, in `resolve_contacts()` (DYING, COMPLETE) and in the `menu` handler, so `jumped` fires only in PLAYING. The player's origin is his feet (`player.gd`: `BOX` comment; collider at `(0, -BOX.y / 2)`). `session.gd` `_ready()` already connects `player.jumped` to `play_sfx("jump")`.
- **Hose steam condition, `player.hosing`:** `var hosing` in `player.gd`. `session.gd` `_physics_process` writes `player.hosing = water_ticks > 0` inside the PLAYING branch only, so the value holds through PAUSED and DYING. A W press in range sets `extinguish_ticks = EXTINGUISH_TICKS` (240) and `water_ticks = EXTINGUISH_TICKS + 60`. `restart_attempt()` runs from `start_session()`, from the R handler in `_unhandled_input` and from the DYING timeout. It zeroes both counters and calls `player.reset_at()`, which sets `hosing = false` at once.
- **Hose steam value, `fire_height()`** (`session.gd`): full height (`level.blocking_fire[3]`) until hosing starts, then `full * extinguish_ticks / EXTINGUISH_TICKS`, and 0 once `fire_active` is false. `godot/levels/first_steps.json` has `"blocking_fire": [1250, 206, 56, 34]`: base at y 240, centre at x 1278, full height 34.
- **Pause:** Esc/P call `session.gd` `set_paused()`, which changes only `state` and `player.enabled`. No `.gd` file under `godot/` sets `get_tree().paused` or `process_mode`. `_on_focus_lost()` also pauses, unless `test_mode` is set.
- **Scene the effects appear in:** `res://game/main.tscn` (`godot/project.godot` `run/main_scene`). It holds one `Node2D` `WalkerJumpman` with `godot/game/session.gd`, whose `_ready()` builds everything in code: solids, hazard areas, `Player.new()`, `Camera2D`, a background `CanvasLayer` (layer −1) and a HUD `CanvasLayer`. `session.gd` `_draw()` draws the buildings, fires and water stream on `WalkerJumpman` itself. The puff's root becomes a child of `WalkerJumpman`, not of the player (CHANGE-BRIEF.md A-R6). The steam root's position is given in level coordinates (B-R4).
- **Previews (to be made):** `godot/previews/jump_puff_preview.tscn` and `godot/previews/hose_steam_preview.tscn`, both over the real B1 art and captured as 30 fps strips (CHANGE-BRIEF.md A5, B5).
- **A5 driver pattern:** `godot/features/player/hose_glow.gd` is a `Node` that `player.gd` `_ready()` adds as a child. It reads `hosing` in `_process` and writes one shader parameter. `godot/tests/test_hose_glow.gd` tests it with real key events.
- **Tests (`godot/tests/`, all `extends SceneTree`):** `_initialize()` defers to `run()`, and `steps(n)` awaits `physics_frame` plus `process_frame`.
  - `test_game.gd` (41 checks) drives the player through its hooks `test_control`, `test_axis`, `test_jump_pressed`, `test_jump_held` and `test_water_pressed`.
  - `test_keyboard.gd` (14) and `test_hose_glow.gd` (15) send `InputEventKey`s via `Input.parse_input_event`.
  - Also `test_audio.gd` (14), `test_materials.gd` (35) and `check_props.gd` (`RESULT: PASS`). Each one calls `quit(1)` on any failure.
  - Other scripts in the folder: `route_driver.gd` (scripted route), `normal_map_check.gd` (helper for `test_materials.gd`), `calibrate_normal_maps.gd`, `write_grey_strip.gd`, the windowed `capture_*.gd`, `run_check_props.sh` (A3 runner).
- **Runner:** `scripts/run-test.sh <test-file.gd> <fps|realtime> [timeout-seconds]` runs `godot --headless [--fixed-fps <fps>] --path godot --script res://tests/<file>` under `timeout` (default 120 s). It tees to `logs/<name>_<fps>fps.log` or `logs/<name>_realtime.log`. The exit status is Godot's (124 = hung), or 1 if the log has a `SHADER ERROR` / `SCRIPT ERROR` line. `realtime` drops `--fixed-fps`. It calls `godot` from PATH (on this Mac a local shim; commit `78d926e`) and forwards no other arguments.
- **Exact commands** (from the repository root; results as in `logs/`):

  ```
  scripts/run-test.sh test_game.gd 60            # 41/41
  scripts/run-test.sh test_keyboard.gd 60        # 14/14
  scripts/run-test.sh test_audio.gd 60           # 12/14 (see below)
  scripts/run-test.sh test_audio.gd realtime     # 14/14
  scripts/run-test.sh check_props.gd 60          # RESULT: PASS
  scripts/run-test.sh test_hose_glow.gd 30       # 15/15; same at 60 and 144
  scripts/run-test.sh test_materials.gd 60       # 35/35
  ```

  - `test_audio` fails `music-behaviour` and `music-loops` only when pinned. Both read the music's playback position, which runs on the real-time audio clock (a5/TEST-REPORT.md Baseline). This is pre-existing: leave it, don't "fix" it.
  - New A6 tests run as `scripts/run-test.sh <file>.gd <fps>`. Use `realtime` only for a test that waits on audio.
- **What headless can see:** headless Godot draws nothing, so no pixel can be read (header comments in `test_hose_glow.gd` and `test_materials.gd`). Node and material properties can be read back. Every claim about the look is an eye or frame-strip check (CHANGE-BRIEF.md "Evidence split"): the puff's shape, the steam against the sky, no pop at the screen edge, the frozen look under a tree pause.

## Current change

@CHANGE-BRIEF.md

## Ownership

- Files in `godot/shaders/` are hand-written by the human and are never edited by an agent. That covers `hose_glow.gdshader`, `hint_experiment.gdshader`, `hydrant_surface.gdshader` and `standard_generated.gdshader`. An agent may read them, write drivers, tests and scenes that use them, and report what it observes; it does not create, edit, rename or delete anything under `godot/shaders/`.
- Effect settings live in scene files in `godot/effects/` (`jump_puff.tscn`, `hose_steam.tscn`), not in code. Every value in CHANGE-BRIEF.md A3 and B3 goes in the `.tscn`: node properties, the `ParticleProcessMaterial`, gradients, curves and the `GradientTexture2D`. No driver script sets them.
- At runtime a driver writes only what the brief gives it. For the puff, that is instancing a `JumpPuff` and placing its root. For the steam, it is `emitting`, `amount_ratio` and the root position (B-R1 to B-R4); `amount` never changes. Only preview scenes set `use_fixed_seed` / `seed`, and only on their own instances.
- CHANGE-BRIEF.md sections P, C and Q are the human's own words; an agent does not edit them.

## Godot 4 names

Use the Godot 4 class and property names of the pinned 4.7.2, never Godot 3 names.

- **Classes:** `GPUParticles2D` (Godot 3: `Particles2D`), `ParticleProcessMaterial` (Godot 3: `ParticlesMaterial`), `CPUParticles2D`, `GradientTexture2D`, `Gradient`. A 1D gradient texture is `GradientTexture1D` (Godot 3: `GradientTexture`).
- **Properties:** copy the spelling from CHANGE-BRIEF.md A3 / B3. The brief says every name there was probed on 4.7.2; this session did not re-probe them (see Unconfirmed).
  - Ranges are `_min` / `_max` pairs. Never write a bare `initial_velocity`, `scale_amount`, `angle`, `angular_velocity`, `damping` or `hue_variation`: Godot ignores an unknown name (prediction P1).
  - CPU and GPU spellings differ: `CPUParticles2D` has `scale_amount_min` / `scale_amount_curve`; `ParticleProcessMaterial` has `scale_min` / `scale_curve`.
  - The 2D flag is `particle_flag_disable_z` (Godot 3: `flag_disable_z`).
- **Enum values, as the brief gives them:** `CPUParticles2D` `emission_shape` point 0, sphere 1; `ParticleProcessMaterial` box 3.
- **GPU-only features:** `CPUParticles2D` has no `amount_ratio`, turbulence or `visibility_rect` (CHANGE-BRIEF.md A3, B3). They exist only on `GPUParticles2D` and its `ParticleProcessMaterial`.
- **Not verified on 4.7.2, so check before relying on them:**
  - In the Godot 4 class reference, `CPUParticles2D.color_ramp` is a `Gradient` and `scale_amount_curve` is a `Curve`. `ParticleProcessMaterial.color_ramp` and `scale_curve` take textures (`GradientTexture1D`, `CurveTexture`).
  - The `finished` signal and `restart()` on both particle nodes.
- **GDScript 4:** `PackedScene.instantiate()` (as in `check_props.gd`), `await` (not `yield`), `signal.connect(callable)` (as in `session.gd`), and `process_mode` (Godot 3: `pause_mode`) for tree-pause behaviour. Scene files use `format=3` (as in `godot/game/main.tscn`).

## Out of scope

Effect code is presentation: it reads `player.jumped`, `player.hosing`, `session.fire_height()` and `session.level`, and writes none of them.

- `godot/game/session.gd` game logic stays as it is: the state machine, the hose counters, `EXTINGUISH_TICKS`, the 60-tick water linger, `FIRE_DEATH_HOLD`, death, rescue, the timer, pause, audio and input. Esc stays a game pause, not a tree pause.
- No change to collision, movement, jump timing, poses, the input map or tuning (the `player.gd` physics, `tuning.gd`, `first_steps.json`).
- No edits to the existing tests or their expectations, including the pinned `test_audio` failures, and none to `scripts/run-test.sh`.
- The A5 work stays as it is: the shaders (see Ownership), the `hose_glow.gd` driver and its hook, the materials, and the 3D scenes and props.
- The HUD, the fires and how they are drawn, the survivors, the background and the generated art under `godot/art/` all stay as they are.
- `project.godot` rendering settings stay as they are, and the renderer is not switched. The Mobile (Metal) price run is a one-off command-line override. No particle trails, no 2D particle collision.
- The effects use no image files, no additive or other draw material and no `preprocess` above 0, and no steam emits on load. No effect scene fixes a seed. The puff is never a child of the player.
- The v1 text of `CHANGE-BRIEF.md` is never rewritten; new findings go under Revisions with a date.

## Unconfirmed

- `godot/effects/` and `godot/previews/` do not exist yet. The brief names no file for the configuration or state tests and gives them no fps. For the frame strips it gives only "30 fps, `--quit-after 210`": no capture script or command.
- The brief names no driver script or hook point. A5 used a node added from `player.gd` `_ready()`. Whether a hook line in `session.gd` `_ready()` counts as touching game logic is the human's call.
- The particle names, enum values and defaults rest on the brief's 4.7.2 probe, which is not committed. That covers `fixed_fps` 30, `interpolate` true, and `use_fixed_seed` / `seed` on both node types. A `ClassDB` probe in this session was blocked, because running Godot outside `scripts/run-test.sh` needed approval.
- Not established: whether `CPUParticles2D` simulates and emits `finished` under headless Godot (the A-R5 self-free test depends on it), and whether a `GPUParticles2D` does anything headlessly beyond storing its properties.
- The brief does not say whether the puff and the steam draw in front of or behind Extinguisho, the fires and the water stream.
- `fire_height()` counts physics ticks (`session.gd`: "4 s @ 60 Hz"), and `project.godot` sets no `physics_ticks_per_second`. No log shows the physics ticks per frame under `--fixed-fps 30` or `144`, so B-R3 ("0.5 after 2.0 s") is untested at those rates. Only 60 fps logs exist for `test_game`, `test_keyboard`, `test_audio` and `check_props`.
- The brief's background luminance and contrast figures, and its Visual Profiler / Mobile-override pricing method, have no committed file that reproduces them.
- The log results above are from the working tree. `logs/test_keyboard_60fps.log` and `logs/test_hose_glow_144fps.log` differ from HEAD; `logs/test_audio_realtime.log` is untracked. `test_keyboard.gd` prints no summary, so its 14/14 is a count of PASS lines.
