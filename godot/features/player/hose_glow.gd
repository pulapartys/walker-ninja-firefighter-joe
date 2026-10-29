extends Node
# Hose glow driver (CHANGE-BRIEF A2/A3). Presentation only: it reads player.hosing and
# writes one shader parameter on player.sprite. It never writes game state.

const SHADER := preload("res://shaders/hose_glow.gdshader")  # hand-written; not edited here
const PARAM := "glow"
const RAMP_SECONDS := 0.25   # R3: 0 -> 1 and 1 -> 0 each take this long in game time
var glow := 0.0
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
	# delta is scaled game time (R4, R6): the ramp takes RAMP_SECONDS at any frame rate.
	# move_toward from the current value: a state change mid-ramp reverses from where it is (R7).
	var target := 1.0 if get_parent().hosing else 0.0
	glow = move_toward(glow, target, delta / RAMP_SECONDS)
	material.set_shader_parameter(PARAM, glow)
