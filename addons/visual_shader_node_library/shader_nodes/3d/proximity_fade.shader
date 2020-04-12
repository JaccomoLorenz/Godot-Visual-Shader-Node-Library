shader_type spatial;

// Use own depth_texture_world_position if it is not passed via input port
void proximity_fade_depth_pos(in sampler2D depth, in vec2 screen_uv, in mat4 inv_proj_mat, out vec3 world_position) {
	float depth_tex = textureLod(depth, screen_uv.xy, 0.0).r;
	vec4 world_pos = inv_proj_mat * vec4(screen_uv.xy * 2.0 - 1.0, depth_tex * 2.0 - 1.0, 1.0);
	world_position = world_pos.xyz / world_pos.w;
}

void proximity_fade(in vec3 world_pos, in vec3 vertex, in float fade_distance, out float alpha) {
	alpha = clamp(1.0 - smoothstep(world_pos.z + fade_distance, world_pos.z, vertex.z), 0.0, 1.0);
}