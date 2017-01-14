/*
 * terran.sl - surface for an Earth-like planet.
 *
 *
 * DESCRIPTION:
 *      When put on a sphere, sets the color to look like relatively
 *   Earth-like.  The shader works by using a variety of fractal 
 *   turbulence and mottling techniques.
 *
 *
 * PARAMETERS:
 *    Ka, Kd - the usual meaning
 *    spectral_exp, lacunarity, octaves - control the fractal characteristics
 *                of the bump pattern.
 *    bump_scale - scaling of the mountains
 *    multifractal - zero uses fBm noise, nonzero uses multifractal
 *    dist_scale - scaling for multifractal distortion
 *    offset - elevation offset
 *    sea_level - obvious
 *    mtn_scale - scaling factor for mountains
 *    lat_scale, nonlinear, purt_scale, map_exp - control scaling of 
 *               terrain type by latitude
 *    ice_caps - latitude at which ice caps tend to form on the oceans
 *    depth_scale, depth_max - scaling factor and max depth of oceans
 *    mottle_limit, mottle_scale, moddle_dim, mottle_mag - control the
 *               mottling that adds detail to lower latitude regions.
 *
 *
 * HINTS:
 *       The default values for the shader assume that the planet is
 *    represented by a unit sphere.  The texture space and/or parameters
 *    to this shader will need to be altered if the size of your planet
 *    is radically different.
 *       For best results, add a cloud layer using either "planetclouds"
 *     or "venusclouds".
 *
 *
 * AUTHOR: Ken Musgrave.
 *    Conversion to Shading Language and minor modifications by Larry Gritz.
 *
 * REFERENCES:
 *    _Texturing and Modeling: A Procedural Approach_, by David S. Ebert, ed.,
 *    F. Kenton Musgrave, Darwyn Peachey, Ken Perlin, and Steven Worley.
 *    Academic Press, 1994.  ISBN 0-12-228760-6.
 *
 * HISTORY:
 *    ???? - original texture developed by F. Ken Musgrave.
 *    Feb 1994 - Conversion to Shading Language by L. Gritz
 *    Apr 1998 - More modern SL and antialiasing by lg
 *
 * last modified 4 Apr 1998 by lg
 */


#include "noises.h"

#define N_OFFSET 0.7
#define VERY_SMALL 0.0001


surface
terran (float Ka = .5, Kd = .7;
	float spectral_exp = 0.5;
	float lacunarity = 2, octaves = 7;
	float bump_scale = 0.07;
	float multifractal = 0;
	float dist_scale = .2;
	float offset = 0;
	float sea_level = 0;
	float mtn_scale = 1;
	float lat_scale = 0.95;
	float nonlinear = 0;
	float purt_scale = .9;
	float map_exp = 0;
	float ice_caps = 0.9;
	float depth_scale = 1;
	float depth_max = .5;
	float mottle_limit = 0.75;
	float mottle_scale = 20;
	float mottle_dim = .25;
	float mottle_mag = .02;)
{
    point PP, P2;
    vector PtN;
    float chaos, latitude, purt;
    color Ct;
    point Ptexture, tp;
    uniform float i;
    float o, weight;      /* Loop variables for fBm calc */
    float bumpy;
    float filtwidth, fw;

    /* Do all shading in shader space */
    Ptexture = transform ("shader", P);
    filtwidth = filterwidthp (Ptexture);
    PtN = normalize (vector Ptexture);  /* Version of Ptexture with radius 1 */

    /**********************************************************************
     * First, figure out where we are in relation to the oceans/mountains.
     * Note: this section of code must be identical to "terranbump" if you
     *       expect these two shaders to work well together.
     **********************************************************************/

    if (multifractal == 0) {	/* use a "standard" fBm bump function */
	bumpy = fBm (Ptexture, filtwidth, octaves, lacunarity, spectral_exp);
    } else {			/* use a "multifractal" fBm bump function */
	/* get "distortion" vector, as used with clouds */
	Ptexture += dist_scale * filteredvsnoise (Ptexture, filtwidth);
	/* compute bump vector using MfBm with displaced point */
	o = spectral_exp;  tp = Ptexture;
	fw = filtwidth;
	weight = abs (filteredVLNoise (tp, fw, 1.5));
	bumpy = weight * filteredsnoise (tp, fw);
	for (i = 1;  i < octaves && weight >= VERY_SMALL && fw < 1;  i += 1) {
	    tp *= lacunarity;  fw *= filtwidth;
	    /* get subsequent values, weighted by previous value */
	    weight *= o * (N_OFFSET + snoise(tp));
	    weight = clamp (abs(weight), 0, 1);
	    bumpy += snoise(tp) * min (weight, spectral_exp);
	    o *= spectral_exp;
	}
    }

    /* make climate symmetric about equator -- use the "v" parameter */
    latitude = abs (zcomp (PtN));

    /* get the "height" of the bump, displacing by offset */
    chaos = bumpy + offset;
    /* set bump for land masses (i.e., areas above "sea level") */
    if (chaos > sea_level) {
	/* Tone the bumps down at the poles, where the ice is. */
	float b = (bump_scale * bumpy) * (1-smoothstep(.6,1,latitude));
	chaos *= mtn_scale;
	P2 = P +  b * normalize(N);
    } else P2 = P;
    N = calculatenormal(P2);

    /************************************************************************
     * Step 2: Assign a climite type, roughly by latitude.
     ************************************************************************/

    /* fractally purturb color map offset using "chaos" */
    /*  "nonlinear" scales purturbation-by-z */
    /*  "purt_scale" scales overall purturbation */
    latitude += chaos*(nonlinear*(1-latitude) + purt_scale);
    if (map_exp > 0)
	latitude = lat_scale * pow(latitude,map_exp);
    else latitude *= lat_scale;
    
    if (chaos > sea_level) {
	/* Choose color of land based on the following spline.
	 * Ken originally had a huge table.  I was too lazy to type it in,
	 * so I used a scanned photo of the real Earth to select some
	 * suitable colors.  -- lg
	 */
	Ct = spline (latitude,
		     color (.5, .39, .2),
		     color (.5, .39, .2),
		     color (.5, .39, .2),
		     color (.2, .3,  0),
		     color (.085, .2, .04),
		     color (.065, .22, .04),
		     color (.5, .42, .28),
		     color (.6, .5, .23),
/*		   color (.976, .820, .471), */
		     color (1,1,1),
		     color (1,1,1));

	/* mottle the color some */
	if (latitude < mottle_limit) {
	    PP = mottle_scale * Ptexture;
	    purt = fBm (PP, mottle_scale*filtwidth, 6, 2, mottle_dim);
	    Ct += (mottle_mag * purt) * (color (0.5,0.175,0.5));
	}
    }
    else { 
	/* Oceans */
	Ct = color(.1,.2,.5);
	if (ice_caps > 0  &&  latitude > ice_caps)
	    Ct = color(1,1,1);  /* Ice color */
	else {
	    /* Adjust color of water to darken deeper seas */
	    chaos -= sea_level;
	    chaos *= depth_scale;
	    chaos = max (chaos, -depth_max);
	    Ct *= (1+chaos);
        }
    }

    /* Shade using matte model */
    Ci = Ct * (Ka * ambient() + Kd * diffuse(faceforward(normalize(N),I)));
    Oi = Os;   Ci *= Oi;
}
