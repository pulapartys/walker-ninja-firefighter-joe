# CHANGE-BRIEF — Assignment 5: hose glow shader, textured hydrant

> v1 · 2026-10-28 · written and committed before any shader exists and before the first Claude Code prompt of this assignment. Later revisions are added at the bottom with a date; the v1 text is not rewritten.
>
> Game: **walker-ninja-firefighter-joe** (Extinguisho, a deadpan ninja firefighter; 2D, Godot 4.7.2, GL Compatibility). The 2D shader goes on Extinguisho in the game. The 3D parts go in the A3 props room (`godot/scenes3d/props_room.tscn`), because the game is 2D.
>
> How this brief was written: I made every decision in it (the state, the glow colour, the timing shape, the hydrant, the textures, how the two materials differ). Claude Code read my game's code for me, listed options, and typed this document from my decisions; I reviewed it. The pixel and hint-experiment arithmetic is shown step by step so I can redo it by hand and be asked about it.

---

## Part A — the shader from code: Extinguisho glows while hosing

### A1. The state

- **What it communicates:** the water is on. Extinguisho is hosing the fire that blocks the first survivor. Today the only signs are the water sprite and the hose pose; his body does not react. A pale blue-white glow on him says "water is pouring, keep holding position" and makes the 5 seconds of standing still read as an action, not a freeze.
- **Why the player needs it:** hosing costs about 4 of the 40 seconds. The player has to decide to stop and wait. A visible change on the character confirms the tap on W registered and the wait is working.
- **Script and variable that hold it:** `godot/game/session.gd` sets `water_ticks = EXTINGUISH_TICKS + 60` (= 300) when W is pressed in range of the blocking fire, counts it down by one per physics tick in `_physics_process`, and writes `player.hosing = water_ticks > 0` every physics frame. The driver reads **`player.hosing`** (a bool on `godot/features/player/player.gd`). It never writes it.
- **How the object is drawn:** Extinguisho is one `Sprite2D` (`player.sprite`) inside a holder `Node2D` (`player.art`) created in `player.gd` `_ready()`. The sprite's texture is swapped per pose (`show_pose`); while hosing it is `res://art/character/hose.png` (126 × 84 texels), drawn at scale 0.5, so 63 × 42 game px in the 640 × 360 viewport, which the window shows at 2× (1280 × 720). One texel is one window pixel.

### A2. The effect specification

**The shader**

| | |
|---|---|
| Path | `godot/shaders/hose_glow.gdshader` |
| `shader_type` | `canvas_item` |
| `render_mode` | none (default blend, default light mode) |
| Attached to | a `ShaderMaterial` on `player.sprite` (the driver creates it; no `.tres` needed for a 2D sprite) |
| Textures of its own | none. The pose image arrives in `COLOR` through the built-in sampler. |

**Uniforms**

| Name | Type | Hint | Default | Set by |
|---|---|---|---|---|
| `glow` | `float` | `hint_range(0.0, 1.0)` | `0.0` | the driver, every frame, from `player.hosing` (see A3) |
| `glow_color` | `vec4` | `source_color` | `vec4(0.6, 0.85, 1.0, 1.0)` | nobody at runtime; the Inspector/material default (pale blue-white) |

**The colour line** (the one line inside `fragment()` that changes the colour; the shader is written from it and every prediction below is computed from it):

```glsl
COLOR.rgb = mix(COLOR.rgb, glow_color.rgb, glow);
```

`COLOR.a` is left alone, so transparent texels stay transparent and the outline keeps its shape. At `glow = 0` the line is a no-op (the sprite looks as it does today). At `glow = 1` every opaque pixel is the glow colour.

### A3. Observable rules

| # | Rule | Value |
|---|---|---|
| R1 | `glow` when the state begins | rises from 0.0 and reaches **1.0** |
| R2 | `glow` when the state ends | falls and reaches **0.0** |
| R3 | How long a change takes | **0.25 s** up (0 → 1) and **0.25 s** down (1 → 0), tolerance one frame period. The hold in between is the game's own 5.0 s (`water_ticks` 300 at 60 physics ticks/s), not the driver's. |
| R4 | Same game time at 30, 60 and 144 fps | yes. The driver advances `glow` by `delta / 0.25` per `_process` frame, so the ramp takes 0.25 s of game time whatever the frame rate. |
| R5 | State begins again mid-transition | **ignore**. `session.gd` only starts hosing when `extinguish_ticks == 0` and the fire is still active, and the fire is out before the water stops, so a second W during the glow does nothing to the state and therefore nothing to `glow`. The test presses W again mid-glow and checks that nothing restarts. |
| R6 | Scaled or unscaled time; paused | **scaled**. The hold is physics ticks (frozen when the tree pauses, slowed by `Engine.time_scale`), and the ramps use `_process` `delta`, which is also scaled. While the tree is paused `glow` keeps its value (pause-menu shows him glowing if he was). |
| R7 | State ends before a transition finishes | the down-ramp starts from wherever `glow` is. On a fire death or R during hosing, `session.start_session()` resets `water_ticks` to 0 the same frame, `player.hosing` goes false, and `glow` ramps down from its current value over at most 0.25 s. It never jumps. |
| R8 | Several instances | there is exactly one Extinguisho. The material is created per player instance in the driver, not shared from a `.tres`, so a second instance would get its own `glow`. |

