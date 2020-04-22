shader_type spatial;

const int SSR_MAX_STEPS = 256;

vec3 line_plane_intersect(vec3 lineorigin, vec3 linedirection, vec3 planeorigin, vec3 planenormal) {
	float dist = dot(planenormal, planeorigin - lineorigin) / dot(planenormal, linedirection);
	return lineorigin + linedirection * dist;
}

float line_unit_box_intersect_dist(vec3 lineorigin, vec3 linedirection) {
  /* https://seblagarde.wordpress.com/2012/09/29/image-based-lighting-approaches-and-parallax-corrected-cubemap/
   */
  vec3 firstplane = (vec3(1.0) - lineorigin) / linedirection;
  vec3 secondplane = (vec3(-1.0) - lineorigin) / linedirection;
  vec3 furthestplane = max(firstplane, secondplane);

  return min(furthestplane.x, min(furthestplane.y, furthestplane.z));
}

vec3 get_specular_refraction_dominant_dir(vec3 N, vec3 V, float ssr_roughness, float ssr_ior) {
	/* TODO: This a bad approximation. Better approximation should fit
	* the refracted vector and ssr_roughness into the best prefiltered reflection
	* lobe. */
	/* Correct the ssr_ior for ssr_ior < 1.0 to not see the abrupt delimitation or the TIR */
	ssr_ior = (ssr_ior < 1.0) ? mix(ssr_ior, 1.0, ssr_roughness) : ssr_ior;
	float eta = 1.0 / ssr_ior;
	
	float NV = dot(N, -V);
	
	/* Custom Refraction. */
	float k = 1.0 - eta * eta * (1.0 - NV * NV);
	k = max(0.0, k); /* Only this changes. */
	vec3 R = eta * -V - (eta * NV + sqrt(k)) * N;
	
	return R;
}

vec3 project_point(mat4 projection_matrix, vec3 point) {
	vec4 ndc = projection_matrix * vec4(point, 1.0);
	return ndc.xyz / ndc.w;
}

float F_eta(float eta, float cos_theta) {
	/* compute fresnel reflectance without explicitly computing
	* the refracted direction */
	float c = abs(cos_theta);
	float g = eta * eta - 1.0 + c * c;
	float result;
	
	if (g > 0.0) {
		g = sqrt(g);
		vec2 g_c = vec2(g) + vec2(c, -c);
		float A = g_c.y / g_c.x;
		A *= A;
		g_c *= c;
		float B = (g_c.y - 1.0) / (g_c.x + 1.0);
		B *= B;
		result = 0.5 * A * (1.0 + B);
	} else {
		result = 1.0; /* TIR (no refracted component) */
	}
	
	return result;
}

void prepare_raycast(mat4 projection_matrix, vec3 ray_origin, vec3 ray_dir, float ssr_thickness, vec2 pixel_size, out vec4 ss_step, out vec4 ss_ray, out float max_time) {
	/* Negate the ray direction if it goes towards the camera.
	* This way we don't need to care if the projected point
	* is behind the near plane. */
	float z_sign = -sign(ray_dir.z);
	vec3 ray_end = ray_origin + z_sign * ray_dir;
	
	/* Project into screen space. */
	vec4 ss_start, ss_end;
	ss_start.xyz = project_point(projection_matrix, ray_origin);
	ss_end.xyz = project_point(projection_matrix, ray_end);
	
	/* We interpolate the ray Z + ssr_thickness values to check if depth is within threshold. */
	ray_origin.z -= ssr_thickness;
	ray_end.z -= ssr_thickness;
	ss_start.w = project_point(projection_matrix, ray_origin).z;
	ss_end.w = project_point(projection_matrix, ray_end).z;
	
	/* XXX This is a hack. A better method is welcome! */
	/* We take the delta between the offsetted depth and the depth and subtract it from the ray
	* depth. This will change the world space ssr_thickness appearance a bit but we can have negative
	* values without worries. We cannot do this in viewspace because of the perspective division. */
	ss_start.w = 2.0 * ss_start.z - ss_start.w;
	ss_end.w = 2.0 * ss_end.z - ss_end.w;
	
	ss_step = ss_end - ss_start;
	max_time = length(ss_step.xyz);
	ss_step = z_sign * ss_step / length(ss_step.xyz);
	
	/* If the line is degenerate, make it cover at least one pixel
	* to not have to handle zero-pixel extent as a special case later */
	ss_step.xy += vec2((dot(ss_step.xy, ss_step.xy) < 0.00001) ? 0.001 : 0.0);
	
	/* Make ss_step cover one pixel. */
	ss_step /= max(abs(ss_step.x), abs(ss_step.y));
	ss_step *= (abs(ss_step.x) > abs(ss_step.y)) ? pixel_size.x : pixel_size.y;
	
	/* Clip to segment's end. */
	max_time /= length(ss_step.xyz);
	
	/* Clipping to frustum sides. */
	max_time = min(max_time, line_unit_box_intersect_dist(ss_start.xyz, ss_step.xyz));
	
	/* Convert to texture coords. Z component included
	* since this is how it's stored in the depth buffer.
	* 4th component how far we are on the ray */
	ss_ray = ss_start * 0.5 + 0.5;
	ss_step *= 0.5;
	
	/* take the center of the texel. */
}

