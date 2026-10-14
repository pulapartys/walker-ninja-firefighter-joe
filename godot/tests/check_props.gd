## A3 headless check of the three props in scenes3d/props_room.tscn.
##   timeout 120 godot --headless --path godot --script res://tests/check_props.gd --fixed-fps 60
##   ... -- mutate     (deliberately breaks the scene in memory: the check must then FAIL all three props)
## For each prop it prints, beside my brief (latest CHANGE-BRIEF revision, in Godot axes W x H x D):
##   - the GLOBAL bounding box (every MeshInstance3D's AABB pushed through its global transform,
##     so a rotated or scaled node cannot hide behind a correct-looking mesh),
##   - the scale of the prop node and of every mesh node under it,
##   - which world axis the prop's height lies along (Y = upright),
##   - the bottom of the prop compared with the floor's surface (sits on it / floats / sinks),
##   - the triangle count from the imported index buffers, against my budget.
## What it does NOT show: whether the props look right, read as a hydrant / backpack / flame,
## have the right colours, or suit the game's style. Those are my human checks.
extends SceneTree

const TOL := 0.01  # metres
const PROPS := {
	"Hydrant":   {"brief": Vector3(0.40, 0.80, 0.36),  "budget": 400},
	"RescueBag": {"brief": Vector3(0.36, 0.612, 0.306), "budget": 300},
	"Flame":     {"brief": Vector3(0.36, 0.62, 0.265),  "budget": 400},
}

func _initialize() -> void:
	var scene: Node3D = load("res://scenes3d/props_room.tscn").instantiate()
	root.add_child(scene)
	var mutate := "mutate" in OS.get_cmdline_user_args()
	if mutate:
		# Planted faults: the check must catch every one of them.
		scene.get_node("Hydrant").rotate_z(PI / 2)            # lying on its side (prediction P1)
		scene.get_node("RescueBag").scale = Vector3(2, 2, 2)  # scale not 1 (wrong size)
		scene.get_node("Flame").position.y -= 0.2             # sunk into the floor (prediction P2)
		print("MUTATE MODE: hydrant rotated 90 deg, bag scaled x2, flame lowered 0.2 m")
	await process_frame

	var floor: MeshInstance3D = scene.get_node("Floor")
	var floor_y: float = _global_aabb(floor).end.y   # the top of the floor plane (a flat plane: its top IS its surface)
	print("Floor surface at y = %.4f (plane %s, its own scale %s)" % [floor_y, floor.mesh.size, floor.scale])

	var failures := 0
	for name in PROPS:
		var node: Node3D = scene.get_node(name)
		var spec: Dictionary = PROPS[name]
		var brief: Vector3 = spec.brief
		var budget: int = spec.budget
		var box := _global_aabb(node)
		var size := box.size
		var scales: Array = [node.scale]
		var tris := 0
		for mi in _meshes(node):
			scales.append(mi.global_transform.basis.get_scale())
			tris += _triangles(mi.mesh)
		var all_one: bool = scales.all(func(s): return s.is_equal_approx(Vector3.ONE))
		var tallest: String = "X" if size.x >= size.y and size.x >= size.z else ("Y" if size.y >= size.z else "Z")
		var bottom_gap: float = box.position.y - floor_y
		var on_floor: bool = absf(bottom_gap) <= TOL
		var diff: Vector3 = (size - brief).abs()
		var size_ok: bool = diff.x <= TOL and diff.y <= TOL and diff.z <= TOL
		var upright: bool = tallest == "Y" and node.global_transform.basis.y.normalized().is_equal_approx(Vector3.UP)
		var ok: bool = size_ok and all_one and upright and on_floor and tris <= budget
		if not ok:
			failures += 1
		print("%-9s | size W×H×D %.3f × %.3f × %.3f m (brief %.3f × %.3f × %.3f) %s | scale %s | height along %s %s | bottom %+.4f m vs floor %s | tris %d / %d %s | %s" % [
			name, size.x, size.y, size.z, brief.x, brief.y, brief.z, "ok" if size_ok else "OFF",
			"1,1,1" if all_one else str(scales), tallest, "(upright)" if upright else "(NOT upright)",
			bottom_gap, "on it" if on_floor else ("FLOATS" if bottom_gap > 0 else "SINKS"),
			tris, budget, "ok" if tris <= budget else "OVER", "PASS" if ok else "FAIL"])
	print("RESULT: %s (%d of %d props failing)%s" % ["PASS" if failures == 0 else "FAIL", failures, PROPS.size(), " [mutate mode]" if mutate else ""])
	quit(1 if failures > 0 else 0)

func _meshes(n: Node) -> Array:
	var out: Array = []
	if n is MeshInstance3D:
		out.append(n)
	for c in n.get_children():
		out.append_array(_meshes(c))
	return out

func _global_aabb(n: Node) -> AABB:
	var box := AABB()
	var first := true
	for mi in _meshes(n):
		var a: AABB = mi.mesh.get_aabb()
		for i in 8:
			var p: Vector3 = mi.global_transform * a.get_endpoint(i)
			if first:
				box = AABB(p, Vector3.ZERO)
				first = false
			else:
				box = box.expand(p)
	return box

func _triangles(mesh: Mesh) -> int:
	var t := 0
	for s in mesh.get_surface_count():
		var arrays: Array = mesh.surface_get_arrays(s)
		var idx = arrays[Mesh.ARRAY_INDEX]
		t += (idx.size() if idx != null else arrays[Mesh.ARRAY_VERTEX].size()) / 3
	return t
