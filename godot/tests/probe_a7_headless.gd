extends SceneTree
# A7 headless probe (CLAUDE.md "Headless facts", "Godot 4 names"): checks on this machine, before
# anything is built, the animation facts the A7 tests rely on. Not a test of the game; it builds
# throwaway clips in memory and in user://, which the game never does.
# Run: scripts/run-test.sh probe_a7_headless.gd 60

func _initialize() -> void:
	call_deferred("run")

func say(label: String, value) -> void:
	print("PROBE %s: %s" % [label, str(value)])

func run() -> void:
	say("version", Engine.get_version_info().string)
	say("adapter (empty = nothing renders)", "'%s'" % RenderingServer.get_video_adapter_name())
	# Names on 4.7.2.
	say("Animation has property loop_mode", "loop_mode" in Animation.new())
	say("Animation has Godot 3 property loop", "loop" in Animation.new())
	say("AnimationPlayer has speed_scale", "speed_scale" in AnimationPlayer.new())
	say("AnimationPlayer has Godot 3 playback_speed", "playback_speed" in AnimationPlayer.new())
	say("ClassDB AnimatedSprite exists (Godot 3)", ClassDB.class_exists("AnimatedSprite"))
	say("AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL", AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL)
	say("AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_IDLE", AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_IDLE)
	say("AnimationPlayer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL (via subclass)", AnimationPlayer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL)
	say("Animation.INTERPOLATION_CUBIC_ANGLE", Animation.INTERPOLATION_CUBIC_ANGLE)
	say("Animation.LOOP_NONE / LOOP_LINEAR", [Animation.LOOP_NONE, Animation.LOOP_LINEAR])
	say("Animation.UPDATE_CONTINUOUS / DISCRETE", [Animation.UPDATE_CONTINUOUS, Animation.UPDATE_DISCRETE])
	say("Animation default step", Animation.new().step)

	# A headless run advances a clip: a discrete frame track on a Sprite2D, manual callback.
	var holder := Node2D.new()
	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	sprite.texture = PlaceholderTexture2D.new()
	sprite.hframes = 4
	sprite.vframes = 3
	holder.add_child(sprite)
	var player := AnimationPlayer.new()
	holder.add_child(player)
	root.add_child(holder)
	var a := Animation.new()
	a.length = 46.0 / 60.0
	var t := a.add_track(Animation.TYPE_VALUE)
	a.track_set_path(t, NodePath("Sprite:frame"))
	a.value_track_set_update_mode(t, Animation.UPDATE_DISCRETE)
	for k in [[0, 8], [15, 9], [30, 1]]:
		a.track_insert_key(t, k[0] / 60.0, k[1])
	var lib := AnimationLibrary.new()
	lib.add_animation("toss", a)
	player.add_animation_library("", lib)
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	sprite.frame = 0
	player.play("toss")
	say("manual: frame right after play(), no seek", sprite.frame)
	player.seek(0.0, true)
	say("manual: frame after seek(0, true)", sprite.frame)
	var seen := []
	for i in 46:
		player.advance(1.0 / 60.0)
		seen.append(sprite.frame)
	say("manual: frame after each of 46 advances of 1/60", seen)
	say("current_animation after the clip end (LOOP_NONE)", "'%s'" % player.current_animation)
	say("assigned_animation after the clip end", "'%s'" % player.assigned_animation)
	await process_frame
	await physics_frame
	var before := sprite.frame
	await process_frame
	say("manual: frame unchanged by the engine's own ticks", sprite.frame == before)
	# play() of the clip already assigned does not restart it.
	player.play("toss")
	player.seek(0.5, true)
	player.play("toss")
	say("play() again on the same clip keeps position (0.5)", player.current_animation_position)

	# A continuous frame track sweeps through the cells between keys.
	var c := Animation.new()
	c.length = 0.25
	var ct := c.add_track(Animation.TYPE_VALUE)
	c.track_set_path(ct, NodePath("Sprite:frame"))
	c.value_track_set_update_mode(ct, Animation.UPDATE_CONTINUOUS)
	c.track_insert_key(ct, 0.0, 9)
	c.track_insert_key(ct, 0.25, 1)
	var sweep := []
	for i in 6:
		sweep.append(c.value_track_interpolate(ct, i * 0.05))
	say("continuous frame track 9 -> 1 sampled every 0.05 s", sweep)

	# Key times are 32-bit floats: a .tres round trip loses digits.
	var r := Animation.new()
	var rt := r.add_track(Animation.TYPE_VALUE)
	r.track_set_path(rt, NodePath("Sprite:frame"))
	r.track_insert_key(rt, 15.0 / 60.0, 9)
	r.track_insert_key(rt, 1.0 / 60.0, 3)
	ResourceSaver.save(r, "user://probe_keys.tres")
	var back: Animation = ResourceLoader.load("user://probe_keys.tres", "", ResourceLoader.CACHE_MODE_IGNORE)
	var k1 := back.track_get_key_time(rt, 0)
	say("key 1/60 after .tres round trip == 1.0/60.0", k1 == 1.0 / 60.0)
	say("key 1/60 after .tres round trip, difference", absf(k1 - 1.0 / 60.0))
	say("step default 1/30 vs 1/60", [Animation.new().step, 1.0 / 60.0])

	# value_track_get_update_mode on a non-value track errors and answers continuous.
	var p := Animation.new()
	var pt := p.add_track(Animation.TYPE_POSITION_3D)
	say("value_track_get_update_mode on a 3D position track (expect an ERROR line above)", p.value_track_get_update_mode(pt))
	print("PROBE DONE")
	quit(0)
