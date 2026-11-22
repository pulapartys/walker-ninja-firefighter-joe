extends SceneTree
# A7 Step 5 structure and state test (CHANGE-BRIEF "The state machine", "Clip 2" authority, and the
# structure/state rows of "The evidence split").
# Structure: every state the code can request (read from player.gd and session.gd as text) maps to
# a clip in Joe's library, and every state in the brief's table is mapped.
# State: real keys through Input.parse_input_event drive the real game loop through idle, run,
# rising, landing, hose, the rescue toss, respawn, burned and celebrate. The current clip is read
# with AnimationPlayer.current_animation (the property this route uses). One authority: the sprite's
# texture never changes, and on every tick its frame equals the key the current clip holds at its
# current position, so nothing else is writing `frame`.
# Setup writes a player can't make: three position writes put him on a roof (B1 in hose range, next
# to the fire, the finish), as test_hose_steam_state.gd does.
# Run: scripts/run-test.sh test_anim_states.gd 60
# What this cannot prove: that any clip looks right. Headless Godot draws nothing.

const Main = preload("res://game/main.tscn")
const Game = preload("res://game/session.gd")
const Player = preload("res://features/player/player.gd")
const BRIEF_STATES := ["idle", "run", "rising", "falling", "landing", "hose", "grab", "toss",
	"respawn", "burned", "celebrate"]
const STAND := Vector2(1220, 240)       # B1's roof, in hose range
const DOG_ROOF := Vector2(1720, 240)    # the roof the dog's window is on
const NEAR_FINISH := Vector2(2000, 164) # on the finish roof, left of the finish area
var game: Node2D
var samples: Array = []
var failures := 0
var count := 0
var sheet: Texture2D

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

# The value the clip `clip` holds at `pos` on its frame track (the last key at or before pos).
func held_cell(clip: Animation, pos: float) -> int:
	var cell := -1
	for k in clip.track_get_key_count(0):
		if clip.track_get_key_time(0, k) <= pos + 1e-4:
			cell = clip.track_get_key_value(0, k)
	return cell

func sample() -> void:
	if not is_instance_valid(game) or game.player == null or game.player.anim == null:
		return
	var a: AnimationPlayer = game.player.anim
	var clip: Animation = a.get_animation(a.assigned_animation) if a.assigned_animation != "" else null
	samples.append({"pose": game.player.pose, "current": a.current_animation, "assigned": a.assigned_animation,
		"frame": game.player.sprite.frame, "held": held_cell(clip, a.current_animation_position) if clip else -2,
		"same_texture": game.player.sprite.texture == sheet, "state": game.state})

func current() -> String:
	return game.player.anim.current_animation