**Boundaries.** Collision, movement, input, the state machine and its timings (`EXTINGUISH_TICKS`, the +60 linger, `FIRE_DEATH_HOLD`), `session.gd`'s game logic, the existing tests and their expectations, the HUD, the fires, the survivors and the background stay unchanged. The driver only reads `player.hosing` and only writes the shader parameter. Presentation reads game state; it never writes it.

**Evidence split**

| Rule | Headless test or eyes | How |
|---|---|---|
| Shader parses; uniform names and types | test | `get_shader_uniform_list()` on the loaded shader must list `glow` (float) and `glow_color` (vec4); defaults read from the source text |
| R1, R2 | test | a sampler node with high `process_priority` reads `glow` every frame through a real W press in range of the fire; first value 0, max 1.0, last value 0 |
| R3, R4 | test at 30, 60, 144 fps | frames from first non-zero to 1.0 × frame period = 0.25 s ± one frame, at all three rates |
| R5 | test | press W again while `glow` is 1; no restart, `water_ticks` not reset |
| R6 | test for pause (value frozen); eyes for time scale | pause via `set_paused(true)` in the test and read `glow` across frames; `Engine.time_scale = 0.5` by eye, the glow should take 0.5 s to appear |
| R7 | test | press R mid-hose; `glow` decreases monotonically to 0, never jumps |
| R8 | eyes / reading | one player; noted, not tested |
| The look (colour, strength, whether it reads as water) | eyes only | the controlled captures below and normal play |

### A4. Controlled inputs and predicted pixel values

Three uniform values: **0.0, 0.5, 1.0**. The glow colour as 8-bit sRGB: 0.6 → 153, 0.85 → 217, 1.0 → 255, i.e. **(153, 217, 255)**.

Named pixels, given as texel (x, y) in `hose.png`, facing right (the capture maps a texel to window pixel `(2·player.x + x − 58.8, 2·player.y + y − 84)` from the anchor in `anchors.json`):

| Pixel | Texel (x, y) | Where on him | File RGB at glow 0 |
|---|---|---|---|
| P1 | (77, 49) | the red heat suit, chest | (229, 29, 25) |
| P2 | (51, 26) | the dark red of the suit in shadow, upper arm | (141, 14, 9) |
| P3 | (63, 6) | the yellow helmet, crown | (210, 134, 47) |

The art is painted, not flat: the 3 × 3 neighbourhood varies by up to 12 levels around P1, 17 around P2 and 68 around P3. The sprite sits at a fractional offset (anchor x = 58.8), so the on-screen pixel is a linear blend of neighbours. Expected tolerance: ±3 levels at P1, ±5 at P2, ±15 at P3. P3 is kept on purpose as the "hard" pixel; P1 and P2 carry the check.

Predictions from `mix(a, b, t) = a + (b − a)·t`, computed on the 8-bit values as written (the project does not enable `rendering/viewport/hdr_2d`, so 2D blending happens on sRGB values and no linearization applies):

| Pixel | glow 0.0 | glow 0.5 | glow 1.0 |
|---|---|---|---|
| P1 (229, 29, 25) | (229, 29, 25) | ((229+153)/2, (29+217)/2, (25+255)/2) = **(191, 123, 140)** | **(153, 217, 255)** |
| P2 (141, 14, 9) | (141, 14, 9) | ((141+153)/2, (14+217)/2, (9+255)/2) = **(147, 116, 132)** | **(153, 217, 255)** |
| P3 (210, 134, 47) | (210, 134, 47) | ((210+153)/2, (134+217)/2, (47+255)/2) = **(182, 176, 151)** | **(153, 217, 255)** |

**Lighting:** none. A `canvas_item` shader with no lights in the scene is unlit, so the output is exactly the arithmetic above. The effect is not lit by the scene.

