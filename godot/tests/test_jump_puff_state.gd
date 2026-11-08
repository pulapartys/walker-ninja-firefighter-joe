extends SceneTree
# A6 Effect A, jump puff (CHANGE-BRIEF A4, Revision 1 A-R8): the driver's rules, headless.
# Every jump is a real Space key through Godot Input in the real game loop (res://game/main.tscn);
# the test never calls the driver. It only watches: SceneTree.node_added for a JumpPuff added
# anywhere in the tree, each emitter's `finished`, each puff's tree_exited, and its own connection to
# player.jumped, which records the tick and his feet at every emit.
# Setup the test does itself, as test_game.gd / test_keyboard.gd do: it moves the player onto the
# block at (600, 288) for the walk-off and into the street spike fire for DYING, enters COMPLETE
# through session.resolve_contacts(false, true), and sets the tree pause (the game never does).
# Run: scripts/run-test.sh test_jump_puff_state.gd 60
# What this cannot see: pixels or particle positions. Headless Godot draws nothing (CLAUDE.md,
# Headless facts); the look, the draw order on screen and the frozen frame are eye checks.
const Main = preload("res://game/main.tscn")
const Game = preload("res://game/session.gd")
const PUFF_PATH := "res://effects/jump_puff.tscn"
const KIDS := ["Flash:CPUParticles2D", "Puff:CPUParticles2D", "Specks:CPUParticles2D"]
const LIFE := 0.9      # A-R5: freed within 0.9 s (+ one frame) of its jump; the Puff layer's lifetime
const EPS := 1e-6
const SPAWN := Vector2(64, 320)
var game: Node2D
var results: Array[Dictionary] = []
var failures := 0
var tick_s := 0.0      # one physics tick in seconds
var frame_s := 0.0     # one drawn frame in seconds: the "one frame" of A-R5
var emits: Array = []  # per player.jumped, in order: {tick, pos, state, live_after}
var puffs: Array = []  # per JumpPuff added, in order: {node, id, tick, pos, parent, kids, emitting, finished, freed_tick, freed_state, samples, moved, max_dist}
var seen_emits := 0
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
	var n := emits.size()
	key(KEY_SPACE, true)
	await wait_for(func(): return emits.size() > n, 10)
	key(KEY_SPACE, false)
	await steps(1)
	return emits.size() == n + 1

# Space as he falls the last 12 px to where he jumped from: inside the 6-tick jump buffer, so the
# next jump starts on the landing tick (CHANGE-BRIEF "Jump timing"), 0.8 s after the last.
func jump_on_landing() -> bool:
	var from_y: float = emits.back().pos.y
	await wait_for(func(): return game.player.velocity.y > 0.0 and game.player.position.y >= from_y - 12.0, 90)
	return await jump()

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
	emits.append({"tick": tick(), "pos": game.player.global_position, "state": game.state, "live_after": -1})

func live() -> Array:
	return puffs.filter(func(r): return r.freed_tick < 0)

func sample() -> void:
	if not is_instance_valid(game):
		return
	var alive := live()
	max_live = maxi(max_live, alive.size())
	if seen_emits < emits.size():
		emits.back().live_after = alive.size()   # puffs alive at the end of the jump's physics tick
		seen_emits = emits.size()
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

# Seconds of unpaused game time from its jump to its free (tree pauses the test made are taken out).
func life(rec: Dictionary) -> float:
	var ticks: int = rec.freed_tick - rec.tick
	for p in tree_pauses:
		ticks -= maxi(0, mini(rec.freed_tick, p[1]) - maxi(rec.tick, p[0]))
	return ticks * tick_s

# A-R5: within LIFE plus one frame; and not before LIFE minus one frame (not cut off).
func on_time(rec: Dictionary) -> bool:
	var l := life(rec)
	return rec.freed_tick >= 0 and l <= LIFE + frame_s + EPS and l >= LIFE - frame_s - EPS

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

