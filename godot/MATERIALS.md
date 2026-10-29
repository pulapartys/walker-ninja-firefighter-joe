# MATERIALS.md — audit of the Assignment 5 materials

Audited 2026-10-28 by Claude Code on the working tree at commit `d6d1030`, reviewed by me the same day (review notes marked **Review:** inline; line numbers, byte counts and enum values re-checked against the files), Godot 4.7.2.stable, GL Compatibility. Everything in the tables was read from the files named in each row and then confirmed by loading the scenes headlessly; `godot/tests/test_materials.gd` pins the tables (35 checks, run with `./scripts/run-test.sh test_materials.gd 60`). Nothing here was judged by eye: headless Godot draws nothing, so the look is a human check recorded in `a5/TEST-REPORT.md`.

## 1. Materials

| Resource | Shader | Uniform values set in the `.tres` | Textures bound | Used by |
|---|---|---|---|---|
| `res://materials/hydrant_fresh.tres` (`resource_name` `hydrant_fresh`) | `res://shaders/hydrant_surface.gdshader` | `rust_amount = 0.1`, `roughness_scale = 0.7`. Not set, so the shader defaults apply: `paint_tint` (0.75, 0.22, 0.17, 1.0), `normal_strength` 1.0, `uv_scale` 2.0 | `albedo_tex` → `rusty_metal_sheet_diff_1k.png`, `rough_tex` → `rusty_metal_sheet_rough_1k.png`, `normal_tex` → `rusty_metal_sheet_nor_gl_1k.png` | surface 0 (`hydrant_red`) of `hydrant.glb`, through the importer's Use External setting (`godot/props3d/hydrant.glb.import` `_subresources`), so every instance of the glb gets it unless overridden |
| `res://materials/hydrant_rusty.tres` (`hydrant_rusty`) | `res://shaders/hydrant_surface.gdshader` (the same `Shader` object at runtime) | `rust_amount = 0.9`, `roughness_scale = 1.4`. Not set: `paint_tint`, `normal_strength`, `uv_scale` (shader defaults, as above) | the same three files | `surface_material_override/0` on `HydrantRusty/Hydrant` in `props_room.tscn` (editable-children instance at x = −1.6) |
| `res://materials/hint_as_color.tres` (`hint_as_color`) | `res://shaders/hint_experiment.gdshader` | `use_color = true` | `as_color` → `art/hint/grey_3x1.png`, `as_data` → `art/hint/grey_3x1.png` | `surface_material_override/0` on `QuadAsColor` in `hint_experiment.tscn` (x = −0.6) |
| `res://materials/hint_as_data.tres` (`hint_as_data`) | `res://shaders/hint_experiment.gdshader` | `use_color = false` | `as_color` → `grey_3x1.png`, `as_data` → `grey_3x1.png` | `surface_material_override/0` on `QuadAsData` (x = +0.6) |

The two hydrant materials differ in exactly two values, `rust_amount` and `roughness_scale` (CHANGE-BRIEF C4); the test computes the difference over every declared uniform and finds only those two. Each `.tres` sets only names the shader declares (five for the hydrant materials, three for the hint materials).

Surface 1 of the hydrant mesh (`hydrant_grey`) is not covered by any file in `godot/materials/`: on both instances it is the glb's embedded `StandardMaterial3D` (`res://props3d/hydrant.glb::StandardMaterial3D_nwqcv`, albedo (0.604, 0.639, 0.671)). See finding F-1.

## 2. Samplers

Hints are quoted from the `.gdshader` source text. The engine's `get_shader_uniform_list()` reports samplers only as `TYPE_OBJECT` with hint 17 (`Texture2D`); it does not expose `source_color`, `hint_normal` or the filter, which is why the test reads the source.

