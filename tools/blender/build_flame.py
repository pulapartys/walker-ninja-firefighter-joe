"""Flame — every execute_blender_code body sent through the Blender MCP on 2026-10-14, in order.

Replaced the rooftop ledge as asset 3 (CHANGE-BRIEF Revision 3). My prompt for every call:
"A, swap the ledge for the flame, also docuemnt decisions and update all docs".
v1 (calls 1-5): stacked straight teardrops + two symmetric side spikes. 336 triangles, 0.426 x 0.34 x 0.62 m.
In my viewport check it "doesn't look like a flame, looks like a chrismas tree with 2 spikes".
v2 (calls 6-8, my prompt: "doesn't look like a flame, looks like a chrismas tree with 2 spikes"): five uneven tongues
with tips bent sideways. 320 triangles, 0.41 x 0.35 x 0.62 m, origin (0, 0, 0), rotation 0, scale 1, min Z 0, max Z 0.62.
This is the version before my hand edit. Calls 1 and 6-8 rebuild it.
"""

# --- Call 1: Flame Step 0: new empty scene, metric units, flat fire colours (yellow base, orange middle, red tip)
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

flat_material("flame_yellow", "f1c40f")
flat_material("flame_orange", "e67e22")
flat_material("flame_red", "c0392b")
print("objects:", len(bpy.data.objects), "| materials:", sorted(m.name for m in bpy.data.materials))

# --- Call 2: Flame Parts 1-3: three stacked "teardrops" (a low-poly UV sphere reshaped by its vertices: round, flattened bottom,
# pointed top; object scale stays 1). Stacked so every colour shows from every side:
# 1 yellow bulb: widest (r 0.17), bottom at Z 0, tip at Z 0.40
# 2 orange middle: r 0.13, from Z 0.08, tip at Z 0.52
# 3 red tip: r 0.08, from Z 0.20, tip at Z 0.62
import bpy, bmesh

def teardrop(name, r, z_centre, bottom_h, top_h, mat, segs=8, rings=6):
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=segs, v_segments=rings, radius=1.0)
    for v in bm.verts:
        x, y, z = v.co
        if z >= 0:
            k = (1.0 - z) ** 0.6          # pinch the upper half to a point
            v.co = (x * r * k, y * r * k, z * top_h)
        else:
            v.co = (x * r, y * r, z * bottom_h)
    bm.to_mesh(mesh)
    bm.free()
    o = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(o)
    o.location = (0, 0, z_centre)
    o.data.materials.append(bpy.data.materials[mat])
    return o

parts = [
    teardrop("F_yellow", 0.17, 0.06, 0.06, 0.34, "flame_yellow"),   # Z 0.00 -> 0.40
    teardrop("F_orange", 0.13, 0.14, 0.06, 0.38, "flame_orange"),   # Z 0.08 -> 0.52
    teardrop("F_red",    0.08, 0.25, 0.05, 0.37, "flame_red"),      # Z 0.20 -> 0.62
]
bpy.context.view_layer.update()
for o in parts:
    zs = [ (o.matrix_world @ v.co).z for v in o.data.vertices ]
    print(o.name, "dims", tuple(round(v, 3) for v in o.dimensions), "Z", round(min(zs), 3), "->", round(max(zs), 3), "scale", tuple(o.scale))

# --- Call 3: Flame Parts 4-5: two side tongues, smaller teardrops (8 x 4), leaning outwards 25 degrees, at X -0.12 / +0.12
import bpy, bmesh, math
from mathutils import Matrix

def tongue(name, side, mat):
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=8, v_segments=4, radius=1.0)
    r, bottom_h, top_h = 0.06, 0.04, 0.22
    for v in bm.verts:
        x, y, z = v.co
        if z >= 0:
            k = (1.0 - z) ** 0.6
            v.co = (x * r * k, y * r * k, z * top_h)
        else:
            v.co = (x * r, y * r, z * bottom_h)
    bmesh.ops.rotate(bm, cent=(0, 0, 0), matrix=Matrix.Rotation(math.radians(25) * side, 3, "Y"), verts=bm.verts)
    bm.to_mesh(mesh)
    bm.free()
    o = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(o)
    o.location = (0.12 * side, 0, 0.12)
    o.data.materials.append(bpy.data.materials[mat])
    return o

made = [tongue("F_tongue_L", -1, "flame_orange"), tongue("F_tongue_R", 1, "flame_red")]
bpy.context.view_layer.update()
for o in made:
    zs = [ (o.matrix_world @ v.co).z for v in o.data.vertices ]
    print(o.name, "loc", tuple(round(v, 3) for v in o.location), "dims", tuple(round(v, 3) for v in o.dimensions),
          "Z", round(min(zs), 3), "->", round(max(zs), 3), "scale", tuple(o.scale))

# --- Call 4: Flame Finish: join into one object "Flame", origin at bottom centre (world origin), apply transforms, report
import bpy, bmesh
parts = [o for o in bpy.data.objects if o.name.startswith("F_")]
bpy.ops.object.select_all(action="DESELECT")
for p in parts:
    p.select_set(True)
bpy.context.view_layer.objects.active = bpy.data.objects["F_yellow"]
bpy.ops.object.join()
f = bpy.context.object
f.name = f.data.name = "Flame"
bpy.context.scene.cursor.location = (0, 0, 0)
bpy.ops.object.origin_set(type="ORIGIN_CURSOR")
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

