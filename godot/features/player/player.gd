extends CharacterBody2D

signal jumped  # emitted once per real jump (the session plays SFX-JUMP; sound never feeds back)

const Tuning = preload("res://features/player/tuning.gd")
var tuning = Tuning.new()
var enabled: bool = false
var tick: int = 0
var last_floor_tick: int = -1000
var jump_request_tick: int = -1000
var opportunity_consumed: bool = false
var require_jump_release: bool = true
var facing: float = 1.0
var rescued: int = 0  # survivors in the rescue bag (set by session; used for drawing)
var bag_types: Array = []  # survivor types riding in the bag, e.g. ["person","dog"] (set by session)
var jumps: int = 0
var test_control: bool = false
var test_axis: float = 0.0
var test_jump_pressed: bool = false
var test_jump_held: bool = false
var test_water_pressed: bool = false  # hose input hook for the scripted route / tests
# Extinguisho art: one static generated image per state, swapped in (visual only; never read by gameplay).
const ART_DIR := "res://art/character/"
const BOX := Vector2(20, 40)   # collision box; feet at the origin (CHARACTER-SHEET, collision option A)
const LAND_TICKS := 20         # landing pose holds this long after real air time (was 8: too fast to see)
const NOZZLE := Vector2(33, -27.5)  # hose nozzle tip in the hose pose (game px, facing right): the water starts here
# Rescue bag center per pose (game px, facing right): on his back at the hip, measured on each image.
const BAG := {"idle": Vector2(-10, -30), "respawn": Vector2(-13, -20), "run": Vector2(-8, -21),
	"jump_crouch": Vector2(-9, -30), "rising": Vector2(-10, -18), "falling": Vector2(-12, -16),
	"landing": Vector2(-8, -20), "hose": Vector2(-10, -19), "grab": Vector2(-10, -27),
	"toss": Vector2(-10, -31), "burned": Vector2(-10, -30), "celebrate": Vector2(-9, -27)}
var pose: String = "idle"
var art: Node2D
var sprite: Sprite2D
var textures := {}
var anchors := {}
var jumped_this_air: bool = false
var air_ticks: int = 0
var land_ticks: int = 0
var was_on_floor: bool = true
var hosing: bool = false        # water is pouring (set by session)
var bag_in_flight: int = 0      # survivors still flying toward the bag (set by session); their heads appear on landing
var action_queue: Array = []    # timed poses that override movement, e.g. [["grab", 15], ["toss", 27]]
var action_cancel_on_move: bool = false

func _ready() -> void:
	name = "Player"
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 1.0
	var shape := RectangleShape2D.new()
	shape.size = BOX
	var collider := CollisionShape2D.new()
	collider.shape = shape
	collider.position = Vector2(0, -BOX.y / 2.0)
	add_child(collider)
	var info: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ART_DIR + "anchors.json"))
	anchors = info.anchors
	for state in anchors:
		textures[state] = load(ART_DIR + state + ".png")
	art = Node2D.new()
	art.show_behind_parent = true  # the code-drawn rescue bag stays on top of the art
	add_child(art)
	sprite = Sprite2D.new()
	sprite.centered = false
	art.add_child(sprite)
	show_pose("idle")

# Swap the state image. The anchor (bottom-center of the collision box in texture px)
# lands on the origin; the holder's negative x scale mirrors the art when facing left.
func show_pose(state: String) -> void:
	pose = state
	sprite.texture = textures[state]
	var a: Array = anchors[state]
	sprite.position = -Vector2(a[0], a[1])
	art.scale = Vector2(0.5 * facing, 0.5)
	queue_redraw()  # the bag follows the pose

# Timed state poses (grab, toss, respawn), played in order and held for their tick count.
func play_actions(steps: Array, cancel_on_move: bool = false) -> void:
	action_queue = steps.duplicate(true)
	action_cancel_on_move = cancel_on_move
	show_pose(action_queue[0][0])

func _update_pose() -> void:
	var on_floor := is_on_floor()
	if on_floor:
		if not was_on_floor and air_ticks > 10:
			land_ticks = LAND_TICKS
		air_ticks = 0
		jumped_this_air = false
	else:
		air_ticks += 1
	was_on_floor = on_floor
	if land_ticks > 0:
		land_ticks -= 1
	if not action_queue.is_empty() and action_cancel_on_move and (absf(velocity.x) > 8.0 or not on_floor):
		action_queue.clear()
	if not action_queue.is_empty():
		show_pose(action_queue[0][0])
		action_queue[0][1] -= 1
		if action_queue[0][1] <= 0:
			action_queue.pop_front()
	elif not on_floor:
		# A jump is one flying kick all the way; walking off a ledge is the meditating fall.
		show_pose("rising" if jumped_this_air else "falling")
	elif land_ticks > 0:
		show_pose("landing")
	elif absf(velocity.x) > 8.0:
		show_pose("run")
	elif hosing:
		show_pose("hose")
	else:
		show_pose("idle")

