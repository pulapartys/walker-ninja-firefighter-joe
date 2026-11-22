extends SceneTree
# A7 Step 6 edge test for the toss (CHANGE-BRIEF "The phase table" as revised in Revision 2, "The two
# clocks", and the interrupt rule in "The evidence split" with Revision 2's re-rescue).
# Each scenario is a fresh game: Enter, one position write onto the dog's roof (no fire there), then
# a real D key walks him into the dog, so the rescue and the toss start in the real game loop. Frame
# 0 is the touch tick T. A sampler that runs after the session in every physics tick logs the clip,
# its position, Sprite.frame and whether the flight has launched.
# Baseline: the cells follow the phase table tick by tick (8 on 0-13, 9 on 14-29, 1 on 30-45, then
# locomotion on 46), and the throw cell first shows on the launch tick (0 ticks of disagreement).
# Interrupts at every phase boundary B in {14, 30, 46}, one tick before, on, and one tick after:
#   R      `respawn` plays on the tick R is handled (restart cuts the toss); he is still on the dog's
#          area, so the pre-existing re-rescue may start a new toss on the next tick, from frame 0;
#   LEFT   held 3 ticks: the toss keeps the table's cells (moving does not cancel it);
#   SPACE  a jump: the toss keeps the table's cells;
#   ESC    pause 10 ticks, then ESC again: the clip freezes on its cell and resumes from it, so the
#          cells over PLAYING ticks are the baseline's.
# Run: scripts/run-test.sh test_toss_edges.gd 60
# What this cannot prove: that the phases read on screen. Headless Godot draws nothing.

const Main = preload("res://game/main.tscn")
const Game = preload("res://game/session.gd")
const DOG_ROOF := Vector2(1720, 240)
const GRAB := 8
const TOSS := 9
const READY := 1
const BOUNDARIES := [14, 30, 46]
var game: Node2D
var samples: Array = []
var failures := 0
var count := 0

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

func sample() -> void:
	if not is_instance_valid(game) or game.player == null or game.player.anim == null:
		return
	var a: AnimationPlayer = game.player.anim
	samples.append({"clip": a.assigned_animation, "pos": a.current_animation_position, "frame": game.player.sprite.frame,
		"state": game.state, "rescued": game.rescued_count, "pose": game.player.pose,
		"launched": game.flights.size() > 0 and game.flights[0].has("launch")})

# The cell the phase table puts on frame f of the toss (0 = the touch tick).
func table_cell(f: int) -> int:
	if f < 14:
		return GRAB
	if f < 30:
		return TOSS
	return READY

# Starts a fresh game, walks him into the dog and returns the sample index of the touch tick.
# Returns -1 when the rescue does not happen within 300 ticks.
func to_touch() -> int:
	if is_instance_valid(game):
		game.queue_free()
		await steps(2)
	samples.clear()
	game = Main.instantiate()
	game.test_mode = true
	root.add_child(game)
	await steps(20)
	key(KEY_ENTER, true)
	await steps(2)
	key(KEY_ENTER, false)
	await steps(40)
	game.player.position = DOG_ROOF
	await steps(3)
	key(KEY_D, true)
	var guard := 0
	while game.rescued_count == 0 and guard < 300:
		await steps(1)
		guard += 1
	key(KEY_D, false)
	if game.rescued_count == 0:
		return -1
	return samples.size() - 1

# Cells over PLAYING samples from the touch through frame 45 (pause ticks left out).
func playing_cells(touch: int) -> Array:
	var out := []
	for i in range(touch, samples.size()):
		if samples[i].state == Game.State.PLAYING:
			out.append(samples[i].frame)
		if out.size() == 46:
			break
	return out

