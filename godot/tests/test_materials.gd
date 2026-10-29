extends SceneTree
# A5 materials audit, pinned (CHANGE-BRIEF Parts B and C; the tables in godot/MATERIALS.md).
# Loads both 3D scenes headlessly and asserts what the audit found: one shader behind both hydrant
# materials, each sampler's hints as written in the source text, each material's uniform values and
# texture paths, the texture import settings read with ConfigFile, the engine's own uniform list,
# the glb's Use External wiring, the lights and environment that change the look, and the
# normal-map curl ratio of every normal map under both green conventions.
#   ./scripts/run-test.sh test_materials.gd 60
# What this cannot see: pixels. Headless Godot draws nothing (CLAUDE.md, Headless facts), so the
# roughness, bumps, tint and the hint-experiment bands are human checks in a5/TEST-REPORT.md.
const Check = preload("res://tests/normal_map_check.gd")

const HYDRANT_SHADER := "res://shaders/hydrant_surface.gdshader"
const HINT_SHADER := "res://shaders/hint_experiment.gdshader"
const FRESH := "res://materials/hydrant_fresh.tres"
const RUSTY := "res://materials/hydrant_rusty.tres"
const HINT_COLOR := "res://materials/hint_as_color.tres"
const HINT_DATA := "res://materials/hint_as_data.tres"
const TEX_DIR := "res://art/textures/rusty_metal_sheet/"
const DIFF := TEX_DIR + "rusty_metal_sheet_diff_1k.png"
const ROUGH := TEX_DIR + "rusty_metal_sheet_rough_1k.png"
const NOR_GL := TEX_DIR + "rusty_metal_sheet_nor_gl_1k.png"
const NOR_DX := TEX_DIR + "rusty_metal_sheet_nor_dx_1k.png"
const GREY := "res://art/hint/grey_3x1.png"
const GLB_IMPORT := "res://props3d/hydrant.glb.import"
const PROPS_ROOM := "res://scenes3d/props_room.tscn"
const HINT_SCENE := "res://scenes3d/hint_experiment.tscn"
const CURL_STRIDE := 4

# Sampler hints exactly as the source text must declare them (CHANGE-BRIEF C2, Part B; F6).
const SAMPLER_HINTS := {
	HYDRANT_SHADER: {
		"albedo_tex": ["source_color", "filter_linear_mipmap"],
		"rough_tex": ["hint_default_white", "filter_linear_mipmap"],
		"normal_tex": ["hint_normal", "filter_linear_mipmap"],
	},
	HINT_SHADER: {
		"as_color": ["source_color", "filter_nearest"],
		"as_data": ["filter_nearest"],
	},
}

# Engine-reported uniform list (name -> Variant type), CHANGE-BRIEF C3 and Part B.
const HYDRANT_UNIFORMS := {
	"albedo_tex": TYPE_OBJECT, "rough_tex": TYPE_OBJECT, "normal_tex": TYPE_OBJECT,
	"paint_tint": TYPE_COLOR, "rust_amount": TYPE_FLOAT, "roughness_scale": TYPE_FLOAT,
	"normal_strength": TYPE_FLOAT, "uv_scale": TYPE_FLOAT,
}
const HYDRANT_RANGES := {"rust_amount": "0.0,1.0", "roughness_scale": "0.0,2.0", "normal_strength": "0.0,2.0", "uv_scale": "0.25,8.0"}
const HINT_UNIFORMS := {"as_color": TYPE_OBJECT, "as_data": TYPE_OBJECT, "use_color": TYPE_BOOL}

# Import settings every texture must carry (CHANGE-BRIEF C2 and Part B; a5/TEST-REPORT.md).
const IMPORTS := {
	DIFF: {"compress/mode": 0, "compress/normal_map": 2, "mipmaps/generate": true, "detect_3d/compress_to": 0, "process/normal_map_invert_y": false},
	ROUGH: {"compress/mode": 0, "compress/normal_map": 2, "mipmaps/generate": true, "detect_3d/compress_to": 0, "process/normal_map_invert_y": false},
	NOR_GL: {"compress/mode": 0, "compress/normal_map": 1, "mipmaps/generate": true, "detect_3d/compress_to": 0, "process/normal_map_invert_y": false},
	NOR_DX: {"compress/mode": 0, "compress/normal_map": 1, "mipmaps/generate": true, "detect_3d/compress_to": 0, "process/normal_map_invert_y": false},
	GREY: {"compress/mode": 0, "compress/normal_map": 2, "mipmaps/generate": false, "detect_3d/compress_to": 0, "process/normal_map_invert_y": false},
}
# Imported pixel format (F9: never a two-channel RG swizzle) and mipmap presence.
const FORMATS := {
	DIFF: {"format": Image.FORMAT_RGB8, "mipmaps": true},
	ROUGH: {"format": Image.FORMAT_L8, "mipmaps": true},
	NOR_GL: {"format": Image.FORMAT_RGBA8, "mipmaps": true},
	NOR_DX: {"format": Image.FORMAT_RGBA8, "mipmaps": true},
	GREY: {"format": Image.FORMAT_RGB8, "mipmaps": false},
}

