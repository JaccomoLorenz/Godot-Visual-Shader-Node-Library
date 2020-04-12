shader_type spatial;

void refraction(in float texture_value, in float refraction_scale, in float roughness, in vec3 albedo_in, in float alpha, in vec3 emission_in, in vec3 ref_normal, in vec2 screen_uv, in sampler2D screen_texture, out vec3 albedo_out, out vec3 emission_out) { 
	vec2 ref_ofs = screen_uv.xy - ref_normal.xy * texture_value * refraction_scale;
	float ref_amount = 1.0 - alpha;
	emission_out = emission_in + textureLod(screen_texture, ref_ofs, roughness * 8.0).rgb * ref_amount;
	albedo_out = albedo_in * vec3(1.0 - ref_amount);
}