extends SceneTree
# A6 Effect B, hose steam (CHANGE-BRIEF B3): loads res://effects/hose_steam.tscn and reads every
# setting the brief names back from the loaded nodes and resources, against the brief's values.
# Node settings are read from each GPUParticles2D; process settings from its ParticleProcessMaterial.
# A Godot 3 or misspelt name in the scene is dropped on load, so its read-back shows the engine
# default instead of the brief's value and the check fails.
# Checks marked "not_in_effect_a" are the features B1 says Effect A doesn't use: GPU particles,
# amount_ratio, turbulence, the box emission area across the fire, and a visibility_rect.
# Run: scripts/run-test.sh test_hose_steam_config.gd 60
# What this cannot see: the look, or amount_ratio following the fire (a state test's job).
# Headless Godot draws no particles and runs no GPU particle process (CLAUDE.md, Headless facts).
const SCENE_PATH := "res://effects/hose_steam.tscn"
const ORDER := ["Haze", "Steam"]   # Haze first, so it draws underneath
const NOT_IN_A := ["amount_ratio", "visibility_rect", "emission_shape", "emission_box_extents",
	"turbulence_enabled", "turbulence_influence_min", "turbulence_influence_max"]
var results: Array[Dictionary] = []
var failures := 0
var not_in_a_checks := 0
var not_in_a_failures := 0

# CHANGE-BRIEF B3 "Node setting" table. use_fixed_seed: "the effect scene never does" set a seed.
# trail_enabled: "What limits the choices", neither effect uses particle trails.
var brief_node := {
	"Haze": {
		"amount": 14, "amount_ratio": 1.0, "emitting": false, "one_shot": false, "explosiveness": 0.0,
		"randomness": 0.3, "lifetime": 1.6, "preprocess": 0.0, "fixed_fps": 30, "interpolate": true,
		"local_coords": false, "visibility_rect": Rect2(-70, -100, 140, 120),
		"use_fixed_seed": false, "trail_enabled": false,
	},
	"Steam": {
		"amount": 40, "amount_ratio": 1.0, "emitting": false, "one_shot": false, "explosiveness": 0.0,
		"randomness": 0.3, "lifetime": 1.4, "preprocess": 0.0, "fixed_fps": 30, "interpolate": true,
		"local_coords": false, "visibility_rect": Rect2(-70, -100, 140, 120),
		"use_fixed_seed": false, "trail_enabled": false,
	},
}
# CHANGE-BRIEF B3 "ParticleProcessMaterial setting" table. collision_mode: "What limits the
# choices", no 2D particle collision.
var brief_material := {
	"Haze": {
		"emission_shape": ParticleProcessMaterial.EMISSION_SHAPE_BOX, "emission_box_extents": Vector3(20, 3, 0),
		"direction": Vector3(0, -1, 0), "spread": 15.0,
		"initial_velocity_min": 12.0, "initial_velocity_max": 25.0, "gravity": Vector3(0, -10, 0),
		"damping_min": 1.0, "damping_max": 3.0,
		"turbulence_enabled": true, "turbulence_influence_min": 0.03, "turbulence_influence_max": 0.08,
		"angle_min": 0.0, "angle_max": 360.0, "scale_min": 0.6, "scale_max": 0.8,
		"particle_flag_disable_z": true, "collision_mode": ParticleProcessMaterial.COLLISION_DISABLED,
	},
	"Steam": {
		"emission_shape": ParticleProcessMaterial.EMISSION_SHAPE_BOX, "emission_box_extents": Vector3(24, 3, 0),
		"direction": Vector3(0, -1, 0), "spread": 25.0,
		"initial_velocity_min": 20.0, "initial_velocity_max": 40.0, "gravity": Vector3(0, -15, 0),
		"damping_min": 2.0, "damping_max": 6.0,
		"turbulence_enabled": true, "turbulence_influence_min": 0.05, "turbulence_influence_max": 0.15,
		"angle_min": 0.0, "angle_max": 360.0, "scale_min": 0.4, "scale_max": 0.6,
		"particle_flag_disable_z": true, "collision_mode": ParticleProcessMaterial.COLLISION_DISABLED,
	},
}
# scale_curve (a CurveTexture) as the (offset, value) points of its Curve.
var scale_curves := {
	"Haze": [Vector2(0, 0.6), Vector2(1, 1.8)],
	"Steam": [Vector2(0, 0.6), Vector2(1, 1.6)],
}
# color_ramp (a GradientTexture1D) as [offset, colour] stops of its Gradient.
const GREY := Color(0.30, 0.31, 0.35)
const WHITE := Color(0.95, 0.95, 0.97)
var color_ramps := {
	"Haze": [[0.0, Color(GREY, 0.0)], [0.2, Color(GREY, 0.8)], [1.0, Color(GREY, 0.0)]],
	"Steam": [[0.0, Color(WHITE, 0.0)], [0.15, Color(WHITE, 0.8)], [0.6, Color(WHITE, 0.5)], [1.0, Color(WHITE, 0.0)]],
}
# "Draw": a GradientTexture2D in the scene file, Effect A's recipe, white α 1 → white α 0.
var disc := {"width": 32, "height": 32, "fill": GradientTexture2D.FILL_RADIAL, "fill_from": Vector2(0.5, 0.5), "fill_to": Vector2(1.0, 0.5)}
var disc_stops := [[0.0, Color(1, 1, 1, 1)], [1.0, Color(1, 1, 1, 0)]]

