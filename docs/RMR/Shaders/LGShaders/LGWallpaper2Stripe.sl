/*
 * wallpaper_2stripe.sl -- surface shader for double striped wall paper
 *
 * DESCRIPTION:
 *   Makes a double striped pattern appropriate for wall paper.  Stripes
 *   are shaded in s-t space, and the stripes are parallel to lines of
 *   equal s.  The background color is given by the surface color.
 *
 * 
 * PARAMETERS:
 *   Ka, Kd, Ks, roughness	the usual
 *   specularcolor
 *   bgcolor, stripecolor       color of background and stripes
 *   stripewidth                width of stripes, in s coordinates
 *   stripespacing              dist between sets of stripes, in s coordinates
 *
 *
 * ANTIALIASING:  should analytically antialias itself quite well.
 *
 *
 * AUTHOR: written by Larry Gritz, GWU
 *         email: gritz AT seas DOT gwu DOT edu 
 *
 * HISTORY:
 *      22 May 1992 -- original written in C by lg for the dresser image
 *      14 Jan 1994 -- recoded by lg in correct shading language.
 *
 * last modified  14 Jan 1994 by Larry Gritz
 */


#define boxstep(a,b,x) (clamp(((x)-(a))/((b)-(a)),0,1))
#define MINFILTERWIDTH 1.0e-7



surface
LGWallpaper2Stripe ( float Ka = 0.5, Kd = 0.75, Ks = 0.25;
		    float roughness = 0.1;  color specularcolor = 1;
		    color stripecolor = color "rgb" (1,0.5,0.5);
		    float stripewidth = 0.05;
		    float stripespacing = 0.5; )
{
  point Nf;
  color Ct;
  float stripe, ss;
  float swidth;
  float W = stripewidth/stripespacing;

  /* For antialiasing */
  swidth = max (abs(Du(s)*du) + abs(Dv(s)*dv), MINFILTERWIDTH) / stripespacing;

  ss = mod (s, stripespacing) / stripespacing - 0.5;

  if (swidth >= 1)
      stripe = 1 - 2*W;
  else stripe = clamp (boxstep(W-swidth,W,ss), max(1-W/swidth,0), 1)
	   - clamp (boxstep(W+stripewidth,W+stripewidth+swidth,ss), 0, 2*W/swidth)
	   + clamp (boxstep(W-swidth+4*stripewidth,W+4*stripewidth,ss), max(1-W/swidth,0), 1)
	   - clamp (boxstep(W+5*stripewidth,W+5*stripewidth+swidth,ss), 0, 2*W/swidth);

  Ct = mix (Cs, stripecolor, stripe);

  Nf = faceforward (normalize(N),I);
  Oi = Os;
  Ci = Os * ( Ct * (Ka*ambient() + Kd*diffuse(Nf)) +
	      specularcolor * Ks*specular(Nf,-normalize(I),roughness));
}
