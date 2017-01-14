/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 127 */ 
/* Listing 7.1  Using hyperboloids to create a solid surface of revolution */

/* SolidSurfOR(): create a solid surface of revolution from a set of points */
SolidSurfOR(points, npoints)
Point2D points[];
int npoints;
{
    RiSolidBegin(RI_PRIMITIVE);
        SurfOR(points, npoints);         /* ... from Chapter 4 */  
        if (points[0].y != 0.0)          /* Seal the object at the ends */
            RiDisk(points[0].x, points[0].y, 360.0, RI_NULL);
        
        if (points[npoints-1].y != 0.0) 
            RiDisk(points[npoints-1].x,
                points[npoints-1].y, 360.0, RI_NULL);

    RiSolidEnd();
}

/* From the RenderMan Companion p. 65 */
/* Listing 4.2  Using hyperboloids to create a surface of revolution */
/* #include <ri.h>  */

SurfOR(points, npoints) 
Point2D points[]; 
int npoints; 
{ 
    int pt; 
    RtPoint point1, point2; 
    RtFloat *pp1, *pp2, *tmp; 
        pp1 = point1; 
        pp2 = point2; 

    /*   
     * For each adjacent pair of x,y points in the outline description, 
     *  draw a hyperboloid by sweeping the line segment defined by  
     *  those points about the z axis. 
     */ 
    pp1[0] = points[0].y; 
    pp1[1] = 0; 
    pp1[2] = points[0].x; 
    for (pt = 1; pt < npoints; pt++) { 
        pp2[0] = points[pt].y; 
        pp2[1] = 0; 
        pp2[2] = points[pt].x; 
        RiHyperboloid(pp1, pp2, 360.0, RI_NULL); 
        tmp = pp1; pp1 = pp2; pp2 = tmp;         /* Swap pointers */ 
    } 
} 
