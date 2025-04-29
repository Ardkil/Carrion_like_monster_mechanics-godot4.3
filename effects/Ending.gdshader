shader_type canvas_item;
uniform sampler2D gradient;
uniform float threshold;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 grad = texture(gradient, UV);
	COLOR.a = grad.r ;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
