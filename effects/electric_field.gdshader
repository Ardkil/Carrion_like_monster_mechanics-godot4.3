shader_type canvas_item;
uniform sampler2D noise:repeat_enable;
uniform sampler2D gradient:repeat_enable;
uniform sampler2D actual_grad;
uniform float threshold;
void fragment() {
	// Called for every pixel the material is visible on.
	vec4 grad = texture(gradient, UV + TIME);
	vec4 ag = texture(actual_grad, UV);
	vec4 noise_ = texture(noise, vec2(UV.x , UV.y + TIME));
	if(noise_.x + grad.x + ag.x< threshold){
		COLOR.a = 0.;
	}
	COLOR.r = 1. - 5.*noise_.x;
	COLOR.g = 1. - grad.x/2.;
	COLOR.b = ag.x + 0.6;
	COLOR.a = ag.x * 1.5;
	
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
