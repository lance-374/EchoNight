	shader_type canvas_item;

	uniform vec2 mouse_position;
	uniform float fog_density : hint_range(0.0, 1.0);
	uniform vec2 viewport_size;
	
	void fragment() {
		vec2 uv = FRAGCOORD.xy / viewport_size;
		float dist = distance(uv, mouse_position / viewport_size);
		// Invert the fog effect: more fog where distance is greater
		float fog = smoothstep(0.0, fog_density, dist* 2.0);
		
		// Base color: blueish-black
		vec3 base_color = vec3(0.0, 0.0, 0.2); // A dark blue color
		COLOR = vec4(base_color, fog);
	}
	