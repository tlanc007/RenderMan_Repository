/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.347 */
/* Listing 16.13  Shader mapping shader-space coordinates to colors */

/*
 * show_xyz(): Color a surface point according to its xyz coordinates
 * 	within a bounding box.
 */
surface
show_xyz (
	float	xmin = -1,
			ymin = -1,
			zmin = -1,
			xmax = 1,
			ymax = 1,
			zmax = 1)
{
	uniform point scale, zero;
	point objP;
	vector cubeP;
	
	/* Check for zero scale components. */
	if (xmax == xmin || ymax == ymin || zmax == zmin) {
		printf ("bad bounding box %f %f %f %f %f %f in show_xyz()",
		 xmin, xmax, ymin, ymax, zmin, zmax);
	}
	else {
		scale = point (1 / (xmax - xmin), 1 / (ymax - ymin), 
		 1 / (zmax - zmin));
		zero = point (xmin, ymin, zmin);
		
		objP = transform ("shader", P);
		cubeP = (objP - zero) * scale;
		Ci = color (xcomp (cubeP), ycomp(cubeP), zcomp(cubeP) );
	}
}
