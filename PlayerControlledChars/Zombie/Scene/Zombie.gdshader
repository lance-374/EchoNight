shader_type canvas_item;
render_mode unshaded;

uniform float reveal_amount = 1.0; 
uniform vec2 sound_source = vec2(0.5, 0.5);
uniform float reveal_radius = 0.2;
uniform float z_index;
uniform sampler2D noise : repeat_enable;
uniform float pulse_intensity = 1.0;   // Lowered intensity
uniform float pulse_frequency = 2.0;   // Lowered frequency
uniform float depth_influence = 0.9;

void fragment() {
    vec4 original_color = texture(TEXTURE, UV);

    float depth = 1.0 - z_index / 1.0; 
    float depth_distance = 1.0 - depth;

    vec2 uv_centered = UV * 2.0 - 1.0;
    vec2 sound_source_centered = sound_source * 2.0 - 1.0;

    float aspect_ratio_adjustment = 1.333; // Adjust as needed
    
    // Calculate distance from the sound source, adjusted for aspect ratio
    vec2 adjusted_uv = vec2(uv_centered.x * aspect_ratio_adjustment, uv_centered.y);
    vec2 adjusted_source = vec2(sound_source_centered.x * aspect_ratio_adjustment, sound_source_centered.y);
    float xy_distance = distance(adjusted_uv, adjusted_source);

    // Key change: Inverted the mask condition
    float mask = 1.0 - step(xy_distance, reveal_radius); 

    float combined_distance = abs(xy_distance * (1.0 - depth_influence) + depth_distance * depth_influence); 

    float noise_value = texture(noise, UV * 2.0 + TIME * vec2(0.1, 0.2)).r;
    float pulse = sin(combined_distance * pulse_intensity - TIME * pulse_frequency + noise_value * 2.0) * 0.5 + 0.5;

    float reveal = smoothstep(0.0, 1.0, pulse) * reveal_amount;

    COLOR = vec4(original_color.rgb * reveal * mask, original_color.a); 
}
