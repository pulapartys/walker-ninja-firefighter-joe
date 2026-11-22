extends SceneTree
# A7 read-back for Joe's sprite clips (CHANGE-BRIEF "The sheet", "The phase table" as revised in
# Revision 2, and the read-back rows of "The evidence split"). It loads res://features/player/joe_art.tscn, the scene player.gd
# instances, and reads back what its AnimationPlayer's clips contain: every track resolves, key
# times and cells match the phase table, step, loop mode, discrete updates, and every frame key
# inside the sheet. What it cannot show: whether the motion reads. Headless Godot draws nothing
# (CLAUDE.md "Headless facts"); that is the frame strip's and my eyes' job.
# Run: scripts/run-test.sh test_toss_readback.gd 60

const Checks = preload("res://tests/anim_checks.gd")
const ART := "res://features/player/joe_art.tscn"
const FPS := 60.0
const TRACK := "Sprite:frame"
const SHEET := Vector2i(568, 435)           # 4 x 3 cells of 142 x 145
const GRID := Vector2i(4, 3)
const SPRITE_AT := Vector2(-70, -133)        # minus the shared cell anchor
const TOSS_FRAMES := [0, 14, 30]             # the phase table (Revision 2): startup, active, recovery begin
const TOSS_CELLS := [8, 9, 1]                # grab, toss, respawn
const TOSS_LENGTH := 46                      # frames; the last shown frame (45) is inside the clip
const HOLDS := {"idle": 0, "respawn": 1, "run": 2, "rising": 4, "falling": 5, "landing": 6,
	"hose": 7, "burned": 10, "celebrate": 11}
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
	var packed: PackedScene = load(ART)
	if packed == null:
		check("art-loads", false, {"path": ART})
		return finish()
	var art: Node2D = packed.instantiate()
	root.add_child(art)
	var sprite := art.get_node_or_null("Sprite") as Sprite2D
	var anim := art.get_node_or_null("AnimationPlayer") as AnimationPlayer
	check("art-loads", sprite != null and anim != null, {"sprite": str(sprite), "anim": str(anim)})
	if sprite == null or anim == null:
		return finish()

	# The sheet and its slicing (CHANGE-BRIEF "The sheet").
	var tex_size := Vector2i(sprite.texture.get_size()) if sprite.texture else Vector2i.ZERO
	check("sheet-grid", tex_size == SHEET and sprite.hframes == GRID.x and sprite.vframes == GRID.y
		and not sprite.centered and sprite.position.is_equal_approx(SPRITE_AT),
		{"texture": str(tex_size), "hframes": sprite.hframes, "vframes": sprite.vframes,
		"centered": sprite.centered, "position": str(sprite.position)})

	# The clock and the authority (CHANGE-BRIEF "The two clocks", "Clip 2").
	check("clock-manual", anim.callback_mode_process == AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL,
		{"callback_mode_process": anim.callback_mode_process})
	check("no-autoplay", anim.autoplay == "", {"autoplay": anim.autoplay})

	var problems := Checks.track_problems(anim)
	check("tracks-resolve", problems.is_empty(), {"problems": problems})

	var names: Array = Array(anim.get_animation_list())
	var want: Array = HOLDS.keys() + ["toss"]
	names.sort()
	want.sort()
	check("clip-list", names == want, {"clips": names, "brief": want})

	var cells := sprite.hframes * sprite.vframes
	for clip_name in anim.get_animation_list():
		var clip := anim.get_animation(clip_name)
		var one := clip.get_track_count() == 1
		var t := 0
		var is_frame := one and clip.track_get_type(t) == Animation.TYPE_VALUE and String(clip.track_get_path(t)) == TRACK
		# Update mode exists only on value tracks; asking any other track type errors.
		var discrete := is_frame and clip.value_track_get_update_mode(t) == Animation.UPDATE_DISCRETE
		check("frame-track:" + clip_name, is_frame and discrete,
			{"tracks": clip.get_track_count(), "path": str(clip.track_get_path(t)) if one else "", "discrete": discrete})
		if not is_frame:
			continue
		var values := Checks.key_values(clip, t)
		var inside := true
		for v in values:
			inside = inside and v is int and v >= 0 and v < cells
		check("frame-in-sheet:" + clip_name, inside, {"values": values, "cells": cells})
		check("step:" + clip_name, is_equal_approx(clip.step, 1.0 / FPS), {"step": clip.step})
		var times := Checks.key_times(clip, t)
		if clip_name == "toss":
			check("toss-keys", Checks.times_match(times, TOSS_FRAMES, FPS) and values == TOSS_CELLS,
				{"times": times, "values": values, "brief_frames": TOSS_FRAMES, "brief_cells": TOSS_CELLS})
			check("toss-length", absf(clip.length - TOSS_LENGTH / FPS) < 0.5 / FPS, {"length": clip.length, "brief": TOSS_LENGTH / FPS})
			check("toss-does-not-loop", clip.loop_mode == Animation.LOOP_NONE, {"loop_mode": clip.loop_mode})
		else:
			check("hold-key:" + clip_name, Checks.times_match(times, [0], FPS) and values == [HOLDS[clip_name]],
				{"times": times, "values": values, "brief_cell": HOLDS.get(clip_name)})
			check("hold-length:" + clip_name, absf(clip.length - 1.0 / FPS) < 0.5 / FPS, {"length": clip.length})
			check("hold-loops:" + clip_name, clip.loop_mode == Animation.LOOP_LINEAR, {"loop_mode": clip.loop_mode})
	finish()

func finish() -> void:
	print("TOSS READBACK RESULT: %d checks / %d failures" % [count, failures])
	quit(1 if failures or count == 0 else 0)