func timings(rec: Dictionary) -> Dictionary:
	var out := {}
	for k in rec.finished:
		out[k] = snappedf((rec.finished[k] - rec.tick) * tick_s, 0.0001)
	return {"finished_after_s": out, "freed_after_s": snappedf(life(rec), 0.0001), "freed_with_last_finished": all_finished(rec)}

func counts() -> Dictionary:
	return {"state": game.state, "jumped": emits.size(), "puffs_added": puffs.size(), "puffs_in_tree": puffs_in_tree()}

func run() -> void:
	node_added.connect(_on_node_added)
	tick_s = 1.0 / Engine.physics_ticks_per_second
	game = Main.instantiate()
	game.test_mode = true
	root.add_child(game)
	game.player.jumped.connect(_on_jumped)
	await steps(30)
	frame_s = root.get_process_delta_time()

	# --- A-R2: nothing on scene load, in MENU, or on start ---
	check("none-on-load", game.state == Game.State.MENU and puffs.is_empty() and emits.is_empty() and puffs_in_tree() == 0, counts())
	await tap(KEY_SPACE)
	await steps(10)
	check("none-in-menu", game.state == Game.State.MENU and puffs.is_empty() and emits.is_empty(), counts())
	await tap(KEY_ENTER)
	await steps(10)
	check("none-on-start", game.state == Game.State.PLAYING and game.player.is_on_floor() and puffs.is_empty() and emits.is_empty(), counts())

	# --- A-R1, A-R4, A-R5, A-R6 and landing: one real jump with D held, so he moves away from it ---
	key(KEY_D, true)
	var jumped: bool = await jump()
	await steps(12)
	key(KEY_D, false)
	var landed: bool = await wait_for(func(): return game.player.is_on_floor(), 90)
	await steps(3)
	check("none-on-landing", jumped and landed and emits.size() == 1 and puffs.size() == 1, counts())
	await wait_for(func(): return live().is_empty(), 90)
	if emits.size() != 1 or puffs.size() != 1:
		check("one-puff-at-feet", false, counts())
		return finish()
	var e: Dictionary = emits[0]
	var p: Dictionary = puffs[0]
	check("one-puff-at-feet", p.tick == e.tick and p.pos == e.pos and e.state == Game.State.PLAYING,
		{"jump_tick": e.tick, "puff_tick": p.tick, "player_at_jump": str(e.pos), "puff_at": str(p.pos), "state_at_jump": e.state})
	check("parent-is-level", p.parent == game and p.parent != game.player and full(p),
		{"parent": str(p.parent.name) if is_instance_valid(p.parent) else "", "children": p.kids, "emitting_when_added": p.emitting})
	check("stays-put", p.samples > 0 and p.moved == 0 and p.max_dist >= 30.0,
		{"frames_sampled": p.samples, "frames_moved": p.moved, "player_max_distance_px": snappedf(p.max_dist, 0.01), "puff_at": str(p.pos)})
	var t := timings(p)
	t.merge({"expected_s": LIFE, "tolerance_s": frame_s, "puffs_in_tree": puffs_in_tree()})
	check("frees-when-finished", all_finished(p) and on_time(p) and puffs_in_tree() == 0, t)

	# --- A-R3 overlap: four jumps, each Space just before he lands, so each jump starts 0.8 s after
	# the last on flat ground, inside one 0.9 s puff life ---
	await steps(10)
	max_live = 0
	var i1 := emits.size()
	var chain_ok: bool = await jump()
	for k in range(3):
		if not await jump_on_landing():
			chain_ok = false
	await wait_for(func(): return live().is_empty(), 90)
	if not chain_ok or emits.size() < i1 + 4 or puffs.size() < i1 + 4:
		check("retrigger-overlap", false, counts())
		return finish()
	var gaps: Array = []
	for k in range(i1 + 1, i1 + 4):
		gaps.append(snappedf((emits[k].tick - emits[k - 1].tick) * tick_s, 0.0001))
	var e1: Dictionary = emits[i1]
	var e2: Dictionary = emits[i1 + 1]
	var p1: Dictionary = puffs[i1]
	var p2: Dictionary = puffs[i1 + 1]
	var gap: float = (e2.tick - e1.tick) * tick_s
	check("retrigger-overlap", gap < LIFE and e2.live_after == 2 and p1.freed_tick > e2.tick and p1.finished.get("Puff", -1) > e2.tick and p2.id != p1.id and p2.tick == e2.tick and p2.pos == e2.pos and full(p2),
		{"jump_gap_s": gap, "live_at_jump_2": e2.live_after, "first_freed_after_jump_2_s": (p1.freed_tick - e2.tick) * tick_s, "first_puff_layer_running_at_jump_2": p1.finished.get("Puff", -1) > e2.tick, "second_is_new_instance": p2.id != p1.id, "second_full": full(p2), "second_at": str(p2.pos), "player_at_jump_2": str(e2.pos)})
	var t1 := timings(p1)
	var t2 := timings(p2)
	check("first-not-restarted", all_finished(p1) and on_time(p1) and all_finished(p2) and on_time(p2),
		{"first": t1, "second": t2, "first_if_restarted_at_jump_2_s": gap + LIFE, "expected_s": LIFE, "tolerance_s": frame_s})
	check("max-two-alive", max_live == 2, {"jumps": 4, "jump_gaps_s": gaps, "max_live": max_live})

	# --- A-R2: walking off a ledge is a fall, not a jump ---
	var n := puffs.size()
	var m := emits.size()
	game.player.position = Vector2(600, 288)   # on the block at x 576-624, top y 288 (first_steps.json)
	await steps(5)
	var on_block: bool = game.player.is_on_floor()
	key(KEY_D, true)
	var left_floor: bool = await wait_for(func(): return not game.player.is_on_floor(), 60)
	var air_from := tick()
	var landed_below: bool = await wait_for(func(): return game.player.is_on_floor(), 60)
	var air_ticks := tick() - air_from
	key(KEY_D, false)
	await steps(10)
	var c := counts()
	c.merge({"on_block": on_block, "left_floor": left_floor, "air_ticks": air_ticks, "landed_at": str(game.player.position)})
	check("none-on-walk-off", on_block and left_floor and landed_below and air_ticks >= 5 and game.player.position.y > 300.0 and puffs.size() == n and emits.size() == m, c)

	# --- A-R2 (PAUSED) and A-R7 (Esc): Esc right after a jump; Space while paused adds nothing; the
	# puff in flight finishes on time while the game stays paused (Esc doesn't pause the tree) ---
	await jump()
	var pp: Dictionary = puffs.back()
	await tap(KEY_ESCAPE)
	var esc_paused: bool = game.state == Game.State.PAUSED
	n = puffs.size()
	m = emits.size()
	await tap(KEY_SPACE)
	await steps(5)
	check("none-while-paused", esc_paused and game.state == Game.State.PAUSED and puffs.size() == n and emits.size() == m, counts())
	await wait_for(func(): return pp.freed_tick >= 0, 90)
	t = timings(pp)
	t.merge({"state_when_freed": pp.freed_state, "expected_s": LIFE, "tolerance_s": frame_s})
	check("game-pause-puff-finishes", pp.freed_state == Game.State.PAUSED and all_finished(pp) and on_time(pp), t)
	await tap(KEY_ENTER)
	await wait_for(func(): return game.player.is_on_floor(), 90)
	await steps(5)

	# --- A-R7 (tree): 0.3 s after a jump the tree is paused for 1.5 s: the puff is not freed, not
	# moved and still visible, and no emitter finishes; afterwards it finishes 0.9 s of unpaused
	# game time after its jump ---
	await jump()
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
	check("tree-pause-freezes", held,
		{"paused_s": (tick() - from) * tick_s, "paused_at_s_after_jump": (from - tp.tick) * tick_s, "freed": tp.freed_tick >= 0, "visible": tp.node.is_visible_in_tree() if is_instance_valid(tp.node) else false, "emitters_finished_before_pause": finished_before, "emitters_finished_while_paused": finished_during, "player_moved": game.player.position != player_at})
	await wait_for(func(): return tp.freed_tick >= 0, 90)
	t = timings(tp)
	t.merge({"wall_s_including_pause": (tp.freed_tick - tp.tick) * tick_s, "expected_s": LIFE, "tolerance_s": frame_s})
	check("tree-pause-resumes", all_finished(tp) and on_time(tp), t)
	await wait_for(func(): return game.player.is_on_floor(), 90)
	await steps(5)

	# --- A-R2 (R) and A-R6: R 0.2 s after a jump away from the spawn point; no new puff, and the puff
	# in flight stays in the level where it was made and finishes on time ---
	await jump()
	var rp: Dictionary = puffs.back()
	await wait_for(func(): return tick() - rp.tick >= 12, 30)
	n = puffs.size()
	m = emits.size()
	await tap(KEY_R)
	var at_spawn: bool = game.player.position.distance_to(SPAWN) < 1.0
	c = counts()
	c.merge({"player_at": str(game.player.position)})
	check("none-on-restart", game.state == Game.State.PLAYING and at_spawn and puffs.size() == n and emits.size() == m, c)
	var after_r: bool = rp.freed_tick < 0 and rp.node.get_parent() == game and rp.node.global_position == rp.pos
	var apart: float = rp.pos.distance_to(game.player.global_position)
	await wait_for(func(): return rp.freed_tick >= 0, 90)
	t = timings(rp)
	t.merge({"alive_in_level_after_R": after_r, "puff_at": str(rp.pos), "player_after_R": str(game.player.position), "apart_px": snappedf(apart, 0.01), "expected_s": LIFE, "tolerance_s": frame_s})
	check("restart-mid-puff", after_r and apart > 100.0 and rp.moved == 0 and all_finished(rp) and on_time(rp), t)

	# --- A-R2 (DYING): into the street spike fire, Space during the 2.0 s hold, then the restart ---
	n = puffs.size()
	m = emits.size()
	game.player.position = Vector2(330, 310)   # in the spike fire at x 320-344 (as test_keyboard.gd)
	var died: bool = await wait_for(func(): return game.state == Game.State.DYING, 10)
	await tap(KEY_SPACE)
	var still_dying: bool = game.state == Game.State.DYING
	var back: bool = await wait_for(func(): return game.state == Game.State.PLAYING, 150)
	await steps(10)
	c = counts()
	c.merge({"died": died, "space_while_dying": still_dying, "restarted": back})
	check("none-while-dying", died and still_dying and back and puffs.size() == n and emits.size() == m, c)

	# --- A-R2 (COMPLETE): entered through the session's own resolve_contacts, as test_keyboard.gd
	# does; finishing the real route would need both rescues ---
	n = puffs.size()
	m = emits.size()
	game.resolve_contacts(false, true)
	await tap(KEY_SPACE)
	await steps(10)
	check("none-when-complete", game.state == Game.State.COMPLETE and puffs.size() == n and emits.size() == m, counts())

	# --- A-R1, A-R4, A-R5, A-R8 over the whole run ---
	var mismatched: Array = []
	var lives: Array = []
	for i in range(mini(emits.size(), puffs.size())):
		var ei: Dictionary = emits[i]
		var ri: Dictionary = puffs[i]
		lives.append(snappedf(life(ri), 0.0001))
		if ri.tick != ei.tick or ri.pos != ei.pos or ei.state != Game.State.PLAYING or not full(ri) or not all_finished(ri) or not on_time(ri):
			mismatched.append(i)
	check("every-jump-one-puff", emits.size() == puffs.size() and emits.size() > 0 and mismatched.is_empty() and puffs_in_tree() == 0,
		{"jumped": emits.size(), "puffs_added": puffs.size(), "mismatched": mismatched, "lives_s": lives, "expected_s": LIFE, "tolerance_s": frame_s, "puffs_in_tree_at_end": puffs_in_tree()})
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
