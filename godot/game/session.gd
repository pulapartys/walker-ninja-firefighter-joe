extends Node2D

const Player = preload("res://features/player/player.gd")
const Hud = preload("res://ui/hud.gd")
enum State { MENU, PLAYING, PAUSED, DYING, COMPLETE }
var state: State = State.MENU
var player: CharacterBody2D
var camera: Camera2D
var hud: Control
var level: Dictionary
var hazard_areas: Array[Area2D] = []
var goal: Area2D
var deaths: int = 0
var elapsed: float = 0.0
var retry_remaining: float = 0.0
var death_reason: String = ""
var last_finish_time: float = 0.0
var test_mode: bool = false
var contact_settle_ticks: int = 0
var survivors: Array = []       # [{area, type, rescued, x, y}] — the trapped survivors
var rescued_count: int = 0      # how many rescued this attempt
var locked_cue_ticks: int = 0   # frames left to flash the "rescue everyone" cue
var saved_popup_ticks: int = 0  # frames left to show the "SAVED!" popup
var saved_popup_pos: Vector2 = Vector2.ZERO
const EXTINGUISH_TICKS := 240          # 4 s @ 60 Hz for the fire to fully die (half by 2 s)
var fire_active: bool = true           # lethal + blocks the rescue until FULLY hosed
var extinguish_ticks: int = 0          # frames until the fire is out (240 = full, 0 = out)
var water_ticks: int = 0               # frames the water visual keeps pouring (lingers ~1 s)
var near_fire: bool = false            # player in hose range this frame (for the prompt)
# Rescue toss (visual only): the rescued survivor is grabbed, flung sky-high, and drops into
# the bag. Game state (rescued, counts) changes at the touch, before any of this is drawn.
const GRAB_TICKS := 15                 # grab pose, survivor held at the window
const TOSS_UP_TICKS := 30              # flying up
const TOSS_DOWN_TICKS := 30            # dropping into the bag
const TOSS_HEIGHT := 150.0
var flights: Array = []                # [{type, from: Vector2, t: int, launch, apex}]
const BOW_TICKS := 75                  # the bow shows ~1.2 s before the "Rescue complete" card covers him
var complete_ticks: int = 0

