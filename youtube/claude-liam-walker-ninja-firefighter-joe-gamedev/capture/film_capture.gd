extends SceneTree
## Film capture driver (written by Claude Code). Runs the real game scene with scripted
## normal input through the player's input hooks and logs inputs and states per physics tick.
## Run on an isolated copy of the frozen source with Godot Movie Maker, one take per run:
##   godot --path <copy> -s res://film_capture.gd --write-movie <take>.avi --fixed-fps 30 -- take=<route|fire|fall|muted>
## "fixture" marks the only non-input setup: the fire take starts next to the first ground flame.
const Game = preload("res://game/session.gd")
const Route = preload("res://tests/route_driver.gd")
var game: Node2D
var take := "route"
var inputs: Array = []
var states: Array = []
var ticks := 0
var last_sfx := {}

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("take="):
			take = a.substr(5)
	call_deferred("run")

func tick() -> void:
	await physics_frame
	ticks += 1
	var p = game.player
	var sfx := []
	for id in game.sfx_counts:
		if game.sfx_counts[id] != last_sfx.get(id, 0):
			sfx.append(id)
	last_sfx = game.sfx_counts.duplicate()
	states.append({"tick": ticks, "t": ticks / 60.0, "state": game.state, "pose": p.pose, "x": snappedf(p.position.x, 0.1), "y": snappedf(p.position.y, 0.1), "facing": p.facing, "sfx": sfx, "rescued": game.rescued_count, "deaths": game.deaths})

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
	root.add_child(game)
	await wait(30)                       # title card
	press("confirm")
	game.start_session()                 # same call Enter makes on the title card
	game.player.test_control = true
	match take:
		"route", "muted":
			if take == "muted":
				press("mute_music"); game._toggle_mute("Music")
				press("mute_sfx"); game._toggle_mute("SFX")
			var route = Route.new()
			var limit := 3000 if take == "route" else 900
			while game.state == Game.State.PLAYING and ticks < limit:
				var ax: float = game.player.test_axis
				route.step(game.player)
				if game.player.test_jump_pressed: press("jump")
				if game.player.test_water_pressed: press("water")
				if game.player.test_axis != ax: press("axis", game.player.test_axis)
				await tick()
			if take == "route":
				await wait(240)          # bow + close-up, then the end card
				finish(game.state == Game.State.COMPLETE and game.deaths == 0, "complete, deaths=%d" % game.deaths)
			else:
				finish(game.is_muted("Music") and game.is_muted("SFX"), "muted run")
		"fire":
			await wait(30)
			press("fixture_position", "275,320")
			game.player.position = Vector2(275, 320)
			press("axis", 1.0); game.player.test_axis = 1.0
			while game.state != Game.State.DYING and ticks < 400:
				await tick()
			press("axis", 0.0); game.player.test_axis = 0.0
			await wait(170)              # 2 s hold, retry, respawn stance, idle
			finish(game.deaths == 1 and game.state == Game.State.PLAYING, "fire death and retry")
		"fall":
			await wait(20)
			press("axis", 1.0); game.player.test_axis = 1.0
			await wait(30)
			press("axis", -1.0); game.player.test_axis = -1.0
			await wait(25)
			press("axis", 0.0); game.player.test_axis = 0.0
			await wait(40)               # standing, facing left
			press("axis", 1.0); game.player.test_axis = 1.0
			var marks := [138.0, 292.0]  # jump the step and the flame, never the gap
			while game.state == Game.State.PLAYING and ticks < 800:
				if not marks.is_empty() and game.player.position.x >= marks[0] and game.player.is_on_floor():
					press("jump"); game.player.test_jump_pressed = true
					marks.pop_front()
				await tick()
			press("axis", 0.0); game.player.test_axis = 0.0
			await wait(150)
			finish(game.death_reason == "You fell.", "missed jump")
