shader_type particles;
uniform sampler2D texture_imitate;
uniform float min_vel;
uniform float max_vel;

float rand_from_seed(inout uint seed) {
	int k;
	int s = int(seed);
	if (s == 0) {
		s = 305420679;
	}
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0) {
		s += 2147483647;
	}
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}

float rand_from_seed_m1_p1(inout uint seed) {
	return rand_from_seed(seed) * 2.0 - 1.0;
}

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}
void start() {
	uint base_number = NUMBER;
	uint alt_seed = hash(base_number + uint(1) + RANDOM_SEED);
	float vel = mix(min_vel, max_vel, rand_from_seed(alt_seed));
	TRANSFORM[3].xyz = vec3(0.);
	vec2 texture_size = vec2(textureSize(texture_imitate, 0));
	TRANSFORM[3].xy = vec2(mod(float(INDEX),texture_size.x), float(int(INDEX)/int(texture_size.x)));
	COLOR = texelFetch(texture_imitate, ivec2(TRANSFORM[3].xy), 0);
	TRANSFORM[3].xy -= texture_size/2.;
	VELOCITY.xy = TRANSFORM[3].xy * vel;
	if(COLOR.a == 0.){
		ACTIVE = false;
	}
	// Called when a particle is spawned.
}

void process() {
	VELOCITY.y += DELTA * 100.;
	// Called every frame on existing particles (according to the Fixed FPS property).
}
