/*
 * TL_rglass -- glass shader with prman refraction, reflection, frensel
 *
 * DESCRIPTION:
 *    Example glass shader demonstrating prman refraction, reflection, 
 *    and frensel.
 *
 * PARAMETERS:
 *    Ka, Kd, Ks - the usual
 *    roughness -  the usual
 *    specularcolor - the usual
 *    Kr - reflection strength
 *    Kt - refraction strength
 *    refractionIndex - snell's refraction index
 *    mapname - environment map
 *
 * AUTHOR: Tal Lancaster
 *   tal AT renderman DOT org
 *
 * History:
 *   Created: 8/27/99
 *   1999/09/12 tal -- originally was an example of refraction,  now can
 *      use reflect, too.
 *
 */

surface TL_rglass (
  float Ka = 1;
  float Kd = 0;
  float Ks = .25;
  color specularcolor = color 1;
  float Kr = 1;
  float Kt = 1;
  float roughness = 0.12,
  refractIndex = 1.1;
  string mapname = "";
)
{
  normal Nf;
  vector NI;
  vector Rfrdir;       /* refraction direction */
  vector Rfldir;       /* reflection direction */
  color Cfr = color 0; /* color from refraction */
  color Cfl = color 0; /* color from reflection */

  NI = normalize(I);
  Nf = normalize (faceforward(N, I));

  if (mapname != "") {
    /* ok have an environment map so use it. */

    if (Kt > 0) {
      Rfrdir = refract(NI, Nf,refractIndex);
      Rfrdir = vtransform("world", Rfrdir);
      Cfr = (length (Rfrdir) < 0.001)? 
	color 0: color environment(mapname, Rfrdir);
    }
    if (Kr > 0) {
      Rfldir = reflect(NI, Nf);
      Rfldir = vtransform("world", Rfldir);
      Cfl = environment(mapname, Rfldir);
    }
  }

  Oi = Os;
  Ci = Cs * (Ka * ambient() + Kd * diffuse (Nf) +
	     specularcolor * Ks * specular (Nf, -NI, roughness)) +
    Kt * Cfr + Kr * Cfl;
}