func reset_at(spawn: Vector2) -> void:
	position = spawn
	velocity = Vector2.ZERO
	last_floor_tick = -1000
	jump_request_tick = -1000
	opportunity_consumed = false
	require_jump_release = true
	test_jump_pressed = false
	jumps = 0
	rescued = 0
	bag_types.clear()
	jumped_this_air = false
	air_ticks = 0
	land_ticks = 0
	was_on_floor = true
	hosing = false
	bag_in_flight = 0
	play_actions([["respawn", 30]], true)  # snaps into the ready stance; any movement ends it
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not enabled:
		return
	tick += 1
	var axis := test_axis if test_control else Input.get_axis("move_left", "move_right")
	var held := test_jump_held if test_control else Input.is_action_pressed("jump")
	var pressed := test_jump_pressed if test_control else Input.is_action_just_pressed("jump")
	test_jump_pressed = false
	if not held:
		require_jump_release = false
	if is_on_floor() and velocity.y >= 0.0:
		last_floor_tick = tick
		opportunity_consumed = false
	if pressed and not require_jump_release:
		jump_request_tick = tick
	var rate: float = tuning.acceleration if not is_zero_approx(axis) else tuning.deceleration
	velocity.x = move_toward(velocity.x, axis * tuning.speed, rate * delta)
	if not is_zero_approx(axis):
		facing = signf(axis)
	velocity.y = minf(velocity.y + tuning.gravity * delta, tuning.terminal_velocity)
	if not opportunity_consumed and tick - last_floor_tick <= tuning.coyote_ticks and tick - jump_request_tick <= tuning.buffer_ticks:
		velocity.y = tuning.jump_velocity
		opportunity_consumed = true
		jump_request_tick = -1000
		jumps += 1
		jumped_this_air = true
		jumped.emit()
	move_and_slide()
	position.x = maxf(position.x, 10.0)
	_update_pose()
	queue_redraw()

func _draw() -> void:
	# The body is the generated art (sprite above). Only the rescue bag is still code-drawn:
	# the art has no bag, and rescued survivors ride in it (person or dog head per rescue).
	# Same drawing as Assignment 1, doubled, placed per pose on his back. Hidden until the
	# first rescue, so the empty bag doesn't cover the generated art.
	if bag_types.is_empty():
		return
	var f := facing                 # +1 right, -1 left
	var c: Vector2 = BAG.get(pose, BAG.idle)
	draw_set_transform(Vector2(c.x * f, c.y), 0.0, Vector2(2.0, 2.0))
	var ink := Color("1b2a3f")      # outline
	var skin := Color("e8b98f")     # face
	var bag_col := Color("e67e22")  # orange rescue duffel
	var bag_dark := Color("b8621b") # bag seam
	draw_rect(Rect2(-4.5, -4.5, 9, 9), ink)
	draw_rect(Rect2(-3.5, -3.5, 7, 7), bag_col)
	draw_rect(Rect2(-3.5, -3.5, 7, 2), bag_dark)
	# rescued survivors ride in the bag — a clear head per rescue (grows as you save more)
	for i in range(bag_types.size() - bag_in_flight):
		var hx := (-1.0 + float(i) * 4.5) * f
		var hyy := -7.0
		if String(bag_types[i]) == "dog":
			draw_colored_polygon(PackedVector2Array([Vector2(hx-3, hyy-1), Vector2(hx-2, hyy-6), Vector2(hx+0.5, hyy-1)]), Color("6b4420"))  # left ear
			draw_colored_polygon(PackedVector2Array([Vector2(hx+0.5, hyy-1), Vector2(hx+2, hyy-6), Vector2(hx+3, hyy-1)]), Color("6b4420"))  # right ear
			draw_circle(Vector2(hx, hyy), 3.2, Color("8a5a2b"))       # dog head
			draw_circle(Vector2(hx + 1.2 * f, hyy + 0.5), 0.9, ink)  # snout/eye
		else:
			draw_circle(Vector2(hx, hyy), 3.2, skin)                 # person head
			draw_rect(Rect2(hx - 3.0, hyy - 3.6, 6.0, 2.2), Color("3a2f1a"))  # hair
			draw_circle(Vector2(hx + 1.2 * f, hyy), 0.8, ink)        # eye
