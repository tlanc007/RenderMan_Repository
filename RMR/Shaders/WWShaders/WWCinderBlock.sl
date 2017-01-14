/*
 * WWCinderBlock.sl -- a surface shader for cinder block walls.
 *
 * DESCRIPTION:
 *   This is a surface shader which combines a matte shader and 
  *  Larry Gritz's brick displacement shader.  
 *   Makes displacements for a wall of bricks.  This is the companion
 *   shader to the surface "brick" shader.  The parameters work exactly
 *   the same.  Of course, you can use it with any surface shader, and
 *   in fact matte or plastic gives those nice white cinder block walls.
 *   However, if you do use it with "brick", the parameters MUST match,
 *   or your bricks will look very strange.
 * 
 * PARAMETERS:
 *    brickwidth                Width of a brick (in st space)
 *    brickheight               Height of a brick (in st space)
 *    mortarthickness           Thickness of the mortar (in st space)
 *    rowvary                   How much does each row shift?
 *    jagged                    How much do bricks deviate from squares?
 *    pitting                   The amplitude of the "pits" on the face of
 *                                 the bricks.
 *    pockfrequency             The st frequency of the pits.
 *    groovedepth               The depth of the grooves between bricks.
 *
 * AUTHOR: written by Larry Gritz, 1992, transmuted by wave in 1994
 *
 * HISTORY:
 *      28 May 1992 -- written by lg for the "Timbre Trees" video (saucer)
 *      12 Jan 1994 -- recoded by lg in correct shading language.
 *      8  Dec 1994 -- hacked unmercifully by wave
 *      10 Jan 1995 -- changed defaults
 *
 * last modified  10 Jan 1995 by wave
 */

surface
WWCinderBlock (float Ka	= .7; 
	       float Kd	= .7;
               float jagged = 0.006;
   	       color brickcolor = color "rgb" (1, 1, .82);
	       color mortarcolor = color "rgb" (1, 1, .82);
               float brickwidth = .3, brickheight = .15;
	       float mortarthickness = .01; 
               float brickvary = 0.15;
	       float rowvary = .01, pitting = 0.03;
	       float pockfrequency = 15, groovedepth = 0.025; )
{
#define BMWIDTH (brickwidth+mortarthickness)
#define BMHEIGHT (brickheight+mortarthickness)
#define MWF (mortarthickness*0.5/BMWIDTH)
#define MHF (mortarthickness*0.5/BMHEIGHT)
#define snoise(x) (2 * noise((x)) - 1)
#define boxstep(a,b,x) (clamp(((x)-(a))/((b)-(a)),0,1))
#define sqr(x) ((x)*(x))
#define MINFILTERWIDTH 1.0e-7
  point PP2, tmpP;
  float sbrick, tbrick, w, h;
  float scoord, tcoord, ss, tt;
  float fact, disp;
  point Nf;
  float swidth, twidth;
  color bcolor, Ct;

  /* Determine how wide in s-t space one pixel projects to */
  swidth = max (abs(Du(s)*du) + abs(Dv(s)*dv), MINFILTERWIDTH);
  twidth = max (abs(Du(t)*du) + abs(Dv(t)*dv), MINFILTERWIDTH);

  scoord = s;  tcoord = t;

  /* Make the shapes of the bricks vary just a bit */
  PP2 = point noise (s/BMWIDTH, t/BMHEIGHT);
  scoord = s + jagged * xcomp (PP2);
  tcoord = t + jagged * ycomp (PP2);

  ss = scoord / BMWIDTH;
  tt = tcoord / BMHEIGHT;

  /* shift alternate rows */
  if (mod (tt*0.5, 1) > 0.5)
      ss += 0.5;

  tbrick = floor (tt);   /* which brick row? */
  /* Shift the columns randomly by row */
  ss += rowvary * (noise (tbrick+0.5) - 0.5);

  sbrick = floor (ss);   /* which brick column? */
  ss -= sbrick;          /* Now ss and tt are coords within the brick */
  tt -= tbrick;

  fact = 1;
  disp = 0;
  if (tt < MHF) {
      /* We're in the top horizontal groove */
      disp = groovedepth * (sqr((tt)/MHF) - 1);
    }
  if (tt > (1.0-MHF)) {
      /* Bottom horizontal groove */
      disp = groovedepth * (sqr((1-tt)/MHF) - 1);
    }
  if (ss < MWF) {
      disp = 0.75 * groovedepth * (sqr(ss/MWF) - 1);
    }
  if (ss > (1.0-MWF)) {
      disp = 0.75 * groovedepth * (sqr((1-ss)/MWF) - 1);
    }

  fact = smoothstep (0, 1.3*MHF, tt) - smoothstep (1.0-1.3*MHF, 1, tt);
  fact *= (smoothstep (0, 1.3*MWF, ss) - smoothstep (1.0-1.3*MWF, 1, ss));
  fact = pitting * (0.75 * fact + 0.25);
  disp -= fact * pow(noise ((ss+sbrick)*pockfrequency/BMHEIGHT,
		            (tt+tbrick)*pockfrequency/BMWIDTH), 0.25);

  tmpP = P + (disp * normalize(N));
  /* okay, we perturb the normal, but not the real point, so we can't see through the wall... */
  N = calculatenormal(tmpP);
  Nf = faceforward(normalize(N),I);

  /* Choose a color for the surface */
  if (swidth >= 1)
      w = 1 - 2*MWF;
  else w = clamp (boxstep(MWF-swidth,MWF,ss), max(1-MWF/swidth,0), 1)
	 - clamp (boxstep(1-MWF-swidth,1-MWF,ss), 0, 2*MWF/swidth);

  if (twidth >= 1)
      h = 1 - 2*MHF;
  else h = clamp (boxstep(MHF-twidth,MHF,tt), max(1-MHF/twidth,0),1)
	 - clamp (boxstep(1-MHF-twidth,1-MHF,tt), 0, 2*MHF/twidth);

  /* Choose a brick color that varies from brick to brick */
  /*
  bcolor = brickcolor * (1 + (brickvary * snoise (tbrick+(100*sbrick)+0.5)));
  */
  bcolor = brickcolor * (1 + (brickvary * snoise (tbrick+0.5)));
  Ct = mix (mortarcolor, bcolor, w*h);


  Oi = 1;
  Ci = Ct * ( Ka*ambient() + Kd*diffuse(Nf) ) ;
}
