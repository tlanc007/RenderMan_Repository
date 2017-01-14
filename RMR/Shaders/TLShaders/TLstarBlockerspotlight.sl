/* This a mixture of the slideprojector, spotlight, and DPStar */

/*
 * TLstarblocker1light -- procedual blocker of a star shape
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
 *	tal@SpamSucks_cs.caltech.edu
 *
 * History:
 *	Created: 8/10/97
 * 
 */
 
light
TLstarBlockerspotlight(	
    float intensity = 1.0;
	color lightcolor = 1;
	float	fieldofview=PI/32;
	point	from		= (8, -4, 10),
		to		= (0,0,0),
		up		= point "eye" (0,1,0);
	float coneangle = radians (30);
	float conedeltaangle = radians (5);
	float beamdistribution = 2;
	float negative = 0;
    uniform color starcolor = color (1, 1, 1);
	uniform color bgColor = color (0, 0, 0);
    uniform float npoints = 5;
    uniform float sctr = 0.5;
    uniform float tctr = 0.5;
	string	blockername 	= "",
		shadowname      = "" )
{
	uniform point	relT, 	/* normalized direction vector */
			relU, 	/* "vertical" perspective of surface point */
			relV;	/* "horizontal" perspective of surface point */
	uniform point A;
	uniform float spread = 1/tan(fieldofview/2); /* spread of "beam" */
	float	Pt, 		/* projection of Ps on relT (distance of 
				   surface point along light direction)	*/
		Pu, 		/* projection of Ps on relU */
 		Pv, 		/* projection of Ps on relU */
 		sloc, tloc;	/* perspected surface point */
	float cosoutside = cos (coneangle);
	float cosinside = cos (coneangle-conedeltaangle);
	float atten;
	float cosangle;
	float blockerVal;
	float sign;

    float ss, tt, angle, r, a, in_out;
    uniform float rmin = 0.07, rmax = 0.2;
    uniform float starangle = 2*PI/npoints;
    uniform point p0 = rmax*(cos(0),sin(0),0);
    uniform point p1 = rmin*
        (cos(starangle/2),sin(starangle/2),0);
    uniform point d0 = p1 - p0;
    point d1;


	/* Initialize uniform variables for perspective */
	relT = normalize(to - from);
	relU = relT ^ up;
	relV = normalize(relT ^ relU);
	relU = relV^relT;
	
	A = relT;

	Cl = lightcolor * intensity;
	
	illuminate(from, relT, /*atan(sqrt(2)/spread)*/coneangle) {
		L =  Ps - from;	/* direction of light source from surf. point */
		Pt = L.relT;	/* coordinates of Ps along relT, relU, relV */
		Pu = L.relU;
		Pv = L.relV;
		sloc = spread*Pu/Pt;	/* perspective divide	*/
		tloc = spread*Pv/Pt;
		sloc = sloc*.5 + .5;	/* correction from [-1,1] to [0,1] */
		tloc  = tloc*.5 + .5;
		
		ss = sloc - sctr; tt = tloc -tctr;
	    angle = atan(ss, tt) + PI;

		cosangle = L.A / length (L);
		atten = pow (cosangle, beamdistribution)/ (L.L);
		atten *= smoothstep (cosoutside, cosinside, cosangle);
	   r = sqrt(ss*ss + tt*tt);
    	a = mod(angle, starangle)/starangle;
    
    if (a >= 0.5)
        a = 1 - a;
    d1 = r*(cos(a), sin(a),0) - p0;
    in_out = step(0, zcomp(d0^d1));
		
		Cl *= atten;
		if (negative == 1)
			in_out = 1 - in_out;
		Cl *= mix (bgColor, starcolor, in_out);
		if( shadowname != "" )
			Cl *= 1-shadow(shadowname, Ps);
	}
}
