/*****************************************************************************
 * JBUMhexscales.sl - Maize / Snakescales - Jim Bumgardner  jbum@SpamSucks_jbum.com
 *
 * Suitable for both Corn Snakes, and Corn (which the snakes mimic)
 *
 * This shader uses a hexagonal variant of voronoi noise - if you set
 * jitter to 0, you'll see the base tiles are hexagons rather than 
 * squares.
 *
 * Suggested Improvements: Work on overall slope of pertubation 
 * across the tile to suggest overlapping nature of scales.
 *
 *****************************************************************************/
#include "noises.h"
#include "material.h"

/* Voronoi cell noise (a.k.a. Worley noise) -- 2-D, 2-feature version.
   with hexagonal interleave - Jim Bumgardner
   
   Note: For jitter values close to 1, there will be a few artifacts due
   to cells being pushed outside the area of examination.  These can be eliminated 
   by looping i & j from -1 to 2, instead of -1 to 1.
   For jitter = .5 (which I typically use), this is fine.
   */
void voronoi_f1f2_2dHex (
		 float ss, tt;
		 float jitter;
		 output float f1;
		 output float spos1, tpos1;
		 output float f2;
		 output float spos2, tpos2;
    )
{
  float sthiscell = floor(ss)+.5, tthiscell = floor(tt)+.5;  /* was floor()+.5 */
	float	ofst;
	f1 = f2 = 1000;

	uniform float i, j;

	for (i = -1;  i <= 1;  i += 1) 
	{
		float stestcell = sthiscell + i;

		/* Introduce Hexagon Offset */
		if (floor((stestcell)/2)*2 != floor((stestcell)))
			ofst = .5;
		else
			ofst= 0;

		for (j = -1;  j <= 1;  j += 1) 
		{
			float ttestcell = tthiscell + j;			

			float spos = stestcell + jitter * (cellnoise(ttestcell, stestcell) - 0.5);
			float tpos = ttestcell+ofst + jitter * (cellnoise(ttestcell+23, stestcell-87) - 0.5);
			float soffset = spos - ss;
			float toffset = tpos - tt;
			float dist = soffset*soffset + toffset*toffset;
			if (dist < f1) 
			{
				f2 = f1;  spos2 = spos1;  tpos2 = tpos1;
				f1 = dist;  spos1 = spos;  tpos1 = tpos;
			} else if (dist < f2) 
			{
				f2 = dist;
				spos2 = spos;  tpos2 = tpos;
			}
		}
	}
	f1 = sqrt(f1);  f2 = sqrt(f2);
}

surface
 JBUMhexscales ( float Ka = 1, Kd = 0.7, spec = 0.4, roughness = 0.2;
 						  	  float Km = 0.02;                          /* scale bumpiness */
 						  	  float scale=40;                           /* scale size */
 						  	  float jitter = .5;                        /* scale random placement */
 						  	  float linethick = .0022;                  /* thickness of scale outlining */
									color darkcolor=(0.257, 0.116, 0.104);    /* darkest scale color (and scale outline color) */
									color lightcolor=(0.830, 0.547, 0.359);   /* lightest scale color */
									float	noiseamp = 0.05; 										/* controls scale bumpiness */
 						  	 )
{
	float r1, spos1, tpos1;
	float r2, spos2, tpos2, lt;
	float	pert = 0, cmix, varycolor;
	color	Ct;

	voronoi_f1f2_2dHex(s*scale,t*scale,jitter,r1,spos1,tpos1,r2,spos2,tpos2);
	varycolor = cellnoise(spos1+.5, tpos1+.5);

	lt = linethick;
	cmix = smoothstep(scale*lt*.9,scale*lt*1.1, r2-r1);

	pert = 1-r1*r1+fBm_default(point(s*scale*24,t*scale*18,0))*noiseamp;
	
	Ct = mix(darkcolor, lightcolor, varycolor*cmix);
  
	P += Km*pert*normalize(N);
	N = calculatenormal(P);	

  Ci = MaterialPlastic (normalize (faceforward (normalize(N), I)), Ct, Ka, Kd, spec, roughness);
  Oi = Os;  Ci *= Oi;
}
