## Renders scenes3d/props_room.tscn from its own camera, then from front, right, back, left, below and top, to PNGs.
##   godot --path godot --script res://tests/capture_props.gd -- <out_dir>      (needs a window, not --headless)
## Only the camera moves; the props are as saved in the scene.
extends SceneTree

func _initialize() -> void:
	var out: String = OS.get_cmdline_user_args()[0] if OS.get_cmdline_user_args().size() > 0 else "user://"
	root.size = Vector2i(1600, 900)
	var scene: Node3D = load("res://scenes3d/props_room.tscn").instantiate()
	root.add_child(scene)
	var cam: Camera3D = scene.get_node("Camera3D")
	await _shot(out + "/godot-props-scene-camera.png")
	var target := Vector3(0.35, 0.35, 0)
	var views := {"front": Vector3(0.35, 0.9, 3.0), "right": Vector3(3.3, 0.9, 0.01), "back": Vector3(0.35, 0.9, -3.0),
		"left": Vector3(-2.6, 0.9, 0.01), "below": Vector3(0.35, -0.6, 2.4), "top": Vector3(0.35, 4.0, 0.01)}
	for v in views:
		cam.global_position = views[v]
		cam.look_at(target, Vector3.UP if v != "top" else Vector3.FORWARD)
		await _shot(out + "/godot-props-%s.png" % v)
	quit()

func _shot(path: String) -> void:
	for i in 8:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)
	print("saved ", path.get_file())
