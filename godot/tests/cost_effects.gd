extends SceneTree
# A6 CPU price of the two effects (CHANGE-BRIEF C), headless. Adapted from the chapter's Example 09 cost
# script (a6/evidence/probes/particle_cost_example09.gd): the same warm-up frames, timed frames, repeats
# and wall-clock timer. At a fixed rate (--fixed-fps) Godot never sleeps between frames, so the time
# between two frames is the CPU time of one whole frame: physics, process, the dummy render and this
# script's own loop.
# Run: scripts/run-test.sh cost_effects.gd 60 300
# Cases, each REPEATS x TIMED_FRAMES frames:
#   empty scene         Example 09's baseline: a bare Node2D, no game. Mostly the main loop and this loop.
#   game, effects off   res://game/main.tscn in PLAYING, him standing at the spawn. Both drivers are in, no
#                       JumpPuff is alive and the level's HoseSteam is not emitting.
#   Effect A            the same with two JumpPuffs alive on every timed frame (A-R3: at most 2, so 34
#                       particles). The test emits player.landed whenever fewer than 2 are alive, so the
#                       real driver instances, places and frees every puff.
#   Effect B            the same with a second HoseSteam from hose_steam.tscn at the full fire's top, both
#                       emitters emitting at amount_ratio 1.0 (54 particles), filled during the warm-up.
# Neither peak can be held with real keys: landings come at least ~0.65 s apart and a puff lives 0.88 s,
# so two overlap only briefly, and amount_ratio is 1.0 only on the first hosing frame. So the test makes
# both states. For B it writes only what the brief gives a driver (emitting, amount_ratio, the root
# position), on its own instance; the level's own steam is left to its driver.
# The three game cases run round by round (off, A, B, off, A, B, ...), so slow drift hits all three alike,
# and each case starts with R, a fresh attempt, so the 40 s level timer never runs out mid-case. Every case
# runs the same per-frame loop, so the loop's own cost is inside every number.
# What this cannot see: GPU work and drawing. Headless Godot uses a dummy renderer (CLAUDE.md, Headless
# facts): Effect B's particles are never processed, so its price here is near zero by construction.
const Main = preload("res://game/main.tscn")
const Game = preload("res://game/session.gd")
const HoseSteam := preload("res://effects/hose_steam.tscn")
const PUFF_PATH := "res://effects/jump_puff.tscn"
const WARM_UP_FRAMES := 120   # 2.0 s at 60 fps: longer than Haze's 1.6 s life, so B's steam has filled
const TIMED_FRAMES := 300
const REPEATS := 10
const SETTLE_FRAMES := 60     # after each case, so A's last puffs (0.88 s) are gone before the next one
const MAX_PUFFS := 2          # A-R3: at most 2 alive at once
const LANDING_GAP_S := 0.43   # at least this between two landings: under half a puff's measured 0.8833 s
                              # (logs/test_jump_puff_state_60fps.log), so two stay alive and a third never starts
const AMOUNTS := [14, 40]     # B3: Haze, Steam
const EMPTY := "empty scene"
const OFF := "game, effects off"
const PUFFS := "Effect A, 2 puffs alive"
const STEAM := "Effect B, ratio 1.0"
var game: Node2D
var level_steam: Array = []   # the level's own HoseSteam emitters (hose_steam_driver.gd), read only
var fixture: Node2D           # Effect B's HoseSteam, the test's own instance
var keep_puffs := false
var live_puffs := 0
var puffs_made := 0
var frame := 0
var last_landing := -1000
var landing_gap := 26
var cases := {}               # name -> {means, ms, alive_min, alive_max, landings, problems}
var flagged := 0

func _initialize() -> void:
	call_deferred("run")

# Synthetic key event through Godot Input, as test_keyboard.gd and the A6 state tests.
func key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func tap(code: Key) -> void:
	key(code, true)
	await frames(2)
	key(code, false)
	await frames(1)

# Example 09's time_frames(), one frame at a time: the wall time between two process_frame signals, and
# the puffs alive in that frame. Warm-up, settle and timed frames all run this same loop.
func frames(count: int) -> Dictionary:
	var ms: Array[float] = []
	var alive: Array[int] = []
	var last := Time.get_ticks_usec()
	for i in count:
		frame += 1
		if keep_puffs and live_puffs < MAX_PUFFS and frame - last_landing >= landing_gap:
			game.player.landed.emit()
			last_landing = frame
		alive.append(live_puffs)
		await process_frame
		var now := Time.get_ticks_usec()
		ms.append((now - last) / 1000.0)
		last = now
	return {"ms": ms, "alive": alive}

# --- watchers: they count puffs, never touch them ---

func _on_node_added(node: Node) -> void:
	if node.scene_file_path == PUFF_PATH:
		live_puffs += 1
		puffs_made += 1
		node.tree_exited.connect(_on_puff_exited)

func _on_puff_exited() -> void:
	live_puffs -= 1

# --- the cases ---

