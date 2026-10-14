"""Rescue bag — every execute_blender_code body sent through the Blender MCP on 2026-10-14, in order.

v1 (calls 1-5, prompt "ok"): cylinder body + flap + ring handle. Numbers passed (264 tris, 0.60 x 0.28 x 0.30 m),
but in my viewport check it read as a barrel/log, and the handle was buried inside the body.
v2 (calls 6-11, prompt "ok build v2"): oval body + two strap handles + zip line. 248 tris, 0.60 x 0.30 x 0.332 m.
Read as a bag, but I asked what it is for: it rides on Extinguisho's back, so we tried a backpack.
Saved as blender/rescue_bag_v2_duffel.blend (the file was renamed after call 11 saved it as rescue_bag.blend).
v3 (calls 12-16, prompt "lets try and see what we like"): boxy backpack, 292 tris, 0.38 x 0.346 x 0.59 m. Read as a
backpack but "more like a box".
v4 (calls 17-21, prompt "no i need you to make it look less boxy"): rounded backpack, 296 tris, 0.36 x 0.306 x 0.612 m,
origin (0, 0, 0), rotation 0, scale 1, min Z 0, max Z 0.612. This is the submitted asset: blender/rescue_bag.blend
(call 21 saved it as rescue_bag_backpack.blend, renamed afterwards). Calls 12 and 17-21 rebuild it.
"""

# ======================= v1 (replaced) =======================

# --- Call 1: Step 0: new empty scene for the bag, metric units, flat-colour materials
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

flat_material("bag_orange", "e67e22")
flat_material("bag_seam", "b8621b")
flat_material("bag_handle", "1b2230")
print("objects:", len(bpy.data.objects), "| units:", scene.unit_settings.system,
      "| materials:", sorted(m.name for m in bpy.data.materials))

# --- Call 2: Part 1: duffel body, cylinder 16 sides lying along X, r 0.14, length 0.60, resting on the floor (Z 0 -> 0.28)
import bpy, math
bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.14, depth=0.60, location=(0, 0, 0.14), rotation=(0, math.pi / 2, 0))
o = bpy.context.object
o.name = "B_body"
o.data.materials.append(bpy.data.materials["bag_orange"])
print(o.name, "loc", tuple(round(v, 3) for v in o.location), "dims", tuple(round(v, 3) for v in o.dimensions),
      "rot_deg", tuple(round(math.degrees(v), 1) for v in o.rotation_euler), "scale", tuple(o.scale))

# --- Call 3: Part 2: top flap, box 0.36 x 0.16 x 0.025 on top of the body (Z 0.26 -> 0.285), sized by its vertices (scale stays 1)
import bpy, bmesh
mesh = bpy.data.meshes.new("B_flap")
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
bmesh.ops.scale(bm, vec=(0.36, 0.16, 0.025), verts=bm.verts)
bm.to_mesh(mesh)
bm.free()
o = bpy.data.objects.new("B_flap", mesh)
bpy.context.collection.objects.link(o)
o.location = (0, 0, 0.2725)
o.data.materials.append(bpy.data.materials["bag_seam"])
bpy.context.view_layer.update()
print(o.name, "loc", tuple(round(v, 4) for v in o.location), "dims", tuple(round(v, 3) for v in o.dimensions), "scale", tuple(o.scale))

# --- Call 4: Part 3: handle, torus 16 x 6, major r 0.06, minor r 0.012, standing upright in the XZ plane, top at Z 0.30
import bpy, math
bpy.ops.mesh.primitive_torus_add(major_segments=16, minor_segments=6, major_radius=0.06, minor_radius=0.012,
                                 location=(0, 0, 0.228), rotation=(math.pi / 2, 0, 0))
o = bpy.context.object
o.name = "B_handle"
o.data.materials.append(bpy.data.materials["bag_handle"])
print(o.name, "loc", tuple(round(v, 3) for v in o.location), "dims", tuple(round(v, 3) for v in o.dimensions),
      "rot_deg", tuple(round(math.degrees(v), 1) for v in o.rotation_euler), "scale", tuple(o.scale))

# --- Call 5: Finish: join into one object "RescueBag", origin at bottom centre (world origin), apply rotation and scale, report
import bpy, bmesh
parts = [o for o in bpy.data.objects if o.name.startswith("B_")]
bpy.ops.object.select_all(action="DESELECT")
for p in parts:
    p.select_set(True)
