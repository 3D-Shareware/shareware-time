shader_type spatial;
render_mode diffuse_toon;

uniform sampler2D noise;

float height(vec2 position, float time) {
  vec2 offset = 0.25 * cos(position + time);
  return texture(noise, (position / 10.0) - offset).x;
}

void vertex() {
	vec2 pos = VERTEX.xz;
	float k = height(pos, TIME);
	VERTEX.y *= 1.625 * k;
	NORMAL = normalize(vec3(k - height(pos + vec2(0.1, 0.0), TIME), 0.1, k - height(pos + vec2(0.0, 0.1), TIME)));
}

void fragment() {
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	RIM = 0.2;
	METALLIC = 1.0;
	ROUGHNESS = 0.25 * (1.0 - fresnel);
	ALBEDO = vec3(0.92, 0.75, 0.18) + (0.1 * fresnel);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}

// Most of this code is copied from the Godot shader tutorial. It's quite cool
// https://docs.godotengine.org/en/stable/tutorials/shaders/your_first_shader/your_second_3d_shader.html