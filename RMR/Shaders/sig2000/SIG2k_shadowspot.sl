/* Modified shadowspot to better handle attenuation.
 * 
 * bias -- to overide the global shadow bias value.  -1 the light will
 *   use the global shadow bias value.  Otherwise whatever value is here
 *   is what will be used for this lights shadow bias.
 * blur -- amount to soften the shadows edges.
 *
 * 
 * Tal Lancaster  talrmr@SpamSucks_pacbell.net
 * 02/12/00
 * 
 * Modification History
 * 03/25/00  Added comments.
 */
light
SIG2k_shadowspot(
    float atten = 1E6;
    color  lightcolor = 1;
    point  from = point "shader" (0,0,0);       /* light position */
    point  to = point "shader" (0,0,1);
    float  coneangle = radians(30);
    float  conedeltaangle = radians(5);
    float  beamdistribution = 2;
    string shadowname = "";
    float samples = 16;
    float blur = 0;
    float bias = -1;
)
{
    float  attenuation, cosangle;
    uniform vector A = (to - from) / length(to - from);
    uniform float cosoutside= cos(coneangle),
                  cosinside = cos(coneangle-conedeltaangle);

    illuminate( from, A, coneangle ) {
        cosangle = L.A / length(L);
        attenuation = atten * pow(cosangle, beamdistribution) / (atten+length(L));
        attenuation *= smoothstep( cosoutside, cosinside, cosangle );
        if (shadowname != "") {
	  if (bias != -1) {
	    /* Have light override global shadow-bias settings */
                attenuation *= 1-shadow(shadowname, Ps, "samples", samples,
                        "blur", blur, "bias", bias);
	  }
	  else {
	    /* Use global shadow-bias settings */
                attenuation *= 1-shadow(shadowname, Ps, "samples", samples,
                        "blur", blur);
	  }
        }
        Cl = attenuation * lightcolor;
    }
}
