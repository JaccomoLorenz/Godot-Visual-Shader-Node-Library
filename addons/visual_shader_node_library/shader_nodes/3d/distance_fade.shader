shader_type spatial;

void distance_fade(in vec3 vertex, in float distance_min, in float distance_max, out float alpha) {
	alpha = clamp(smoothstep(distance_min, distance_max, -vertex.z), 0.0, 1.0);
}