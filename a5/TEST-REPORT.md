# TEST REPORT — Assignment 5 (shaders, materials, the Godot shading language)

- **Engine:** Godot 4.7.2.stable.official (ed1daf0bf), GL Compatibility renderer (`godot/project.godot`).
- **OS:** macOS 26.6.2, Apple M1. OpenGL API 4.1 Metal (Compatibility) reported at window start.
- **How tests run:** every headless test through `scripts/run-test.sh <test>.gd <fps>` from the repository root; logs in `logs/`. Windowed captures through `godot --path godot --script res://tests/capture_glow.gd`.
- Each entry names the source revision it ran on. Results are recorded as they happened, newest last. **HUMAN CHECK** marks what only my eyes judged.

## Baseline — before any A5 change (2026-10-28)

- **Revision:** `c9cd749` (wrapper added, nothing else changed). Logs committed in `025acf1`.

| Test | Through the wrapper at 60 fps | The old way (no `--fixed-fps`) |
|---|---|---|
| `test_game.gd` | 41 checks / 0 failures | 41 / 0 |
| `test_keyboard.gd` | 14 PASS / 0 FAIL | 14 / 0 |
| `test_audio.gd` | **12 / 2 failures** (`music-behaviour`, `music-loops`) | 14 / 0 |
| `check_props.gd` | RESULT: PASS (3 of 3 props) | PASS |

- No `SHADER ERROR` or `SCRIPT ERROR` in any log.
- **Finding:** the two audio failures appear only when the frame rate is pinned. Both check the music stream's playback position (loop wrap, "back without restart"), which runs on the audio clock in real time; under `--fixed-fps` the game loop no longer waits for real time, so the stream never reaches its loop point inside the test's game-time window. Reproduced twice with the pin, passes twice without. It is a wrapper-versus-test interaction, not a game change; the assignment forbids editing existing tests, so the pinned baseline is recorded as 12/14 and the unpinned as 14/14.

## Shaders parse — `hose_glow.gdshader` (2026-10-28)

- **Revision:** `5775582` (the shader, typed by me in TextEdit from CHANGE-BRIEF A2).
- Reimport: no `SHADER ERROR`. Headless `get_shader_uniform_list()` on the loaded shader: 2 uniforms, `glow` type 3 (TYPE_FLOAT) hint 1 range `0.0,1.0`, `glow_color` type 20 (TYPE_COLOR, how a `source_color` vec4 is reported).

## Driver — `hose_glow.gd` + `test_hose_glow.gd` (2026-10-28)

