/****************************************************************************
 * shadowspot.sl -- spot light with shadow
 *
 * Reference:
 *   _Advanced RenderMan: Creating CGI for Motion Picture_, 
 *   by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
 *
 ****************************************************************************/


light
shadowspot (float  intensity = 1;
	    color  lightcolor = 1;
	    point  from = point "shader" (0,0,0);	/* light position */
	    point  to = point "shader" (0,0,1);
	    float  coneangle = radians(30);
	    float  conedeltaangle = radians(5);
	    float  beamdistribution = 2;
	    string shadowname = "";
	    float  shadownsamps = 16;
	    float  shadowblur = 0;
	    float  shadowbias = 0.001;)
{
    uniform vector A = normalize(to - from);
    uniform float cosoutside= cos(coneangle),
		  cosinside = cos(coneangle-conedeltaangle);

    illuminate (from, A, coneangle) {
	float cosangle = (L.A) / length(L);
	float atten = pow (cosangle, beamdistribution) / (L.L);
	atten *= smoothstep (cosoutside, cosinside, cosangle );
	if (shadowname != "") {
	    atten *= 1 - shadow (shadowname, Ps, "samples", shadownsamps,
				 "blur", shadowblur, "bias", shadowbias);
	}
	Cl = atten * intensity * lightcolor;
    }
}
