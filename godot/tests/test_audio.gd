extends SceneTree
## Assignment 2 automated check (added 2026-10-07): each sound event fires exactly once per real
## occurrence, including a held key, rapid repeats, W mashing, and a duplicate death at reset; and
## muting both buses, or missing sound files, change nothing about what happens in the game; sounds
## play after the state change they report; the siren plays per session, not per retry; and the
## music follows pause / death / win (once the music file exists).
##   godot --headless --path . -s tests/test_audio.gd
const Game = preload("res://game/session.gd")
const Route = preload("res://tests/route_driver.gd")
var game: Node2D
var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func steps(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func check(id: String, passed: bool, observation: Dictionary) -> void:
	if not passed:
		failures += 1
	print(JSON.stringify({"id": id, "status": "PASS" if passed else "FAIL", "observed": observation}))

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

func counts() -> Dictionary:
	return game.sfx_counts.duplicate()

# Full scripted route (normal inputs only); returns what happened, for the mute comparison.
# Steps exactly one physics tick per input (await physics_frame), so two runs are identical
# tick for tick. Stepping by rendered frames varied by ±1 tick between unmuted runs (harness
# timing, not the game), which first made the mute check fail on 1265 vs 1268 ticks.
func play_route() -> Dictionary:
	await fresh()
	var route = Route.new()
	var ticks := 0
	while game.state == Game.State.PLAYING and ticks < 3000:
		route.step(game.player)
		await physics_frame
		ticks += 1
	return {"state": game.state, "ticks": ticks, "deaths": game.deaths, "jumps": game.player.jumps,
		"rescued": game.rescued_count, "pos": str(game.player.position.round()), "sfx": counts()}

func run() -> void:
	# 1. Session start: the siren once; nothing else.
	await fresh()
	check("siren-once-on-start", counts().siren == 1 and counts().jump == 0, counts())

	# 2. Held jump key: one jump, one sound, even held for a second.
	game.player.test_jump_pressed = true
	game.player.test_jump_held = true
	await steps(60)
	game.player.test_jump_held = false
	await steps(30)
	check("held-jump-one-sound", game.player.jumps == 1 and counts().jump == 1, {"jumps": game.player.jumps, "sfx": counts()})

	# 3. Rapid repeats: five taps, a few ticks apart. Every real jump sounds once; no extra sounds.
	await fresh()
	for i in range(5):
		game.player.test_jump_pressed = true
		await steps(4)
		await steps(60)  # land again before the next tap
	check("rapid-jumps-match", counts().jump == game.player.jumps and game.player.jumps >= 1, {"jumps": game.player.jumps, "sfx": counts()})

	# 4. Fire death, then a duplicate death call at the same moment: one burn sound.
	await fresh()
	game.player.position = Vector2(330, 310)  # onto the first ground flame (as test_game does)
	await steps(4)
	game.resolve_contacts(true, false)       # duplicate: ignored, no second sound
	check("burn-once-per-death", game.state == Game.State.DYING and game.deaths == 1 and counts().burn == 1, {"deaths": game.deaths, "sfx": counts()})
	await steps(130)  # the fire death holds FIRE_DEATH_HOLD = 2.0 s before the retry
	check("no-burn-after-retry", game.state == Game.State.PLAYING and counts().burn == 1, {"state": game.state, "sfx": counts()})

	# 5. Full route: jump sounds = jumps, one hose, one rescue per survivor, one win, no burn.
	var a := await play_route()
	var c: Dictionary = a.sfx
	check("route-one-sound-per-event", a.state == Game.State.COMPLETE and c.jump == a.jumps and c.hose == 1 and c.rescue == a.rescued and c.rescue == 2 and c.win == 1 and c.burn == 0 and c.siren == 1, a)

	# 6. W mashed while the water pours: one hose sound.
	await fresh()
	var route = Route.new()
	var ticks := 0
	while not route.hosed and ticks < 1500:
		route.step(game.player)
		await steps(1)
		ticks += 1
	for i in range(30):
		game.player.test_water_pressed = true
		await steps(1)
	check("w-mashing-one-hose", game.extinguish_ticks > 0 and counts().hose == 1, {"extinguish_ticks": game.extinguish_ticks, "sfx": counts()})

	# 7. Muted (both buses): the same route has the identical outcome, tick for tick.
	game._toggle_mute("Music")
	game._toggle_mute("SFX")
	var muted := await play_route()
	var both_muted: bool = game.is_muted("Music") and game.is_muted("SFX")
	var same: bool = muted.state == a.state and muted.ticks == a.ticks and muted.deaths == a.deaths and muted.jumps == a.jumps and muted.rescued == a.rescued and muted.pos == a.pos
	check("mute-changes-nothing", both_muted and same, {"unmuted": a, "muted": muted})
	game._toggle_mute("Music")
	game._toggle_mute("SFX")

	# 8. Every sound plays in the state of the event it reports (after the state change).
	var expected := {"jump": Game.State.PLAYING, "hose": Game.State.PLAYING, "rescue": Game.State.PLAYING,
		"siren": Game.State.PLAYING, "burn": Game.State.DYING, "win": Game.State.COMPLETE}
	await play_route()
	var bad := []
	for e in game.sfx_log:
		if e.state != expected[e.id]:
			bad.append(e)
	await fresh()
	game.player.position = Vector2(330, 310)
	await steps(4)
	for e in game.sfx_log:
		if e.state != expected[e.id]:
			bad.append(e)
	check("sound-after-state-change", bad.is_empty(), {"wrong": bad})

	# 9. Siren: once per new session, never on a retry.
	await steps(130)                       # the fire death retries by itself
	var after_retry: int = counts().siren
	game.restart_attempt()                 # R-style retry
	var after_r: int = counts().siren
	game.resolve_contacts(false, true)     # finish, then a new session from the end card
	game.start_session()
	check("siren-session-not-retry", after_retry == 1 and after_r == 1 and counts().siren == 2, {"after_retry": after_retry, "after_r": after_r, "after_new_session": counts().siren})

	# 10. Falling or running out of time: no burn sound (the text explains it).
	await fresh()
	game.player.position = Vector2(480, 300)  # over the first gap
	var t := 0
	while game.state == Game.State.PLAYING and t < 120:
		await physics_frame
		t += 1
	var fell_reason: String = game.death_reason
	var fell_burn: int = counts().burn
	await fresh()
	game.elapsed = float(game.level.time_limit) - 0.01
	await steps(3)
	check("no-burn-for-fall-or-timeout", fell_reason == "You fell." and game.death_reason == "Out of time!" and fell_burn == 0 and counts().burn == 0, {"fell": fell_reason, "timeout": game.death_reason, "burns": [fell_burn, counts().burn]})

	# 11. Every sound file missing: the same route has the identical outcome.
	await fresh()
	for id in game.sfx_players:
		game.sfx_players[id].stream = null
	game.music.stream = null
	var route2 = Route.new()
	var ticks2 := 0
	while game.state == Game.State.PLAYING and ticks2 < 3000:
		route2.step(game.player)
		await physics_frame
		ticks2 += 1
	var silent := {"state": game.state, "ticks": ticks2, "deaths": game.deaths, "jumps": game.player.jumps, "rescued": game.rescued_count, "pos": str(game.player.position.round())}
	check("missing-sounds-change-nothing", silent.state == a.state and silent.ticks == a.ticks and silent.deaths == a.deaths and silent.jumps == a.jumps and silent.rescued == a.rescued and silent.pos == a.pos, {"reference": a, "no_sound_files": silent})

	# 12. Music behaviour (CHANGE-BRIEF). Runs only when godot/audio/music_loop.ogg exists;
	#     otherwise it is reported as SKIPPED, not passed.
	await fresh()
	if game.music.stream == null:
		print(JSON.stringify({"id": "music-behaviour", "status": "SKIPPED", "observed": "no res://audio/music_loop.ogg yet"}))
	else:
		await steps(5)
		var playing: bool = game.music.playing and not game.music.stream_paused and game.music.volume_db == 0.0
		game.set_paused(true)
		await steps(3)
		var paused: bool = game.music.stream_paused
		game.set_paused(false)
		await steps(3)
		var pos_before: float = game.music.get_playback_position()
		game.player.position = Vector2(330, 310)
		await steps(4)
		var dipped: bool = game.state == Game.State.DYING and game.music.volume_db < -1.0 and game.music.playing
		await steps(130)
		var back: bool = game.state == Game.State.PLAYING and game.music.volume_db == 0.0 and game.music.get_playback_position() > pos_before
		game.resolve_contacts(false, true)
		await steps(3)
		var stopped: bool = not game.music.playing
		check("music-behaviour", playing and paused and dipped and back and stopped, {"playing": playing, "paused": paused, "dipped": dipped, "back_without_restart": back, "stopped_on_win": stopped})
		# The loop wraps: after one full length (25.6 s) it is back near the start and still playing.
		await fresh()
		var length: float = game.music.stream.get_length()
		var wrapped := false
		var last := 0.0
		var t2 := 0
		while t2 < int((length + 2.0) * 60.0) and game.state == Game.State.PLAYING:
			await physics_frame
			t2 += 1
			var pos: float = game.music.get_playback_position()
			if pos + 1.0 < last:
				wrapped = true
			last = pos
		check("music-loops", game.music.stream.loop and wrapped and game.music.playing, {"length_s": length, "loop": game.music.stream.loop, "wrapped": wrapped, "playing": game.music.playing})

	print("AUDIO TESTS: %d failures" % failures)
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)
