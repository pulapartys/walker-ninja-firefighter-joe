"""Export the three props to binary glTF (.glb) for Godot — every execute_blender_code body sent through the Blender MCP
on 2026-10-14 (my prompt: "push and start the export"). For each prop: call A opens its .blend, call B exports it.
(A first try did both in one call and failed: after open_mainfile in the same script, the glTF exporter found no
`active_object` in Blender's context — "AttributeError: 'Context' object has no attribute 'active_object'".)
Settings: +Y Up (export_yup=True), transforms applied, materials exported, into godot/props3d/<name>.glb.
Results: hydrant.glb 356 tris 0.40 x 0.36 x 0.80 · rescue_bag.glb 296 tris 0.36 x 0.306 x 0.612 ·
flame.glb 48 tris 0.36 x 0.265 x 0.62 (with my hand edit); each at location 0, rotation 0, scale 1, min Z 0.
"""

# --- Call A (once per prop: hydrant, rescue_bag, flame): open the file
import bpy, os
REPO = os.path.expanduser("~/Desktop/repos/walker-ninja-firefighter-joe")
bpy.ops.wm.open_mainfile(filepath=os.path.join(REPO, "blender", "hydrant.blend"))   # then rescue_bag.blend, flame.blend
print("opened", os.path.basename(bpy.data.filepath), [o.name for o in bpy.data.objects])

# --- Call B (same code for every prop): report the open prop, export it as .glb (+Y Up, transforms applied,
# materials) into the Godot project at godot/props3d/<file>.glb
import bpy, os
REPO = os.path.expanduser("~/Desktop/repos/walker-ninja-firefighter-joe")
OUT = os.path.join(REPO, "godot", "props3d")
os.makedirs(OUT, exist_ok=True)
name = os.path.splitext(os.path.basename(bpy.data.filepath))[0]
o = bpy.data.objects[0]
bpy.context.view_layer.objects.active = o
o.select_set(True)
tris = sum(len(p.vertices) - 2 for p in o.data.polygons)
zs = [v.co.z for v in o.data.vertices]
path = os.path.join(OUT, f"{name}.glb")
bpy.ops.export_scene.gltf(filepath=path, export_format="GLB", use_selection=False,
                          export_yup=True, export_apply=True, export_materials="EXPORT")
print(f"{name}: objects {[x.name for x in bpy.data.objects]} | tris {tris} | dims {tuple(round(v, 3) for v in o.dimensions)} | "
      f"loc {tuple(o.location)} | rot {tuple(o.rotation_euler)} | scale {tuple(o.scale)} | min_z {round(min(zs), 4)} | "
      f"materials {[m.name for m in o.data.materials]} -> {os.path.basename(path)} {os.path.getsize(path)} bytes")
