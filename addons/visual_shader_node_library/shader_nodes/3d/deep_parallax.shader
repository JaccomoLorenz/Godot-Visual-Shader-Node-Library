shader_type spatial;
uniform sampler2D texture_parallax_default : hint_black;

void deep_parallax(in vec3 uv_in, in sampler2D depth_texture, in float depth_scale, in float min_layers, in float max_layers, in vec3 vertex, in vec3 normal, in vec3 tangent, in vec3 binormal, in vec3 depth_flip, out vec3 uv_out) {
	vec3 view_dir = normalize(normalize(-vertex) * mat3( tangent * depth_flip.x, -binormal * depth_flip.y, normal));
	float num_layers = mix( max_layers, min_layers, abs(dot(vec3(0.0, 0.0, 1.0), view_dir)));
	float layer_depth = 1.0 / num_layers;
	float current_layer_depth = 0.0;
	vec2 P = view_dir.xy * depth_scale;
	vec2 delta = P / num_layers;
	vec2 ofs = uv_in.xy;
	float depth = textureLod(depth_texture, ofs, 0.0).r;
	float current_depth = 0.0;
	while(current_depth < depth) {
		ofs -= delta;
		depth = textureLod(depth_texture, ofs, 0.0).r;
		current_depth += layer_depth;
	}
	vec2 prev_ofs = ofs + delta;
	float after_depth  = depth - current_depth;
	float before_depth = textureLod(depth_texture, prev_ofs, 0.0).r - current_depth + layer_depth;
	float weight = after_depth / (after_depth - before_depth);
	uv_out.xy = mix(ofs, prev_ofs, weight);
}