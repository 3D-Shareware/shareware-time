shader_type spatial;

uniform sampler2D albedo_texture : source_color;
uniform vec2 scroll_direction = vec2(1.0, 0.0); // X = horizontal, Y = vertical
uniform float scroll_speed = 1.0;

void fragment() {
    vec2 uv = UV;

    // Time-based scrolling
    uv += scroll_direction * scroll_speed * TIME;

    vec4 tex = texture(albedo_texture, uv);

    ALBEDO = tex.rgb;
    ALPHA = tex.a;
}