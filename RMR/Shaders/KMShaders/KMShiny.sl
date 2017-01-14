/* I took wave's lead and renamed starfield to KMShiny.sl -- tal AT renderman DOT org */

/*
 * shiny.sl -- Shiny metal surface, using ray tracing.
 *
 * DESCRIPTION:
 *   Makes a smoothly polished metal, using ray tracing to calculate
 *   reflections of the environment.
 * 
 * PARAMETERS:
 *    Ka, Kd, Ks, roughness, specularcolor - The usual meaning
 *    Kr - coefficient for mirror-like reflections of environment
 *    blur - how blurry are the reflections? (0 = perfectly sharp)
 *    samples - set to higher than 1 for oversampling of blur
 *
 * AUTHOR: written by Larry Gritz, 1991
 *
 * HISTORY:
 *      Aug 1991 -- written by lg in C
 *      25 Jan 1994 -- recoded by lg in correct shading language.
 *
 * last modified 25 Jan 1994 by Larry Gritz
 */


surface
KMShiny ( float Ka = 1, Kd = 0.5, Ks = 1;
	float Kr = 0.5, roughness = 0.005, blur = 0;
	color specularcolor = 1;
	float samples = 1; )
{
  point Nf;               /* Forward facing normal vector */
  point IN;               /* normalized incident vector */
  point Rdir;             /* Smooth reflection direction */
  point uoffset, voffset; /* Offsets for blur */
  color ev;               /* Color of the reflections */
  point R;                /* Direction to cast the ray */
  float i;

  /* Construct a forward facing surface normal */
  Nf = faceforward (normalize(N), I);
  IN = normalize (I);
  ev = 0;

  /* Calculate the reflection color */
  if (Kr > 0) {
      /* Rdir gets the perfect reflection direction */
      Rdir = normalize (reflect (IN, Nf));

      if (blur > 0) {
	  /* Construct orthogonal components to Rdir */
	  uoffset = normalize (point (zcomp(Rdir) - ycomp(Rdir),
				      xcomp(Rdir) - zcomp(Rdir),
				      ycomp(Rdir) - xcomp(Rdir)));
	  voffset = Rdir ^ uoffset;
	}
      for (i = 0;  i < samples;  i += 1) {
	  R = Rdir;
	  if (blur > 0) {
	      /* Add a random offset to the smooth reflection vector */
	      R += (float random()-0.5) * blur * uoffset;
	      R += (float random()-0.5) * blur * voffset;
	      R = normalize (R);
	    }
	  ev += trace (P, R);
	}
      ev *= Kr / samples;
    }

  /* The rest is like the plastic shader */
  Oi = Os;
  Ci = Os * ( Cs * (Ka*ambient() + Kd*diffuse(Nf)) +
	      specularcolor * (ev + Ks*specular(Nf,-IN,roughness)));
}
