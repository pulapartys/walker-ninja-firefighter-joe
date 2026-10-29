extends Node
# Hose glow driver (CHANGE-BRIEF A2/A3, Revision 3). Presentation only: it reads player.hosing
# and writes one shader parameter on player.sprite. It never writes game state.

const SHADER := preload("res://shaders/hose_glow.gdshader")  # hand-written; not edited here
const PARAM := "glow"
const RAMP_SECONDS := 0.25   # R3: the ramps move at 1/RAMP_SECONDS per game second (0 -> 1 in 0.25 s)
const BREATH_CENTRE := 0.6   # Revision 3: while hosing, glow breathes 0.4..0.8 ...
const BREATH_AMPLITUDE := 0.2
const BREATH_PERIOD := 1.0   # ... with a 1.0 s period, in game seconds
var glow := 0.0
var hose_time := 0.0         # game seconds since hosing began (driver clock, not the shader's TIME)
var material: ShaderMaterial

func _ready() -> void:
	name = "HoseGlow"
	# One material per player instance (R8), on the sprite only (F5): the code-drawn rescue
	# bag and survivor heads are drawn on the body, not on the sprite, so they keep their colours.
	material = ShaderMaterial.new()
	material.shader = SHADER
	get_parent().sprite.material = material
	material.set_shader_parameter(PARAM, glow)

func _process(delta: float) -> void:
	# _process runs after this frame's physics ticks, so it sees the session's fresh `hosing`.
	# delta is scaled game time (R4, R6): the ramps and the breathing run on it at any frame rate.
	# move_toward from the current value: a state change mid-ramp reverses from where it is (R7).
	var target := 0.0
	if get_parent().hosing:
		# t = 0 on the first frame hosing is seen (target 0.6), then accumulates per frame.
		target = BREATH_CENTRE + BREATH_AMPLITUDE * sin(TAU * hose_time / BREATH_PERIOD)
		hose_time += delta
	else:
		hose_time = 0.0
	glow = move_toward(glow, target, delta / RAMP_SECONDS)
	material.set_shader_parameter(PARAM, glow)