| Shader | Sampler | Hints as written | Bound texture | `compress/mode` | `compress/normal_map` | `mipmaps/generate` | Imported format (`get_image().get_format()`) |
|---|---|---|---|---|---|---|---|
| `hydrant_surface.gdshader` | `albedo_tex` | `source_color, filter_linear_mipmap` | `rusty_metal_sheet_diff_1k.png` (both hydrant materials) | 0 (Lossless) | 2 (Disabled) | true | 4 = RGB8, 1024², mipmaps |
| | `rough_tex` | `hint_default_white, filter_linear_mipmap` | `rusty_metal_sheet_rough_1k.png` (both) | 0 | 2 | true | 0 = L8, 1024², mipmaps |
| | `normal_tex` | `hint_normal, filter_linear_mipmap` | `rusty_metal_sheet_nor_gl_1k.png` (both) | 0 | 1 (Enable) | true | 5 = RGBA8, 1024², mipmaps |
| `hint_experiment.gdshader` | `as_color` | `source_color, filter_nearest` | `art/hint/grey_3x1.png` (both hint materials) | 0 | 2 | false | 4 = RGB8, 3 × 1, no mipmaps |
| | `as_data` | `filter_nearest` | `art/hint/grey_3x1.png` (both) | 0 | 2 | false | 4 = RGB8, 3 × 1, no mipmaps |
| (none) | — | — | `rusty_metal_sheet_nor_dx_1k.png`, bound to no material; read from the source PNG by the curl check only | 0 | 1 | true | 5 = RGBA8, 1024², mipmaps |

All five `.import` files also carry `detect_3d/compress_to=0` (so the first 3D use cannot silently reimport as VRAM Compressed) and `process/normal_map_invert_y=false` (right for an OpenGL-convention map).

Non-sampler uniforms, from the source: `paint_tint : source_color = vec4(0.75, 0.22, 0.17, 1.0)`, `rust_amount : hint_range(0.0, 1.0) = 0.3`, `roughness_scale : hint_range(0.0, 2.0) = 1.0`, `normal_strength : hint_range(0.0, 2.0) = 1.0`, `uv_scale : hint_range(0.25, 8.0) = 2.0`, in groups `paint` and `surface`; `use_color = false`. `get_shader_uniform_list()` returns 8 entries for the hydrant shader (10 with `get_groups = true`, the two extra being the group markers) and 3 for the hint shader.

Fragment logic, as written: `uv = UV * uv_scale`; `base = texture(albedo_tex, uv).rgb`; `ALBEDO = mix(base * paint_tint.rgb, base, rust_amount)`; `ROUGHNESS = texture(rough_tex, uv).r * roughness_scale`; `NORMAL_MAP = texture(normal_tex, uv).rgb`; `NORMAL_MAP_DEPTH = normal_strength`. The hint shader is `spatial`, `render_mode unshaded`, and writes `ALBEDO` from `as_color` or `as_data` according to `use_color`. Both match CHANGE-BRIEF C3 and Part B.

## 3. Lights and environment

| Scene | Setting | Value | Source |
|---|---|---|---|
| `props_room.tscn` | Lights | exactly one: `Sun`, `DirectionalLight3D`, `light_energy` 1.0 (default), colour white, `shadow_enabled = true`, `light_specular` 1.0, `light_indirect_energy` 1.0, direction (−0.369, −0.766, −0.527) | `.tscn` lines 40–42; defaults confirmed by loading |
| | Environment background | `background_mode = 1` (Color), (0.17, 0.19, 0.23) | sub_resource `env` |
| | Ambient | `ambient_light_source = 2` (Color), (0.6, 0.62, 0.68), `ambient_light_energy = 0.6` | sub_resource `env` |
| | Tonemap | `tonemap_mode` 0 (Linear), `tonemap_exposure` 1.0, `tonemap_white` 1.0 — none of these keys is written in the file; they are the class defaults | loaded `Environment` |
| | Post effects | glow, fog, adjustments, SSAO, SSR, SSIL, SDFGI all off (defaults; SSIL/SDFGI are unavailable in Compatibility anyway) | loaded `Environment` |
| `hint_experiment.tscn` | Lights | none (the shader is unshaded, so none would matter) | scene tree |
| | Environment | `background_mode = 1` (Color), (0.25, 0.25, 0.25); `tonemap_mode = 0` (Linear), `tonemap_exposure = 1.0`, `glow_enabled = false`, `fog_enabled = false`, `adjustment_enabled = false`, all written explicitly | `.tscn` lines 9–16 |
| | Camera | z = 2.2, fov 50, quads 1 × 1 at x = ±0.6 | `.tscn` |

Both scenes therefore show the materials with a Linear tonemap at exposure 1.0, which is what CHANGE-BRIEF C1 and Part B ask for. Roughness and bump differences on the hydrants are driven by one white sun plus a dim blue-grey ambient; nothing else lights them.

## 4. Findings

