# COMPONENTS

Godot project components covered by the film (`godot/`, hashed in gamedev-evidence.json).

## props

The three props exported from Blender as binary glTF (+Y Up, transforms applied), with Godot's import settings: hydrant, rescue backpack, flame.

Files (6): `props3d/flame.glb`, `props3d/flame.glb.import`, `props3d/hydrant.glb`, `props3d/hydrant.glb.import`, `props3d/rescue_bag.glb`, `props3d/rescue_bag.glb.import`

Beats: B07, B09, B12

## props-scene

The 3D props scene: floor, one sun with shadows, camera, the three props placed by translation only, and a 1.8 m size-reference pole.

Files (1): `scenes3d/props_room.tscn`

Beats: B11, B12

## prop-check

The headless prop check (global AABB vs brief, scale chain, up axis, bottom vs floor, triangles), its strict runner that requires a printed PASS, and the screenshot capture.

Files (3): `tests/capture_props.gd`, `tests/check_props.gd`, `tests/run_check_props.sh`

Beats: B13, B14

## a2-game

The Assignment 2 game this layer is added to (2D player, generated art and audio, session, level, HUD, its tests and project settings); unchanged in A3.

Files (61): `art/character/anchors.json`, `art/character/burned.png`, `art/character/burned.png.import`, `art/character/celebrate.png`, `art/character/celebrate.png.import`, `art/character/celebrate_portrait.png`, `art/character/celebrate_portrait.png.import`, `art/character/devastated_portrait.png`, `art/character/devastated_portrait.png.import`, `art/character/falling.png`, `art/character/falling.png.import`, `art/character/grab.png` …

Beats: B02

