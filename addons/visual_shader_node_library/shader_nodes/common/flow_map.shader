shader_type spatial;

void flow_map(vec3 flow_map, float blend_cycle, float speed, vec3 uv, vec3 direction, float offset, float time, out float blend_factor, out vec3 layer1, out vec3 layer2, out float flow_strength) {
	float half_cycle = blend_cycle * 0.5;
	
	float t = time * speed + offset;
	float phase1 = mod(t, blend_cycle);
	float phase2 = mod(t + half_cycle, blend_cycle);
	
	// Blend factor to mix the two layers
	blend_factor = abs(half_cycle - phase1) / half_cycle;
	
	// Offset by halfCycle to improve the animation for color
	// Not absolutely necessary for normalmaps
	phase1 -= half_cycle;
	phase2 -= half_cycle;
	
	vec2 flow = flow_map.xy * 2.0 - 1.0;
	flow *= normalize(direction.xy);
	
	layer1.xy = flow * phase1;
	layer2.xy = flow * phase2;
	
	// Flow intensity
	flow_strength = length(abs(flow));
}