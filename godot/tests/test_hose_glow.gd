extends SceneTree
# A5 hose glow (CHANGE-BRIEF Part A): the shader's interface and the driver's rules, headless.
# The hosing state is driven through the real game loop and synthetic key events (W, R), never
# by calling the driver. The uniform is read every frame by a Sampler node whose process_priority
# is high, so it runs after every other _process in the frame (the driver included).
# Run at 30, 60 and 144 fps: scripts/run-test.sh test_hose_glow.gd <fps>.
# Revision 3: the hold is a breathing band 0.4..0.8 with a 1.0 s period instead of a flat 1.0;
# the hold assertions (in-band, maxima, period) and the ramp targets follow it.
# What this cannot see: pixels. Headless Godot draws nothing (CLAUDE.md, Headless facts).
const Game = preload("res://game/session.gd")
const SHADER_PATH := "res://shaders/hose_glow.gdshader"
const DRIVER_PATH := "res://features/player/hose_glow.gd"
const RAMP := 0.25     # R3: ramp rate is 1/RAMP per game second
const BAND_LO := 0.4   # Revision 3: while hosing, glow breathes 0.6 + 0.2 sin(2π t) ...
const BAND_HI := 0.8
const PERIOD := 1.0    # ... with a 1.0 s period in game seconds
const EPS := 1e-5
const BAND_EPS := 1e-4   # membership tolerance for the band
const REACH_EPS := 0.01  # how close the sampled signal must come to 0.4 and 0.8 (sampling at 30 fps loses < 0.002)
var game: Node2D
var sampler: Sampler
var results: Array[Dictionary] = []
var failures := 0

# Records {g: glow uniform, d: process delta, h: player.hosing} once per _process frame, after
# everyone else's _process (priority 100). It only reads; it never touches the driver.
class Sampler extends Node:
	var game: Node2D
	var samples: Array = []
	func _process(delta: float) -> void:
		if not is_instance_valid(game) or game.player == null or game.player.sprite == null:
			return
		var mat: Material = game.player.sprite.material
		var g: float = float(mat.get_shader_parameter("glow")) if mat is ShaderMaterial else -1.0
		samples.append({"g": g, "d": delta, "h": game.player.hosing})

func _initialize() -> void:
	call_deferred("run")