// #define GROUPED_FETCHES /* is still slower, need to see where is the bottleneck. */
/* Return the hit position, and negate the z component (making it positive) if not hit occurred. */
/* __ray_dir__ is the ray direction premultiplied by it's maximum length */
vec3 raycast(mat4 projection_matrix, sampler2D depth_texture, vec3 ray_origin, vec3 ray_dir, float ssr_thickness, float ray_jitter, float trace_quality, float ssr_roughness, bool discard_backface) {
	vec4 ss_step, ss_start;
	float max_time;
	prepare_raycast(projection_matrix, ray_origin, ray_dir, ssr_thickness, 1.0 / vec2(textureSize(depth_texture, 0)), ss_step, ss_start, max_time);
	
	float max_trace_time = max(0.01, max_time - 0.01);
	
	/* x : current_time, y: previous_time, z: current_delta, w: previous_delta */
	vec4 times_and_deltas = vec4(0.0);
	
	float ray_time = 0.0;
	float depth_sample = textureLod(depth_texture, ss_start.xy, 0.0).x;
	times_and_deltas.z = depth_sample - ss_start.z;
	
	float lod_fac = clamp(sqrt(ssr_roughness) * 2.0 - 0.4, 0.0, 1.0);
	bool hit = false;
	float iter;
	for(iter = 1.0; !hit && (ray_time < max_time) && (iter < float(SSR_MAX_STEPS)); iter++) {
		/* Minimum stride of 2 because we are using half res minmax zbuffer. */
		float stride = max(1.0, iter * trace_quality) * 2.0;
		float lod = log2(stride * 0.5 * trace_quality) * lod_fac;
		ray_time += stride;
		
		/* Save previous values. */
		times_and_deltas.xyzw = times_and_deltas.yxwz;
		
		float jit_stride = mix(2.0, stride, ray_jitter);
		
		times_and_deltas.x = min(ray_time + jit_stride, max_trace_time);
		vec4 ss_ray = ss_start + ss_step * times_and_deltas.x;
		
		depth_sample = textureLod(depth_texture, ss_ray.xy, lod).x;
		
		float prev_w = ss_start.w + ss_step.w * times_and_deltas.y;
		times_and_deltas.z = depth_sample - ss_ray.z;
		hit = (times_and_deltas.z <= 0.0) && (prev_w <= depth_sample);
	}
	
	if (discard_backface) {
		/* Discard backface hits */
		hit = hit && (times_and_deltas.w > 0.0);
	}
	
	/* Reject hit if background. */
	hit = hit && (depth_sample != 1.0);
	
	times_and_deltas.x = hit ? mix(times_and_deltas.y, times_and_deltas.x, clamp(times_and_deltas.w / (times_and_deltas.w - times_and_deltas.z), 0.0, 1.0)) : times_and_deltas.x;
	ray_time = hit ? times_and_deltas.x : ray_time;
	
	/* Clip to frustum. */
	ray_time = max(0.001, min(ray_time, max_time - 1.5));
	
	vec4 ss_ray = ss_start + ss_step * ray_time;
	
	/* Tag Z if ray failed. */
//	ss_ray.z *= (hit) ? 1.0 : -1.0;
	return ss_ray.xyz;
}

