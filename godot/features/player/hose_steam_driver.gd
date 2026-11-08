extends Node
# Hose steam driver (CHANGE-BRIEF B1, B4, Revision 5). Presentation only: it reads player.hosing,
# session.fire_height() and session.level, and writes `emitting`, `amount_ratio` and the HoseSteam
# root's position. It never writes game state, `amount` or `visible` (B-R6).
# Every effect setting lives in res://effects/hose_steam.tscn; this only instances, places and drives.
const HoseSteam := preload("res://effects/hose_steam.tscn")
var session: Node2D
var steam: Node2D
var emitters: Array[GPUParticles2D] = []

func _ready() -> void:
	name = "HoseSteamDriver"
	var player: Node2D = get_parent()
	session = player.get_parent()                      # WalkerJumpman: the root's position is in level coordinates (B-R4)
	if not session.level.has("blocking_fire"):
		set_process(false)
		return
	steam = HoseSteam.instantiate()
	for emitter in steam.get_children():
		emitters.append(emitter)
	steam.position = _fire_top()                       # at the fire before it ever emits, so nothing is released from (0, 0)
	session.add_child(steam)
	# Revision 5 (B-R8): just before him in the level's child order, so it draws over the level's own
	# _draw() (the fire and the water stream) and behind Extinguisho. Not z_index, as jump_puff_driver.gd.
	session.move_child(steam, player.get_index())

# _process runs after this frame's physics ticks, so it sees the session's fresh `hosing` and fire.
# Position and amount_ratio are written first, so the first emitting frame starts at the fire top at
# the fire's strength. A tree pause stops this with the session, whose values then hold (B-R5).
func _process(_delta: float) -> void:
	var hosing: bool = get_parent().hosing
	steam.position = _fire_top()                                                                    # B-R4
	var ratio := clampf(session.fire_height() / float(session.level.blocking_fire[3]), 0.0, 1.0)  # B-R3
	for emitter in emitters:
		emitter.amount_ratio = ratio
		# B-R1, B-R2: written on a change only. Stopping is `emitting = false` alone (no restart, hide
		# or free), so steam already in the air finishes its life.
		if emitter.emitting != hosing:
			emitter.emitting = hosing

func _fire_top() -> Vector2:
	var fire: Array = session.level.blocking_fire
	return Vector2(float(fire[0]) + float(fire[2]) / 2.0, float(fire[1]) + float(fire[3]) - session.fire_height())
