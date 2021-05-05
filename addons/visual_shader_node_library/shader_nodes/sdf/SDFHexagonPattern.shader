shader_type spatial;

void hexagon_pattern(
	in vec2 offset,
	in vec3 border,
	out vec3 distances,
	out vec3 id
) {
	float c_30 = 0.8660254037844387;
	float s_30 = 0.5;

	vec2 alpha = vec2(0.0, 1.0);
	vec2 beta = vec2(c_30, s_30);
	vec2 gamma = vec2(-c_30, s_30);

	vec2 Xk = vec2(1.0, -1.0) * 0.5 / c_30;
	vec2 alphaX = alpha.yx * Xk;
	vec2 betaX = beta.yx * Xk;
	vec2 gammaX = gamma.yx * Xk;

	vec3 v = vec3(dot(offset, alpha), dot(offset, beta), dot(offset, gamma)) + vec3(0.5);
	vec3 vx = vec3(dot(offset, alphaX), dot(offset, betaX), dot(offset, gammaX));
	vec3 vfr = fract(v);
	vec3 vfrx = fract(vx);
	vec3 vfl = floor(v);
	vec3 vflx = floor(vx);
	
	vec3 vc = min(vfr, vec3(1.0) - vfr) * 2.0;
	vec3 vcx = min(vfrx, vec3(1.0) - vfrx) * 2.0;

	vec3 vmx = step(vcx * 3.0 - 1.0, vc);

	id = mix(vfl + 0.5 * sign(vfr - vec3(0.5)), vfl, vmx);
	distances = border - mix(vec3(1.0) - vc, vc, vmx);
}
