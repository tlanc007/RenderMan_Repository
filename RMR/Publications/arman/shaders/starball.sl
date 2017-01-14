/************************************************************************
 * starball.sl - make a striped ball with a star pattern
 *
 * Reference:
 *   _Advanced RenderMan: Creating CGI for Motion Picture_, 
 *   by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
 ************************************************************************/

#include "material.h"


surface
starball (float Ka=1, Kd=0.5, Ks = 0.5, roughness=.1;) 
{
    float ddv = 2*abs(dv);
    float ddu = 2*abs(du);
	
    float ang = mod (s*360, 144);
    float ht = .3090/sin(((ang+18)*.01745));
    ang = mod ((1-s)*360, 144);
    float ht1 = .3090/sin(((ang+18)*.01745));
    ht = max (ht, ht1);
    ht1 = ht*.5-min(t*2, 1);
    ht1 = clamp (ht1, -ddu, ddu)/(ddu*2)+.5;
    ht = ht/2 - min((1-t)*2, 1);
    ht1 = ht1 + clamp(ht, -ddu, ddu)/(ddu*2)+.5;

    color Ct = mix (color(.8,.6,0), color (.5,.05,.05), ht1);
    Ct = mix (color(0,0.2,.7), Ct, clamp(abs(t-0.5)-0.1, 0, ddv)/ddv);

    normal Nf = faceforward (normalize(N), I);
    Ci = MaterialPlastic (Nf, Ct, Ka, Kd, Ks, roughness);
    Oi = Os;  Ci *= Oi;
}
