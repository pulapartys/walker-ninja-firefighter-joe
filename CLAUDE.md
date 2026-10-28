# CLAUDE.md

There is no AGENTS.md in this repository.

## Project context

- **Engine:** Godot 4.7.2 stable. `godot/project.godot` declares `config/features=PackedStringArray("4.7", "GL Compatibility")`; every log in `logs/*.log` starts with `Godot Engine v4.7.2.stable.official`.
- **Renderer:** GL Compatibility. `godot/project.godot` `[rendering]` sets `renderer/rendering_method="gl_compatibility"` and `renderer/rendering_method.mobile="gl_compatibility"`. No `rendering/viewport/hdr_2d` key is present, so 2D blending is on sRGB values (as CHANGE-BRIEF.md A4 assumes).
- **Viewport:** 640 × 360, window override 1280 × 720, stretch mode `canvas_items` (`godot/project.godot` `[display]`). One texel of a sprite drawn at scale 0.5 is one window pixel.
- **Main scene:** `res://game/main.tscn` (`godot/project.godot` `run/main_scene`). `godot/game/main.tscn` is a single `Node2D` named `WalkerJumpman` with `res://game/session.gd` attached; everything else is built in code.
- **Game state that drives the effect:** `godot/game/session.gd`. In `_physics_process` it sets `water_ticks = EXTINGUISH_TICKS + 60` on a W press in range of the blocking fire, counts it down, and writes `player.hosing = water_ticks > 0` every physics tick. `EXTINGUISH_TICKS := 240`. `restart_attempt()` resets `water_ticks = 0`; it is called by `start_session()`, by the R key handler in `_unhandled_input`, and by the DYING timeout in `_physics_process`. The driver reads `player.hosing` only; nothing in `session.gd` changes.
- **How the shaded object is drawn:** `godot/features/player/player.gd` builds, in `_ready()`, a holder `Node2D` `art` (`show_behind_parent = true`) and inside it one `Sprite2D` `sprite` with `centered = false`. `show_pose()` swaps `sprite.texture` to `res://art/character/<pose>.png`, sets `sprite.position` to minus the anchor from `godot/art/character/anchors.json`, and sets `art.scale = Vector2(0.5 * facing, 0.5)`. `_update_pose()` picks the `hose` pose when `hosing` is true and he is grounded and still. The `hose` anchor is `[58.8, 84.0]`; `hose.png` is 126 × 84 texels. The rescue bag and survivor heads are code-drawn in `player.gd` `_draw()` on the `CharacterBody2D` itself, not on `sprite`. There is no player `.tscn`; the player is `Player.new()` in `session.gd` `_ready()`.
- **Hose pose texture import:** `godot/art/character/hose.png.import` has `compress/mode=0` (Lossless) and `mipmaps/generate=false`.
- **3D object for the textured shader:** node `Hydrant` in `godot/scenes3d/props_room.tscn`, instancing `res://props3d/hydrant.glb` at x = −0.8. The scene also holds `WorldEnvironment` (flat background, ambient energy 0.6), `Sun` (`DirectionalLight3D`, shadows on), `Camera3D`, `RescueBag` at x = 0, `Flame` at x = 0.8, and a 1.8 m reference pole at x = 1.5.
- **Where the hydrant's material comes from today:** embedded in the glb. `godot/props3d/hydrant.glb` carries two glTF materials, `hydrant_red` (baseColorFactor ≈ 0.527, 0.041, 0.024) and `hydrant_grey`, both created as flat colours by `flat_material()` in `tools/blender/build_hydrant.py`. The mesh has `TEXCOORD_0`. `godot/props3d/hydrant.glb.import` has `materials/extract=0`, `_subresources={}` and `meshes/ensure_tangents=true`: no external material or per-material override exists yet, so the "Use External" path in CHANGE-BRIEF.md C1 is still to be set up in the editor.
- **Existing tests (`godot/tests/`), all `extends SceneTree`:** `test_game.gd` (41 checks; also writes `evidence/mechanics-*.json`), `test_keyboard.gd` (14 checks, synthetic `InputEventKey`), `test_audio.gd` (14 checks), `check_props.gd` (A3 prop geometry; prints `RESULT: PASS`). Tests drive hosing through `game.player.test_water_pressed = true` with `test_control = true` (`test_game.gd`). **Not tests:** `route_driver.gd` (scripted route helper), `capture_game.gd` and `capture_props.gd` (screenshot scripts, need a window), `run_check_props.sh` (A3 runner, superseded by `scripts/run-test.sh` for A5).
- **Test runner:** `scripts/run-test.sh <test-file.gd> <fps>` runs `godot --headless --path godot --script res://tests/<file> --fixed-fps <fps>` under `timeout 120`, tees to `logs/<name>_<fps>fps.log`, and exits 1 on any `SHADER ERROR` or `SCRIPT ERROR` line (exit 124 = hung). `GODOT` may name the binary; it falls back to `~/Downloads/Godot.app/Contents/MacOS/Godot` (adapt this path on another machine). It forwards no extra user args, so `check_props.gd`'s `-- mutate` mode is not reachable through it.
- **Exact test commands (from the repository root):**

  ```
  scripts/run-test.sh test_game.gd 60
  scripts/run-test.sh test_keyboard.gd 60
  scripts/run-test.sh test_audio.gd 60
  scripts/run-test.sh check_props.gd 60
  ```

  Baseline on commit `025acf1` (logs in `logs/`): `test_game` 41/41, `test_keyboard` 14/14, `check_props` `RESULT: PASS`, `test_audio` 12/14. The two `test_audio` failures (`music-behaviour`, `music-loops`) occur only under `--fixed-fps` (14/14 without it) and are pre-existing; they are not caused by this change and must not be "fixed" as part of it. New A5 tests run the same way at 30, 60 and 144 fps.

