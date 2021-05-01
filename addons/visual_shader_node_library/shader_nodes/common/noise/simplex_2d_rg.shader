shader_type spatial;


// Modulo 289, optimizes to code without divisions
vec3 HELPER_HELPER_mod289_3(vec3 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float HELPER_mod289(float x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

// Permutation polynomial (ring size 289 = 17*17)
vec3 HELPER_permute_3(vec3 x) {
	return HELPER_HELPER_mod289_3(((x*34.0)+1.0)*x);
}

float HELPER_permute(float x) {
    return HELPER_mod289(((x * 34.0) + 1.0) * x);
}

// Hashed 2-D gradients with an extra rotation.
// (The constant 0.0243902439 is 1/41)
vec2 HELPER_rgrad2(vec2 p, float rot) {
/*// Map from a line to a diamond such that a shift maps to a rotation.
	float u = HELPER_permute(HELPER_permute(p.x) + p.y) * 0.0243902439 + rot; // Rotate by shift
	u = 4.0 * fract(u) - 2.0;
	// (This vector could be normalized, exactly or approximately.)
	return vec2(abs(u)-1.0, abs(abs(u+1.0)-2.0)-1.0);
*/
// For more isotropic gradients, sin/cos can be used instead.
	float u = HELPER_permute(HELPER_permute(p.x) + p.y) * 0.0243902439 + rot; // Rotate by shift
	u = fract(u) * 6.28318530718; // 2*pi
	return vec2(cos(u), sin(u));
}

//*
//
// 2-D tiling simplex noise with rotating gradients and analytical derivative.
// The first component of the 3-element return vector is the noise value,
// and the second and third components are the x and y partial derivatives.
//
vec3 simplex_noise_2d_rg_p(vec2 pos, vec2 per, float rot) {
    // Hack: offset y slightly to hide some rare artifacts
    pos.y += 0.01;
    // Skew to hexagonal grid
    vec2 uv = vec2(pos.x + pos.y*0.5, pos.y);
    
    vec2 i0 = floor(uv);
    vec2 f0 = fract(uv);
    // Traversal order
    vec2 i1 = (f0.x > f0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    
    // Unskewed grid points in (x,y) space
    vec2 p0 = vec2(i0.x - i0.y * 0.5, i0.y);
    vec2 p1 = vec2(p0.x + i1.x - i1.y * 0.5, p0.y + i1.y);
    vec2 p2 = vec2(p0.x + 0.5, p0.y + 1.0);
    
    // Integer grid point indices in (u,v) space
    i1 = i0 + i1;
    vec2 i2 = i0 + vec2(1.0, 1.0);
    
    // Vectors in unskewed (x,y) coordinates from
    // each of the simplex corners to the evaluation point
    vec2 d0 = pos - p0;
    vec2 d1 = pos - p1;
    vec2 d2 = pos - p2;
    
    // Wrap i0, i1 and i2 to the desired period before gradient hashing:
    // wrap points in (x,y), map to (u,v)
    vec3 xw = mod(vec3(p0.x, p1.x, p2.x), per.x);
    vec3 yw = mod(vec3(p0.y, p1.y, p2.y), per.y);
    vec3 iuw = xw + 0.5 * yw;
    vec3 ivw = yw;
    
    // Create gradients from indices
    vec2 g0 = HELPER_rgrad2(vec2(iuw.x, ivw.x), rot);
    vec2 g1 = HELPER_rgrad2(vec2(iuw.y, ivw.y), rot);
    vec2 g2 = HELPER_rgrad2(vec2(iuw.z, ivw.z), rot);
    
    // Gradients dot vectors to corresponding corners
    // (The derivatives of this are simply the gradients)
    vec3 w = vec3(dot(g0, d0), dot(g1, d1), dot(g2, d2));
    
    // Radial weights from corners
    // 0.8 is the square of 2/sqrt(5), the distance from
    // a grid point to the nearest simplex boundary
    vec3 t = 0.8 - vec3(dot(d0, d0), dot(d1, d1), dot(d2, d2));
    
    // Partial derivatives for analytical gradient computation
    vec3 dtdx = -2.0 * vec3(d0.x, d1.x, d2.x);
    vec3 dtdy = -2.0 * vec3(d0.y, d1.y, d2.y);
    
    // Set influence of each surflet to zero outside radius sqrt(0.8)
    if (t.x < 0.0) {
        dtdx.x = 0.0;
        dtdy.x = 0.0;
        t.x = 0.0;
    }
    if (t.y < 0.0) {
        dtdx.y = 0.0;
        dtdy.y = 0.0;
        t.y = 0.0;
    }
    if (t.z < 0.0) {
        dtdx.z = 0.0;
        dtdy.z = 0.0;
        t.z = 0.0;
    }
    
    // Fourth power of t (and third power for derivative)
    vec3 t2 = t * t;
    vec3 t4 = t2 * t2;
    vec3 t3 = t2 * t;
    
    // Final noise value is:
    // sum of ((radial weights) times (gradient dot vector from corner))
    float n = dot(t4, w);
    
    // Final analytical derivative (gradient of a sum of scalar products)
    vec2 dt0 = vec2(dtdx.x, dtdy.x) * 4.0 * t3.x;
    vec2 dn0 = t4.x * g0 + dt0 * w.x;
    vec2 dt1 = vec2(dtdx.y, dtdy.y) * 4.0 * t3.y;
    vec2 dn1 = t4.y * g1 + dt1 * w.y;
    vec2 dt2 = vec2(dtdx.z, dtdy.z) * 4.0 * t3.z;
    vec2 dn2 = t4.z * g2 + dt2 * w.z;
    
    return 11.0*vec3(n, dn0 + dn1 + dn2);
}

/*/
//
// 2-D tiling simplex noise with rotating gradients,
// but without the analytical derivative.
//
float simplex_noise_2d_rg_p(vec2 pos, vec2 per, float rot) {
    // Offset y slightly to hide some rare artifacts
    pos.y += 0.001;
    // Skew to hexagonal grid
    vec2 uv = vec2(pos.x + pos.y*0.5, pos.y);
    
    vec2 i0 = floor(uv);
    vec2 f0 = fract(uv);
    // Traversal order
    vec2 i1 = (f0.x > f0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    
    // Unskewed grid points in (x,y) space
    vec2 p0 = vec2(i0.x - i0.y * 0.5, i0.y);
    vec2 p1 = vec2(p0.x + i1.x - i1.y * 0.5, p0.y + i1.y);
    vec2 p2 = vec2(p0.x + 0.5, p0.y + 1.0);
    
    // Integer grid point indices in (u,v) space
    i1 = i0 + i1;
    vec2 i2 = i0 + vec2(1.0, 1.0);
    
    // Vectors in unskewed (x,y) coordinates from
    // each of the simplex corners to the evaluation point
    vec2 d0 = pos - p0;
    vec2 d1 = pos - p1;
    vec2 d2 = pos - p2;
    
    // Wrap i0, i1 and i2 to the desired period before gradient hashing:
    // wrap points in (x,y), map to (u,v)
    vec3 xw = mod(vec3(p0.x, p1.x, p2.x), per.x);
    vec3 yw = mod(vec3(p0.y, p1.y, p2.y), per.y);
    vec3 iuw = xw + 0.5 * yw;
    vec3 ivw = yw;
    
    // Create gradients from indices
    vec2 g0 = HELPER_rgrad2(vec2(iuw.x, ivw.x), rot);
    vec2 g1 = HELPER_rgrad2(vec2(iuw.y, ivw.y), rot);
    vec2 g2 = HELPER_rgrad2(vec2(iuw.z, ivw.z), rot);
    
    // Gradients dot vectors to corresponding corners
    // (The derivatives of this are simply the gradients)
    vec3 w = vec3(dot(g0, d0), dot(g1, d1), dot(g2, d2));
    
    // Radial weights from corners
    // 0.8 is the square of 2/sqrt(5), the distance from
    // a grid point to the nearest simplex boundary
    vec3 t = 0.8 - vec3(dot(d0, d0), dot(d1, d1), dot(d2, d2));
    
    // Set influence of each surflet to zero outside radius sqrt(0.8)
    t = max(t, vec3(0.0));
    
    // Fourth power of t
    vec3 t2 = t * t;
    vec3 t4 = t2 * t2;
    
    // Final noise value is:
    // sum of ((radial weights) times (gradient dot vector from corner))
    float n = dot(t4, w);
    
    // Rescale to cover the range [-1,1] reasonably well
    return 11.0*n;
}

//*/

//*
//
// 2-D non-tiling simplex noise with rotating gradients and analytical derivative.
// The first component of the 3-element return vector is the noise value,
// and the second and third components are the x and y partial derivatives.
//
vec3 simplex_noise_2d_rg_np(vec2 pos, float rot) {
    // Offset y slightly to hide some rare artifacts
    pos.y += 0.001;
    // Skew to hexagonal grid
    vec2 uv = vec2(pos.x + pos.y*0.5, pos.y);
    
    vec2 i0 = floor(uv);
    vec2 f0 = fract(uv);
    // Traversal order
    vec2 i1 = (f0.x > f0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    
    // Unskewed grid points in (x,y) space
    vec2 p0 = vec2(i0.x - i0.y * 0.5, i0.y);
    vec2 p1 = vec2(p0.x + i1.x - i1.y * 0.5, p0.y + i1.y);
    vec2 p2 = vec2(p0.x + 0.5, p0.y + 1.0);
    
    // Integer grid point indices in (u,v) space
    i1 = i0 + i1;
    vec2 i2 = i0 + vec2(1.0, 1.0);
    
    // Vectors in unskewed (x,y) coordinates from
    // each of the simplex corners to the evaluation point
    vec2 d0 = pos - p0;
    vec2 d1 = pos - p1;
    vec2 d2 = pos - p2;
    
    vec3 x = vec3(p0.x, p1.x, p2.x);
    vec3 y = vec3(p0.y, p1.y, p2.y);
    vec3 iuw = x + 0.5 * y;
    vec3 ivw = y;
    
    // Avoid precision issues in permutation
    iuw = HELPER_HELPER_mod289_3(iuw);
    ivw = HELPER_HELPER_mod289_3(ivw);
    
    // Create gradients from indices
    vec2 g0 = HELPER_rgrad2(vec2(iuw.x, ivw.x), rot);
    vec2 g1 = HELPER_rgrad2(vec2(iuw.y, ivw.y), rot);
    vec2 g2 = HELPER_rgrad2(vec2(iuw.z, ivw.z), rot);
    
    // Gradients dot vectors to corresponding corners
    // (The derivatives of this are simply the gradients)
    vec3 w = vec3(dot(g0, d0), dot(g1, d1), dot(g2, d2));
    
    // Radial weights from corners
    // 0.8 is the square of 2/sqrt(5), the distance from
    // a grid point to the nearest simplex boundary
    vec3 t = 0.8 - vec3(dot(d0, d0), dot(d1, d1), dot(d2, d2));
    
    // Partial derivatives for analytical gradient computation
    vec3 dtdx = -2.0 * vec3(d0.x, d1.x, d2.x);
    vec3 dtdy = -2.0 * vec3(d0.y, d1.y, d2.y);
    
    // Set influence of each surflet to zero outside radius sqrt(0.8)
    if (t.x < 0.0) {
        dtdx.x = 0.0;
        dtdy.x = 0.0;
        t.x = 0.0;
    }
    if (t.y < 0.0) {
        dtdx.y = 0.0;
        dtdy.y = 0.0;
        t.y = 0.0;
    }
    if (t.z < 0.0) {
        dtdx.z = 0.0;
        dtdy.z = 0.0;
        t.z = 0.0;
    }
    
    // Fourth power of t (and third power for derivative)
    vec3 t2 = t * t;
    vec3 t4 = t2 * t2;
    vec3 t3 = t2 * t;
    
    // Final noise value is:
    // sum of ((radial weights) times (gradient dot vector from corner))
    float n = dot(t4, w);
    
    // Final analytical derivative (gradient of a sum of scalar products)
    vec2 dt0 = vec2(dtdx.x, dtdy.x) * 4.0 * t3.x;
    vec2 dn0 = t4.x * g0 + dt0 * w.x;
    vec2 dt1 = vec2(dtdx.y, dtdy.y) * 4.0 * t3.y;
    vec2 dn1 = t4.y * g1 + dt1 * w.y;
    vec2 dt2 = vec2(dtdx.z, dtdy.z) * 4.0 * t3.z;
    vec2 dn2 = t4.z * g2 + dt2 * w.z;
    
    return 11.0*vec3(n, dn0 + dn1 + dn2);
}

/*/

//
// 2-D non-tiling simplex noise with rotating gradients,
// without the analytical derivative.
//
float simplex_noise_2d_rg_np(vec2 pos, float rot) {
    // Offset y slightly to hide some rare artifacts
    pos.y += 0.001;
    // Skew to hexagonal grid
    vec2 uv = vec2(pos.x + pos.y*0.5, pos.y);
    
    vec2 i0 = floor(uv);
    vec2 f0 = fract(uv);
    // Traversal order
    vec2 i1 = (f0.x > f0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    
    // Unskewed grid points in (x,y) space
    vec2 p0 = vec2(i0.x - i0.y * 0.5, i0.y);
    vec2 p1 = vec2(p0.x + i1.x - i1.y * 0.5, p0.y + i1.y);
    vec2 p2 = vec2(p0.x + 0.5, p0.y + 1.0);
    
    // Integer grid point indices in (u,v) space
    i1 = i0 + i1;
    vec2 i2 = i0 + vec2(1.0, 1.0);
    
    // Vectors in unskewed (x,y) coordinates from
    // each of the simplex corners to the evaluation point
    vec2 d0 = pos - p0;
    vec2 d1 = pos - p1;
    vec2 d2 = pos - p2;
    
    // Wrap i0, i1 and i2 to the desired period before gradient hashing:
    // wrap points in (x,y), map to (u,v)
    vec3 x = vec3(p0.x, p1.x, p2.x);
    vec3 y = vec3(p0.y, p1.y, p2.y);
    vec3 iuw = x + 0.5 * y;
    vec3 ivw = y;
    
    // Avoid precision issues in permutation
    iuw = HELPER_HELPER_mod289_3(iuw);
    ivw = HELPER_HELPER_mod289_3(ivw);
    
    // Create gradients from indices
    vec2 g0 = HELPER_rgrad2(vec2(iuw.x, ivw.x), rot);
    vec2 g1 = HELPER_rgrad2(vec2(iuw.y, ivw.y), rot);
    vec2 g2 = HELPER_rgrad2(vec2(iuw.z, ivw.z), rot);
    
    // Gradients dot vectors to corresponding corners
    // (The derivatives of this are simply the gradients)
    vec3 w = vec3(dot(g0, d0), dot(g1, d1), dot(g2, d2));
    
    // Radial weights from corners
    // 0.8 is the square of 2/sqrt(5), the distance from
    // a grid point to the nearest simplex boundary
    vec3 t = 0.8 - vec3(dot(d0, d0), dot(d1, d1), dot(d2, d2));
    
    // Set influence of each surflet to zero outside radius sqrt(0.8)
    t = max(t, vec3(0.0));
    
    // Fourth power of t
    vec3 t2 = t * t;
    vec3 t4 = t2 * t2;
    
    // Final noise value is:
    // sum of ((radial weights) times (gradient dot vector from corner))
    float n = dot(t4, w);
    
    // Rescale to cover the range [-1,1] reasonably well
    return 11.0*n;
}

//*/
