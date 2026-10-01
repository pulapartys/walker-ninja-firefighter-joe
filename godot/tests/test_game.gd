extends SceneTree
const Game = preload("res://game/session.gd")
const Route = preload("res://tests/route_driver.gd")
var game: Node2D
var results: Array[Dictionary] = []
var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func steps(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func check(id: String, passed: bool, observation: Dictionary) -> void:
	results.append({"id": id, "status": "PASS" if passed else "FAIL", "observed": observation})
	if not passed:
		failures += 1
	print(JSON.stringify(results.back()))

func fresh() -> void:
	if is_instance_valid(game):
		game.queue_free()
		await process_frame
	game = Game.new()
	game.test_mode = true
	root.add_child(game)
	game.start_session()
	game.player.test_control = true
	await steps(3)

func run() -> void:
	await fresh()
	check("launch-grounded", game.player.is_on_floor() and game.state == Game.State.PLAYING, {"position": str(game.player.position), "engine": Engine.get_version_info().string})
	game.player.test_axis = 1
	await steps(8)
	check("speed-cap", is_equal_approx(game.player.velocity.x,160), {"velocity_x": game.player.velocity.x})
	game.player.test_axis = 0
	await steps(5)
	check("neutral-stop", is_zero_approx(game.player.velocity.x), {"velocity_x": game.player.velocity.x})
	game.player.test_control = false
	Input.action_press("move_left")
	Input.action_press("move_right")
	await steps(5)
	check("simultaneous-directions", is_zero_approx(game.player.velocity.x), {"velocity_x": game.player.velocity.x})
	Input.action_release("move_left")
	Input.action_release("move_right")
	game.player.test_control = true
	game.player.test_axis = -1
	await steps(70)
	check("left-wall", game.player.position.x >= 9 and game.player.position.x <= 11, {"x": game.player.position.x})
	await fresh()
	game.player.test_jump_pressed = true
	game.player.test_jump_held = true
	var min_y: float = game.player.position.y
	for i in range(50):
		await steps(1)
		min_y = minf(min_y, game.player.position.y)
		if i == 12:
			game.player.test_jump_pressed = true
	check("fixed-jump-and-no-double", game.player.jumps == 1 and absf((320-min_y)-53.3333) < 5, {"rise_px":320-min_y, "jumps":game.player.jumps})
	await steps(30)
	check("held-jump-no-bounce", game.player.jumps == 1 and game.player.is_on_floor(), {"jumps":game.player.jumps})
	# Actual geometry fixtures at a ledge; tick ages exercise inclusive 6 / expired 7.
	for age in [5,6,7]:
		await fresh()
		game.player.position = Vector2(478, 285)
		await steps(2)
		game.player.last_floor_tick = game.player.tick + 1 - age
		game.player.opportunity_consumed = false
		game.player.test_jump_pressed = true
		await steps(1)
		check("coyote-%d" % age, (game.player.jumps == 1) == (age <= 6), {"age":age, "jumps":game.player.jumps})
	for age in [5,6,7]:
		await fresh()
		game.player.jump_request_tick = game.player.tick + 1 - age
		await steps(1)
		check("buffer-%d" % age, (game.player.jumps == 1) == (age <= 6), {"age":age, "jumps":game.player.jumps})
	await fresh()
	game._add_solid(Rect2(32,260,64,12))
	await steps(2)
	game.player.test_jump_pressed = true
	min_y = 320
	for i in range(45):
		await steps(1)
		min_y = minf(min_y,game.player.position.y)
	check("low-ceiling", min_y >= 300-0.2 and game.player.jumps == 1 and game.player.is_on_floor(), {"minimum_feet_y":min_y,"jumps":game.player.jumps})
	await fresh()
	game.player.test_jump_pressed = true
	await steps(5)
	game.set_paused(true)
	var paused_position: Vector2 = game.player.position
	var paused_time: float = game.elapsed
	await steps(10)
	check("pause-freezes", game.player.position == paused_position and game.elapsed == paused_time, {"position":str(game.player.position),"elapsed":game.elapsed})
	game.set_paused(false)
	game.test_mode = false
	game._on_focus_lost()
	check("focus-loss-pauses", game.state == Game.State.PAUSED, {"state":game.state})
	game.test_mode = true
	await fresh()
	game.player.position = Vector2(330,310)
	await steps(4)
	check("actual-spike-collision", game.state == Game.State.DYING and game.deaths == 1, {"state":game.state,"deaths":game.deaths})
	game.resolve_contacts(true,true)
	check("duplicate-death-ignored", game.deaths == 1, {"deaths":game.deaths})
	await steps(38)
	check("respawn", game.state == Game.State.PLAYING and game.player.position.distance_to(Vector2(64,320)) < 1, {"state":game.state,"position":str(game.player.position)})
	game.restart_attempt()
	check("manual-restart-not-death", game.deaths == 1, {"deaths":game.deaths})
	var largest_retry_ticks: int = 0
	for i in range(20):
		game.resolve_contacts(true,false)
		var waited := 0
		while game.state == Game.State.DYING and waited < 65:
			await steps(1)
			waited += 1
		largest_retry_ticks = maxi(largest_retry_ticks, waited)
	check("twenty-retries", game.deaths == 21 and largest_retry_ticks <= 60, {"deaths":game.deaths,"max_retry_ticks":largest_retry_ticks})
	await fresh()
	game.resolve_contacts(true,true)
	check("death-before-finish", game.state == Game.State.DYING, {"state":game.state})
	await fresh()
	game.player.position = Vector2(415,432)
	await steps(1)
	check("fall-boundary", game.state == Game.State.DYING, {"state":game.state})
	await fresh()
	var route = Route.new()
	var route_ticks := 0
	var climb_flames := [Rect2(1136,266,14,14), Rect2(1485,306,45,14), Rect2(1666,266,14,14), Rect2(1926,186,14,14)]  # B1-L1, street, B2-L1, B2-L2
	var min_clears := [999.0, 999.0, 999.0, 999.0]
	while game.state == Game.State.PLAYING and route_ticks < 3000:
		route.step(game.player)
		await steps(1)
		route_ticks += 1
		if not game.player.is_on_floor():
			var px: float = game.player.position.x
			var py: float = game.player.position.y  # feet
			for fi in range(climb_flames.size()):
				var fl: Rect2 = climb_flames[fi]
				if px + 9.0 >= fl.position.x and px - 9.0 <= fl.end.x:
					min_clears[fi] = minf(min_clears[fi], fl.position.y - py)
	check("complete-real-route", game.state == Game.State.COMPLETE and game.deaths == 0 and game.rescued_count == game.survivors.size(), {"state":game.state,"deaths":game.deaths,"ticks":route_ticks,"rescued":game.rescued_count,"pos":str(game.player.position),"marks":route.next_jump})
	check("route-beats-timer", game.state == Game.State.COMPLETE and game.elapsed < float(game.level.time_limit), {"elapsed":game.elapsed, "limit":game.level.time_limit})
	check("reached-b2-roof-both-rescued", game.state == Game.State.COMPLETE and game.rescued_count == 2 and game.player.position.x > 2000.0 and game.player.position.y < 180.0, {"rescued":game.rescued_count, "pos":str(game.player.position)})
	check("flame-clearance-positive", min_clears[0] > 0.0 and min_clears[1] > 0.0 and min_clears[2] > 0.0 and min_clears[3] > 0.0, {"B1L1":min_clears[0],"street":min_clears[1],"B2L1":min_clears[2],"B2L2":min_clears[3]})
	# Gating: reaching the B2 roof exit without both rescues must NOT complete.
	await fresh()
	game.player.position = Vector2(2073, 164)  # on the B2 roof, at the exit, 0 rescued
	await steps(4)
	check("exit-locked-without-rescues", game.state == Game.State.PLAYING and game.rescued_count == 0, {"state":game.state,"rescued":game.rescued_count})
	# The person becomes reachable ONLY after hosing: extinguish, then walk right and rescue -> removed.
	await fresh()
	game.player.position = Vector2(1220, 240)  # on B1-PW, in hose range
	await steps(3)
	game.player.test_water_pressed = true
	await steps(250)                           # extinguish the blocking fire
	game.player.position = Vector2(1335, 240)  # now walk to the (previously blocked) person
	await steps(4)
	check("survivor-removed-on-rescue", game.survivors[0].rescued and not game.survivors[0].area.monitoring and game.player.bag_types.size() >= 1, {"person_rescued":game.survivors[0].rescued, "still_monitoring":game.survivors[0].area.monitoring, "bag":game.player.bag_types.size()})
	# Stick-up platform flames must kill a player standing/walking in them.
	await fresh()
	game.player.position = Vector2(1143, 280)  # in the B1-L1 flame
	await steps(4)
	check("walk-into-flame-B1L1", game.state == Game.State.DYING, {"state":game.state})
	await fresh()
	game.player.position = Vector2(1673, 280)  # in the B2-L1 flame
	await steps(4)
	check("walk-into-flame-B2L1", game.state == Game.State.DYING, {"state":game.state})
	await fresh()
	game.player.position = Vector2(1933, 200)  # in the B2-L2 flame
	await steps(4)
	check("walk-into-flame-B2L2", game.state == Game.State.DYING, {"state":game.state})
	game.start_session()
	game.start_session()
	check("replay-idempotent", game.state == Game.State.PLAYING and game.deaths == 0 and game.player.jumps == 0, {"state":game.state,"deaths":game.deaths,"jumps":game.player.jumps})
	# Countdown timer: running out of time fails the attempt, and resets on retry.
	await fresh()
	game.elapsed = float(game.level.time_limit) + 1.0
	await steps(4)
	check("timer-expiry-fails", game.state == Game.State.DYING and game.death_reason == "Out of time!", {"state":game.state, "reason":game.death_reason})
	await steps(45)
	check("timer-resets-on-retry", game.state == Game.State.PLAYING and game.elapsed < 1.0, {"state":game.state, "elapsed":game.elapsed})
	# --- Hose / blocking-fire mechanic ---
	await fresh()
	game.player.position = Vector2(1220, 240)  # on B1-PW, in hose range (clear of the fire)
	await steps(3)
	game.player.test_water_pressed = true
	await steps(210)                            # ~3.5 s in: shrinking but NOT out yet
	var lit_at_3_5: bool = game.fire_active
	await steps(45)                             # cross the ~4 s mark
	check("hose-extinguishes-fire", lit_at_3_5 and not game.fire_active, {"lit_at_3.5s":lit_at_3_5, "fire_active":game.fire_active, "extinguish_ticks":game.extinguish_ticks})
	await fresh()
	game.player.position = Vector2(64, 320)  # far from the fire
	await steps(3)
	game.player.test_water_pressed = true
	await steps(20)
	check("hose-out-of-range-noop", game.fire_active, {"fire_active":game.fire_active})
	await fresh()
	game.player.position = Vector2(1278, 240)  # standing in the lit blocking fire
	await steps(4)
	check("blocking-fire-kills-on-touch", game.state == Game.State.DYING, {"state":game.state})
	# Progressive extinguish: at t=2 s the fire is half height but STILL lethal + blocking.
	await fresh()
	game.player.position = Vector2(1220, 240)  # in range
	await steps(3)
	game.player.test_water_pressed = true       # start hosing (fire full)
	await steps(120)                             # t=2 s -> fire down to ~half height, still lit
	var half_ticks: int = game.extinguish_ticks
	game.player.position = Vector2(1278, 240)   # step into the HALF-height fire
	await steps(2)
	check("half-size-fire-still-kills", game.state == Game.State.DYING and game.fire_active and not game.survivors[0].rescued, {"state":game.state, "fire_active":game.fire_active, "ticks_at_touch":half_ticks})
	await fresh()
	game.player.position = Vector2(1230, 240)  # on the runway, LEFT of the lit fire
	await steps(3)
	game.player.test_axis = 1.0                # walk right toward the person -- straight through the fire
	await steps(30)
	check("person-rescue-blocked-until-extinguished", game.state == Game.State.DYING and not game.survivors[0].rescued, {"state":game.state, "person_rescued":game.survivors[0].rescued})
	await fresh()
	game.player.position = Vector2(1220, 240)
	await steps(3)
	game.player.test_water_pressed = true
	await steps(250)               # extinguish the fire
	game.resolve_contacts(true, false)  # then die
	await steps(45)                # auto-retry
	check("extinguish-resets-on-retry", game.fire_active and game.extinguish_ticks == 0 and game.state == Game.State.PLAYING, {"fire_active":game.fire_active, "state":game.state})
	var report := {"scope":"First Steps slice; not full GDD acceptance or human playtesting", "engine":Engine.get_version_info().string,"created_at":Time.get_datetime_string_from_system(true),"results":results,"failures":failures}
	var out := ProjectSettings.globalize_path("res://../evidence")
	DirAccess.make_dir_recursive_absolute(out)
	var file := FileAccess.open(out + "/mechanics-" + str(Time.get_unix_time_from_system()) + ".json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"  "))
	file.close()
	print("WALKER TESTS: %d checks / %d failures" % [results.size(), failures])
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)