func _ready() -> void:
	process_physics_priority = 10
	level = JSON.parse_string(FileAccess.get_file_as_string("res://levels/first_steps.json"))
	_setup_input()
	for entry in level.solids:
		_add_solid(Rect2(entry[0], entry[1], entry[2], entry[3]))
	_add_solid(Rect2(-32, 0, 32, 430))
	_add_solid(Rect2(level.width, 0, 32, 430))
	for entry in level.hazards:
		hazard_areas.append(_add_area(Rect2(entry[0], entry[1], entry[2], entry[3]), 8, true))
	var f: Array = level.finish
	goal = _add_area(Rect2(f[0], f[1], f[2], f[3]), 16, false)
	for entry in level.survivors:
		var area := _add_area(Rect2(entry[0] - 8.0, entry[1] - 22.0, 16.0, 22.0), 32, false)
		survivors.append({"area": area, "type": String(entry[2]), "rescued": false, "x": float(entry[0]), "y": float(entry[1])})
	player = Player.new()
	add_child(player)
	player.reset_at(Vector2(level.spawn[0], level.spawn[1]))
	camera = Camera2D.new()
	camera.position = Vector2(320, 180)
	add_child(camera)
	# ENV-BG: the generated skyline, fixed behind everything (a distant backdrop, so it doesn't scroll).
	var bg_layer := CanvasLayer.new()
	bg_layer.layer = -1
	add_child(bg_layer)
	var bg := TextureRect.new()
	bg.texture = load("res://art/env/env_bg.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.size = Vector2(640, 360)
	bg_layer.add_child(bg)
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Hud.new()
	hud.game = self
	layer.add_child(hud)
	get_window().focus_exited.connect(_on_focus_lost)
	queue_redraw()

func _setup_input() -> void:
	var actions := {"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT], "jump": [KEY_SPACE], "pause": [KEY_ESCAPE, KEY_P], "restart": [KEY_R], "confirm": [KEY_ENTER], "menu": [KEY_M], "water": [KEY_W]}
	for action in actions:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		for key in actions[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)

func _add_solid(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = rect.position + rect.size / 2
	body.collision_layer = 1
	body.collision_mask = 2
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	body.add_child(collision)
	add_child(body)

func _add_area(rect: Rect2, layer: int, spikes: bool) -> Area2D:
	var area := Area2D.new()
	area.position = rect.position
	area.collision_layer = layer
	area.collision_mask = 2
	if spikes:
		# Three exact triangular trigger silhouettes; no oversized invisible box.
		for i in range(3):
			var triangle := CollisionPolygon2D.new()
			var x := float(i) * rect.size.x / 3.0
			triangle.polygon = PackedVector2Array([Vector2(x, rect.size.y), Vector2(x + 4, 0), Vector2(x + 8, rect.size.y)])
			area.add_child(triangle)
	else:
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		collision.shape = shape
		collision.position = rect.size / 2.0
		area.add_child(collision)
	add_child(area)
	return area

func start_session() -> void:
	if state == State.PLAYING:
		return
	deaths = 0
	restart_attempt()

func restart_attempt() -> void:
	state = State.PLAYING
	elapsed = 0.0
	retry_remaining = 0.0
	# Area2D overlaps are physics-step snapshots. Discard pre-teleport contacts
	# until the broadphase has observed the reset, preventing a phantom second death.
	contact_settle_ticks = 2
	player.reset_at(Vector2(level.spawn[0], level.spawn[1]))
	player.enabled = true
	camera.position = Vector2(320, 180)
	rescued_count = 0
	locked_cue_ticks = 0
	saved_popup_ticks = 0
	fire_active = true
	extinguish_ticks = 0
	water_ticks = 0
	flights.clear()
	for s in survivors:
		s.rescued = false
		s.area.set_deferred("monitoring", true)

# Blocking-fire height in px: full until hosing starts, then shrinks linearly to 0
# over EXTINGUISH_TICKS (half by 2 s). Drives both the flame visual and the kill-zone.
func fire_height() -> float:
	if not fire_active or not level.has("blocking_fire"):
		return 0.0
	var full: float = float(level.blocking_fire[3])
	if extinguish_ticks > 0:
		return full * float(extinguish_ticks) / float(EXTINGUISH_TICKS)
	return full

func set_paused(value: bool) -> void:
	if value and state == State.PLAYING:
		state = State.PAUSED
		player.enabled = false
	elif not value and state == State.PAUSED:
		state = State.PLAYING
		player.enabled = true
		player.require_jump_release = true
		player.jump_request_tick = -1000

func _on_focus_lost() -> void:
	if not test_mode:
		set_paused(true)

func resolve_contacts(fatal: bool, finished: bool) -> void:
	if state != State.PLAYING:
		return
	if fatal:
		state = State.DYING
		deaths += 1
		retry_remaining = 0.55
		player.enabled = false
		player.velocity = Vector2.ZERO
		if death_reason == "The fire got you.":
			player.show_pose("burned")
			retry_remaining = 0.9  # hold the burned pose long enough to read (was 0.55 s: unseen in playtest 2); still under the 1 s retry limit
	elif finished:
		state = State.COMPLETE
		last_finish_time = elapsed
		player.enabled = false
		player.velocity = Vector2.ZERO
		player.show_pose("celebrate")
		complete_ticks = 0

func _physics_process(delta: float) -> void:
	if state == State.DYING:
		retry_remaining -= delta
		if retry_remaining <= 0:
			restart_attempt()
	elif state == State.PLAYING:
		elapsed += delta
		var fell := player.position.y > float(level.fall_y)
		var timed_out := elapsed >= float(level.time_limit)
		var hit_fire := false
		for hazard in hazard_areas:
			if hazard.overlaps_body(player):
				hit_fire = true
		# The blocking fire is lethal + blocks the path until FULLY hosed. Its kill-zone
		# shrinks from the top with the flames (see fire_height), but the base stays lethal
		# until the fire is completely out -- so walking in mid-extinguish still kills.
		if fire_active and level.has("blocking_fire"):
			var bf0: Array = level.blocking_fire
			var fire_top: float = (float(bf0[1]) + float(bf0[3])) - fire_height()
			var half_w: float = Player.BOX.x / 2.0
			if player.position.x + half_w > float(bf0[0]) and player.position.x - half_w < float(bf0[0]) + float(bf0[2]) and player.position.y > fire_top and player.position.y - Player.BOX.y < float(bf0[1]) + float(bf0[3]):
				hit_fire = true
		var fatal := fell or timed_out or hit_fire
		if fatal:
			death_reason = "Out of time!" if timed_out else ("You fell." if fell else "The fire got you.")
		# Hose: tap W within range of the blocking fire -> water pours ~4 s -> fire out.
		near_fire = false
		if fire_active and level.has("blocking_fire"):
			var bf: Array = level.blocking_fire
			near_fire = player.is_on_floor() and player.position.x > float(bf[0]) - 50.0 and player.position.x < float(bf[0]) + float(bf[2]) + 10.0 and player.position.y < float(bf[1]) + float(bf[3]) + 20.0 and player.position.y > float(bf[1]) - 40.0
			var water: bool = player.test_water_pressed if player.test_control else Input.is_action_just_pressed("water")
			if player.test_control:
				player.test_water_pressed = false
			if water and near_fire and extinguish_ticks == 0:
				extinguish_ticks = EXTINGUISH_TICKS
				water_ticks = EXTINGUISH_TICKS + 60  # water lingers ~1 s after it is out
		if extinguish_ticks > 0:
			extinguish_ticks -= 1
			if extinguish_ticks == 0:
				fire_active = false
		if water_ticks > 0:
			water_ticks -= 1
		player.hosing = water_ticks > 0
		# Touch to rescue -- only while NOT in a fatal state, so you can't rescue THROUGH fire.
		if not fatal:
			for s in survivors:
				if not s.rescued and s.area.overlaps_body(player):
					s.rescued = true
					s.area.set_deferred("monitoring", false)
					rescued_count += 1
					player.rescued = rescued_count
					player.bag_types.append(s.type)
					player.bag_in_flight += 1
					player.play_actions([["grab", GRAB_TICKS], ["toss", TOSS_UP_TICKS]])
					flights.append({"type": s.type, "from": Vector2(s.x, s.y), "t": 0})
					saved_popup_ticks = 55
					saved_popup_pos = Vector2(s.x - 18.0, s.y - 34.0)
		var all_rescued := rescued_count >= survivors.size()
		var at_exit := goal.overlaps_body(player) and player.is_on_floor()
		if at_exit and not all_rescued:
			locked_cue_ticks = 45  # flash "rescue everyone first"
		if locked_cue_ticks > 0:
			locked_cue_ticks -= 1
		if saved_popup_ticks > 0:
			saved_popup_ticks -= 1
		if contact_settle_ticks > 0:
			contact_settle_ticks -= 1
		else:
			# Exit completes only when BOTH survivors are rescued AND reached on foot.
			# State machine unchanged; only the COMPLETE condition gains "both rescued".
			resolve_contacts(fatal, at_exit and all_rescued)
		camera.position.x = clampf(player.position.x + 100, 320, float(level.width) - 320)
	if state == State.COMPLETE:
		complete_ticks += 1
	for fl in flights:
		fl.t += 1
		if fl.t == GRAB_TICKS:  # toss starts: launch from his raised hand, straight up
			fl.launch = player.position + Vector2(0.0, -62.0)
			fl.apex = fl.launch + Vector2(0.0, -TOSS_HEIGHT)
		if fl.t >= GRAB_TICKS + TOSS_UP_TICKS + TOSS_DOWN_TICKS:
			player.bag_in_flight = maxi(player.bag_in_flight - 1, 0)
			player.queue_redraw()
	flights = flights.filter(func(fl): return fl.t < GRAB_TICKS + TOSS_UP_TICKS + TOSS_DOWN_TICKS)
	if is_instance_valid(hud):
		hud.queue_redraw()
	queue_redraw()  # refresh the level's own dynamic draw: survivors vanish, SAVED! animates, exit unlocks

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return
	if event.is_action_pressed("confirm"):
		if state in [State.MENU, State.COMPLETE]:
			start_session()
		elif state == State.PAUSED:
			set_paused(false)
	elif event.is_action_pressed("pause"):
		set_paused(state != State.PAUSED)
	elif event.is_action_pressed("restart") and state in [State.PLAYING, State.PAUSED, State.DYING]:
		restart_attempt()
	elif event.is_action_pressed("menu") and state in [State.PAUSED, State.COMPLETE]:
		state = State.MENU
		player.enabled = false
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Rect2(220, 215, 200, 34).has_point(hud.get_local_mouse_position()):
			if state in [State.MENU, State.COMPLETE]:
				start_session()
			elif state == State.PAUSED:
				set_paused(false)

func _draw() -> void:
	if level.is_empty():
		return
	var font := ThemeDB.fallback_font
	var ink := Color("25354a")
	# All visual assets are original Godot vector drawing, not recovered art.
	# The A1 cream sky, grid, and hills are replaced by the generated ENV-BG (see _ready).
	# Burning buildings — decorative facades drawn BEHIND the ledges (no collision).
	for b in level.get("buildings", []):
		var bl := Rect2(b[0], b[1], b[2], b[3])
		draw_rect(bl, Color("e0cdaf"))                                         # very light brown wall (contrast for dark figures)
		draw_rect(Rect2(bl.position, Vector2(bl.size.x, 5)), Color("a3855f"))  # roof cap (medium brown)
		draw_rect(bl, Color(0.96, 0.46, 0.16, 0.18))                           # warm fire glow (keeps the burning read)
		for wx in range(int(bl.position.x) + 18, int(bl.end.x) - 14, 84):
			for wy in range(int(bl.position.y) + 16, int(bl.end.y) - 24, 34):
				draw_rect(Rect2(wx, wy, 13, 17), Color("6f5c46"))
				draw_rect(Rect2(wx + 2, wy + 2, 9, 13), Color("f2ecd8"))
	for entry in level.solids:
		var r := Rect2(entry[0], entry[1], entry[2], entry[3])
		# Light concrete with a dark outline: the A1 navy (#25354a) vanished against ENV-BG's dark fog (#2c3547).
		draw_rect(Rect2(r.position - Vector2(1, 1), r.size + Vector2(2, 2)), Color("1b2230"))
		draw_rect(r, Color("b8b2a6"))
		draw_rect(Rect2(r.position, Vector2(r.size.x, 4)), Color("438e7d"))
		for x in range(int(r.position.x)+12, int(r.end.x), 24):
			draw_line(Vector2(x, r.position.y+12), Vector2(x+7, r.position.y+19), Color("8f897d"), 1)
	# Fire hazard drawn as bold flames, data-driven from the hazard rect. The VISUAL is
	# enlarged for readability but the COLLISION (the rect, built in _add_area) is
	# UNCHANGED, so the jump-over margins verified by flame-clearance-positive still
	# hold. Flame tips stay below the player's jump clearance, so a cleared jump does
	# not clip the visual.
	for entry in level.hazards:
		var hx: float = entry[0]
		var hy: float = entry[1]
		var hw: float = entry[2]
		var base_y: float = hy + entry[3]
		var tongues: int = maxi(1, int(hw / 12.0))
		var span: float = hw / float(tongues)
		for i in range(tongues):
			var cx: float = hx + span * (float(i) + 0.5)
			var tip: float = hy - 6.0 - (2.0 if i % 2 == 0 else 0.0)
			draw_colored_polygon(PackedVector2Array([Vector2(cx-span*0.5, base_y), Vector2(cx-3, hy+3), Vector2(cx, tip), Vector2(cx+3, hy+3), Vector2(cx+span*0.5, base_y)]), Color("e0411c"))
			draw_colored_polygon(PackedVector2Array([Vector2(cx-span*0.3, base_y), Vector2(cx-2, hy+4), Vector2(cx, tip+3), Vector2(cx+2, hy+4), Vector2(cx+span*0.3, base_y)]), Color("f5a01f"))
			draw_colored_polygon(PackedVector2Array([Vector2(cx-2, base_y), Vector2(cx, hy+2), Vector2(cx+2, base_y)]), Color("ffe95a"))
	# Finish: a FIRE-ESCAPE window. Data-driven from level.finish; LOCKED until both
	# survivors are rescued, then it brightens with a "JUMP OUT" prompt.
	var fr := Rect2(level.finish[0], level.finish[1], level.finish[2], level.finish[3])
	var all_saved := rescued_count >= survivors.size()
	var glow := Color("e8792b") if all_saved else Color("6b7683")
	var pane := Color("ffe08a") if all_saved else Color("aeb7c2")
	draw_rect(Rect2(fr.position.x - 3.0, fr.position.y - 3.0, fr.size.x + 6.0, fr.size.y + 6.0), glow)
	draw_rect(fr, ink)
	draw_rect(Rect2(fr.position.x + 2.0, fr.position.y + 2.0, fr.size.x - 4.0, fr.size.y - 4.0), pane)
	draw_rect(Rect2(fr.position.x + fr.size.x / 2.0 - 1.0, fr.position.y + 2.0, 2.0, fr.size.y - 4.0), ink)
	draw_rect(Rect2(fr.position.x + 2.0, fr.position.y + fr.size.y / 2.0 - 1.0, fr.size.x - 4.0, 2.0), ink)
	draw_rect(Rect2(fr.position.x - 2.0, fr.end.y - 2.0, fr.size.x + 4.0, 3.0), ink)
	if all_saved:
		_label(Vector2(fr.position.x - 22.0, fr.position.y - 14.0), "JUMP OUT →", 13, Color("7fe0b0"))
	else:
		var lx: float = fr.position.x + fr.size.x / 2.0
		var ly: float = fr.position.y + fr.size.y / 2.0
		draw_rect(Rect2(lx - 4.0, ly - 1.0, 8.0, 7.0), Color("3a2f1a"))
		draw_arc(Vector2(lx, ly - 1.0), 3.0, PI, TAU, 8, Color("3a2f1a"), 1.5)
		_label(Vector2(fr.position.x - 40.0, fr.position.y - 14.0), "FIRE ESCAPE", 13, Color("f6f3ec"))
	if locked_cue_ticks > 0:
		_label(Vector2(fr.position.x - 66.0, fr.position.y - 30.0), "Rescue everyone first!", 14, Color("ff7a66"))
	# "SAVED!" popup that rises + fades at the moment of a rescue.
	if saved_popup_ticks > 0:
		var pa: float = clampf(float(saved_popup_ticks) / 55.0, 0.0, 1.0)
		var rise: float = float(55 - saved_popup_ticks) * 0.35
		_label(saved_popup_pos - Vector2(0.0, rise), "SAVED!", 16, Color(0.5, 0.88, 0.69, pa))
	# Trapped survivors (un-rescued only), each with a HELP! bubble to draw the player in.
	for s in survivors:
		if s.rescued:
			continue
		var sx: float = s.x
		var sy: float = s.y
		# rescue window: thin frame + DARK interior + soft fire backlight (a clear opening, not a flat box)
		draw_rect(Rect2(sx - 13.0, sy - 33.0, 26.0, 33.0), ink)                             # frame
		draw_rect(Rect2(sx - 11.0, sy - 31.0, 22.0, 31.0), Color("241d1b"))                 # dark room interior
		draw_rect(Rect2(sx - 11.0, sy - 15.0, 22.0, 15.0), Color(0.98, 0.55, 0.22, 0.30))   # soft fire glow, low
		if s.type == "dog":
			# clearly a dog: tail + body + four legs + head + snout + ear (dark outline, warm fill)
			var dg := Color("d59243")
			draw_colored_polygon(PackedVector2Array([Vector2(sx-7,sy-9), Vector2(sx-11,sy-14), Vector2(sx-9,sy-14.5), Vector2(sx-6,sy-8)]), ink)
			draw_colored_polygon(PackedVector2Array([Vector2(sx-7,sy-9), Vector2(sx-10,sy-13), Vector2(sx-8.5,sy-13.5), Vector2(sx-6,sy-8.5)]), dg)
			for lx in [-6.0, -2.5, 1.5, 4.5]:
				draw_rect(Rect2(sx + lx, sy - 6.0, 2.6, 6.0), ink)
				draw_rect(Rect2(sx + lx + 0.5, sy - 5.5, 1.6, 5.0), dg)
			draw_rect(Rect2(sx - 8.0, sy - 12.0, 14.0, 7.0), ink)
			draw_rect(Rect2(sx - 7.0, sy - 11.0, 12.0, 5.5), dg)
			draw_colored_polygon(PackedVector2Array([Vector2(sx+3.5,sy-15.5), Vector2(sx+4.5,sy-11), Vector2(sx+7,sy-13)]), ink)
			draw_circle(Vector2(sx + 6.0, sy - 12.0), 4.2, ink)
			draw_circle(Vector2(sx + 6.0, sy - 12.0), 3.2, dg)
			draw_rect(Rect2(sx + 7.5, sy - 12.0, 4.0, 3.0), ink)
			draw_rect(Rect2(sx + 7.8, sy - 11.6, 3.6, 2.2), dg)
			draw_circle(Vector2(sx + 11.0, sy - 10.8), 0.9, ink)
			draw_circle(Vector2(sx + 6.2, sy - 12.6), 0.9, ink)
		else:
			# clearly a person: head+face, torso, one arm RAISED waving, two legs (dark outline, bright fill)
			var shirt := Color("46a0e0")
			var face := Color("f2c9a0")
			draw_rect(Rect2(sx - 3.6, sy - 8.0, 3.2, 8.0), ink)
			draw_rect(Rect2(sx + 0.4, sy - 8.0, 3.2, 8.0), ink)
			draw_rect(Rect2(sx - 3.1, sy - 7.5, 2.2, 7.0), Color("2b3a55"))
			draw_rect(Rect2(sx + 0.9, sy - 7.5, 2.2, 7.0), Color("2b3a55"))
			draw_rect(Rect2(sx - 5.0, sy - 19.0, 10.0, 12.0), ink)
			draw_rect(Rect2(sx - 4.0, sy - 18.0, 8.0, 10.0), shirt)
			draw_rect(Rect2(sx - 7.0, sy - 18.0, 3.0, 9.0), ink)
			draw_rect(Rect2(sx - 6.5, sy - 17.0, 2.0, 8.0), face)
			draw_rect(Rect2(sx + 3.2, sy - 27.0, 3.0, 11.0), ink)
			draw_rect(Rect2(sx + 3.7, sy - 26.0, 2.0, 10.0), face)
			draw_circle(Vector2(sx + 4.7, sy - 27.5), 2.3, ink)
			draw_circle(Vector2(sx + 4.7, sy - 27.5), 1.5, face)
			draw_circle(Vector2(sx, sy - 22.5), 5.2, ink)
			draw_circle(Vector2(sx, sy - 22.5), 4.2, face)
			draw_rect(Rect2(sx - 4.3, sy - 27.0, 8.6, 3.2), Color("3a2f1a"))
			draw_circle(Vector2(sx - 1.6, sy - 23.0), 0.9, ink)
			draw_circle(Vector2(sx + 1.6, sy - 23.0), 0.9, ink)
			draw_rect(Rect2(sx - 1.5, sy - 20.0, 3.0, 1.1), Color("a23e36"))
		# HELP! speech bubble (enlarged) with a pointer/tail down to the survivor
		var buby := sy - 58.0
		var bubx := sx - 23.0
		draw_colored_polygon(PackedVector2Array([Vector2(sx-5,buby+17), Vector2(sx+7,buby+17), Vector2(sx+1,buby+27)]), ink)
		draw_rect(Rect2(bubx - 2.0, buby - 2.0, 50.0, 22.0), ink)
		draw_rect(Rect2(bubx, buby, 46.0, 18.0), Color("fff2b0"))
		draw_colored_polygon(PackedVector2Array([Vector2(sx-3,buby+16), Vector2(sx+5,buby+16), Vector2(sx+1,buby+24)]), Color("fff2b0"))
		draw_string(font, Vector2(bubx + 6.0, buby + 15.0), "HELP!", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("a23e36"))
	# Blocking fire at the person's window (big, lethal until hosed) + water stream + prompt.
	if level.has("blocking_fire"):
		var bf: Array = level.blocking_fire
		var bx: float = bf[0]
		var byy: float = bf[1]
		var bw: float = bf[2]
		var bbase: float = byy + float(bf[3])
		if fire_active:
			var ftop: float = bbase - fire_height()  # flame top rises as the fire burns down
			var n: int = maxi(2, int(bw / 14.0))
			for i in range(n):
				var fcx: float = bx + bw * (float(i) + 0.5) / float(n)
				var tip: float = ftop - 8.0 - (4.0 if i % 2 == 0 else 0.0)
				var mid: float = minf(ftop + 4.0, bbase)
				draw_colored_polygon(PackedVector2Array([Vector2(fcx-7, bbase), Vector2(fcx-4, mid), Vector2(fcx, tip), Vector2(fcx+4, mid), Vector2(fcx+7, bbase)]), Color("d0341a"))
				draw_colored_polygon(PackedVector2Array([Vector2(fcx-4, bbase), Vector2(fcx, tip+8.0), Vector2(fcx+4, bbase)]), Color("f39a1e"))
				draw_colored_polygon(PackedVector2Array([Vector2(fcx-2, bbase), Vector2(fcx, minf(ftop+1.0, bbase)), Vector2(fcx+2, bbase)]), Color("ffe95a"))
		if water_ticks > 0:
			var tgt := Vector2(bx + bw / 2.0, bbase - maxf(fire_height() * 0.5, 6.0))
			var src := player.position + Vector2(Player.NOZZLE.x * player.facing, Player.NOZZLE.y)
			draw_line(src, tgt, Color(0.42, 0.72, 1.0, 0.85), 3.0)
			draw_circle(tgt, 7.0, Color(0.6, 0.82, 1.0, 0.55))
		if near_fire and fire_active and extinguish_ticks == 0:
			_label(Vector2(bx - 40.0, byy - 56.0), "Press W to hose the fire", 13, Color("f6f3ec"))
	# Intro context labels near the spawn — hidden while the menu/pause/complete card is up.
	if state == State.PLAYING or state == State.DYING:
		_label(Vector2(33, 150), "01 / TO THE BUILDINGS", 15, Color("f6f3ec"))
		_label(Vector2(33, 172), "Save the person + dog, then out the B2 roof.", 13, Color("f6f3ec"))
	_draw_flights()
	_label(Vector2(1010, 200), "B1 / SAVE THE PERSON", 14, Color("f6f3ec"))
	_label(Vector2(1560, 138), "B2 / SAVE THE DOG -> ROOF", 14, Color("f6f3ec"))

# Survivors mid-toss: held at the window during the grab, flung straight up, then dropped
# into the bag on his back (which moves with him). Small code-drawn figures, spinning.
func _draw_flights() -> void:
	var ink := Color("25354a")
	for fl in flights:
		var t: int = fl.t
		var from: Vector2 = fl.from + Vector2(0.0, -12.0)
		var launch: Vector2 = fl.get("launch", from)
		var apex: Vector2 = fl.get("apex", from + Vector2(0.0, -TOSS_HEIGHT))
		var bag: Vector2 = Player.BAG.get(player.pose, Player.BAG.idle)
		var into := player.position + Vector2(bag.x * player.facing, bag.y - 6.0)
		var pos := from
		var spin := 0.0
		if t >= GRAB_TICKS + TOSS_UP_TICKS:
			var k := float(t - GRAB_TICKS - TOSS_UP_TICKS) / float(TOSS_DOWN_TICKS)
			pos = Vector2(lerpf(apex.x, into.x, k), lerpf(apex.y, into.y, k * k))
			spin = float(t) * 0.5
		elif t >= GRAB_TICKS:
			var k := float(t - GRAB_TICKS) / float(TOSS_UP_TICKS)
			pos = launch.lerp(apex, 1.0 - (1.0 - k) * (1.0 - k))
			spin = float(t) * 0.5
		draw_set_transform(pos, spin, Vector2.ONE)
		if fl.type == "dog":
			draw_rect(Rect2(-7, -3, 12, 7), ink)
			draw_rect(Rect2(-6, -2, 10, 5), Color("d59243"))
			draw_circle(Vector2(6, -3), 4.0, ink)
			draw_circle(Vector2(6, -3), 3.0, Color("d59243"))
		else:
			draw_rect(Rect2(-4, -2, 8, 10), ink)
			draw_rect(Rect2(-3, -1, 6, 8), Color("46a0e0"))
			draw_circle(Vector2(0, -6), 4.5, ink)
			draw_circle(Vector2(0, -6), 3.5, Color("f2c9a0"))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# World text: light or colored fill with a dark outline, readable on ENV-BG and on the buildings.
func _label(pos: Vector2, text: String, size: int, color: Color) -> void:
	var font := ThemeDB.fallback_font
	draw_string_outline(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 4, Color(0.106, 0.133, 0.188, color.a))
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
