# Extinguisho's First 3D Props

Final narration as voiced by Liam (Kokoro am_onyx), generated from beat_sheet.json. Script v2 (more technical), drafted by Claude Code and approved by Sreeja (SCRIPT-DRAFT.md).

## B00 — The prompt

Please use Walker to turn a 2D firefighter game into its first three 3D props. I'm Liam, the narrator voice of the Brutalist toolkit. This is Assignment Three for C S Y E seventy-two seventy.

## B01 — What was built

Extinguisho is Sreeja's Godot game. For this assignment she directed Claude Code through the Blender M C P server, driving a live Blender five point two session, to model three low-poly props: a fire hydrant, a rescue backpack and a flame. Each was exported as binary glTF and verified in a Godot four point seven 3D scene.

## B02 — Why these three

Each prop maps to something in the game. The flame is the core hazard. The backpack is the rescue bag drawn on his back, where survivors land. The hydrant belongs on the burning street. The game is 2D, so the props live in a separate 3D scene for now.

## B03 — The brief came first

Before any geometry, Sreeja committed a brief. Extinguisho is sixty-four pixels tall; she fixed him at one point eight metres, about two point eight centimetres per pixel. Each prop got dimensions in metres, a bottom-centre origin, flat colours and a triangle budget under five hundred, plus four predicted failures, each with a check.

## B04 — Learning the window

First she explored Blender by hand. Blender is Z-up; Godot is Y-up. And the default cube's origin sits at its centre, so its base is one metre below the grid. That observation became prediction two: a prop that sinks into the floor.

## B05 — Connecting the M C P

The setup line in the assignment failed: Claude Code's dash e option accepts several values, and swallowed the server name. Putting the name first fixed it. The add-on listened on localhost, port nine eight seven six, with every asset library and generator disabled.

## B06 — A prompt and what it built

One asset per request, plan first. For the hydrant Claude proposed six primitives with reduced segment counts: three hundred fifty-six triangles, against a default sphere's nine hundred sixty. After her approval, each part was one execute blender code call, then a join, an origin set to the world origin, and transform apply, leaving scale at one.

## B07 — Barrel to backpack

The bag shows the limit of numbers. Version one matched its brief dimensions within two centimetres, yet read as a barrel, with the handle torus buried inside the body. Sreeja asked what the bag is for: it rides on his back. Three revisions later it is a rounded backpack, two hundred ninety-six triangles.

## B08 — Ledge to flame

Her third prop began as a ledge derived from the level data, ninety by sixteen pixels. It matched the brief, and was, in her words, nothing interesting, so she swapped it for a flame. Built from stacked primitives, version after version read as a Christmas tree, crystals or spikes.

## B09 — One flame first

So she changed the method. One mesh, built in bmesh from hexagonal cross-sections with independent left and right widths, approved in grey before colour. Faces were coloured by height and by normal direction, brighter in the centre. Forty-eight triangles.

## B10 — Her hand edit

Then her own edit, in the viewport. Edit mode, vertex select, the tip vertex, G then X: a constrained move along global X of nought point one nine metres. On screen the drag ran toward the centre, because an axis's screen direction depends on the view. She kept the straighter flame.

## B11 — Three props in one scene

Export used the glTF exporter with plus Y up and transforms applied. In the scene file each prop is an instanced dot G L B with an identity basis; only the origin column moves. No rotation, no scale. A one point eight metre cylinder stands in for Extinguisho.

## B12 — In the engine

This is the running engine, recorded by Movie Maker at a fixed thirty frames per second. Upright, grounded, at game scale beside the pole. Blender's Z-up became Godot's Y-up, so prediction one did not happen.

## B13 — The headless check

The headless check pushes every mesh's bounding box through its global transform, so a rotated or scaled node can't hide behind a correct mesh. Then it tests size within a centimetre of the brief, every scale at one, height along Y, the bottom against the floor surface, and the triangle count.

## B14 — The numbers, labelled headless

Headless, all three pass, matching the brief to the millimetre. Mutation mode plants three faults: a hydrant rotated ninety degrees, a bag scaled two times, a flame lowered twenty centimetres. All three fail. And one trap: Godot exited with code zero when the script failed to parse, so the runner now requires a printed pass.

## B15 — What the check can't see

The check proves geometry, not appearance. Sreeja's own review in the editor: the fire's colour shades read as realistic, the hydrant is basic, the backpack's shape and colours could improve, and the backpack and flame could be larger. Materials survived the export, so prediction three did not happen.

## B16 — Verdict

The verdict. Verified in Blender and headless Godot: dimensions, unit scale, Y-up orientation, grounded origins and triangle budgets. Uncertain: whether the props suit the game's art style. Claude's errors: a buried handle, spiky flames, a camera basis written in the wrong order, and a check that passed without running. Sreeja directed, decided and reviewed; Claude Code proposed and implemented. Source revision on screen.

## B17 — Your turn

Your turn. Take the backpack Sreeja flagged. Ask Walker for a plan that improves its shape and colours and scales it up, then update the brief and predict which assertion in the headless check would catch a mistake. This has been Liam, from Brutalist.

## B18 — Outro

Extinguisho's First 3D Props. At Nik Bear Brown.