bpy.context.view_layer.objects.active = bpy.data.objects["B_body"]
bpy.ops.object.join()
b = bpy.context.object
b.name = b.data.name = "RescueBag"
bpy.context.scene.cursor.location = (0, 0, 0)
bpy.ops.object.origin_set(type="ORIGIN_CURSOR")
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

bm = bmesh.new()
bm.from_object(b, bpy.context.evaluated_depsgraph_get())
bmesh.ops.triangulate(bm, faces=bm.faces[:])
tris = len(bm.faces)
zs = [v.co.z for v in bm.verts]
bm.free()
print("name", b.name, "| triangles", tris, "| dims", tuple(round(v, 3) for v in b.dimensions),
      "| location", tuple(b.location), "| rotation", tuple(round(v, 6) for v in b.rotation_euler), "| scale", tuple(b.scale),
      "| min_z", round(min(zs), 4), "max_z", round(max(zs), 4),
      "| materials", [m.name for m in b.data.materials])

# ======================= v2 (submitted) =======================

# --- Call 6: v2 Step 0: clear the v1 bag, keep the scene metric; materials (orange body, dark handles and zip)
import bpy
for o in list(bpy.data.objects):
    bpy.data.objects.remove(o, do_unlink=True)
for coll in (bpy.data.meshes, bpy.data.materials):
    for d in list(coll):
        if d.users == 0:
            coll.remove(d)

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

flat_material("bag_orange", "e67e22")
flat_material("bag_dark", "1b2230")
bpy.context.scene.cursor.location = (0, 0, 0)
print("objects:", len(bpy.data.objects), "| materials:", sorted(m.name for m in bpy.data.materials),
      "| units:", bpy.context.scene.unit_settings.system)

# --- Call 7: v2 Part 1: body, 12-sided cylinder along X, r 0.15, squashed in Z to 0.8 (oval 0.30 deep x 0.24 tall), resting on the floor
import bpy, bmesh, math
bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.15, depth=0.60, location=(0, 0, 0), rotation=(0, math.pi / 2, 0))
o = bpy.context.object
o.name = "B_body"
bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)   # bake the lying-down rotation into the mesh
bm = bmesh.new()
bm.from_mesh(o.data)
bmesh.ops.scale(bm, vec=(1.0, 1.0, 0.8), verts=bm.verts)                       # squash the vertices, object scale stays 1
bm.to_mesh(o.data)
bm.free()
o.location = (0, 0, 0.12)
o.data.materials.append(bpy.data.materials["bag_orange"])
bpy.context.view_layer.update()
print(o.name, "loc", tuple(round(v, 3) for v in o.location), "dims", tuple(round(v, 3) for v in o.dimensions),
      "rot", tuple(round(v, 4) for v in o.rotation_euler), "scale", tuple(o.scale))

# --- Call 8: v2 Parts 2-3: two strap handles, torus 12 x 4, major r 0.08, minor r 0.012, upright in the YZ plane
# (crossing the bag's width), centred on the body top (Z 0.24) at X = -0.13 and +0.13, so half of each ring arches above
import bpy, math
for side, name in ((-1, "B_handle_L"), (1, "B_handle_R")):
    bpy.ops.mesh.primitive_torus_add(major_segments=12, minor_segments=4, major_radius=0.08, minor_radius=0.012,
                                     location=(side * 0.13, 0, 0.24), rotation=(0, math.pi / 2, 0))
    o = bpy.context.object
    o.name = name
    o.data.materials.append(bpy.data.materials["bag_dark"])
    print(o.name, "loc", tuple(round(v, 3) for v in o.location), "dims", tuple(round(v, 3) for v in o.dimensions),
          "rot_deg", tuple(round(math.degrees(v), 1) for v in o.rotation_euler), "scale", tuple(o.scale))

# --- Call 9: v2 Part 4: zip line, thin dark box 0.50 x 0.02 x 0.01 along X on the top of the body, sized by its vertices (scale stays 1)
import bpy, bmesh
mesh = bpy.data.meshes.new("B_zip")
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
bmesh.ops.scale(bm, vec=(0.50, 0.02, 0.01), verts=bm.verts)
bm.to_mesh(mesh)
bm.free()
o = bpy.data.objects.new("B_zip", mesh)
bpy.context.collection.objects.link(o)
o.location = (0, 0, 0.24)
o.data.materials.append(bpy.data.materials["bag_dark"])
bpy.context.view_layer.update()
print(o.name, "loc", tuple(round(v, 3) for v in o.location), "dims", tuple(round(v, 3) for v in o.dimensions), "scale", tuple(o.scale))

