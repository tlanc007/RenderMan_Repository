/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 102 */ 
/* Listing 6.4  Defining a surface of revolution using a wrapped patch mesh */

#include <ri.h>
#include <stdio.h>

#include "pcontour.h"

RtColor color = {.9,.9,.5};
Go() { 
    RiColor(color);
    RiRotate(-90.0, 1.0, 0.0, 0.0);
    SurfOR(points, NPOINTS);
}


#define MAXNPTS 100
#define BEZIERWIDTH    12

RtPoint mesh[MAXNPTS][BEZIERWIDTH];

SurfOR(points, npoints)
Point2D points[];
int npoints;
{
    BezierSurfOR(points, npoints, mesh);
    RiBasis(RiBezierBasis, RI_BEZIERSTEP,
            RiBezierBasis, RI_BEZIERSTEP);
    RiPatchMesh(RI_BICUBIC,
           (RtInt) BEZIERWIDTH, RI_PERIODIC,
           (RtInt) npoints, RI_NONPERIODIC,
           RI_P, (RtPointer) mesh, RI_NULL);
}
#define F .5522847
float coeff[BEZIERWIDTH][2] = { 
    { 1, 0 }, { 1, F }, { F, 1 }, { 0, 1 }, {-F, 1 }, {-1, F }, 
    {-1, 0 }, {-1,-F }, {-F,-1 }, { 0,-1 }, { F,-1 }, { 1,-F }  };
BezierSurfOR(points, npoints, mesh)
Point2D points[];
int npoints;
RtPoint mesh[][BEZIERWIDTH];
{
    int u, v;
    /*
     *  coeff holds a matrix of coefficients for sweeping a point on the XZ
     *  plane circularly around the Z axis, with the circle approximated by 
     *  4 Bezier curves.
     */
    for (v = 0; v < npoints; v++) {    
        /* 
         *  Start at the upper left of the mesh. 
         *  For each control point on the circle being swept out, 
         *  rotate every point on the XZ curve into position.
         */
        for (u = 0; u < BEZIERWIDTH; u++) {    
            /*  Here comes each point on the XZ curve */
            mesh[v][u][0] = points[v].x * coeff[u][0];
            mesh[v][u][1] = points[v].x * coeff[u][1];
            mesh[v][u][2] = points[v].y;
        }
    }
}

