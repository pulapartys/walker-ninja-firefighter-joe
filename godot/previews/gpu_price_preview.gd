extends Node2D
# A6 GPU price fixture for the editor's Visual Profiler (Claude). A normal scene, so a run started with
# --remote-debug is a full debugger session (a --script run connects but the editor gives it no
# profiler). It instances the real level and the two effects and plays three phases by itself, so a
# person only needs to press Start / Stop in the Visual Profiler:
#   godot --path godot --remote-debug tcp://127.0.0.1:6007 --rendering-method mobile --rendering-driver vulkan res://previews/gpu_price_preview.tscn -- wait=20
# Phases (PHASE_S each): level, effects off | Effect A, two puffs alive at all times | Effect B,
# steam at amount_ratio 1.0. The console prints when each starts; the window title shows it too.
const JumpPuff := preload("res://effects/jump_puff.tscn")
const HoseSteam := preload("res://effects/hose_steam.tscn")
const PHASE_S := 12.0
const PUFF_AT := Vector2(1240, 240)
const STEAM_AT := Vector2(1278, 206)
@onready var game: Node2D = $WalkerJumpman
var steam: Node2D

func _ready() -> void:
	game.test_mode = true
	game.hud.visible = false
	run()

func phase(label: String) -> void:
	print("phase: ", label)
	DisplayServer.window_set_title("GPU price: " + label)

func run() -> void:
	var wait := 0.0
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("wait="):
			wait = float(arg.substr(5))
	game.camera.position = Vector2(1310, 180)
	phase("waiting %d s - press Start in the Visual Profiler" % int(wait))
	await get_tree().create_timer(wait).timeout
	phase("1 of 3: effects off")
	await get_tree().create_timer(PHASE_S).timeout
	phase("2 of 3: Effect A, two puffs alive")
	var t := 0.0
	while t < PHASE_S:
		var p: Node2D = JumpPuff.instantiate()
		p.position = PUFF_AT
		game.add_child(p)
		get_tree().create_timer(0.9).timeout.connect(p.queue_free)
		await get_tree().create_timer(0.45).timeout
		t += 0.45
	await get_tree().create_timer(1.0).timeout
	phase("3 of 3: Effect B, steam at ratio 1.0")
	steam = HoseSteam.instantiate()
	steam.position = STEAM_AT
	game.add_child(steam)
	for e in steam.get_children():
		e.amount_ratio = 1.0
		e.emitting = true
	await get_tree().create_timer(PHASE_S).timeout
	phase("done - press Stop in the Visual Profiler")
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()

func _process(_delta: float) -> void:
	game.camera.position.x = 1310.0   # the session's physics moves it with the player each tick
