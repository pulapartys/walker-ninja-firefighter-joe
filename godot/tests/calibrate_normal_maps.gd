extends SceneTree
# A5: calibrates tests/normal_map_check.gd on the Poly Haven _nor_gl / _nor_dx pair of the same
# material (CHANGE-BRIEF C2, Assignment 5 Step 3). Expected: the GL file low with directx=false and
# near 2 with directx=true; the DX file the other way round. Reversed results mean the sign
# convention is backwards (then flip s and say so in TEST-REPORT.md).
#   ./scripts/run-test.sh calibrate_normal_maps.gd 60
const Check = preload("res://tests/normal_map_check.gd")
const DIR := "res://art/textures/rusty_metal_sheet/"
const FILES := {"gl": "rusty_metal_sheet_nor_gl_1k.png", "dx": "rusty_metal_sheet_nor_dx_1k.png"}
const STRIDE := 4

func _initialize() -> void:
	var failures := 0
	var ratios := {}
	for key in FILES:
		var img := Image.load_from_file(ProjectSettings.globalize_path(DIR + FILES[key]))
		if img == null:
			print("FAIL load %s" % FILES[key])
			failures += 1
			continue
		var r_gl := Check.curl_ratio(img, false, STRIDE)
		var r_dx := Check.curl_ratio(img, true, STRIDE)
		ratios[key] = {"as_gl": r_gl, "as_dx": r_dx}
		print("%s file: %dx%d format=%d  curl_ratio directx=false: %.4f  directx=true: %.4f" % [key, img.get_width(), img.get_height(), img.get_format(), r_gl, r_dx])
	var ok_gl: bool = ratios.has("gl") and ratios.gl.as_gl < ratios.gl.as_dx
	var ok_dx: bool = ratios.has("dx") and ratios.dx.as_dx < ratios.dx.as_gl
	print("%s calibration: GL file reads as GL (%s), DX file reads as DX (%s)" % ["PASS" if ok_gl and ok_dx else "FAIL", ok_gl, ok_dx])
	if not (ok_gl and ok_dx):
		failures += 1
	print("NORMAL MAP CALIBRATION: %d failures (stride %d)" % [failures, STRIDE])
	quit(1 if failures else 0)
