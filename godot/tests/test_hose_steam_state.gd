extends SceneTree
# A6 Effect B, hose steam (CHANGE-BRIEF B4, Revision 5 B-R8): the driver's rules, headless.
# The condition (player.hosing) and the game value (session.fire_height()) come out of the real game
# loop (res://game/main.tscn), driven by real keys through Godot Input: W, R, D, Space and Esc, plus
# Enter to start or resume. The test never calls the driver and never writes hosing, the hose counters
# or the fire. It only watches: a Sampler node (process_priority 100, so it runs after the driver's
# _process; process_mode ALWAYS, so it also runs while the tree is paused) records one sample per frame.
# Three things the test does that a player can't: before each W it puts him on B1's roof in hose range
# (as test_game.gd and test_hose_glow.gd do; the walk there is test_game.gd's route), it sets the tree
# pause (the game never does), and it sets `visible = false` on the steam root (B-R6).
# Run: scripts/run-test.sh test_hose_steam_state.gd 60
# What this cannot see: particles. Headless Godot runs no GPU particle process and draws nothing
# (CLAUDE.md, Headless facts), so whether steam spawns, thins, finishes or freezes on screen, and the
# draw order on screen, are eye checks. This reads the node state the driver writes.
const Main = preload("res://game/main.tscn")
const Game = preload("res://game/session.gd")
const STEAM_PATH := "res://effects/hose_steam.tscn"
const PUFF_PATH := "res://effects/jump_puff.tscn"
const KIDS := ["Haze:GPUParticles2D", "Steam:GPUParticles2D"]
const AMOUNTS := [14, 40]          # B3: fixed, never changed at runtime (B-R3)
const FULL := 34.0                 # B1: the fire's full height, level.blocking_fire[3]
const TOP := Vector2(1278, 240)    # B-R4: the root is at (1278, 240 - fire_height()) while hosing
const EXT := 240                   # session.gd EXTINGUISH_TICKS: the fire falls to 0 over 4.0 s
const STAND := Vector2(1220, 240)  # on B1's roof, in hose range (test_game.gd, test_hose_glow.gd)
const SPAWN := Vector2(64, 320)
const EPS := 1e-6
const POS_EPS := 1e-3
var game: Node2D
var sampler: Sampler
var samples: Array = []  # one per frame, after the driver: {paused, state, hosing, h, water, ext, p, steams, pidx, puffs, id, parent_ok, idx, pos, vis, emit, ratio, amount, shown, proc}
var results: Array[Dictionary] = []
var failures := 0
var frame_s := 0.0   # one drawn frame in seconds
var tpf := 1         # physics ticks per drawn frame (1 at 60 fps)
var steam_id := 0

# Calls the test's sample() once per frame, after every other _process (the driver's included).
class Sampler extends Node:
	var take: Callable
	func _process(_delta: float) -> void:
		take.call()

func _initialize() -> void:
	call_deferred("run")

