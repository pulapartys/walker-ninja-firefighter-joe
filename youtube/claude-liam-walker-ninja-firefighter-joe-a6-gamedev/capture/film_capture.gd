extends SceneTree
## Film capture driver for the A6 explainer (written by Claude Code). Runs the real game scene with
## scripted normal input through the player's input hooks (the hooks tests/route_driver.gd uses) and
## real key events for Esc, and logs inputs and per-tick state: landings, live JumpPuff count, the
## steam's emitting / amount_ratio. No teleporting: Extinguisho hops twice at the spawn, then walks
## and jumps to the blocking fire exactly as the route driver plays the level, taps W, and stands
## while the water runs; Esc pauses for 1.5 s mid-hose and Esc resumes.
## test_mode only disables the focus-lost auto-pause (session.gd _on_focus_lost); nothing else reads it.
## Run on an isolated copy of the source revision with Godot Movie Maker:
##   godot --path <copy> --always-on-top -s res://film_capture.gd --write-movie play.avi --fixed-fps 30 -- take=play
const Game = preload("res://game/session.gd")
const Route = preload("res://tests/route_driver.gd")
const PUFF := "res://effects/jump_puff.tscn"
var game: Node2D
var take := "play"
var inputs: Array = []
var states: Array = []
var marks: Array = []
var ticks := 0
var landings := 0

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("take="):
			take = a.substr(5)
	call_deferred("run")

func puffs() -> int:
	var n := 0
	for c in game.get_children():
		if c.scene_file_path == PUFF:
			n += 1
	return n

func steam_emitter() -> GPUParticles2D:
	var d: Node = game.player.get_node_or_null("HoseSteamDriver")
	return d.steam.get_child(1) if d and d.steam else null

func mark(what: String) -> void:
	marks.append({"tick": ticks, "t": snappedf(ticks / 60.0, 0.001), "event": what})

func tick() -> void:
	await physics_frame
	ticks += 1
	var p = game.player
	var s := steam_emitter()
	states.append({"tick": ticks, "t": snappedf(ticks / 60.0, 0.001), "state": game.state, "pose": p.pose,
		"x": snappedf(p.position.x, 0.1), "y": snappedf(p.position.y, 0.1), "on_floor": p.is_on_floor(),
		"puffs_alive": puffs(), "landings": landings, "hosing": p.hosing, "water_ticks": game.water_ticks,
		"fire_height": snappedf(game.fire_height(), 0.01),
		"steam_emitting": s.emitting if s else false, "amount_ratio": snappedf(s.amount_ratio, 0.001) if s else -1.0})

func press(what: String, value = true) -> void:
	inputs.append({"tick": ticks, "input": what, "value": value})

func key(code: Key, down: bool) -> void:
	var e := InputEventKey.new()
	e.keycode = code
	e.physical_keycode = code
	e.pressed = down
	Input.parse_input_event(e)

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
	game.player.landed.connect(func(): landings += 1; mark("landed (puff)"))
	mark("start")
	await wait(30)
	# Two hops at the spawn, street level: the second jump is pressed just before the first landing (the game's own
	# 6-tick jump buffer), so it leaves on the landing tick and the second landing comes ~0.8 s after the first.
	game.player.test_axis = 0.0
	press("jump"); game.player.test_jump_pressed = true
	await wait(2)
	var rebuffered := false
	while landings < 2 and ticks < 400:
		var p = game.player
		if not rebuffered and landings == 0 and not p.is_on_floor() and p.velocity.y > 0.0 and p.position.y > 305.0:
			press("jump"); p.test_jump_pressed = true
			rebuffered = true
		await tick()
	mark("double hop done")
	await wait(40)
	var route = Route.new()
	var saw_hose := false
	var hose_ticks := 0
	var paused_done := false
	var after := 0
	var peak := 0
	while game.state in [Game.State.PLAYING, Game.State.PAUSED] and ticks < 3600:
		if not saw_hose:
			var ax: float = game.player.test_axis
			route.step(game.player)      # walk, jump the gaps, tap W in range of the blocking fire
			if game.player.test_jump_pressed: press("jump")
			if game.player.test_water_pressed: press("water")
			if game.player.test_axis != ax: press("axis", game.player.test_axis)
		else:
			game.player.test_axis = 0.0  # stand and watch the water, as a player would
			game.player.test_jump_pressed = false
		if game.player.hosing and not saw_hose:
			saw_hose = true
			mark("hosing starts (W)")
		if saw_hose and game.player.hosing:
			hose_ticks += 1
			if hose_ticks == 120 and not paused_done:
				press("pause (Esc)"); key(KEY_ESCAPE, true); await tick(); key(KEY_ESCAPE, false)
				mark("Esc: game paused")
				await wait(90)
				press("pause (Esc)"); key(KEY_ESCAPE, true); await tick(); key(KEY_ESCAPE, false)
				mark("Esc: game resumed")
				paused_done = true
		elif saw_hose:
			if after == 0:
				mark("water stops")
			after += 1
			if after >= 75:              # 1.25 s after the water stops: the last steam has risen and faded
				break
		peak = maxi(peak, puffs())
		await tick()
	finish(saw_hose and paused_done and landings >= 2 and game.state == Game.State.PLAYING,
		"landings=%d, hosed, paused once, deaths=%d" % [landings, game.deaths])
