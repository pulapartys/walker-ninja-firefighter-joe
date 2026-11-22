extends Node2D
# A7 frame-strip fixture for Joe's toss (CHANGE-BRIEF "The frame strip"). It runs the real game scene
# over the real level art at the person's window and lets a real D key walk Joe into the survivor, so
# the rescue and the toss happen in the game loop. Fixture writes a player can't make: it starts the
# session, puts the blocking fire out and places Joe on B1's roof left of the window. It never touches
# a clip, the sprite or the rig. One log line per drawn frame goes to logs/toss_preview_<run>.log.
# Capture (windowed): godot --path godot res://previews/toss_preview.tscn --write-movie
#   "$PWD/captures/toss/r0/frame.png" --fixed-fps 30 --quit-after 90 -- r0

const Main = preload("res://game/main.tscn")
const START := Vector2(1286, 240)   # on B1's roof, where the fire was, left of the person's window
const WALK_AFTER := 20              # drawn frames of standing (the wave plays) before D is pressed
var game: Node2D
var frame := 0
var touch_tick := -1
var walking := false
var log_file: FileAccess

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var run := args[0] if args.size() > 0 else "r0"
	var path := ProjectSettings.globalize_path("res://").path_join("../logs/toss_preview_%s.log" % run)
	log_file = FileAccess.open(path, FileAccess.WRITE)
	if log_file == null:
		push_error("toss_preview: cannot write %s (error %d)" % [path, FileAccess.get_open_error()])
	game = Main.instantiate()
	game.test_mode = true
	add_child(game)
	game.start_session()
	game.fire_active = false
	game.player.position = START
	game.player.action_queue.clear()   # reset_at's respawn stance; in play he walks up to the window
	_write("frame\ttick_since_touch\tclip\tclip_time\tsprite_frame\tbag_pose\tpose\tlaunched\tshoulder_rotation\tplayer_x")

func _process(_delta: float) -> void:
	frame += 1
	if frame == WALK_AFTER:
		_key(KEY_D, true)
		walking = true
	if walking and game.rescued_count > 0:
		_key(KEY_D, false)
		walking = false
	if touch_tick < 0 and game.rescued_count > 0:
		touch_tick = _touch_tick()
	var since := Engine.get_physics_frames() - touch_tick if touch_tick >= 0 else -1
	var a: AnimationPlayer = game.player.anim
	var rig: Node2D = game.survivors[0].rig
	var launched: bool = game.flights.size() > 0 and game.flights[0].has("launch")
	_write("%d\t%d\t%s\t%.4f\t%d\t%s\t%s\t%s\t%.3f\t%.1f" % [frame, since, a.assigned_animation,
		a.current_animation_position, game.player.sprite.frame, game.player.bag_pose(), game.player.pose,
		launched, rig.get_node("Shoulder").rotation, game.player.position.x])

# The physics frame of the touch: the toss clip's position counts the ticks since it, by construction
# (CHANGE-BRIEF "The two clocks").
func _touch_tick() -> int:
	return Engine.get_physics_frames() - roundi(game.player.anim.current_animation_position * 60.0)

func _key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func _write(line: String) -> void:
	if log_file:
		log_file.store_line(line)
		log_file.flush()
