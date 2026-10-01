extends CharacterBody2D

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

func _ready() -> void:
	name = "Player"
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 1.0
	var shape := RectangleShape2D.new()
	shape.size = Vector2(18, 28)
	var collider := CollisionShape2D.new()
	collider.shape = shape
	collider.position = Vector2(0, -14)
	add_child(collider)

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
	move_and_slide()
	position.x = maxf(position.x, 10.0)
	queue_redraw()

func _draw() -> void:
	# Firefighter ("Firefighter Rescue"). Original geometric drawing — no imported art.
	# Collider (18x28) and movement unchanged; pure repaint. The solid body fills the
	# collider; the helmet, air tank, and rescue bag extend a few px past it cosmetically.
	var coat := Color("2c3e50")     # dark turnout coat
	var stripe := Color("f4d03f")   # reflective yellow band
	var helmet := Color("c0392b")   # red fire helmet
	var ink := Color("1b2a3f")      # outline
	var skin := Color("e8b98f")     # face
	var bag_col := Color("e67e22")  # orange rescue duffel
	var bag_dark := Color("b8621b") # bag seam
	var tank := Color("9aa4ab")     # air tank
	var gold := Color("f1c40f")     # helmet badge
	var f := facing                 # +1 right, -1 left
	var stride := sin(float(tick) * 0.7) * 2.0 if is_on_floor() and absf(velocity.x) > 8 else 0.0
	# pale rim light so the dark suit separates from dark ledges + burning interiors
	var rim := Color(0.88, 0.94, 0.99, 0.85)
	draw_rect(Rect2(-10, -31, 20, 27), rim)
	# boots to the feet, step when walking
	draw_rect(Rect2(-5, -4, 3, 4 + stride), ink)
	draw_rect(Rect2(2, -4, 3, 4 - stride), ink)
	# body: coat outline, dark coat, reflective stripe
	draw_rect(Rect2(-9, -19, 18, 15), ink)
	draw_rect(Rect2(-7, -17, 14, 13), coat)
	draw_rect(Rect2(-7, -12, 14, 2), stripe)
	# air tank high on the back (mirrors with facing)
	var tank_left := -10.0 if f > 0 else 7.0
	draw_rect(Rect2(tank_left - 0.5, -21, 4, 8), ink)
	draw_rect(Rect2(tank_left, -20, 3, 6), tank)
	# rescue duffel on the back hip (mirrors); rescued survivors ride here
	var bag_left := -12.0 if f > 0 else 5.0
	draw_rect(Rect2(bag_left - 1.0, -13, 9, 9), ink)
	draw_rect(Rect2(bag_left, -12, 7, 7), bag_col)
	draw_rect(Rect2(bag_left, -12, 7, 2), bag_dark)
	# rescued survivors ride in the bag — a clear head per rescue (grows as you save more)
	for i in range(bag_types.size()):
		var hx := bag_left + 2.5 + float(i) * 4.5
		var hyy := -15.5
		if String(bag_types[i]) == "dog":
			draw_colored_polygon(PackedVector2Array([Vector2(hx-3, hyy-1), Vector2(hx-2, hyy-6), Vector2(hx+0.5, hyy-1)]), Color("6b4420"))  # left ear
			draw_colored_polygon(PackedVector2Array([Vector2(hx+0.5, hyy-1), Vector2(hx+2, hyy-6), Vector2(hx+3, hyy-1)]), Color("6b4420"))  # right ear
			draw_circle(Vector2(hx, hyy), 3.2, Color("8a5a2b"))       # dog head
			draw_circle(Vector2(hx + 1.2 * f, hyy + 0.5), 0.9, ink)  # snout/eye
		else:
			draw_circle(Vector2(hx, hyy), 3.2, skin)                 # person head
			draw_rect(Rect2(hx - 3.0, hyy - 3.6, 6.0, 2.2), Color("3a2f1a"))  # hair
			draw_circle(Vector2(hx + 1.2 * f, hyy), 0.8, ink)        # eye
	# head (skin) with outline
	draw_rect(Rect2(-6, -25, 12, 7), ink)
	draw_rect(Rect2(-5, -24, 10, 5), skin)
	# helmet: dome + brim + back beavertail + gold front badge (mirrors)
	draw_rect(Rect2(-7, -30, 14, 6), ink)
	draw_rect(Rect2(-6, -29, 12, 5), helmet)
	draw_rect(Rect2(-8, -25, 16, 2), helmet)
	var tail_left := -12.0 if f > 0 else 8.0
	draw_rect(Rect2(tail_left, -25, 4, 3), helmet)
	var badge_x := 1.0 if f > 0 else -4.0
	draw_rect(Rect2(badge_x, -28, 3, 3), gold)
	# eye on the front of the face
	draw_circle(Vector2(2.5 * f, -21), 1.2, ink)