# Where hose_steam_driver.gd puts the level's steam: the fire's top centre (B-R4), at full height here.
func fire_top() -> Vector2:
	var fire: Array = game.level.blocking_fire
	return Vector2(float(fire[0]) + float(fire[2]) / 2.0, float(fire[1]) + float(fire[3]) - game.fire_height())

func start_case(name: String) -> void:
	if name == PUFFS:
		keep_puffs = true
		last_landing = -1000
	elif name == STEAM:
		fixture = HoseSteam.instantiate()
		fixture.position = fire_top()
		game.add_child(fixture)
		game.move_child(fixture, game.player.get_index())   # just before him, as the driver does (Revision 5)
		for e in fixture.get_children():
			e.amount_ratio = 1.0
			e.emitting = true

func end_case() -> void:
	keep_puffs = false
	if fixture:
		fixture.queue_free()
		fixture = null

func snapshot() -> Dictionary:
	var s := {"state": game.state, "deaths": game.deaths, "on_floor": game.player.is_on_floor(), "made": puffs_made,
		"level_emit": level_steam.map(func(e): return e.emitting), "fix_emit": [], "fix_ratio": [], "fix_amount": []}
	if fixture:
		for e in fixture.get_children():
			s.fix_emit.append(e.emitting)
			s.fix_ratio.append(e.amount_ratio)
			s.fix_amount.append(e.amount)
	return s

func problem(c: Dictionary, text: String) -> void:
	if not text in c.problems:
		c.problems.append(text)

# One repeat: its mean goes into the case, and the checks that it measured what the case's name says.
func record(name: String, res: Dictionary, before: Dictionary, after: Dictionary) -> void:
	var c: Dictionary = cases[name]
	c.means.append(mean(res.ms))
	c.ms.append_array(res.ms)
	var alive: Array = res.alive
	c.alive_min = mini(c.alive_min, alive.min())
	c.alive_max = maxi(c.alive_max, alive.max())
	var want := MAX_PUFFS if name == PUFFS else 0
	if alive.min() != want or alive.max() != want:
		problem(c, "puffs alive per timed frame %d-%d, want %d" % [alive.min(), alive.max(), want])
	if before.is_empty():
		return
	c.landings += after.made - before.made
	for s in [before, after]:
		if s.state != Game.State.PLAYING or s.deaths != before.deaths or not s.on_floor:
			problem(c, "not PLAYING on the floor throughout (state %d, deaths %d -> %d)" % [s.state, before.deaths, s.deaths])
		if s.level_emit != [false, false]:
			problem(c, "the level's own steam was emitting: %s" % [s.level_emit])
		if name == STEAM and (s.fix_emit != [true, true] or s.fix_ratio != [1.0, 1.0] or s.fix_amount != AMOUNTS):
			problem(c, "steam not at its heaviest: emitting %s, amount_ratio %s, amount %s" % [s.fix_emit, s.fix_ratio, s.fix_amount])

func game_case(name: String) -> void:
	await tap(KEY_R)
	start_case(name)
	await frames(WARM_UP_FRAMES)
	var before := snapshot()
	var res: Dictionary = await frames(TIMED_FRAMES)
	var after := snapshot()
	end_case()
	await frames(SETTLE_FRAMES)
	record(name, res, before, after)

# --- the report ---

func mean(values: Array) -> float:
	var total := 0.0
	for v in values:
		total += v
	return total / values.size()

func sd(values: Array) -> float:
	var m := mean(values)
	var total := 0.0
	for v in values:
		total += (v - m) * (v - m)
	return sqrt(total / (values.size() - 1))

func report(name: String) -> void:
	var c: Dictionary = cases[name]
	var sorted: Array = c.ms.duplicate()
	sorted.sort()
	print("%-24s mean %.6f ms/frame | spread over %d repeats: sd %.6f, min %.6f, max %.6f | per frame (%d): median %.6f, p95 %.6f"
		% [name, mean(c.means), c.means.size(), sd(c.means), c.means.min(), c.means.max(), sorted.size(),
		sorted[floori(sorted.size() * 0.5)], sorted[floori(sorted.size() * 0.95)]])
	print("%-24s repeat means: %s" % ["", ", ".join(PackedStringArray(c.means.map(func(m): return "%.6f" % m)))])
	var detail := "puffs alive per timed frame %d-%d" % [c.alive_min, c.alive_max]
	if name == PUFFS:
		detail += ", %d landings emitted in timed frames (%.1f per repeat)" % [c.landings, float(c.landings) / c.means.size()]
	elif name == STEAM:
		detail += ", its own HoseSteam emitting at amount_ratio 1.0 with amount %s at the start and end of every timed window" % [AMOUNTS]
	if name != EMPTY:
		detail += ", PLAYING on the floor, the level's own steam not emitting"
	print("%-24s checks: %s; %s" % ["", "OK" if c.problems.is_empty() else "PROBLEM: " + "; ".join(PackedStringArray(c.problems)), detail])

