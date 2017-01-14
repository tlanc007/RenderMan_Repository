/* Copyrighted Pixar 1989 */
/* Used with the RenderMan Companion chapter 16 */

#include <ri.h>
#include <stdio.h>

#define NLIGHTS 3
RtPoint lights[NLIGHTS] = {
 15.0,    24.0,    45.0,
  0.0,    24.0,    45.0,
-15.0,    24.0,    45.0,
};
#define AMBIENT .2


Go()
{
    float intensity,
          spin;
    RtToken RI_SPIN;

    intensity = AMBIENT;
    RiLightSource("ambientlight","intensity",&intensity,RI_NULL);

    intensity = 900.0/NLIGHTS;

    RiLightSource("pointlight","intensity", &intensity, 
        "from", lights[0], RI_NULL);
    RiLightSource("pointlight","intensity", &intensity, 
        "from", lights[1], RI_NULL);
    RiLightSource("pointlight","intensity", &intensity, 
        "from", lights[2], RI_NULL); 
    
    create_pin();

    {
        spin = 0.5;
        RI_SPIN = RiDeclare("spin", "uniform float");
        RiDisplacement("gouge", RI_SPIN, &spin, RI_NULL);
        RiSurface("pin_color", RI_SPIN, &spin, RI_NULL); 
        RiTransformBegin();
        draw_pin();
        RiTransformEnd();
    }
}

#include "pcontour.h"

#define BEZIERWIDTH 12
RtPoint mesh[NPOINTS][BEZIERWIDTH];

#define F .5522847
float coeff[BEZIERWIDTH][2] = 
              { {1, 0}, {1, F}, {F, 1}, {0, 1},
                {-F, 1},{-1, F},{-1, 0},
                {-1,-F},{-F,-1}, {0,-1},
                {F,-1}, {1,-F}};

draw_pin()
{
    RtColor brown;

    brown[0] = .4; brown[1] = .2; brown[2] = .1;
    RiBasis(RiBezierBasis, RI_BEZIERSTEP, RiBezierBasis, RI_BEZIERSTEP);
    RiSides( (RtInt) 1);
    RiPatchMesh(RI_BICUBIC,
        (RtInt)BEZIERWIDTH,RI_PERIODIC,(RtInt)NPOINTS,
        RI_NONPERIODIC, RI_P, (RtPointer)mesh,
        RI_NULL);
}

create_pin()
{
    int             u,v;

/*    coeff holds a matrix of coefficients for sweeping a point on the XY plane
 *    circularly around the Y axis, with the circle approximated by 
 *    4 bezier patches
 */

    for (v = 0; v < NPOINTS; v++) {    
        /* 
         *  Start at the upper left of the mesh.
         *  For each control point on the circle being swept out, 
         *  rotate every point on the XY curve into position
         */
        for (u = 0; u < BEZIERWIDTH; u++) {    
            /*  Here comes each point on the XY curve 
             */
            mesh[v][u][0] = points[v].x * coeff[u][0];
            mesh[v][u][1] = points[v].y;
            mesh[v][u][2] = points[v].x * coeff[u][1];
        }
    }
}