- **Revision:** `41f7b17` (agent-written driver and test; invocation 2 of the Step 2 prompt, transcript `a5/sessions/session-2b-implement.jsonl`).
- The test presses W and R through `Input.parse_input_event` and samples the uniform from a `process_priority = 100` node every frame. It never calls the driver. I read the test to confirm this (the assignment's recorded agent mistake), and grepped it for driver calls: none.

| Run | Result | Up ramp | Down ramp | R mid-ramp |
|---|---|---|---|---|
| `test_hose_glow.gd` 30 fps | 12 / 0 | 8 frames = 0.267 s (tolerance 0.033) | 8 frames = 0.267 s | from 0.40, 4 frames to 0 |
| `test_hose_glow.gd` 60 fps | 12 / 0 | 15 frames = 0.250 s | 15 frames = 0.250 s | from 0.40 |
| `test_hose_glow.gd` 144 fps | 12 / 0 | 36 frames = 0.250 s | 36 frames = 0.250 s | from 0.36 |
| existing four at 60 | unchanged from baseline (41/41, 14/14, 12/14 audio, props PASS) | | | |

- First value 0.0 before W; max 1.0; last value 0.0 after the water stops; hold 152 frames at 30 fps = 5.07 s (the game's 300 physics ticks plus the ramp frame), `hosing` flipped false on the exact frame the down ramp began.
- Retrigger (R5): second W at glow 1.0 left `water_ticks` falling (282 → 276), hose sound count stayed 1, every sample stayed 1.0.
- Pause (R6, Revision 2): `set_paused(true)` during the hold, 10 frames, `water_ticks` frozen, every sample 1.0.
- Caveat the agent itself raised and I kept: the ramp-time check multiplies frames by the delta at the end of the ramp rather than summing per-frame deltas; the first few frames of a pinned run carry a slightly different delta. The monotonic check uses each frame's own delta. Not changed.

## Shader mutations (2026-10-28)

- **Revision:** `41f7b17` with the shader mutated in the working tree only, then `git checkout` restored it. Logs: `a5/evidence/mutations/`.

| Mutation | Result | Exit |
|---|---|---|
| Delete the semicolon on the colour line | `SHADER ERROR: Expected a ';'.`; uniform list empty; 3 checks fail (`shader-uniforms`, `colour-line`, `driver-param-declared`) | **1** |
| Rename `glow` → `glow_amount` in the shader only | parses; uniform list has `glow_amount`; 4 checks fail (`shader-uniforms`, `shader-defaults`, `colour-line`, `driver-param-declared`) | **1** |
| Restored, clean run | 12 / 0 | 0 |

- `git diff --stat godot/shaders/` empty after each restore.

## Controlled values — HUMAN CHECK (2026-10-28)

- **Revision:** `41f7b17` for the game source; `capture_glow.gd` added in the next commit. Captures: `a5/evidence/captures/glow_{0.0,0.5,1.0,2.0}.png` (rendered 1280 × 720 frames read from the viewport texture, not OS screenshots), samples in `capture_glow_output.jsonl`.
- How: a real session, Extinguisho at (1220, 240), W pressed through Input, waited for the `hose` pose (the first attempt sampled during the 30-tick respawn stance and landed on sky; fixed by waiting for `pose == "hose"`), driver `_process` stopped, `glow` set from code, two `frame_post_draw` awaits, frame saved, texel → window pixel via the viewport's final transform (the first mapping forgot the 2× `canvas_items` stretch and also landed on sky; both false starts are in FRICTIONAL).

| Pixel | glow | Predicted (A4) | Measured | Δ max channel |
|---|---|---|---|---|
| P1 chest (77, 49) | 0.0 | (229, 29, 25) | (227, 29, 25) | 2 |
| | 0.5 | (191, 123, 140) | (190, 123, 140) | 1 |
| | 1.0 | (153, 217, 255) | (153, 217, 255) | 0 |
| | 2.0 | (77, 255, 255) | (79, 255, 255) | 2 |
| P2 shadow (51, 26) | 0.0 | (141, 14, 9) | (143, 15, 10) | 2 |
| | 0.5 | (147, 116, 132) | (148, 116, 133) | 1 |
| | 1.0 | (153, 217, 255) | (153, 217, 255) | 0 |
| | 2.0 | (165, 255, 255) | (163, 255, 255) | 2 |
| P3 helmet (63, 6) | 0.0 | (210, 134, 47) | (206, 129, 47) | 5 |
| | 0.5 | (182, 176, 151) | (180, 173, 151) | 3 |
| | 1.0 | (153, 217, 255) | (153, 217, 255) | 0 |
| | 2.0 | (96, 255, 255) | (100, 255, 255) | 4 |

- Every difference is within the tolerance the brief set (±3 at P1, ±5 at P2, ±15 at P3); the small offsets at glow 0 are the sub-pixel blend of painted neighbours the brief predicted.
- **`hint_range` does not clamp a value set from code:** `set_shader_parameter("glow", 2.0)` read back 2.0 and the pixels overshot to cyan with green and blue clipped at 255, exactly the A4 arithmetic. Prediction confirmed.
- **F3 ruled out:** at glow 1.0 the pixel is exactly (153, 217, 255), so `source_color` did not convert the uniform to linear in 2D under Compatibility without HDR 2D.
- **OS screenshot comparison:** to do once (TEST-REPORT entry pending).
- **What I saw (my words):** _pending: my verdict on glow_0.5.png and glow_1.0.png._

## Import settings and texture data (2026-10-28)

- **Revision:** the "Part B/C groundwork" commit after `fc0f5b9`.
- Importer defaults on first import of every new PNG: `compress/mode=0`, `compress/normal_map=0` (Detect), `mipmaps/generate=false`, **`detect_3d/compress_to=1`** (on first 3D use the editor would silently reimport as VRAM Compressed). Set explicitly and reimported; values survived the reimport:

| File | compress/mode | compress/normal_map | mipmaps/generate | detect_3d/compress_to | Imported format (`get_image().get_format()`) |
|---|---|---|---|---|---|
| `art/hint/grey_3x1.png` | 0 Lossless | 2 Disabled | false | 0 Disabled | 4 = RGB8, 3 × 1, no mipmaps |
| `rusty_metal_sheet_diff_1k.png` | 0 | 2 | true | 0 | 4 = RGB8, 1024², mipmaps |
| `rusty_metal_sheet_rough_1k.png` | 0 | 2 | true | 0 | 0 = L8 (single channel), mipmaps |
| `rusty_metal_sheet_nor_gl_1k.png` | 0 | 1 Enable | true | 0 | 5 = RGBA8, mipmaps |
| `rusty_metal_sheet_nor_dx_1k.png` | 0 | 1 Enable | true | 0 | (calibration only, not bound) |

- **F9 ruled out:** with Lossless + `normal_map=1` the imported normal map is RGBA8, not a two-channel swizzle; `.rgb` is still (x, y, z).
- **Normal-map curl check**, `tests/normal_map_check.gd` (the assignment's code, unchanged), calibrated by `tests/calibrate_normal_maps.gd` at stride 4 on the 1K pair (`logs/calibrate_normal_maps_60fps.log`):

| File | `directx = false` | `directx = true` |
|---|---|---|
| `_nor_gl` | **0.5419** | 1.4581 |
| `_nor_dx` | 1.4584 | **0.5416** |

- The GL file reads low as GL and high as DX, the DX file the mirror image, so the sign convention is right as given (no flip). The values sit at 0.54 / 1.46 rather than ~0 / ~2 because Godot loads the 16-bit PNGs as 8-bit and the quantization noise pulls both toward 1, as the assignment's calibration note predicts. **Threshold set from the pair:** a map bound to a material must score below 1.0 with `directx = false` and above 1.0 with `directx = true`; the bound file is `_nor_gl` (0.54 / 1.46).
- The grey strip: `write_grey_strip.gd` wrote 3 × 1 RGB8 and read back `[64, 128, 192]`.

## Hint experiment — HUMAN CHECK (2026-10-28)

- **Revision:** the "Materials and scenes for Part B/C" commit; capture by `tests/capture_hint.gd` (windowed, real frame read from the viewport texture): `a5/evidence/captures/hint_experiment.png`, samples in `capture_hint_output.jsonl`. Scene: `scenes3d/hint_experiment.tscn`, `tonemap_mode=0` (Linear), `tonemap_exposure=1.0`, glow/fog/adjustments off, background 0.25 grey (= 64, which is why the first sampling attempt that landed on the background read 64 everywhere; fixed by applying the window stretch to the unprojected point, same mistake as the glow capture).

| Band in file | Colour quad (`use_color = true`, `source_color`) predicted | measured | Data quad (`use_color = false`) predicted (Forward+/Mobile) | measured |
|---|---|---|---|---|
| 64 | 64 | **64** | 137 | **64** |
| 128 | 128 | **128** | 188 | **128** |
| 192 | 192 | **192** | 225 | **192** |

- 5 × 5 neighbourhood around each sample is flat (min = max), so these are band values, not edges.
- **What I saw:** two identical quads. The colour quad matches its prediction; the data quad does **not** match the Forward+/Mobile prediction. This is CHANGE-BRIEF F10, the Compatibility case the brief said to measure before explaining.
- **Explanation (after measuring):** the GL Compatibility renderer shades 3D in sRGB ("gamma") space, not linear. There is no linear stage, so `source_color` has nothing to decode into and the sampler returns the stored 8-bit value; and the output is written to the sRGB framebuffer as-is, with no encode step. Both paths are identity, so both quads show the file. The prediction's two steps (decode on sample, encode on display) both exist only in Forward+ and Mobile. Under this renderer the `source_color` hint changes how the Inspector and importer treat the texture, not the value the shader receives (LANGUAGE-NOTES question 4 cites this).
- **What this does not change:** the hint is still required and still correct for the colour textures; on Forward+ or Mobile the same project would show 137/188/225 on the data quad.

## One shader, two materials + interface sweep — HUMAN CHECK (2026-10-28)

- **Revision:** the "Materials and scenes for Part B/C" commit; captures by `tests/capture_hydrant.gd` (windowed, real frames): `a5/evidence/captures/hydrant/*.png`, sampled body pixels (5 × 5 mean at a point 0.45 m up the front of each body) in `hydrant_output.jsonl`. Lighting: the props room's own `Sun` (shadows on) and `Environment` (flat background, ambient 0.6), nothing else, as CHANGE-BRIEF C1 says. Camera moved to frame the two hydrants; nothing else in the scene touched.
- The fresh hydrant (x = −0.8) gets `hydrant_fresh.tres` through the glb importer's Use External; the rusty one (x = −1.6) gets `hydrant_rusty.tres` through a surface override on the instance. Both report the same `Shader` object at runtime.

| Capture | fresh body mean RGB | rusty body mean RGB |
|---|---|---|
| `side_by_side` | (115, 43, 33) | (130, 121, 103) |
| `sweep_rust_amount_min` | (115, 43, 33) | (99, 29, 21) |
| `sweep_rust_amount_default` | (115, 43, 33) | (109, 58, 47) |
| `sweep_rust_amount_max` | (115, 43, 33) | (133, 131, 113) |
| `sweep_roughness_scale_min` | (115, 43, 33) | (127, 117, 99) |
| `sweep_roughness_scale_default` | (115, 43, 33) | (130, 121, 104) |
| `sweep_roughness_scale_max` | (115, 43, 33) | (128, 119, 101) |
| `sweep_normal_strength_min` | (115, 43, 33) | (130, 120, 103) |
| `sweep_normal_strength_default` | (115, 43, 33) | (130, 121, 103) |
| `sweep_normal_strength_max` | (115, 43, 33) | (130, 121, 104) |
| `sweep_uv_scale_min` | (115, 43, 33) | (129, 108, 76) |
| `sweep_uv_scale_default` | (115, 43, 33) | (130, 121, 103) |
| `sweep_uv_scale_max` | (115, 43, 33) | (129, 118, 98) |
| `sweep_paint_tint_min` | (115, 43, 33) | (119, 118, 101) |
| `sweep_paint_tint_default` | (115, 43, 33) | (130, 121, 103) |
| `sweep_paint_tint_max` | (115, 43, 33) | (133, 131, 113) |
| `material_edit_rust_0` | (115, 43, 33) | (99, 29, 21) |
| `shader_edited` | (57, 43, 48) | (63, 121, 157) |

- **Two materials, one shader:** `side_by_side`: red painted vs rusty raw metal under the same sun. They differ in `rust_amount` (0.1 vs 0.9) and `roughness_scale` (0.7 vs 1.4).
- **Edit one value in one material** (`material_edit_rust_0`): `rust_amount` set to 0.0 on the rusty material at runtime; the rusty body went from (130, 121, 103) to (99, 29, 21), the fresh body stayed (115, 43, 33). Only one changed.
- **Edit one line of the shader** (`shader_edited`): the `ALBEDO` line temporarily multiplied by `vec3(0.5, 1.0, 1.5)` in `hydrant_surface.gdshader`, captured, then the file restored with `git checkout` (diff empty). Fresh body (115, 43, 33) → (57, 43, 48); rusty body (130, 121, 103) → (63, 121, 157). Both changed.
- **Interface sweep (rusty material):** `rust_amount` swings the body from fully painted red (99, 29, 21) to the raw photo (133, 131, 113); `paint_tint` black → white moves it the same way at the painted fraction; `uv_scale` 0.25 makes one big smear of the sheet (129, 108, 76) and 8 a fine tile. `roughness_scale` and `normal_strength` move the sampled point by only 1–3 levels because they change highlight position and shading across the surface, not one spot: judged by eye below.
- **What I saw (my words):** _pending: my verdict on side_by_side.png, the roughness and normal-strength sweeps, and any setting that breaks the look._

## Open items

- In play (HUMAN CHECK): trigger hosing by normal play several times; boundaries hold.
- `Engine.time_scale = 0.5` by eye.
- The bag at (230, 126, 34) after a rescue at glow 1.0 (F5).
- Hint experiment, textured shader, materials, language notes: not started.
