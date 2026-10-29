# FACTCHECK

Every claim narrated, with its source in the repository at revision `e8c2a30`. Checked by Claude Code against the files; the final film is reviewed by Sreeja.

| Claim | Source |
|---|---|
| Godot 4.7.2, GL Compatibility renderer | `a5/TEST-REPORT.md` header; `godot/project.godot` `renderer/rendering_method="gl_compatibility"` |
| the state is `player.hosing`, written by `session.gd` every physics tick while `water_ticks > 0` | `godot/game/session.gd` (`player.hosing = water_ticks > 0`); CHANGE-BRIEF A1 |
| the 3D object is the A3 hydrant in the props room | CHANGE-BRIEF C1; `godot/scenes3d/props_room.tscn` |
| brief committed before any shader or prompt (2026-10-28) | CHANGE-BRIEF header; `a5/TEST-REPORT.md` baseline revision `c9cd749` → brief → shader `5775582` |
| the colour line, two uniforms with type / hint / default | CHANGE-BRIEF A2; `godot/shaders/hose_glow.gdshader` lines 3, 4, 7 |
| 0.25 s ramps, same game time at 30 / 60 / 144, retrigger ignored, fade from current value | CHANGE-BRIEF A3 rules R3, R4, R5, R7 |
| evidence split per rule (test or eyes) | CHANGE-BRIEF A3 "Evidence split" table |
| "Sreeja typed these eight lines herself" | `a5/FRICTIONAL.md` "Typing the shaders"; `a5/SOURCES.md` Shaders table |
| captures match within a few levels; largest difference 2 levels at P1 / P2 | `a5/TEST-REPORT.md` Controlled values table |
| glow 2.0 from code reads back 2.0 and overshoots to cyan; `hint_range` does not clamp | `a5/TEST-REPORT.md` Controlled values; `capture_glow_output.jsonl` `uniform_readback` |
| driver: one material per player, on the sprite only; bag stays orange | `godot/features/player/hose_glow.gd` `_ready`; TEST-REPORT F5 bag capture (230, 126, 34) |
| target 0 or a breath between 0.4 and 0.8; `move_toward` by delta / 0.25 | `hose_glow.gd` lines 28–35 (`BREATH_CENTRE 0.6 ± 0.2`, `RAMP_SECONDS 0.25`) |
| driver never writes game state | `hose_glow.gd` header; CHANGE-BRIEF A3 Boundaries |
| Movie Maker, scripted key presses, labelled | `CAPTURE.md`; `capture/film_capture.gd`; the on-screen plate |
| breath about once a second, suit visible at the low end | `BREATH_PERIOD 1.0`; TEST-REPORT Revision 3 table (period 1.0 s; band 0.400 / 0.800); her words "the blue breathes" |
| quarter-second fade when the water stops | TEST-REPORT Revision 3 `hold-is-game-time` (down ramp ≤ 0.25 s) |
| movement, jumps, fires, timings untouched | TEST-REPORT "In play" Boundaries; existing suites unchanged (41/41, 14/14, 12/14 pinned audio, props PASS) |
| "a block of ice blue" (her words); Revision 3 changed the driver's number, not the shader | `a5/TEST-REPORT.md` Controlled values "What I saw"; CHANGE-BRIEF Revision 3 ("The shader and the colour line are unchanged") |
| Poly Haven, CC0, Amal Kumar, credits file beside the textures | `godot/art/textures/rusty_metal_sheet/ATTRIBUTION.md`; `a5/SOURCES.md` |
| import settings set explicitly, not left on Detect; the OpenGL normal map | TEST-REPORT "Import settings and texture data"; `.import` files; `MATERIALS.md` §2 |
| line 3 `source_color`; lines 4 and 5 without; five dials in two groups | `godot/shaders/hydrant_surface.gdshader` lines 3–16 |
| sweep: rust 0 → (99, 29, 21), 1 → (133, 131, 113); uv 0.25 smear / 8 fine tile; roughness and normal 1–3 levels | TEST-REPORT sweep table and "Interface sweep" |
| "no difference I could see" (her words) | TEST-REPORT "What I saw (my words, 2026-10-29)" |
| two materials: fresh rust 0.1 / roughness 0.7, rusty 0.9 / 1.4; Use External and surface override | `godot/materials/hydrant_fresh.tres`, `hydrant_rusty.tres`; `MATERIALS.md` §1 |
| edit one value → one hydrant changes; edit one shader line → both change | TEST-REPORT `material_edit_rust_0`, `shader_edited` rows |
| "the first hydrant looks very realistic … the second looks more like a cartoon" (her words) | TEST-REPORT "What I saw (my words, 2026-10-29)" |
| grey strip 64 / 128 / 192 by a committed script, lossless, no mipmaps | `godot/tests/write_grey_strip.gd`; `art/hint/grey_3x1.png.import`; TEST-REPORT |
| two samplers of one file, bool picks the one that writes ALBEDO; unshaded quads; Linear tonemap, exposure 1.0 | `godot/shaders/hint_experiment.gdshader`; `scenes3d/hint_experiment.tscn`; `MATERIALS.md` §3 |
| predicted data quad 137 / 188 / 225 (Forward+); measured both quads 64 / 128 / 192 | CHANGE-BRIEF Part B; TEST-REPORT "Hint experiment" |
| Compatibility shades 3D in sRGB space, no decode / encode | TEST-REPORT "Explanation (after measuring)"; CHANGE-BRIEF F10 |
| Godot wrote `standard_generated.gdshader` from a StandardMaterial3D converted in the editor | `a5/LANGUAGE-NOTES.md` header; commit `0290c4b` |
| generated line 7 `source_color` ↔ hers line 3; generated line 19 `hint_roughness_normal` ↔ hers line 5 | `godot/shaders/standard_generated.gdshader`; `a5/STANDARD-GENERATED-ANNOTATED.md` |
| glow test: real input events, sampler after everything else, 15 checks at 30 / 60 / 144 | `godot/tests/test_hose_glow.gd` (`parse_input_event`, `process_priority = 100`); `logs/test_hose_glow_*fps.log` |
| material test after an audit she reviewed; passes from an empty cache | `MATERIALS.md` header; TEST-REPORT "Material wiring" (`test_materials_fresh_cache_60fps.log` 35 / 0) |
| three mutations exit 1 | `a5/evidence/mutations/mutation-1-semicolon`, `mutation-2-rename`, `mutation-3-source_color` logs; TEST-REPORT |
| capture script sampled sky twice | `a5/FRICTIONAL.md` "Controlled-value captures: two false starts" |
| audit claimed a conversion the renderer never performs; memory figures nobody measured; both corrected | `MATERIALS.md` F-5, F-7 review notes; TEST-REPORT "Review of the audit" |
| the brief's pause rule unattainable; revision four records it | CHANGE-BRIEF Revision 4; TEST-REPORT Revision 3 "Finding" |
| shader folder diff empty after every session | TEST-REPORT ("`git diff --stat godot/shaders/` empty"); `a5/SOURCES.md` |
| uncertain: ROUGHNESS > 1 clamped?; source_color uniform under Compatibility? | `MATERIALS.md` F-4, F-5 |
| next step "a better hydrant mesh" (her words) | TEST-REPORT "Irrespective I think we need to improve the structure of the hydrant" |
| contributions split | `a5/FRICTIONAL.md` "Human / AI contributions"; `a5/SOURCES.md` |

The gamedev checker (`./art godot-gamedev --check`) covers file hashes, inventory, the four code excerpts and their result media; it does not judge whether the explanation is true or the visuals good.
