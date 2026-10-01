extends RefCounted
## Scripted LINEAR route through the two-building level, now with the hose:
## approach -> climb B1 -> HOSE the blocking fire at the person's window -> rescue person
## -> descent -> burning-street jump -> climb B2 (rescue dog) -> B2 rooftop exit.
## No position/velocity edits -- only inputs, like a player.
var right_marks: Array[float] = [138.0, 292.0, 424.0, 548.0, 712.0, 955.0, 1010.0, 1112.0, 1445.0, 1540.0, 1642.0, 1815.0, 1902.0]
var next_jump: int = 0
var hosed: bool = false
var hose_wait: int = 0

func step(player: CharacterBody2D) -> void:
	player.test_control = true
	player.test_jump_held = false
	player.test_water_pressed = false
	# On B1's window ledge (in the ~40px runway before the fire), hose it, then wait ~4 s.
	if not hosed and player.is_on_floor() and player.position.y > 232.0 and player.position.y < 248.0 and player.position.x > 1188.0 and player.position.x < 1245.0:
		player.test_water_pressed = true
		hosed = true
		hose_wait = 255
	if hose_wait > 0:
		hose_wait -= 1
		player.test_axis = 0.0  # stand still in the runway while the water pours
		return
	player.test_axis = 1.0
	if next_jump < right_marks.size() and player.position.x >= right_marks[next_jump] and player.is_on_floor():
		player.test_jump_pressed = true
		next_jump += 1
