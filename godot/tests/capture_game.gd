extends SceneTree
const Game = preload("res://game/session.gd")
const Route = preload("res://tests/route_driver.gd")
var game: Node2D
var output: String

func _initialize() -> void:
	call_deferred("run")

func step() -> void:
	await physics_frame
	await process_frame

func capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png(output + "/" + label + ".png")
	assert(error == OK)
	print("Captured rendered game viewport: " + label)

func run() -> void:
	output = ProjectSettings.globalize_path("res://../evidence/screens")
	DirAccess.make_dir_recursive_absolute(output)
	game = Game.new()
	game.test_mode = true
	root.add_child(game)
	for i in range(3): await step()
	await capture("01-menu")
	game.start_session()
	game.player.test_control = true
	game.player.test_axis = 1
	# Walk from a safe landing into the spike trigger, not an invented failure card.
	game.player.position = Vector2(275, 320)
	for i in range(90):
		await step()
		if game.state == Game.State.DYING: break
	assert(game.state == Game.State.DYING)
	await capture("02-failure")
	await capture("state-burned")
	game.state = Game.State.MENU
	game.start_session()
	# Retry stance, then idle after standing still for a moment (no input).
	game.player.test_axis = 0.0
	await step()
	await capture("state-respawn")
	for i in range(35): await step()
	await capture("state-idle")
	# Orientation: run right, then left (the art mirrors at runtime), and stand facing left.
	game.player.test_axis = 1.0
	for i in range(30): await step()
	game.player.test_axis = -1.0
	for i in range(15): await step()
	await capture("facing-left-run")
	game.player.test_axis = 0.0
	for i in range(40): await step()
	await capture("facing-left-idle")
	game.restart_attempt()
	await step()
	var route = Route.new()
	var gap_captured := false
	var seen := {}
	# 3000 ticks, as in test_game.gd: the route now waits ~4 s for the hose, so 900 was too short.
	for i in range(3000):
		route.step(game.player)
		await step()
		if not gap_captured and game.player.position.x > 463 and game.player.position.y < 300:
			await capture("03-jump")
			gap_captured = true
		# First real occurrence of each character state image during the route.
		if not seen.has(game.player.pose):
			seen[game.player.pose] = true
			await capture("state-" + game.player.pose)
		if game.state != Game.State.PLAYING: break
	print("ROUTE END state=%d deaths=%d pos=%s reason=%s rescued=%d" % [game.state, game.deaths, str(game.player.position), game.death_reason, game.rescued_count])
	assert(game.state == Game.State.COMPLETE, "Input route did not complete")
	await capture("04-complete")
	await capture("state-celebrate")
	print("VISUAL ROUTE: completed with %d deaths" % game.deaths)
	game.queue_free()
	await process_frame
	quit()
