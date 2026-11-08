extends SceneTree
# A6 Effect A, jump puff (CHANGE-BRIEF A3): loads res://effects/jump_puff.tscn and reads every
# setting the brief names back from the loaded nodes and resources, against the brief's values.
# A Godot 3 or misspelt name in the scene (prediction P1) is dropped on load, so its read-back
# shows the engine default instead of the brief's value and the check fails.
# Run: scripts/run-test.sh test_jump_puff_config.gd 60
# What this cannot see: the look. Headless Godot draws no particles (CLAUDE.md, Headless facts).
const SCENE_PATH := "res://effects/jump_puff.tscn"
const ORDER := ["Flash", "Puff", "Specks"]
var results: Array[Dictionary] = []
var failures := 0

# CHANGE-BRIEF A3 settings table, one column per emitter; "—" cells are left out. preprocess and
# use_fixed_seed come from the bullets under the table ("No preprocess (0)"; "the effect scene
# never does" set a seed).
var brief := {
	"Flash": {
		"amount": 1, "one_shot": true, "explosiveness": 1.0, "lifetime": 0.12, "lifetime_randomness": 0.0,
		"emission_shape": CPUParticles2D.EMISSION_SHAPE_POINT,
		"initial_velocity_min": 0.0, "initial_velocity_max": 0.0, "gravity": Vector2(0, 0),
		"damping_min": 0.0, "damping_max": 0.0, "angle_min": 0.0, "angle_max": 0.0,
		"angular_velocity_min": 0.0, "angular_velocity_max": 0.0,
		"scale_amount_min": 0.6, "scale_amount_max": 0.6,
		"hue_variation_min": 0.0, "hue_variation_max": 0.0,
		"local_coords": false, "preprocess": 0.0, "use_fixed_seed": false,
	},
	"Puff": {
		"amount": 10, "one_shot": true, "explosiveness": 1.0, "lifetime": 0.9, "lifetime_randomness": 0.2,
		"emission_shape": CPUParticles2D.EMISSION_SHAPE_SPHERE, "emission_sphere_radius": 3.0,
		"direction": Vector2(0, -1), "spread": 80.0,
		"initial_velocity_min": 50.0, "initial_velocity_max": 90.0, "gravity": Vector2(0, -20),
		"damping_min": 250.0, "damping_max": 300.0, "angle_min": 0.0, "angle_max": 360.0,
		"angular_velocity_min": -90.0, "angular_velocity_max": 90.0,
		"scale_amount_min": 0.35, "scale_amount_max": 0.55,
		"hue_variation_min": -0.02, "hue_variation_max": 0.02,
		"local_coords": false, "preprocess": 0.0, "use_fixed_seed": false,
	},
	"Specks": {
		"amount": 6, "one_shot": true, "explosiveness": 1.0, "lifetime": 0.45, "lifetime_randomness": 0.25,
		"emission_shape": CPUParticles2D.EMISSION_SHAPE_SPHERE, "emission_sphere_radius": 4.0,
		"direction": Vector2(0, -1), "spread": 60.0,
		"initial_velocity_min": 80.0, "initial_velocity_max": 150.0, "gravity": Vector2(0, 600),
		"damping_min": 0.0, "damping_max": 0.0, "angle_min": 0.0, "angle_max": 0.0,
		"angular_velocity_min": 0.0, "angular_velocity_max": 0.0,
		"scale_amount_min": 0.08, "scale_amount_max": 0.14,
		"hue_variation_min": 0.0, "hue_variation_max": 0.0,
		"local_coords": false, "preprocess": 0.0, "use_fixed_seed": false,
	},
}
# scale_amount_curve as (offset, value) points; null = "none".
var scale_curves := {
	"Flash": [Vector2(0, 1.0), Vector2(1, 0.3)],
	"Puff": [Vector2(0, 0.6), Vector2(0.3, 1.0), Vector2(1.0, 1.3)],
	"Specks": null,
}
# color_ramp as [offset, colour] stops.
var color_ramps := {
	"Flash": [[0.0, Color(1, 1, 1, 0.9)], [1.0, Color(1, 1, 1, 0.0)]],
	"Puff": [[0.0, Color(0.97, 0.96, 0.94, 0.95)], [0.35, Color(0.85, 0.85, 0.88, 0.7)], [1.0, Color(0.60, 0.62, 0.68, 0.0)]],
	"Specks": [[0.0, Color(Color("25354a"), 1.0)], [1.0, Color(Color("25354a"), 0.0)]],
}
# "Draw": one GradientTexture2D in the scene file, white α 1 → white α 0.
var disc := {"width": 32, "height": 32, "fill": GradientTexture2D.FILL_RADIAL, "fill_from": Vector2(0.5, 0.5), "fill_to": Vector2(1.0, 0.5)}
var disc_stops := [[0.0, Color(1, 1, 1, 1)], [1.0, Color(1, 1, 1, 0)]]

