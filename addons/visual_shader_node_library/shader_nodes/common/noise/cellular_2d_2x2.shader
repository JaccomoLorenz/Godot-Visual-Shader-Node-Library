shader_type spatial;

// Cellular noise (\"Worley noise\") in 2D in GLSL.
// Copyright (c) Stefan Gustavson 2011-04-19. All rights reserved.
// This code is released under the conditions of the MIT license.
// See LICENSE file for details.
// https://github.com/stegu/webgl-noise

// Modulo 289 without a division (only multiplications)
vec2 HELPER_mod289_2(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 HELPER_mod289_4(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

// Modulo 7 without a division
vec4 HELPER_mod7(vec4 x) {
  return x - floor(x * (1.0 / 7.0)) * 7.0;
}

// Permutation polynomial: (34x^2 + x) mod 289
vec4 HELPER_permute(vec4 x) {
  return HELPER_mod289_4((34.0 * x + 1.0) * x);
}

// Cellular noise, returning F1 and F2 in a vec2.
// Speeded up by using 2x2 search window instead of 3x3,
// at the expense of some strong pattern artifacts.
// F2 is often wrong and has sharp discontinuities.
// If you need a smooth F2, use the slower 3x3 version.
// F1 is sometimes wrong, too, but OK for most purposes.
vec2 cellular_noise_2d_2x2(vec2 P, float jitter) {
    float K = 0.142857142857; // 1/7
    float K2 = 0.0714285714285; // K/2

    vec2 Pi = HELPER_mod289_2(floor(P));
    vec2 Pf = fract(P);
    vec4 Pfx = Pf.x + vec4(-0.5, -1.5, -0.5, -1.5);
    vec4 Pfy = Pf.y + vec4(-0.5, -0.5, -1.5, -1.5);
    vec4 p = HELPER_permute(Pi.x + vec4(0.0, 1.0, 0.0, 1.0));
    p = HELPER_permute(p + Pi.y + vec4(0.0, 0.0, 1.0, 1.0));
    vec4 ox = HELPER_mod7(p)*K+K2;
    vec4 oy = HELPER_mod7(floor(p*K))*K+K2;
    vec4 dx = Pfx + jitter*ox;
    vec4 dy = Pfy + jitter*oy;
    vec4 d = dx * dx + dy * dy; // d11, d12, d21 and d22, squared
    // Sort out the two smallest distances

/*// F1 Only Block (works faster of course)
    d.xy = min(d.xy, d.zw);
    d.x = min(d.x, d.y);
    return vec2(sqrt(d.x)); // F1 duplicated, F2 not computed
//*/// End of F1 Only Block

//*// F1 and F2 block
    d.xy = (d.x < d.y) ? d.xy : d.yx; // Swap if smaller
    d.xz = (d.x < d.z) ? d.xz : d.zx;
    d.xw = (d.x < d.w) ? d.xw : d.wx;
    d.y = min(d.y, d.z);
    d.y = min(d.y, d.w);
    return sqrt(d.xy);
//*/// End of F1 and F2 block
}
