/****************************************************************************
 * cel.sl
 *
 * Description: generate flatly shaded objects that look like cartoon
 * "cel" paintings.
 *   
 * Parameters:
 *   Ka, Kd, Ks, roughness - the usual meaning
 *   outlinethickness - scales the thickness of the silhouette outlines
 *
 ***************************************************************************
 *
 * Author: Larry Gritz (lg AT larrygritz DOT com), 1999
 *
 * Reference:
 *   _Advanced RenderMan: Creating CGI for Motion Picture_, 
 *   by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
 *
 * $Revision: 1.2 $    $Date: 2003/12/24 06:18:06 $
 *
 ****************************************************************************/


#include "filterwidth.h"
#include "material.h"


color LocIllumCelDiffuse ( normal N; )
{
    color C = 0;
    extern point P;
    illuminance (P, N, PI/2) {
	/* Must declare because extern L & Cl because we're in a function */
	extern vector L;  extern color Cl; 
	float nondiff = 0;
	lightsource ("__nondiffuse", nondiff);
	if (nondiff < 1) {
	    C += Cl * ((1-nondiff) * smoothstep(0,0.1,N.normalize(L)));
	}
    }
    return C;
}


color MaterialCel (normal Nf;  color Cs;
                   float Ka, Kd, Ks, roughness, specsharpness;)
{
    extern vector I;
    vector IN = normalize(I), V = -IN;
    return   Cs * (Ka*ambient() + Kd*LocIllumCelDiffuse(Nf))
            + Ks * LocIllumGlossy (Nf, V, roughness/10, specsharpness);
}


color CelOutline (normal N; float outlinethickness;)
{
    extern float du, dv;
    extern color Ci, Oi;
    extern vector I;
    float angle = abs(normalize(N) . normalize(I));
    float dangle = filterwidth(angle);
    float border = 1 - filterstep (5*outlinethickness, angle/dangle);
    Oi = mix (Oi, color 1, border);
    return mix (Ci, color 0, border);
}


surface
cel ( float Ka = 1, Kd = 1, Ks = .5, roughness = 0.25;
      float outlinethickness = 1;)
{
    normal Nf = faceforward(normalize(N),I);

    Ci = MaterialCel (Nf, Cs, Ka, Kd, Ks, roughness, 0.25);
    Oi = Os;  Ci *= Oi;
    Ci = CelOutline (N, outlinethickness);
}
