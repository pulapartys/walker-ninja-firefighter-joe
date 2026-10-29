extends SceneTree
## Film capture driver for the A5 explainer (written by Claude Code). Runs the real game scene with
## scripted normal input through the player's input hooks (the same hooks tests/route_driver.gd uses)
## and logs inputs, states and the hose-glow uniform per physics tick. No teleporting: Extinguisho
## walks and jumps from the spawn to the blocking fire exactly as the route driver plays the level.
## test_mode only disables the focus-lost auto-pause (session.gd _on_focus_lost); nothing else in the game reads it.
## Run on an isolated copy of the frozen source with Godot Movie Maker:
##   godot --path <copy> -s res://film_capture.gd --write-movie hose.avi --fixed-fps 30 -- take=hose
const Game = preload("res://game/session.gd")
const Route = preload("res://tests/route_driver.gd")
var game: Node2D
var take := "hose"
var inputs: Array = []
var states: Array = []
var ticks := 0

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("take="):
			take = a.substr(5)
	call_deferred("run")

func glow_value() -> float:
	var d: Node = game.player.get_node_or_null("HoseGlow")
	return d.glow if d else -1.0

func tick() -> void:
	await physics_frame
	ticks += 1
	var p = game.player
	states.append({"tick": ticks, "t": ticks / 60.0, "state": game.state, "pose": p.pose, "x": snappedf(p.position.x, 0.1),
		"y": snappedf(p.position.y, 0.1), "hosing": p.hosing, "water_ticks": game.water_ticks, "glow": snappedf(glow_value(), 0.001)})

func press(what: String, value = true) -> void:
	inputs.append({"tick": ticks, "input": what, "value": value})

func wait(n: int) -> void:
	for i in range(n):
		await tick()

func finish(ok: bool, note: String) -> void:
	var dir := "res://capture_logs"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	for pair in [["inputs", inputs], ["states", states]]:
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
	var route = Route.new()
	var saw_hose := false
	var after := 0
	var peak := 0.0
	while game.state == Game.State.PLAYING and ticks < 2400:
		if not saw_hose:
			var ax: float = game.player.test_axis
			route.step(game.player)      # walk, jump the gaps, tap W in range of the blocking fire
			if game.player.test_jump_pressed: press("jump")
			if game.player.test_water_pressed: press("water")
			if game.player.test_axis != ax: press("axis", game.player.test_axis)
		else:
			game.player.test_axis = 0.0  # stand and watch the water, as a player would
			game.player.test_jump_pressed = false
		if game.player.hosing:
			saw_hose = true
			peak = maxf(peak, glow_value())
		elif saw_hose:
			after += 1
			if after >= 90:              # 1.5 s after the water stops: the fade is over, hold a moment
				break
		await tick()
	var g := glow_value()
	finish(saw_hose and game.state == Game.State.PLAYING and g <= 0.001 and peak >= 0.75,
		"hosed, peak glow %.3f, glow at end %.3f, deaths=%d" % [peak, g, game.deaths])
