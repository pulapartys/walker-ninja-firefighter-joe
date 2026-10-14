"""Rooftop ledge — every execute_blender_code body sent through the Blender MCP on 2026-10-14, in order.

Each block below was one MCP call (my prompt for every call: "build ledge").
Running this whole file in Blender's Scripting workspace rebuilds the asset as Claude built it,
before my hand edit (see a3/FRICTIONAL.md and a3/TEST-REPORT.md for the hand edit).
Reports from the session: 2 boxes, joined: 24 triangles, 2.5 x 1.0 x 0.45 m,
origin (0, 0, 0), rotation 0, scale 1, 1, 1, min Z 0.0, max Z 0.45.
"""

# --- Call 1: Ledge Step 0: new empty scene, metric units, flat-colour materials from my game's ledge drawing (session.gd)
import bpy
bpy.ops.wm.read_homefile(use_empty=True)
scene = bpy.context.scene
scene.unit_settings.system = "METRIC"
scene.unit_settings.scale_length = 1.0
scene.cursor.location = (0, 0, 0)

def srgb_to_linear(hex_):
    c = [int(hex_[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    return tuple(x / 12.92 if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4 for x in c) + (1.0,)

def flat_material(name, hex_):
    m = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = next(n for n in m.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    bsdf.inputs["Base Color"].default_value = srgb_to_linear(hex_)
    bsdf.inputs["Roughness"].default_value = 0.8
    m.diffuse_color = srgb_to_linear(hex_)
    return m

flat_material("ledge_concrete", "b8b2a6")
flat_material("ledge_green", "438e7d")
print("objects:", len(bpy.data.objects), "| units:", scene.unit_settings.system,
      "| materials:", sorted(m.name for m in bpy.data.materials))

# --- Call 2: Ledge Parts 1-2: two boxes sized by their vertices (object scale stays 1).
# 90 x 16 px at 0.028125 m/px: 2.53 m wide (rounded to 2.5 in the brief), 0.45 m thick; depth 1.0 m (my choice).
# 1 concrete slab: 2.5 x 1.0 x 0.3375, Z 0 -> 0.3375
# 2 green top strip: the game's 4 px = 0.1125 m, Z 0.3375 -> 0.45
import bpy, bmesh

def box(name, size, loc, mat):
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=size, verts=bm.verts)
    bm.to_mesh(mesh)
    bm.free()
    o = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(o)
    o.location = loc
    o.data.materials.append(bpy.data.materials[mat])
    return o

STRIP = 4 * 0.028125
parts = [
    box("L_slab",  (2.5, 1.0, 0.45 - STRIP), (0, 0, (0.45 - STRIP) / 2),    "ledge_concrete"),
    box("L_strip", (2.5, 1.0, STRIP),        (0, 0, 0.45 - STRIP / 2),      "ledge_green"),
]
bpy.context.view_layer.update()
for o in parts:
    print(o.name, "loc", tuple(round(v, 4) for v in o.location), "dims", tuple(round(v, 4) for v in o.dimensions), "scale", tuple(o.scale))

# --- Call 3: Ledge Finish: join into one object "RooftopLedge", origin at bottom centre (world origin), apply transforms, report
import bpy, bmesh
parts = [o for o in bpy.data.objects if o.name.startswith("L_")]
bpy.ops.object.select_all(action="DESELECT")
for p in parts:
    p.select_set(True)
bpy.context.view_layer.objects.active = bpy.data.objects["L_slab"]
bpy.ops.object.join()
l = bpy.context.object
l.name = l.data.name = "RooftopLedge"
bpy.context.scene.cursor.location = (0, 0, 0)
bpy.ops.object.origin_set(type="ORIGIN_CURSOR")
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

bm = bmesh.new()
bm.from_object(l, bpy.context.evaluated_depsgraph_get())
bmesh.ops.triangulate(bm, faces=bm.faces[:])
tris = len(bm.faces)
zs = [v.co.z for v in bm.verts]
bm.free()
print("name", l.name, "| triangles", tris, "| dims", tuple(round(v, 4) for v in l.dimensions),
      "| location", tuple(l.location), "| rotation", tuple(l.rotation_euler), "| scale", tuple(l.scale),
      "| min_z", round(min(zs), 4), "max_z", round(max(zs), 4),
      "| materials", [m.name for m in l.data.materials])

# --- Call 4: Save this asset's source file
import bpy, os
path = os.path.expanduser("~/Desktop/repos/walker-ninja-firefighter-joe/blender/rooftop_ledge.blend")
bpy.ops.wm.save_as_mainfile(filepath=path)
print("saved", os.path.basename(path), os.path.getsize(path), "bytes")
