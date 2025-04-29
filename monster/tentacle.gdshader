shader_type canvas_item;
uniform float amplitute;
uniform float wavelength;
uniform float speed;
void fragment() {
	vec4 tex = texture(TEXTURE, vec2(UV.x, UV.y + amplitute*sin(TIME*speed + UV.x* wavelength)));
	COLOR = tex;
	// Called for every pixel the material is visible on.
}