| # | Kind | Finding | Evidence |
|---|---|---|---|
| F-1 | Not covered by the brief, consistent | The hydrant mesh has **two** surfaces, `hydrant_red` then `hydrant_grey`. Only `hydrant_red` is behind Use External; `hydrant_grey` stays the glb's embedded flat `StandardMaterial3D` on both instances, so the rusty override on surface 0 leaves the grey parts identical on the fresh and rusty hydrants. This is what CHANGE-BRIEF C1 describes ("the material" is the red one) and is not wrong, but no file in `godot/materials/` governs the grey, and the `surface_material_override/0` wiring depends on `hydrant_red` staying surface 0 in the glb export. The test pins both the surface order and the per-surface active material. | `hydrant.glb.import` lines 43–49 (only `hydrant_red` listed); headless `surface_get_name(0..1)` = `hydrant_red`, `hydrant_grey`; `props_room.tscn` line 56 |
| F-2 | Wasteful, minor | `rusty_metal_sheet_nor_dx_1k.png` is never bound, and the curl check reads it from the source PNG with `Image.load_from_file`, yet it is imported like a bound normal map (`compress/normal_map=1`, `mipmaps/generate=true`), producing a 1.06 MB `.ctex` in `.godot/imported/` that nothing loads. No VRAM cost at runtime (nothing references it); only import time and cache space. Changing its importer is an `.import` edit and out of scope for this task. | `rusty_metal_sheet_nor_dx_1k.png.import` lines 24, 26; `ls godot/.godot/imported/` shows `rusty_metal_sheet_nor_dx_1k.png-….ctex` 1 058 664 bytes; `grep nor_dx godot/materials/*.tres` empty |
| F-3 | Consistent, by design | Each hint material binds the grey strip to **both** samplers, although the shader samples only the one `use_color` selects, so one binding per material is unused at runtime. This is deliberate (Part B: "two samplers of that one file"), so that the only difference between the quads is the sampler hint. | `hint_as_color.tres` lines 10–11, `hint_as_data.tres` lines 10–11 |
| F-4 | Watch item, not establishable headlessly | `hydrant_rusty` sets `roughness_scale = 1.4`, so `ROUGHNESS` exceeds 1.0 wherever the roughness map reads above 0.714. Whether Godot's Compatibility scene shader clamps `ROUGHNESS` to 1.0 before lighting is not something this repository establishes; the brief's own range ("2 = chalk") assumes it is harmless. Judge the rusty hydrant by eye for specular artefacts and note the verdict in `a5/TEST-REPORT.md`. | `hydrant_rusty.tres` line 12; shader line `ROUGHNESS = texture(rough_tex, uv).r * roughness_scale;` |
| F-5 | Arithmetic; renderer-dependent (reviewed) | `paint_tint` default (0.75, 0.22, 0.17) carries `source_color`; on Forward+ or Mobile the shader would receive it linearised, ≈ (0.522, 0.040, 0.025). **Review:** under GL Compatibility the hint experiment (`a5/TEST-REPORT.md`) showed no sRGB decode on a `source_color` sampler, so whether a `source_color` *uniform* is linearised here is unverified; the arithmetic below holds only where the decode happens. That is the glb's original flat `hydrant_red` baseColorFactor (0.527, 0.041, 0.024) from CLAUDE.md, so with `rust_amount = 0` and a white albedo texel the painted hydrant would match the old flat red. The albedo photo is darker than white, so the fresh hydrant reads darker than the A3 one; expected, not a bug. | shader line `uniform vec4 paint_tint : source_color = vec4(0.75, 0.22, 0.17, 1.0);`; CLAUDE.md "Where the hydrant's material comes from today" |
| F-6 | Unverified claim in `ATTRIBUTION.md` | `ATTRIBUTION.md` says the PNGs are 16-bit per channel as shipped. Godot's `Image.load_from_file` returns 8-bit formats for all four (RGB8, L8, RGBA8, RGBA8) and the imported `.ctex` files are 8-bit, so any extra precision is dropped at load. `a5/TEST-REPORT.md` already attributes the curl ratios of 0.54 / 1.46 (rather than ~0 / ~2) to this quantisation. **Review:** the PNG headers were read with `file(1)`: `diff` 16-bit/color RGB, `rough` 16-bit grayscale, `nor_gl` and `nor_dx` 16-bit/color RGBA. The claim is verified; the precision is dropped at load, as stated. | `ATTRIBUTION.md` line 12; test output `imported-format` rows; `ls -l godot/art/textures/rusty_metal_sheet/` |
| F-7 | Minor waste | Both normal-map PNGs load as RGBA8, so the files carry an alpha channel the shader never samples (`.rgb`). The bound GL map therefore occupies four channels in VRAM where three would do. **Review:** the draft's megabyte estimates were computed, not measured, and are removed. | test output `imported-format rusty_metal_sheet_nor_gl_1k.png` format 5 |
| F-8 | Consistent | Every `.import` value in CHANGE-BRIEF C2's table matches the files: Lossless on all, `normal_map` 2 on diff/rough and 1 on the normal map, mipmaps on for the 1K maps and off for the grey strip. The brief's table does not list `detect_3d/compress_to=0`, which all five files set; without it the editor's first 3D use would have reimported them as VRAM Compressed and broken the Lossless assumption (recorded in TEST-REPORT). | the five `.import` files, `[params]` blocks |
| F-9 | Consistent | `hydrant.glb.import` has `materials/extract=0` with Use External enabled for `hydrant_red`, `use_external/path` and `use_external/fallback_path` both `res://materials/hydrant_fresh.tres`; `meshes/ensure_tangents=true` so the normal map has tangents. The glb is still the single source of the mesh (F8 in the brief: a reimport keeps the material because it is referenced from the `.import`, not stored in the mesh). | `hydrant.glb.import` lines 26, 39, 42–50 |
| F-10 | Consistent | `props_room.tscn` writes no tonemap keys; the Linear tonemap and exposure 1.0 the brief relies on (C1) are class defaults. A future edit in the editor would appear as a new line in the `.tscn`, and the test now asserts the loaded values, so a change cannot slip in silently. | `props_room.tscn` sub_resource `env`, lines 24–29 |
| F-11 | Consistent | Both hydrant materials leave `paint_tint`, `normal_strength` and `uv_scale` unset; `get_shader_parameter()` returns `null` for them and the shader default applies. Editing one of those defaults in the shader changes both hydrants, which is what C4 wants. The flip side: a test cannot read the effective value from the material, only from the source text. | test output `material-values` rows (`paint_tint: null`, etc.) |

