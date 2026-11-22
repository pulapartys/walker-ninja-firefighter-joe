extends SceneTree
# Bakes Joe's clips into res://animations/joe.tres from CHANGE-BRIEF "The phase table" (as revised
# in Revision 2) and "The sheet". Clips are built here, once, and committed; the game only loads them.
# Run: godot --headless --path godot --script res://tools/bake_joe_clips.gd

const OUT := "res://animations/joe.tres"
const ANCHORS := "res://art/character/anchors.json"  # its key order is the sheet's cell order
const FPS := 60.0                # the phase table's frame rate: one frame per physics tick
const TRACK := "Sprite:frame"    # relative to the AnimationPlayer's root_node, the Art root
# One-key hold clips, one per state the state machine can show outside the toss.
const HOLDS := ["idle", "respawn", "run", "rising", "falling", "landing", "hose", "burned", "celebrate"]
# The toss: [first frame of the phase, cell shown], then the clip length in frames.
const TOSS_KEYS := [[0, "grab"], [14, "toss"], [30, "respawn"]]
const TOSS_FRAMES := 46

func _initialize() -> void:
	var cells: Array = JSON.parse_string(FileAccess.get_file_as_string(ANCHORS)).anchors.keys()
	var unknown := []
	for pose in HOLDS + TOSS_KEYS.map(func(k): return k[1]):
		if cells.find(pose) < 0:
			unknown.append(pose)
	if not unknown.is_empty():
		push_error("poses %s are not in %s" % [str(unknown), ANCHORS])
		quit(1)
		return
	var library := AnimationLibrary.new()
	for pose in HOLDS:
		library.add_animation(pose, clip([[0, cells.find(pose)]], 1, Animation.LOOP_LINEAR))
	var keys: Array = []
	for k in TOSS_KEYS:
		keys.append([k[0], cells.find(k[1])])
	library.add_animation("toss", clip(keys, TOSS_FRAMES, Animation.LOOP_NONE))
	var err := ResourceSaver.save(library, OUT)
	if err != OK:
		push_error("could not save %s: error %d" % [OUT, err])
		quit(1)
		return
	print("baked %s: %s" % [OUT, library.get_animation_list()])
	quit(0)

# Builds one clip with a single discrete value track on the sprite's `frame`.
# keys: [frame number, cell index] pairs; frames: clip length in frames; loop: an Animation.LoopMode.
# Returns the clip; it raises nothing (the caller has checked every cell index exists).
func clip(keys: Array, frames: int, loop: Animation.LoopMode) -> Animation:
	var a := Animation.new()
	a.length = frames / FPS
	a.step = 1.0 / FPS
	a.loop_mode = loop
	var t := a.add_track(Animation.TYPE_VALUE)
	a.track_set_path(t, NodePath(TRACK))
	a.value_track_set_update_mode(t, Animation.UPDATE_DISCRETE)
	a.track_set_interpolation_type(t, Animation.INTERPOLATION_NEAREST)
	for k in keys:
		a.track_insert_key(t, k[0] / FPS, int(k[1]))
	return a
