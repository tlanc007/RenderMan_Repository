/**************************************************************************
 * platlight.sl - light shader for use with planetary atmosphere.
 *
 * DESCRIPTION:
 *    This is a light shader which handles atmospheric extinction.
 *    Trapezoidal integration with varying step size is used to
 *    integrate the GADD to find extinction.
 *
 *
 * PARAMTERS:
 *   intensity, lightcolor - color of the light
 *   from, to - give the direction of the light
 *
 *   density, falloff - control the atmospheric density function
 *   integstart, integend - bounds (along the viewing ray direction) of the
 *          integration of atmospheric effects.
 *   minstepsize, maxstepsize - bounds on step size for integration
 *   rbound - in the case of radial atmosphere, if the viewing ray never
 *          gets closer than this radius, we don't worry about computing the
 *          atmospheric effects.
 *   k - the magic number which scales the adaptive step size (larger means 
 *          smaller steps)
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

#define GADD(PP,A,B,li,g) \
         if      (atmos_type == 0) g = (A * exp(-B*(length(PP)-.999))); \
         else if (atmos_type == 1) g = (A * exp(-B*(zcomp(PP)))); \
         else                      g = A;





light
platlight (float intensity = 1;
	   color lightcolor = 1;
	   point from = point "shader" (0,0,0);
	   point to = point "shader" (0,0,1); 
	   
	   float density = 2, falloff = 400;
	   float integstart = 0, integend = 100, rbound = 10.5;
	   float minstepsize = 0.01, maxstepsize = 2.5;
	   float k = 1;
	   float debug = 0;
	   float atmos_type = 0;
    )
{
  float t, tau;
  point origin;
  vector incident, IN;
  float te;
  color Ov = 0;           /* net opacity of volume */
  color dO;                   /* differential color & opacity */
  float ss, dtau, last_dtau, tc, minrad;
  float nsteps = 0;          /* record number of integration steps */
  point PP;

  solar (to-from, 0) {

      te = integend;
      incident = vtransform ("shader", L);
      IN = normalize (incident);
      origin = transform ("shader", Ps) - IN*te;

      if (debug > 0) 
	  printf ("origin = %p, incident = %p\n", origin, te*IN);

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
	  GADD (PP, density, falloff, li, dtau)
	  ss = random() * min (clamp (1/(k*dtau+.001), minstepsize, maxstepsize), te-t);
	  t += ss;
	  nsteps += 1;

	  while (t <= te) {
	      last_dtau = dtau;
	      PP = origin + t*IN;
	      GADD (PP, density, falloff, li, dtau)

	      /* Our goal now is to find dC and dO, the color and opacity
	       * of the portion of the volume covered by this step.
	       */
		  
	      tau = .5 * ss * (dtau + last_dtau);
	      
	      dO = 1 - color (exp(-tau), exp(-tau*2.25), exp(-tau*21));
	      Ov += (1-Ov)*dO;
	      
	      ss = max (min (clamp (1/(k*dtau+.001), minstepsize, maxstepsize), te-t), 0.0005);
	      t += ss;
	      nsteps += 1;
	    }
        }


      /* Integrate backwards from the center point */
      t = tc;
      if (t > integstart  &&  minrad < rbound) {
	  PP = origin + t * IN;
	  GADD (PP, density, falloff, li, dtau)
	  ss = random() * min (clamp (1/(k*dtau+.001), minstepsize, maxstepsize), t-integstart);
	  t -= ss;
	  nsteps += 1;
	  
	  while (t >= integstart) {
	      last_dtau = dtau;
	      PP = origin + t*IN;
	      GADD (PP, density, falloff, li, dtau)
		  
	      /* Our goal now is to find dC and dO, the color and opacity
	       * of the portion of the volume covered by this step.
	       */
		  
	      tau = .5 * ss * (dtau + last_dtau);
	      
	      dO = 1 - color (exp(-tau), exp(-tau*2.25), exp(-tau*21));
	      Ov = dO + (1-dO)*Ov;
	      
	      ss = max (min (clamp (1/(k*dtau+.001), minstepsize, maxstepsize), t-integstart), 0.0005);
	      t -= ss;
	      nsteps += 1;
	  }
      }

  
      Cl = intensity * lightcolor * (1-Ov);
    }

  if (debug > 0) {
      printf ("nsteps = %f, tc = %f, t1 = %f, te = %f, Ov = %c\n",
	      nsteps, tc, integstart, te, Ov);
    } 
}
