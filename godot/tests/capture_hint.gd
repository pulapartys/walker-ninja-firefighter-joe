extends SceneTree
# A5 hint experiment capture (CHANGE-BRIEF Part B, TEST-REPORT "Hint experiment"). Needs a window:
#   ~/Downloads/Godot.app/Contents/MacOS/Godot --path godot --script res://tests/capture_hint.gd
# Loads scenes3d/hint_experiment.tscn, waits for frames to draw, saves the rendered viewport as PNG,
# and samples the centre of each of the three bands on each quad (the quad's local x = -1/3, 0, +1/3
# unprojected through the camera). Real engine output; judging it against the predictions is the
# human check. Prints one JSON line per quad.
var OUT: String = ProjectSettings.globalize_path("res://").path_join("../a5/evidence/captures/")
const BANDS := {"64": -1.0 / 3.0, "128": 0.0, "192": 1.0 / 3.0}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var scene: Node3D = load("res://scenes3d/hint_experiment.tscn").instantiate()
	root.add_child(scene)
	for i in 10:
		await process_frame
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var img: Image = get_root().get_texture().get_image()
	var path := OUT.path_join("hint_experiment.png")
	img.save_png(path)
	var cam: Camera3D = scene.get_node("Camera3D")
	var env: Environment = scene.get_node("WorldEnvironment").environment
	print("image %dx%d tonemap_mode=%d exposure=%.1f file=%s" % [img.get_width(), img.get_height(), env.tonemap_mode, env.tonemap_exposure, path])
	for quad_name in ["QuadAsColor", "QuadAsData"]:
		var quad: MeshInstance3D = scene.get_node(quad_name)
		var mat: ShaderMaterial = quad.get_surface_override_material(0)
		var row := {"quad": quad_name, "use_color": mat.get_shader_parameter("use_color")}
		for band in BANDS:
			var world: Vector3 = quad.global_transform * Vector3(BANDS[band], 0.0, 0.0)
			# unproject gives the 640x360 logical viewport; the final transform applies the window stretch.
			var p: Vector2 = get_root().get_final_transform() * cam.unproject_position(world)
			var pi := Vector2i(int(floor(p.x)), int(floor(p.y)))
			var c := img.get_pixel(pi.x, pi.y)
			# the band is flat: also report the 5x5 min/max so a one-pixel error at a band edge shows
			var lo := 255; var hi := 0
			for dy in range(-2, 3):
				for dx in range(-2, 3):
					var n := img.get_pixel(pi.x + dx, pi.y + dy).r8
					lo = mini(lo, n); hi = maxi(hi, n)
			row["band_" + band] = {"window_px": [pi.x, pi.y], "rgb": [c.r8, c.g8, c.b8], "r_min_max_5x5": [lo, hi]}
		print(JSON.stringify(row))
	print("CAPTURE DONE")
	quit(0)
