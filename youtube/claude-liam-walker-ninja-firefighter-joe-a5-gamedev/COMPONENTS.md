# COMPONENTS

Godot project components covered by the film (`godot/`, hashed in gamedev-evidence.json).

## hose-glow

The shader from code: the hand-written canvas_item glow shader on Extinguisho's sprite, the agent-written driver that sets its uniform from player.hosing, its headless test at three frame rates, and the in-engine capture script.

Files (4): `features/player/hose_glow.gd`, `shaders/hose_glow.gdshader`, `tests/capture_glow.gd`, `tests/test_hose_glow.gd`

Beats: B04, B05, B06, B07, B15

## textured-hydrant

The textured spatial shader and its two materials on the hydrant, the Poly Haven textures with their credits and explicit import settings, the materials audit, its headless test, the normal-map curl check and calibration, and the sweep capture script.

Files (17): `MATERIALS.md`, `art/textures/rusty_metal_sheet/ATTRIBUTION.md`, `art/textures/rusty_metal_sheet/rusty_metal_sheet_diff_1k.png`, `art/textures/rusty_metal_sheet/rusty_metal_sheet_diff_1k.png.import`, `art/textures/rusty_metal_sheet/rusty_metal_sheet_nor_dx_1k.png`, `art/textures/rusty_metal_sheet/rusty_metal_sheet_nor_dx_1k.png.import`, `art/textures/rusty_metal_sheet/rusty_metal_sheet_nor_gl_1k.png`, `art/textures/rusty_metal_sheet/rusty_metal_sheet_nor_gl_1k.png.import`, `art/textures/rusty_metal_sheet/rusty_metal_sheet_rough_1k.png`, `art/textures/rusty_metal_sheet/rusty_metal_sheet_rough_1k.png.import`, `materials/hydrant_fresh.tres`, `materials/hydrant_rusty.tres` …

Beats: B08, B09, B10, B11, B15

## hint-experiment

The hint experiment: the script that writes the 3×1 grey strip, its lossless import, the unshaded shader with two samplers of that file, the two materials and the scene with a Linear tonemap at exposure 1.0, and the capture script.

Files (8): `art/hint/grey_3x1.png`, `art/hint/grey_3x1.png.import`, `materials/hint_as_color.tres`, `materials/hint_as_data.tres`, `scenes3d/hint_experiment.tscn`, `shaders/hint_experiment.gdshader`, `tests/capture_hint.gd`, `tests/write_grey_strip.gd`

Beats: B12, B13

## generated-shader

Godot's own shader, converted in the editor from a StandardMaterial3D with the three rusty-metal textures, and the scratch scene it was made in; nothing in the game uses either.

Files (2): `scenes3d/scratch_standard.tscn`, `shaders/standard_generated.gdshader`

Beats: B14

## props-room

The Assignment 3 props (hydrant, rescue backpack, flame as binary glTF with import settings; the hydrant's import now binds hydrant_fresh.tres through Use External) and the props room scene with its sun and environment, now holding the second hydrant instance.

Files (10): `props3d/flame.glb`, `props3d/flame.glb.import`, `props3d/hydrant.glb`, `props3d/hydrant.glb.import`, `props3d/rescue_bag.glb`, `props3d/rescue_bag.glb.import`, `scenes3d/props_room.tscn`, `tests/capture_props.gd`, `tests/check_props.gd`, `tests/run_check_props.sh`

Beats: B02, B11

## a2-game

The Assignment 2 game this layer is added to (2D player and its hosing state, session, level, HUD, generated art and audio, its tests and project settings); unchanged in A5 except the two-line hook that adds the glow driver to the player.

Files (61): `art/character/anchors.json`, `art/character/burned.png`, `art/character/burned.png.import`, `art/character/celebrate.png`, `art/character/celebrate.png.import`, `art/character/celebrate_portrait.png`, `art/character/celebrate_portrait.png.import`, `art/character/devastated_portrait.png`, `art/character/devastated_portrait.png.import`, `art/character/falling.png`, `art/character/falling.png.import`, `art/character/grab.png` …

Beats: B02, B07

