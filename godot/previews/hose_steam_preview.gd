extends Node2D
# A6 Effect B frame-strip fixture (CHANGE-BRIEF B5). Not part of the game.
# It instances the real level (res://game/main.tscn) and starts a session with `test_mode` on (a
# focus loss doesn't pause it) and the player under test control (no key moves him). He stands on
# B1's roof at x 1215, facing the blocking fire and in hose range; the session puts the camera at
# x 1315 (player.x + 100, y stays 180). The HUD is hidden, as in the jump puff preview.
# Condition: on frame 10 it presses W through the player's hook (`test_water_pressed`, as
# test_game.gd does), so the session's own counters run it, and the fire shrinks and goes out as in
# play. The session counts the press tick as the first of its 240 / 300, so the press is made on
# frame 10's last physics tick: under --fixed-fps 30 (two ticks per frame) `player.hosing` is then
# first true on frame 10, the fire is out on frame 130 and `hosing` is false from frame 160.
# The steam is the game's own: the HoseSteam that hose_steam_driver.gd adds to the level node, just
# before Extinguisho in its child order (Revision 5), and drives from `player.hosing` and
# `fire_height()` (B-R1 to B-R4). The preview writes nothing on it but fixed seeds (CHANGE-BRIEF B3,
# preview only), set here before it first emits. It runs after the driver in each frame
# (process_priority 1), so its console lines report the values the driver wrote that frame.
# Frame N here is the preview's N-th drawn frame, counted from 0 (file N of a Movie Maker strip).
# Capture with a window (30 fps):
#   godot --path godot --write-movie <absolute dir>/frame.png --fixed-fps 30 --quit-after 210 --always-on-top res://previews/hose_steam_preview.tscn
const STAND := Vector2(1215, 240)   # B1 roof (x 1175-1365, top at y 240), left of the fire at x 1250-1306
const TRIGGER_FRAME := 10
const SEED := 1278  # preview only (CHANGE-BRIEF B3): fixed seeds on the driver's instance in this scene
@onready var game: Node2D = $WalkerJumpman
var emitters: Array[GPUParticles2D] = []
var frame := 0                     # frames drawn so far
var ticks_in_frame := 0            # physics ticks run so far in this frame
var ticks_per_frame := 1           # from the last frame's delta: 2 under --fixed-fps 30
var pressed := false
var was_hosing := false
var was_fire_active := true

func _ready() -> void:
	process_priority = 1               # after the driver's _process (priority 0)
	game.test_mode = true
	game.start_session()
	game.player.test_control = true
	game.player.reset_at(STAND)
	game.player.action_queue.clear()   # reset_at's 0.5 s respawn stance; in play he walks up to the fire
	game.camera.position = Vector2(STAND.x + 100.0, 180.0)
	game.hud.visible = false
	var steam: Node2D = game.player.get_node("HoseSteamDriver").steam
	for i in steam.get_child_count():
		var emitter: GPUParticles2D = steam.get_child(i)
		emitter.use_fixed_seed = true
		emitter.seed = SEED + i
		emitters.append(emitter)

func _physics_process(_delta: float) -> void:
	ticks_in_frame += 1
	# `>=`, not `==`: in a live window ticks and drawn frames are not one-to-one, so the press falls
	# on the first tick that reaches the count, on frame 10 or just after.
	if not pressed and frame >= TRIGGER_FRAME and ticks_in_frame >= ticks_per_frame:
		game.player.test_water_pressed = true   # the session reads it later in this same tick
		pressed = true

func _process(delta: float) -> void:
	var hosing: bool = game.player.hosing
	if hosing != was_hosing:
		print("preview: hosing %s on frame %d (fire height %.2f, amount_ratio %.3f)" % [hosing, frame, game.fire_height(), emitters[0].amount_ratio])
		was_hosing = hosing
	if game.fire_active != was_fire_active:
		print("preview: fire out on frame %d" % frame)
		was_fire_active = game.fire_active
	frame += 1
	ticks_in_frame = 0
	ticks_per_frame = maxi(1, roundi(delta * Engine.physics_ticks_per_second))
