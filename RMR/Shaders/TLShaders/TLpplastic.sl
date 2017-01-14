/*
 * TLpplastic -- painted plastic 
 *
 * DESCRIPTION:
 *    RC painted plastic but can flip S & T
 *
 * PARAMETERS:
 *    Ka, Kd, Ks - the usual
 *    roughness -  the usual
 *    specularcolor - the usual
 *    texturename - environment map
 *    flipS - if true invert s
 *    flipT - if true invert t
 *
 * AUTHOR: Tal Lancaster
 *   tal AT renderman DOT org
 *
 * History:
 *   Created: 8/27/99
 *
 */

surface TLpplastic ( 
  float Ka = 1, Ks=.5, Kd=.5, roughness=.1; color specularcolor=1;
  string texturename = ""; 
  float flipS = 0;
  float flipT = 0;
)
{
    normal Nf;
    vector V;
    color Ct;  /* color from texture map */
    float ss  = (flipS == 0)? s: 1 - s;
    float tt  = (flipT == 0)? t: 1 - t;


    Nf = faceforward( normalize(N), I );
    V = -normalize(I);

    if (texturename != "") {
	Ct = color texture(texturename, ss, tt);
    } else {
	Ct = 1.0;
    }

    Oi = Os;
    Ci = Os * ( Cs * Ct * (Ka*ambient() + Kd*diffuse(Nf)) +
	 	specularcolor * Ks * specular(Nf,V,roughness) );
}
