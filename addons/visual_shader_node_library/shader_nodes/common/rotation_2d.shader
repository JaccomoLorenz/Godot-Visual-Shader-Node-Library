shader_type spatial;

void rotation_2d(float angle, vec3 pivot, in vec3 position_in,  out vec3 position_out) {
	mat2 rotation_matrix = mat2( vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
	position_in -= pivot;
	position_out.xy = rotation_matrix * position_in.xy;
	position_out.z = position_in.z;
	position_out += pivot;
	
}