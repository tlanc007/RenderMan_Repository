/**************************************************************************
 * platnetatmo.sl - planet atmosphere (6th iteration) 
 *
 * DESCRIPTION:
 *    This is a volume shader which handles atmospheric extinction and
 *    scattering.  Trapezoidal integration with varying step size is
 *    used to integrate the GADD to find scattering and extinction.
 *
 *
 * PARAMTERS:
 *   density, falloff - control the atmospheric density function
 *   integstart, integend - bounds (along the viewing ray direction) of the
 *          integration of atmospheric effects.
 *   rbound - in the case of radial atmosphere, if the viewing ray never
 *          gets closer than this radius, we don't worry about computing the
 *          atmospheric effects.
 *   minstepsize, maxstepsize - bounds on step size for integration
 *   k - the magic number which scales the adaptive step size (larger means 
 *          smaller steps)
 *   use_lighting - if nonzero, light visibility along the ray will be taken
 *          into account.
 *   atmos_type - 0=radial (like a planet), 1=height (like mountains),
 *          2=uniform (like a room).
 *   debug - if nonzero, copious output will be sent to stderr.
 *
 *
 * AUTHORS: Larry Gritz (lg AT larrygritz DOT com) 
 *          and Ken Musgrave (musgrave AT fractalworlds DOT com )
 *
 * REFERENCES:
 *      Texturing and Modeling: a Procedural Approach (2nd edition)
 *      by Ebert, Musgrave, Peachey, Worley, and Perlin.
 *
 * HISTORY:
 *   last modified 5 Jan 1994
 **************************************************************************/




/* Here is where we define the GADD. */

#define GADD(PP,density,falloff,use_lighting,atmos_type,g,li) \
{\
    li = 0;\
    if (atmos_type == 0) { \
         float len = length(PP); \
         if (len < 1) g = 0; \
	 else g = (density * exp(-falloff*(len-.999)));\
    } else if (atmos_type == 1) g = (density * exp(-falloff*(zcomp(PP))));\
    else                      g = density;\
    if (use_lighting > 0) {\
	point PW = transform ("shader", "current", PP);\
	illuminance (PW) { li += Cl; }\
    } else { li = 1; }\
}





volume
planetatmo (float density = 60, falloff = 400;
	    float integstart = 0, integend = 100, rbound = 1.05;
	    float minstepsize = 0.01, maxstepsize = 2.5;
	    float k = 50;
	    float debug = 0;
	    float use_lighting = 1;
	    float atmos_type = 0;
    )
{
  float t, tau;
  point origin = transform ("shader", P-I);
  vector incident = vtransform ("shader", I);
  vector IN = normalize (incident);
  color Cv = 0, Ov = 0;           /* net color & opacity of volume */
  color dC, dO;                   /* differential color & opacity */
  float ss, dtau, last_dtau, tc, minrad, te;
  float nsteps = 0;          /* record number of integration steps */
  color li, last_li, lighttau;
  point PP;

  te = min (length (incident), integend) - 0.0001;

  /* To increase accuracy of the integration in the case of radial GADD,
   * we calculate the closest approach of the viewing ray to the center
   * of the GADD, then integrate separately forward and backward from that
   * point.  tc = the ray index of the closest approach, minrad is the
   * minimum distance from the center of the GADD.
   */
  if (atmos_type == 0) {
      tc = clamp (-(origin.IN), integstart, te);
      minrad = length (origin + tc * IN);
    }
  else {
      tc = integstart;
      minrad = 0;
    }

  /* Integrate forwards from the center point */
  t = tc;
  if (t < te  &&  minrad < rbound) {
      PP = origin + t * IN;
      GADD (PP, density, falloff, use_lighting, atmos_type, dtau, li);
      ss = random() * min (clamp (1/(k*dtau+.001), minstepsize, maxstepsize), te-t);
      t += ss;
      nsteps += 1;

      while (t <= te) {
	  last_dtau = dtau;
	  last_li = li;
	  PP = origin + t*IN;
	  GADD (PP, density, falloff, use_lighting, atmos_type, dtau, li);

	  /* Our goal now is to find dC and dO, the color and opacity
	   * of the portion of the volume covered by this step.
	   */

	  tau = .5 * ss * (dtau + last_dtau);
	  lighttau = .5 * ss * (li*dtau + last_li*last_dtau);

	  dO = 1 - color (exp(-tau), exp(-tau*2.25), exp(-tau*21));
	  dC = lighttau * dO;

	  /* Now we adjust Cv/Ov to account for dC and dO */
	  Cv += (1-Ov)*dC;
	  Ov += (1-Ov)*dO;

	  ss = max (min (clamp (1/(k*dtau+.001), minstepsize, maxstepsize), te-t), 0.0005);
	  t += ss;
	  nsteps += 1;
/*	  printf (" t = %f (te = %f, ss = %f)\n", t, te, ss);  */
        }
    }

  /* Integrate backwards from the center point */
  t = tc;
  if (t > integstart  &&  minrad < rbound) {
      PP = origin + t * IN;
      GADD (PP, density, falloff, use_lighting, atmos_type, dtau, li);
      ss = random() * min (clamp (1/(k*dtau+.001), minstepsize, maxstepsize), t-integstart);
      t -= ss;
      nsteps += 1;

      while (t >= integstart) {
	  last_dtau = dtau;
	  last_li = li;
	  PP = origin + t*IN;
	  GADD (PP, density, falloff, use_lighting, atmos_type, dtau, li);

	  /* Our goal now is to find dC and dO, the color and opacity
	   * of the portion of the volume covered by this step.
	   */

	  tau = .5 * ss * (dtau + last_dtau);
	  lighttau = .5 * ss * (li*dtau + last_li*last_dtau);

	  dO = 1 - color (exp(-tau), exp(-tau*2.25), exp(-tau*21));
	  dC = lighttau * dO;

	  /* Now we adjust Cv/Ov to account for dC and dO */
	  Cv = dC + (1-dO)*Cv;
	  Ov = dO + (1-dO)*Ov;

	  ss = max (min (clamp (1/(k*dtau+.001), minstepsize, maxstepsize), t-integstart), 0.0005);
	  t -= ss;
	  nsteps += 1;
        }
    }


  /* Ci & Oi are the color (premultiplied by opacity) and opacity of 
   * the background element.
   * Now Cv is the light contributed by the volume itself, and Ov is the
   * opacity of the volume, i.e. (1-Ov)*Ci is the light from the background
   * which makes it through the volume.
   */
  Ci = 15*Cv + (1-Ov)*Ci; 
  Oi = Ov + (1-Ov)*Oi;
  
  if (debug > 0) {
      printf ("nsteps = %f, tc = %f, t1 = %f, te = %f\n", nsteps, tc, integstart, te);
      printf ("   Cv = %c, Ov = %c\n", Cv, Ov);
    }
}
