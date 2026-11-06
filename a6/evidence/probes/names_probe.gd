extends SceneTree
func _initialize() -> void:
	var want := {
		"CPUParticles2D": ["amount","one_shot","explosiveness","lifetime","lifetime_randomness","randomness","local_coords","preprocess","emission_shape","emission_sphere_radius","direction","spread","initial_velocity_min","initial_velocity_max","gravity","damping_min","damping_max","scale_amount_min","scale_amount_max","scale_amount_curve","color","color_ramp","color_initial_ramp","angle_min","angle_max","angular_velocity_min","angular_velocity_max","hue_variation_min","hue_variation_max","texture","use_fixed_seed","seed","speed_scale","amount_ratio","initial_velocity","scale_amount"],
		"GPUParticles2D": ["amount","amount_ratio","one_shot","explosiveness","lifetime","randomness","local_coords","preprocess","fixed_fps","interpolate","visibility_rect","texture","process_material","use_fixed_seed","seed","speed_scale","trail_enabled","draw_order"],
		"ParticleProcessMaterial": ["emission_shape","emission_box_extents","direction","spread","initial_velocity_min","initial_velocity_max","gravity","damping_min","damping_max","turbulence_enabled","turbulence_noise_strength","turbulence_noise_scale","turbulence_noise_speed","turbulence_influence_min","turbulence_influence_max","scale_min","scale_max","scale_curve","color","color_ramp","hue_variation_min","angle_min","angle_max","particle_flag_disable_z","initial_velocity","scale"],
		"CanvasItemMaterial": ["blend_mode","particles_animation"],
		"GradientTexture2D": ["fill","fill_from","fill_to","width","height","gradient"],
	}
	for cls in want:
		var have := {}
		for p in ClassDB.class_get_property_list(cls):
			have[p.name] = true
		var missing := []
		for n in want[cls]:
			if not have.has(n):
				missing.append(n)
		print(cls, " missing: ", missing)
	var c := CPUParticles2D.new()
	print("CPUParticles2D defaults: emission_shape=", c.emission_shape, " spread=", c.spread, " gravity=", c.gravity, " direction=", c.direction, " local_coords=", c.local_coords)
	print("EMISSION_SHAPE_SPHERE=", CPUParticles2D.EMISSION_SHAPE_SPHERE, " BOX=", ParticleProcessMaterial.EMISSION_SHAPE_BOX)
	c.free()
	quit()