**Contrast against the background.** Where he hoses, the sky behind his head is about (153, 162, 177) (`env_bg.png` texel (440, 400); the background is a fixed 640 × 360 `TextureRect` on a `CanvasLayer`). WCAG relative luminance, sRGB linearized: sky L ≈ 0.358; P1 at glow 0 L ≈ 0.176, at glow 0.5 L ≈ 0.271, at glow 1.0 L ≈ 0.636. Contrast ratio (L₁ + 0.05)/(L₂ + 0.05): **1.80 : 1** at glow 0, **1.27 : 1** at glow 0.5, **1.68 : 1** at glow 1.0. So mid-glow the suit sits closest to the sky. That is acceptable: the glow signals water, and his silhouette is carried by the dark outline, which the line also tints but which stays far darker than the sky. If the mid-glow frame looks washed out in play, Revision: lower `glow_color` toward (0.45, 0.75, 1.0) or cap `glow` at 0.8.

**The hint_range question (predict now):** `hint_range(0.0, 1.0)` does **not** clamp a value set from code. `set_shader_parameter("glow", 2.0)` will store 2.0 and `mix` will extrapolate: P1 → (229 + (153−229)·2, 29 + (217−29)·2, 25 + (255−25)·2) = (77, 405, 485), clamped by the 8-bit output to **(77, 255, 255)**. The capture with glow = 2.0 should show that cyan, not the glow colour. If it shows (153, 217, 255), the hint clamped and the prediction was wrong.

### A5. Predicted failure cases (Part A)

| # | What could go wrong | Check that catches it |
|---|---|---|
| F1 | The driver ramps in physics ticks or counts frames, so 0.25 s becomes 0.5 s at 30 fps and 0.1 s at 144 fps. | the 30/60/144 runs of the new test: the ramp must be 0.25 s ± one frame at all three |
| F2 | The driver restarts the ramp on a second W, or the test "passes" by calling the driver's update function directly instead of pressing W through the game loop. | the retrigger assertion, and reading the test: it must use `Input.action_press("water")` / the player's `test_water_pressed` hook, never call the driver |
| F3 | `source_color` on `glow_color` converts the uniform to linear even in 2D, so glow 1.0 shows (81, 177, 255) instead of (153, 217, 255). | the glow-1.0 capture at P1: (153, 217, 255) means no conversion, (81, 177, 255) means the hint converted |
| F4 | The driver sets a uniform the shader does not declare (typo), which raises no error. | the uniform-list assertion plus the rename mutation |
| F5 | The ShaderMaterial is put on `player` or `player.art` instead of `player.sprite`, so the code-drawn rescue bag and survivor heads glow too. | the controlled capture after a rescue: the orange bag must stay (230, 126, 34) at glow 1.0 |

---

## Part B — the hint experiment (its own scene)

- `godot/tests/write_grey_strip.gd` (committed) writes `godot/art/hint/grey_3x1.png`: 3 × 1 texels, greys **64, 128, 192**, imported Lossless, mipmaps off.
- `godot/shaders/hint_experiment.gdshader`: `shader_type spatial; render_mode unshaded;` two samplers of that one file, `uniform sampler2D as_color : source_color, filter_nearest;` and `uniform sampler2D as_data : filter_nearest;`, and `uniform bool use_color = false;` picking which one writes `ALBEDO`.
- Two materials, one per bool value, on two `MeshInstance3D` quads facing the camera in `godot/scenes3d/hint_experiment.tscn`, with a `WorldEnvironment` whose tonemap is **Linear** at exposure **1.0**, glow, fog and adjustments off.

**Predictions.** Values in the file as fractions: 64/255 = 0.251, 128/255 = 0.502, 192/255 = 0.753.

- *Data quad (no `source_color`)*: the shader receives the stored numbers as if they were linear light. The display encodes linear to sRGB with encode(x) = 1.055·x^(1/2.4) − 0.055: 0.251 → 0.538 → **137**; 0.502 → 0.737 → **188**; 0.753 → 0.882 → **225**. The bands come out lighter than the file.
- *Colour quad (`source_color`)*: the sampler decodes sRGB → linear first, the shader passes it through, the display re-encodes: **64, 128, 192**, unchanged. This is the quad I expect to show the file's values.
- *Renderer caveat:* this project uses **GL Compatibility**. The assignment's predictions assume Forward+ or Mobile. I will measure both quads before explaining; if Compatibility does not keep a linear 3D pipeline for this scene, the data quad may land elsewhere and that is a finding to record, not a reason to edit the prediction.

---

## Part C — the textured shader and its materials: the hydrant

