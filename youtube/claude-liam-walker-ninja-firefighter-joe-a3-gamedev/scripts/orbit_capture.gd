## Film capture (not part of the game): one slow orbit around scenes3d/props_room.tscn, recorded by Godot's Movie Maker.
## Copied into an isolated copy of godot/ with override.cfg (3840x2160); the scene is loaded as saved, only the camera moves.
extends SceneTree

const SECONDS := 14.0
var cam: Camera3D
var t := 0.0

func _initialize() -> void:
	var scene: Node3D = load("res://scenes3d/props_room.tscn").instantiate()
	root.add_child(scene)
	cam = scene.get_node("Camera3D")

func _process(delta: float) -> bool:
	t += delta
	var a := TAU * t / SECONDS + PI / 2.0
	cam.global_position = Vector3(0.35 + cos(a) * 3.0, 1.25, sin(a) * 3.0)
	cam.look_at(Vector3(0.35, 0.4, 0))
	return t >= SECONDS
