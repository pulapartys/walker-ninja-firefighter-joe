extends Node
# A6 debug key (Claude, from the assignment's snippet): F9 toggles vsync for the FPS comparison in the
# GPU price check, without changing a project setting. F9 is not an InputMap action and nothing else
# in the game reads it; the game's own input and state are untouched.

func _ready() -> void:
	name = "VsyncKey"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F9:
		var off := DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_DISABLED
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if off else DisplayServer.VSYNC_DISABLED)
		print("F9: vsync ", "on" if off else "off")