Nothing was found that is wrong. F-2 and F-7 are the only waste, both small; F-4 is the one thing that needs eyes.

## 5. Attribution

Facts as recorded in CHANGE-BRIEF.md C2 (checked by the author of the brief, not re-verified here):

- **Source:** Poly Haven, asset **Rusty Metal Sheet** (`rusty_metal_sheet`), author **Amal Kumar**, URL `https://polyhaven.com/a/rusty_metal_sheet`, date checked **2026-10-28**.
- **Licence:** **CC0** (no credit required; the course requires provenance anyway).
- **Files:** 1K PNG, in `godot/art/textures/rusty_metal_sheet/` with `ATTRIBUTION.md` beside them: `rusty_metal_sheet_diff_1k.png` (base colour), `rusty_metal_sheet_rough_1k.png` (roughness), `rusty_metal_sheet_nor_gl_1k.png` (OpenGL normal map, the one Godot expects and the one bound), `rusty_metal_sheet_nor_dx_1k.png` (DirectX twin, downloaded only for the curl-check calibration and bound to no material).
- `art/hint/grey_3x1.png` is generated by `godot/tests/write_grey_strip.gd` (greys 64, 128, 192); no external source.

## 6. What the test cannot establish headlessly

- Any pixel: the tint, the rust blend, the roughness difference between the two hydrants, the bump direction, and the hint-experiment bands. The dummy renderer draws nothing.
- Whether `source_color` on `albedo_tex` and `paint_tint` actually linearises under GL Compatibility, and whether `ROUGHNESS > 1.0` is clamped (F-4). Only a capture or the editor shows that.
- Whether the normal map's bumps lean the right way on screen. The curl ratio (0.54 as GL, 1.46 as DX for the bound file) is evidence about the file's convention, not about the rendered result.
- The 16-bit depth of the source PNGs (F-6): Godot loads them as 8-bit, so the test sees only 8-bit data.
- That `set_shader_parameter` names match the shader: it stores anything. The test instead checks the names written in each `.tres` against the engine's uniform list, which does catch a renamed uniform.