# --- Call 10: v2 Finish: join into one object "RescueBag", origin at bottom centre (world origin), apply rotation and scale, report
import bpy, bmesh
parts = [o for o in bpy.data.objects if o.name.startswith("B_")]
bpy.ops.object.select_all(action="DESELECT")
for p in parts:
    p.select_set(True)
bpy.context.view_layer.objects.active = bpy.data.objects["B_body"]
bpy.ops.object.join()
b = bpy.context.object
b.name = b.data.name = "RescueBag"
bpy.context.scene.cursor.location = (0, 0, 0)
bpy.ops.object.origin_set(type="ORIGIN_CURSOR")
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

bm = bmesh.new()
bm.from_object(b, bpy.context.evaluated_depsgraph_get())
bmesh.ops.triangulate(bm, faces=bm.faces[:])
tris = len(bm.faces)
zs = [v.co.z for v in bm.verts]
bm.free()
print("name", b.name, "| triangles", tris, "| dims", tuple(round(v, 3) for v in b.dimensions),
      "| location", tuple(b.location), "| rotation", tuple(round(v, 6) for v in b.rotation_euler), "| scale", tuple(b.scale),
      "| min_z", round(min(zs), 4), "max_z", round(max(zs), 4),
      "| materials", [m.name for m in b.data.materials])

# --- Call 11: Save this asset's source file
import bpy, os
path = os.path.expanduser("~/Desktop/repos/walker-ninja-firefighter-joe/blender/rescue_bag.blend")
bpy.ops.wm.save_as_mainfile(filepath=path)
print("saved", os.path.basename(path), os.path.getsize(path), "bytes")

# ======================= v3 boxy backpack (replaced) =======================

# --- Call 12: v3 backpack Step 0: new empty scene (the duffel v2 is already saved in rescue_bag.blend), materials
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

flat_material("bag_orange", "e67e22")
flat_material("bag_seam", "b8621b")
flat_material("bag_dark", "1b2230")
print("objects:", len(bpy.data.objects), "| materials:", sorted(m.name for m in bpy.data.materials))

# --- Call 13: v3 Parts 1-3: three boxes sized by their vertices (scale stays 1). Front of the pack faces -Y, the wearer's back side is +Y.
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

parts = [
    box("P_body",   (0.36, 0.22, 0.50),  (0, 0, 0.25),      "bag_orange"),   # Z 0 -> 0.50
    box("P_pocket", (0.26, 0.06, 0.20),  (0, -0.14, 0.18),  "bag_seam"),     # on the front, Z 0.08 -> 0.28
    box("P_lid",    (0.38, 0.24, 0.06),  (0, 0, 0.50),      "bag_orange"),   # over the top edge, Z 0.47 -> 0.53
]
bpy.context.view_layer.update()
for o in parts:
    print(o.name, "loc", tuple(round(v, 3) for v in o.location), "dims", tuple(round(v, 3) for v in o.dimensions), "scale", tuple(o.scale))

# --- Call 14: v3 Parts 4-5: two shoulder straps on the back (+Y), torus 12 x 4, major r 0.15, minor r 0.015, upright in the YZ plane,
# centred on the back face at X = -0.10 / +0.10, Z 0.25; squashed to 0.4 in Y so the loops sit close to the pack
# Part 6: grab handle on top, torus 8 x 4, major r 0.05, minor r 0.01, upright in the XZ plane on the lid
import bpy, bmesh, math

def ring(name, major_seg, minor_seg, R, r, loc, rot, squash_y, mat):
    bpy.ops.mesh.primitive_torus_add(major_segments=major_seg, minor_segments=minor_seg, major_radius=R, minor_radius=r,
                                     location=(0, 0, 0), rotation=rot)
    o = bpy.context.object
    o.name = name
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    if squash_y != 1.0:
        bm = bmesh.new()
        bm.from_mesh(o.data)
        bmesh.ops.scale(bm, vec=(1.0, squash_y, 1.0), verts=bm.verts)
        bm.to_mesh(o.data)
        bm.free()
    o.location = loc
    o.data.materials.append(bpy.data.materials[mat])
    return o

