shader_type spatial;

uniform sampler2D depth_texture : source_color, hint_depth_texture;

void vertex() {
	
	}


void fragment() {
	vec4 color;
	
	color.r = 0.0;
	color.g = 0.0;
	color.b = 0.0;
	color = vec4(0.8, 0.0, 0.0, 1.0);  // Set only the RGB channels
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
