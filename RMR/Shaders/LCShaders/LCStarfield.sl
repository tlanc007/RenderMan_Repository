
/*  
 * LCStarfield.sl -- Antialiased surface shader for a star field.
 *
 * DESCRIPTION:
 *      Make a star field as inside of a big sphere (compute a spherical
 *      mapping). This shader is anti-aliased for animation.
 * 
 * PARAMETERS:
 *      frequency               frequency of the stars
 *      lightIntensity          how bright are the stars?
 *      minsize                 minimum size for a star. For the anti-aliasing
 *                              to work, this value should be adjusted so that
 *                              no star is smaller than 2 pixels. 
 *                              Would be better if expressed in screen pixel 
 *                              (maybe for the next version).
 *      maxsize                 maximum size for a star. Should be bigger than
 *                              minsize.
 *                              Would be better if expressed in screen pixel 
 *                              (maybe for the next version).
 *      lightIntensity          Maximal brightness of the stars.
 *      lightFallOff            Profile of the stars. Values greater than one
 *                              give smooth profile. Values smaller than one
 *                                                      give a hard edge.
 *
 * AUTHOR: written by Laurent Charbonnel, 1998. (laurentc@SpamSucks_worldnet.att.net)
 *
 * HISTORY:
 *      29 Aug 1998 -- tal, added choice for xyz axis when using planes,
 *                          added f_getAlphaBeta().
 *      22 Aug 1998 -- Written by LC for Tal's space animation.
 *
 */


/* 
 * void f_getAlphaBeta -- deterimine which axises to get values from
 *
 * v -- vector to get values from.  Converted into "world space".
 * useYZPlane -- if true, use Z instead of X
 * usexZPlane --  "   "    "  "    "    "  Y
 *     if both are false the use X and Y.
 */ 
void f_getAlphaBeta (
  vector v;
  uniform float useYZplane, useXZplane;

  output float a, b;
)
{

  vector wV = normalize (vtransform ("world", v));

  if (useYZplane == 0 && useXZplane == 0) {
    /* using xy coords */
    b = ycomp (wV);
    a = xcomp (wV);
  }
  else if (useYZplane == 1) {
    /* using ZY coords */
      b = ycomp (wV);
      a = zcomp (wV);
  }
  else {
    /* XZ coords */
      b = zcomp (wV);
      a = xcomp (wV);
  }
}

surface LCStarfield (
	    float frequency = 1;
	    float minsize = .05;
	    float maxsize = .2;
	    float lightIntensity = 1, lightFallOff = .15;
 float useYZplane = 0;
 float useXZplane = 0;
) {
  float val;
  vector wI;
  float alpha, beta, variation;
  val = 0;

  
#if 0 /* orig */
  wI= normalize(vtransform("world", I));
  beta = ycomp(wI);
  alpha = xcomp(wI);
#else /* added by tal */
  f_getAlphaBeta (I, useYZplane, useXZplane, alpha, beta);
#endif  

  float cx, cy, x, y, r, rad;
  float starDifRadius;
  starDifRadius = maxsize-minsize;
  r = minsize+starDifRadius*(cellnoise(frequency*alpha, frequency*beta)*2);
 
  cx = (cellnoise(frequency*alpha, frequency*beta)-.5)*2*(1-r);
  cy = (cellnoise(142+frequency*alpha, 235+frequency*beta)-.5)*2*(1-r);

  x = (mod(frequency*alpha,1)-0.5)*2;
  y = (mod(frequency*beta,1)-0.5)*2;
  
  rad = sqrt((x-cx)*(x-cx)+(y-cy)*(y-cy));

  variation = lightIntensity * cellnoise(130-frequency*alpha, 
					 151+frequency*beta);

  if(rad > r) val = 0; 
  else val = variation*pow(r,lightFallOff)*pow(1-rad,3);
  
  Ci = val*color(1,1,1);
  Oi = 1;

#ifndef BMRT
  Ci = clamp(Ci, color 0, color 1);
  Oi = clamp(Oi, color 0, color 1);
#else  /* Added -- tal */
  Ci = color (clamp (comp (Ci, 0), 0, 1),
              clamp (comp (Ci, 1), 0, 1),
              clamp (comp (Ci, 2), 0, 1));
  Oi = color (clamp (comp (Oi, 0), 0, 1),
              clamp (comp (Oi, 1), 0, 1),
              clamp (comp (Oi, 2), 0, 1));
#endif
}
