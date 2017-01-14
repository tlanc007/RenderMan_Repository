/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 254 */

#include <math.h>
#include <ri.h>
#include "hcontour.h"

#define GRID_TEXTURE "grid.tx"

Go() { 
    RiRotate(-90.0, 1.0, 0.0, 0.0);
    RiShadingRate(0.5);
    MapSurfOR(points, NPOINTS);
}



/* Listing 12.2  Routine used to draw Figure 12.5    */


/*
 * MapSurfOR(): produce a surface of revolution from a profile curve.
 *    The first surface has a texture distributed evenly among its 
 *    individual rings. In the second surface, the texture distribution
 *    is equalized according to the size of the ring.
 */

MapSurfOR(points, npoints) 
Point2D points[];
int npoints;
{ 
    double totlen, xlen, ylen;
    RtFloat tcoords[NPOINTS];
    int pt;

    /* Distribute the texture interval [0,1] linearly among the surfaces */
    for (pt = 0; pt < npoints; pt++)
        tcoords[pt] = ((float)pt)/(npoints-1);
    RiTransformBegin();
        RiTranslate(-0.6, 0.0, 0.0);
        TextSurfOR(points, tcoords, npoints, 360.0); 
    RiTransformEnd();

    /* Equalize the texture coordinates */
    tcoords[0] = totlen = 0.0;
    for (pt = 0; pt < npoints-1; pt++) {
        xlen = points[pt+1].x-points[pt].x;
        ylen = points[pt+1].y-points[pt].y;
        /* Set tcoords[i] to the accumulated length of all segments <= i */
        tcoords[pt+1] = (totlen += sqrt(xlen*xlen+ylen*ylen));
    }

    /* Normalize the accumulated lengths to the interval [0,1]     */
    for (pt = 1; pt < npoints; pt++) 
        tcoords[pt] /= totlen;

    /* Declare the surface again */
    RiTransformBegin();
        RiTranslate(0.6, 0.0, 0.0);
        TextSurfOR(points, tcoords, NPOINTS, 360.0); 
    RiTransformEnd();
}
/*
 * TextSurfOR(): create a surface of revolution with a texture, distributing
 *    texture space among the segments 
 */

TextSurfOR(points, tcoords, npoints, thetamax)
Point2D points[];
int npoints;
RtFloat tcoords[], thetamax;
{
    int pt;
    RtPoint point1, point2;
    RtFloat *pp1, *pp2, *tmp;
    RtFloat thisT, nextT;
    RtToken RI_TMAP;
    char *tmap =GRID_TEXTURE;
    
    RiAttributeBegin();
        pp1 = point1;
        pp2 = point2;
    
        /*  
         * For each adjacent pair of points in the description,
         *  draw a hyperboloid by sweeping the line segment defined by 
         *  those points about the z axis.
         */
        pp1[0] = points[0].y;
        pp1[1] = 0;
        pp1[2] = points[0].x;
        nextT = tcoords[0];
        RI_TMAP = RiDeclare("tmap", "uniform string");
        RiSurface("mytexture", 
                  RI_TMAP, (RtPointer) &tmap, RI_NULL);
        RiRotate(90.0, 0.0, 0.0, 1.0);
        for (pt = 1; pt < npoints; pt++) {
            pp2[0] = points[pt].y;
            pp2[1] = 0;
            pp2[2] = points[pt].x;
            thisT = nextT;
            nextT = tcoords[pt];
            RiTextureCoordinates(0.0,thisT, 1.0,thisT, 0.0,nextT, 1.0,nextT);  
            RiHyperboloid(pp1, pp2, 360.0, RI_NULL);
            tmp = pp1; pp1 = pp2; pp2 = tmp;      /* Swap pointers */
        }
    RiAttributeEnd();
}
