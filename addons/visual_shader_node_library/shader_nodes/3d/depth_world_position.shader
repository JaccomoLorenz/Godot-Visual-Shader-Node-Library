shader_type spatial;

void depth_texture_world_position(in sampler2D depth, in vec2 screen_uv, in mat4 inv_proj_mat, out vec3 world_position) {
	float depth_tex = textureLod(depth, screen_uv.xy, 0.0).r;
	vec4 world_pos = inv_proj_mat * vec4(screen_uv.xy * 2.0 - 1.0, depth_tex * 2.0 - 1.0, 1.0);
	world_position = world_pos.xyz / world_pos.w;
}