func _initialize() -> void:
	call_deferred("run")

func check(id: String, condition: bool, observed: Dictionary) -> void:
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
	var puff: Node = packed.instantiate()

	# --- A3: Node2D root JumpPuff, three CPUParticles2D children Flash, Puff, Specks ---
	var kids := []
	for c in puff.get_children():
		kids.append("%s:%s" % [c.name, c.get_class()])
	var shape_ok: bool = puff.name == "JumpPuff" and puff.get_class() == "Node2D" and puff.get_child_count() == ORDER.size()
	for i in ORDER.size():
		shape_ok = shape_ok and i < puff.get_child_count() and puff.get_child(i).name == ORDER[i] and puff.get_child(i).get_class() == "CPUParticles2D"
	check("structure", shape_ok, {"root": "%s:%s" % [puff.name, puff.get_class()], "children": kids, "expected": ["Flash:CPUParticles2D", "Puff:CPUParticles2D", "Specks:CPUParticles2D"]})

	# --- A3: "No draw material: default mix blend" ---
	check("root.material", puff.material == null, {"read_back": str(puff.material), "expected": "none (mix blend)"})

	var textures := []
	for emitter_name in ORDER:
		var e: Node = puff.get_node_or_null(emitter_name)
		if e == null:
			check(emitter_name, false, {"missing": emitter_name})
			continue
		var want: Dictionary = brief[emitter_name]
		for prop in want:
			var got = e.get(prop)
			check("%s.%s" % [emitter_name, prop], same(got, want[prop]), {"expected": shown(want[prop]), "read_back": shown(got)})

		# scale_amount_curve: a Curve inside the scene with the brief's points, or none.
		var curve = e.get("scale_amount_curve")
		var want_pts = scale_curves[emitter_name]
		if want_pts == null:
			check("%s.scale_amount_curve" % emitter_name, curve == null, {"expected": "none", "read_back": str(curve)})
		else:
			var pts := points_of(curve) if curve is Curve else []
			check("%s.scale_amount_curve" % emitter_name, curve is Curve and embedded(curve) and same_points(pts, want_pts),
				{"expected_points": str(want_pts), "read_back_points": str(pts), "type": str(curve), "in_scene_file": embedded(curve) if curve is Resource else false})

		# color_ramp: a Gradient inside the scene with the brief's stops.
		var ramp = e.get("color_ramp")
		var stops := stops_of(ramp) if ramp is Gradient else []
		check("%s.color_ramp" % emitter_name, ramp is Gradient and embedded(ramp) and same_stops(stops, color_ramps[emitter_name]),
			{"expected": str(color_ramps[emitter_name]), "read_back": str(stops), "type": str(ramp), "in_scene_file": embedded(ramp) if ramp is Resource else false})

		check("%s.material" % emitter_name, e.material == null, {"read_back": str(e.material), "expected": "none (mix blend)"})
		var tex = e.get("texture")
		textures.append(tex)
		check("%s.texture" % emitter_name, tex is GradientTexture2D and embedded(tex), {"read_back": str(tex), "resource_path": tex.resource_path if tex is Resource else ""})

	# --- A3 "Draw": every emitter uses one GradientTexture2D defined in the scene file ---
	var one: bool = textures.size() == ORDER.size() and textures[0] is GradientTexture2D
	for t in textures:
		one = one and is_same(t, textures[0])
	check("texture-shared", one, {"emitters": textures.size(), "same_object": one})
	if textures.size() > 0 and textures[0] is GradientTexture2D:
		var tex: GradientTexture2D = textures[0]
		for prop in disc:
			check("texture.%s" % prop, same(tex.get(prop), disc[prop]), {"expected": shown(disc[prop]), "read_back": shown(tex.get(prop))})
		var g_stops := stops_of(tex.gradient)
		check("texture.gradient", tex.gradient != null and embedded(tex.gradient) and same_stops(g_stops, disc_stops),
			{"expected": str(disc_stops), "read_back": str(g_stops), "in_scene_file": embedded(tex.gradient)})

	print("JUMP PUFF CONFIG: %d checks / %d failures" % [results.size(), failures])
	puff.free()
	quit(1 if failures else 0)