## Headless facts

What a `scripts/run-test.sh` run on this machine can and cannot observe:

- Headless Godot uses a dummy renderer: nothing is drawn, no viewport image exists, no pixel can be read. Every claim about the look (colour, glow strength, roughness, bumps, the hint-experiment bands) is a human check in the editor, recorded in `a5/TEST-REPORT.md`.
- `Shader.get_shader_uniform_list()` works headlessly and returns names and types; it returns an empty list for a shader that failed to parse. Uniform defaults are not reported headlessly; read them from the `.gdshader` source text.
- `ShaderMaterial.set_shader_parameter()` stores any name and any value without error, and `get_shader_parameter()` reads it back, so a set-then-get round trip proves nothing about the shader. Only the uniform-list assertion catches a renamed or missing uniform.
- `--fixed-fps N` pins the physics and process step to 1/N s of game time; a run does not take real time. A ramp written in `delta` seconds must take the same number of game-seconds at 30, 60 and 144.
- Real input works headlessly: `Input.action_press()` / `action_release()`, and the player's `test_water_pressed` hook used by `test_game.gd`. The hosing state can be driven through the real game loop.
- Audio timing is not headless-safe under `--fixed-fps`: `AudioStreamPlayer` playback position runs on the audio clock, which is why `test_audio.gd` loses two checks when pinned.
- A `.import` file is written by the editor's importer; `godot --headless --path godot --import` reproduces it from the source file and the `[params]` block, and `ConfigFile` can read it in a test.

## Current change

@CHANGE-BRIEF.md

## Ownership

Files in `godot/shaders/` are hand-written by the human and are never edited by an agent. That covers `hose_glow.gdshader`, `hint_experiment.gdshader` and `hydrant_surface.gdshader` named in the brief. An agent may read them, write drivers, tests and scenes that use them, and report what it observes; it does not create, edit, rename or delete anything under `godot/shaders/`.

## Out of scope

This change adds presentation that reads game state. It must not:

- Edit `godot/game/session.gd` game logic: the hose state machine, `EXTINGUISH_TICKS`, the +60 water linger, `FIRE_DEATH_HOLD`, death, rescue, timer, pause, audio or input handling. Any A5 driver reads `player.hosing` and writes only a shader parameter.
- Change collision, movement, input mapping or tuning (`godot/features/player/player.gd` physics, `tuning.gd`, `godot/levels/first_steps.json`).
- Alter the existing tests or their expectations (`test_game.gd`, `test_keyboard.gd`, `test_audio.gd`, `check_props.gd`), including the pre-existing `test_audio` fixed-fps failures.
- Touch the HUD (`godot/ui/hud.gd`), the fires, the survivors, the background or the generated art under `godot/art/character/` and `godot/art/env/`.
- Put the glow material anywhere but `player.sprite`. The code-drawn rescue bag and survivor heads must stay their own colours.
- Change the hydrant mesh, `hydrant.glb`, or the other props and their placement; the second hydrant is a new instance at x = −1.6, the existing one stays at x = −0.8. Lighting and the environment in `props_room.tscn` stay as they are.
- Edit `project.godot` rendering settings (no `hdr_2d`, no renderer switch).
- Rewrite the v1 text of `CHANGE-BRIEF.md`; new findings go under its Revisions heading with a date.
- Write or edit any `.gdshader` (see Ownership). Edit `scripts/run-test.sh`.

## Unconfirmed

- CHANGE-BRIEF.md Part B names `godot/tests/write_grey_strip.gd`; it is planned, not yet written. `godot/art/hint/`, `godot/art/textures/`, `godot/shaders/` and `godot/materials/` do not exist yet.
- The Poly Haven `rusty_metal_sheet` files, their licence and the `ATTRIBUTION.md` are described in the brief only; nothing is downloaded.
- The pixel values for P1–P3 come from a headless `Image.load_from_file` probe of `hose.png` (not committed); the sky texel from the same probe of `env_bg.png`. They are not editor measurements.
- Whether `hint_range` clamps `set_shader_parameter` values, and how GL Compatibility treats `source_color` in 2D and the Part B quads, are predictions in the brief, not facts established from this repository.
- Whether `--fixed-fps 30` and `144` runs pass the existing tests: only 60 fps logs exist in `logs/`.
