/****************************************************************************
 * shinyplastic.sl -- Shiny plastic surface
 *
 * Parameters:
 *    Ka, Kd, Ks, roughness - The usual meaning
 *    Kr - coefficient for mirror-like reflections of environment
 *    blur - how blurry are the reflections? (0 = perfectly sharp)
 *    ior - index of refraction (1.5 is a good estimate for most plastics)
 *    envname, envspace, envrad - controls for using environment maps
 *    rayjitter, raysamples - ray tracing controls for reflection
 *    twosided - if nonzero both sides of the surface are shiny, otherwise
 *        only the "outside" (where the surface normal points) will
 *        spawn rays.  This can be an important optimization, especially
 *        when using the "ray server."
 *
 ***************************************************************************
 *
 * Author: Larry Gritz (lg AT larrygritz DOT com)
 *
 * Reference:
 *   _Advanced RenderMan: Creating CGI for Motion Picture_, 
 *   by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
 *
 * $Revision: 1.3 $    $Date: 2003/12/24 06:18:06 $
 *
 ****************************************************************************/


/* Comment out the following line if you do *not* wish to use BMRT and
 * PRMan together.
 */
#ifdef WANT_RAYSERVER
#include "rayserver.h"
#endif

#include "material.h"


surface
shinyplastic ( float Ka = 1, Kd = 0.5, Ks = .5, roughness = 0.1;
               float Kr = 1, blur = 0, ior = 1.5; 
               DECLARE_DEFAULTED_ENVPARAMS;
	       float twosided = 0;
             )
{
    normal Nf = faceforward (normalize(N), I);
    Ci = MaterialShinyPlastic (Nf, Cs, Ka, Kd, Ks, roughness, Kr, blur, ior,
                               twosided, ENVPARAMS);
    Oi = Os;  Ci *= Oi;
}