made = [
    ring("P_strap_L", 12, 4, 0.15, 0.015, (-0.10, 0.11, 0.25), (0, math.pi / 2, 0), 0.4, "bag_dark"),
    ring("P_strap_R", 12, 4, 0.15, 0.015, ( 0.10, 0.11, 0.25), (0, math.pi / 2, 0), 0.4, "bag_dark"),
    ring("P_handle",   8, 4, 0.05, 0.010, ( 0.00, 0.05, 0.53), (math.pi / 2, 0, 0), 1.0, "bag_dark"),
]
bpy.context.view_layer.update()
for o in made:
    print(o.name, "loc", tuple(round(v, 3) for v in o.location), "dims", tuple(round(v, 3) for v in o.dimensions),
          "rot", tuple(round(v, 4) for v in o.rotation_euler), "scale", tuple(o.scale))

# --- Call 15: v3 Finish: join into one object "RescueBag", origin at bottom centre (world origin), apply transforms, report
import bpy, bmesh
parts = [o for o in bpy.data.objects if o.name.startswith("P_")]
bpy.ops.object.select_all(action="DESELECT")
for p in parts:
    p.select_set(True)
bpy.context.view_layer.objects.active = bpy.data.objects["P_body"]
bpy.ops.object.join()
b = bpy.context.object
b.name = b.data.name = "RescueBag"
bpy.context.scene.cursor.location = (0, 0, 0)
bpy.ops.object.origin_set(type="ORIGIN_CURSOR")
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

bm = bmesh.new()
bm.from_object(b, bpy.context.evaluated_depsgraph_get())
bmesh.ops.triangulate(bm, faces=bm.faces[:])
tris = len(bm.faces)
zs = [v.co.z for v in bm.verts]
bm.free()
print("name", b.name, "| triangles", tris, "| dims", tuple(round(v, 3) for v in b.dimensions),
      "| location", tuple(b.location), "| rotation", tuple(round(v, 6) for v in b.rotation_euler), "| scale", tuple(b.scale),
      "| min_z", round(min(zs), 4), "max_z", round(max(zs), 4),
      "| materials", [m.name for m in b.data.materials])

# --- Call 16: Save the backpack try as its own file (the duffel stays in rescue_bag.blend)
import bpy, os
path = os.path.expanduser("~/Desktop/repos/walker-ninja-firefighter-joe/blender/rescue_bag_backpack.blend")
bpy.ops.wm.save_as_mainfile(filepath=path)
print("saved", os.path.basename(path), os.path.getsize(path), "bytes")

# ======================= v4 rounded backpack (submitted) =======================

# --- Call 17: v4 (rounded backpack) Step 0: clear the boxy v3 (kept in rescue_bag_backpack.blend's saved copy + picture), keep materials
import bpy
for o in list(bpy.data.objects):
    bpy.data.objects.remove(o, do_unlink=True)
for d in list(bpy.data.meshes):
    if d.users == 0:
        bpy.data.meshes.remove(d)
bpy.context.scene.cursor.location = (0, 0, 0)
print("objects:", len(bpy.data.objects), "| materials:", sorted(m.name for m in bpy.data.materials))

# --- Call 18: v4 Parts 1-3, each sized by its vertices (object scale stays 1). Front faces -Y, the wearer's back is +Y.
# 1 body: upright 12-sided tube, oval 0.36 x 0.22, Z 0 -> 0.48, top ring narrowed (x 0.85, y 0.9) so it tapers
# 2 top flap: dome (UV sphere 8 x 4) squashed to 0.34 x 0.22 x 0.18, centred on the body top, so the top is rounded
# 3 front pocket: 8-sided tube along Y, oval 0.24 wide x 0.20 tall, 0.08 deep, half sunk into the front, Z 0.07 -> 0.27
import bpy, bmesh, math

def make(name, build, mat, loc):
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    build(bm)
    bm.to_mesh(mesh)
    bm.free()
    o = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(o)
    o.location = loc
    o.data.materials.append(bpy.data.materials[mat])
    return o

def body(bm):
    bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=12, radius1=1.0, radius2=1.0, depth=0.48)
    bmesh.ops.scale(bm, vec=(0.18, 0.11, 1.0), verts=bm.verts)
    bmesh.ops.translate(bm, vec=(0, 0, 0.24), verts=bm.verts)
    top = [v for v in bm.verts if v.co.z > 0.47]
    bmesh.ops.scale(bm, vec=(0.85, 0.9, 1.0), verts=top)

def dome(bm):
    bmesh.ops.create_uvsphere(bm, u_segments=8, v_segments=4, radius=1.0)
    bmesh.ops.scale(bm, vec=(0.17, 0.11, 0.09), verts=bm.verts)

