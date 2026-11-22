extends SceneTree
## Film capture driver for the A7 explainer (written by Claude Code). Runs the real game scene with scripted
## normal input through the player's input hooks (the hooks tests/route_driver.gd uses) and real key events for
## Esc and R, and logs inputs and per-tick state: the pose, Joe's clip, its position and Sprite.frame, the
## survivor flight's launch, and the person rig's visibility and shoulder rotation. No teleporting: Extinguisho
## plays the level as the route driver does (climb B1, hose the blocking fire while the person waves, walk into
## the window, descend, climb B2, walk into the dog's window). One interrupt per phase of the toss:
##   person's toss, startup (frame 6): a jump through the jump hook;
##   dog's toss, active (frame 20): Esc for 45 ticks, then Esc again;
##   dog's toss, recovery (frame 36): R (restart).
## test_mode only disables the focus-lost auto-pause (session.gd _on_focus_lost); nothing else reads it.
## Run on an isolated copy of the source revision with Godot Movie Maker:
##   godot --path <copy>/godot --always-on-top -s res://film_capture.gd --write-movie play.avi --fixed-fps 30 -- take=play
const Game = preload("res://game/session.gd")
const Route = preload("res://tests/route_driver.gd")
var game: Node2D
var take := "play"
var inputs: Array = []
var states: Array = []
var marks: Array = []
var ticks := 0

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("take="):
			take = a.substr(5)
	call_deferred("run")

func mark(what: String) -> void:
	marks.append({"tick": ticks, "t": snappedf(ticks / 60.0, 0.001), "event": what})

func tick() -> void:
	await physics_frame
	ticks += 1
	var p = game.player
	var rig: Node2D = game.survivors[0].rig
	states.append({"tick": ticks, "t": snappedf(ticks / 60.0, 0.001), "state": game.state, "pose": p.pose,
		"clip": p.anim.assigned_animation, "clip_time": snappedf(p.anim.current_animation_position, 0.0001),
		"frame": p.sprite.frame, "bag_pose": p.bag_pose(), "rescued": game.rescued_count,
		"launched": game.flights.size() > 0 and game.flights[0].has("launch"),
		"x": snappedf(p.position.x, 0.1), "y": snappedf(p.position.y, 0.1), "hosing": p.hosing,
		"rig_visible": rig.visible, "shoulder": snappedf(rig.get_node("Shoulder").rotation, 0.001)})

func press(what: String, value = true) -> void:
	inputs.append({"tick": ticks, "input": what, "value": value})

func key(code: Key, down: bool) -> void:
	var e := InputEventKey.new()
	e.keycode = code
	e.physical_keycode = code
	e.pressed = down
	Input.parse_input_event(e)

func tap_key(code: Key, label: String) -> void:
	press(label)
	key(code, true)
	await tick()
	key(code, false)

func wait(n: int) -> void:
	for i in range(n):
		await tick()

func finish(ok: bool, note: String) -> void:
	var dir := "res://capture_logs"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	for pair in [["inputs", inputs], ["states", states], ["marks", marks]]:
		var f := FileAccess.open(dir + "/%s-%s.jsonl" % [take, pair[0]], FileAccess.WRITE)
		for row in pair[1]:
			f.store_line(JSON.stringify(row))
		f.close()
	print("TAKE %s %s: %s ticks=%d" % [take, "OK" if ok else "FAILED", note, ticks])
	quit(0 if ok else 1)

func run() -> void:
	game = Game.new()
	game.test_mode = true                # only effect: the window-focus-lost auto-pause is off (Movie Maker runs unfocused)
	root.add_child(game)
	await wait(30)                       # title card
	press("confirm")
	game.start_session()                 # the same call Enter makes on the title card
	game.player.test_control = true
	mark("start")
	await wait(30)
	var route = Route.new()
	var touch1 := -1
	var touch2 := -1
	var jumped := false
	var paused := false
	var restarted := false
	var after := 0
	while ticks < 4000:
		var rescued: int = game.rescued_count
		if touch1 < 0 and rescued >= 1:
			touch1 = ticks
			mark("touch 1: the person (toss frame 0)")
		if touch2 < 0 and rescued >= 2:
			touch2 = ticks
			mark("touch 2: the dog (toss frame 0)")
		if game.state == Game.State.PLAYING:
			var ax: float = game.player.test_axis
			route.step(game.player)      # walk, jump the gaps, tap W in range of the blocking fire
			if game.player.test_jump_pressed: press("jump")
			if game.player.test_water_pressed: press("water")
			if game.player.test_axis != ax: press("axis", game.player.test_axis)
		if game.player.hosing and not marks.any(func(m): return m.event == "hosing starts (W)"):
			mark("hosing starts (W)")
		# Startup interrupt: a jump on the person's toss frame 6.
		if touch1 >= 0 and not jumped and ticks - touch1 == 6:
			press("jump (startup interrupt)")
			game.player.test_jump_pressed = true
			jumped = true
			mark("jump on toss frame 6 (startup)")
		# Active interrupt: Esc on the dog's toss frame 20, held paused 45 ticks, then Esc again.
		if touch2 >= 0 and not paused and ticks - touch2 == 20:
			mark("Esc on toss frame 20 (active): paused")
			await tap_key(KEY_ESCAPE, "pause (Esc)")
			await wait(45)
			mark("Esc: resumed")
			await tap_key(KEY_ESCAPE, "pause (Esc)")
			paused = true
			continue
		# Recovery interrupt: R on the dog's toss frame 36 (counting PLAYING ticks only).
		if paused and not restarted and touch2 >= 0:
			var playing_since := 0
			for s in states:
				if s.tick > touch2 and s.state == Game.State.PLAYING:
					playing_since += 1
			if playing_since == 36:
				mark("R on toss frame 36 (recovery): restart")
				await tap_key(KEY_R, "restart (R)")
				restarted = true
				continue
		if restarted:
			after += 1
			if after >= 50:
				break
		await tick()
	finish(touch1 >= 0 and touch2 >= 0 and jumped and paused and restarted,
		"touches at %d and %d, interrupts done, deaths=%d" % [touch1, touch2, game.deaths])
