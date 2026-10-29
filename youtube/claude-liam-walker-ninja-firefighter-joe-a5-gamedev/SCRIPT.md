# Extinguisho's Hand-Written Shaders

Final narration as voiced by Liam (Kokoro am_onyx), generated from beat_sheet.json. Script v4 (the 5½-minute cut, plain voice), drafted by Claude Code from the A5 record and approved by Sreeja (SCRIPT-DRAFT.md).

## B00 — The prompt

Please use Walker to turn my firefighter game's hosing state into a glow on the character, and give its hydrant a real surface. This is Liam, in for Bear. Assignment Five for C S Y E seventy-two seventy.

## B01 — What was built

Two hand-written shaders for a two-D Godot game. The idea underneath: a texture is not a picture the shader shows. It is a table of numbers the shader reads, and one word on the sampler decides whether those numbers are colour or data.

## B02 — The game, the state, the object

Extinguisho is Sreeja's deadpan ninja firefighter, Godot four point seven, Compatibility renderer. One state drives the effect: player dot hosing, true while the water runs on the fire that blocks the first survivor. The shader only reads it. The three-D object is the Assignment Three hydrant in the props room, because the game itself is two-D.

## B03 — The brief came first

Before any shader or any prompt, Sreeja committed a brief. It names the one line of shading language that makes the effect, two uniforms with type, hint and default, and rules a test can measure: a quarter-second ramp at any frame rate, a second W ignored, a fade from wherever the value is. Each rule says whether a test or her eyes will check it.

## B04 — What a shader is

A shader is a small program the G P U runs for every pixel at once, and it remembers nothing between pixels. Sreeja typed these eight lines herself. Line three declares a dial called glow, with a range and a default. Line seven is the whole effect: slide this pixel's colour toward pale blue by however far the dial is turned. Alpha is untouched, so his outline keeps its shape.

## B05 — The colour line, measured

From that one line, the brief worked out by hand what three named pixels should become. The engine captures, read from the viewport rather than screenshots, match within a few levels. Then glow set to two from code: the pixels overshoot to cyan. The range hint shapes the Inspector slider; it does not clamp what the game sets.

## B06 — The driver

Claude Code wrote the driver, with the shader folder locked. One material per player, on the sprite only, so the rescue bag on his back stays orange. Each frame it reads hosing and picks a target: zero, or a gentle breath between point four and point eight, then moves toward it by the frame's delta, so the ramp takes the same game time at any frame rate. It never writes game state.

## B07 — In play, and her revision

The running game, recorded by Movie Maker with scripted key presses, labelled as such. W at the fire: the water starts and he brightens into a pale blue breath, the suit still visible at the low end. When the water stops, a quarter-second fade. The breath is her revision: at a held full glow she called him a block of ice blue, so revision three changed the number the game feeds the dial. The shader did not change.

## B08 — Textures as information

Three textures from Poly Haven, C C zero, by Amal Kumar, with source, licence and date in a credits file beside them. The colour map is a photo of rusting steel. The roughness map and the normal map look like pictures too, but they are tables: how matte each spot is, which way it slopes. Import settings set by hand, not left on Detect, and the OpenGL normal map, the convention Godot expects.

## B09 — The textured shader

Her spatial shader. Line three samples the photo as colour, with source colour. Lines four and five have no such hint: the roughness and normal maps are read exactly as stored. That one word is the difference between a picture and information. Below, five dials with ranges and defaults in two Inspector groups, paint and surface; the fragment function below them mixes paint and rust and hands roughness and normal to Godot's lighting.

## B10 — The interface sweep

Every dial at its minimum, default and maximum, captured in the engine under the scene's single sun. Rust amount walks the body from painted red to the raw photo. U V scale goes from one big smear to a fine tile. Roughness and bump strength barely moved the sampled pixel, and by eye she saw no difference: wired, the test shows that, but this lighting does not show them. Recorded as found.

## B11 — Two materials, one shader

Here is how a material differs from a shader. One shader; two resource files, each holding its own dial values and textures. Fresh is mostly paint and slightly glossy; rusty is mostly photo and matte. Edit one value in one file: one hydrant changes. Edit one line of the shader: both change. Her verdict: the rusty one reads real, the red one reads cartoon.

## B12 — The hint experiment

The experiment, in its own scene. A committed script writes a three-pixel grey strip. Two samplers bind that same file, one marked as colour, one not, and a switch picks which paints the quad. Two unshaded quads, a linear tonemap at exposure one. The brief predicted the data quad would come out lighter, if the renderer does its maths in linear light.

## B13 — Predicted, measured

Measured: the two quads are identical. The prediction assumed Forward Plus. This project runs Compatibility, which shades in s R G B space: nothing is decoded going in or encoded coming out, so the hint changes nothing on screen here. The brief had this down as a predicted failure case: measure first, then explain.

## B14 — Godot's own shader

Godot can write a shader from a Standard Material; Sreeja converted one in the editor. Line seven: the albedo sampler, marked as colour, her line three. Line nineteen: the normal sampler, marked as data under a different hint name, her line five. This is what the Godot shading language is: G L S L with a shader type instead of main, named outputs like albedo and roughness, and hints that shape the Inspector.

## B15 — What the tests proved

The glow test presses W and R as real input and samples the dial every frame; fifteen checks at thirty, sixty and one forty-four. The material test, written after an audit she reviewed, pins shader paths, sampler hints and import settings, and passes from an empty cache. Three sabotages: a deleted semicolon, a renamed uniform, source colour removed. All three exit one. Proven: parse, names, timing, wiring. Not proven: a single pixel.

## B16 — What Claude got wrong

The agent's mistakes, caught in review. The capture script sampled sky twice. The audit claimed a colour conversion this renderer never performs, and quoted memory figures nobody measured; both corrected. The brief's own pause rule turned out unattainable; the test showed it, revision four says so. After every session, the shader folder's diff was empty.

## B17 — Verdict

The verdict. Verified: three hand-typed shaders parse and match their spec; the pixel predictions hold; the driver at three frame rates through real events; three mutations fail; the materials survive a reimport. Uncertain: whether roughness above one is clamped, and whether a source-colour uniform converts under Compatibility. Next, in her words: a better hydrant mesh. Sreeja specified, typed, looked and decided; Claude Code drafted, drove, tested and audited. Source revision on screen.

## B18 — Your turn

Your turn. Read my change brief. The roughness and normal-strength sliders showed nothing under one sun. Plan a second light for the props room, predict which hydrant pixel changes most, and name the assertion in test materials that must not change. One bounded change, one prediction, one test kept honest. This has been Liam, in for Bear.

## B19 — Outro

Extinguisho's Hand-Written Shaders. At Nik Bear Brown.

