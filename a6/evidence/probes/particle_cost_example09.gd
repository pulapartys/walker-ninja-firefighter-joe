extends SceneTree

const AMOUNTS := [1000, 10000, 50000]
const WARM_UP_FRAMES := 60
const TIMED_FRAMES := 300
const REPEATS := 3


func _initialize() -> void:
	call_deferred("run")


func wait_frames(count: int) -> void:
	for _frame in count:
		await process_frame


func time_frames(count: int) -> float:
	var started_usec := Time.get_ticks_usec()
	await wait_frames(count)
	var elapsed_usec := Time.get_ticks_usec() - started_usec
	return elapsed_usec / 1000.0 / count


func make_gpu_particles(amount: int) -> GPUParticles2D:
	var material := ParticleProcessMaterial.new()
	material.initial_velocity_min = 50.0
	material.initial_velocity_max = 100.0
	material.gravity = Vector3(0.0, 98.0, 0.0)

	var particles := GPUParticles2D.new()
	particles.amount = amount
	particles.lifetime = 1.0
	particles.process_material = material
	particles.emitting = true
	return particles


func make_cpu_particles(amount: int) -> CPUParticles2D:
	var particles := CPUParticles2D.new()
	particles.amount = amount
	particles.lifetime = 1.0
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 100.0
	particles.gravity = Vector2(0.0, 98.0)
	particles.emitting = true
	return particles


func benchmark_case(container: Node2D, type_name: String, amount: int) -> void:
	var means: Array[float] = []
	for _repeat in REPEATS:
		var emitter: Node2D
		if type_name == "GPUParticles2D":
			emitter = make_gpu_particles(amount)
		else:
			emitter = make_cpu_particles(amount)

		container.add_child(emitter)
		await wait_frames(WARM_UP_FRAMES)
		means.append(await time_frames(TIMED_FRAMES))
		emitter.queue_free()
		await wait_frames(2)

	var total := 0.0
	for value in means:
		total += value
	print(
		"%s amount=%d: min=%.6f ms/frame, mean=%.6f ms/frame, max=%.6f ms/frame"
		% [type_name, amount, means.min(), total / means.size(), means.max()]
	)


func run() -> void:
	print("Rendering method: ", RenderingServer.get_current_rendering_method())
	print("Video adapter: ", RenderingServer.get_video_adapter_name())
	print("Headless Godot uses a dummy renderer, so GPU particle simulation and all drawing are not measured.")

	var container := Node2D.new()
	root.add_child(container)
	await wait_frames(WARM_UP_FRAMES)
	var baseline := await time_frames(TIMED_FRAMES)
	print("Empty scene baseline: %.6f ms/frame" % baseline)

	for type_name in ["GPUParticles2D", "CPUParticles2D"]:
		for amount in AMOUNTS:
			await benchmark_case(container, type_name, amount)

	container.queue_free()
	await process_frame
	quit()
