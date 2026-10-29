extends SceneTree
# A5 controlled-value captures (CHANGE-BRIEF A4, TEST-REPORT "Controlled values"). Needs a window:
#   ~/Downloads/Godot.app/Contents/MacOS/Godot --path godot --script res://tests/capture_glow.gd
# Starts a real session, walks Extinguisho into hose range, presses W through Input so the hose
# pose and water are real, then for each controlled glow value: stops the driver's _process so it
# cannot overwrite the value, sets the uniform from code, waits for the frame to draw, saves the
# rendered viewport as PNG, and samples the three named texels P1-P3 (and the glow-2.0 clamp case).
# It is real engine output, not a headless log. Judging the captures is the human check.
const Game = preload("res://game/session.gd")
var OUT: String = ProjectSettings.globalize_path("res://").path_join("../a5/evidence/captures/")
const VALUES := [0.0, 0.5, 1.0, 2.0]
# Named texels in hose.png (CHANGE-BRIEF A4) and their file colours.
const PIXELS := {"P1": Vector2i(77, 49), "P2": Vector2i(51, 26), "P3": Vector2i(63, 6)}
var game: Node2D

func _initialize() -> void:
	call_deferred("run")

func steps(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func key(code: Key, pressed: bool) -> void:
	var e := InputEventKey.new()
	e.keycode = code
	e.physical_keycode = code
	e.pressed = pressed
	Input.parse_input_event(e)

func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	game = Game.new()
	game.test_mode = true
	root.add_child(game)
	game.start_session()
	game.player.position = Vector2(1220, 240)  # hose range, same spot as the tests
	game.player.facing = 1.0
	await steps(3)
	key(KEY_W, true)
	await steps(2)
	key(KEY_W, false)
	# Wait for the real hose pose: hosing true AND the 30-tick respawn stance over, so the sprite is
	# hose.png and its anchor is the one the A4 texel mapping assumes. Then let the camera settle.
	var guard := 0
	while guard < 200 and not (game.player.hosing and game.player.pose == "hose"):
		await steps(1)
		guard += 1
	if not (game.player.hosing and game.player.pose == "hose"):
		push_error("hose pose never showed (hosing=%s pose=%s); nothing captured" % [game.player.hosing, game.player.pose])
		quit(1)
		return
	await steps(5)
	var player: CharacterBody2D = game.player
	var sprite: Sprite2D = player.sprite
	var driver: Node = player.get_node("HoseGlow")
	var mat: ShaderMaterial = sprite.material
	print("pose=%s facing=%d player=%s window=%s" % [player.pose, int(player.facing), player.position, get_root().size])
	# Freeze the driver (it writes glow every _process); the session keeps running so the water pours.
	driver.set_process(false)
	for v in VALUES:
		mat.set_shader_parameter("glow", v)
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var img: Image = get_root().get_texture().get_image()
		var path := OUT + "glow_%s.png" % String.num(v, 1)
		img.save_png(path)
		# canvas coords are the 640x360 game space; the final transform applies the canvas_items
		# stretch to the 1280x720 window the image was read from.
		var xf: Transform2D = get_root().get_final_transform() * sprite.get_global_transform_with_canvas()
		var row := {"glow": v, "uniform_readback": mat.get_shader_parameter("glow"), "file": path, "image": "%dx%d" % [img.get_width(), img.get_height()]}
		row["pose"] = player.pose
		row["sprite_origin_window_px"] = [xf.origin.x, xf.origin.y]
		for name in PIXELS:
			var t: Vector2i = PIXELS[name]
			var p: Vector2 = xf * Vector2(t.x + 0.5, t.y + 0.5)  # texel centre -> window pixel
			var pi := Vector2i(int(floor(p.x)), int(floor(p.y)))
			var c := img.get_pixel(pi.x, pi.y)
			var neigh := []  # the 3x3 around it, so a one-pixel misalignment is visible
			for dy in [-1, 0, 1]:
				for dx in [-1, 0, 1]:
					var n := img.get_pixel(pi.x + dx, pi.y + dy)
					neigh.append([n.r8, n.g8, n.b8])
			row[name] = {"texel": [t.x, t.y], "window_px": [pi.x, pi.y], "rgb": [c.r8, c.g8, c.b8], "neighbours_3x3": neigh}
		print(JSON.stringify(row))
	driver.set_process(true)
	print("CAPTURE DONE: %d files in %s" % [VALUES.size(), OUT])
	quit(0)
