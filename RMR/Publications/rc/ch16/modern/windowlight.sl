/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.361 */
/* Listing 16.21  Light shader simulating sunlight through a window*/

/*
 *  windowlight(): Cast patches of light as through a paned window.
 */
light 
windowlight(
	point	from 		= point "world" ( 0, 0, -20),
		to		= point "world" (0, 0, 0),
		center		= point "world" (0, 0, -4);
	vector	in		= vector "world" (0, 0, 1),
		up		= vector "world" (0, 1, 0);
	color	lightcolor 	= color (1, .9, .6),
		darkcolor 	= color (.05, .2, .1); 
	float 	intensity	=  1,
		xorder		=  2,	/* number of panes horizontally */
		yorder		=  3,	/* number of panes vertically 	*/
		panewidth	=  6,	/* horizontal size of a pane	*/
		paneheight	=  6,	/* vertical size of a pane	*/
		framewidth	=  1,	/* sash width between panes 	*/
		fuzz	= .2;) /* transition region between pane and sash */
{
    uniform
      vector	in2, 	/* normalized in			    */
		right,	/* unit vector perpendicular to in2 and up2 */
		up2;	/* normalized up perpendicular to in	    */
      point	corner;	/* location of lower left corner of window  */
      vector	path, 	/* direction of sunlight travel		    */
        	PtoC, 	/* vector from surface point to window corner */
      		PtoF;	/* vector from surface point to wall along path	*/
      float offset, modulus, yfract, xfract;

    /* Initialize the uniform variables */
    path = (from - to);
    in2 = normalize(in);
    in2 *= sign(-path.in2);
    right = up ^ in2;
    up2 = normalize(in2 ^ right);
    right = up2 ^ in2;
    corner = center - right*xorder*panewidth/2 - 
			    up2*yorder*paneheight/2;

    solar( -path, 0.0 ) {

	PtoC = corner - Ps;
	if (path.PtoC <= 0) { 		/* outdoors => full illumination */
	    xfract = yfract = 1;
	} else {

	/*
	 * Make PtoF be a vector from the surface point to the wall 
	 *	by adjusting the length of the reflected vector path.
	 */
	    PtoF = path * (PtoC.in2)/(path.in2);

	/* 
	 * Calculate the vector from the corner to the intersection point, and
	 *	project it onto up2. This length is the vertical offset of the
	 *	 intersection point within the window. 
	 */
	    offset = (PtoF - PtoC).up2;
	    modulus = mod(offset, paneheight);
	    if( offset > 0 && offset/paneheight < yorder ) { /* inside window */
		if( modulus > (paneheight/2))
		    modulus = paneheight - modulus;				/* symmetry in pane */
		yfract = smoothstep( 	/* include sash fuzz  */
		    (framewidth/2) - (fuzz/2),
		    (framewidth/2) + (fuzz/2),
		    modulus);
	    } else {
		yfract = 0;
	    }

	/* Repeat for horizontal offset */
	    offset = (PtoF - PtoC).right;
	    modulus = mod(offset, panewidth);
	    if( offset > 0 && offset/panewidth < xorder ) {
		if( modulus > (panewidth/2))
		    modulus = panewidth - modulus;
		xfract = smoothstep( 
		    (framewidth/2) - (fuzz/2),
		    (framewidth/2) + (fuzz/2),
		    modulus);
	    } else {
		xfract = 0;
	    }
	}
	Cl = intensity * mix( darkcolor, lightcolor, yfract*xfract);
    }
}
