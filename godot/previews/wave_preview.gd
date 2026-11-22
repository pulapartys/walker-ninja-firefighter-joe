extends Node2D
# A7 viewing fixture for the person survivor's wave (CHANGE-BRIEF "The evidence split": "the wave reads,
# wraps with no hitch"). It runs the real game scene and zooms the game's own camera onto the person's
# window, so the wave can be watched for as many wraps as wanted at normal speed (or with
# --time-scale 0.25). Fixture writes a player can't make: it starts the session, stands Joe left of
# the fire, and sets the camera's zoom and offset. It never touches the rig or its clip.
# Run (windowed): godot --path godot res://previews/wave_preview.tscn

const Main = preload("res://game/main.tscn")
const STAND := Vector2(1235, 240)   # left of the blocking fire; the session centres the camera 100 px ahead of him
var game: Node2D

func _ready() -> void:
	game = Main.instantiate()
	game.test_mode = true
	add_child(game)
	game.start_session()
	game.player.position = STAND
	game.camera.zoom = Vector2(3, 3)
	game.camera.offset = Vector2(0, 40)