var results: Array[Dictionary] = []
var failures := 0


func _initialize() -> void:
	call_deferred("run")


func check(id: String, condition: bool, observed: Dictionary) -> void:
	results.append({"id": id, "status": "PASS" if condition else "FAIL", "observed": observed})
	print("%s %s %s" % ["PASS" if condition else "FAIL", id, JSON.stringify(observed)])
	if not condition:
		failures += 1


func rx(pattern: String, text: String) -> bool:
	return RegEx.create_from_string(pattern).search(text) != null


func res_path(v: Variant) -> String:
	return v.resource_path if v is Resource else ""


# Every `uniform sampler2D NAME : hints;` in the source, as {name: [hint, ...]}.
func sampler_hints_from_source(src: String) -> Dictionary:
	var out := {}
	var re := RegEx.create_from_string("uniform\\s+sampler2D\\s+(\\w+)\\s*(?::\\s*([^;]*?))?\\s*;")
	for m in re.search_all(src):
		var hints: Array = []
		for h in m.get_string(2).split(","):
			var t := h.strip_edges()
			if t != "":
				hints.append(t)
		out[m.get_string(1)] = hints
	return out


# Every `shader_parameter/NAME` key a .tres sets, from its text.
func tres_param_names(path: String) -> Array:
	var names: Array = []
	for m in RegEx.create_from_string("(?m)^shader_parameter/(\\w+)\\s*=").search_all(FileAccess.get_file_as_string(path)):
		names.append(m.get_string(1))
	return names


func uniform_map(shader: Shader) -> Dictionary:
	var out := {}
	for u in shader.get_shader_uniform_list():
		out[String(u.name)] = {"type": int(u.type), "hint": int(u.hint), "hint_string": String(u.hint_string)}
	return out


func range_of(hint_string: String) -> String:
	var parts := hint_string.split(",")
	return "%s,%s" % [parts[0], parts[1]] if parts.size() >= 2 else hint_string


