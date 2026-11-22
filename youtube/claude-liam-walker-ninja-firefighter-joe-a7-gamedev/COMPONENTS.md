# COMPONENTS

Godot project components covered by the film (`godot/`, hashed in gamedev-evidence.json).

## survivor-wave

The cycle, the person survivor's wave: the cutout rig rebuilt from the session's old drawing as Polygon2D parts, the Shoulder pivot and its wave clip keyed as resource text; session.gd, which places the rig once, hides it on rescue and shows it on restart; and the wave viewing fixture.

Files (4): `features/survivor/survivor_person.tscn`, `game/session.gd`, `previews/wave_preview.gd`, `previews/wave_preview.tscn`

Beats: B04, B05, B02

## toss-sheet

The committing action, Joe's survivor toss: the sheet packed from the A2 poses (with its import settings and credits), Joe's art scene with the sliced Sprite and the manual-callback AnimationPlayer, the clip library baked from the phase table, the player's state machine that plays one clip per state and advances it on the physics tick, and the frame-strip fixture.

Files (9): `animations/joe.tres`, `art/character/ATTRIBUTION.md`, `art/character/joe_sheet.png`, `art/character/joe_sheet.png.import`, `features/player/joe_art.tscn`, `features/player/player.gd`, `previews/toss_preview.gd`, `previews/toss_preview.tscn`, `tools/bake_joe_clips.gd`

Beats: B06, B07, B08, B09, B12, B13, B14, B15

## a7-tests

The A7 tests: the shared read-back helper (track_problems), both read-backs, the Step 2 pins, the structure and state test, the phase-boundary edge test, and the headless probe.

Files (7): `tests/anim_checks.gd`, `tests/probe_a7_headless.gd`, `tests/test_anim_states.gd`, `tests/test_pins_a7.gd`, `tests/test_toss_edges.gd`, `tests/test_toss_readback.gd`, `tests/test_wave_readback.gd`

Beats: B10, B11, B16, B17

## earlier-layers

The game this layer is added to: the A2 2D game (level, HUD, generated art and audio, its tests and project settings), the A3 props room, the A5 shaders and materials, and the A6 particle effects with their drivers, previews and tests; unchanged in A7 except player.gd and session.gd, which belong to the components above.

Files (121): `MATERIALS.md`, `art/character/anchors.json`, `art/character/burned.png`, `art/character/burned.png.import`, `art/character/celebrate.png`, `art/character/celebrate.png.import`, `art/character/celebrate_portrait.png`, `art/character/celebrate_portrait.png.import`, `art/character/devastated_portrait.png`, `art/character/devastated_portrait.png.import`, `art/character/falling.png`, `art/character/falling.png.import` …

Beats: B02, B05

