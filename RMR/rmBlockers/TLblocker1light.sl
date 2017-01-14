/* This is a varient of the slide-projector light shader 
   From the RenderMan Companion p.373
*/

/*
 * TLblocker1light -- texture-map used as a light blocker (1 channel version)
 *
 * DESCRIPTION:
 * This is basically the slideprojector from the RC.  The twist is that the
 * 1 Channel texture map is treated as a either a positive or negative blocker.
 * ie. the image is use to block the light based on the pattern of the black &
 * white image.
 *
 * HINTS:
 * If the "negative" is false, then the white region will let light pass though
 * and block the rest.  If "negative" is true, then it will do the opposite.
 *
 * AUTHOR: Tal Lancaster
 *	tal AT renderman DOT org
 *
 * History:
 *	Created: 8/10/97
 */
 
light
TLblocker1light (	
    float intensity = 1.0;
	color lightcolor = 1;
	float	fieldofview = PI/32;
	point	from = (8, -4, 10),
		to		= (0,0,0),
		up		= point "eye" (0,1,0);
	float negative = 0;
	string	blockername 	= "",
  		    shadowname      = "";
)
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
	float blockerVal;    /* value from texture-map */

	/* Initialize uniform variables for perspective */
	relT = normalize(to - from);
	relU = relT ^ up;
	relV = normalize(relT ^ relU);
	relU = relV^relT;

	Cl = lightcolor * intensity;
	
	illuminate(from, relT, atan(sqrt(2)/spread)) {
		L =  Ps - from;	/* direction of light source from surf. point */
		Pt = L.relT;	/* coordinates of Ps along relT, relU, relV */
		Pu = L.relU;
		Pv = L.relV;
		sloc = spread*Pu/Pt;	/* perspective divide	*/
		tloc = spread*Pv/Pt;
		sloc = sloc*.5 + .5;	/* correction from [-1,1] to [0,1] */
		tloc  = tloc*.5 + .5;
		
		if (blockername != "") {
			/* NOTE: assumes 1 channel and white is the blocker imsge */
			blockerVal = float texture(blockername, sloc,tloc);
			if (negative == 1)
				blockerVal = 1 - blockerVal;
			Cl *= blockerVal;
		}
		if( shadowname != "" )
			Cl *= 1-shadow(shadowname, Ps);
	}
}