func run() -> void:
	# ---------- 1. Shaders parse; the engine's uniform list (names, types, ranges, groups) ----------
	var hydrant_shader: Shader = load(HYDRANT_SHADER)
	var hint_shader: Shader = load(HINT_SHADER)
	var hu := uniform_map(hydrant_shader)
	var hi := uniform_map(hint_shader)
	var types_ok := hu.size() == HYDRANT_UNIFORMS.size()
	for name in HYDRANT_UNIFORMS:
		types_ok = types_ok and hu.has(name) and hu[name].type == HYDRANT_UNIFORMS[name]
	var ranges_ok := true
	for name in HYDRANT_RANGES:
		ranges_ok = ranges_ok and hu.has(name) and hu[name].hint == PROPERTY_HINT_RANGE and range_of(hu[name].hint_string) == HYDRANT_RANGES[name]
	check("hydrant-shader-uniform-list", types_ok and ranges_ok, {"uniforms": hu, "expected_count": HYDRANT_UNIFORMS.size()})
	var groups: Array = []
	for u in hydrant_shader.get_shader_uniform_list(true):
		if int(u.usage) & PROPERTY_USAGE_GROUP:
			groups.append(String(u.name))
	check("hydrant-shader-groups", groups == ["paint", "surface"], {"groups": groups, "entries_with_groups": hydrant_shader.get_shader_uniform_list(true).size()})
	var hint_ok := hi.size() == HINT_UNIFORMS.size()
	for name in HINT_UNIFORMS:
		hint_ok = hint_ok and hi.has(name) and hi[name].type == HINT_UNIFORMS[name]
	check("hint-shader-uniform-list", hint_ok, {"uniforms": hi})

	# ---------- 2. Sampler hints and uniform defaults, from the source text (F6) ----------
	for shader_path in SAMPLER_HINTS:
		var src: String = FileAccess.get_file_as_string(shader_path)
		var found := sampler_hints_from_source(src)
		var expected: Dictionary = SAMPLER_HINTS[shader_path]
		var ok := found.size() == expected.size()
		for name in expected:
			ok = ok and found.has(name) and found[name] == expected[name]
		check("sampler-hints " + shader_path.get_file(), ok, {"found": found, "expected": expected})
	var hsrc: String = FileAccess.get_file_as_string(HYDRANT_SHADER)
	var defaults := {
		"paint_tint": rx("uniform\\s+vec4\\s+paint_tint\\s*:\\s*source_color\\s*=\\s*vec4\\(\\s*0\\.75\\s*,\\s*0\\.22\\s*,\\s*0\\.17\\s*,\\s*1\\.0\\s*\\)\\s*;", hsrc),
		"rust_amount": rx("uniform\\s+float\\s+rust_amount\\s*:\\s*hint_range\\(\\s*0\\.0\\s*,\\s*1\\.0\\s*\\)\\s*=\\s*0\\.3\\s*;", hsrc),
		"roughness_scale": rx("uniform\\s+float\\s+roughness_scale\\s*:\\s*hint_range\\(\\s*0\\.0\\s*,\\s*2\\.0\\s*\\)\\s*=\\s*1\\.0\\s*;", hsrc),
		"normal_strength": rx("uniform\\s+float\\s+normal_strength\\s*:\\s*hint_range\\(\\s*0\\.0\\s*,\\s*2\\.0\\s*\\)\\s*=\\s*1\\.0\\s*;", hsrc),
		"uv_scale": rx("uniform\\s+float\\s+uv_scale\\s*:\\s*hint_range\\(\\s*0\\.25\\s*,\\s*8\\.0\\s*\\)\\s*=\\s*2\\.0\\s*;", hsrc),
		"spatial_lit": rx("shader_type\\s+spatial\\s*;", hsrc) and not rx("render_mode", hsrc),
	}
	check("hydrant-shader-defaults", not defaults.values().has(false), defaults)
	var fragment := {
		"uv": rx("vec2\\s+uv\\s*=\\s*UV\\s*\\*\\s*uv_scale\\s*;", hsrc),
		"base": rx("vec3\\s+base\\s*=\\s*texture\\(\\s*albedo_tex\\s*,\\s*uv\\s*\\)\\.rgb\\s*;", hsrc),
		"albedo": rx("ALBEDO\\s*=\\s*mix\\(\\s*base\\s*\\*\\s*paint_tint\\.rgb\\s*,\\s*base\\s*,\\s*rust_amount\\s*\\)\\s*;", hsrc),
		"roughness": rx("ROUGHNESS\\s*=\\s*texture\\(\\s*rough_tex\\s*,\\s*uv\\s*\\)\\.r\\s*\\*\\s*roughness_scale\\s*;", hsrc),
		"normal_map": rx("NORMAL_MAP\\s*=\\s*texture\\(\\s*normal_tex\\s*,\\s*uv\\s*\\)\\.rgb\\s*;", hsrc),
		"normal_map_depth": rx("NORMAL_MAP_DEPTH\\s*=\\s*normal_strength\\s*;", hsrc),
	}
	check("hydrant-shader-fragment-lines", not fragment.values().has(false), fragment)
	var isrc: String = FileAccess.get_file_as_string(HINT_SHADER)
	var hint_src := {
		"spatial_unshaded": rx("shader_type\\s+spatial\\s*;", isrc) and rx("render_mode\\s+unshaded\\s*;", isrc),
		"use_color_default_false": rx("uniform\\s+bool\\s+use_color\\s*=\\s*false\\s*;", isrc),
		"color_branch": rx("if\\s*\\(\\s*use_color\\s*\\)\\s*\\{\\s*ALBEDO\\s*=\\s*texture\\(\\s*as_color\\s*,\\s*UV\\s*\\)\\.rgb\\s*;", isrc),
		"data_branch": rx("else\\s*\\{\\s*ALBEDO\\s*=\\s*texture\\(\\s*as_data\\s*,\\s*UV\\s*\\)\\.rgb\\s*;", isrc),
	}
	check("hint-shader-source", not hint_src.values().has(false), hint_src)

	# ---------- 3. The hydrant materials: one shader, values, textures, differ in two values ----------
	var fresh: ShaderMaterial = load(FRESH)
	var rusty: ShaderMaterial = load(RUSTY)
	check("hydrant-materials-same-shader", fresh.shader == rusty.shader and res_path(fresh.shader) == HYDRANT_SHADER and res_path(rusty.shader) == HYDRANT_SHADER,
		{"fresh": res_path(fresh.shader), "rusty": res_path(rusty.shader), "same_object": fresh.shader == rusty.shader})
	var expect_values := {
		FRESH: {"rust_amount": 0.1, "roughness_scale": 0.7},
		RUSTY: {"rust_amount": 0.9, "roughness_scale": 1.4},
	}
	var expect_textures := {"albedo_tex": DIFF, "rough_tex": ROUGH, "normal_tex": NOR_GL}
	for mp in expect_values:
		var m: ShaderMaterial = load(mp)
		var seen := {}
		var ok := true
		for name in expect_values[mp]:
			var v = m.get_shader_parameter(name)
			seen[name] = v
			ok = ok and v is float and is_equal_approx(v, expect_values[mp][name])
		for name in expect_textures:
			var p := res_path(m.get_shader_parameter(name))
			seen[name] = p
			ok = ok and p == expect_textures[name]
		for name in ["paint_tint", "normal_strength", "uv_scale"]:   # C4: "red (default)", 1.0 default
			seen[name] = m.get_shader_parameter(name)
			ok = ok and m.get_shader_parameter(name) == null
		var set_names := tres_param_names(mp)
		var declared := true
		for n in set_names:
			declared = declared and hu.has(n)
		seen["tres_sets"] = set_names
		ok = ok and declared and set_names.size() == 5
		check("material-values " + mp.get_file(), ok, seen)
	var diff_names: Array = []
	for name in hu:
		var a = fresh.get_shader_parameter(name)
		var b = rusty.get_shader_parameter(name)
		if a is Resource or b is Resource:
			if res_path(a) != res_path(b):
				diff_names.append(name)
		elif a != b:
			diff_names.append(name)
	check("hydrant-materials-differ-in-two", diff_names == ["rust_amount", "roughness_scale"], {"differ": diff_names})

	# ---------- 4. The hint materials ----------
	var hint_expect := {HINT_COLOR: true, HINT_DATA: false}
	for mp in hint_expect:
		var m: ShaderMaterial = load(mp)
		var obs := {"shader": res_path(m.shader), "use_color": m.get_shader_parameter("use_color"), "as_color": res_path(m.get_shader_parameter("as_color")), "as_data": res_path(m.get_shader_parameter("as_data")), "tres_sets": tres_param_names(mp)}
		check("material-values " + mp.get_file(), obs.shader == HINT_SHADER and obs.use_color == hint_expect[mp] and obs.as_color == GREY and obs.as_data == GREY and obs.tres_sets.size() == 3, obs)

	# ---------- 5. Import settings (ConfigFile on the .import files) and imported formats ----------
	for tp in IMPORTS:
		var cf := ConfigFile.new()
		var err := cf.load(tp + ".import")
		var obs := {"load": error_string(err), "importer": cf.get_value("remap", "importer", "")}
		var ok: bool = err == OK and obs.importer == "texture"
		for key in IMPORTS[tp]:
			var v = cf.get_value("params", key, null)
			obs[key] = v
			ok = ok and v == IMPORTS[tp][key]
		check("import " + tp.get_file(), ok, obs)
	for tp in FORMATS:
		var t: Texture2D = load(tp)
		var img: Image = t.get_image() if t else null
		var obs := {"class": t.get_class() if t else "", "format": img.get_format() if img else -1, "mipmaps": img.has_mipmaps() if img else null, "size": [t.get_width(), t.get_height()] if t else null}
		var not_rg: bool = img != null and img.get_format() != Image.FORMAT_RG8 and img.get_format() != Image.FORMAT_LA8
		check("imported-format " + tp.get_file(), img != null and obs.format == FORMATS[tp].format and obs.mipmaps == FORMATS[tp].mipmaps and not_rg, obs)
	var gcf := ConfigFile.new()
	var gerr := gcf.load(GLB_IMPORT)
	var subs: Dictionary = gcf.get_value("params", "_subresources", {})
	var red: Dictionary = subs.get("materials", {}).get("hydrant_red", {})
	check("glb-use-external", gerr == OK and gcf.get_value("params", "materials/extract", -1) == 0 and red.get("use_external/enabled", false) == true and red.get("use_external/path", "") == FRESH and red.get("use_external/fallback_path", "") == FRESH and subs.get("materials", {}).size() == 1,
		{"materials/extract": gcf.get_value("params", "materials/extract", null), "subresource_materials": subs.get("materials", {}).keys(), "hydrant_red": red, "ensure_tangents": gcf.get_value("params", "meshes/ensure_tangents", null)})

	# ---------- 6. props_room.tscn: wiring, light and environment ----------
	var room: Node3D = load(PROPS_ROOM).instantiate()
	root.add_child(room)
	var h_fresh: MeshInstance3D = room.get_node("Hydrant/Hydrant")
	var h_rusty: MeshInstance3D = room.get_node("HydrantRusty/Hydrant")
	var mesh: Mesh = h_fresh.mesh
	var names: Array = []
	for i in mesh.get_surface_count():
		names.append((mesh as ArrayMesh).surface_get_name(i))
	check("hydrant-mesh-surfaces", mesh == h_rusty.mesh and mesh.get_surface_count() == 2 and names == ["hydrant_red", "hydrant_grey"] and res_path(mesh).begins_with("res://props3d/hydrant.glb::"),
		{"mesh": res_path(mesh), "surfaces": names, "shared": mesh == h_rusty.mesh})
	var fresh_obs := {"x": h_fresh.get_parent().position.x, "surface0_mesh_material": res_path(mesh.surface_get_material(0)), "surface0_override": res_path(h_fresh.get_surface_override_material(0)), "surface0_active": res_path(h_fresh.get_active_material(0)), "surface1_active": res_path(h_fresh.get_active_material(1)), "surface1_name": h_fresh.get_active_material(1).resource_name}
	check("props-hydrant-fresh", is_equal_approx(fresh_obs.x, -0.8) and fresh_obs.surface0_mesh_material == FRESH and h_fresh.get_surface_override_material(0) == null and fresh_obs.surface0_active == FRESH and fresh_obs.surface1_active.begins_with("res://props3d/hydrant.glb::") and fresh_obs.surface1_name == "hydrant_grey" and h_fresh.get_active_material(1) is StandardMaterial3D, fresh_obs)
	var rusty_obs := {"x": h_rusty.get_parent().position.x, "surface0_override": res_path(h_rusty.get_surface_override_material(0)), "surface0_active": res_path(h_rusty.get_active_material(0)), "surface1_override": res_path(h_rusty.get_surface_override_material(1)), "surface1_active": res_path(h_rusty.get_active_material(1)), "surface1_name": h_rusty.get_active_material(1).resource_name}
	check("props-hydrant-rusty", is_equal_approx(rusty_obs.x, -1.6) and rusty_obs.surface0_override == RUSTY and rusty_obs.surface0_active == RUSTY and h_rusty.get_surface_override_material(1) == null and rusty_obs.surface1_active.begins_with("res://props3d/hydrant.glb::") and rusty_obs.surface1_name == "hydrant_grey", rusty_obs)
	var env: Environment = room.get_node("WorldEnvironment").environment
	var env_obs := {"background_mode": env.background_mode, "ambient_source": env.ambient_light_source, "ambient_energy": env.ambient_light_energy, "tonemap_mode": env.tonemap_mode, "tonemap_exposure": env.tonemap_exposure, "tonemap_white": env.tonemap_white, "glow": env.glow_enabled, "fog": env.fog_enabled, "adjustment": env.adjustment_enabled, "ssao": env.ssao_enabled, "ssr": env.ssr_enabled, "ssil": env.ssil_enabled, "sdfgi": env.sdfgi_enabled}
	check("props-environment", env.background_mode == Environment.BG_COLOR and env.ambient_light_source == Environment.AMBIENT_SOURCE_COLOR and is_equal_approx(env.ambient_light_energy, 0.6) and env.tonemap_mode == Environment.TONE_MAPPER_LINEAR and is_equal_approx(env.tonemap_exposure, 1.0) and not env.glow_enabled and not env.fog_enabled and not env.adjustment_enabled and not env.ssao_enabled and not env.ssr_enabled and not env.ssil_enabled and not env.sdfgi_enabled, env_obs)
	var lights := room.find_children("*", "Light3D", true, false)
	var sun: DirectionalLight3D = room.get_node("Sun")
	var sun_obs := {"lights": lights.size(), "energy": sun.light_energy, "color": [sun.light_color.r, sun.light_color.g, sun.light_color.b], "shadows": sun.shadow_enabled, "indirect": sun.light_indirect_energy, "specular": sun.light_specular, "direction": [-sun.global_transform.basis.z.x, -sun.global_transform.basis.z.y, -sun.global_transform.basis.z.z]}
	check("props-sun", lights.size() == 1 and lights[0] == sun and is_equal_approx(sun.light_energy, 1.0) and sun.light_color == Color.WHITE and sun.shadow_enabled and is_equal_approx(sun.light_specular, 1.0), sun_obs)
	room.queue_free()

	# ---------- 7. hint_experiment.tscn: wiring and environment ----------
	var hint: Node3D = load(HINT_SCENE).instantiate()
	root.add_child(hint)
	var qc: MeshInstance3D = hint.get_node("QuadAsColor")
	var qd: MeshInstance3D = hint.get_node("QuadAsData")
	var henv: Environment = hint.get_node("WorldEnvironment").environment
	var hobs := {"color_quad": res_path(qc.get_surface_override_material(0)), "data_quad": res_path(qd.get_surface_override_material(0)), "color_x": qc.position.x, "data_x": qd.position.x, "lights": hint.find_children("*", "Light3D", true, false).size(), "tonemap_mode": henv.tonemap_mode, "tonemap_exposure": henv.tonemap_exposure, "glow": henv.glow_enabled, "fog": henv.fog_enabled, "adjustment": henv.adjustment_enabled, "background_mode": henv.background_mode}
	check("hint-scene", hobs.color_quad == HINT_COLOR and hobs.data_quad == HINT_DATA and hobs.lights == 0 and henv.tonemap_mode == Environment.TONE_MAPPER_LINEAR and is_equal_approx(henv.tonemap_exposure, 1.0) and not henv.glow_enabled and not henv.fog_enabled and not henv.adjustment_enabled, hobs)
	hint.queue_free()

	# ---------- 8. The grey strip's bytes and the normal maps' curl ratio (F7) ----------
	var grey := Image.load_from_file(ProjectSettings.globalize_path(GREY))
	var bands: Array = []
	var grey_ok := grey != null and grey.get_width() == 3 and grey.get_height() == 1
	if grey_ok:
		for x in 3:
			var c := grey.get_pixel(x, 0)
			bands.append([c.r8, c.g8, c.b8])
			grey_ok = grey_ok and c.r8 == c.g8 and c.g8 == c.b8
		grey_ok = grey_ok and bands[0][0] == 64 and bands[1][0] == 128 and bands[2][0] == 192
	check("grey-strip-source", grey_ok, {"bands": bands})
	# The bound normal map must read as a real surface in the OpenGL convention: below 1.0 with
	# directx = false and above 1.0 with directx = true (threshold set from the calibration pair in
	# a5/TEST-REPORT.md: GL file 0.54 / 1.46, DX file the mirror image).
	var bound := res_path(fresh.get_shader_parameter("normal_tex"))
	for tp in [NOR_GL, NOR_DX]:
		var img := Image.load_from_file(ProjectSettings.globalize_path(tp))
		if img == null:
			check("curl " + tp.get_file(), false, {"load": "failed"})
			continue
		var as_gl := Check.curl_ratio(img, false, CURL_STRIDE)
		var as_dx := Check.curl_ratio(img, true, CURL_STRIDE)
		print("curl_ratio %s: directx=false %.4f  directx=true %.4f  (%dx%d format %d, stride %d)" % [tp.get_file(), as_gl, as_dx, img.get_width(), img.get_height(), img.get_format(), CURL_STRIDE])
		var is_gl_file: bool = tp == NOR_GL
		var reads_right := (as_gl < 1.0 and as_dx > 1.0) if is_gl_file else (as_dx < 1.0 and as_gl > 1.0)
		check("curl " + tp.get_file(), reads_right, {"directx_false": as_gl, "directx_true": as_dx, "expected": "GL convention" if is_gl_file else "DX convention", "bound_to_material": tp == bound})
	check("normal-map-bound-is-gl", bound == NOR_GL and res_path(rusty.get_shader_parameter("normal_tex")) == NOR_GL, {"fresh_binds": bound, "rusty_binds": res_path(rusty.get_shader_parameter("normal_tex"))})

	print("MATERIALS TESTS: %d checks / %d failures" % [results.size(), failures])
	await process_frame
	quit(1 if failures else 0)
