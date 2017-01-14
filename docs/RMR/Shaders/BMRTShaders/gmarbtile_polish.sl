/*
 * gmarbtile_polish.sl -- polished green marble tiles
 *
 * DESCRIPTION:
 *   Makes the same marble texture as greenmarble, but polished (with ray traced
 *   reflections) and cut into tiles (divided in xy texture space).
 *   
 * 
 * PARAMETERS:
 *   Ka, Kd, Ks, roughness, specularcolor - work just like the plastic
 *   Kr - reflectivity (shininess) of the surface
 *   txtscale - overall scaling for the texture
 *   darkcolor, lightcolor - colors of the underlying substrate
 *   veincolor - color of the bright veins
 *   veinfreq - controls the frequency of the veining effects
 *   sharpness - how sharp the veins appear
 *   groovecolor - the color of the grooves between the tiles.
 *   groovewidth - the width of the grooves
 *   tilesize - how big each tile is
 *
 * ANTIALIASING: should antialias itself fairly well
 *
 * AUTHOR: written by Larry Gritz
 *
 * HISTORY:
 *
 * last modified  11 July 1994 by Larry Gritz
 */



surface
gmarbtile_polish (float Ka = 0.5, Kd = 0.4, Ks = 0.2;
		  float Kr = 0.2, roughness = 0.05;
		  color specularcolor = 1;
		  float txtscale = 1;
		  color darkcolor = color(0.01, 0.12, 0.004);
		  color lightcolor = color(0.06, 0.18, 0.02);
		  color veincolor = color(0.47, 0.57, 0.03);
		  color groovecolor = color(.02,.02,.02);
		  float veinfreq = 1;
		  float sharpness = 25;
		  float tilesize = 1;
		  float groovewidth = 0.015;
  )
{
#define snoise(x) (2*noise(x)-1)
#define boxstep(a,b,x) (clamp(((x)-(a))/((b)-(a)),0,1))
#define MINFILTERWIDTH 1.0e-7
  point PP;
  vector offset;
  normal Nf;
  vector V, refldir;
  color Ct, env;
  float pixelsize, twice, scale;
  uniform float freq;
  float turbsum, turb;
  uniform float i;
  float swidth, twidth;
  float w, h, ss, tt, whichs, whicht, groovy, GWF;
/*  float swidth, twidth; */

  PP = txtscale * transform ("shader", P);

  /* Calculate info for antialiasing */
  pixelsize = txtscale * sqrt(area(P));
  twice = 2 * pixelsize;
  swidth = pixelsize;
  twidth = swidth;

  GWF = groovewidth*0.5/tilesize;
  ss = xcomp(PP) / tilesize;
  whichs = ss;  ss = mod(ss,1);  whichs -= ss;
  tt = ycomp(PP) / tilesize;
  whicht = tt;  tt = mod(tt,1);  whicht -= tt;
  offset = vector(7*whichs, 15*whicht, 0 /*-23*floor(zcomp(PQ))*/);
  PP += offset;

  /*
   * First calculate the underlying color of the substrate
   *    Use turbulence - use frequency clamping
   */
  turb = 0;
  for (scale = 1; scale > twice; scale /= 2)
      turb += scale * abs(noise(PP/scale)-0.5);
  if (scale > pixelsize)
      turb += clamp ((scale/pixelsize)-1, 0, 1) * scale * abs(noise(PP/scale)-0.5);

  Ct = mix (darkcolor, lightcolor, smoothstep(0.1,.35,turb));

  /*
   * Now we layer on the veins
   */

  /* perturb the lookup */
  freq = 1;
  offset = vector(35.2,-21.9,6.25);
  /* This offset makes it uncorrelated to the substrate pattern */
  for (i = 0;  i < 6;  i += 1) {
      offset += (vector noise (freq * PP) - vector(.5,.5,.5))  / freq;
      freq *= 2;
    }
  PP += offset;

  /* Now calculate the veining function for the lookup area */
  turbsum = 0;  freq = 1;
  PP *= veinfreq;
  for (i = 0;  i < 3;  i += 1) {
      turb = abs (snoise (PP*freq));
      turb = pow (smoothstep (0.8, 1, 1 - turb), sharpness) / freq;
      turbsum += (1-turbsum) * turb;
      freq *= 2;
    }
  turbsum *= smoothstep (-0.1, 0.05, snoise(2*(PP+vector(-4.4,8.34,27.1))));

  Ct = mix (Ct, veincolor, turbsum);


  if (swidth >= 1)
      w = 1 - 2*GWF;
  else w = clamp (boxstep(GWF-swidth,GWF,ss), max(1-GWF/swidth,0), 1)
	 - clamp (boxstep(1-GWF-swidth,1-GWF,ss), 0, 2*GWF/swidth);
  if (twidth >= 1)
      h = 1 - 2*GWF;
  else h = clamp (boxstep(GWF-twidth,GWF,tt), max(1-GWF/twidth,0),1)
	 - clamp (boxstep(1-GWF-twidth,1-GWF,tt), 0, 2*GWF/twidth);
  groovy = w*h;
  
  Ct = mix (groovecolor, Ct, groovy);

  Nf = faceforward (normalize(N), I);
  V = normalize (I);

  env = Ks * specular(Nf,-V,roughness);
  if (Kr*groovy > 0) {
      refldir = reflect (V, Nf);
      env += Kr * trace (P, refldir);
    }
  env *= groovy * specularcolor;

  Oi = Os;
  Ci = Oi * (Ct * (Ka*ambient() + Kd*diffuse(Nf)) + env);
}
