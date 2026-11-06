extends SceneTree
var cpu_finished := 0
var gpu_finished := 0
func _initialize() -> void:
	call_deferred("run")
func ptype(cls: String, prop: String) -> String:
	for p in ClassDB.class_get_property_list(cls):
		if p.name == prop:
			return "%s(type=%d hint=%s)" % [prop, p.type, p.hint_string]
	return prop + " MISSING"
func run() -> void:
	print("rendering method: ", RenderingServer.get_current_rendering_method(), " adapter: '", RenderingServer.get_video_adapter_name(), "'")
	print(ptype("CPUParticles2D", "color_ramp"), " ", ptype("CPUParticles2D", "scale_amount_curve"))
	print(ptype("ParticleProcessMaterial", "color_ramp"), " ", ptype("ParticleProcessMaterial", "scale_curve"))
	for cls in ["CPUParticles2D", "GPUParticles2D"]:
		print(cls, " signal finished=", ClassDB.class_has_signal(cls, "finished"), " restart()=", ClassDB.class_has_method(cls, "restart"))
	print("GPU defaults: fixed_fps=", ClassDB.class_get_property_default_value("GPUParticles2D", "fixed_fps"), " interpolate=", ClassDB.class_get_property_default_value("GPUParticles2D", "interpolate"), " amount_ratio=", ClassDB.class_get_property_default_value("GPUParticles2D", "amount_ratio"))
	var cpu := CPUParticles2D.new()
	cpu.one_shot = true; cpu.lifetime = 0.5; cpu.amount = 8; cpu.explosiveness = 1.0
	cpu.finished.connect(func(): cpu_finished += 1)
	var gpu := GPUParticles2D.new()
	gpu.one_shot = true; gpu.lifetime = 0.5; gpu.amount = 8; gpu.explosiveness = 1.0
	gpu.process_material = ParticleProcessMaterial.new()
	gpu.finished.connect(func(): gpu_finished += 1)
	root.add_child(cpu); root.add_child(gpu)
	cpu.emitting = true; gpu.emitting = true
	var frames := 0
	while frames < 120 and (cpu_finished == 0 or gpu_finished == 0):
		await process_frame
		frames += 1
	print("after ", frames, " frames (1/60 s each): cpu finished=", cpu_finished, " emitting=", cpu.emitting, " | gpu finished=", gpu_finished, " emitting=", gpu.emitting)
	gpu.amount_ratio = 0.4
	print("gpu amount_ratio set/get: ", gpu.amount_ratio, " amount still ", gpu.amount)
	quit()