func steps(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

# Synthetic key event through Godot Input, the path test_keyboard.gd already proves reaches
# Input.is_action_just_pressed in physics (W) and _unhandled_input (R) headlessly.
func key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func check(id: String, condition: bool, observed: Dictionary) -> void:
	results.append({"id": id, "status": "PASS" if condition else "FAIL", "observed": observed})
	print(JSON.stringify(results.back()))
	if not condition:
		failures += 1

func fresh() -> void:
	if is_instance_valid(game):
		game.queue_free()
		await process_frame
	game = Game.new()
	game.test_mode = true
	root.add_child(game)
	game.start_session()          # real input: player.test_control stays false
	sampler.game = game
	sampler.samples.clear()
	game.player.position = Vector2(1220, 240)  # on B1-PW, in hose range (same spot as test_game.gd)
	await steps(3)

func S() -> Array:
	return sampler.samples

func in_band(g: float) -> bool:
	return g >= BAND_LO - BAND_EPS and g <= BAND_HI + BAND_EPS

func zero(g: float) -> bool:
	return is_zero_approx(g)

func first_from(from: int, pred: Callable) -> int:
	for i in range(from, S().size()):
		if pred.call(S()[i]):
			return i
	return -1

func last_before(limit: int, pred: Callable) -> int:
	var found := -1
	for i in range(0, limit):
		if pred.call(S()[i]):
			found = i
	return found

# Every step between a and b (inclusive) moves in `dir` (+1 up, -1 down), never backwards,
# and by at most delta / RAMP (+ EPS). Returns {ok, worst_step}.
func monotone(a: int, b: int, dir: float) -> Dictionary:
	var ok := a >= 0 and b > a
	var worst := 0.0
	for i in range(a + 1, b + 1):
		var step: float = (S()[i].g - S()[i - 1].g) * dir
		var max_step: float = S()[i].d / RAMP + EPS
		worst = maxf(worst, step)
		if step < -EPS or step > max_step:
			ok = false
	return {"ok": ok, "worst_step": worst}

func all_in_band(a: int, b: int) -> bool:
	if a < 0 or b < a:
		return false
	for i in range(a, b + 1):
		if not in_band(S()[i].g):
			return false
	return true

# Indices of the strict local maxima of g in [a, b] (a > 0, b < size - 1). A tie with the next
# sample counts once, on the first of the pair (at 30 fps the peak at t = 0.25 s falls between
# two samples that are equal up to rounding).
func local_maxima(a: int, b: int) -> Array[int]:
	var peaks: Array[int] = []
	for i in range(maxi(a, 1), mini(b, S().size() - 2) + 1):
		if S()[i].g > S()[i - 1].g and S()[i].g >= S()[i + 1].g:
			peaks.append(i)
	return peaks

func min_max(a: int, b: int) -> Dictionary:
	var lo := INF
	var hi := -INF
	for i in range(a, b + 1):
		lo = minf(lo, S()[i].g)
		hi = maxf(hi, S()[i].g)
	return {"min": lo, "max": hi}

func run() -> void:
	sampler = Sampler.new()
	sampler.process_priority = 100
	root.add_child(sampler)

	# --- A2 / F4: the shader's interface, from the engine and from the source text ---
	var shader: Shader = load(SHADER_PATH)
	var uniforms: Array = shader.get_shader_uniform_list()
	var types := {}
	var raw: Array = []
	for u in uniforms:
		types[String(u.name)] = int(u.type)
		raw.append({"name": String(u.name), "type": int(u.type), "hint": int(u.hint), "hint_string": String(u.hint_string)})
	check("shader-uniforms", uniforms.size() == 2 and types.get("glow", -1) == TYPE_FLOAT and types.get("glow_color", -1) == TYPE_COLOR,
		{"uniforms": raw, "TYPE_FLOAT": TYPE_FLOAT, "TYPE_COLOR": TYPE_COLOR})
	var src: String = FileAccess.get_file_as_string(SHADER_PATH)
	var re_glow := RegEx.create_from_string("uniform\\s+float\\s+glow\\s*:\\s*hint_range\\(\\s*0\\.0\\s*,\\s*1\\.0\\s*\\)\\s*=\\s*0\\.0\\s*;")
	var re_color := RegEx.create_from_string("uniform\\s+vec4\\s+glow_color\\s*:\\s*source_color\\s*=\\s*vec4\\(\\s*0\\.6\\s*,\\s*0\\.85\\s*,\\s*1\\.0\\s*,\\s*1\\.0\\s*\\)\\s*;")
	check("shader-defaults", re_glow.search(src) != null and re_color.search(src) != null,
		{"glow_default_line": re_glow.search(src) != null, "glow_color_default_line": re_color.search(src) != null, "source_bytes": src.length()})
	var re_line := RegEx.create_from_string("COLOR\\.rgb\\s*=\\s*mix\\(\\s*COLOR\\.rgb\\s*,\\s*glow_color\\.rgb\\s*,\\s*glow\\s*\\)\\s*;")
	check("colour-line", re_line.search(src) != null, {"a2_colour_line_present": re_line.search(src) != null})
	var driver_param: String = load(DRIVER_PATH).PARAM
	check("driver-param-declared", types.has(driver_param), {"driver_writes": driver_param, "shader_declares": types.keys()})

	# --- A2 / F5 / R8: where the material sits ---
	await fresh()
	var mat: Material = game.player.sprite.material
	var mat_shader_path: String = mat.shader.resource_path if mat is ShaderMaterial and mat.shader else ""
	check("material-on-sprite", mat is ShaderMaterial and mat_shader_path == SHADER_PATH and game.player.material == null and game.player.art.material == null,
		{"sprite_material": str(mat), "shader": mat_shader_path, "player_material": str(game.player.material), "art_material": str(game.player.art.material)})

	# --- R1: nothing glows before W ---
	var pre_n := S().size()
	var pre_ok := pre_n >= 3
	for i in range(pre_n):
		if S()[i].g != 0.0 or S()[i].h:
			pre_ok = false
	check("glow-starts-zero", pre_ok, {"frames": pre_n, "last": S()[pre_n - 1] if pre_n > 0 else null})

	# --- R1, R3, R4, F1 (Revision 3): W through the game loop; ramp from 0 into the band ---
	# The brief says "into the band within 0.25 s". At the ramp rate 1/RAMP the band's low edge
	# (0.4) is reached in 0.4 × 0.25 = 0.1 s, asserted to one frame as well, so a slower ramp (F1)
	# is still caught on the way up now that 1.0 is no longer the target.
	var press_at := S().size()
	key(KEY_W, true)
	await steps(2)
	key(KEY_W, false)
	var guard := 0
	while guard < 200 and first_from(press_at, func(s): return in_band(s.g)) < 0:
		await steps(1)
		guard += 1
	var i_rise := first_from(press_at, func(s): return s.g > 0.0)
	var i0 := last_before(i_rise, func(s): return s.g == 0.0) if i_rise > 0 else -1
	var i1 := first_from(press_at, func(s): return in_band(s.g))
	var d: float = S()[i1].d if i1 >= 0 else 0.0
	var up_frames := i1 - i0
	var up_time := up_frames * d
	var up_expected := BAND_LO * RAMP
	var g_max := 0.0
	for s in S():
		g_max = maxf(g_max, s.g)
	check("ramp-up-time", i0 >= 0 and i1 > i0 and up_time <= RAMP + d + EPS and absf(up_time - up_expected) <= d + EPS and g_max <= BAND_HI + BAND_EPS and S()[i_rise].h,
		{"delta": d, "fps_from_delta": 1.0 / d if d > 0.0 else 0.0, "frames": up_frames, "seconds": up_time, "within": RAMP, "expected_at_ramp_rate": up_expected, "tolerance": d, "max_glow": g_max, "hosing_at_first_rise": S()[i_rise].h if i_rise >= 0 else null})
	var up := monotone(i0, i1, 1.0)
	check("ramp-up-monotonic", up.ok, {"from": i0, "to": i1, "worst_step": up.worst_step, "max_step": d / RAMP})

	# --- R5, F2: a second W during the glow changes nothing ---
	var ticks_before: int = game.water_ticks
	var ext_before: int = game.extinguish_ticks
	var near: bool = game.near_fire
	var retrig_at := S().size()
	key(KEY_W, true)
	await steps(2)
	key(KEY_W, false)
	await steps(1)
	check("retrigger-ignored", near and ext_before > 0 and game.water_ticks < ticks_before and game.sfx_counts.hose == 1 and all_in_band(retrig_at, S().size() - 1),
		{"near_fire": near, "water_ticks_before": ticks_before, "water_ticks_after": game.water_ticks, "hose_sounds": game.sfx_counts.hose, "samples_since": S().size() - retrig_at})

	# --- R6 (Revision 2, band per Revision 3): the game's pause during the hold ---
	# The game pause freezes water_ticks (the hold) but leaves player.hosing true and does not pause
	# the tree, so the driver, which reads only player.hosing, keeps breathing inside the band. The
	# check asserts the band; min/max over the paused frames are recorded so the log shows whether
	# the value moved. A value frozen outright needs a tree pause (R6), which this test does not do.
	game.set_paused(true)
	var pause_at := S().size()
	var ticks_paused: int = game.water_ticks
	await steps(10)
	var paused_mm := min_max(pause_at, S().size() - 1)
	check("pause-holds", game.state == Game.State.PAUSED and game.water_ticks == ticks_paused and S().size() - pause_at >= 10 and all_in_band(pause_at, S().size() - 1),
		{"state": game.state, "water_ticks": game.water_ticks, "frames_paused": S().size() - pause_at, "glow_min_while_paused": paused_mm.min, "glow_max_while_paused": paused_mm.max, "glow_moved_while_paused": paused_mm.max - paused_mm.min > BAND_EPS})
	game.set_paused(false)

	# --- R1/R3 hold (Revision 3): after the first 0.25 s every hosing sample is in [0.4, 0.8] ---
	guard = 0
	while guard < 2000 and (game.player.hosing or not zero(S().back().g)):
		await steps(1)
		guard += 1
	var i_h := first_from(press_at, func(s): return s.h)         # hosing began (t = 0)
	var j0 := last_before(S().size(), func(s): return s.h)        # last hosing sample
	var band_from := i_h + ceili(RAMP / d - EPS)                  # first sample at t >= 0.25 s
	var hold_mm := min_max(band_from, j0)
	check("hold-in-band", i_h >= 0 and j0 > band_from and all_in_band(band_from, j0),
		{"hosing_from": i_h, "band_from": band_from, "last_hosing": j0, "hold_frames": j0 - i_h + 1, "hold_seconds": (j0 - i_h + 1) * d, "min": hold_mm.min, "max": hold_mm.max, "band": [BAND_LO, BAND_HI], "band_eps": BAND_EPS})

	# --- the signal breathes: at least 4 local maxima in the hold, reaching both ends of the band ---
	var peaks := local_maxima(i_h + 1, j0 - 1)
	var peak_values: Array = []
	for p in peaks:
		peak_values.append(S()[p].g)
	check("hold-breathes", peaks.size() >= 4 and hold_mm.max >= BAND_HI - REACH_EPS and hold_mm.min <= BAND_LO + REACH_EPS,
		{"maxima": peaks.size(), "maxima_at": peaks, "maxima_values": peak_values, "min": hold_mm.min, "max": hold_mm.max, "reach_eps": REACH_EPS})

	# --- period 1.0 s, peak to peak, within one frame period at this frame rate ---
	var gaps_s: Array = []
	var period_ok := peaks.size() >= 2
	var worst_gap := 0.0
	for k in range(1, peaks.size()):
		var gap_s: float = (peaks[k] - peaks[k - 1]) * d
		gaps_s.append(gap_s)
		worst_gap = maxf(worst_gap, absf(gap_s - PERIOD))
		if absf(gap_s - PERIOD) > d + EPS:
			period_ok = false
	check("hold-period", period_ok, {"peak_to_peak_seconds": gaps_s, "expected": PERIOD, "tolerance": d, "worst_error": worst_gap})

	# --- R2, R3: the hold is the game's; the down-ramp starts the frame hosing ends ---
	# From a band value g the ramp at rate 1/RAMP takes g × 0.25 s (≤ 0.25 s), asserted to one frame.
	var j1 := first_from(j0 + 1, func(s): return zero(s.g)) if j0 >= 0 else -1
	var down_frames := j1 - j0
	var down_time := down_frames * d
	var g_at_end: float = S()[j0].g if j0 >= 0 else -1.0
	var down_expected := g_at_end * RAMP
	var hold_ok: bool = j0 >= 0 and j0 + 1 < S().size() and in_band(g_at_end) and S()[j0].h and not S()[j0 + 1].h
	var down := monotone(j0, j1, -1.0)
	check("hold-is-game-time", hold_ok and j1 > j0 and absf(down_time - down_expected) <= d + EPS and down_time <= RAMP + d + EPS and zero(S().back().g) and down.ok,
		{"hold_frames": j0 - i_h + 1, "hold_seconds": (j0 - i_h + 1) * d, "glow_at_last_hosing": g_at_end, "hosing_at_last": S()[j0].h, "hosing_next_frame": S()[j0 + 1].h, "down_frames": down_frames, "down_seconds": down_time, "expected": down_expected, "tolerance": d, "monotone": down.ok, "worst_step": down.worst_step, "last": S().back().g, "water_ticks": game.water_ticks})

	# --- R7: R mid-ramp; glow descends from where it is, never jumps ---
	await fresh()
	key(KEY_W, true)
	var r_at := -1
	guard = 0
	while guard < 100 and r_at < 0:
		await steps(1)
		guard += 1
		var g: float = S().back().g
		if g > 0.3 and g < 0.7:
			key(KEY_R, true)
			r_at = S().size() - 1   # the sample on screen when R was posted
	await steps(2)
	key(KEY_R, false)
	key(KEY_W, false)
	guard = 0
	while guard < 100 and not zero(S().back().g):
		await steps(1)
		guard += 1
	var peak_idx := r_at
	for i in range(r_at, S().size()):
		if S()[i].g > S()[peak_idx].g:
			peak_idx = i
	var peak: float = S()[peak_idx].g if r_at >= 0 else -1.0
	var k1 := first_from(peak_idx + 1, func(s): return zero(s.g)) if r_at >= 0 else -1
	var dn := monotone(peak_idx, k1, -1.0)
	var restarted: bool = game.state == Game.State.PLAYING and game.water_ticks == 0 and game.player.position.distance_to(Vector2(64, 320)) < 1.0
	check("restart-mid-ramp", r_at >= 0 and peak <= BAND_HI + BAND_EPS and peak > 0.3 and peak_idx - r_at <= 2 and k1 > peak_idx and dn.ok and (k1 - peak_idx) * d <= RAMP + d + EPS and restarted,
		{"glow_at_R": S()[r_at].g if r_at >= 0 else null, "peak": peak, "frames_until_descent": peak_idx - r_at, "down_frames": k1 - peak_idx, "down_seconds": (k1 - peak_idx) * d, "monotone": dn.ok, "worst_step": dn.worst_step, "restarted": restarted, "state": game.state, "water_ticks": game.water_ticks})

	print("HOSE GLOW TESTS: %d checks / %d failures (process delta %.6f s)" % [results.size(), failures, d])
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)
