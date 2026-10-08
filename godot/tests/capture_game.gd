extends SceneTree
## Screenshots of the whole play session, from the real rendered viewport (run with a window:
##   godot --path . -s tests/capture_game.gd   -> ../evidence/screens/*.png).
## Every moment is reached with normal inputs (test_axis / jump / water presses through the
## player's input hooks), except where a label says "fixture": there the script calls the same
## function the key would (pause, mute) or sets up a start position, and the screenshot is not
## presented as played gameplay.
const Game = preload("res://game/session.gd")
const Route = preload("res://tests/route_driver.gd")
var game: Node2D
var output: String
var positions := {}   # label -> {x, y, pose}: the character's origin (feet) in screenshot pixels

func _initialize() -> void:
	call_deferred("run")

func step() -> void:
	await physics_frame
	await process_frame

func capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var error := image.save_png(output + "/" + label + ".png")
	assert(error == OK)
	if is_instance_valid(game) and game.player:
		var k := float(image.get_width()) / 640.0   # screenshot px per game px
		var o: Vector2 = game.player.get_global_transform_with_canvas().origin * k
		positions[label] = {"x": o.x, "y": o.y, "pose": game.player.pose, "facing": game.player.facing}
	print("Captured rendered game viewport: " + label)

func steps(n: int) -> void:
	for i in range(n):
		await step()

func run() -> void:
	output = ProjectSettings.globalize_path("res://../evidence/screens")
	DirAccess.make_dir_recursive_absolute(output)
	game = Game.new()
	game.test_mode = true
	root.add_child(game)
	await steps(3)
	await capture("01-menu")
	game.start_session()
	game.player.test_control = true

	# --- Failure 1: the fire gets him (fixture start position next to the first ground flame).
	game.player.test_axis = 1
	game.player.position = Vector2(275, 320)
	for i in range(90):
		await step()
		if game.state == Game.State.DYING: break
	assert(game.state == Game.State.DYING)
	await capture("02-failure")
	await capture("state-burned")
	await steps(60)
	await capture("02b-failure-held-1s")      # still DYING: burned pose + DEVASTATED close-up (2 s hold)
	game.player.test_axis = 0.0
	for i in range(130):
		await step()
		if game.state == Game.State.PLAYING: break
	await capture("02c-retry-respawn")        # back at the start in the ready stance

	# --- Retry stance, idle, orientation.
	await capture("state-respawn")
	await steps(35)
	await capture("state-idle")
	game.player.test_axis = 1.0
	await steps(30)
	game.player.test_axis = -1.0
	await steps(15)
	await capture("facing-left-run")
	game.player.test_axis = 0.0
	await steps(40)
	await capture("facing-left-idle")

	# --- Pause card and mute indicators (fixture: the same functions Esc, N and B call).
	game.set_paused(true)
	await steps(2)
	await capture("05-pause-card")
	game.set_paused(false)
	game._toggle_mute("Music")
	game._toggle_mute("SFX")
	await steps(2)
	await capture("06-muted-music-and-sound")
	game._toggle_mute("Music")
	game._toggle_mute("SFX")

	# --- Failure 2: missing a jump. Input only: jump the first step and the ground flame (the
	#     route's first two marks), then keep running and never jump at the gap.
	game.restart_attempt()
	await step()
	var marks := [138.0, 292.0]
	game.player.test_axis = 1.0
	var fall_shot := false
	for i in range(600):
		if not marks.is_empty() and game.player.position.x >= marks[0] and game.player.is_on_floor():
			game.player.test_jump_pressed = true
			marks.pop_front()
		await step()
		if not fall_shot and game.player.position.x > 452.0 and game.player.position.y > 326.0:
			await capture("07a-missed-jump-falling")   # meditating fall, off the edge
			fall_shot = true
		if game.state == Game.State.DYING: break
	assert(game.state == Game.State.DYING and game.death_reason == "You fell.")
	await capture("07b-you-fell")
	game.player.test_axis = 0.0
	for i in range(130):
		await step()
		if game.state == Game.State.PLAYING: break

	# --- Failure 3: the clock runs out. Input only: stand still for the whole 40 s.
	#     Waits on the game's own clock (elapsed), not on rendered frames: a frame can hold
	#     more than one physics tick, so counting frames overshot the first time.
	game.restart_attempt()
	await step()
	while game.elapsed < float(game.level.time_limit) - 8.0:
		await physics_frame
	await capture("08a-clock-under-10s")      # the timer turns red under 10 s
	while game.state != Game.State.DYING:
		await physics_frame
	assert(game.death_reason == "Out of time!")
	await capture("08b-out-of-time")
	for i in range(130):
		await step()
		if game.state == Game.State.PLAYING: break

	# --- The full scripted route (input only), with sequences around each event. A fresh
	#     session (menu -> start) so the HUD's retry count starts at 0 for the clean run.
	game.state = Game.State.MENU
	game.start_session()
	await step()
	var route = Route.new()
	var gap_captured := false
	var seen := {}
	var pending := {}          # loop index -> screenshot label
	var hose_seen := false
	var fire_out_seen := false
	var rescues := 0
	for i in range(3000):
		route.step(game.player)
		await step()
		if not gap_captured and game.player.position.x > 463 and game.player.position.y < 300:
			await capture("03-jump")
			gap_captured = true
		# First real occurrence of each character state image during the route.
		if not seen.has(game.player.pose):
			seen[game.player.pose] = true
			await capture("state-" + game.player.pose)
		# Hose: start, half way, fire out.
		if not hose_seen and game.extinguish_ticks > 0:
			hose_seen = true
			await capture("09a-hose-start")
			pending[i + 120] = "09b-hose-half-way"
		if hose_seen and not fire_out_seen and not game.fire_active:
			fire_out_seen = true
			await capture("09c-hose-fire-out")
		# Each rescue: grab, toss up, apex, falling into the bag, in the bag.
		if game.rescued_count > rescues:
			rescues = game.rescued_count
			var n := "10-rescue-%d-%s" % [rescues, "person" if rescues == 1 else "dog"]
			await capture(n + "-a-grab")
			pending[i + 20] = n + "-b-toss"
			pending[i + 40] = n + "-c-flying-up"
			pending[i + 62] = n + "-d-falling-into-bag"
			pending[i + 80] = n + "-e-in-the-bag"
		if pending.has(i):
			await capture(pending[i])
		if game.state != Game.State.PLAYING: break
	print("ROUTE END state=%d deaths=%d pos=%s reason=%s rescued=%d" % [game.state, game.deaths, str(game.player.position), game.death_reason, game.rescued_count])
	assert(game.state == Game.State.COMPLETE, "Input route did not complete")

	# --- The end: the bow and its close-up, then the "Rescue complete" card.
	await capture("04-complete")
	await capture("state-celebrate")
	await steps(90)
	await capture("04b-complete-card")
	print("VISUAL ROUTE: completed with %d deaths" % game.deaths)
	var f := FileAccess.open(output + "/positions.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(positions, " "))
	f.close()
	game.queue_free()
	await process_frame
	quit()