### C1. Object and lighting

- **Object:** the **fire hydrant** in `godot/scenes3d/props_room.tscn` (node `Hydrant`, instancing `godot/props3d/hydrant.glb`, 356 triangles, with UVs in the export; the flame has no UVs, the backpack does). The material goes behind the importer's per-material **Use External** setting on the glb so a reimport keeps it; the second material goes on a second instance of the hydrant added to the scene at x = −1.6 (the existing one stays at x = −0.8), so both are judged under the same light.
- **Lighting to judge under:** the scene's existing `Sun` (`DirectionalLight3D`, shadows on, energy 1) and the `Environment` (flat colour background, ambient 0.6 energy), nothing else. No SSAO, no glow, no SSIL (unavailable in Compatibility anyway). Tonemap left at the scene's default (Linear) so roughness and bump differences are not hidden by a curve.

### C2. Textures

Source: Poly Haven, asset **Rusty Metal Sheet** (`rusty_metal_sheet`), author Amal Kumar, licence **CC0** (no credit required; the course requires provenance anyway), 1K PNG, URL `https://polyhaven.com/a/rusty_metal_sheet`, date checked **2026-10-28**. Files go in `godot/art/textures/rusty_metal_sheet/` with `ATTRIBUTION.md` beside them. The normal map used is the **OpenGL** one (`_nor_gl`), which Godot expects; the `_nor_dx` twin is downloaded only for the curl-check calibration and is not bound to any material.

| File | Role | What the numbers mean | Sampled as | Import settings I will set explicitly |
|---|---|---|---|---|
| `rusty_metal_sheet_diff_1k.png` | base colour | sRGB colour of painted, rusting steel | colour: `uniform sampler2D albedo_tex : source_color, filter_linear_mipmap;` | `compress/mode=0` (Lossless), `compress/normal_map=2` (Disabled), `mipmaps/generate=true` |
| `rusty_metal_sheet_rough_1k.png` | roughness | 0 = mirror, 1 = matte, stored as-is | data: `uniform sampler2D rough_tex : hint_default_white, filter_linear_mipmap;` (no `source_color`) | `compress/mode=0`, `compress/normal_map=2`, `mipmaps/generate=true` |
| `rusty_metal_sheet_nor_gl_1k.png` | tangent-space normal map | (x, y, z) slopes of the surface, packed 0–1, green = +Y (OpenGL) | data: `uniform sampler2D normal_tex : hint_normal, filter_linear_mipmap;` | `compress/mode=0`, `compress/normal_map=1` (Enable), `mipmaps/generate=true` |

Lossless is chosen so the bytes the shader samples are the bytes in the file, which is also what the curl check reads. `compress/normal_map` only matters for VRAM compression, but it is set explicitly on every file so the editor's "Detect" has nothing to change later.

### C3. The shader and its interface

`godot/shaders/hydrant_surface.gdshader`, `shader_type spatial;`, no `render_mode` (lit, so the roughness and normal map show).