# Two cases read the same when their difference is inside the spread. The game cases ran round by round,
# so they are compared round by round: the same when the mean per-round difference is within two
# standard errors of zero. The empty scene ran on its own before the game, so it is compared by range:
# the same when the two cases' repeat means overlap.
func compare(a: String, b: String, should_differ: bool, why: String) -> void:
	var ma: Array = cases[a].means
	var mb: Array = cases[b].means
	var diff := mean(ma) - mean(mb)
	var same: bool
	var how: String
	if a == EMPTY or b == EMPTY:
		same = maxf(ma.min(), mb.min()) <= minf(ma.max(), mb.max())
		how = "repeat ranges overlap" if same else "repeat ranges apart"
	else:
		var d: Array = []
		var above := 0
		for i in ma.size():
			d.append(ma[i] - mb[i])
			if ma[i] > mb[i]:
				above += 1
		var se := sd(d) / sqrt(d.size())
		same = absf(mean(d)) < 2.0 * se
		how = "per-round difference %+.6f, 2 standard errors %.6f; the first is higher in %d of %d rounds" % [mean(d), 2.0 * se, above, d.size()]
	print("%s vs %s: %+.6f ms/frame (%+.1f %%) -> %s (%s)" % [a, b, diff, 100.0 * diff / mean(mb),
		"SAME within spread" if same else "DIFFERENT", how])
	if same and should_differ:
		flagged += 1
		print("  FLAG: these should differ (%s) but read the same: the script may be measuring itself, not the effect." % why)
	elif same:
		print("  same, as expected headless (%s): this number is the game and the script, not the effect." % why)
	elif not should_differ:
		flagged += 1
		print("  FLAG: expected the same headless (%s) but they differ: something besides the effect changed." % why)
	else:
		print("  differ, as expected (%s)." % why)

func run() -> void:
	var adapter := RenderingServer.get_video_adapter_name()
	print("Rendering method: ", RenderingServer.get_current_rendering_method())
	print("Video adapter: \"%s\"%s" % [adapter, " (empty: dummy renderer, nothing is drawn and no GPU particle process runs)" if adapter == "" else ""])
	node_added.connect(_on_node_added)
	for name in [EMPTY, OFF, PUFFS, STEAM]:
		cases[name] = {"means": [], "ms": [], "alive_min": 1 << 30, "alive_max": -1, "landings": 0, "problems": []}

	# --- a fixed rate: every frame advances the game clock by the same step, and nothing sleeps ---
	var deltas: Array[float] = []
	for i in 30:
		await process_frame
		deltas.append(root.get_process_delta_time())
	var step: float = deltas[0]
	var fixed: bool = deltas.max() - deltas.min() < 1e-9
	print("Frame step %.6f s (%s); %d warm-up + %d timed frames x %d repeats per case"
		% [step, "fixed" if fixed else "NOT fixed", WARM_UP_FRAMES, TIMED_FRAMES, REPEATS])
	if not fixed:
		print("COST EFFECTS: not at a fixed rate, so every case would read the frame sleep (CLAUDE.md, Headless facts). Run with --fixed-fps.")
		quit(1)
		return
	landing_gap = maxi(1, floori(LANDING_GAP_S / step))

	# --- empty scene: Example 09's baseline ---
	var container := Node2D.new()
	root.add_child(container)
	await frames(WARM_UP_FRAMES)
	var ticks_from := Engine.get_physics_frames()
	for r in REPEATS:
		var res: Dictionary = await frames(TIMED_FRAMES)
		record(EMPTY, res, {}, {})
	print("Physics ticks per frame over the empty scene's timed frames: %.3f" % (float(Engine.get_physics_frames() - ticks_from) / (REPEATS * TIMED_FRAMES)))
	container.queue_free()
	await frames(2)

	# --- the game, started with Enter; then off, A, B, round by round ---
	game = Main.instantiate()
	game.test_mode = true
	root.add_child(game)
	level_steam = game.player.get_node("HoseSteamDriver").emitters
	await frames(30)
	await tap(KEY_ENTER)
	await frames(30)
	if game.state != Game.State.PLAYING:
		print("COST EFFECTS: Enter did not start the game (state %d)" % game.state)
		quit(1)
		return
	for r in REPEATS:
		for name in [OFF, PUFFS, STEAM]:
			await game_case(name)

	print("--- CPU time per frame, wall clock at a fixed rate (ms) ---")
	for name in [EMPTY, OFF, PUFFS, STEAM]:
		report(name)
	print("--- comparisons ---")
	compare(OFF, EMPTY, true, "the game's physics, process and draw calls run on the CPU")
	compare(PUFFS, OFF, true, "34 CPUParticles2D particles simulate on the CPU, headless included")
	compare(PUFFS, STEAM, true, "A simulates on the CPU; B's GPU process does not run headless")
	compare(STEAM, OFF, false, "headless runs no GPU particle process")
	var problems := 0
	for name in cases:
		problems += cases[name].problems.size()
	print("COST EFFECTS: %d cases x %d repeats x %d frames at %.6f s per frame; %d of 4 comparisons flagged; setup checks: %s"
		% [cases.size(), REPEATS, TIMED_FRAMES, step, flagged, "OK" if problems == 0 else "%d problems" % problems])
	game.queue_free()
	await process_frame
	quit(1 if problems else 0)
