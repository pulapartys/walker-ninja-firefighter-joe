"""Fire hydrant — every execute_blender_code body sent through the Blender MCP on 2026-10-14, in order.

Each block below was one MCP call (the user's prompt for every call: "ok", approving the plan).
Running this whole file in Blender's Scripting workspace rebuilds the same asset.
Reports from the session: 6 parts, then joined: 356 triangles, 0.40 x 0.36 x 0.80 m,
origin (0, 0, 0), rotation 0, scale 1, 1, 1, min Z 0.0, max Z 0.8.
"""

# --- Call 1: Step 0: empty scene, metric units, flat-colour materials for the hydrant
import bpy

if bpy.context.object and bpy.context.object.mode != "OBJECT":
    bpy.ops.object.mode_set(mode="OBJECT")
for o in list(bpy.data.objects):
    bpy.data.objects.remove(o, do_unlink=True)
for coll in (bpy.data.meshes, bpy.data.materials, bpy.data.cameras, bpy.data.lights):
    for d in list(coll):
        if d.users == 0:
            coll.remove(d)

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

flat_material("hydrant_red", "c0392b")
flat_material("hydrant_grey", "9aa3ab")
print("objects:", len(bpy.data.objects), "| units:", scene.unit_settings.system, scene.unit_settings.scale_length,
      "| materials:", [m.name for m in bpy.data.materials])

# --- Call 2: Part 1: base flange, cylinder 16 sides, r 0.18, Z 0 -> 0.08
import bpy
bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.18, depth=0.08, location=(0, 0, 0.04))
o = bpy.context.object
o.name = "H_base"
o.data.materials.append(bpy.data.materials["hydrant_red"])
print(o.name, "loc", tuple(round(v, 3) for v in o.location), "dims", tuple(round(v, 3) for v in o.dimensions), "scale", tuple(o.scale))

# --- Call 3: Part 2: body, cylinder 16 sides, r 0.12, Z 0.08 -> 0.62
import bpy
bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.12, depth=0.54, location=(0, 0, 0.35))
o = bpy.context.object
o.name = "H_body"
o.data.materials.append(bpy.data.materials["hydrant_red"])
print(o.name, "loc", tuple(round(v, 3) for v in o.location), "dims", tuple(round(v, 3) for v in o.dimensions), "scale", tuple(o.scale))

# --- Call 4: Part 3: rounded cap, UV sphere 12 x 6, r 0.12, centred on the body top (Z 0.62)
import bpy
bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=6, radius=0.12, location=(0, 0, 0.62))
o = bpy.context.object
o.name = "H_cap"
o.data.materials.append(bpy.data.materials["hydrant_red"])
print(o.name, "loc", tuple(round(v, 3) for v in o.location), "dims", tuple(round(v, 3) for v in o.dimensions), "scale", tuple(o.scale))

# --- Call 5: Part 4: top nut, cylinder 8 sides, r 0.035, Z 0.72 -> 0.80
import bpy
bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.035, depth=0.08, location=(0, 0, 0.76))
o = bpy.context.object
o.name = "H_nut"
o.data.materials.append(bpy.data.materials["hydrant_grey"])
print(o.name, "loc", tuple(round(v, 3) for v in o.location), "dims", tuple(round(v, 3) for v in o.dimensions), "scale", tuple(o.scale))

# --- Call 6: Parts 5-6: side outlets, cylinder 12 sides, r 0.05, lying along X, reaching x = +/-0.20, at Z 0.45
import bpy, math
for side, name in ((-1, "H_outlet_L"), (1, "H_outlet_R")):
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.05, depth=0.16,
                                        location=(side * 0.12, 0, 0.45), rotation=(0, math.pi / 2, 0))
    o = bpy.context.object
    o.name = name
    o.data.materials.append(bpy.data.materials["hydrant_grey"])
    print(o.name, "loc", tuple(round(v, 3) for v in o.location), "dims", tuple(round(v, 3) for v in o.dimensions),
          "rot_deg", tuple(round(math.degrees(v), 1) for v in o.rotation_euler), "scale", tuple(o.scale))

# --- Call 7: Finish: join into one object "Hydrant", origin at bottom centre (world origin), apply rotation and scale, report
import bpy, bmesh
parts = [o for o in bpy.data.objects if o.name.startswith("H_")]
bpy.ops.object.select_all(action="DESELECT")
for p in parts:
    p.select_set(True)
bpy.context.view_layer.objects.active = bpy.data.objects["H_body"]
bpy.ops.object.join()
h = bpy.context.object
h.name = h.data.name = "Hydrant"
bpy.context.scene.cursor.location = (0, 0, 0)
bpy.ops.object.origin_set(type="ORIGIN_CURSOR")
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

bm = bmesh.new()
bm.from_object(h, bpy.context.evaluated_depsgraph_get())
bmesh.ops.triangulate(bm, faces=bm.faces[:])
tris = len(bm.faces)
zs = [v.co.z for v in bm.verts]
bm.free()
print("name", h.name, "| triangles", tris, "| dims", tuple(round(v, 3) for v in h.dimensions),
      "| location", tuple(h.location), "| rotation", tuple(h.rotation_euler), "| scale", tuple(h.scale),
      "| min_z", round(min(zs), 4), "max_z", round(max(zs), 4),
      "| materials", [m.name for m in h.data.materials])

# --- Call 8: Save this asset's source file
import bpy, os
path = os.path.expanduser("~/Desktop/repos/walker-ninja-firefighter-joe/blender/hydrant.blend")
bpy.ops.wm.save_as_mainfile(filepath=path)
print("saved", os.path.basename(path), os.path.getsize(path), "bytes")
