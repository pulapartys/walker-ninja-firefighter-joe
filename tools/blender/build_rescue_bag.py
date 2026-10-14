"""Rescue bag — every execute_blender_code body sent through the Blender MCP on 2026-10-14, in order.

v1 (calls 1-5, prompt "ok"): cylinder body + flap + ring handle. Numbers passed (264 tris, 0.60 x 0.28 x 0.30 m),
but in my viewport check it read as a barrel/log, and the handle was buried inside the body.
v2 (calls 6-11, prompt "ok build v2"): oval body + two strap handles + zip line. 248 tris, 0.60 x 0.30 x 0.332 m,
origin (0, 0, 0), rotation 0, scale 1, min Z 0, max Z 0.332. The saved .blend is v2.
Running only the v2 section (from call 6) in Blender's Scripting workspace rebuilds the submitted asset.
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
