extends Control
var game: Node2D
const INK := Color("25354a")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func text_at(text: String, position: Vector2, size_px: int = 14, color: Color = INK) -> void:
	draw_string(ThemeDB.fallback_font, position, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, color)

func centered(text: String, y: float, font_size: int, color: Color = INK) -> void:
	var width := ThemeDB.fallback_font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	text_at(text, Vector2((640-width)/2, y), font_size, color)

func _draw() -> void:
	if not is_instance_valid(game):
		return
	draw_rect(Rect2(0,0,640,74), Color("f6f3ec"))
	text_at("FIREFIGHTER RESCUE", Vector2(22,27), 18)
	text_at("FIRST ALARM", Vector2(510,27), 14)
	text_at("A/D or arrows: move     Space: jump     W: hose     R: retry     Esc: pause", Vector2(22,50), 13)
	draw_rect(Rect2(22,63,596,3), Color("daddd6"))
	var progress: float = clampf((game.player.position.x-64)/maxf(1.0, float(game.level.finish[0])-64.0), 0, 1)
	draw_rect(Rect2(22,63,596*progress,3), Color("287c68"))
	draw_rect(Rect2(0,335,640,25), Color("f6f3ec"))
	text_at("No lives. Just get them out.", Vector2(22,353), 13)
	var remaining: float = maxf(0.0, float(game.level.time_limit) - game.elapsed)
	var tcol := Color("a23e36") if remaining < 10.0 else INK
	text_at("RETRIES %02d     TIME %04.1fs" % [game.deaths, remaining], Vector2(428,353), 13, tcol)
	text_at("SAVE:", Vector2(206,353), 12)
	var ox := 246.0
	for s in game.survivors:
		text_at(("[x] " if s.rescued else "[ ] ") + ("DOG" if s.type == "dog" else "PERSON"), Vector2(ox,353), 12, Color("287c68") if s.rescued else INK)
		ox += 84.0
	if game.state == game.State.PLAYING:
		return
	if game.state == game.State.DYING:
		draw_rect(Rect2(180,128,280,68), Color("fff9ee"))
		centered(game.death_reason, 155, 21, Color("a23e36"))
		centered("Back at the start in a moment.", 180, 13)
		return
	draw_rect(Rect2(0,74,640,261), Color(0.10,0.16,0.20,0.16))
	draw_rect(Rect2(163,103,318,159), Color("fffdf7"))
	draw_rect(Rect2(163,103,318,4), Color("ef875f"))
	var title := "Into the fire."
	var detail := "Walk into the person + dog to save them, then out the fire escape."
	var button := "ENTER  /  START"
	if game.state == game.State.PAUSED:
		title = "Take a breath."
		detail = "R: restart attempt    M: main menu"
		button = "ENTER  /  RESUME"
	elif game.state == game.State.COMPLETE:
		title = "Rescue complete."
		detail = "Everyone out! saved %d/%d  ·  %.1fs  ·  %d retries" % [game.rescued_count, game.survivors.size(), game.last_finish_time, game.deaths]
		button = "ENTER  /  PLAY AGAIN"
	centered(title, 143, 24)
	centered(detail, 177, 12)
	centered("One jump. No double jump. Unlimited retries.", 197, 12)
	draw_rect(Rect2(220,215,200,34), Color("287c68"))
	centered(button, 237, 14, Color("fffdf7"))
