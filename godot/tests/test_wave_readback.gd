extends SceneTree
# A7 read-back for the person survivor's wave (CHANGE-BRIEF "Clip 1", "The cycle spec" and the
# read-back rows of "The evidence split"). It loads res://features/survivor/survivor_person.tscn and
# reads back its clip: the track resolves to a real node and property, key times and values match
# the cycle spec, step, loop mode, and the seam (the value at 0 equals the value at the length).
# What it cannot show: whether the wave reads or wraps without a visible hitch. Headless Godot draws
# nothing (CLAUDE.md "Headless facts"); that is my eyes' job in the running game.
# Run: scripts/run-test.sh test_wave_readback.gd 60

const Checks = preload("res://tests/anim_checks.gd")
const RIG := "res://features/survivor/survivor_person.tscn"
const FPS := 30.0
const TRACK := "Shoulder:rotation"
const FRAMES := [0, 12, 24]
const VALUES := [0.0, 0.45, 0.0]   # radians
const LENGTH := 24                 # frames
const SHOULDER_AT := Vector2(4.7, -16.0)
var failures := 0
var count := 0

func _initialize() -> void:
	call_deferred("run")

func check(id: String, condition: bool, observed: Dictionary) -> void:
	count += 1
	if not condition:
		failures += 1
	print(JSON.stringify({"id": id, "status": "PASS" if condition else "FAIL", "observed": observed}))

func run() -> void:
	var packed: PackedScene = load(RIG)
	if packed == null:
		check("rig-loads", false, {"path": RIG})
		return finish()
	var rig: Node2D = packed.instantiate()
	root.add_child(rig)
	var anim := rig.get_node_or_null("AnimationPlayer") as AnimationPlayer
	var shoulder := rig.get_node_or_null("Shoulder") as Node2D
	check("rig-loads", anim != null and shoulder != null, {"anim": str(anim), "shoulder": str(shoulder)})
	if anim == null or shoulder == null:
		return finish()
	check("shoulder-pivot", shoulder.position.is_equal_approx(SHOULDER_AT), {"position": str(shoulder.position)})
	check("autoplay-wave", anim.autoplay == "wave", {"autoplay": anim.autoplay})
	check("clock-idle", anim.callback_mode_process == AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_IDLE,
		{"callback_mode_process": anim.callback_mode_process})
	var problems := Checks.track_problems(anim)
	check("tracks-resolve", problems.is_empty(), {"problems": problems})
	check("clip-list", Array(anim.get_animation_list()) == ["wave"], {"clips": Array(anim.get_animation_list())})
	if not anim.has_animation("wave"):
		return finish()
	var clip := anim.get_animation("wave")
	var one := clip.get_track_count() == 1
	var t := 0
	check("one-rotation-track", one and clip.track_get_type(t) == Animation.TYPE_VALUE and String(clip.track_get_path(t)) == TRACK,
		{"tracks": clip.get_track_count(), "path": str(clip.track_get_path(t)) if one else ""})
	if not one:
		return finish()
	var times := Checks.key_times(clip, t)
	var values := Checks.key_values(clip, t)
	var close := values.size() == VALUES.size()
	for i in mini(values.size(), VALUES.size()):
		close = close and absf(float(values[i]) - VALUES[i]) < 1e-6
	check("wave-keys", Checks.times_match(times, FRAMES, FPS) and close,
		{"times": times, "values": values, "brief_frames": FRAMES, "brief_values": VALUES})
	check("wave-length", absf(clip.length - LENGTH / FPS) < 0.5 / FPS, {"length": clip.length, "brief": LENGTH / FPS})
	check("step", is_equal_approx(clip.step, 1.0 / FPS), {"step": clip.step})
	check("wave-loops", clip.loop_mode == Animation.LOOP_LINEAR, {"loop_mode": clip.loop_mode})
	check("continuous", clip.value_track_get_update_mode(t) == Animation.UPDATE_CONTINUOUS,
		{"update_mode": clip.value_track_get_update_mode(t)})
	# Seam rule for a continuous track: the value at time 0 equals the value at the clip length.
	var at_zero := float(clip.value_track_interpolate(t, 0.0))
	var at_end := float(clip.value_track_interpolate(t, clip.length))
	check("seam", absf(at_zero - at_end) < 1e-6 and absf(float(values.front()) - float(values.back())) < 1e-6,
		{"value_at_0": at_zero, "value_at_length": at_end})
	finish()

func finish() -> void:
	print("WAVE READBACK RESULT: %d checks / %d failures" % [count, failures])
	quit(1 if failures or count == 0 else 0)
