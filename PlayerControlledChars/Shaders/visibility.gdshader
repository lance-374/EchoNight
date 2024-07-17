shader_type canvas_item;

uniform vec2 displacement = vec2(0.0, 0.0);
uniform vec2 scale = vec2(1.0, 1.0);
uniform vec2 velocity = vec2(1.0, 1.0);
uniform vec4 fog_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform sampler2D noise: repeat_enable;
uniform vec3 audio_source_position; // New uniform for audio source XYZ

void fragment() {
    // Calculate distance from fragment to audio source
    float distance_to_audio = distance(vec3(UV, 0.0), audio_source_position);

    // Use distance to adjust the UV coordinates for sampling
    vec2 fixed_uv = displacement + scale * UV + TIME * velocity + vec2(distance_to_audio * 0.1); // Example scaling factor

    float fog = texture(noise, fixed_uv).r;
    
    // Optionally, adjust fog intensity based on distance
    fog *= 1.0 - smoothstep(0.0, 5.0, distance_to_audio); // Example falloff

    COLOR = mix(vec4(0.0), fog_color, fog);
}
