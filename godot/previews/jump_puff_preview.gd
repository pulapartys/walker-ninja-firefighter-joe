extends Node2D
# A6 Effect A frame-strip fixture (CHANGE-BRIEF A5). Not part of the game.
# It instances the real level (res://game/main.tscn, left in MENU so nothing moves and the player
# stays at the spawn, off camera) for the B1 rooftop art, puts the session's camera where the game
# puts it for a player at x 1105 (session.gd: x = player.x + 100, y stays 180), hides the HUD (in
# MENU its tint and card sit over the art), and adds a JumpPuff to the level node at (1105, 280)
# on frame 10, and again on frame 25 when `retrigger` is on. Each puff is added in a physics tick,
# as `jumped` is emitted in the game, so it is simulated and drawn in that same frame.
# Frame N here is the preview's N-th drawn frame, counted from 0 (file N of a Movie Maker strip).
# Capture with a window (30 fps): add `-- retrigger` to the command to turn the export on.
#   godot --path godot --write-movie <absolute dir>/frame.png --fixed-fps 30 --quit-after 60 res://previews/jump_puff_preview.tscn
# Watching by eye (no capture): `-- loop` adds an unseeded puff every LOOP_SECONDS of game time, so
# repeats show the brief's variation; each loop puff is freed after LOOP_SECONDS.
const JumpPuff = preload("res://effects/jump_puff.tscn")
const AT := Vector2(1105, 280)                  # on the B1 ledge (x 1060-1150, top at y 280)
const CAMERA := Vector2(AT.x + 100.0, 180.0)
const TRIGGER_FRAME := 10
const RETRIGGER_FRAME := 25
const SEEDS := [1105, 2805]  # preview only (CHANGE-BRIEF A3): fixed seeds on this scene's own instances
const LOOP_SECONDS := 1.2
@export var retrigger := false
@export var loop := false
@onready var game: Node2D = $WalkerJumpman
var frame := 0               # frames drawn so far
var fired := 0
var loop_clock := 0.0

func _ready() -> void:
	if "retrigger" in OS.get_cmdline_user_args():
		retrigger = true
	if "loop" in OS.get_cmdline_user_args():
		loop = true
	game.camera.position = CAMERA
	game.hud.visible = false

func _physics_process(delta: float) -> void:
	if loop:
		loop_clock += delta
		if loop_clock >= LOOP_SECONDS:
			loop_clock = 0.0
			_spawn_loop()
		return
	var due := [TRIGGER_FRAME, RETRIGGER_FRAME] if retrigger else [TRIGGER_FRAME]
	# `>=`, not `==`: in a live window the physics ticks and drawn frames are not one-to-one, so a
	# tick can miss frame N exactly. Under --fixed-fps 30 every frame runs two ticks, so the first
	# tick of frame N fires, as before.
	if fired < due.size() and frame >= due[fired]:
		_spawn(SEEDS[fired])
		fired += 1

func _spawn_loop() -> void:
	var puff: Node2D = JumpPuff.instantiate()
	puff.position = AT
	game.add_child(puff)
	get_tree().create_timer(LOOP_SECONDS).timeout.connect(puff.queue_free)

func _process(_delta: float) -> void:
	frame += 1

func _spawn(seed_base: int) -> void:
	var puff: Node2D = JumpPuff.instantiate()
	var live := []
	for i in puff.get_child_count():
		var emitter: CPUParticles2D = puff.get_child(i)
		emitter.use_fixed_seed = true
		emitter.seed = seed_base + i
		live.append(emitter.emitting)
	puff.position = AT
	game.add_child(puff)
	print("preview: JumpPuff %d added at %s on frame %d (emitting %s, seeds from %d)" % [fired + 1, AT, frame, live, seed_base])
