/* RudyCsteelfloor_d.sl
 * 
 * Copyright (C) 2002, Rudy Cortes   rcortes AT kc DOT rr DOT com 
 * created  02/14/2002
 * 
 * This software is placed in the public domain and is provided as is 
 * without express or implied warranty. 
 * 
 * Surface shader that implements a displacement model that should have a visual
 * appearence general similar to that of steel metal floor.
 *
 * Feel free to use this shader to create floors anywhere and
 * everywhere, just list me on the credits under "Shading Team"
 *
 ****************************************
 * PARAMETERS
 * freq = The overall frequency of the texture. How much does it tile?
 * Km = Displacement amount
 * crumple = crumpling strenght
 * crumplefreq = frequency that controls the crumpling. "IT IS ALSO AFFECTED BY
 * THE freq PARAMETER".
 * fuzz = the softness of the edges on the stars
 *
 ***************************************
 *
 * NOTE- You will need Steve May's "rmannotes.sl"
 * http://www.accad.ohio-state.edu/~smay/RManNotes/rmannotes.html
 * and Larry Gritz's "noises.h"
 * http://www.renderman.org/RMR/Shaders/BMRTShaders/noises.h
 *
 * Enjoy!!
 *
 * Modification history:
 *   10/16/02 implemented simple Box-filtering anti-aliasing support
 *   on the crumple function
 *
 */


#include "noises.h"
#include "rmannotes.h"

displacement RudyCsteelfloor_d ( 
  float freq = 10, 
  Km = 0.005,
  crumple = 0.3,
  crumplefreq = 50,
  fuzz = 0.3)

{
/*shader local variables*/
float surface_mag, layer_mag;
float ss,tt;
point center, Ndiff,PP;
float radius = 0.35;
float d, dPP, turb,f;

/*repeat and rotate current pattern freq n times*/
rotate2d(s,t,radians(45),.5,.5,ss,tt);
ss = repeat (ss,freq);
tt = repeat (tt,freq);

/* circle 01 */
surface_mag = 0;
center = (0.5, 0.5, 0);  /* location of center of disk */
radius = 0.35;           /* radius of disk */
d = distance(center, point (ss, (tt * 6) - 2.5 , 0));
layer_mag = 1 - smoothstep(radius - fuzz, radius, d);
surface_mag += layer_mag;


/*circle 02, combine with previous layer to create the star*/
d = distance(center, point ((ss * 6) - 2.5, tt , 0));
layer_mag = 1 - smoothstep(radius - fuzz, radius, d);
surface_mag = max (surface_mag, layer_mag);


/*add noise*/
PP = transform ("shader",P) * crumplefreq;
dPP = filterwidthp(PP);

turb = 0;
for ( f = 1; f < freq ; f *= 2)
  turb += clamp(abs(filteredsnoise(PP * f,dPP * f)) / f, 0, 1);

surface_mag += turb * crumple;

/* displace*/
P += Km * surface_mag * normalize (N);
N = calculatenormal (P);  

}