float screen_border_mask(vec2 hit_co) {
	const float ssrBorderFac = 0.1;
	
	const float margin = 0.003;
	float atten = ssrBorderFac + margin; /* Screen percentage */
	hit_co = smoothstep(margin, atten, hit_co) * (1.0 - smoothstep(1.0 - atten, 1.0 - margin, hit_co));
	float screenfade = hit_co.x * hit_co.y;
	return screenfade;
}

vec4 ssr(vec3 position, mat4 projection_matrix, mat4 view_matrix, sampler2D screen_texture, sampler2D depth_texture, vec3 N, vec3 V, float ssr_ior, float ssr_roughnessSquared) {
	float a2 = max(5e-6, ssr_roughnessSquared * ssr_roughnessSquared);
	
	vec3 H = N;
	float pdf = 0.0;
	
	vec3 vV = V;
	float eta = 1.0 / ssr_ior;
	if (dot(H, V) < 0.0) {
		H = -H;
		eta = ssr_ior;
	}
	
	vec3 R = refract(-V, H, 1.0 / ssr_ior);
	
	R = (view_matrix * vec4(R, 0.0)).xyz;
	
	const float ssrssr_thickness = 1.0;
	const float ssrQuality = 0.0;
	
	vec3 hit_pos = raycast(projection_matrix, depth_texture, position, R * 1e16, ssrssr_thickness, 0.0, ssrQuality, ssr_roughnessSquared, false);
	
	if ((hit_pos.z > 0.0) && (F_eta(ssr_ior, dot(H, V)) < 1.0)) {
		vec2 hit_uvs = project_point(projection_matrix, hit_pos).xy * 0.5 + 0.5;
		
		vec3 spec = textureLod(screen_texture, hit_pos.xy, ssr_roughnessSquared * 8.0).xyz;
		float mask = screen_border_mask(hit_uvs);
		return vec4(spec, mask);
	}
	
	return vec4(0.0);
}

void screenspace_refraction(in float ssr_ior, in float ssr_roughness, in float ssr_thickness, in vec3 albedo_in, in float alpha_in, in vec3 emission_in, in vec2 screen_uv, in sampler2D screen_texture, in sampler2D depth_texture, in vec3 view, in vec3 normal, in vec3 position, in mat4 view_matrix, in mat4 camera_matrix, in mat4 projection_matrix, out vec3 albedo_out, out vec3 emission_out) { 
	vec3 V = (camera_matrix * vec4(view, 0.0)).xyz;
	vec3 N = (camera_matrix * vec4(normal, 0.0)).xyz;
	vec3 world_pos = (camera_matrix * vec4(position, 1.0)).xyz;
	
	/* Refract the view vector using the depth heuristic.
	* Then later Refract a second time the already refracted
	* ray using the inverse ssr_ior. */
	float final_ior = (ssr_thickness > 0.0) ? 1.0 / ssr_ior : ssr_ior;
	vec3 refr_V = (ssr_thickness > 0.0) ? -refract(-V, N, final_ior) : V;
	vec3 refr_pos = (ssr_thickness > 0.0) ?
			line_plane_intersect(world_pos, refr_V, world_pos - N * ssr_thickness, N) :
			world_pos;
	vec3 refr_dir = get_specular_refraction_dominant_dir(N, refr_V, ssr_roughness, final_ior);
	
	/* ---------------------------- */
	/*   Screen Space Refraction    */
	/* ---------------------------- */
	/* Find approximated position of the 2nd refraction event. */
	vec3 refr_vpos = (ssr_thickness > 0.0) ? (view_matrix * vec4(refr_pos, 1.0)).xyz :
			position;
	vec4 trans = ssr(refr_vpos, projection_matrix, view_matrix, screen_texture, depth_texture, N, refr_V, final_ior, ssr_roughness * ssr_roughness);
	trans.a *= smoothstep(1.0 + 0.2, 1.0, ssr_roughness);
	
	float fac = 1.0 - alpha_in;
	fac *= 1.0 - pow(1.0 - dot(V, N), 5.0) * (1.0 - ssr_roughness);
	
	emission_out = emission_in + trans.rgb * albedo_in * fac;
	albedo_out = albedo_in * 1.0 - fac;
}
