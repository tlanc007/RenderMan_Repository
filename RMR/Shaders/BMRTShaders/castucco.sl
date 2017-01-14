#ifdef RCSIDS
static char rcsid[] = "$Id: castucco.sl,v 1.1.1.1 2002/02/10 02:35:49 tal Exp $";
#endif

/*
 * castucco.sl -- dispacement shader for stucco.
 *
 * Description:
 *   I call this "castucco" because it's the stuff on the walls *everywhere*
 *   in Northern California.  I never really saw it on the East Coast,
 *   but in CA it's truly ubiquitous.
 * 
 * Parameters:
 *   freq - basic frequency of the texture
 *   Km - amplitude of the mesas.
 *   octaves - how many octaves of fBm to sum
 *   trough, peak - define the shape of the valleys and mesas of the stucco.
 *
 * $Revision: 1.1.1.1 $    $Date: 2002/02/10 02:35:49 $
 *
 */


#include "noises.h"



displacement
castucco (float freq = 1;
	  float Km = 0.2;
	  float octaves = 3;
	  float trough = -0.15, peak = 0.35)
{
    point Pshad;       /* Point to be shaded, in shader space */
    normal NN;         /* Unit length surface normal */
    float fwidth;      /* Estimated change in P between image samples */
    float disp;        /* Amount to displace */

    /* Do texture calcs in "shader" space */
    Pshad = freq * transform ("shader", P);

    /* Estimate how much Pshad changes between adjacent iamge samples */
    fwidth = sqrt (area(Pshad));

    /* Compute some fractional Brownian motion */
    disp = filtered_fBm (Pshad, fwidth, 3, 2, 0.6);
    
    /* Threshold the fBm and scale it */
    disp = Km * smoothstep (trough, peak, disp);

    /* displace in shader space units */
    NN = normalize(N);
    P += NN * (disp / length (ntransform ("shader", NN)));
    N = normalize (calculatenormal(P));
}
