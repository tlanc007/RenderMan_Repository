/* Copyrighted Pixar 1989 */
/* To be used with listing7_2.c from the RenderMan Companion p.128 */

#include <math.h>
#include <ri.h>
#include <stdio.h>

#define XSHIFT 2.1
#define YSHIFT 2.0
#define ZSHIFT 2.0
#define MINTHETA 30.0
#define MAXTHETA 360.0
#define THETADEL (MAXTHETA-MINTHETA)
#define ROWWIDTH 4

Go() 
{
    int x;
    RtColor color;
    color[0] = color[1] = color[2] = 0.7;

    RiShadingRate(1.0);
    RiSides( (RtInt) 2);
    RiTranslate(-XSHIFT*(ROWWIDTH-1)/2, -YSHIFT, -ZSHIFT);
    RiTransformBegin();
        RiRotate(-120.0, 1.0, 0.0, 0.0);                                
        for (x=0; x<ROWWIDTH; x++) {
            SolidWedge(1.0, -.2, .2, MINTHETA+THETADEL*x/(ROWWIDTH-1));
            RiTranslate(XSHIFT, 0.0, 0.0);
        }
    RiTransformEnd();

    RiTranslate(0.0, YSHIFT, ZSHIFT);
    RiTransformBegin();
        RiRotate(-120.0, 1.0, 0.0, 0.0);                                
        for (x=0; x<ROWWIDTH; x++) {
            SolidWedge(1.0, -.8, .6, MINTHETA+THETADEL*x/(ROWWIDTH-1));
            RiTranslate(XSHIFT, 0.0, 0.0);
        }
    RiTransformEnd();

    RiTranslate(0.0, YSHIFT, ZSHIFT*1.2);
    RiTransformBegin();
        RiRotate(-120.0, 1.0, 0.0, 0.0);                                
        for (x=0; x<ROWWIDTH; x++) {
            SolidWedge(1.0, -1.0, 1.0, MINTHETA+THETADEL*x/(ROWWIDTH-1));
            RiTranslate(XSHIFT, 0.0, 0.0);
        }
    RiTransformEnd();
}

#include "wedge7_2.c"
