shader_type spatial;

void depth(in vec3 uv_in, in vec3 depth_texture, in float depth_scale, in vec3 vertex, in vec3 normal, in vec3 tangent, in vec3 binormal, in vec3 depth_flip, out vec3 uv_out) {
	vec3 view_dir = normalize( normalize( -vertex ) * mat3(tangent * depth_flip.x, -binormal * depth_flip.y, normal));
	uv_out.xy = uv_in.xy - view_dir.xy / view_dir.z * (depth_texture.r * depth_scale);
}