extends SceneTree
# A6 GPU price helper (Claude), a windowed fixture measurement, not a headless test. It reads the
# viewport's measured GPU render time, which on this M1 is only reported under the Vulkan driver
# (a6/evidence/probes/gpu_time_probe.log). Run from the repository root:
#   godot --path godot --rendering-method mobile --rendering-driver vulkan --always-on-top --script res://tests/gpu_price_effects.gd
# Cases, each over FRAMES frames and REPEATS repeats, with the real level on screen at the B1 rooftop:
#   level, effects off | Effect A heaviest: 2 puffs alive at all times | Effect B heaviest: steam at
#   amount_ratio 1.0 after it has filled. The effects are instanced here as fixtures (not wired), so
#   the numbers are what drawing them costs, not what the game's drivers do.
const JumpPuff := preload("res://effects/jump_puff.tscn")
const HoseSteam := preload("res://effects/hose_steam.tscn")
const FRAMES := 240
const REPEATS := 3
const PUFF_AT := Vector2(1240, 240)       # on the B1 roof platform, in view of the camera
const STEAM_AT := Vector2(1278, 206)      # top centre of the blocking fire at full height (B3)
var game: Node2D
var vp: RID

func _initialize() -> void:
	call_deferred("run")

func frames(n: int) -> void:
	for i in n:
		await process_frame

# Mean GPU and CPU render time (ms) over FRAMES frames. `tick` runs once per frame for live cases.
func sample(tick: Callable) -> Vector2:
	var gpu := 0.0
	var cpu := 0.0
	for i in FRAMES:
		tick.call(i)
		await process_frame
		gpu += RenderingServer.viewport_get_measured_render_time_gpu(vp)
		cpu += RenderingServer.viewport_get_measured_render_time_cpu(vp)
	return Vector2(gpu, cpu) / FRAMES

func report(label: String, runs: Array) -> void:
	var g: Array = runs.map(func(v): return v.x)
	var c: Array = runs.map(func(v): return v.y)
	print("%-28s GPU mean %.4f ms (min %.4f, max %.4f) | CPU render mean %.4f ms" % [label, g.reduce(func(a, b): return a + b) / g.size(), g.min(), g.max(), c.reduce(func(a, b): return a + b) / c.size()])

func run() -> void:
	print("rendering method: ", RenderingServer.get_current_rendering_method(), ", adapter: ", RenderingServer.get_video_adapter_name())
	game = (load("res://game/main.tscn") as PackedScene).instantiate()
	game.test_mode = true
	root.add_child(game)
	await frames(2)
	game.camera.position = Vector2(1310, 180)
	game.hud.visible = false
	vp = root.get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(vp, true)
	await frames(60)
	var off := []
	for r in REPEATS:
		off.append(await sample(func(_i): pass))
	report("level, effects off", off)
	# Effect A: a new puff every 0.45 s keeps two alive at all times (CHANGE-BRIEF A-R3 peak).
	var puffs := []
	for r in REPEATS:
		puffs.append(await sample(func(i):
			if i % 27 == 0:
				var p: Node2D = JumpPuff.instantiate()
				p.position = PUFF_AT
				game.add_child(p)
				create_timer(0.9).timeout.connect(p.queue_free)))
	report("Effect A, 2 puffs alive", puffs)
	await frames(60)
	var steam: Node2D = HoseSteam.instantiate()
	steam.position = STEAM_AT
	game.add_child(steam)
	for e in steam.get_children():
		e.amount_ratio = 1.0
		e.emitting = true
	await frames(120)                     # fill: longer than the 1.6 s Haze lifetime at 60+ fps
	var steamed := []
	for r in REPEATS:
		steamed.append(await sample(func(_i): pass))
	report("Effect B, ratio 1.0, filled", steamed)
	quit()
