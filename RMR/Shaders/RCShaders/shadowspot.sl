/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.380 */
/* Listing 16.33  Spotlight using shadow map*/

/*
 *  shadowspot(): spotlight with an optional shadow map
 */
light
shadowspot( 
	float	intensity	= 1;
	color	lightcolor	= 1;
	point	from		= point 0,	/* light position */
		to		= point (0,0,1);
	float	coneangle	= radians(30),
		conedeltaangle	= radians(5),
		beamdistribution= 2;
	string	shadowfile	= "" )
{
	uniform point A = (to - from) / length(to - from); /* direction */
	uniform float	cosoutside= cos(coneangle),
			cosinside = cos(coneangle-conedeltaangle);
	float	attenuation, 	/* falloff from center of illumination cone */
		cosangle;	/* cosine of angle wrt center of cone */

	illuminate( from, A, coneangle ) {
		cosangle = L.A / length(L);	/* A is already normalized */
		attenuation = pow(cosangle, beamdistribution) / (L.L);
		attenuation *= smoothstep( cosoutside, cosinside, cosangle );
		if( shadowfile != "" )
		    attenuation *= (1.0 - shadow( shadowfile, Ps ));
		Cl = attenuation * intensity * lightcolor;
	}
}
