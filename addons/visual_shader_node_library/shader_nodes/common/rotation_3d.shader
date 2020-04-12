shader_type spatial;

mat4 rotation_matrix_3d(vec3 axis, float angle){
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat4(vec4(oc * axis.x * axis.x + c,			oc * axis.x * axis.y - axis.z * s,	oc * axis.z * axis.x + axis.y * s,	0.0),
                vec4(oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c,			oc * axis.y * axis.z - axis.x * s,	0.0),
                vec4(oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, 	oc * axis.z * axis.z + c,			0.0),
                vec4(0.0,								0.0, 								0.0,								1.0));
}

void rotation_3d_normal(vec3 axis, float angle, in vec3 normal_in, out vec3 normal_out) {
	normal_out = (rotation_matrix_3d(axis, angle) * vec4(normal_in, 0.0)).xyz;
}

void rotation_3d(vec3 axis, float angle, vec3 pivot, in vec3 position_in, out vec3 position_out) {
	position_in.xyz -= pivot;
	vec4 position = vec4(position_in, 1.0);
	position_out = (rotation_matrix_3d(axis, angle) * position).xyz;
	position_out += pivot;
}