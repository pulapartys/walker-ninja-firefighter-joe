extends SceneTree
# A7 Step 2 pins (CHANGE-BRIEF "The evidence split": today's states, order and timings unchanged).
# Committed before any clip is wired, and re-run after: the values below were measured on the game
# before the change (a7/TEST-REPORT.md, Pins), so a different value afterwards is a finding.
# One scripted run through the real game loop and real keys (Input.parse_input_event): Enter to
# start, run right, stop, jump and land, hose the blocking fire, walk into the person survivor (the
# rescue toss), then R. One position write puts him on B1's roof in hose range, as
# test_hose_steam_state.gd does; a player walks there. A sampler that runs after the session in
# every physics tick records the state.
# Pinned: (1) the state sequence of the run, in order, with each state's length in ticks; (2) the
# timed states: respawn, landing, grab shown from the touch tick, toss, the hand-back tick; (3) the
# gameplay fact the toss is read against: the flight launches 15 ticks after the touch.
# Run: scripts/run-test.sh test_pins_a7.gd 60

const Main = preload("res://game/main.tscn")
const Game = preload("res://game/session.gd")
const STAND := Vector2(1220, 240)   # on B1's roof, in hose range (test_hose_steam_state.gd)
# Measured before the change (a7/TEST-REPORT.md, Pins). [state, ticks] runs of the scripted run.
# The last three runs are a pre-existing re-rescue: R at the person's window restores the survivor while
# the area still reports the old overlap, so the next tick rescues them again (CHANGE-BRIEF Revision 2).
const SEQUENCE := [["respawn", 30], ["idle", 13], ["run", 45], ["idle", 55], ["rising", 48], ["landing", 19],
	["idle", 30], ["hose", 299], ["idle", 13], ["run", 52], ["grab", 16], ["toss", 30], ["idle", 35],
	["respawn", 1], ["grab", 16], ["toss", 26]]
const RESPAWN_TICKS := 30           # the respawn run after Enter
const LANDING_TICKS := 19           # the landing run: LAND_TICKS is 20, decremented on the landing tick itself
const GRAB_SHOWN := 16              # ticks the grab shows, counting the touch tick
const TOSS_SHOWN := 30
const HANDBACK := 46                # ticks from the touch to the first locomotion state
const LAUNCH_AFTER := 14            # ticks from the touch to the flight's launch (fl.t starts counting on the touch tick)
var game: Node2D
var samples: Array = []             # one per physics tick: {t, pose, state, rescued, launched}
var failures := 0
var count := 0

# Calls take() once per physics tick, after the player (priority 0) and the session (priority 10).
class TickSampler extends Node:
	var take: Callable
	func _physics_process(_delta: float) -> void:
		take.call()

func _initialize() -> void:
	call_deferred("run")

func check(id: String, condition: bool, observed: Dictionary) -> void:
	count += 1
	if not condition:
		failures += 1
	print(JSON.stringify({"id": id, "status": "PASS" if condition else "FAIL", "observed": observed}))

func steps(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

# Synthetic key event through Godot Input, as test_keyboard.gd and the A6 state tests.
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

func sample() -> void:
	if not is_instance_valid(game) or game.player == null:
		return
	samples.append({"t": Engine.get_physics_frames(), "pose": game.player.pose, "state": game.state,
		"rescued": game.rescued_count, "launched": game.flights.size() > 0 and game.flights[0].has("launch")})

# Collapses the per-tick poses (in PLAYING only) into [pose, ticks] runs.
func runs() -> Array:
	var out: Array = []
	for s in samples:
		if s.state != Game.State.PLAYING:
			continue
		if out.is_empty() or out.back()[0] != s.pose:
			out.append([s.pose, 1])
		else:
			out.back()[1] += 1
	return out

func run() -> void:
	var sampler := TickSampler.new()
	sampler.process_physics_priority = 100
	sampler.take = sample
	root.add_child(sampler)
	game = Main.instantiate()
	game.test_mode = true
	root.add_child(game)
	await steps(30)
	await tap(KEY_ENTER)              # start: respawn stance
	await steps(40)
	key(KEY_D, true)                  # run right
	await steps(60)
	key(KEY_D, false)
	await steps(40)
	await tap(KEY_SPACE)              # jump and land
	await steps(90)
	game.player.position = STAND      # the one position write: on B1's roof in hose range
	await steps(3)
	await tap(KEY_W)                  # hose until the fire is out and the water stops
	await steps(310)
	key(KEY_D, true)                  # walk into the person survivor
	var guard := 0
	while game.rescued_count == 0 and guard < 300:
		await steps(1)
		guard += 1
	key(KEY_D, false)
	await steps(80)
	await tap(KEY_R)                  # restart
	await steps(40)

	var seq := runs()
	print("MEASURED SEQUENCE: ", JSON.stringify(seq))
	var touch := -1
	for i in samples.size():
		if samples[i].rescued > 0:
			touch = i
			break
	var grab := 0
	var toss := 0
	var handback := -1
	var launch := -1
	if touch >= 0:
		for i in range(touch, samples.size()):
			var p: String = samples[i].pose
			if p == "grab" and toss == 0:
				grab += 1
			elif p == "toss":
				toss += 1
			elif handback < 0:
				handback = i - touch
				break
		for i in range(touch, samples.size()):
			if samples[i].launched:
				launch = i - touch
				break
	var respawn := -1
	var landing := -1
	for r in seq:
		if r[0] == "respawn" and respawn < 0:
			respawn = r[1]
		if r[0] == "landing" and landing < 0:
			landing = r[1]
	var facts := {"respawn": respawn, "landing": landing, "grab_shown": grab, "toss_shown": toss,
		"handback": handback, "launch_after": launch, "touch_pose": samples[touch].pose if touch >= 0 else ""}
	print("MEASURED FACTS: ", JSON.stringify(facts))

	check("rescued", touch >= 0 and samples[touch].pose == "grab", {"touch_index": touch, "facts": facts})
	check("sequence", seq == SEQUENCE, {"observed": seq, "pinned": SEQUENCE})
	check("respawn-ticks", respawn == RESPAWN_TICKS, {"observed": respawn, "pinned": RESPAWN_TICKS})
	check("landing-ticks", landing == LANDING_TICKS, {"observed": landing, "pinned": LANDING_TICKS})
	check("grab-shown", grab == GRAB_SHOWN, {"observed": grab, "pinned": GRAB_SHOWN})
	check("toss-shown", toss == TOSS_SHOWN, {"observed": toss, "pinned": TOSS_SHOWN})
	check("handback", handback == HANDBACK, {"observed": handback, "pinned": HANDBACK})
	check("launch-after-touch", launch == LAUNCH_AFTER, {"observed": launch, "pinned": LAUNCH_AFTER})
	print("PINS RESULT: %d checks / %d failures" % [count, failures])
	quit(1 if failures else 0)
