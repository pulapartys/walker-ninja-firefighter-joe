extends SceneTree
# A5 Part C captures (TEST-REPORT "Interface sweep" and "One shader, two materials"). Needs a window:
#   ~/Downloads/Godot.app/Contents/MacOS/Godot --path godot --script res://tests/capture_hydrant.gd [-- shader-edited]
# Loads scenes3d/props_room.tscn, frames the two hydrants under the scene's own Sun and Environment,
# and saves real rendered frames to a5/evidence/captures/hydrant/:
#   side_by_side.png                 both materials, defaults as saved in the .tres files
#   sweep_<uniform>_<min|default|max>.png   the rusty material's uniform at each value, then restored
#   material_edit.png                rusty material's rust_amount set to 0.0 at runtime (only one changes)
# With `-- shader-edited` it only saves shader_edited.png: run it after temporarily editing one line
# of hydrant_surface.gdshader (both hydrants must change), then restore the shader.
# One pixel on each hydrant body is sampled so "changed / unchanged" is a number, not an impression.
var OUT: String = ProjectSettings.globalize_path("res://").path_join("../a5/evidence/captures/hydrant/")
# CHANGE-BRIEF C3 interface: name -> [min, default, max]
const SWEEP := {
	"rust_amount": [0.0, 0.3, 1.0],
	"roughness_scale": [0.0, 1.0, 2.0],
	"normal_strength": [0.0, 1.0, 2.0],
	"uv_scale": [0.25, 2.0, 8.0],
}
const TINT_SWEEP := {"paint_tint": [Color(0, 0, 0, 1), Color(0.75, 0.22, 0.17, 1), Color(1, 1, 1, 1)]}
var scene: Node3D
var cam: Camera3D
var fresh_mi: MeshInstance3D
var rusty_mi: MeshInstance3D

func _initialize() -> void:
	call_deferred("run")

func sample(mi: MeshInstance3D, img: Image) -> Dictionary:
	# a point on the front of the body, ~0.45 m up (the hydrant is 0.8 m tall, ~0.18 m radius)
	var world: Vector3 = mi.get_parent().global_transform * Vector3(0.0, 0.45, 0.17)
	var p: Vector2 = get_root().get_final_transform() * cam.unproject_position(world)
	var pi := Vector2i(int(floor(p.x)), int(floor(p.y)))
	var c := img.get_pixel(pi.x, pi.y)
	var acc := Vector3.ZERO
	for dy in range(-2, 3):
		for dx in range(-2, 3):
			var n := img.get_pixel(pi.x + dx, pi.y + dy)
			acc += Vector3(n.r8, n.g8, n.b8)
	acc /= 25.0
	return {"window_px": [pi.x, pi.y], "rgb": [c.r8, c.g8, c.b8], "mean_5x5": [roundi(acc.x), roundi(acc.y), roundi(acc.z)]}

func capture(name: String) -> Dictionary:
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var img: Image = get_root().get_texture().get_image()
	img.save_png(OUT.path_join(name + ".png"))
	var row := {"capture": name, "fresh": sample(fresh_mi, img), "rusty": sample(rusty_mi, img)}
	print(JSON.stringify(row))
	return row

func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	scene = load("res://scenes3d/props_room.tscn").instantiate()
	root.add_child(scene)
	cam = scene.get_node("Camera3D")
	fresh_mi = scene.get_node("Hydrant/Hydrant")
	rusty_mi = scene.get_node("HydrantRusty/Hydrant")
	# frame the two hydrants; the Sun and Environment are the scene's own (CHANGE-BRIEF C1)
	cam.position = Vector3(-1.2, 0.75, 1.7)
	cam.look_at(Vector3(-1.2, 0.38, 0.0))
	for i in 10:
		await process_frame
	var rusty: ShaderMaterial = rusty_mi.get_surface_override_material(0)
	var fresh: ShaderMaterial = fresh_mi.mesh.surface_get_material(0)
	print("fresh material=%s rusty material=%s same shader=%s" % [fresh.resource_path, rusty.resource_path, fresh.shader == rusty.shader])
	if "shader-edited" in OS.get_cmdline_user_args():
		await capture("shader_edited")
		quit(0)
		return
	await capture("side_by_side")
	for u in SWEEP:
		var saved = rusty.get_shader_parameter(u)
		for i in 3:
			rusty.set_shader_parameter(u, SWEEP[u][i])
			await capture("sweep_%s_%s" % [u, ["min", "default", "max"][i]])
		rusty.set_shader_parameter(u, saved)
	for u in TINT_SWEEP:
		var saved = rusty.get_shader_parameter(u)
		for i in 3:
			rusty.set_shader_parameter(u, TINT_SWEEP[u][i])
			await capture("sweep_%s_%s" % [u, ["min", "default", "max"][i]])
		rusty.set_shader_parameter(u, saved)
	# one value in one material: only the rusty hydrant may change
	var saved_rust = rusty.get_shader_parameter("rust_amount")
	rusty.set_shader_parameter("rust_amount", 0.0)
	await capture("material_edit_rust_0")
	rusty.set_shader_parameter("rust_amount", saved_rust)
	print("CAPTURE DONE in %s" % OUT)
	quit(0)
