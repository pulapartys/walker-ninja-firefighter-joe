extends SceneTree
# A6 Effect A, jump puff (CHANGE-BRIEF A4, Revision 1 A-R8, Revision 2): the driver's rules, headless.
# Revision 2: the puff comes from player.landed (on the floor after more than 10 ticks in the air), not
# from the jump. Every landing comes out of the real game loop (res://game/main.tscn), driven by real
# keys through Godot Input: Space, D, A, R and Esc, plus Enter to start or resume and M for the menu.
# The test never emits `landed`, never calls the driver and never moves the player. It only watches:
# SceneTree.node_added for a JumpPuff added anywhere in the tree, each emitter's `finished`, each puff's
# tree_exited, and its own connections to player.jumped and player.landed, which record the tick, his
# feet and his air ticks at every emit.
# Two things the test does that a player can't: it enters COMPLETE through the session's own
# resolve_contacts(false, true) while he is in the air (the real route needs both rescues), and it sets
# the tree pause (the game never does).
# Not tested: a landing after 10 ticks or fewer in the air. Real keys can't make one on first_steps.json;
# its lowest drop, the 16 px step, takes 11 ticks (walk-off-landing reports the count).
# Run: scripts/run-test.sh test_jump_puff_state.gd 60
# What this cannot see: pixels or particle positions. Headless Godot draws nothing (CLAUDE.md,
# Headless facts); the look, the draw order on screen and the frozen frame are eye checks.
const Main = preload("res://game/main.tscn")
const Game = preload("res://game/session.gd")
const PUFF_PATH := "res://effects/jump_puff.tscn"
const KIDS := ["Flash:CPUParticles2D", "Puff:CPUParticles2D", "Specks:CPUParticles2D"]
const LIFE := 0.9      # A-R5: freed within 0.9 s (+ one frame) of its landing; the Puff layer's lifetime
const SHORTEST := 0.72 # the Puff layer's shortest possible life: lifetime 0.9 x (1 - lifetime_randomness 0.2) (A3)
const EPS := 1e-6
const SPAWN := Vector2(64, 320)
const GROUND_Y := 320.0  # top of the street ground (first_steps.json [0, 320, 448, 64])
const STEP_TOP := 304.0  # top of the 16 px step at x 160-208 (first_steps.json [160, 304, 48, 16])
const FEET_EPS := 0.5    # his feet rest this close above a floor's top (the body's safe margin)
var game: Node2D
var results: Array[Dictionary] = []
var failures := 0
var tick_s := 0.0      # one physics tick in seconds
var frame_s := 0.0     # one drawn frame in seconds: the "one frame" of A-R5
var jumps: Array = []     # per player.jumped, in order: {tick, pos, state}
var landings: Array = []  # per player.landed, in order: {tick, pos, state, air_ticks, on_floor, live_after}
var puffs: Array = []  # per JumpPuff added, in order: {node, id, tick, pos, parent, kids, emitting, finished, freed_tick, freed_state, samples, moved, max_dist}
var seen_landings := 0
var tree_pauses: Array = []  # [from_tick, to_tick] of each tree pause the test made
var max_live := 0
var looked := 0        # live-puff samples taken (once per live puff per frame)
var moved := 0         # samples where a live puff's root was not where it was made (A-R4)
var wrong_parent := 0  # samples where a live puff was not a child of WalkerJumpman (A-R6)
var in_front := 0      # samples where a live puff's index was not below the player's (A-R8)

func _initialize() -> void:
	call_deferred("run")

func tick() -> int:
	return Engine.get_physics_frames()

