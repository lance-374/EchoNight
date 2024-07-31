shader_type spatial;
render_mode unshaded, depth_draw_always;

// Uniform Parameters
uniform float audio_intensity : hint_range(0, 1) = 0.5;
uniform float wave_frequency = 0.7;
uniform float max_distance = 1.0; // Adjust for larger range if needed
uniform float wave_speed = 1.0;
uniform float threshold : hint_range(0, 1) = 0.1; // Lower threshold for more visible effect
uniform vec3 player_position;
uniform vec3 audio_source_position; // Position of the audio source
uniform vec3 sweep_direction = vec3(1.0, 0.0, 0.0); // Direction of the sweeping motion
uniform float wave_variation = 0.2;
uniform float noise_scale = 1.0;
uniform bool isHuman = false;

// Delay parameters
uniform float delay_duration = 0.8; // Reduced for faster fading
uniform float last_time = 0.0;

// Visual enhancements
uniform float pulse_thickness = 0.1; // Thickness of the wave pulse
const vec3 echo_color = vec3(0.0, 0.8, 1.0); // Cyan color for echolocation
const vec3 fade_color = vec3(0.2, 0.2, 0.2); // Faded color for visual effect
const vec3 human_color = vec3(1.0, 0.0, 0.0); // Bright red color for humans

varying float var_intensity;

// Noise function for variation
float noise(vec3 p) {
    return 0.5 * sin(p.x) + 0.25 * sin(p.y) + 0.125 * sin(p.z);
}

void vertex() {
    // Direction and distance from player
    vec3 direction_to_fragment_from_player = VERTEX - player_position;
    float dist_from_player = length(direction_to_fragment_from_player);

    // Direction and distance from audio source
    vec3 direction_to_fragment_from_audio_source = VERTEX - audio_source_position;
    float dist_from_audio_source = length(direction_to_fragment_from_audio_source);

    // Calculate sweep effect based on a directional vector
    float sweep_effect = dot(normalize(direction_to_fragment_from_player), normalize(sweep_direction));

    // Base wave calculation with sweep effect
    float base_wave = sin(TIME * wave_speed + (dist_from_player + sweep_effect * max_distance) * wave_frequency);
    base_wave = (base_wave + 1.0) * 0.5;

    // Add noise for visual variation
    vec3 noise_pos = player_position * noise_scale + vec3(TIME * wave_speed);
    float noise_value = noise(noise_pos);
    float varied_wave = base_wave + (noise_value * 2.0 - 1.0) * wave_variation;
    varied_wave = clamp(varied_wave, 0.0, 1.0);

    // Adjust wave frequency and variation if isHuman is true
    float human_wave_frequency = isHuman ? wave_frequency * 3.0 : wave_frequency; // Increase frequency if human
    float human_wave_variation = isHuman ? wave_variation * 2.0 : wave_variation; // Increase variation if human

    // Base wave calculation with adjusted frequency and variation if isHuman is true
    base_wave = sin(TIME * wave_speed + (dist_from_player + sweep_effect * max_distance) * human_wave_frequency);
    base_wave = (base_wave + 1.0) * 0.5;

    // Add noise for visual variation
    noise_pos = player_position * noise_scale + vec3(TIME * wave_speed);
    noise_value = noise(noise_pos);
    varied_wave = base_wave + (noise_value * 2.0 - 1.0) * human_wave_variation;
    varied_wave = clamp(varied_wave, 0.0, 1.0);

    

    // Calculate final intensity considering both attenuations
    var_intensity = max(varied_wave * audio_intensity , 0.01);
}

void fragment() {
    float pulse_factor = smoothstep(0.0, pulse_thickness, var_intensity) 
                - smoothstep(pulse_thickness, 2.0 * pulse_thickness, var_intensity);

    // Delay fading
    float intensity = var_intensity * pulse_factor;
    if (intensity < threshold) {
        float time_since_drop = TIME - last_time;
        if (time_since_drop < delay_duration) {
            intensity = mix(threshold, intensity, time_since_drop / delay_duration);
        } else {
            intensity = 0.0;
        }
    }

    // Final color calculation
    vec3 final_color;
    if (isHuman) {
        final_color = human_color; 
    } else {
        final_color = mix(fade_color, echo_color, step(threshold, intensity));
    }

    ALBEDO = final_color * intensity;
}


