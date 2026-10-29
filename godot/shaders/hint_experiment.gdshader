shader_type spatial;
render_mode unshaded;
uniform sampler2D as_color : source_color, filter_nearest;
uniform sampler2D as_data : filter_nearest;
uniform bool use_color = false;

void fragment() {
      if (use_color) {
              ALBEDO = texture(as_color, UV).rgb;
      } else {
              ALBEDO = texture(as_data, UV).rgb;
      }
}