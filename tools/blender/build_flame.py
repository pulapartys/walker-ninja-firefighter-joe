"""Flame — every execute_blender_code body sent through the Blender MCP on 2026-10-14, in order.

Replaced the rooftop ledge as asset 3 (CHANGE-BRIEF Revision 3). My prompt for every call:
"A, swap the ledge for the flame, also docuemnt decisions and update all docs".
v1 (calls 1-5): stacked straight teardrops + two symmetric side spikes. 336 triangles, 0.426 x 0.34 x 0.62 m.
In my viewport check it "doesn't look like a flame, looks like a chrismas tree with 2 spikes".
v2 (calls 6-8, my prompt: "doesn't look like a flame, looks like a chrismas tree with 2 spikes"): five uneven tongues
with tips bent sideways. 320 triangles, 0.41 x 0.35 x 0.62 m, origin (0, 0, 0), rotation 0, scale 1, min Z 0, max Z 0.62.
Still "not a flame" in my viewport (`flame-v2-my-viewport-check.png`).
v3 (calls 9-13): MY design. Symmetrical: a cone base layer, two mirrored bent side spikes, the bent top flame centred on
top of the cone, yellow base; then the top flame extended down to meet the spikes halfway (v3b).
336 triangles, 0.40 x 0.34 x 0.62 m, origin (0, 0, 0), rotation 0, scale 1, min Z 0, max Z 0.62.
v3 was kept for a while ("not the best but we can keep it as a basic version and improve on it later"), then replaced.
v4-v8 (calls 14-23): tried with a ChatGPT reference sheet and two written briefs of mine; all rejected (crystals/spikes).
SUBMITTED: the SINGLE FLAME (v9, calls 24-29 at the end of this file): one curved flame, 48 triangles,
0.36 x 0.265 x 0.62 m, five fire colours, origin (0, 0, 0), rotation 0, scale 1, min Z 0, max Z 0.62.
Calls 1, 9, 10, 11, 13 rebuild it (call 10 makes the first top flame, call 11 replaces it).
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

# ======================= v3 (my design, submitted) =======================
# My prompt for calls 9-10: "nope not a flame again too, so let me tell you how we can do it lets try making a symmetrical flame, starting from a comes type shape as the base layer with 2 bent spikes just like how it is now, theninstead of the top bent flame being on the side, we put it directly on top of the cone and see if we like it"

# --- Call 9: Flame v3 (my design): symmetrical. Clear v2 (kept as flame-angles-v2.png and my screenshot), keep the fire materials.
import bpy
for o in list(bpy.data.objects):
    bpy.data.objects.remove(o, do_unlink=True)
for d in list(bpy.data.meshes):
    if d.users == 0:
        bpy.data.meshes.remove(d)
bpy.context.scene.cursor.location = (0, 0, 0)
print("objects:", len(bpy.data.objects), "| materials:", sorted(m.name for m in bpy.data.materials))

# --- Call 10: Flame v3 parts (each a low-poly UV sphere reshaped by its vertices; object scale stays 1):
# 1 cone-type base layer, orange, centred: round bottom, pointed top at Z ~0.40
# 2-3 two bent side spikes, red, mirrored at X -0.12 / +0.12, each tip curving outwards
# 4 top bent flame, red, centred directly on top of the cone (base inside the cone's upper part), tip curling, top ~0.62
# 5 yellow base under the cone (bright bottom)
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
    # name            material        r     base  bottom top   bend   (x, y)        segs rings
    tongue("F_cone",    "flame_orange", 0.17, 0.00, 0.10, 0.30,  0.00, ( 0.00, 0.0), 8, 6),   # cone base layer, Z 0 -> 0.40
    tongue("F_spike_L", "flame_red",    0.07, 0.02, 0.06, 0.26, -0.08, (-0.12, 0.0), 8, 5),   # left spike, bends left
    tongue("F_spike_R", "flame_red",    0.07, 0.02, 0.06, 0.26,  0.08, ( 0.12, 0.0), 8, 5),   # right spike, bends right (mirror)
    tongue("F_top",     "flame_red",    0.09, 0.26, 0.06, 0.30,  0.07, ( 0.00, 0.0), 8, 5),   # top flame on the cone, tip curls
    tongue("F_core",    "flame_yellow", 0.16, 0.00, 0.05, 0.14,  0.00, ( 0.00, 0.0), 8, 4),   # yellow base
]
bpy.context.view_layer.update()
for o in parts:
    zs = [(o.matrix_world @ v.co).z for v in o.data.vertices]
    print(o.name, "loc", tuple(round(v, 3) for v in o.location), "dims", tuple(round(v, 3) for v in o.dimensions),
          "Z", round(min(zs), 3), "->", round(max(zs), 3), "scale", tuple(o.scale))

# --- Call 11 (my prompt: "ok now extend the upper bent cone to be longer in the bottom and meet the smaller spikes on the side halfway"):
# Flame v3b: rebuild only the top bent flame, longer at the bottom and wider, so its sides meet the two side spikes
# about halfway up them (spikes run Z 0.02 -> 0.34; halfway ~0.18). Tip stays at Z 0.62 and still curls.
import bpy, bmesh
old = bpy.data.objects.get("F_top")
if old:
    bpy.data.objects.remove(old, do_unlink=True)

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

t = tongue("F_top", "flame_red", 0.13, 0.13, 0.07, 0.42, 0.07, (0.0, 0.0), 8, 6)   # Z 0.13 -> 0.62, widest at Z 0.20
bpy.context.view_layer.update()
zs = [(t.matrix_world @ v.co).z for v in t.data.vertices]
print(t.name, "loc", tuple(round(v, 3) for v in t.location), "dims", tuple(round(v, 3) for v in t.dimensions),
      "Z", round(min(zs), 3), "->", round(max(zs), 3), "scale", tuple(t.scale))

# --- Call 13 (my prompt: "not the best but we can keep it as a bsic verisonand imporve on it later"); call 12 was a `look` picture, not code.
# Flame v3 Finish: join into one object "Flame", origin at bottom centre (world origin), apply transforms, report, save
import bpy, bmesh, os
parts = [o for o in bpy.data.objects if o.name.startswith("F_")]
bpy.ops.object.select_all(action="DESELECT")
for p in parts:
    p.select_set(True)
bpy.context.view_layer.objects.active = bpy.data.objects["F_cone"]
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
print("name", f.name, "| parts joined", len(parts), "| triangles", tris, "| dims", tuple(round(v, 3) for v in f.dimensions),
      "| location", tuple(f.location), "| rotation", tuple(f.rotation_euler), "| scale", tuple(f.scale),
      "| min_z", round(min(zs), 4), "max_z", round(max(zs), 4),
      "| materials", [m.name for m in f.data.materials])
path = os.path.expanduser("~/Desktop/repos/walker-ninja-firefighter-joe/blender/flame.blend")
bpy.ops.wm.save_as_mainfile(filepath=path)
print("saved", os.path.basename(path), os.path.getsize(path), "bytes")

# =====================================================================================================================
# v4 – v8: attempts that were tried and rejected (kept because every piece of code run through the MCP is recorded).
# None of these is the submitted flame. The submitted flame is the SINGLE FLAME section at the end of this file.
# =====================================================================================================================

# --- Call 14 (my prompt: "before we hand edit, use this to im[rove the blender flame" + the ChatGPT reference sheet)
# Flame v4 (from my reference sheet): three nested star-shaped layers, red outer / orange middle / yellow core,
# each turned so its points stick out between the outer layer's points; twisted as they rise; main tip curls.
# Each layer is one mesh built from its vertices (object scale stays 1). Flame v3 stays saved in flame.blend.
import bpy, bmesh, math

for o in list(bpy.data.objects):
    bpy.data.objects.remove(o, do_unlink=True)
for d in list(bpy.data.meshes):
    if d.users == 0:
        bpy.data.meshes.remove(d)
bpy.context.scene.cursor.location = (0, 0, 0)

TS = [0.0, 0.2, 0.45, 0.7, 0.88]          # ring heights as a fraction of the layer height

def profile(t):                             # width along the height: full at the bottom, slight bulge, tapering to the tip
    return (1.0 - t) ** 0.8 * (1.0 + 1.2 * t)

def star_layer(name, mat, K, H, r_point, r_notch, rot, twist, bend, lifts):
    bm = bmesh.new()
    rings = []
    for t in TS:
        ring = []
        for j in range(2 * K):
            a = rot + twist * t + j * math.pi / K
            point = (j % 2 == 0)
            r = (r_point if point else r_notch) * profile(t)
            z = t * H + (lifts[j // 2] * t * H if point else 0.0)
            ring.append(bm.verts.new((r * math.cos(a) + bend * t * t, r * math.sin(a), z)))
        rings.append(ring)
    apex = bm.verts.new((bend, 0.0, H))
    n = 2 * K
    for a_ring, b_ring in zip(rings, rings[1:]):
        for j in range(n):
            bm.faces.new((a_ring[j], a_ring[(j + 1) % n], b_ring[(j + 1) % n], b_ring[j]))
    for j in range(n):
        bm.faces.new((rings[-1][j], rings[-1][(j + 1) % n], apex))
    bm.faces.new(list(reversed(rings[0])))                     # flat bottom on the floor
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    mesh = bpy.data.meshes.new(name)
    bm.to_mesh(mesh)
    bm.free()
    o = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(o)
    o.data.materials.append(bpy.data.materials[mat])
    return o

K = 6
slot = math.pi / K / 1.5                    # 20 degrees: outer points at 0, middle at +20, inner at +40
layers = [
    star_layer("F_outer",  "flame_red",    K, 0.62, 0.21, 0.07, 0.0,      math.radians(35), 0.08, [0.00, 0.10, -0.05, 0.06, -0.08, 0.04]),
    star_layer("F_middle", "flame_orange", K, 0.48, 0.18, 0.06, slot,     math.radians(35), 0.04, [0.05, -0.06, 0.08, -0.03, 0.06, -0.05]),
    star_layer("F_inner",  "flame_yellow", K, 0.36, 0.15, 0.05, 2 * slot, math.radians(35), 0.02, [-0.04, 0.06, -0.02, 0.07, -0.05, 0.03]),
]
bpy.context.view_layer.update()
for o in layers:
    zs = [v.co.z for v in o.data.vertices]
    print(o.name, "dims", tuple(round(v, 3) for v in o.dimensions), "Z", round(min(zs), 3), "->", round(max(zs), 3),
          "faces", len(o.data.polygons), "scale", tuple(o.scale))

# --- Call 15 (same prompt): Flame v4b: same three star layers, but (1) the body narrows to a point instead of a round bell,
# (2) each star point rises to its own tip at a different height (side flames), (3) the outer main tip is taller and curls.
import bpy, bmesh, math
for o in list(bpy.data.objects):
    bpy.data.objects.remove(o, do_unlink=True)
for d in list(bpy.data.meshes):
    if d.users == 0:
        bpy.data.meshes.remove(d)

TS = [0.0, 0.18, 0.4, 0.62, 0.82]

def body(t):            # notches: narrow quickly to a point
    return (1.0 - t) ** 1.3 * (1.0 + 0.7 * t)

def fin(t):             # points: stay out longer, so they read as separate side flames
    return (1.0 - t) ** 0.7 * (1.0 + 0.5 * t)

def star_layer(name, mat, K, H, r_point, r_notch, rot, twist, bend, lifts):
    bm = bmesh.new()
    rings = []
    for t in TS:
        ring = []
        for j in range(2 * K):
            a = rot + twist * t + j * math.pi / K
            point = (j % 2 == 0)
            if point:
                r = r_point * fin(t)
                z = t * H * (1.0 + lifts[j // 2] * t)   # each point rises to its own height
            else:
                r = r_notch * body(t)
                z = t * H
            ring.append(bm.verts.new((r * math.cos(a) + bend * t * t, r * math.sin(a), z)))
        rings.append(ring)
    apex = bm.verts.new((bend * 1.3, 0.0, H))
    n = 2 * K
    for a_ring, b_ring in zip(rings, rings[1:]):
        for j in range(n):
            bm.faces.new((a_ring[j], a_ring[(j + 1) % n], b_ring[(j + 1) % n], b_ring[j]))
    for j in range(n):
        bm.faces.new((rings[-1][j], rings[-1][(j + 1) % n], apex))
    bm.faces.new(list(reversed(rings[0])))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    mesh = bpy.data.meshes.new(name)
    bm.to_mesh(mesh)
    bm.free()
    o = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(o)
    o.data.materials.append(bpy.data.materials[mat])
    return o

K = 6
slot = math.radians(20)
layers = [
    star_layer("F_outer",  "flame_red",    K, 0.62, 0.21, 0.10, 0.0,      math.radians(30), 0.10, [-0.35, 0.05, -0.15, -0.30, 0.00, -0.20]),
    star_layer("F_middle", "flame_orange", K, 0.46, 0.18, 0.08, slot,     math.radians(30), 0.05, [0.10, -0.25, 0.20, -0.10, 0.15, -0.30]),
    star_layer("F_inner",  "flame_yellow", K, 0.32, 0.15, 0.06, 2 * slot, math.radians(30), 0.02, [-0.20, 0.15, -0.10, 0.20, -0.25, 0.10]),
]
bpy.context.view_layer.update()
for o in layers:
    zs = [v.co.z for v in o.data.vertices]
    print(o.name, "dims", tuple(round(v, 3) for v in o.dimensions), "Z", round(min(zs), 3), "->", round(max(zs), 3), "scale", tuple(o.scale))

# --- Call 16 (my prompt: "youre doing somethign wrong, do you need me to give you a prompt or id the reference image enough")
# Flame v5: crown (wide bowl + 6 outward side flames) + tall main flame + second flame, colours as height zones.
import bpy, bmesh, math

for o in list(bpy.data.objects):
    bpy.data.objects.remove(o, do_unlink=True)
for d in list(bpy.data.meshes):
    if d.users == 0:
        bpy.data.meshes.remove(d)
MATS = ["flame_yellow", "flame_orange", "flame_red"]
H, R = 0.62, 0.20

def finish(name, bm, colour_of_face):
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    for f in bm.faces:
        f.material_index = colour_of_face(f)
    mesh = bpy.data.meshes.new(name)
    bm.to_mesh(mesh)
    bm.free()
    o = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(o)
    for m in MATS:
        o.data.materials.append(bpy.data.materials[m])
    return o

def crown():
    bm = bmesh.new()
    K = 6
    ring0 = [bm.verts.new((0.62 * R * math.cos(a), 0.62 * R * math.sin(a), 0.0)) for a in [i * math.pi / K for i in range(2 * K)]]
    ring1 = [bm.verts.new((1.00 * R * math.cos(a), 1.00 * R * math.sin(a), 0.07)) for a in [i * math.pi / K for i in range(2 * K)]]
    z2 = 0.17
    ring2 = []
    for i in range(2 * K):
        a = i * math.pi / K
        r = 0.95 * R if i % 2 == 0 else 0.72 * R
        ring2.append(bm.verts.new((r * math.cos(a), r * math.sin(a), z2)))
    heights = [0.38, 0.30, 0.35, 0.27, 0.36, 0.31]
    tips = []
    for j in range(K):
        a = 2 * j * math.pi / K + 0.12
        tips.append(bm.verts.new((1.08 * R * math.cos(a), 1.08 * R * math.sin(a), heights[j])))
    n = 2 * K
    bm.faces.new(list(reversed(ring0)))
    for a_r, b_r in ((ring0, ring1), (ring1, ring2)):
        for i in range(n):
            bm.faces.new((a_r[i], a_r[(i + 1) % n], b_r[(i + 1) % n], b_r[i]))
    centre = bm.verts.new((0.0, 0.0, z2 + 0.03))
    for j in range(K):
        p, gl, gr = ring2[2 * j], ring2[(2 * j - 1) % n], ring2[(2 * j + 1) % n]
        t = tips[j]
        bm.faces.new((gl, p, t))
        bm.faces.new((p, gr, t))
        bm.faces.new((gr, centre, t))
        bm.faces.new((centre, gl, t))
    def colour(f):
        zc = f.calc_center_median().z
        return 2 if zc > z2 + 0.02 else 1
    return finish("F_crown", bm, colour)

def tongue(name, r, z0, bottom_h, top_h, bend, pos, segs, rings, cuts):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=segs, v_segments=rings, radius=1.0)
    for v in bm.verts:
        x, y, z = v.co
        if z >= 0:
            k = (1.0 - z) ** 0.75
            v.co = (x * r * k + bend * z * z + pos[0], y * r * k + pos[1], z0 + bottom_h + z * top_h)
        else:
            v.co = (x * r + pos[0], y * r + pos[1], z0 + bottom_h + z * bottom_h)
    lo, hi = z0, z0 + bottom_h + top_h
    def colour(f):
        frac = (f.calc_center_median().z - lo) / (hi - lo)
        return 0 if frac < cuts[0] else (1 if frac < cuts[1] else 2)
    return finish(name, bm, colour)

parts = [
    crown(),
    tongue("F_main",   0.125, 0.03, 0.08, H - 0.11, -0.07, (0.00,  0.00), 10, 8, (0.42, 0.68)),
    tongue("F_second", 0.080, 0.10, 0.06, 0.30,      0.07, (0.07, -0.03),  8, 6, (0.35, 0.62)),
]
bpy.context.view_layer.update()
for o in parts:
    zs = [v.co.z for v in o.data.vertices]
    print(o.name, "dims", tuple(round(v, 3) for v in o.dimensions), "Z", round(min(zs), 3), "->", round(max(zs), 3),
          "faces", len(o.data.polygons), "scale", tuple(o.scale))

# --- Call 17 (same prompt): Flame v5b: shorter bowl, big side tongues, fatter main flame.
# Identical to call 16 except: ring0 radius 0.70*R; ring1 at z 0.035; z2 = 0.08; gaps at 0.62*R; side-flame heights
# [0.44, 0.33, 0.40, 0.30, 0.42, 0.35] with tips at 0.85*R turned +0.15 rad; crown colour: orange below z 0.20, red above;
# tongues: F_main r 0.150 z0 0.02 bottom 0.08 top H-0.10 bend -0.07 (10x8, cuts 0.45/0.70);
#          F_second r 0.100 z0 0.06 bottom 0.06 top 0.34 bend 0.07 at (0.07, -0.04) (8x6, cuts 0.40/0.66).

# --- Call 18 (my prompt: "layer more spikes until the top arounf the main centre cone like a star from the top view")
# Flame v6: rings of spikes rising up around the main centre cone, each ring smaller and higher and turned
# into the gaps of the ring below, so the top view is a star.
import bpy, bmesh, math
for o in list(bpy.data.objects):
    bpy.data.objects.remove(o, do_unlink=True)
for d in list(bpy.data.meshes):
    if d.users == 0:
        bpy.data.meshes.remove(d)
MATS = ["flame_yellow", "flame_orange", "flame_red"]
YELLOW, ORANGE, RED = 0, 1, 2
H, R = 0.62, 0.20

def finish(name, bm, colour_of_face):
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    for f in bm.faces:
        f.material_index = colour_of_face(f)
    mesh = bpy.data.meshes.new(name)
    bm.to_mesh(mesh)
    bm.free()
    o = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(o)
    for m in MATS:
        o.data.materials.append(bpy.data.materials[m])
    return o

def add_spike(bm, angle, r_base, z_base, r_tip, z_tip, half_w):
    ca, sa = math.cos(angle), math.sin(angle)
    tx, ty = -sa, ca
    base = []
    for dr, dt in ((-0.6, -1), (-0.6, 1), (0.6, 1), (0.6, -1)):
        r = r_base + dr * half_w
        base.append(bm.verts.new((r * ca + dt * half_w * tx, r * sa + dt * half_w * ty, z_base)))
    tip = bm.verts.new((r_tip * ca, r_tip * sa, z_tip))
    for i in range(4):
        bm.faces.new((base[i], base[(i + 1) % 4], tip))
    bm.faces.new(list(reversed(base)))

def spike_ring(name, count, offset_deg, r_base, z_base, r_tip, tip_heights, half_w, low, high):
    bm = bmesh.new()
    for j in range(count):
        a = math.radians(offset_deg) + 2 * math.pi * j / count
        add_spike(bm, a, r_base, z_base, r_tip, tip_heights[j], half_w)
    lo, hi = z_base, max(tip_heights)
    return finish(name, bm, lambda f: low if f.calc_center_median().z < (lo + hi) / 2 else high)

def base_ring():
    bm = bmesh.new()
    K, n = 6, 12
    ang = [i * math.pi / K for i in range(n)]
    ring0 = [bm.verts.new((0.70 * R * math.cos(a), 0.70 * R * math.sin(a), 0.0)) for a in ang]
    ring1 = [bm.verts.new((1.00 * R * math.cos(a), 1.00 * R * math.sin(a), 0.035)) for a in ang]
    z2 = 0.08
    ring2 = [bm.verts.new(((1.0 if i % 2 == 0 else 0.62) * R * math.cos(a), (1.0 if i % 2 == 0 else 0.62) * R * math.sin(a), z2))
             for i, a in enumerate(ang)]
    heights = [0.32, 0.29, 0.31, 0.28, 0.32, 0.30]
    tips = [bm.verts.new((1.02 * R * math.cos(2 * j * math.pi / K), 1.02 * R * math.sin(2 * j * math.pi / K), heights[j])) for j in range(K)]
    bm.faces.new(list(reversed(ring0)))
    for a_r, b_r in ((ring0, ring1), (ring1, ring2)):
        for i in range(n):
            bm.faces.new((a_r[i], a_r[(i + 1) % n], b_r[(i + 1) % n], b_r[i]))
    centre = bm.verts.new((0.0, 0.0, z2 + 0.03))
    for j in range(K):
        p, gl, gr, t = ring2[2 * j], ring2[(2 * j - 1) % n], ring2[(2 * j + 1) % n], tips[j]
        bm.faces.new((gl, p, t)); bm.faces.new((p, gr, t))
        bm.faces.new((gr, centre, t)); bm.faces.new((centre, gl, t))
    return finish("F_ring1", bm, lambda f: ORANGE if f.calc_center_median().z < 0.18 else RED)

def main_cone():
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=8, radius=1.0)
    r, z0, bh, th, bend = 0.13, 0.02, 0.08, H - 0.10, 0.03
    for v in bm.verts:
        x, y, z = v.co
        if z >= 0:
            k = (1.0 - z) ** 0.75
            v.co = (x * r * k + bend * z * z, y * r * k, z0 + bh + z * th)
        else:
            v.co = (x * r, y * r, z0 + bh + z * bh)
    def colour(f):
        frac = (f.calc_center_median().z - z0) / (H - z0)
        return YELLOW if frac < 0.45 else (ORANGE if frac < 0.72 else RED)
    return finish("F_main", bm, colour)

parts = [
    base_ring(),
    spike_ring("F_ring2", 6, 30, 0.115, 0.16, 0.165, [0.45, 0.43, 0.46, 0.42, 0.45, 0.44], 0.035, ORANGE, RED),
    spike_ring("F_ring3", 6,  0, 0.070, 0.30, 0.115, [0.56, 0.54, 0.57, 0.55, 0.56, 0.54], 0.028, YELLOW, ORANGE),
    main_cone(),
]
bpy.context.view_layer.update()
for o in parts:
    zs = [v.co.z for v in o.data.vertices]
    print(o.name, "dims", tuple(round(v, 3) for v in o.dimensions), "Z", round(min(zs), 3), "->", round(max(zs), 3), "scale", tuple(o.scale))

# --- Call 19 (same prompt): Flame v6 colours
import bpy
def recolour(name, rule):
    o = bpy.data.objects[name]
    me = o.data
    for p in me.polygons:
        p.material_index = rule(p.center.z)
    me.update()
recolour("F_ring1", lambda z: 1 if z < 0.085 else 2)
recolour("F_ring2", lambda z: 1 if z < 0.24 else 2)
recolour("F_ring3", lambda z: 0 if z < 0.40 else 1)
counts = {n: [sum(1 for p in bpy.data.objects[n].data.polygons if p.material_index == i) for i in range(3)] for n in ("F_ring1", "F_ring2", "F_ring3", "F_main")}
print("faces per colour [yellow, orange, red]:", counts)

# --- Call 20 (my prompt: "the spikes have o be less thin and pointy and more curvier and filling aorung the main centre cone , same for the main centre cone")
# Flame v7: fat, curved tongues instead of thin pyramids, overlapping so they fill around a fatter, curled main cone.
import bpy, bmesh, math
for o in list(bpy.data.objects):
    bpy.data.objects.remove(o, do_unlink=True)
for d in list(bpy.data.meshes):
    if d.users == 0:
        bpy.data.meshes.remove(d)
MATS = ["flame_yellow", "flame_orange", "flame_red"]
YELLOW, ORANGE, RED = 0, 1, 2

def add_tongue(bm, cx, cy, z0, r, bottom_h, top_h, lean, curl, segs, rings, pinch=0.7):
    tmp = bmesh.new()
    bmesh.ops.create_uvsphere(tmp, u_segments=segs, v_segments=rings, radius=1.0)
    m = bpy.data.meshes.new("_tmp")
    tmp.to_mesh(m); tmp.free()
    vmap = {}
    for v in m.vertices:
        x, y, z = v.co
        if z >= 0:
            k = (1.0 - z) ** pinch
            p = (cx + x * r * k + lean[0] * z + curl[0] * z * z,
                 cy + y * r * k + lean[1] * z + curl[1] * z * z,
                 z0 + bottom_h + z * top_h)
        else:
            p = (cx + x * r, cy + y * r, z0 + bottom_h + z * bottom_h)
        vmap[v.index] = bm.verts.new(p)
    for poly in m.polygons:
        bm.faces.new([vmap[i] for i in poly.vertices])
    bpy.data.meshes.remove(m)

def finish(name, bm, colour_of_z):
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    for f in bm.faces:
        f.material_index = colour_of_z(f.calc_center_median().z)
    mesh = bpy.data.meshes.new(name)
    bm.to_mesh(mesh); bm.free()
    o = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(o)
    for mt in MATS:
        o.data.materials.append(bpy.data.materials[mt])
    return o

def tongue_ring(name, count, offset_deg, ring_r, z0, r, bottom_h, heights, out_lean, side_curl, segs, rings, colour):
    bm = bmesh.new()
    for j in range(count):
        a = math.radians(offset_deg) + 2 * math.pi * j / count
        ca, sa = math.cos(a), math.sin(a)
        top_h = heights[j] - z0 - bottom_h
        lean = (out_lean * ca, out_lean * sa)
        curl = (-side_curl * sa, side_curl * ca)
        add_tongue(bm, ring_r * ca, ring_r * sa, z0, r, bottom_h, top_h, lean, curl, segs, rings)
    return finish(name, bm, colour)

def main_cone():
    bm = bmesh.new()
    add_tongue(bm, 0.0, 0.0, 0.0, 0.16, 0.09, 0.53, (0.0, 0.0), (-0.07, 0.0), 8, 6, pinch=0.85)
    return finish("F_main", bm, lambda z: YELLOW if z < 0.28 else (ORANGE if z < 0.46 else RED))

parts = [
    tongue_ring("F_outer", 6, 0,  0.12, 0.00, 0.090, 0.06, [0.36, 0.31, 0.34, 0.30, 0.35, 0.32], 0.03, 0.05, 5, 4,
                lambda z: ORANGE if z < 0.10 else RED),
    tongue_ring("F_inner", 6, 30, 0.07, 0.06, 0.075, 0.06, [0.49, 0.46, 0.50, 0.45, 0.48, 0.47], 0.02, -0.05, 5, 3,
                lambda z: YELLOW if z < 0.24 else ORANGE),
    main_cone(),
]
bpy.context.view_layer.update()
for o in parts:
    zs = [v.co.z for v in o.data.vertices]
    tris = sum(len(p.vertices) - 2 for p in o.data.polygons)
    print(o.name, "dims", tuple(round(v, 3) for v in o.dimensions), "Z", round(min(zs), 3), "->", round(max(zs), 3),
          "tris", tris, "scale", tuple(o.scale))

# --- Calls 21-23 (my prompt: my full written design brief "I want you to redesign my current 3D flame ... rebuild from scratch,
# 7-8 curved broad tongues, 100-150 triangles, max 180, keep parts separate, do not finalize")
# Flame v8 / v8b / v8c: 7-8 separate tongues, each flattened 4/5/6-sided rings along a curved spine closed by a tip vertex.
import bpy, bmesh, math
for o in list(bpy.data.objects):
    bpy.data.objects.remove(o, do_unlink=True)
for d in list(bpy.data.meshes):
    if d.users == 0:
        bpy.data.meshes.remove(d)

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

# The five fire materials used by the final flame were created here (call 21):
for n, h in (("fire_deep_red", "c62a1c"), ("fire_red_orange", "eb5223"), ("fire_orange", "f5901e"),
             ("fire_golden_yellow", "f8bb2c"), ("fire_bright_yellow", "ffe14a")):
    flat_material(n, h)
MATS = [bpy.data.materials[n] for n in ("fire_deep_red", "fire_red_orange", "fire_orange", "fire_golden_yellow", "fire_bright_yellow")]
IDX = {"deep_red": 0, "red_orange": 1, "orange": 2, "gold": 3, "yellow": 4}

def tongue(name, angle_deg, dist, base_z, height, width, depth, sides, levels, radial_lean, side_curl, colours, cap=False):
    a = math.radians(angle_deg)
    rx, ry = math.cos(a), math.sin(a)
    tx, ty = -ry, rx
    cx, cy = dist * rx, dist * ry
    def spine(t):
        return (cx + radial_lean * t * rx + side_curl * t * t * tx, cy + radial_lean * t * ry + side_curl * t * t * ty)
    bm = bmesh.new()
    rings = []
    for t, s in [(0.0, 1.0)] + levels:
        px, py = spine(t)
        ring = []
        for k in range(sides):
            th = 2 * math.pi * k / sides + math.pi / sides
            u, v = width * s * math.cos(th), depth * s * math.sin(th)
            ring.append(bm.verts.new((px + u * tx + v * rx, py + u * ty + v * ry, base_z + t * height)))
        rings.append(ring)
    tpx, tpy = spine(1.0)
    tip = bm.verts.new((tpx, tpy, base_z + height))
    for i, (lo, hi) in enumerate(zip(rings, rings[1:])):
        for k in range(sides):
            bm.faces.new((lo[k], lo[(k + 1) % sides], hi[(k + 1) % sides], hi[k])).material_index = IDX[colours[i]]
    for k in range(sides):
        bm.faces.new((rings[-1][k], rings[-1][(k + 1) % sides], tip)).material_index = IDX[colours[-1]]
    if cap:
        bm.faces.new(list(reversed(rings[0]))).material_index = IDX[colours[0]]
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    mesh = bpy.data.meshes.new(name)
    bm.to_mesh(mesh); bm.free()
    o = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(o)
    for m in MATS:
        o.data.materials.append(m)
    return o

# v8c (the last of the three; v8 had 2-segment tongues + an inner yellow tongue, 145 tris; v8b curled the centre the wrong way):
L3 = [(0.38, 0.58), (0.74, 0.24)]
flames = [
    tongue("Flame_Center",    90,  0.00, 0.00, 0.62, 0.165, 0.140, 6, L3,   0.00,  0.16, ["yellow", "orange", "red_orange"], cap=True),
    tongue("Flame_Outer_01", 195,  0.12, 0.00, 0.28, 0.110, 0.080, 5, L3,   0.10,  0.07, ["red_orange", "deep_red", "deep_red"]),
    tongue("Flame_Outer_02", 340,  0.12, 0.00, 0.25, 0.105, 0.080, 5, L3,   0.10, -0.06, ["red_orange", "deep_red", "deep_red"]),
    tongue("Flame_Outer_03",  75,  0.11, 0.00, 0.31, 0.110, 0.080, 5, L3,   0.09,  0.07, ["red_orange", "deep_red", "deep_red"]),
    tongue("Flame_Middle_01",235,  0.075,0.02, 0.44, 0.095, 0.070, 4, L3,   0.06, -0.10, ["orange", "orange", "red_orange"]),
    tongue("Flame_Middle_02",310,  0.075,0.02, 0.40, 0.090, 0.070, 4, L3,   0.06,  0.09, ["orange", "orange", "red_orange"]),
    tongue("Flame_Middle_03",130,  0.07, 0.02, 0.48, 0.095, 0.070, 4, L3,   0.05,  0.10, ["orange", "orange", "red_orange"]),
]
bpy.context.view_layer.update()
print("TOTAL triangles:", sum(sum(len(p.vertices) - 2 for p in o.data.polygons) for o in flames))   # 169

# =====================================================================================================================
# SINGLE FLAME — the submitted flame (v9). Built from my second written brief: "Start with ONLY ONE flame shape ...
# do NOT create the flame by extruding and scaling a circle upward to a point". Calls 1 (materials) + 21 (fire materials)
# + 25, 27, 28, 29 rebuild it.
# =====================================================================================================================

# --- Call 24 (my prompt: "Stop modifying the current flame ... Delete the current flame geometry after preserving a backup")
import bpy, os
backup = os.path.expanduser("~/Desktop/repos/walker-ninja-firefighter-joe/blender/flame_v8c_backup.blend")
bpy.ops.wm.save_as_mainfile(filepath=backup, copy=True)
print("backup saved:", os.path.basename(backup), os.path.getsize(backup), "bytes | objects in it:", sorted(o.name for o in bpy.data.objects))
for o in list(bpy.data.objects):
    bpy.data.objects.remove(o, do_unlink=True)
for d in list(bpy.data.meshes):
    if d.users == 0:
        bpy.data.meshes.remove(d)
print("objects now:", len(bpy.data.objects), "| open file:", os.path.basename(bpy.data.filepath))

# --- Call 25 (same prompt): single flame v1 (5-sided sections, 40 tris; "closer, but it still looks like a bent horn")
import bpy, bmesh, math
W = 0.17
SIDES = 5
SECTIONS = [(0.05, 0.74, 0.000), (0.17, 1.00, 0.010), (0.36, 0.76, 0.045), (0.51, 0.40, 0.015)]
TIP = (-0.095, 0.0, 0.62)
DEPTH = 0.65
bm = bmesh.new()
bottom = bm.verts.new((0.0, 0.0, 0.0))
rings = []
for z, wf, cx in SECTIONS:
    w = W * wf
    ring = []
    for k in range(SIDES):
        th = 2 * math.pi * k / SIDES
        ring.append(bm.verts.new((cx + w * math.cos(th), DEPTH * w * math.sin(th), z)))
    rings.append(ring)
tip = bm.verts.new(TIP)
for k in range(SIDES):
    bm.faces.new((bottom, rings[0][(k + 1) % SIDES], rings[0][k]))
for lo, hi in zip(rings, rings[1:]):
    for k in range(SIDES):
        bm.faces.new((lo[k], lo[(k + 1) % SIDES], hi[(k + 1) % SIDES], hi[k]))
for k in range(SIDES):
    bm.faces.new((rings[-1][k], rings[-1][(k + 1) % SIDES], tip))
bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
mesh = bpy.data.meshes.new("Flame_Single")
bm.to_mesh(mesh); bm.free()
o = bpy.data.objects.new("Flame_Single", mesh)
bpy.context.collection.objects.link(o)

# --- Calls 26-27 (my prompt: "This is closer, but I don't approve the shape yet. It still looks like a bent horn ...
# Base ... Middle ... Tip ... Depth ... Proportions ..."). Call 26 was a first try with a vertical right side;
# call 27 (below) is the APPROVED shape: separate left/right half-widths per section give the S-curve.
import bpy, bmesh, math
old = bpy.data.objects.get("Flame_Single")
if old:
    bpy.data.objects.remove(old, do_unlink=True)
for d in list(bpy.data.meshes):
    if d.users == 0:
        bpy.data.meshes.remove(d)

W = 0.18
SIDES = 6
# (z, centre x, left half-width, right half-width, depth)
SECTIONS = [
    (0.060,  0.000, 0.72, 0.72, 0.85),   # rounds the bottom off
    (0.200,  0.000, 1.00, 1.00, 0.85),   # belly, widest, ~1/3 of the height
    (0.350,  0.015, 0.64, 0.80, 0.75),   # right curves in steadily, left curves in more (S)
    (0.490, -0.040, 0.44, 0.48, 0.60),   # moving left: curl begins
]
TIP = (-0.15, 0.0, 0.62)

bm = bmesh.new()
bottom = bm.verts.new((0.0, 0.0, 0.0))
rings = []
for z, cx, wl, wr, dep in SECTIONS:
    mean_w = W * (wl + wr) / 2
    ring = []
    for k in range(SIDES):
        th = 2 * math.pi * k / SIDES
        c = math.cos(th)
        ring.append(bm.verts.new((cx + (W * wr if c >= 0 else W * wl) * c, dep * mean_w * math.sin(th), z)))
    rings.append(ring)
tip = bm.verts.new(TIP)
for k in range(SIDES):
    bm.faces.new((bottom, rings[0][(k + 1) % SIDES], rings[0][k]))
for lo, hi in zip(rings, rings[1:]):
    for k in range(SIDES):
        bm.faces.new((lo[k], lo[(k + 1) % SIDES], hi[(k + 1) % SIDES], hi[k]))
for k in range(SIDES):
    bm.faces.new((rings[-1][k], rings[-1][(k + 1) % SIDES], tip))
bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
mesh = bpy.data.meshes.new("Flame_Single")
bm.to_mesh(mesh); bm.free()
o = bpy.data.objects.new("Flame_Single", mesh)
bpy.context.collection.objects.link(o)
bpy.context.view_layer.update()
print("Flame_Single | triangles", sum(len(p.vertices) - 2 for p in mesh.polygons), "| dims", tuple(round(v, 3) for v in o.dimensions))

# --- Call 28 (my prompt: "ok now add the colours")
# Each face gets a colour from: its height (0 bottom .. 1 tip) + 0.30 if it faces sideways rather than front/back.
import bpy
o = bpy.data.objects["Flame_Single"]
me = o.data
names = ["fire_bright_yellow", "fire_golden_yellow", "fire_orange", "fire_red_orange", "fire_deep_red"]
me.materials.clear()
for n in names:
    me.materials.append(bpy.data.materials[n])
H = 0.62
counts = [0] * 5
for p in me.polygons:
    h = p.center.z / H
    side = abs(p.normal.x) > abs(p.normal.y)
    score = h + (0.30 if side else 0.0)
    idx = 0 if score < 0.30 else 1 if score < 0.45 else 2 if score < 0.62 else 3 if score < 0.82 else 4
    p.material_index = idx
    counts[idx] += 1
me.update()
print("faces per colour:", dict(zip(names, counts)))

# --- Call 29 (my prompt: "this is good enough, update all the docs")
# Finalise: name "Flame", origin at the bottom centre (world origin), transforms applied, save.
import bpy, os
o = bpy.data.objects["Flame_Single"]
o.name = o.data.name = "Flame"
bpy.ops.object.select_all(action="DESELECT")
o.select_set(True)
bpy.context.view_layer.objects.active = o
bpy.context.scene.cursor.location = (0, 0, 0)
bpy.ops.object.origin_set(type="ORIGIN_CURSOR")
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
zs = [v.co.z for v in o.data.vertices]
print("name", o.name, "| triangles", sum(len(p.vertices) - 2 for p in o.data.polygons), "| dims", tuple(round(v, 3) for v in o.dimensions),
      "| location", tuple(o.location), "| scale", tuple(o.scale), "| min_z", round(min(zs), 4), "max_z", round(max(zs), 4))
path = os.path.expanduser("~/Desktop/repos/walker-ninja-firefighter-joe/blender/flame.blend")
bpy.ops.wm.save_as_mainfile(filepath=path)
# Result: Flame | 48 triangles | 0.36 x 0.265 x 0.62 m | location 0,0,0 | rotation 0 | scale 1 | min_z 0.0 max_z 0.62