func _initialize() -> void:
	call_deferred("run")

func check(id: String, condition: bool, observed: Dictionary, not_in_a := false) -> void:
	if not_in_a:
		observed["not_in_effect_a"] = true
		not_in_a_checks += 1
		if not condition:
			not_in_a_failures += 1
	results.append({"id": id, "status": "PASS" if condition else "FAIL", "observed": observed})
	print(JSON.stringify(results.back()))
	if not condition:
		failures += 1

# Floats within is_equal_approx (scene values are stored as 32-bit floats); everything else exact.
func same(got, want) -> bool:
	match typeof(want):
		TYPE_FLOAT:
			return typeof(got) in [TYPE_FLOAT, TYPE_INT] and is_equal_approx(float(got), want)
		TYPE_VECTOR2:
			return typeof(got) == TYPE_VECTOR2 and got.is_equal_approx(want)
		TYPE_VECTOR3:
			return typeof(got) == TYPE_VECTOR3 and got.is_equal_approx(want)
		TYPE_RECT2:
			return typeof(got) == TYPE_RECT2 and got.is_equal_approx(want)
		TYPE_COLOR:
			return typeof(got) == TYPE_COLOR and got.is_equal_approx(want)
		_:
			return typeof(got) == typeof(want) and got == want

# JSON-safe form of a value for the log.
func shown(v):
	return v if typeof(v) in [TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING] else str(v)

func embedded(res: Resource) -> bool:
	return res != null and res.resource_path.begins_with(SCENE_PATH + "::")

func stops_of(g: Gradient) -> Array:
	var out := []
	if g != null:
		for i in g.get_point_count():
			out.append([g.get_offset(i), g.get_color(i)])
	return out

func same_stops(got: Array, want: Array) -> bool:
	if got.size() != want.size():
		return false
	for i in want.size():
		if not (same(got[i][0], want[i][0]) and same(got[i][1], want[i][1])):
			return false
	return true

func points_of(c: Curve) -> Array:
	var out := []
	if c != null:
		for i in c.point_count:
			out.append(c.get_point_position(i))
	return out

func same_points(got: Array, want: Array) -> bool:
	if got.size() != want.size():
		return false
	for i in want.size():
		if not same(got[i], want[i]):
			return false
	return true

