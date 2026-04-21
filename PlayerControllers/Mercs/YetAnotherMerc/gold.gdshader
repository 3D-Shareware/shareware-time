shader_type spatial;
render_mode diffuse_toon;

void fragment() {
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	RIM = 0.2;
	METALLIC = 1.0;
	ROUGHNESS = 0.25 * (1.0 - fresnel);
	ALBEDO = vec3(0.92, 0.75, 0.18) + (0.1 * fresnel);
}