# One frame, then one look at every live puff (after this frame's physics, before its _process).
func steps(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
		sample()

# Synthetic key event through Godot Input, as test_keyboard.gd and test_hose_glow.gd.
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

# One real jump: Space down until the jump is seen (at most 10 frames), then up.
func jump() -> bool:
	var n := jumps.size()
	key(KEY_SPACE, true)
	await wait_for(func(): return jumps.size() > n, 10)
	key(KEY_SPACE, false)
	await steps(1)
	return jumps.size() == n + 1

# Space as he falls the last 12 px to where he jumped from: inside the 6-tick jump buffer, so the
# next jump starts on the tick after the landing (CHANGE-BRIEF "Jump timing").
func jump_on_landing() -> bool:
	var from_y: float = jumps.back().pos.y
	await wait_for(func(): return game.player.velocity.y > 0.0 and game.player.position.y >= from_y - 12.0, 90)
	return await jump()

# Onto the 16 px step with real keys, from the ground to its left: D held, Space at x 110, D let go at
# x 176, so he comes down on the step's top. True if that landing was on the step.
func onto_step() -> bool:
	var n := landings.size()
	key(KEY_D, true)
	await wait_for(func(): return game.player.position.x >= 110.0, 90)
	var ok: bool = await jump()
	await wait_for(func(): return game.player.position.x >= 176.0, 60)
	key(KEY_D, false)
	await wait_for(func(): return landings.size() > n, 90)
	return ok and landings.size() == n + 1 and absf(landings.back().pos.y - STEP_TOP) < FEET_EPS

# In the air above the street ground (where every mid-air check below happens).
func airborne() -> bool:
	return not game.player.is_on_floor() and game.player.position.y < GROUND_Y - FEET_EPS

func check(id: String, condition: bool, observed: Dictionary) -> void:
	results.append({"id": id, "status": "PASS" if condition else "FAIL", "observed": observed})
	print(JSON.stringify(results.back()))
	if not condition:
		failures += 1

# --- watchers: they read, never write ---

func _on_node_added(node: Node) -> void:
	if node.scene_file_path != PUFF_PATH:
		return
	var rec := {"node": node, "id": node.get_instance_id(), "tick": tick(), "pos": node.global_position,
		"parent": node.get_parent(), "kids": [], "emitting": [], "finished": {}, "freed_tick": -1,
		"freed_state": -1, "samples": 0, "moved": 0, "max_dist": 0.0}
	for c in node.get_children():
		rec.kids.append("%s:%s" % [c.name, c.get_class()])
		rec.emitting.append(c.emitting)
		c.finished.connect(_on_emitter_finished.bind(rec, String(c.name)))
	node.tree_exited.connect(_on_puff_exited.bind(rec))
	puffs.append(rec)

func _on_emitter_finished(rec: Dictionary, emitter: String) -> void:
	rec.finished[emitter] = tick()

func _on_puff_exited(rec: Dictionary) -> void:
	rec.freed_tick = tick()
	rec.freed_state = game.state if is_instance_valid(game) else -1

func _on_jumped() -> void:
	jumps.append({"tick": tick(), "pos": game.player.global_position, "state": game.state})

# Runs inside the emit, before _update_pose() zeroes air_ticks, so air_ticks is his time in the air.
func _on_landed() -> void:
	var p: CharacterBody2D = game.player
	landings.append({"tick": tick(), "pos": p.global_position, "state": game.state, "air_ticks": p.air_ticks,
		"on_floor": p.is_on_floor(), "live_after": -1})

func live() -> Array:
	return puffs.filter(func(r): return r.freed_tick < 0)

func sample() -> void:
	if not is_instance_valid(game):
		return
	var alive := live()
	max_live = maxi(max_live, alive.size())
	if seen_landings < landings.size():
		landings.back().live_after = alive.size()   # puffs alive at the end of the landing's physics tick
		seen_landings = landings.size()
	var player_index: int = game.player.get_index()
	for rec in alive:
		var node: Node2D = rec.node
		looked += 1
		rec.samples += 1
		rec.max_dist = maxf(rec.max_dist, node.global_position.distance_to(game.player.global_position))
		if node.global_position != rec.pos:
			moved += 1
			rec.moved += 1
		if node.get_parent() != game:
			wrong_parent += 1
		if node.get_index() >= player_index:
			in_front += 1

func puffs_in_tree() -> int:
	var n := 0
	for node in root.find_children("*", "", true, false):
		if node.scene_file_path == PUFF_PATH:
			n += 1
	return n

# Puffs added in physics ticks [from, to).
func puffs_between(from: int, to: int) -> int:
	return puffs.filter(func(r): return r.tick >= from and r.tick < to).size()

# Seconds of unpaused game time from its landing to its free (tree pauses the test made are taken out).
func life(rec: Dictionary) -> float:
	var ticks: int = rec.freed_tick - rec.tick
	for p in tree_pauses:
		ticks -= maxi(0, mini(rec.freed_tick, p[1]) - maxi(rec.tick, p[0]))
	return ticks * tick_s

# A-R5: within LIFE plus one frame; and not before SHORTEST minus one frame. Not LIFE minus one frame:
# with lifetime_randomness the last Puff particle can die early (unseeded puffs, no game: 1 in 400
# finished 3 frames early).
func on_time(rec: Dictionary) -> bool:
	var l := life(rec)
	return rec.freed_tick >= 0 and l <= LIFE + frame_s + EPS and l >= SHORTEST - frame_s - EPS

# A-R5: all three emitters finished, and the puff was freed in the frame the last one did.
func all_finished(rec: Dictionary) -> bool:
	if rec.finished.size() != KIDS.size():
		return false
	var last := -1
	for t in rec.finished.values():
		last = maxi(last, t)
	return rec.freed_tick == last

# A-R3 "full puff": the scene's three emitters, all emitting when it was added.
func full(rec: Dictionary) -> bool:
	return rec.kids == KIDS and rec.emitting == [true, true, true]

# Revision 2 A-R1: the puff is the one added in the landing's tick, at his feet then, on the floor at
# floor_y, in PLAYING, after more than 10 ticks in the air.
func at_feet(l: Dictionary, p: Dictionary, floor_y: float) -> bool:
	return p.tick == l.tick and p.pos == l.pos and l.state == Game.State.PLAYING and l.on_floor and absf(l.pos.y - floor_y) < FEET_EPS and l.air_ticks > 10

func landing_info(l: Dictionary, p: Dictionary) -> Dictionary:
	return {"landing_tick": l.tick, "puff_tick": p.tick, "player_at_landing": str(l.pos), "puff_at": str(p.pos),
		"on_floor": l.on_floor, "air_ticks": l.air_ticks, "state_at_landing": l.state}

func timings(rec: Dictionary) -> Dictionary:
	var out := {}
	for k in rec.finished:
		out[k] = snappedf((rec.finished[k] - rec.tick) * tick_s, 0.0001)
	return {"finished_after_s": out, "freed_after_s": snappedf(life(rec), 0.0001), "freed_with_last_finished": all_finished(rec)}

func counts() -> Dictionary:
	return {"state": game.state, "jumped": jumps.size(), "landed": landings.size(), "puffs_added": puffs.size(), "puffs_in_tree": puffs_in_tree()}

func mark() -> Array:
	return [jumps.size(), landings.size(), puffs.size()]

func same(m: Array) -> bool:
	return jumps.size() == m[0] and landings.size() == m[1] and puffs.size() == m[2]

func run() -> void:
	node_added.connect(_on_node_added)
	tick_s = 1.0 / Engine.physics_ticks_per_second
	game = Main.instantiate()
	game.test_mode = true
	root.add_child(game)
	game.player.jumped.connect(_on_jumped)
	game.player.landed.connect(_on_landed)
	await steps(30)
	frame_s = root.get_process_delta_time()

	# --- A-R2: nothing on scene load, in MENU, or on start (the start respawns him) ---
	check("none-on-load", game.state == Game.State.MENU and puffs.is_empty() and landings.is_empty() and puffs_in_tree() == 0, counts())
	await tap(KEY_SPACE)
	await steps(10)
	check("none-in-menu", game.state == Game.State.MENU and puffs.is_empty() and jumps.is_empty() and landings.is_empty(), counts())
	await tap(KEY_ENTER)
	await steps(10)
	check("none-on-start", game.state == Game.State.PLAYING and game.player.is_on_floor() and puffs.is_empty() and jumps.is_empty() and landings.is_empty(), counts())

	# --- Revision 2 A-R1/A-R2, A-R4, A-R5, A-R6: one real jump with D held for 12 frames, so he comes down
	# away from where he took off: nothing on the jump, one puff on the landing; then A walks him away ---
	key(KEY_D, true)
	var jumped: bool = await jump()
	var at_jump := puffs.size()
	await steps(12)
	key(KEY_D, false)
	var landed: bool = await wait_for(func(): return landings.size() > 0, 90)
	key(KEY_A, true)
	await steps(30)
	key(KEY_A, false)
	await wait_for(func(): return live().is_empty(), 90)
	if not jumped or not landed or jumps.size() != 1 or landings.size() != 1 or puffs.size() != 1:
		check("none-on-jump", false, counts())
		return finish()
	var j: Dictionary = jumps[0]
	var l: Dictionary = landings[0]
	var p: Dictionary = puffs[0]
	check("none-on-jump", at_jump == 0 and puffs_between(j.tick, l.tick) == 0 and p.tick == l.tick and p.tick != j.tick,
		{"jump_tick": j.tick, "puffs_after_jump_frame": at_jump, "puffs_while_in_air": puffs_between(j.tick, l.tick), "landing_tick": l.tick, "puff_tick": p.tick})
	var info := landing_info(l, p)
	info.merge({"player_at_jump": str(j.pos), "takeoff_to_puff_px": snappedf(j.pos.distance_to(p.pos), 0.01)})
	check("one-puff-at-landing", at_feet(l, p, GROUND_Y) and j.pos.distance_to(p.pos) >= 15.0, info)
	check("parent-is-level", p.parent == game and p.parent != game.player and full(p),
		{"parent": str(p.parent.name) if is_instance_valid(p.parent) else "", "children": p.kids, "emitting_when_added": p.emitting})
	check("stays-put", p.samples > 0 and p.moved == 0 and p.max_dist >= 30.0,
		{"frames_sampled": p.samples, "frames_moved": p.moved, "player_max_distance_px": snappedf(p.max_dist, 0.01), "puff_at": str(p.pos)})
	var t := timings(p)
	t.merge({"expected_s": LIFE, "earliest_s": SHORTEST,"tolerance_s": frame_s, "puffs_in_tree": puffs_in_tree()})
	check("frees-when-finished", all_finished(p) and on_time(p) and puffs_in_tree() == 0, t)

	# --- A-R3 overlap: four jumps, each Space just before he lands, so each jump starts on the tick after
	# a landing and the next landing comes 0.8 s later on flat ground, inside one 0.9 s puff life ---
	await steps(10)
	max_live = 0
	var i1 := landings.size()
	var chain_ok: bool = await jump()
	for k in range(3):
		if not await jump_on_landing():
			chain_ok = false
	await wait_for(func(): return landings.size() >= i1 + 4, 90)
	await wait_for(func(): return live().is_empty(), 90)
	if not chain_ok or landings.size() != i1 + 4 or puffs.size() != i1 + 4:
		check("retrigger-overlap", false, counts())
		return finish()
	var gaps: Array = []
	for k in range(i1 + 1, i1 + 4):
		gaps.append(snappedf((landings[k].tick - landings[k - 1].tick) * tick_s, 0.0001))
	var l1: Dictionary = landings[i1]
	var l2: Dictionary = landings[i1 + 1]
	var p1: Dictionary = puffs[i1]
	var p2: Dictionary = puffs[i1 + 1]
	var gap: float = (l2.tick - l1.tick) * tick_s
	check("retrigger-overlap", gap < LIFE and l2.live_after == 2 and p1.tick == l1.tick and p1.freed_tick > l2.tick and p1.finished.get("Puff", -1) > l2.tick and p2.id != p1.id and at_feet(l2, p2, GROUND_Y) and full(p2),
		{"landing_gap_s": gap, "live_at_landing_2": l2.live_after, "first_freed_after_landing_2_s": (p1.freed_tick - l2.tick) * tick_s, "first_puff_layer_running_at_landing_2": p1.finished.get("Puff", -1) > l2.tick, "second_is_new_instance": p2.id != p1.id, "second_full": full(p2), "second_at": str(p2.pos), "player_at_landing_2": str(l2.pos)})
	var t1 := timings(p1)
	var t2 := timings(p2)
	check("first-not-restarted", all_finished(p1) and on_time(p1) and all_finished(p2) and on_time(p2),
		{"first": t1, "second": t2, "first_if_restarted_at_landing_2_s": gap + LIFE, "expected_s": LIFE, "earliest_s": SHORTEST,"tolerance_s": frame_s})
	check("max-two-alive", max_live == 2, {"landings": 4, "landing_gaps_s": gaps, "max_live": max_live})

	# --- Revision 2 on a higher floor, A-R2 (R) and A-R6: real keys put him on the 16 px step; R 0.2 s
	# after that landing: no puff from R or the respawn, and the step puff stays where it was made ---
	await steps(10)
	var on_step: bool = await onto_step()
	var sl: Dictionary = landings.back()
	var sp: Dictionary = puffs.back()
	check("one-puff-on-step", on_step and at_feet(sl, sp, STEP_TOP), landing_info(sl, sp))
	await wait_for(func(): return tick() - sp.tick >= 12, 30)
	var m := mark()
	await tap(KEY_R)
	await steps(10)
	var at_spawn: bool = game.player.position.distance_to(SPAWN) < 1.0
	var c := counts()
	c.merge({"player_at": str(game.player.position)})
	check("none-on-restart", game.state == Game.State.PLAYING and at_spawn and game.player.is_on_floor() and same(m), c)
	var after_r: bool = sp.freed_tick < 0 and sp.node.get_parent() == game and sp.node.global_position == sp.pos
	var apart: float = sp.pos.distance_to(game.player.global_position)
	await wait_for(func(): return sp.freed_tick >= 0, 90)
	t = timings(sp)
	t.merge({"alive_in_level_after_R": after_r, "puff_at": str(sp.pos), "player_after_R": str(game.player.position), "apart_px": snappedf(apart, 0.01), "expected_s": LIFE, "earliest_s": SHORTEST,"tolerance_s": frame_s})
	check("restart-mid-puff", after_r and apart > 50.0 and sp.moved == 0 and all_finished(sp) and on_time(sp), t)

	# --- Revision 2 A-R2: walking off the step is a landing when he is in the air more than 10 ticks; D
	# stays held, so he walks on into the street spike fire (x 320-344): DYING. Space and A while DYING
	# do nothing; the restart after the 2.0 s hold is a respawn, not a landing ---
	await steps(5)
	var on_step_2: bool = await onto_step()
	await steps(5)
	m = mark()
	key(KEY_D, true)
	var left_step: bool = await wait_for(func(): return not game.player.is_on_floor(), 60)
	var air_from := tick()
	var down: bool = await wait_for(func(): return game.player.is_on_floor(), 60)
	var air_measured := tick() - air_from
	var wl: Dictionary = landings.back()
	var wp: Dictionary = puffs.back()
	info = landing_info(wl, wp)
	info.merge({"on_step_before": on_step_2, "left_step": left_step, "air_ticks_measured_by_test": air_measured, "jumped_since_on_step": jumps.size() - m[0], "landed_since_on_step": landings.size() - m[1], "puffs_since_on_step": puffs.size() - m[2]})
	check("walk-off-landing", on_step_2 and left_step and down and jumps.size() == m[0] and landings.size() == m[1] + 1 and puffs.size() == m[2] + 1 and air_measured > 10 and wl.air_ticks == air_measured and at_feet(wl, wp, GROUND_Y), info)
	var died: bool = await wait_for(func(): return game.state == Game.State.DYING, 90)
	key(KEY_D, false)
	m = mark()
	await tap(KEY_SPACE)
	await tap(KEY_A)
	var still_dying: bool = game.state == Game.State.DYING
	var back: bool = await wait_for(func(): return game.state == Game.State.PLAYING, 150)
	var none_dying := same(m)
	c = counts()
	c.merge({"died": died, "death_reason": game.death_reason, "space_and_a_while_dying": still_dying, "restarted": back, "walk_off_puff_freed_in_state": wp.freed_state})
	check("none-while-dying", died and game.death_reason == "The fire got you." and still_dying and back and none_dying, c)
	await steps(10)
	c = counts()
	c.merge({"player_at": str(game.player.position)})
	check("none-on-respawn", game.state == Game.State.PLAYING and game.player.position.distance_to(SPAWN) < 1.0 and game.player.is_on_floor() and same(m), c)

	# --- A-R2 (R mid-air): R while he is in the air puts him back on the spawn point; that respawn is not
	# a landing (reset_at), and the landing he was heading for never comes ---
	await steps(5)
	await jump()
	await steps(15)
	var up := airborne()
	m = mark()
	await tap(KEY_R)
	await steps(60)
	c = counts()
	c.merge({"in_air_at_R": up, "player_at": str(game.player.position)})
	check("none-on-restart-midair", up and game.state == Game.State.PLAYING and game.player.position.distance_to(SPAWN) < 1.0 and game.player.is_on_floor() and same(m), c)

	# --- A-R2 (PAUSED) and A-R7 (Esc): Esc while he is in the air holds him there (Esc stops the player,
	# not the tree): no landing, no puff for 1 s, Space included. Enter resumes, he comes down, and that
	# landing makes one puff; Esc again at once, and the puff finishes on time while paused ---
	await steps(5)
	await jump()
	await steps(15)
	up = airborne()
	await tap(KEY_ESCAPE)
	var esc_paused: bool = game.state == Game.State.PAUSED
	m = mark()
	await steps(60)
	await tap(KEY_SPACE)
	await steps(5)
	c = counts()
	c.merge({"in_air_at_esc": up, "still_in_air": airborne(), "player_at": str(game.player.position)})
	check("none-while-paused", up and esc_paused and game.state == Game.State.PAUSED and airborne() and same(m), c)
	await tap(KEY_ENTER)
	var resumed: bool = game.state == Game.State.PLAYING
	var came_down: bool = await wait_for(func(): return landings.size() > m[1], 90)
	await tap(KEY_ESCAPE)
	var paused_again: bool = game.state == Game.State.PAUSED
	var rl: Dictionary = landings.back()
	var pp: Dictionary = puffs.back()
	info = landing_info(rl, pp)
	info.merge({"resumed": resumed, "landed_since_esc": landings.size() - m[1], "puffs_since_esc": puffs.size() - m[2]})
	check("landing-after-resume", resumed and came_down and landings.size() == m[1] + 1 and puffs.size() == m[2] + 1 and at_feet(rl, pp, GROUND_Y), info)
	await wait_for(func(): return pp.freed_tick >= 0, 90)
	t = timings(pp)
	t.merge({"paused_after_landing": paused_again, "state_when_freed": pp.freed_state, "expected_s": LIFE, "earliest_s": SHORTEST,"tolerance_s": frame_s})
	check("game-pause-puff-finishes", paused_again and pp.freed_state == Game.State.PAUSED and all_finished(pp) and on_time(pp), t)
	await tap(KEY_ENTER)
	await steps(5)

	# --- A-R2 (MENU): Esc then M while he is in the air; the menu holds him there: no landing, no puff,
	# Space included. Enter starts a new session, a respawn: still nothing ---
	await jump()
	await steps(15)
	up = airborne()
	await tap(KEY_ESCAPE)
	await tap(KEY_M)
	var in_menu: bool = game.state == Game.State.MENU
	m = mark()
	await steps(60)
	await tap(KEY_SPACE)
	await steps(5)
	c = counts()
	c.merge({"in_air_at_menu": up, "still_in_air": airborne(), "player_at": str(game.player.position)})
	check("none-in-menu-midair", up and in_menu and game.state == Game.State.MENU and airborne() and same(m), c)
	await tap(KEY_ENTER)
	await steps(30)
	c = counts()
	c.merge({"player_at": str(game.player.position)})
	check("none-on-start-from-menu", game.state == Game.State.PLAYING and game.player.position.distance_to(SPAWN) < 1.0 and game.player.is_on_floor() and same(m), c)

	# --- A-R7 (tree): 0.3 s after a landing the tree is paused for 1.5 s: the puff is not freed, not
	# moved and still visible, and no emitter finishes; afterwards it finishes 0.9 s of unpaused game
	# time after its landing ---
	var n := landings.size()
	await jump()
	await wait_for(func(): return landings.size() > n, 90)
	var tp: Dictionary = puffs.back()
	await wait_for(func(): return tick() - tp.tick >= 18, 30)
	var finished_before: int = tp.finished.size()
	var player_at: Vector2 = game.player.position
	paused = true
	var from := tick()
	await steps(90)
	var held: bool = tp.freed_tick < 0 and is_instance_valid(tp.node) and tp.node.is_inside_tree() and tp.node.is_visible_in_tree() and tp.node.global_position == tp.pos and tp.finished.size() == finished_before and game.player.position == player_at
	var finished_during: int = tp.finished.size() - finished_before
	paused = false
	tree_pauses.append([from, tick()])
	check("tree-pause-freezes", held and landings.size() == n + 1 and tp.tick == landings.back().tick,
		{"paused_s": (tick() - from) * tick_s, "paused_at_s_after_landing": (from - tp.tick) * tick_s, "freed": tp.freed_tick >= 0, "visible": tp.node.is_visible_in_tree() if is_instance_valid(tp.node) else false, "emitters_finished_before_pause": finished_before, "emitters_finished_while_paused": finished_during, "player_moved": game.player.position != player_at})
	await wait_for(func(): return tp.freed_tick >= 0, 90)
	t = timings(tp)
	t.merge({"wall_s_including_pause": (tp.freed_tick - tp.tick) * tick_s, "expected_s": LIFE, "earliest_s": SHORTEST,"tolerance_s": frame_s})
	check("tree-pause-resumes", all_finished(tp) and on_time(tp), t)
	await steps(5)

	# --- A-R2 (COMPLETE): entered through the session's own resolve_contacts while he is in the air (the
	# real route needs both rescues); COMPLETE holds him there: no landing, no puff, Space included ---
	await jump()
	await steps(15)
	up = airborne()
	game.resolve_contacts(false, true)
	m = mark()
	await steps(60)
	await tap(KEY_SPACE)
	await steps(5)
	c = counts()
	c.merge({"in_air_at_complete": up, "still_in_air": airborne(), "player_at": str(game.player.position)})
	check("none-when-complete", up and game.state == Game.State.COMPLETE and airborne() and same(m), c)

	# --- Revision 2 A-R1, A-R4, A-R5, A-R8 over the whole run ---
	var mismatched: Array = []
	var lives: Array = []
	var airs: Array = []
	for i in range(mini(landings.size(), puffs.size())):
		var li: Dictionary = landings[i]
		var ri: Dictionary = puffs[i]
		lives.append(snappedf(life(ri), 0.0001))
		airs.append(li.air_ticks)
		if ri.tick != li.tick or ri.pos != li.pos or li.state != Game.State.PLAYING or not li.on_floor or li.air_ticks <= 10 or not full(ri) or not all_finished(ri) or not on_time(ri):
			mismatched.append(i)
	check("every-landing-one-puff", landings.size() == puffs.size() and landings.size() > 0 and mismatched.is_empty() and puffs_in_tree() == 0,
		{"landed": landings.size(), "puffs_added": puffs.size(), "mismatched": mismatched, "air_ticks": airs, "lives_s": lives, "expected_s": LIFE, "earliest_s": SHORTEST,"tolerance_s": frame_s, "puffs_in_tree_at_end": puffs_in_tree()})
	var jump_ticks: Array = jumps.map(func(e): return e.tick)
	var in_jump_tick: int = puffs.filter(func(r): return r.tick in jump_ticks).size()
	check("none-on-any-jump", jumps.size() > 0 and in_jump_tick == 0,
		{"jumped": jumps.size(), "landed": landings.size(), "puffs_added": puffs.size(), "puffs_added_in_a_jump_tick": in_jump_tick})
	var unsampled := puffs.filter(func(r): return r.samples == 0).size()
	check("always-behind-player", looked > 0 and unsampled == 0 and in_front == 0 and wrong_parent == 0,
		{"live_puff_samples": looked, "puffs_never_sampled": unsampled, "index_not_below_player": in_front, "not_child_of_level": wrong_parent, "player_index": game.player.get_index()})
	check("never-moved", looked > 0 and moved == 0, {"live_puff_samples": looked, "samples_moved": moved})
	finish()

func finish() -> void:
	print("JUMP PUFF STATE: %d checks / %d failures (physics tick %.6f s, frame %.6f s)" % [results.size(), failures, tick_s, frame_s])
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)
