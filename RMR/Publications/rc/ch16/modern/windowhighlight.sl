/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.357 */
/* Listing 16.20  Surface shader providing a paned-window highlight*/

/*
 *  windowhighlight(): Give a surface a window-shaped specular highlight.
 */
surface 
windowhighlight(	
	point	center	= point "world" (0, 0, -4); /* center of the window */
	vector  in	= vector "world" (0, 0, 1),  /* normal to the wall */
		up	= vector "world" (0, 1, 0);  /* 'up' on the wall */
	color	specularcolor = 1; 
	float	Ka	= .3,
		Kd	= .5,
		xorder	   = 2,	/* number of panes horizontally */
		yorder	   = 3,	/* number of panes vertically   */
		panewidth  = 6,	/* horizontal size of a pane    */
		paneheight = 6,	/* vertical size of a pane      */
		framewidth = 1,	/* sash width between panes     */
		fuzz	   = .2;) /* transition region between pane and sash */
{
    uniform
      vector    in2,	/* normalized in */
		right, 	/* unit vector perpendicular to	 in2 and up2 */
		up2;	/* normalized up perpendicular to in	     */
      point	corner;	/* location of lower left corner of window   */
      vector 	path,	/* incident vector I reflected about normal N */
		PtoC, 	/* vector from surface point to window corner */
		PtoF;	/* vector from surface point to wall along path */
      float 	offset, modulus, yfract, xfract;
      normal 	Nf = faceforward( normalize(N), I );

    /* Set up uniform variables as described above */
    in2 	= normalize(in);				
    right 	= up ^ in2;				
    up2 	= normalize(in2^right);
    right	= up2 ^ in2;
    corner = center - right*xorder*panewidth/2 - 
			    up2*yorder*paneheight/2;

    path = reflect(I, normalize(Nf));	/* trace source of highlight */
    PtoC = corner - P;

    if (path.PtoC <= 0) {	/* outside the room */
	xfract = yfract = 0;
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
	if( offset > 0 && offset/paneheight < yorder ) { /* inside the window */
	    if( modulus > (paneheight/2))						/* symmetry about pane center  */
		modulus = paneheight - modulus;
	    yfract = smoothstep(	/* fuzz at the edge of a pane    */
		(framewidth/2) - (fuzz/2),
		(framewidth/2) + (fuzz/2),
		modulus);
	} else {
	    yfract = 0;
	}

	/* Repeat the process for horizontal offset */
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
    /* specular calculation using the highlight */
    Ci = Cs * (Kd*diffuse(Nf) + Ka*ambient())
	  + yfract*xfract*specularcolor ;
}
