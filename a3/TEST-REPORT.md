# TEST-REPORT — Assignment 3: three 3D props

> All checks run on 2026-10-14. **Blender 5.2.2 LTS**, **Godot 4.7.2 stable** (GL Compatibility renderer), **MCP for Blender** server 2.1.9 / add-on 1.8, **macOS 26.6.2** on an Apple M1.
> Numbers marked *Blender* were read from the object (the same values the sidebar's Dimensions shows) through the MCP; numbers marked *Godot (headless)* come from `godot/tests/check_props.gd`. My own visual checks are marked **HUMAN CHECK**.

## Summary

| Check | Result |
|---|---|
| Interface notes | ✅ six parts in my words, my own screenshot (`BLENDER-NOTES.md`) |
| Size: Blender = brief = Godot | ✅ all three within 0.001 m of the latest brief revision |
| Upright, scale 1, 1, 1 | ✅ all three |
| Origin on the floor | ✅ bottom of each prop exactly at the floor (+0.0000 m) |
| Triangle count within budget | ✅ 356 / 400 · 296 / 300 · 48 / 400 |
| Imports and appears | ✅ all three import with no errors and appear in `scenes3d/props_room.tscn` |
| HUMAN CHECK: look | ✅ done (my observations below, including limitations) |
| What Claude got wrong | ✅ several, listed below |
| Inspect-and-revise cycles | ✅ bag ×3, ledge → flame swap, flame ×8, plus my hand edit |
| My A2 game still works | ✅ 41 / 0 game checks, keyboard checks pass, 0 audio failures |

## How to run the checks

```
# import once (creates the .import files)
godot --headless --path godot --import
# the A3 prop check (Godot on macOS: ~/Downloads/Godot.app/Contents/MacOS/Godot)
timeout 120 godot --headless --path godot --script res://tests/check_props.gd --fixed-fps 60
# the same, but it only passes if the script printed "RESULT: PASS" (see "Godot exits 0" below)
GODOT=/path/to/Godot godot/tests/run_check_props.sh
# planted faults: must FAIL
GODOT=/path/to/Godot godot/tests/run_check_props.sh mutate
```

Open the scene: Godot → Import `godot/project.godot` → double-click `scenes3d/props_room.tscn`. `timeout` comes from Homebrew's coreutils (9.12).

## 1. Interface notes

Six parts of the window in my own words, with my screenshot of my own session (default cube selected, sidebar open): see `BLENDER-NOTES.md` and `evidence/blender-session.png`, `evidence/blender-edit-mode.png`.

## 2. Size: Blender vs brief vs Godot

Godot is Y-up, Blender is Z-up, so Blender X × Y × Z shows up in Godot as W (X) × D (Z) × H (Y). Below everything is written **W × D × H** in metres.

| Prop | Brief v1 (before building) | Latest brief revision | *Blender* (Dimensions) | *Godot (headless)* global box | Match |
|---|---|---|---|---|---|
| Fire hydrant | about 0.4 × 0.4 × 0.8 | — (v1) | 0.40 × 0.36 × 0.80 | 0.400 × 0.360 × 0.800 | ✅ (depth 0.36 vs "about 0.4": the outlets make it wider than deep) |
| Rescue bag | 0.6 × 0.3 × 0.3 (duffel) | Rev 2: 0.36 × 0.31 × 0.61 (backpack) | 0.36 × 0.306 × 0.612 | 0.360 × 0.306 × 0.612 | ✅ |
| Flame (replaced the ledge) | ledge 2.5 × 1.0 × 0.45 | Rev 6: 0.36 × 0.27 × 0.62 | 0.36 × 0.265 × 0.62 | 0.360 × 0.265 × 0.620 | ✅ |

Godot's numbers are the **global** bounding box of every mesh in the prop, after its node transform, so a rotated or scaled node cannot hide behind a correct-looking mesh. Recorded output: `evidence/check-props-output.txt`.

## 3. Upright and scale

| Prop | *Blender* rotation / scale | *Godot (headless)* node + mesh scale | Height along | Result |
|---|---|---|---|---|
| Hydrant | 0, 0, 0 / 1, 1, 1 | 1, 1, 1 | Y (up) | ✅ upright |
| Rescue bag | 0, 0, 0 / 1, 1, 1 | 1, 1, 1 | Y (up) | ✅ upright |
| Flame | 0, 0, 0 / 1, 1, 1 | 1, 1, 1 | Y (up) | ✅ upright |

All rotations and scales were applied in Blender before export (the bag's straps and the hydrant's outlets were rotated 90° while being built; the join step baked that in). The `.glb` files were exported with **+Y Up**, so **prediction P1 (lying on its side) did not happen**.

## 4. Origin

Every prop was built around Blender's world origin with its base at Z = 0, origin set to the bottom centre (0, 0, 0). In Godot each prop is placed only by moving it sideways (no rotation, no scale), on a floor plane at Y = 0.

| Prop | *Blender* lowest point | *Godot (headless)* bottom vs floor | HUMAN CHECK | Result |
|---|---|---|---|---|
| Hydrant | Z 0.0000 | +0.0000 m | stands on the floor, shadow touches the base | ✅ |
| Rescue bag | Z 0.0000 | +0.0000 m | stands on the floor | ✅ |
| Flame | Z 0.0000 | +0.0000 m | sits on the floor | ✅ |

**Prediction P2 (sinks into the floor) did not happen.** I had seen the risk myself in my first Blender session: the default cube's origin is in its middle (a corner at Z = −1 m).

## 5. Triangle count

| Prop | Budget (brief) | *Blender* (triangulated mesh, via MCP) | *Godot (headless)* (imported index buffers) | Shapes |
|---|---|---|---|---|
| Hydrant | ≤ 400 | 356 | 356 | 6 (base, body, cap, nut, 2 outlets) |
| Rescue bag | ≤ 300 | 296 | 296 | 6 (body, flap, pocket, 2 straps, handle) |
| Flame | ≤ 400 (Rev 3) | 48 | 48 | 1 shaped mesh |

Course limit: 500 triangles and 6 shapes per asset. Blender's count was read by triangulating each object's mesh through the MCP (the same figure as Scene Statistics); Godot counts the imported triangles independently, and the two agree.

## 6. Imports and appears

`godot --headless --path godot --import` imported `props3d/hydrant.glb`, `rescue_bag.glb` and `flame.glb` with no errors or warnings and wrote their `.import` files. All three appear in `scenes3d/props_room.tscn` with a floor (4 × 4 m), one sun light with shadows, a camera, and a 1.8 m grey pole labelled as Extinguisho's height (a size reference, not an asset). Screenshots from the scene camera and from front, right, back, left, below and top: `evidence/godot-props-*.png`.

## 7. HUMAN CHECK: look

I opened the scene in the Godot editor and walked the camera around the props (`evidence/godot-my-human-check.png`, `godot-my-human-check-2.png`). In my words:

- **Flame:** "I like the different shades of colours in the fire, it looks more realistic." It reads as fire.
- **Hydrant:** "basic." It reads as a hydrant, but plain.
- **Backpack:** "can make it better in shape and colours." It reads as a bag, but the shape and the orange are simple.
- **Size:** "backpack and flame can be bigger" next to the 1.8 m pole.
- **Missing faces / wrong colours:** none seen. **The colours survived the export** — the same red hydrant, orange backpack and five fire shades as in Blender — so **prediction P3 did not happen**.
- **From below:** the floor disappears, because a Godot plane has only a top side; the props are then seen from underneath through it. Not a prop problem.

I decided not to change the props after this check (deadline); the size and look comments are recorded as limitations and next steps below.

## 8. What Claude got wrong

Every one of these was caught — by me in the viewport, by a render, or by a check — and is in FRICTIONAL.md:

1. **Rescue bag v1:** the handle ring was buried inside the body (only ~1.5 cm showed), and the whole thing read as a barrel. Every number passed.
2. **Flame v1 and v2:** read as "a christmas tree with 2 spikes", then "not a flame again".
3. **Flame v4:** nested shells — in 3D an outer shell hides the inner colours, so only red showed.
4. **Flame v4–v8c:** kept producing spikes and crystals even from my reference sheet and written brief.
5. **Flame v8b:** the centre flame curled towards the back instead of sideways, so from the front it looked straight (Claude found and fixed it).
6. **Export:** opening a file and exporting in the same script failed (`'Context' object has no attribute 'active_object'`); split into two calls.
7. **Godot camera and sun:** the rotation was written column by column, but Godot's scene files store rows, so the camera first looked upward and cut the props off.
8. **The check script** first had a type error — and **Godot still exited with code 0** although the script never ran. The runner now passes only if `RESULT: PASS` is printed.
9. **My hand edit:** Claude told me to drag "to the right" to strengthen the curl; in that view the drag moved the tip towards the centre. (I kept the result because I liked it.)

## 9. Inspect-and-revise cycles

| Observation (who / how) | Revision | Evidence |
|---|---|---|
| Bag v1 "looks like a barrel", handle buried (my viewport + render) | v2 duffel with two strap handles and a zip | Rev 1, `bag-v1-*`, `bag-angles-v2.png` |
| The bag rides on his back in my game (my decision) | v3 backpack | Rev 2, `bag-angles-v3-backpack.png` |
| v3 "more like a box" (my viewport) | v4 rounded backpack — final | Rev 2, `bag-v4-my-viewport-check.png` |
| Ledge "fine but nothing interesting" (my viewport) | swapped for a flame, the game's main hazard | Rev 3, `ledge-*` |
| Flame v1–v8c read as a tree, spikes or crystals (my viewport) | my symmetrical design, my reference sheet, two written briefs, then one curved flame built from cross-sections — final | Rev 4–6, `flame-*` |
| My preference after building | hand edit: flame tip moved 0.19 m | Rev 7, `hand-edit-flame-*` |
| Headless check had a weak spot (Godot exit 0) | strict runner requiring `RESULT: PASS` | `godot/tests/run_check_props.sh` |

## 10. Predictions vs results

| # | Prediction (CHANGE-BRIEF v1) | Result | How checked |
|---|---|---|---|
| P1 | Arrives lying on its side (Z-up vs Y-up) | **Did not happen** — height lies along Y for all three | headless "height along Y"; my look in Godot |
| P2 | Sinks into the floor (origin in the middle) | **Did not happen** — bottoms at +0.0000 m | headless bottom vs floor; my look |
| P3 | Colours don't survive the export | **Did not happen** — same colours in Godot | my look in Godot vs Blender |
| P4 | The MCP won't connect | **Partly** — the assignment's `claude mcp add -e … blender` line failed; with the name first it connected on the next try | FRICTIONAL MCP table |

## 11. What the check does and does not show

**It shows:** each prop's global size within 0.01 m of my brief; the scale of the prop node and of every mesh under it is 1, 1, 1; the height lies along Y with the node's up vector pointing up; the bottom sits on the floor's surface; the triangle count is within budget. **It catches planted faults:** with `mutate`, a hydrant rotated 90° (height on X, and it sinks 0.2 m because it turns around its base), a bag scaled ×2 and a flame lowered 0.2 m all FAIL (`evidence/check-props-mutate.txt`).

**It does not show:** whether the props look like a hydrant, a backpack or a flame; whether the colours are right; whether the sizes suit the game; whether faces are missing or point the wrong way; anything about lighting. It measures the floor from the floor plane's own box — it does not prove the plane is the only floor, and it would not notice a prop floating above a different surface. Those are my human checks (section 7).

## 12. My A2 game still works

The 3D scene and props are new files; nothing in the 2D game was edited. Re-run after adding them: `tests/test_game.gd` **41 checks / 0 failures**; `tests/test_keyboard.gd` all PASS; `tests/test_audio.gd` **0 failures**.

## 13. Known limitations

- **The flame is one shaped mesh**, built from placed cross-sections, not a combination of Blender's basic shapes. I chose it after eight primitive-based versions read as spikes or crystals.
- **The hydrant is basic** and **the backpack's shape and colours are simple** (my human check).
- **The backpack and flame could be bigger** next to Extinguisho (my human check); the flame's 0.62 m came from the game's 22 px flame drawing.
- **My hand edit straightened the flame**, a little against my own brief ("a tip that curls noticeably sideways").
- **The 3D scene is not connected to the 2D game yet** (the assignment says that is not needed now).
- From the back, the flame's lower yellow looks darker under the scene light.

## 14. Next steps

- Make the backpack and flame bigger in the brief and rebuild them at the new size.
- Improve the backpack's shape and add a second colour band; add detail to the hydrant (a chain, a darker cap).
- Use the props scene in Assignments 4 and 5.
