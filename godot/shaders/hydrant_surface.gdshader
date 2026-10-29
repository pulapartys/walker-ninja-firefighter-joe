shader_type spatial;

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap;
uniform sampler2D rough_tex : hint_default_white, filter_linear_mipmap;
uniform sampler2D normal_tex : hint_normal, filter_linear_mipmap;

group_uniforms paint;
uniform vec4 paint_tint : source_color = vec4(0.75, 0.22, 0.17, 1.0);
uniform float rust_amount : hint_range(0.0, 1.0) = 0.3;
group_uniforms;

group_uniforms surface;
uniform float roughness_scale : hint_range(0.0, 2.0) = 1.0;
uniform float normal_strength : hint_range(0.0, 2.0) = 1.0;
uniform float uv_scale : hint_range(0.25, 8.0) = 2.0;
group_uniforms;

void fragment() {
      vec2 uv = UV * uv_scale;
      vec3 base = texture(albedo_tex, uv).rgb;
      ALBEDO = mix(base * paint_tint.rgb, base, rust_amount);
      ROUGHNESS = texture(rough_tex, uv).r * roughness_scale;
      NORMAL_MAP = texture(normal_tex, uv).rgb;
      NORMAL_MAP_DEPTH = normal_strength;
}