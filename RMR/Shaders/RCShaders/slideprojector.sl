/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.373 */
/* Listing 16.28  Slide-projector light shader */

/*
 *  slideprojector(): Cast a texture map into a scene as a light source
 */
light
slideprojector(	
	float	fieldofview=PI/32;
	point	from		= (8, -4, 10),
		to		= (0,0,0),
		up		= point "eye" (0,1,0);
	string	slidename 	= "",
		shadowname      = "" )
{
	uniform point	relT, 	/* normalized direction vector */
			relU, 	/* "vertical" perspective of surface point */
			relV;	/* "horizontal" perspective of surface point */
	uniform float spread = 1/tan(fieldofview/2); /* spread of "beam" */
	float	Pt, 		/* projection of Ps on relT (distance of 
				   surface point along light direction)	*/
		Pu, 		/* projection of Ps on relU */
 		Pv, 		/* projection of Ps on relU */
 		sloc, tloc;	/* perspected surface point */

	/* Initialize uniform variables for perspective */
	relT = normalize(to - from);
	relU = relT ^ up;
	relV = normalize(relT ^ relU);
	relU = relV^relT;

	illuminate(from, relT, atan(sqrt(2)/spread)) {
		L =  Ps - from;	/* direction of light source from surf. point */
		Pt = L.relT;	/* coordinates of Ps along relT, relU, relV */
		Pu = L.relU;
		Pv = L.relV;
		sloc = spread*Pu/Pt;	/* perspective divide	*/
		tloc = spread*Pv/Pt;
		sloc = sloc*.5 + .5;	/* correction from [-1,1] to [0,1] */
		tloc  = tloc*.5 + .5;
		Cl = color texture(slidename, sloc,tloc);
		if( shadowname != "" )
			Cl *= 1-shadow(shadowname, Ps);
	}
}
