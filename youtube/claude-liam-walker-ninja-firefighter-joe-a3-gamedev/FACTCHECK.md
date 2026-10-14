# FACTCHECK

Every number narrated, with its source. Checked by Claude Code against the repository; the final film is reviewed by Sreeja.

| Claim | Source |
|---|---|
| Blender 5.2, Godot 4.7 | `a3/SOURCES.md` (5.2.2 LTS, 4.7.2 stable) |
| 64 px, 1.8 m, ~2.8 cm per px | CHANGE-BRIEF v1 (1.8 / 64 = 0.028125) |
| triangle budget under 500, four predictions | CHANGE-BRIEF v1 (P1–P4) |
| default cube base 1 m below the grid | BLENDER-NOTES, note 6 (corner at Z = −1 m) |
| `-e` swallowed the server name; port 9876; services off | `a3/FRICTIONAL.md` MCP table; `evidence/mcp-panel-services-off.png` |
| hydrant 6 primitives, 356 tris; default UV sphere 960 | `tools/blender/build_hydrant.py`; 2 × 32 × (16 − 1) = 960 |
| bag v1 within 2 cm of the brief | v1 0.60 × 0.28 × 0.30 vs brief 0.6 × 0.3 × 0.3 |
| backpack 296 tris | `tools/blender/build_rescue_bag.py` call 20 |
| ledge from 90 × 16 px | `godot/levels/first_steps.json`, CHANGE-BRIEF v1 |
| one mesh, hexagonal cross-sections, left/right widths, colour by height and normal, 48 tris | `tools/blender/build_flame.py` calls 27–28 |
| hand edit 0.19 m along global X | her screenshot: "D: 0.188830 m along global X" |
| identity basis, only the origin moves | `godot/scenes3d/props_room.tscn` lines 48–55 |
| Movie Maker, fixed 30 fps | CAPTURE.md |
| AABB through global transform; 1 cm tolerance | `godot/tests/check_props.gd` (`_global_aabb`, `TOL := 0.01`) |
| match to the millimetre; planted faults fail | `a3/evidence/check-props-output.txt`, `check-props-mutate.txt` |
| Godot exit code 0 on parse error | TEST-REPORT §8.8 |
| her human-check words | TEST-REPORT §7 |

The gamedev checker (`./art godot-gamedev --check`) covers file hashes, inventory and the two code excerpts; it does not judge whether the explanation is true or the visuals good.
