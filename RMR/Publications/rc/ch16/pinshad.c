/* Copyrighted Pixar 1989 */
/* Used with the RenderMan Companion chapter 16 */

#include <math.h>
#include <ri.h>
#include "pinshad.h"

RtPoint CameraFrom   = { CAMXPOS, CAMYPOS, CAMZPOS}, 
        CameraTo     = { CAMXDIR, CAMYDIR, CAMZDIR};

main()
{
    RiBegin(RI_NULL); /* As always */

        /* Output image characteristics */
        RiDisplay("pinshad.z", "zfile", "z", RI_NULL);
        RiFormat( (RtInt) PICXRES, (RtInt) PICYRES, 1.0);    /* image resolution */
	RiShadingRate(1.0);
        /* region of image rendered */
        RiCropWindow(CROPMINX, CROPMAXX, CROPMINY, CROPMAXY);

        /* Nature of the projection to the image plane */
        RiProjection("perspective", RI_NULL);    /* perspective view        */

        /* Camera characteristics */
        FrameCamera((float)PICXRES*CAMZOOM, (float)PICXRES, (float)PICYRES);
        
        /* Camera position and orientation */
        CameraTo[0] -= CameraFrom[0];
        CameraTo[1] -= CameraFrom[1];
        CameraTo[2] -= CameraFrom[2];
        PlaceCamera (CameraFrom, CameraTo, CAMROLL);

        /* Now describe the world */
        RiWorldBegin();
            Go();
        RiWorldEnd();
        
    RiEnd();

    return 0;
}

/* Listing 7.4  Setting up bowling pins in the x,y plane using  */
/*              object instancing */
/* 
 *  PlacePins: set up ten bowling pins using object instancing. We assume
 *      that the pin is centered on the z axis, and separate the rows by 
 *      xseparation. 
 */


RtPoint ground[4] = {{ -0.5, -7.5, 0.0},
                     { -0.5, 7.5,  0.0},
                     {  2.0, 7.5,  0.0},
                     {  2.0, -7.5, 0.0}};
void PlacePins();

Go()
{
    RiTransformBegin();
        RiScale(2.0, 0.33333, 1.0);
        RiPolygon( (RtInt) 4, RI_P, ground, RI_NULL);
    RiTransformEnd();
    PlacePins(1.2*sin(60.0*3.14159/180.0), 1.2);
}

RtColor color = {.9,.9,.5};
void
PlacePins(xseparation, yseparation)
RtFloat xseparation, yseparation;
{
    int row, pin;
    RtObjectHandle phandle;

    RiBasis(RiBezierBasis, RI_BEZIERSTEP, RiBezierBasis, RI_BEZIERSTEP);

    phandle = RiObjectBegin();
    if (!phandle)        /* If can't create a retained model*/
        return;
    BowlingPin();
    RiObjectEnd();

    RiColor(color);

    for (row = 0; row < 4; row++) {   /* For four rows */
        RiTransformBegin();     /* Independent movement for each row */
            RiTranslate(row*xseparation, row*yseparation/2, 0.0);
            for(pin = 0; pin <= row; pin++) {  /* #pins == row#-1 */
                RiTransformBegin();
                    RiTranslate(0.0, -pin * yseparation, 0.0);
                    RiObjectInstance(phandle);
                RiTransformEnd();
            }
        RiTransformEnd();
    }
}

#define NPOINTS 10
typedef struct { RtFloat x, y; } Point2D;
Point2D points[NPOINTS] = {
{0.0000,1.5000},
{0.0703,1.5000},
{0.1273,1.4293},
{0.1273,1.3727},
{0.1273,1.2300},
{0.0899,1.1600},
{0.0899,1.0000},
{0.0899,0.7500},
{0.4100,0.6780},
{0.1250, 0.000},
};

BowlingPin()
{
    SurfOR(points, NPOINTS);
}

/* Listing 6.3  Version of SurfOR() taking profile points and  */
/*              producing a bicubic  */
#define NU 13
#define MAXNPTS 100
#define F .5522847
float coeff[NU][2] = { 
    { 1, 0 }, { 1, F }, { F, 1 }, { 0, 1 }, {-F, 1 }, {-1, F }, 
    {-1, 0 }, {-1,-F }, {-F,-1 }, { 0,-1 }, { F,-1 }, { 1,-F }, { 1, 0} };

RtPoint    mesh[MAXNPTS][NU];

SurfOR(points, npoints)
Point2D points[];
int npoints;
{
    int        u, v;

/*    coeff holds a matrix of coefficients for sweeping a point on the XZ
 *    plane circularly around the Z axis, with the circle approximated by 
 *    4 Bezier curves
 */
    for (v = 0; v < npoints; v++) {    
        /* 
         *  Start at the upper left of the mesh.  For each 
         *  control point on the circle being swept out, 
         *  rotate every point on the XZ curve into position
         */
        for (u = 0; u < NU; u++) {    
            /*  Here comes each point on the XZ curve */
            mesh[v][u][0] = points[v].x * coeff[u][0];
            mesh[v][u][1] = points[v].x * coeff[u][1];
            mesh[v][u][2] = points[v].y;
        }
    }
    RiPatchMesh(RI_BICUBIC, 
        (RtInt) NU, RI_NONPERIODIC,
        (RtInt) npoints, RI_NONPERIODIC,
        RI_P, (RtPointer) mesh, 
        RI_NULL);
}

