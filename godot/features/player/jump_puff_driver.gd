extends Node
# Jump puff driver (CHANGE-BRIEF A1, A4, Revision 1). Presentation only: it reads player.jumped and
# the player's global_position and adds a JumpPuff to the level node. It never writes game state.
# Every effect setting lives in res://effects/jump_puff.tscn; this only instances, places and frees.
const JumpPuff := preload("res://effects/jump_puff.tscn")

func _ready() -> void:
	name = "JumpPuffDriver"
	get_parent().jumped.connect(_on_jumped)

# A-R3 overlap: every jump adds a new, full puff; earlier puffs are never touched.
func _on_jumped() -> void:
	var player: Node2D = get_parent()
	var level: Node2D = player.get_parent()                  # WalkerJumpman (A-R6), never the player
	var puff: Node2D = JumpPuff.instantiate()
	puff.position = level.to_local(player.global_position)   # A-R1: his feet at the emit
	var left := [puff.get_child_count()]                     # an Array, so the lambdas below share the count
	for emitter in puff.get_children():
		emitter.finished.connect(func():
			left[0] -= 1
			if left[0] == 0:
				puff.queue_free()                            # A-R5: freed when all three have finished
		)
	level.add_child(puff)
	# Revision 1 (A-R8): just before him in the level's child order, so it draws over the level's own
	# _draw() and behind Extinguisho. Not z_index: below 0 it would also go behind the buildings.
	level.move_child(puff, player.get_index())
