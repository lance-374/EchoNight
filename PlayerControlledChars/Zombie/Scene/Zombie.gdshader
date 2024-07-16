shader_type spatial;

// Uniforms are no longer needed since we're not using them
// uniform float height_scale = 0.5;
// uniform sampler2D noise;
// uniform sampler2D normalmap;

varying vec2 tex_position; 

void vertex() {
    // We still calculate the texture position for consistency, but we don't use it to modify the geometry anymore.
    tex_position = VERTEX.xz / 2.0 + 0.5;
}

void fragment() {
    // Set the output color to black (0, 0, 0)
    ALBEDO = vec3(0.0); 

    // You can also optionally set the alpha to 1.0 for full opacity:
    // ALPHA = 1.0;

    // We're not using the normal map anymore, so we don't need to set NORMAL_MAP.
}
