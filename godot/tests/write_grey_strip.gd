extends SceneTree
# A5 hint experiment (CHANGE-BRIEF Part B): writes the 3x1 PNG whose texels are the greys 64, 128
# and 192, to res://art/hint/grey_3x1.png. Run once, headless:
#   ~/Downloads/Godot.app/Contents/MacOS/Godot --headless --path godot --script res://tests/write_grey_strip.gd
# Then reimport so the .import file exists (lossless, no mipmaps; set explicitly in that file).
const PATH := "res://art/hint/grey_3x1.png"
const GREYS := [64, 128, 192]

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://art/hint"))
	var img := Image.create(GREYS.size(), 1, false, Image.FORMAT_RGB8)
	for x in GREYS.size():
		var g: float = float(GREYS[x]) / 255.0
		img.set_pixel(x, 0, Color(g, g, g))
	var err := img.save_png(PATH)
	if err != OK:
		push_error("save_png failed: %d" % err)
		quit(1)
		return
	var back := Image.load_from_file(ProjectSettings.globalize_path(PATH))
	var read := []
	for x in back.get_width():
		read.append(back.get_pixel(x, 0).r8)
	print("wrote %s %dx%d; read back greys %s" % [PATH, back.get_width(), back.get_height(), read])
	quit(0 if read == GREYS else 1)