func run() -> void:
	# --- Structure: every requested state has a clip ---
	var library: AnimationLibrary = load("res://animations/joe.tres")
	var mapped: Dictionary = Player.STATE_CLIPS
	var missing := []
	for s in BRIEF_STATES:
		if not mapped.has(s) or not library.has_animation(mapped[s]):
			missing.append(s)
	check("brief-states-have-clips", missing.is_empty(), {"missing": missing, "map": mapped})
	var requested := {}
	var re := RegEx.create_from_string("show_pose\\(\"(\\w+)\"\\)|\\[\"(\\w+)\", (?:GRAB_TICKS|TOSS_UP_TICKS|\\d+)\\]")
	for path in ["res://features/player/player.gd", "res://game/session.gd"]:
		for m in re.search_all(FileAccess.get_file_as_string(path)):
			requested[m.get_string(1) if m.get_string(1) != "" else m.get_string(2)] = path
	for line in FileAccess.get_file_as_string("res://features/player/player.gd").split("\n"):
		for word in ["\"rising\"", "\"falling\"", "\"landing\"", "\"run\"", "\"hose\"", "\"idle\""]:
			if "show_pose(" in line and word in line:
				requested[word.trim_prefix("\"").trim_suffix("\"")] = "player.gd _update_pose"
	var unmapped := []
	for s in requested:
		if not mapped.has(s) or not library.has_animation(mapped[s]):
			unmapped.append(s)
	check("requested-states-have-clips", unmapped.is_empty() and requested.size() >= BRIEF_STATES.size(),
		{"requested": requested.keys(), "unmapped": unmapped})

	# --- State: real play ---
	var sampler := TickSampler.new()
	sampler.process_physics_priority = 100
	sampler.take = sample
	root.add_child(sampler)
	game = Main.instantiate()
	game.test_mode = true
	root.add_child(game)
	sheet = game.player.sprite.texture   # the player's _ready ran in add_child; the sampler compares against this
	await steps(30)
	# The person's rig: in the level, waving on its own clock, before anyone presses a key.
	var rig: Node2D = null
	for sv in game.survivors:
		if sv.type == "person":
			rig = sv.rig
	var rig_anim: AnimationPlayer = rig.get_node("AnimationPlayer") if rig else null
	var shoulder: Node2D = rig.get_node("Shoulder") if rig else null
	var r0 := shoulder.rotation if shoulder else 0.0
	await steps(6)
	check("wave-plays-in-level", rig != null and rig.visible and rig_anim.current_animation == "wave"
		and absf(shoulder.rotation - r0) > 0.01 and rig.position == Vector2(1335, 240),
		{"rig": str(rig), "current": rig_anim.current_animation if rig_anim else "", "rotation_change": (shoulder.rotation - r0) if shoulder else 0.0,
		"position": str(rig.position) if rig else ""})
	await tap(KEY_ENTER)
	check("respawn-on-start", current() == "respawn", {"current": current(), "pose": game.player.pose})
	await steps(40)
	check("idle", current() == "idle", {"current": current()})
	key(KEY_D, true)
	await steps(20)
	check("run", current() == "run", {"current": current()})
	key(KEY_D, false)
	await wait_for(func(): return current() == "idle", 60)
	await tap(KEY_SPACE)
	var rose := await wait_for(func(): return current() == "rising", 10)
	var landed := await wait_for(func(): return current() == "landing", 120)
	check("rising-then-landing", rose and landed, {"rose": rose, "landed": landed, "current": current()})
	await wait_for(func(): return current() == "idle", 60)
	game.player.position = STAND
	await steps(3)
	await tap(KEY_W)
	check("hose", current() == "hose" and game.player.hosing, {"current": current(), "hosing": game.player.hosing})
	await wait_for(func(): return not game.player.hosing, 400)
	key(KEY_D, true)
	var tossed := await wait_for(func(): return current() == "toss", 200)
	key(KEY_D, false)
	check("toss-on-rescue", tossed and game.player.pose == "grab", {"current": current(), "pose": game.player.pose})
	check("rig-hidden-on-rescue", rig != null and not rig.visible, {"visible": rig.visible if rig else null})
	await steps(60)
	# Walk back off the survivor's area first: R while still on it re-rescues (CHANGE-BRIEF Revision 2).
	key(KEY_A, true)
	await steps(30)
	key(KEY_A, false)
	await steps(20)
	await tap(KEY_R)
	check("respawn-on-R", current() == "respawn", {"current": current(), "rescued": game.rescued_count})
	check("rig-visible-after-restart", rig != null and rig.visible, {"visible": rig.visible if rig else null})
	await steps(40)
	# Death by fire: R restored the fire; walk into it from B1's roof.
	game.player.position = STAND
	await steps(3)
	key(KEY_D, true)
	var burned := await wait_for(func(): return game.state == Game.State.DYING, 200)
	key(KEY_D, false)
	check("burned", burned and current() == "burned", {"state": game.state, "current": current()})
	await wait_for(func(): return game.state == Game.State.PLAYING, 200)
	await steps(40)
	# Level complete: hose, rescue both, reach the finish.
	game.player.position = STAND
	await steps(3)
	await tap(KEY_W)
	await wait_for(func(): return not game.player.hosing, 400)
	key(KEY_D, true)
	await wait_for(func(): return game.rescued_count >= 1, 200)
	key(KEY_D, false)
	await steps(60)
	game.player.position = DOG_ROOF
	await steps(3)
	key(KEY_D, true)
	await wait_for(func(): return game.rescued_count >= 2, 200)
	key(KEY_D, false)
	await steps(60)
	game.player.position = NEAR_FINISH
	await steps(3)
	key(KEY_D, true)
	var done := await wait_for(func(): return game.state == Game.State.COMPLETE, 200)
	key(KEY_D, false)
	await steps(5)
	check("celebrate", done and current() == "celebrate", {"state": game.state, "current": current(), "rescued": game.rescued_count})

	# --- One authority over Joe's sprite ---
	var wrong_texture := 0
	var wrong_frame := []
	for i in samples.size():
		var s: Dictionary = samples[i]
		if not s.same_texture:
			wrong_texture += 1
		if s.frame != s.held:
			wrong_frame.append({"i": i, "frame": s.frame, "held": s.held, "assigned": s.assigned, "pose": s.pose})
	check("texture-never-changes", wrong_texture == 0 and sheet != null, {"ticks": samples.size(), "changed": wrong_texture})
	check("frame-is-the-clips-key", wrong_frame.is_empty(), {"ticks": samples.size(), "mismatches": wrong_frame.slice(0, 5)})
	print("ANIM STATES RESULT: %d checks / %d failures" % [count, failures])
	quit(1 if failures else 0)
