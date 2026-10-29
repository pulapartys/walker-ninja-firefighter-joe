# `standard_generated.gdshader`, annotated

> Annotations written by Claude Code at my request, from the file as Godot wrote it, and reviewed by me; I can explain every line (recorded in FRICTIONAL.md). The source file `godot/shaders/standard_generated.gdshader` is unchanged: it is Godot 4.7.2's own output from converting a StandardMaterial3D (albedo texture, normal map, roughness texture; scene `godot/scenes3d/scratch_standard.tscn`). Nothing in the game uses it. Where a line has an equivalent in one of my shaders, the annotation names it. My line numbers in `LANGUAGE-NOTES.md` section 1 point into this same file.

Line numbers are the file's own. Blank lines are omitted.

| Line | As written | What it does, and my equivalent |
|---|---|---|
| 1 | `// NOTE: Shader automatically converted from Godot Engine 4.7.2.stable's StandardMaterial3D.` | Godot's provenance comment. Everything below is what the Inspector's checkboxes expand to. |
| 3 | `shader_type spatial;` | 3D shader, so `ALBEDO`, `ROUGHNESS`, `NORMAL_MAP` and the lighting pipeline exist. Same as `hydrant_surface.gdshader` line 1 and `hint_experiment.gdshader` line 1; my 2D shader uses `canvas_item` instead (`hose_glow.gdshader` line 1). |
| 4 | `render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;` | The Inspector's Transparency, Depth Draw, Cull and Shading settings written out: normal alpha blend, write depth for opaque pixels, skip back faces, Burley diffuse, GGX specular. I wrote no `render_mode` on the hydrant (these are the defaults) and `unshaded` on the hint experiment (`hint_experiment.gdshader` line 2) so lighting could not touch the measurement. |
| 6 | `uniform vec4 albedo : source_color;` | The Inspector's Albedo > Color swatch. `source_color` gives it a colour picker and, on a Forward+/Mobile renderer, decodes sRGB to linear before the shader sees it. My equivalent is `paint_tint` (`hydrant_surface.gdshader` line 8). |
| 7 | `uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;` | The Albedo > Texture slot. `source_color` marks the texels as colour to be decoded; the other two hints set filtering and wrapping. My equivalent is `albedo_tex` (`hydrant_surface.gdshader` line 3), which has `source_color` and `filter_linear_mipmap` but no `repeat_enable` (I rely on the default). |
| 8 | `uniform ivec2 albedo_texture_size;` | Pixel size of the albedo texture, used only by the pixel-snap option that is off here. Unused in this file; no equivalent in mine. |
| 9 | `uniform float point_size : hint_range(0.1, 128.0, 0.1);` | Point size for point-cloud rendering. Unused here; Godot emits it regardless. |
| 11 | `uniform float roughness : hint_range(0.0, 1.0);` | The Roughness slider, a multiplier on the texture. My equivalent is `roughness_scale` (`hydrant_surface.gdshader` line 13), which I let go to 2.0. |
| 12 | `uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;` | Metallic texture slot. `hint_default_white` means an unbound sampler reads as 1.0, so the `metallic` slider alone controls it. I used the same hint on `rough_tex` (`hydrant_surface.gdshader` line 4) for the same reason. |
| 13 | `uniform vec4 metallic_texture_channel;` | Which channel of the metallic texture to read, as a mask vector used with `dot()` on line 37. No equivalent in mine; I read `.r` directly. |
| 14 | `uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;` | The Roughness > Texture slot. `hint_roughness_r` says "data, red channel, roughness" so the importer can generate roughness-aware mipmaps; it is not `source_color`, so the numbers are read as stored. My equivalent is `rough_tex` (`hydrant_surface.gdshader` line 4), sampled as data with `hint_default_white` instead. |
| 16 | `uniform float specular : hint_range(0.0, 1.0, 0.01);` | Specular slider, the third number in the hint is the Inspector step. No equivalent in mine. |
| 17 | `uniform float metallic : hint_range(0.0, 1.0, 0.01);` | Metallic slider. No equivalent in mine. |
| 19 | `uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;` | The Normal Map > Texture slot. Godot names the hint `hint_roughness_normal` here, not `hint_normal`; both say "this is a normal map, read it as data, do not decode sRGB". My equivalent is `normal_tex : hint_normal` (`hydrant_surface.gdshader` line 5). |
| 20 | `uniform float normal_scale : hint_range(-16.0, 16.0);` | The Inspector's Normal Map > Scale slider, the strength of the bump. Negative inverts it. My equivalent is `normal_strength` (`hydrant_surface.gdshader` line 14), range 0 to 2. |
| 22–25 | `uniform vec3 uv1_scale;` … `uniform vec3 uv2_offset;` | The UV1 and UV2 transform settings. Only `uv1_*` is used, on line 28. My equivalent is the single `uv_scale` (`hydrant_surface.gdshader` line 15), applied in `fragment()` on line 19 instead of in `vertex()`. |
| 27–29 | `void vertex() { UV = UV * uv1_scale.xy + uv1_offset.xy; }` | Runs once per vertex. Scales and offsets the mesh's UVs before interpolation to the pixels. I wrote no `vertex()`; my `uv` scaling happens per pixel on `hydrant_surface.gdshader` line 19, same result for a plain scale. |
| 31–32 | `void fragment() { vec2 base_uv = UV;` | Runs once per pixel. Copies the interpolated UV, already transformed by `vertex()`. |
| 34 | `vec4 albedo_tex = texture(texture_albedo, base_uv);` | Sample the albedo as colour (because of line 7's hint). Mine: `hydrant_surface.gdshader` line 20. |
| 35 | `ALBEDO = albedo.rgb * albedo_tex.rgb;` | Base colour = swatch × texture. Mine: line 21, where the tint is applied through `mix()` by `rust_amount` instead of a plain multiply. |
| 37 | `float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);` | Pick one channel of the metallic texture with a dot product against the channel mask. With no texture bound, `hint_default_white` makes this 1.0 × the chosen channel. |
| 38 | `METALLIC = metallic_tex * metallic;` | Metallic output. I never write `METALLIC`, so mine stays at its default 0. |
| 39 | `SPECULAR = specular;` | Specular output. Not written in mine. |
| 41 | `vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);` | A constant mask: read the red channel of the roughness texture. The Inspector's Texture Channel setting, baked in. |
| 42 | `float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);` | Sample the roughness texture as data and take red. Mine is `texture(rough_tex, uv).r` on `hydrant_surface.gdshader` line 22, the same thing without the dot product. |
| 43 | `ROUGHNESS = roughness_tex * roughness;` | Roughness output = texture × slider. Mine: line 22, `× roughness_scale`. |
| 45 | `// Normal Map: Enabled` | Godot's marker that the Normal Map checkbox was on when it converted. |
| 46 | `NORMAL_MAP = texture(texture_normal, base_uv).rgb;` | Sample the normal map as data and hand it to the lighting pipeline, which decodes the 0–1 range to −1–1 itself. Mine: `hydrant_surface.gdshader` line 23. |
| 47 | `NORMAL_MAP_DEPTH = normal_scale;` | Bump strength from the slider. Mine: line 24, from `normal_strength`. |
| 48 | `}` | End of `fragment()`. |

## What the comparison shows

- Godot's file is the Inspector expanded: every slider and slot is a uniform with a hint, and every checkbox that was on produces a block in `fragment()`.
- Colour versus data is decided entirely by the sampler's hint: line 7 has `source_color`, lines 14 and 19 do not. My textured shader makes the same split on lines 3 and 5.
- The generated file does in `vertex()` what mine does in `fragment()` for UV scale. For a uniform scale the result is the same; the generated approach costs less because it runs per vertex, not per pixel.
