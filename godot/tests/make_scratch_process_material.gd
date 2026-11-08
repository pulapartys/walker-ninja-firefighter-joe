extends SceneTree
# A6 Step 6 helper (Claude): writes res://previews/scratch_process_material.tscn, a scratch scene with
# one GPUParticles2D whose ParticleProcessMaterial is a deep, unique copy of hose_steam.tscn's Steam
# material, so converting it in the editor never touches the effect. Nothing in the game uses it.
func _initialize() -> void:
	var steam := (load("res://effects/hose_steam.tscn") as PackedScene).instantiate()
	var src := steam.get_node("Steam") as GPUParticles2D
	var root := Node2D.new()
	root.name = "ScratchProcessMaterial"
	var copy := GPUParticles2D.new()
	copy.name = "ScratchSteam"
	copy.emitting = false
	copy.amount = src.amount
	copy.lifetime = src.lifetime
	copy.texture = src.texture
	copy.process_material = src.process_material.duplicate(true)
	root.add_child(copy)
	copy.owner = root
	var packed := PackedScene.new()
	var err := packed.pack(root)
	if err == OK:
		err = ResourceSaver.save(packed, "res://previews/scratch_process_material.tscn")
	print("scratch scene: ", error_string(err), "; material is a copy: ", copy.process_material != src.process_material)
	steam.free()
	root.free()
	quit(0 if err == OK else 1)
