shader_type spatial;

void emission_multiply(in vec3 emission_color, in vec3 emission_tex, in float energy, out vec3 emission) {
	emission = (emission_color + emission_tex) * energy;
}