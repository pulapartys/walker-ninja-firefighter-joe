shader_type canvas_item;

uniform float glow : hint_range(0.0, 1.0) = 0.0;
uniform vec4 glow_color : source_color = vec4(0.6, 0.85, 1.0, 1.0);

void fragment() {
      COLOR.rgb = mix(COLOR.rgb, glow_color.rgb, glow);
}