shader_type canvas_item;
uniform sampler2D techno_noise:repeat_enable;
uniform float threshold;
uniform sampler2D grad;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 tex = texture(techno_noise, UV);
	vec4 gradient = texture(grad, UV);
	if(tex.r*2. - gradient.r + sin(TIME) * 0.2 > threshold){
		COLOR.a = 0.;
	}
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
