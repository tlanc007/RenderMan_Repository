/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.340 */
/* Listing 16.8  Spotlight shader */

/* 
 * spotlight(): cast a fuzzy cone of light
 */
light
spotlight ( float intensity = 1;
	    color lightcolor = 1;
	    point from = point "camera" (0,0,0);
	    point to = point "camera" (0,0,1);
	    float coneangle = radians(30);
	    float conedeltaangle = radians(5);
	    float beamdistribution = 2 )
{
  uniform point A = (to - from) / length (to - from);
  uniform float cosoutside = cos (coneangle),
  		cosinside = cos (coneangle - conedeltaangle);
		
  float atten, cosangle;

	illuminate (from, A, coneangle) {
      cosangle = (L . A) / length(L);
      atten = pow (cosangle, beamdistribution) / (L . L);
      atten *= smoothstep (cosoutside, cosinside, cosangle);
      Cl = atten * intensity * lightcolor ;
    }
}

