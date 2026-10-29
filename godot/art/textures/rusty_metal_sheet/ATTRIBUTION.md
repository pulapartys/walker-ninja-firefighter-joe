# Texture credits — rusty_metal_sheet

Provenance for every file in this folder (Assignment 5, "Rights and provenance"). Poly Haven's CC0 licence requires no credit; the course requires provenance anyway.

| Field | Value |
|---|---|
| Asset | **Rusty Metal Sheet** (`rusty_metal_sheet`) |
| Source URL | https://polyhaven.com/a/rusty_metal_sheet |
| Author and role | Amal Kumar — creator (texture capture and processing), as listed on the asset page |
| Licence | **CC0 1.0** (public domain dedication), per the asset page and https://polyhaven.com/license |
| Date checked | 2026-10-28 |
| Resolution and format downloaded | 1K (1024 × 1024), PNG, 16-bit per channel as shipped |
| Download URL pattern | `https://dl.polyhaven.org/file/ph-assets/Textures/png/1k/rusty_metal_sheet/rusty_metal_sheet_<map>_1k.png` |

| File | Map | Role in this project | Sampled as |
|---|---|---|---|
| `rusty_metal_sheet_diff_1k.png` | diffuse / base colour | colour of the painted, rusting steel | colour (`source_color`) |
| `rusty_metal_sheet_rough_1k.png` | roughness | 0 = mirror, 1 = matte | data (no `source_color`) |
| `rusty_metal_sheet_nor_gl_1k.png` | normal map, **OpenGL** green convention | surface slope, the one Godot expects; this is the file bound to the material | data (`hint_normal`) |
| `rusty_metal_sheet_nor_dx_1k.png` | normal map, DirectX green convention | **calibration only** for `godot/tests/normal_map_check.gd`; bound to no material | not sampled |

Downloaded by `curl` on 2026-10-28 (the same four URLs as the pattern above); no edits to the files. Import settings are set explicitly in each `.import` file (see `godot/MATERIALS.md` and CHANGE-BRIEF C2).
