/* I took wave's lead and renamed starfield to KMTerranbump.sl -- tal AT renderman DOT org */

/*
 * terranbump.sl - displacement for an Earth-like planet.
 *
 *
 * DESCRIPTION:
 *      When put on a sphere, makes displacements to make Earth-like
 *   mountains and oceans.  The shader works by using a variety of fractal 
 *   turbulence and mottling techniques.
 *      Note that there is a companion surface shader "terran".  You need
 *   to use exactly the same parameters for "terran" and "terranbump" to
 *   get them to work well together.
 *
 *
 * PARAMETERS:
 *    spectral_exp, lacunarity, octaves - control the fractal characteristics
 *                of the bump pattern.
 *    bump_scale - scaling of the mountains
 *    multifractal - zero uses fBm noise, nonzero uses multifractal
 *    dist_scale - scaling for multifractal distortion
 *    offset - elevation offset
 *    sea_level - obvious
 *
 *
 * HINTS:
 *       The default values for the shader assume that the planet is
 *    represented by a unit sphere.  The texture space and/or parameters
 *    to this shader will need to be altered if the size of your planet
 *    is radically different.
 *       For best results, use with the "terran" surface shader, and
 *    add a cloud layer using either "planetclouds" or "venusclouds".
 *
 *
 * AUTHOR: Ken Musgrave.
 *    Conversion to Shading Language and minor modifications by Larry Gritz.
 *
 *
 * REFERENCES:
 *
 *
 * HISTORY:
 *    ???? - original texture developed by F. Ken Musgrave.
 *    Feb 1994 - Conversion to Shading Language by L. Gritz
 *
 * last modified 1 March 1994 by lg
 */


#ifdef BMRT
#define snoise(x) (2*(noise(x)-0.5))
#else
/* This is because PRMAN's noise has less range than BMRT's */
#define snoise(x) (2.5*(noise(x)-0.5))
#endif

#define DNoise(x) ((2*(point noise(x))) - point(1,1,1))
#define VLNoise(Pt,scale) (snoise(DNoise(Pt)+(scale*Pt)))
#define N_OFFSET 0.7
#define VERY_SMALL 0.0001



displacement
KMTerranbump (float spectral_exp = 0.5;
	    float lacunarity = 2, octaves = 7;
	    float bump_scale = 0.04;
	    float multifractal = 0;
	    float dist_scale = .2;
	    float offset = 0;
	    float sea_level = 0;)
{
  float chaos;
  point Ptexture, tp;
  float l, o, a, i, weight;    /* Loop variables for fBm calc */
  float bumpy;

  /* Do all shading in shader space */
  Ptexture = transform ("shader", P);

  if (multifractal == 0) {	/* use a "standard" fBm bump function */
      o = 1;  l = 1;  bumpy = 0;
      for (i = 0;  i < octaves;  i += 1) {
	  bumpy += o * snoise (l * Ptexture);
	  l *= lacunarity;
	  o *= spectral_exp;
        }
    }
  else {			/* use a "multifractal" fBm bump function */
      /* get "distortion" vector, as used with clouds */
      Ptexture += dist_scale * DNoise (Ptexture);
      /* compute bump vector using MfBm with displaced point */
      o = spectral_exp;  tp = Ptexture;
      weight = abs (VLNoise (tp, 1.5));
      bumpy = weight * snoise (tp);
      for (i = 1;  i < octaves  &&  weight >= VERY_SMALL;  i += 1) {
	  tp *= lacunarity;
	  /* get subsequent values, weighted by previous value */
	  weight *= o * (N_OFFSET + snoise(tp));
	  weight = clamp (abs(weight), 0, 1);
	  bumpy += snoise(tp) * min (weight, spectral_exp);
	  o *= spectral_exp;
	}
    }

  /* get the "height" of the bump, displacing by offset */
  chaos = bumpy + offset;

  /* set bump for land masses (i.e., areas above "sea level") */
  if (chaos > sea_level)
      P += (bump_scale * bumpy) * normalize(Ng);

  /* Recalculate the surface normal (this is where all the real magic is!) */
  N = calculatenormal (P);
}
