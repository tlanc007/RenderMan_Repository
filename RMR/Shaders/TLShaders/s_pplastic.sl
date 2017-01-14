/* $Id: s_pplastic.sl,v 1.3 2003/12/24 06:18:06 tal Exp $ */

/*
 * based off of Pixar's paintedplastic 
 *
 * NAME s_pplastic.sl 
 *
 * SYNOPSIS
 *   A slightly souped up version of paintedplastic.  flipST flags
 *
 * INPUTS
 *
 *   Variable      Description
 *
 *   Kd, Ka, Ks    usual
 *   roughness       " 
 *   specularcolor   "
 *   texturename   texture-map name
 *   flipS         if true will apply a 1-s
 *   flipT         "   "    "    "    " 1-t
 *
 *
 * AUTHOR
 *   Tal Lancaster   tal AT renderman DOT org  98/06/03
 *
 *   Modification History
 *     Tal 10/22/99 cleaned up
 *
 */

surface s_pplastic( 
  float Ks=.5;
  float Kd=.5;
  float  Ka=1;
  float  roughness=.1; 
  color specularcolor=1;
  string texturename = "";  /* type texture */
  float flipS = 0;          /* type switch */
  float flipT = 1;          /* type switch */
  float MtorFlip = 0;       /* type switch def 1 */

)
{
    normal Nf;
    vector V;
    color Ct;


    Nf = faceforward( normalize(N), I );
    V = -normalize(I);

    float ss;
    float tt;

    if (MtorFlip == 1) {
	ss = t;
	tt = s;
    }
    else {
	ss = s;
	tt = t;
    }
    if (flipS == 1)
	ss = 1 - ss;
    if (flipT == 1)
	tt = 1 - tt;
       
    Ct = (texturename != "")? color texture (texturename, ss, tt): color 1.0;

    /* Ct = color (ss, tt, 0); */
   
    Oi = Os;
    Ci = Os * ( Cs * Ct * (Ka*ambient() + Kd*diffuse(Nf)) + 
	 	specularcolor * Ks * specular(Nf,V,roughness) );
}