func run() -> void:
	var packed: PackedScene = load(SCENE_PATH)
	check("scene-loads", packed != null, {"path": SCENE_PATH})
	if packed == null:
		quit(1)
		return
	var steam: Node = packed.instantiate()

	# --- B3: Node2D root HoseSteam, two GPUParticles2D children, Haze (drawn first) then Steam ---
	var kids := []
	for c in steam.get_children():
		kids.append("%s:%s" % [c.name, c.get_class()])
	var shape_ok: bool = steam.name == "HoseSteam" and steam.get_class() == "Node2D" and steam.get_child_count() == ORDER.size()
	for i in ORDER.size():
		shape_ok = shape_ok and i < steam.get_child_count() and steam.get_child(i).name == ORDER[i] and steam.get_child(i).get_class() == "GPUParticles2D"
	check("structure", shape_ok, {"root": "%s:%s" % [steam.name, steam.get_class()], "children": kids, "expected": ["Haze:GPUParticles2D", "Steam:GPUParticles2D"]}, true)

	# --- B3 "Draw": no draw material, default mix blend ---
	check("root.material", steam.material == null, {"read_back": str(steam.material), "expected": "none (mix blend)"})

	for emitter_name in ORDER:
		var e: Node = steam.get_node_or_null(emitter_name)
		if e == null:
			check(emitter_name, false, {"missing": emitter_name})
			continue

		# Node settings, read from the GPUParticles2D.
		var want_node: Dictionary = brief_node[emitter_name]
		for prop in want_node:
			var got = e.get(prop)
			check("%s.%s" % [emitter_name, prop], same(got, want_node[prop]), {"expected": shown(want_node[prop]), "read_back": shown(got)}, prop in NOT_IN_A)

		# Process settings, read from the ParticleProcessMaterial inside the scene file.
		var mat = e.get("process_material")
		var mat_ok: bool = mat is ParticleProcessMaterial and embedded(mat)
		check("%s.process_material" % emitter_name, mat_ok, {"read_back": str(mat), "in_scene_file": embedded(mat) if mat is Resource else false, "expected": "ParticleProcessMaterial in the scene file"})
		if not mat_ok:
			continue
		var want_mat: Dictionary = brief_material[emitter_name]
		for prop in want_mat:
			var got = mat.get(prop)
			check("%s.process_material.%s" % [emitter_name, prop], same(got, want_mat[prop]), {"expected": shown(want_mat[prop]), "read_back": shown(got)}, prop in NOT_IN_A)

		# scale_curve: a CurveTexture inside the scene whose Curve has the brief's points.
		var st = mat.get("scale_curve")
		var curve = st.curve if st is CurveTexture else null
		var pts := points_of(curve) if curve is Curve else []
		check("%s.process_material.scale_curve" % emitter_name, st is CurveTexture and embedded(st) and curve is Curve and embedded(curve) and same_points(pts, scale_curves[emitter_name]),
			{"expected_points": str(scale_curves[emitter_name]), "read_back_points": str(pts), "type": str(st), "in_scene_file": embedded(st) if st is Resource else false})

		# color_ramp: a GradientTexture1D inside the scene whose Gradient has the brief's stops.
		var rt = mat.get("color_ramp")
		var ramp = rt.gradient if rt is GradientTexture1D else null
		var stops := stops_of(ramp) if ramp is Gradient else []
		check("%s.process_material.color_ramp" % emitter_name, rt is GradientTexture1D and embedded(rt) and ramp is Gradient and embedded(ramp) and same_stops(stops, color_ramps[emitter_name]),
			{"expected": str(color_ramps[emitter_name]), "read_back": str(stops), "type": str(rt), "in_scene_file": embedded(rt) if rt is Resource else false})

		# Draw: no draw material; a GradientTexture2D in the scene file with Effect A's recipe.
		check("%s.material" % emitter_name, e.material == null, {"read_back": str(e.material), "expected": "none (mix blend)"})
		var tex = e.get("texture")
		check("%s.texture" % emitter_name, tex is GradientTexture2D and embedded(tex), {"read_back": str(tex), "resource_path": tex.resource_path if tex is Resource else ""})
		if tex is GradientTexture2D:
			for prop in disc:
				check("%s.texture.%s" % [emitter_name, prop], same(tex.get(prop), disc[prop]), {"expected": shown(disc[prop]), "read_back": shown(tex.get(prop))})
			var g_stops := stops_of(tex.gradient)
			check("%s.texture.gradient" % emitter_name, tex.gradient != null and embedded(tex.gradient) and same_stops(g_stops, disc_stops),
				{"expected": str(disc_stops), "read_back": str(g_stops), "in_scene_file": embedded(tex.gradient)})

	print("HOSE STEAM CONFIG: features Effect A doesn't use: %d checks / %d failures" % [not_in_a_checks, not_in_a_failures])
	print("HOSE STEAM CONFIG: %d checks / %d failures" % [results.size(), failures])
	steam.free()
	quit(1 if failures else 0)
