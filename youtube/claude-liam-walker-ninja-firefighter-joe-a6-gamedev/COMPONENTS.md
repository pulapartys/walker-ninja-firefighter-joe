# COMPONENTS

Godot project components covered by the film (`godot/`, hashed in gamedev-evidence.json).

## landing-puff

Effect A, the landing puff: three CPUParticles2D emitters in one scene file with a scene-defined texture (ATTRIBUTION.md), the driver that adds a fresh puff behind Extinguisho on every landed signal, the player script's landed signal and driver hooks, the preview fixture, and its configuration and state tests.

Files (8): `effects/ATTRIBUTION.md`, `effects/jump_puff.tscn`, `features/player/jump_puff_driver.gd`, `features/player/player.gd`, `previews/jump_puff_preview.gd`, `previews/jump_puff_preview.tscn`, `tests/test_jump_puff_config.gd`, `tests/test_jump_puff_state.gd`

Beats: B04, B05, B06, B07, B08, B13

## hose-steam

Effect B, the hose steam: two GPUParticles2D emitters with turbulence and a box emitter in one scene file, the driver that writes emitting, amount_ratio from the fire's height and the position, the preview fixture, and its configuration and state tests.

Files (6): `effects/hose_steam.tscn`, `features/player/hose_steam_driver.gd`, `previews/hose_steam_preview.gd`, `previews/hose_steam_preview.tscn`, `tests/test_hose_steam_config.gd`, `tests/test_hose_steam_state.gd`

Beats: B09, B10, B11, B13

## process-shader

The process step as a shader: Godot's own code generated from a unique copy of the steam's ParticleProcessMaterial (converted by Sreeja in the editor), the scratch scene that holds the copy, and the helper that wrote it; nothing in the game uses them.

Files (3): `previews/scratch_process_material.tscn`, `shaders/particles_generated.gdshader`, `tests/make_scratch_process_material.gd`

Beats: B12

## price

The price instruments: the headless CPU cost script with its empty-scene control, the windowed GPU-time helper and the self-playing fixture used with the Visual Profiler under Mobile + Vulkan, and the F9 vsync debug key.

Files (5): `features/debug/vsync_key.gd`, `previews/gpu_price_preview.gd`, `previews/gpu_price_preview.tscn`, `tests/cost_effects.gd`, `tests/gpu_price_effects.gd`

Beats: B14

## earlier-layers

The game this layer is added to: the A2 2D game (session, level, HUD, generated art and audio, its tests and project settings), the A3 props room and the A5 shaders, materials, textures and their tests; unchanged in A6 except the player's landed signal and driver hooks.

Files (101): `MATERIALS.md`, `art/character/anchors.json`, `art/character/burned.png`, `art/character/burned.png.import`, `art/character/celebrate.png`, `art/character/celebrate.png.import`, `art/character/celebrate_portrait.png`, `art/character/celebrate_portrait.png.import`, `art/character/devastated_portrait.png`, `art/character/devastated_portrait.png.import`, `art/character/falling.png`, `art/character/falling.png.import` …

Beats: B02, B11

