extends SceneTree
func _initialize() -> void:
	for cls in ["ParticleProcessMaterial", "CPUParticles2D"]:
		for p in ClassDB.class_get_property_list(cls):
			if p.name in ["initial_velocity", "scale", "Initial Velocity", "Scale"] or String(p.name).begins_with("initial_velocity"):
				print(cls, " name=", p.name, " usage=", p.usage, " group=", (p.usage & PROPERTY_USAGE_GROUP) != 0, " subgroup=", (p.usage & PROPERTY_USAGE_SUBGROUP) != 0, " hint_string=", p.hint_string)
	var m := ParticleProcessMaterial.new()
	print("get initial_velocity -> ", m.get("initial_velocity"))
	m.set("initial_velocity", 123.0)
	print("after set: min=", m.initial_velocity_min, " max=", m.initial_velocity_max, " get=", m.get("initial_velocity"))
	quit()
