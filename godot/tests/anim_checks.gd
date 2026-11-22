extends RefCounted
# Shared read-back helper for the A7 clip tests (CHANGE-BRIEF "The evidence split", first row).

# Every track in every clip of `player` resolves to a real node, and to a real property, bone or
# blend shape where the track names one (the assignment's check, branched on track type).
# Returns one line per problem; an empty array means every track resolves. It proves a track points
# at something real, never that it points at the right thing: `sub in node` is also true for a method.
static func track_problems(player: AnimationPlayer) -> Array[String]:
	var problems: Array[String] = []
	var root := player.get_node_or_null(player.root_node)
	if root == null:
		problems.append("root_node %s resolves to nothing" % player.root_node)
		return problems
	for clip_name in player.get_animation_list():
		var clip := player.get_animation(clip_name)
		for t in clip.get_track_count():
			var path := clip.track_get_path(t)
			var node := root.get_node_or_null(NodePath(path.get_concatenated_names()))
			if node == null:
				problems.append("%s track %d: no node at %s" % [clip_name, t, path])
				continue
			if path.get_subname_count() == 0:
				continue
			var sub := path.get_subname(0)
			match clip.track_get_type(t):
				Animation.TYPE_POSITION_3D, Animation.TYPE_ROTATION_3D, Animation.TYPE_SCALE_3D:
					var skeleton := node as Skeleton3D
					if skeleton == null or skeleton.find_bone(sub) == -1:
						problems.append("%s track %d: no bone %s on %s" % [clip_name, t, sub, node.name])
				Animation.TYPE_BLEND_SHAPE:
					var mesh := node as MeshInstance3D
					if mesh == null or mesh.find_blend_shape_by_name(sub) == -1:
						problems.append("%s track %d: no blend shape %s on %s" % [clip_name, t, sub, node.name])
				_:
					if not (sub in node):
						problems.append("%s track %d: %s has no property %s" % [clip_name, t, node.name, sub])
	return problems

# The key times of track `t` in `clip`, as a plain Array of floats.
static func key_times(clip: Animation, t: int) -> Array:
	var out := []
	for k in clip.track_get_key_count(t):
		out.append(clip.track_get_key_time(t, k))
	return out

# The key values of track `t` in `clip`, as a plain Array.
static func key_values(clip: Animation, t: int) -> Array:
	var out := []
	for k in clip.track_get_key_count(t):
		out.append(clip.track_get_key_value(t, k))
	return out

# True when `times` matches `frames` / `fps` key for key, each within half a frame period.
# Key times are stored as 32-bit floats, so they are never compared with ==.
static func times_match(times: Array, frames: Array, fps: float) -> bool:
	if times.size() != frames.size():
		return false
	var tol := 0.5 / fps
	for i in times.size():
		if absf(float(times[i]) - float(frames[i]) / fps) >= tol:
			return false
	return true