def pocket(bm):
    bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=8, radius1=1.0, radius2=1.0, depth=0.08)
    bmesh.ops.rotate(bm, cent=(0, 0, 0), matrix=__import__("mathutils").Matrix.Rotation(math.pi / 2, 3, "X"), verts=bm.verts)
    bmesh.ops.scale(bm, vec=(0.12, 1.0, 0.10), verts=bm.verts)

parts = [
    make("P_body",   body,   "bag_orange", (0, 0, 0)),
    make("P_flap",   dome,   "bag_seam",   (0, 0, 0.48)),
    make("P_pocket", pocket, "bag_seam",   (0, -0.10, 0.17)),
]
bpy.context.view_layer.update()
for o in parts:
    print(o.name, "loc", tuple(round(v, 3) for v in o.location), "dims", tuple(round(v, 3) for v in o.dimensions), "scale", tuple(o.scale))

# --- Call 19: v4 Parts 4-6: two shoulder straps on the back (+Y): torus 8 x 4, major r 0.15, minor r 0.015, upright in the YZ plane,
# squashed to 0.4 in Y, at X -0.09 / +0.09, centred on the back surface (Y 0.10), Z 0.24
# grab handle: torus 6 x 4, major r 0.05, minor r 0.01, upright in the XZ plane, on top of the dome (Z 0.56), Y 0.03
import bpy, bmesh, math

def ring(name, major_seg, minor_seg, R, r, loc, rot, squash_y, mat):
    bpy.ops.mesh.primitive_torus_add(major_segments=major_seg, minor_segments=minor_seg, major_radius=R, minor_radius=r,
                                     location=(0, 0, 0), rotation=rot)
    o = bpy.context.object
    o.name = name
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    if squash_y != 1.0:
        bm = bmesh.new()
        bm.from_mesh(o.data)
        bmesh.ops.scale(bm, vec=(1.0, squash_y, 1.0), verts=bm.verts)
        bm.to_mesh(o.data)
        bm.free()
    o.location = loc
    o.data.materials.append(bpy.data.materials[mat])
    return o

made = [
    ring("P_strap_L", 8, 4, 0.15, 0.015, (-0.09, 0.10, 0.24), (0, math.pi / 2, 0), 0.4, "bag_dark"),
    ring("P_strap_R", 8, 4, 0.15, 0.015, ( 0.09, 0.10, 0.24), (0, math.pi / 2, 0), 0.4, "bag_dark"),
    ring("P_handle",  6, 4, 0.05, 0.010, ( 0.00, 0.03, 0.56), (math.pi / 2, 0, 0), 1.0, "bag_dark"),
]
bpy.context.view_layer.update()
for o in made:
    print(o.name, "loc", tuple(round(v, 3) for v in o.location), "dims", tuple(round(v, 3) for v in o.dimensions), "scale", tuple(o.scale))

# --- Call 20: v4 Finish: join into one object "RescueBag", origin at bottom centre (world origin), apply transforms, report
import bpy, bmesh
parts = [o for o in bpy.data.objects if o.name.startswith("P_")]
bpy.ops.object.select_all(action="DESELECT")
for p in parts:
    p.select_set(True)
bpy.context.view_layer.objects.active = bpy.data.objects["P_body"]
bpy.ops.object.join()
b = bpy.context.object
b.name = b.data.name = "RescueBag"
bpy.context.scene.cursor.location = (0, 0, 0)
bpy.ops.object.origin_set(type="ORIGIN_CURSOR")
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

bm = bmesh.new()
bm.from_object(b, bpy.context.evaluated_depsgraph_get())
bmesh.ops.triangulate(bm, faces=bm.faces[:])
tris = len(bm.faces)
zs = [v.co.z for v in bm.verts]
bm.free()
print("name", b.name, "| triangles", tris, "| dims", tuple(round(v, 3) for v in b.dimensions),
      "| location", tuple(b.location), "| rotation", tuple(round(v, 6) for v in b.rotation_euler), "| scale", tuple(b.scale),
      "| min_z", round(min(zs), 4), "max_z", round(max(zs), 4),
      "| materials", [m.name for m in b.data.materials])

# --- Call 21: Save the rounded backpack over the boxy try (the boxy one is kept as a picture: evidence/bag-angles-v3-backpack.png)
import bpy, os
path = os.path.expanduser("~/Desktop/repos/walker-ninja-firefighter-joe/blender/rescue_bag_backpack.blend")
bpy.ops.wm.save_as_mainfile(filepath=path)
print("saved", os.path.basename(path), os.path.getsize(path), "bytes")