bm = bmesh.new()
bm.from_object(f, bpy.context.evaluated_depsgraph_get())
bmesh.ops.triangulate(bm, faces=bm.faces[:])
tris = len(bm.faces)
zs = [v.co.z for v in bm.verts]
bm.free()
print("name", f.name, "| triangles", tris, "| dims", tuple(round(v, 3) for v in f.dimensions),
      "| location", tuple(f.location), "| rotation", tuple(f.rotation_euler), "| scale", tuple(f.scale),
      "| min_z", round(min(zs), 4), "max_z", round(max(zs), 4),
      "| materials", [m.name for m in f.data.materials])

# --- Call 5: Save this asset's source file
import bpy, os
path = os.path.expanduser("~/Desktop/repos/walker-ninja-firefighter-joe/blender/flame.blend")
bpy.ops.wm.save_as_mainfile(filepath=path)
print("saved", os.path.basename(path), os.path.getsize(path), "bytes")

# ======================= v2 (after "looks like a christmas tree") =======================

# --- Call 6: Flame v2: clear v1 (kept as flame-angles-v1.png and the user's screenshot), keep the three fire materials
import bpy
for o in list(bpy.data.objects):
    bpy.data.objects.remove(o, do_unlink=True)
for d in list(bpy.data.meshes):
    if d.users == 0:
        bpy.data.meshes.remove(d)
bpy.context.scene.cursor.location = (0, 0, 0)
print("objects:", len(bpy.data.objects), "| materials:", sorted(m.name for m in bpy.data.materials))

# --- Call 7: Flame v2: five uneven "tongues", each a low-poly UV sphere reshaped by its vertices (object scale stays 1):
# round fat bottom, upper half pinched to a tip, and the upper half BENT sideways (x += bend * t^2) so each tip licks.
# Different heights, leans and positions so it is not mirrored like v1.
import bpy, bmesh

def tongue(name, mat, r, base_z, bottom_h, top_h, bend, pos, segs=8, rings=6, pinch=0.8):
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=segs, v_segments=rings, radius=1.0)
    for v in bm.verts:
        x, y, z = v.co
        if z >= 0:
            k = (1.0 - z) ** pinch
            v.co = (x * r * k + bend * z * z, y * r * k, z * top_h)
        else:
            v.co = (x * r, y * r, z * bottom_h)
    bm.to_mesh(mesh)
    bm.free()
    o = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(o)
    o.location = (pos[0], pos[1], base_z + bottom_h)
    o.data.materials.append(bpy.data.materials[mat])
    return o

parts = [
    # name          material        r     base  bottom top   bend   (x, y)          segs rings
    tongue("F_main",   "flame_orange", 0.16, 0.00, 0.10, 0.36,  0.07, ( 0.00,  0.00), 8, 6),   # fat body, tip curls right, top ~0.46
    tongue("F_tall",   "flame_red",    0.10, 0.06, 0.08, 0.48, -0.09, (-0.05,  0.03), 8, 6),   # tallest, curls left, top ~0.62
    tongue("F_right",  "flame_red",    0.07, 0.02, 0.06, 0.26,  0.08, ( 0.12, -0.02), 8, 5),   # short, curls right
    tongue("F_left",   "flame_orange", 0.06, 0.00, 0.05, 0.20, -0.07, (-0.14, -0.02), 8, 4),   # small, low, curls left
    tongue("F_core",   "flame_yellow", 0.15, 0.00, 0.05, 0.16,  0.02, ( 0.01, -0.04), 8, 4),   # yellow base, bright bottom
]
bpy.context.view_layer.update()
for o in parts:
    zs = [(o.matrix_world @ v.co).z for v in o.data.vertices]
    print(o.name, "loc", tuple(round(v, 3) for v in o.location), "dims", tuple(round(v, 3) for v in o.dimensions),
          "Z", round(min(zs), 3), "->", round(max(zs), 3), "scale", tuple(o.scale))

# --- Call 8: Flame v2 Finish: join into one object "Flame", origin at bottom centre (world origin), apply transforms, report, save
import bpy, bmesh, os
parts = [o for o in bpy.data.objects if o.name.startswith("F_")]
bpy.ops.object.select_all(action="DESELECT")
for p in parts:
    p.select_set(True)
bpy.context.view_layer.objects.active = bpy.data.objects["F_main"]
bpy.ops.object.join()
f = bpy.context.object
f.name = f.data.name = "Flame"
bpy.context.scene.cursor.location = (0, 0, 0)
bpy.ops.object.origin_set(type="ORIGIN_CURSOR")
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

bm = bmesh.new()
bm.from_object(f, bpy.context.evaluated_depsgraph_get())
bmesh.ops.triangulate(bm, faces=bm.faces[:])
tris = len(bm.faces)
zs = [v.co.z for v in bm.verts]
xs = [v.co.x for v in bm.verts]
ys = [v.co.y for v in bm.verts]
bm.free()
print("name", f.name, "| triangles", tris, "| dims", tuple(round(v, 3) for v in f.dimensions),
      "| location", tuple(f.location), "| rotation", tuple(f.rotation_euler), "| scale", tuple(f.scale),
      "| min_z", round(min(zs), 4), "max_z", round(max(zs), 4),
      "| x", round(min(xs), 3), round(max(xs), 3), "| y", round(min(ys), 3), round(max(ys), 3),
      "| materials", [m.name for m in f.data.materials])
path = os.path.expanduser("~/Desktop/repos/walker-ninja-firefighter-joe/blender/flame.blend")
bpy.ops.wm.save_as_mainfile(filepath=path)
print("saved", os.path.basename(path), os.path.getsize(path), "bytes")
