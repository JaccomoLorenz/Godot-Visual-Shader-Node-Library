shader_type spatial;

void dither(in vec4 fragcoord, in float fade, out float alpha_scissor) {
	int x = int(fragcoord.x) % 4;
	int y = int(fragcoord.y) % 4;
	int index = x + y * 4;
	float limit = 0.0;

	if (x < 8) {
		if (index == 0) limit = 0.0625;
		if (index == 1) limit = 0.5625;
		if (index == 2) limit = 0.1875;
		if (index == 3) limit = 0.6875;
		if (index == 4) limit = 0.8125;
		if (index == 5) limit = 0.3125;
		if (index == 6) limit = 0.9375;
		if (index == 7) limit = 0.4375;
		if (index == 8) limit = 0.25;
		if (index == 9) limit = 0.75;
		if (index == 10) limit = 0.125;
		if (index == 11) limit = 0.625;
		if (index == 12) limit = 1.0;
		if (index == 13) limit = 0.5;
		if (index == 14) limit = 0.875;
		if (index == 15) limit = 0.375;
	}
	// Workaround: Use alpha scissor > 1 for discarding because shader nodes without output will not included
	alpha_scissor = 0.0;
	if (fade < limit) {
		alpha_scissor = 1.1;
		//Discard;
	}
}