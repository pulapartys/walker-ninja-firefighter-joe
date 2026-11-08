extends SceneTree
# Windowed probe: does this machine report GPU time for 2D particles? Run with a window and a
# renderer override, e.g. --rendering-method mobile. Prints the viewport's measured GPU and CPU
# render time over 120 frames with no particles, then with 20,000 GPU particles on screen.
func _initialize() -> void:
	call_deferred("run")

func measure(label: String) -> void:
	var vp := root.get_viewport_rid()
	var gpu := 0.0
	var cpu := 0.0
	for i in 120:
		await process_frame
		gpu += RenderingServer.viewport_get_measured_render_time_gpu(vp)
		cpu += RenderingServer.viewport_get_measured_render_time_cpu(vp)
	print("%s: mean GPU %.4f ms, mean CPU %.4f ms over 120 frames" % [label, gpu / 120.0, cpu / 120.0])

func run() -> void:
	print("rendering method: ", RenderingServer.get_current_rendering_method(), ", adapter: ", RenderingServer.get_video_adapter_name())
	RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(), true)
	await measure("empty")
	var p := GPUParticles2D.new()
	p.amount = 20000
	p.lifetime = 2.0
	p.position = Vector2(320, 180)
	var m := ParticleProcessMaterial.new()
	m.initial_velocity_min = 20.0
	m.initial_velocity_max = 120.0
	m.spread = 180.0
	m.gravity = Vector3.ZERO
	m.particle_flag_disable_z = true
	m.scale_min = 4.0
	m.scale_max = 8.0
	p.process_material = m
	root.add_child(p)
	await measure("20000 GPU particles")
	quit()