| Group | Uniform | Type | Hint | Range | Default | What I expect to change across its range |
|---|---|---|---|---|---|---|
| `group_uniforms paint;` | `paint_tint` | `vec4` | `source_color` | — | `vec4(0.75, 0.22, 0.17, 1.0)` (the hydrant's red `#c0392b`) | the hue of the metal under the rust, from the raw photo colour (white tint) to deep red |
| | `rust_amount` | `float` | `hint_range(0.0, 1.0)` | 0–1 | `0.3` | how much of the texture's rust shows through the paint: 0 = fully painted, 1 = the photo as is |
| `group_uniforms surface;` | `roughness_scale` | `float` | `hint_range(0.0, 2.0)` | 0–2 | `1.0` | multiplies the roughness map: 0 = chrome, 2 = chalk |
| | `normal_strength` | `float` | `hint_range(0.0, 2.0)` | 0–2 | `1.0` | `NORMAL_MAP_DEPTH`: 0 = smooth, 2 = exaggerated pitting |
| | `uv_scale` | `float` | `hint_range(0.25, 8.0)` | 0.25–8 | `2.0` | how many times the sheet tiles around the hydrant |

Fragment logic (not the colour line of Part A; written here so the audit can check it): `ALBEDO = mix(albedo_tex.rgb * paint_tint.rgb, albedo_tex.rgb, rust_amount)`; `ROUGHNESS = texture(rough_tex, uv).r * roughness_scale`; `NORMAL_MAP = texture(normal_tex, uv).rgb; NORMAL_MAP_DEPTH = normal_strength`.

### C4. The two materials

| Material | `paint_tint` | `rust_amount` | `roughness_scale` | `normal_strength` | Why |
|---|---|---|---|---|---|
| `godot/materials/hydrant_fresh.tres` | red (default) | **0.1** | **0.7** | 1.0 | a newly painted hydrant: mostly red, a little rust in the pits, slightly glossy |
| `godot/materials/hydrant_rusty.tres` | red (default) | **0.9** | **1.4** | 1.0 | the same hydrant years later: the photo's rust dominates, matte |

They differ in two values (`rust_amount`, `roughness_scale`), share the shader and all three textures, and sit side by side under the same sun. Editing one line of the shader must change both; editing one value in `hydrant_rusty.tres` must change only that one.

### C5. Predicted failure cases (Parts B and C)

| # | What could go wrong | Check that catches it |
|---|---|---|
| F6 | The roughness or normal map gets `source_color` by mistake (or the editor's Detect sets the normal map to sRGB), so the surface is too glossy and the bumps lean the wrong way. | `test_materials.gd` reads each sampler's hints from the source text; the `source_color` mutation on the colour sampler must exit 1 |
| F7 | The DirectX normal map is bound instead of the OpenGL one, so lighting looks lit from below. | `normal_map_check.gd` curl ratio: the bound file must come out near 0 with `directx = false` and near 2 with `directx = true`, calibrated on the `_nor_gl` / `_nor_dx` pair |
| F8 | The material is set on the imported glb's mesh directly, and a reimport wipes it. | delete `godot/.godot`, reimport, run `test_materials.gd`: both materials must still resolve to `hydrant_surface.gdshader` |
| F9 | Lossless + `compress/normal_map=1` makes the importer swizzle the normal map into two channels, so `.rgb` is no longer (x, y, z). | the audit's `get_image().get_format()` on the imported normal texture must be RGB8/RGBA8, not an RG format; and the curl check reads the source PNG, not the import |
| F10 | The data quad in the hint experiment shows 64/128/192 unchanged under Compatibility, because the 2D/3D colour pipeline differs from Forward+. | the measured capture of both quads beside the predicted table; a mismatch is recorded and explained, not edited away |

---

## Short answers

1. **Renderer:** `godot/project.godot` names `renderer/rendering_method="gl_compatibility"`. That rules out decals and compute shaders (Forward+/Mobile only) and VoxelGI, SDFGI and SSIL (unavailable in Mobile and Compatibility). Everything in this brief works in Compatibility.
2. **What colour arrives in `fragment()`:** in `canvas_item`, `COLOR` arrives as the sprite's texel at this pixel already multiplied by the node's `modulate`/`self_modulate` and vertex colour. The tempting alternative, `texture(TEXTURE, UV)`, gives the raw texel with no modulate, so a `modulate` tint on the node would be lost.
3. **canvas_item, `texture(TEXTURE, UV)` vs `COLOR`:** the un-modulated texel; `COLOR` is the texel times modulate.
4. **spatial, `ALBEDO` and `COLOR`:** if `ALBEDO` is never written it holds white (1, 1, 1), so the surface takes only the lights' colour. `COLOR` holds the mesh's vertex colour (white for the hydrant, which has none).
5. **A frame-counting version:** if the ramp were "15 frames" it would last 0.50 s at 30 fps, 0.25 s at 60 fps and 0.104 s at 144 fps. That is why the driver uses `delta`.
6. **Default vs current value, shared material:** the **shader** (`.gdshader` source) holds the uniform's default; the **ShaderMaterial** holds its current value. If two objects shared one material, setting `glow` on it would glow both.
7. **Does `hint_range` clamp a value set from code?** Predicted: **no**. The Inspector slider clamps; `set_shader_parameter` does not. Checked in Use It with glow = 2.0 (A4).

---

## Revisions

<!-- Dated revisions go here. The v1 text above is not edited. -->

### Revision 1 — 2026-10-28, rule R7 names the wrong function

- **What I found:** reviewing the agent's CLAUDE.md draft against `godot/game/session.gd`, the function that resets `water_ticks` to 0 is `restart_attempt()`, not `start_session()`. `start_session()` calls it; so do the R key handler and the DYING timeout. The rule's behaviour is unchanged (the water stops the same frame and `glow` ramps down from its current value); only the name was wrong.
- **R7 now reads:** on a fire death, the DYING timeout or R during hosing, `session.restart_attempt()` resets `water_ticks` to 0 the same frame, `player.hosing` goes false, and `glow` ramps down from its current value over at most 0.25 s. It never jumps.
- The v1 text above is kept as written.
