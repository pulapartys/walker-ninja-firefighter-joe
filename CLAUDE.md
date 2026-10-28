# CLAUDE.md

There is no AGENTS.md in this repository (checked at the root on 2026-10-28).

## Project context

- **Engine:** Godot 4.7.2 stable. `godot/project.godot` declares `config/features=PackedStringArray("4.7", "GL Compatibility")`; every log in `logs/*.log` starts with `Godot Engine v4.7.2.stable.official`.
- **Renderer:** GL Compatibility. `godot/project.godot` `[rendering]` sets `renderer/rendering_method="gl_compatibility"` and `renderer/rendering_method.mobile="gl_compatibility"`. No `rendering/viewport/hdr_2d` key is present in `godot/project.godot`, so 2D blending is on sRGB values (as CHANGE-BRIEF.md A4 assumes).
- **Viewport:** 640 × 360, window override 1280 × 720, stretch mode `canvas_items` (`godot/project.godot` `[display]`).
- **Main scene:** `res://game/main.tscn` (`godot/project.godot` `run/main_scene`). `godot/game/main.tscn` is a single `Node2D` named `WalkerJumpman` with `res://game/session.gd` attached; everything else is built in code.
- **Game state that drives the effect:** `godot/game/session.gd`. In `_physics_process` it sets `water_ticks = EXTINGUISH_TICKS + 60` on a W press in range of the blocking fire (lines 246–249), counts it down (lines 254–255) and writes `player.hosing = water_ticks > 0` every physics tick (line 256). `EXTINGUISH_TICKS := 240` (line 25). `restart_attempt()` resets `water_ticks = 0` (line 161). The driver reads `player.hosing` only; nothing in `session.gd` should change.
- **How the shaded object is drawn:** `godot/features/player/player.gd` builds, in `_ready()` (lines 61–66), a holder `Node2D` `art` (`show_behind_parent = true`) and inside it one `Sprite2D` `sprite` with `centered = false`. `show_pose()` (lines 71–77) swaps `sprite.texture` to `res://art/character/<pose>.png`, sets `sprite.position` to minus the anchor from `godot/art/character/anchors.json`, and sets `art.scale = Vector2(0.5 * facing, 0.5)`. `_update_pose()` picks the `hose` pose when `hosing` is true and he is grounded and still (lines 111–112). The `hose` anchor is `[58.8, 84.0]` (`anchors.json`). The rescue bag and survivor heads are code-drawn in `player.gd` `_draw()` (lines 168–197) on the `CharacterBody2D` itself, not on `sprite`. There is no player `.tscn`; the player is `Player.new()` in `session.gd` line 69.
- **Hose pose texture import:** `godot/art/character/hose.png.import` has `compress/mode=0` (Lossless) and `mipmaps/generate=false`.
- **3D object for the textured shader:** node `Hydrant` in `godot/scenes3d/props_room.tscn` (line 48), instancing `res://props3d/hydrant.glb` at x = −0.8. The scene also holds `WorldEnvironment` (flat background, ambient energy 0.6), `Sun` (`DirectionalLight3D`, shadows on), `Camera3D`, `RescueBag` at x = 0, `Flame` at x = 0.8, and a 1.8 m reference pole at x = 1.5.
- **Where the hydrant's material comes from today:** embedded in the glb. `godot/props3d/hydrant.glb` carries two glTF materials, `hydrant_red` (baseColorFactor ≈ 0.527, 0.041, 0.024) and `hydrant_grey`, both created as flat colours in `tools/blender/build_hydrant.py` (lines 39–40). The mesh has `TEXCOORD_0`. `godot/props3d/hydrant.glb.import` has `materials/extract=0`, `_subresources={}` and `meshes/ensure_tangents=true`: no external material or per-material override exists yet, so the "Use External" path in CHANGE-BRIEF.md C1 has not been set up.
- **Existing tests (`godot/tests/`):** `test_game.gd` (41 checks, `SceneTree` script, writes `evidence/mechanics-*.json`), `test_keyboard.gd` (14 checks, synthetic `InputEventKey`), `test_audio.gd` (14 checks), `check_props.gd` (A3 prop geometry; prints `RESULT: PASS`), plus `route_driver.gd` (scripted route), `capture_game.gd` and `capture_props.gd` (need a window), and `run_check_props.sh`. Tests drive hosing through `game.player.test_water_pressed = true` with `test_control = true` (`test_game.gd` lines 161, 193).
- **Test runner:** `scripts/run-test.sh <test-file.gd> <fps>` runs `godot --headless --path godot --script res://tests/<file> --fixed-fps <fps>` under `timeout 120`, tees to `logs/<name>_<fps>fps.log`, and exits 1 on any `SHADER ERROR` or `SCRIPT ERROR` line (exit 124 = hung). `GODOT` may name the binary; it falls back to `~/Downloads/Godot.app/Contents/MacOS/Godot`. It forwards no extra user args, so `check_props.gd`'s `-- mutate` mode is not reachable through it.
- **Exact test commands (from the repository root):**

  ```
  scripts/run-test.sh test_game.gd 60
  scripts/run-test.sh test_keyboard.gd 60
  scripts/run-test.sh test_audio.gd 60
  scripts/run-test.sh check_props.gd 60
  ```

  Baseline on commit `025acf1` (logs in `logs/`): `test_game` 41/41, `test_keyboard` 14/14, `check_props` `RESULT: PASS`, `test_audio` 12/14. The two `test_audio` failures (`music-behaviour`, `music-loops`) occur only under `--fixed-fps` and are pre-existing; they are not caused by this change and must not be "fixed" as part of it. New A5 tests run the same way at 30, 60 and 144 fps.

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
- Write or edit any `.gdshader` (see Ownership).

## Unconfirmed

- `hose.png` is 126 × 84 texels (CHANGE-BRIEF.md A1). I could not read the PNG header in this session; `anchors.json` gives the hose anchor y as 84.0, which is consistent but not proof.
- CHANGE-BRIEF.md Part B says `godot/tests/write_grey_strip.gd` is committed. It is not in `godot/tests/` and has no git history. Neither `godot/art/hint/`, `godot/art/textures/`, `godot/shaders/` nor `godot/materials/` exists yet.
- The Poly Haven `rusty_metal_sheet` files, their licence and the `ATTRIBUTION.md` are described in the brief only; nothing is downloaded.
- The pixel values for P1–P3 and the sky texel are taken from the brief; they were not re-sampled here.
- Whether `hint_range` clamps `set_shader_parameter` values, and how GL Compatibility treats `source_color` in 2D and the Part B quads, are predictions in the brief, not facts established from this repository.
- Whether `-fixed-fps 30` and `144` runs pass the existing tests: only 60 fps logs exist in `logs/`.
