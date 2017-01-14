/************************************************************************
 * clay.sl -- simple clay surface using MaterialClay
 *
 * Author: Larry Gritz (lg AT larrygritz DOT com)
 *
 * Reference:
 *   _Advanced RenderMan: Creating CGI for Motion Picture_, 
 *   by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
 ************************************************************************/


#include "material.h"


surface
clay ( float Ka = 1, Kd = 0.7, roughness = 0.1;)
{
    normal Nf = faceforward (normalize(N), I);
    Ci = MaterialClay (Nf, Cs, Ka, Kd, roughness);
    Oi = Os;  Ci *= Oi;
}