func steps(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

# Synthetic key event through Godot Input, as test_keyboard.gd, test_hose_glow.gd and test_jump_puff_state.gd.
func key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func tap(code: Key) -> void:
	key(code, true)
	await steps(2)
	key(code, false)
	await steps(1)

func wait_for(cond: Callable, limit: int) -> bool:
	var n := 0
	while n < limit and not cond.call():
		await steps(1)
		n += 1
	return cond.call()

# Puts him on B1's roof in hose range (the one write a player can't make) and presses W. Returns the
# index of the first sample after he stands there.
func hose() -> int:
	game.player.position = STAND
	await steps(3)
	var at := S().size()
	await tap(KEY_W)
	return at

func check(id: String, condition: bool, observed: Dictionary) -> void:
	results.append({"id": id, "status": "PASS" if condition else "FAIL", "observed": observed})
	print(JSON.stringify(results.back()))
	if not condition:
		failures += 1

# --- the watcher: it reads, never writes ---

func in_tree(path: String) -> Array:
	return root.find_children("*", "", true, false).filter(func(n): return n.scene_file_path == path)

func sample() -> void:
	if not is_instance_valid(game) or game.player == null:
		return
	var found := in_tree(STEAM_PATH)
	var s := {"paused": paused, "state": game.state, "hosing": game.player.hosing, "h": game.fire_height(),
		"water": game.water_ticks, "ext": game.extinguish_ticks, "p": game.player.position,
		"steams": found.size(), "pidx": game.player.get_index(), "puffs": in_tree(PUFF_PATH).size(),
		"id": 0, "parent_ok": false, "idx": -1, "pos": Vector2.INF, "vis": false,
		"emit": [], "ratio": [], "amount": [], "shown": [], "proc": []}
	if found.size() > 0:
		var st: Node2D = found[0]
		s.id = st.get_instance_id()
		s.parent_ok = st.get_parent() == game
		s.idx = st.get_index()
		s.pos = st.global_position
		s.vis = st.visible
		for e in st.get_children():
			s.emit.append(e.emitting)
			s.ratio.append(e.amount_ratio)
			s.amount.append(e.amount)
			s.shown.append(e.is_visible_in_tree())
			s.proc.append(e.can_process())
	samples.append(s)

func S() -> Array:
	return samples

func both(values: Array, v: Variant) -> bool:
	return values.size() == 2 and values[0] == v and values[1] == v

# B-R3: amount_ratio on both emitters = fire_height() / 34, clamped to 0..1.
func ratio_ok(s: Dictionary) -> bool:
	var want := clampf(s.h / FULL, 0.0, 1.0)
	return s.ratio.size() == 2 and absf(s.ratio[0] - want) <= EPS and absf(s.ratio[1] - want) <= EPS

# B-R4: the root at the fire's top centre.
func pos_ok(s: Dictionary) -> bool:
	return s.pos.distance_to(Vector2(TOP.x, TOP.y - s.h)) <= POS_EPS

func first_from(from: int, pred: Callable) -> int:
	for i in range(maxi(from, 0), S().size()):
		if pred.call(S()[i]):
			return i
	return -1

# pred holds on every sample in [a, b), and there is at least one.
func all_of(a: int, b: int, pred: Callable) -> bool:
	if a < 0 or b <= a or b > S().size():
		return false
	for i in range(a, b):
		if not pred.call(S()[i]):
			return false
	return true

func brief(s: Dictionary) -> Dictionary:
	return {"state": s.state, "hosing": s.hosing, "fire_height": snappedf(s.h, 0.0001), "emitting": s.emit,
		"amount_ratio": s.ratio, "amount": s.amount, "root_at": str(s.pos), "water_ticks": s.water, "extinguish_ticks": s.ext}

func run() -> void:
	sampler = Sampler.new()
	sampler.process_priority = 100
	sampler.process_mode = Node.PROCESS_MODE_ALWAYS
	sampler.take = sample
	root.add_child(sampler)
	game = Main.instantiate()
	game.test_mode = true
	root.add_child(game)
	await steps(30)
	frame_s = root.get_process_delta_time()
	tpf = maxi(1, roundi(frame_s * Engine.physics_ticks_per_second))
	var tol := float(tpf) / EXT + EPS   # one frame of the fire's 4.0 s fall, as a ratio
	var fire: Array = game.level.blocking_fire

	# --- B-R1 and "No steam on scene load": one HoseSteam in the level, not emitting, preprocess 0 ---
	var found := in_tree(STEAM_PATH)
	if found.size() != 1:
		check("none-on-load", false, {"hose_steams_in_tree": found.size()})
		return finish()
	var steam: Node2D = found[0]
	steam_id = steam.get_instance_id()
	var kids: Array = []
	var pre: Array = []
	for c in steam.get_children():
		kids.append("%s:%s" % [c.name, c.get_class()])
		pre.append(c.preprocess)
	check("none-on-load", game.state == Game.State.MENU and pre == [0.0, 0.0] and all_of(0, S().size(), func(s): return not s.hosing and both(s.emit, false)),
		{"state": game.state, "frames": S().size(), "emitting": S().back().emit, "preprocess": pre, "root_at": str(steam.position),
		"level_fire": fire, "brief_top_and_full": [str(TOP), FULL]})

	# --- B-R1: not on start (Enter) ---
	var s0 := S().size()
	await tap(KEY_ENTER)
	await steps(30)
	check("none-on-start", game.state == Game.State.PLAYING and all_of(s0, S().size(), func(s): return not s.hosing and both(s.emit, false)),
		brief(S().back()))

	# --- B-R1: W at the spawn, out of range of the fire: no hosing, no steam ---
	s0 = S().size()
	await tap(KEY_W)
	await steps(30)
	var c := brief(S().back())
	c.merge({"player_at": str(game.player.position), "hose_sounds": game.sfx_counts.hose, "fire_active": game.fire_active})
	check("none-out-of-range", game.sfx_counts.hose == 0 and game.fire_active and all_of(s0, S().size(), func(s): return not s.hosing and both(s.emit, false)), c)

	# --- B-R1: a jump and its landing (a JumpPuff, placed just before the player) start nothing ---
	s0 = S().size()
	await tap(KEY_SPACE)
	var puffed: bool = await wait_for(func(): return in_tree(PUFF_PATH).size() > 0, 90)
	await steps(10)
	c = brief(S().back())
	c.merge({"jumps": game.player.jumps, "landing_puff_seen": puffed, "steam_index": S().back().idx, "player_index": S().back().pidx})
	check("none-on-landing", puffed and game.player.jumps == 1 and all_of(s0, S().size(), func(s): return not s.hosing and both(s.emit, false)), c)

	# --- Attempt 1, a clean hose: start, the loop at five fire strengths, the root, the stop ---
	var a1: int = await hose()
	await wait_for(func(): return game.player.hosing, 10)
	await wait_for(func(): return not game.player.hosing, 400)
	await steps(60)
	var i_h := first_from(a1, func(s): return s.hosing)
	var i_end := first_from(i_h, func(s): return not s.hosing) if i_h >= 0 else -1
	if i_h < 1 or i_end < 0:
		check("starts-with-hosing", false, {"first_hosing": i_h, "first_not_hosing_after": i_end})
		return finish()
	var hs: Dictionary = S()[i_h]
	c = {"before": brief(S()[i_h - 1]), "first_hosing_frame": brief(hs), "frames_from_stand_to_first_hosing": i_h - a1}
	check("starts-with-hosing", not S()[i_h - 1].hosing and both(S()[i_h - 1].emit, false) and both(hs.emit, true)
		and all_of(a1, i_h, func(s): return both(s.emit, false)) and absf(hs.ratio[0] - 1.0) <= tol and hs.amount == AMOUNTS, c)

	var points: Array = []
	var strengths_ok := true
	for t in [0.0, 1.0, 2.0, 3.0, 4.0]:
		var k := i_h + roundi(t / frame_s)
		var expected := maxf(0.0, 1.0 - t / 4.0)
		var s: Dictionary = S()[k] if k < i_end else {}
		var ok: bool = not s.is_empty() and s.hosing and ratio_ok(s) and s.amount == AMOUNTS and absf(s.ratio[0] - expected) <= tol
		strengths_ok = strengths_ok and ok
		points.append({"t_s": t, "expected": expected, "amount_ratio": s.get("ratio"), "fire_height": s.get("h"), "amount": s.get("amount"), "ok": ok})
	var distinct := {}
	for i in range(i_h, i_end):
		distinct[snappedf(S()[i].ratio[0], 1e-6)] = true
	var z := first_from(i_h, func(s): return s.ratio.size() == 2 and s.ratio[0] == 0.0)
	var four := roundi(4.0 / frame_s)
	check("ratio-at-strengths", strengths_ok and distinct.size() >= 2 and z > i_h and z - i_h <= four and z - i_h >= four - tpf
		and all_of(z, i_end, func(s): return both(s.ratio, 0.0)),
		{"points": points, "tolerance": tol, "distinct_ratios_while_hosing": distinct.size(), "zero_from_s": (z - i_h) * frame_s if z > 0 else -1.0})

	var moved: float = S()[i_end - 1].pos.y - hs.pos.y
	check("position-follows-fire", all_of(i_h, i_end, func(s): return pos_ok(s)) and absf(moved - hs.h) <= POS_EPS,
		{"hosing_frames": i_end - i_h, "root_at_first": str(hs.pos), "root_at_last": str(S()[i_end - 1].pos), "moved_down_px": moved, "fire_height_at_first": hs.h})

	var last: Dictionary = S()[i_end - 1]
	var off: Dictionary = S()[i_end]
	c = {"last_hosing_frame": brief(last), "first_frame_not_hosing": brief(off), "linger_s": (i_end - z) * frame_s, "hosing_s": (i_end - i_h) * frame_s,
		"frames_checked_after": S().size() - i_end, "visible": off.vis, "emitters_visible": off.shown}
	check("stops-with-hosing", last.hosing and both(last.emit, true) and both(last.ratio, 0.0) and both(off.emit, false) and off.water == 0
		and all_of(i_end, S().size(), func(s): return not s.hosing and both(s.emit, false) and s.id == steam_id and s.steams == 1 and s.vis and both(s.shown, true)), c)

	# --- B-R1: not on R (R after the water has stopped) ---
	s0 = S().size()
	await tap(KEY_R)
	await steps(30)
	c = brief(S().back())
	c.merge({"player_at": str(game.player.position)})
	check("none-on-restart", game.state == Game.State.PLAYING and game.player.position.distance_to(SPAWN) < 1.0
		and all_of(s0, S().size(), func(s): return not s.hosing and both(s.emit, false)), c)

	# --- Attempt 2: B-R5 game pause (Esc) at 1.5 s, B-R5 tree pause at 2.5 s, B-R7 R at 3.0 s ---
	await hose()
	await wait_for(func(): return game.extinguish_ticks > 0 and game.extinguish_ticks <= EXT - 90, 200)
	var esc_from := S().size()
	await tap(KEY_ESCAPE)
	await steps(60)
	await tap(KEY_ENTER)
	await steps(10)
	var esc_to := S().size()
	var held: Array = range(esc_from, esc_to).filter(func(i): return S()[i].state == Game.State.PAUSED)
	var esc_ok := held.size() >= 60
	var p0: Dictionary = S()[held[0]] if esc_ok else {}
	if esc_ok:
		for i in held:
			var s: Dictionary = S()[i]
			esc_ok = esc_ok and s.hosing and both(s.emit, true) and s.ext == p0.ext and s.water == p0.water and s.ratio == p0.ratio and s.pos == p0.pos and both(s.proc, true) and not s.paused
		esc_ok = esc_ok and p0.ratio[0] > 0.0 and p0.ratio[0] < 1.0 and ratio_ok(p0) and S()[held[0] - 1].ratio == p0.ratio and S()[esc_to - 1].ratio[0] < p0.ratio[0]
	check("game-pause-holds", esc_ok,
		{"paused_frames": held.size(), "at_pause": brief(p0) if not p0.is_empty() else {}, "emitters_processing_while_paused": p0.get("proc"), "tree_paused": p0.get("paused"),
		"after_resume": brief(S()[esc_to - 1])})

	await wait_for(func(): return game.extinguish_ticks > 0 and game.extinguish_ticks <= EXT - 150, 200)
	await physics_frame
	paused = true   # set before this tick's physics: the session stops on the values the driver last wrote
	var tp_from := S().size()
	await process_frame
	await steps(59)
	await physics_frame
	paused = false
	var tp_to := S().size()
	await process_frame
	await steps(10)
	var before: Dictionary = S()[tp_from - 1]
	var frozen: Array = range(tp_from, tp_to).filter(func(i): return S()[i].paused)
	var tree_ok: bool = frozen.size() >= 60 and before.hosing and not before.paused
	for i in frozen:
		var s: Dictionary = S()[i]
		tree_ok = tree_ok and s.hosing and s.h == before.h and s.ext == before.ext and s.water == before.water and s.emit == before.emit and s.ratio == before.ratio
		tree_ok = tree_ok and s.pos == before.pos and s.vis and both(s.shown, true) and both(s.proc, false)
	tree_ok = tree_ok and S()[S().size() - 1].ext < before.ext
	check("tree-pause-holds", tree_ok,
		{"paused_frames": frozen.size(), "before_pause": brief(before), "while_paused": brief(S()[tp_to - 1]) if tp_to > tp_from else {},
		"emitters_processing_while_paused": S()[tp_to - 1].proc if tp_to > tp_from else [], "emitters_visible_while_paused": S()[tp_to - 1].shown if tp_to > tp_from else [],
		"extinguish_ticks_after": S().back().ext})

	await wait_for(func(): return game.extinguish_ticks > 0 and game.extinguish_ticks <= EXT - 180, 200)
	var r_from := S().size()
	await tap(KEY_R)
	await steps(60)
	var i_off := first_from(r_from, func(s): return not s.hosing)
	var r_ok := i_off > r_from
	if r_ok:
		var on: Dictionary = S()[i_off - 1]
		var r: Dictionary = S()[i_off]
		r_ok = on.hosing and both(on.emit, true) and on.water > 1 and both(r.emit, false) and r.state == Game.State.PLAYING and r.water == 0 and r.ext == 0
		r_ok = r_ok and r.p.distance_to(SPAWN) < 1.0 and all_of(i_off, S().size(), func(s): return not s.hosing and both(s.emit, false))
	check("restart-stops", r_ok,
		{"last_hosing_frame": brief(S()[i_off - 1]) if i_off > 0 else {}, "first_frame_after_R": brief(S()[i_off]) if i_off >= 0 else {},
		"player_after_R": str(S()[i_off].p) if i_off >= 0 else "", "frames_checked_after": S().size() - i_off})

	# --- Attempt 3: B-R1 again after R, then B-R7 fire death during hosing (D held into the fire) ---
	var a3: int = await hose()
	await wait_for(func(): return game.extinguish_ticks > 0 and game.extinguish_ticks <= EXT - 60, 100)
	var i_h3 := first_from(a3, func(s): return s.hosing)
	var again_ok := i_h3 > a3 and both(S()[i_h3 - 1].emit, false) and both(S()[i_h3].emit, true) and absf(S()[i_h3].ratio[0] - 1.0) <= tol and pos_ok(S()[i_h3])
	check("starts-again-after-restart", again_ok, {"first_hosing_frame": brief(S()[i_h3]) if i_h3 >= 0 else {}, "tolerance": tol})
	key(KEY_D, true)
	var died: bool = await wait_for(func(): return game.state == Game.State.DYING, 90)
	key(KEY_D, false)
	var back: bool = await wait_for(func(): return game.state == Game.State.PLAYING, 200)
	await steps(30)
	var d0 := first_from(a3, func(s): return s.state == Game.State.DYING)
	var d1 := first_from(d0, func(s): return s.state != Game.State.DYING) if d0 >= 0 else -1
	var death_ok: bool = died and back and d0 > 0 and d1 > d0 and game.death_reason == "The fire got you."
	if death_ok:
		var dy: Dictionary = S()[d0]
		death_ok = dy.ratio[0] > 0.0 and dy.ratio[0] < 1.0 and all_of(d0, d1, func(s): return s.hosing and both(s.emit, true) and s.ratio == dy.ratio and s.pos == dy.pos)
		death_ok = death_ok and S()[d1].state == Game.State.PLAYING and not S()[d1].hosing and both(S()[d1].emit, false)
	check("fire-death-holds", death_ok,
		{"died": died, "death_reason": game.death_reason, "dying_frames": d1 - d0, "dying_s": (d1 - d0) * frame_s, "at_death": brief(S()[d0]) if d0 >= 0 else {},
		"last_dying_frame": brief(S()[d1 - 1]) if d1 > 0 else {}, "first_frame_after_restart": brief(S()[d1]) if d1 >= 0 else {}})

	# --- Attempt 4: B-R6 hidden from before W until after the water stops ---
	steam.visible = false
	var a4: int = await hose()
	await wait_for(func(): return game.player.hosing, 10)
	await wait_for(func(): return not game.player.hosing, 400)
	await steps(10)
	var hid_to := S().size()
	steam.visible = true
	await steps(5)
	var i_h4 := first_from(a4, func(s): return s.hosing)
	var i_e4 := first_from(i_h4, func(s): return not s.hosing) if i_h4 >= 0 else -1
	var hid_ok := i_h4 > a4 and i_e4 > i_h4 and i_e4 < hid_to
	var hid_ratios := {}
	if hid_ok:
		for i in range(i_h4, i_e4):
			hid_ratios[snappedf(S()[i].ratio[0], 1e-6)] = true
		hid_ok = all_of(a4, hid_to, func(s): return not s.vis and both(s.shown, false)) and both(S()[i_h4 - 1].emit, false) and both(S()[i_h4].emit, true)
		hid_ok = hid_ok and both(S()[i_e4].emit, false) and hid_ratios.size() >= 2 and all_of(i_h4, i_e4, func(s): return ratio_ok(s) and pos_ok(s))
	check("hidden-still-driven", hid_ok,
		{"hidden_frames": hid_to - a4, "hosing_frames_while_hidden": i_e4 - i_h4, "distinct_ratios_while_hidden": hid_ratios.size(),
		"first_hosing_frame": brief(S()[i_h4]) if i_h4 >= 0 else {}, "first_frame_not_hosing": brief(S()[i_e4]) if i_e4 >= 0 else {},
		"emitters_visible_while_hidden": S()[i_h4].shown if i_h4 >= 0 else [], "visible_again": S().back().vis})

	# --- over the whole run ---
	var bad_emit := 0
	var bad_ratio := 0
	var bad_pos := 0
	var bad_amount := 0
	var hosing_frames := 0
	for s in S():
		if s.emit != [s.hosing, s.hosing]:
			bad_emit += 1
		if s.amount != AMOUNTS:
			bad_amount += 1
		if s.hosing:
			hosing_frames += 1
			if not ratio_ok(s):
				bad_ratio += 1
			if not pos_ok(s):
				bad_pos += 1
	check("every-frame", hosing_frames > 0 and bad_emit == 0 and bad_ratio == 0 and bad_pos == 0 and bad_amount == 0,
		{"frames": S().size(), "hosing_frames": hosing_frames, "emitting_not_hosing": bad_emit, "ratio_off_rule": bad_ratio, "root_off_fire_top": bad_pos, "amount_changed": bad_amount})
	var one := S().filter(func(s): return s.steams == 1 and s.id == steam_id and s.parent_ok).size()
	check("one-steam-in-level", one == S().size() and kids == KIDS,
		{"frames": S().size(), "frames_with_the_same_one_steam_in_the_level": one, "children": kids})
	var behind := S().filter(func(s): return s.idx >= 0 and s.idx < s.pidx).size()
	var with_puff := S().filter(func(s): return s.puffs > 0).size()
	check("steam-behind-player", behind == S().size() and with_puff > 0,
		{"frames": S().size(), "frames_steam_index_below_player": behind, "frames_with_a_live_puff": with_puff, "steam_index_at_end": S().back().idx, "player_index_at_end": S().back().pidx})
	finish()

func finish() -> void:
	print("HOSE STEAM STATE: %d checks / %d failures (physics tick %.6f s, frame %.6f s)" % [results.size(), failures, 1.0 / Engine.physics_ticks_per_second, frame_s])
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)
