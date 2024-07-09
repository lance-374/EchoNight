shader_type canvas_item;

uniform vec2 displacement = vec2(0.0, 0.0);
uniform vec2 scale = vec2(1.0, 1.0);
uniform vec2 velocity = vec2(1.0, 1.0);
uniform vec4 fog_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform sampler2D noise: repeat_enable;

void fragment() {
    vec2 fixed_uv = displacement + scale * UV + TIME * velocity;
    float fog = texture(noise, fixed_uv).r;
    COLOR = mix(vec4(0.0), fog_color, fog);
}