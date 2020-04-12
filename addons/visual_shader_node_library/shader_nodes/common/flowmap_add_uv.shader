shader_type spatial;

void flow_map_add_uv(in vec3 uv, in float uv_scale, in vec3 layer1, in vec3 layer2, out vec3 uv1, out vec3 uv2) {
	vec3 uv_data = uv * uv_scale;
	uv1 = layer1 + uv_data;
	uv2 = layer2 + uv_data;
}