func run() -> void:
	var sampler := TickSampler.new()
	sampler.process_physics_priority = 100
	sampler.take = sample
	root.add_child(sampler)
	var expected := []
	for f in 46:
		expected.append(table_cell(f))

	# --- Baseline: the table tick by tick, and the launch on the throw's first tick ---
	var touch := await to_touch()
	await steps(60)
	if touch < 0:
		check("baseline-rescue", false, {})
		return finish()
	var cells := []
	for f in range(-1, 48):
		cells.append(samples[touch + f].frame)
	var log_rows := []
	for f in range(-1, 48):
		var s: Dictionary = samples[touch + f]
		log_rows.append("%d:%s@%.4f=%d%s" % [f, s.clip, s.pos, s.frame, "L" if s.launched else ""])
	print("BASELINE TICK LOG (frame:clip@position=cell, L = flight launched): ", " ".join(log_rows))
	var launch := -1
	var first_throw := -1
	for f in range(0, 48):
		if launch < 0 and samples[touch + f].launched:
			launch = f
		if first_throw < 0 and samples[touch + f].frame == TOSS:
			first_throw = f
	check("baseline-table", cells.slice(1, 47) == expected, {"cells_0_to_45": cells.slice(1, 47)})
	check("baseline-before-touch-not-toss", samples[touch - 1].clip != "toss", {"clip_before": samples[touch - 1].clip})
	check("baseline-handback-on-46", samples[touch + 46].clip != "toss" and samples[touch + 45].clip == "toss",
		{"clip_45": samples[touch + 45].clip, "clip_46": samples[touch + 46].clip})
	check("throw-on-launch-tick", launch == 14 and first_throw == 14, {"launch_frame": launch, "first_throw_frame": first_throw,
		"disagreement_ticks": first_throw - launch})

	# --- Interrupts one tick before, on and after each boundary ---
	for b in BOUNDARIES:
		for k in [b - 1, b, b + 1]:
			for what in ["R", "LEFT", "SPACE", "ESC"]:
				touch = await to_touch()
				if touch < 0:
					check("rescue:%s@%d" % [what, k], false, {})
					continue
				await steps(k - 1)             # the next physics tick is frame k
				match what:
					"R":
						key(KEY_R, true)
						await steps(1)
						key(KEY_R, false)
						await steps(1)
						var s: Dictionary = samples[touch + k]
						var nxt: Dictionary = samples[touch + k + 1]
						var before_ok := true
						for f in range(0, mini(k, 46)):
							before_ok = before_ok and samples[touch + f].frame == table_cell(f)
						# A re-rescue on the next tick must start a fresh toss at frame 0, never continue the old one.
						var next_ok: bool = nxt.clip == "respawn" or (nxt.clip == "toss" and nxt.pos == 0.0 and nxt.frame == GRAB)
						check("R@%d" % k, s.clip == "respawn" and before_ok and next_ok,
							{"clip_on_k": s.clip, "before_follow_table": before_ok, "next": [nxt.clip, nxt.pos, nxt.frame]})
						await steps(5)
					"LEFT":
						key(KEY_LEFT, true)
						await steps(3)
						key(KEY_LEFT, false)
						await steps(50)
						check("LEFT@%d" % k, playing_cells(touch) == expected, {"cells": playing_cells(touch)})
					"SPACE":
						key(KEY_SPACE, true)
						await steps(2)
						key(KEY_SPACE, false)
						await steps(50)
						check("SPACE@%d" % k, playing_cells(touch) == expected, {"cells": playing_cells(touch)})
					"ESC":
						key(KEY_ESCAPE, true)
						await steps(1)
						key(KEY_ESCAPE, false)
						await steps(10)
						var frozen := samples.slice(samples.size() - 8)
						var still := true
						for s in frozen:
							still = still and s.state == Game.State.PAUSED and s.frame == frozen[0].frame and is_equal_approx(s.pos, frozen[0].pos)
						key(KEY_ESCAPE, true)
						await steps(1)
						key(KEY_ESCAPE, false)
						await steps(60)
						check("ESC@%d" % k, still and playing_cells(touch) == expected,
							{"frozen_while_paused": still, "cells": playing_cells(touch)})
	finish()

func finish() -> void:
	print("TOSS EDGES RESULT: %d checks / %d failures" % [count, failures])
	quit(1 if failures else 0)
