# LANGUAGE-NOTES — Assignment 5, Step 4

> The answers in section 2 are mine, pasted in word for word from what I typed in chat. Claude Code filled the line-number table in section 1 from the generated file, added the _Lines:_ note under each answer, and checked that every reference points where it says (recorded in FRICTIONAL.md). The generated file is `godot/shaders/standard_generated.gdshader` (48 lines, Godot 4.7.2, converted from a StandardMaterial3D with an albedo texture, a normal map and a roughness texture, scene `godot/scenes3d/scratch_standard.tscn`). My three shaders: `godot/shaders/hose_glow.gdshader`, `godot/shaders/hint_experiment.gdshader`, `godot/shaders/hydrant_surface.gdshader`.

## 1. Line numbers in `standard_generated.gdshader`

| What | Line(s) | The line, as written |
|---|---|---|
| `shader_type` | 3 | `shader_type spatial;` |
| `render_mode` | 4 | `render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;` |
| uniform for the Inspector's albedo colour | 6 | `uniform vec4 albedo : source_color;` |
| uniform for the Inspector's normal-map strength | 20 | `uniform float normal_scale : hint_range(-16.0, 16.0);` (the Inspector calls it Scale under Normal Map) |
| albedo sampler, with its hints | 7 | `uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;` |
| normal-map sampler, with its hints | 19 | `uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;` |
| the line that writes `ALBEDO` | 35 | `ALBEDO = albedo.rgb * albedo_tex.rgb;` |
| the line that writes `ROUGHNESS` | 43 | `ROUGHNESS = roughness_tex * roughness;` |
| the line that writes `NORMAL_MAP` | 46 | `NORMAL_MAP = texture(texture_normal, base_uv).rgb;` |

## 2. Questions, in my own words, each with a line reference to one of my three shaders

### Q1. What does `shader_type` decide? (answer for each type I used, citing the first line of each shader)

It tells Godot whether the shader is for 2D or 3D and what things it can use.

- canvas_item is for 2D, so we use COLOR.
- spatial is for 3D, so we use things like ALBEDO, ROUGHNESS, and NORMAL_MAP for colours, textures, and lighting.

_Lines: `hose_glow.gdshader` line 1 (`canvas_item`); `hint_experiment.gdshader` line 1 and `hydrant_surface.gdshader` line 1 (`spatial`)._

### Q2. Which processor functions did I write, and when does each run? What would change if I moved my colour line into `vertex()`, and why?

- fragment() runs for every pixel, so it gives more detailed effects.
- vertex() runs for every corner of the shape.

I used fragment() in all three shaders. If I used vertex() for the glow instead, the colour would be calculated at the corners and blended across the shape, so it wouldn't look as detailed.

_Lines: `fragment()` at `hose_glow.gdshader` line 6, `hint_experiment.gdshader` line 7, `hydrant_surface.gdshader` line 18; the colour line is `hose_glow.gdshader` line 7._

### Q3. Three built-ins I read and two I wrote. Which of the ones I read are read-only?

- Read: COLOR and UV. I used them to get the existing colour and texture position.
- Wrote: COLOR, ALBEDO, ROUGHNESS, NORMAL_MAP, and NORMAL_MAP_DEPTH to change how things look.
- UV is read-only in fragment(), but COLOR can be both read and changed in a 2D shader.

_Lines: `COLOR` read and written at `hose_glow.gdshader` line 7; `UV` read at `hint_experiment.gdshader` line 9 and `hydrant_surface.gdshader` line 19; `ALBEDO` written at `hydrant_surface.gdshader` line 21, `ROUGHNESS` line 22, `NORMAL_MAP` line 23, `NORMAL_MAP_DEPTH` line 24._

### Q4. For each hint I used: does it change only the Inspector, or also the value the shader receives? (cite the hint experiment)

It depends on the hint.

- hint_range just adds a slider in the Inspector.
- source_color adds a colour picker and can affect how colours are handled, but it didn't change my results with the Compatibility renderer.
- hint_default_white, hint_normal, and texture filtering hints can actually affect what values the shader receives.

_Lines: `hint_range` at `hose_glow.gdshader` line 3 and `hydrant_surface.gdshader` lines 9, 13–15; `source_color` on a colour at `hose_glow.gdshader` line 4 and `hydrant_surface.gdshader` line 8; the hint experiment is `hint_experiment.gdshader` line 3 (`source_color`) against line 4 (no hint), measured in `a5/TEST-REPORT.md`; `hint_default_white` at `hydrant_surface.gdshader` line 4, `hint_normal` line 5, `filter_nearest` at `hint_experiment.gdshader` lines 3–4, `filter_linear_mipmap` at `hydrant_surface.gdshader` lines 3–5._

### Q5. Does `hint_range` clamp a value set from code? (cite what I observed)

No. It only limits the Inspector slider, not values set through code.

I tested setting the glow to 2.0 through code, and it still worked even though it was outside the slider range.

_Lines: `hose_glow.gdshader` line 3; the observation is the glow 2.0 capture in `a5/TEST-REPORT.md` (`a5/evidence/captures/glow_2.0.png`, uniform readback 2.0)._

### Q6. Which line of the generated shader makes the albedo sample as colour and the normal map as data, and what is the equivalent line in my textured shader?

Colour textures use source_color because they're meant to show actual colours.

Normal maps use hint_normal because they store information about how light should hit the surface, not regular colours.

_Lines: generated file line 7 (`texture_albedo : source_color`) against line 19 (`texture_normal : hint_roughness_normal`, no `source_color`); mine are `hydrant_surface.gdshader` line 3 (`albedo_tex : source_color`) against line 5 (`normal_tex : hint_normal`)._

### Q7. My `fragment()` runs for every pixel at once. Why can't it read what the neighbouring pixel's `fragment()` is computing, and how does game state reach it instead?

Because all the pixels are being processed separately, so one pixel doesn't know what the other pixel is doing.

If we want to pass information into the shader, we use a uniform. For example, my script sends the glow value to the shader through a uniform.

_Lines: the uniform is `hose_glow.gdshader` line 3; the driver that sets it each frame is `godot/features/player/hose_glow.gd` (see TEST-REPORT)._

### Q8. Two things the Godot shading language provides that plain GLSL does not, or makes you write yourself.

Two things are:

1. Built-in outputs: Godot gives us things like ALBEDO and ROUGHNESS, so we don't have to write all the lighting calculations ourselves.
2. Hints: We can use things like hint_range and source_color to get sliders and colour pickers directly in the Inspector.

_Lines: `ALBEDO` and `ROUGHNESS` at `hydrant_surface.gdshader` lines 21–22; `hint_range` at line 9 and `source_color` at line 8 of the same file._
