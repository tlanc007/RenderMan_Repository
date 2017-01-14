/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 135 */ 
/* Listing 7.4  Setting up bowling pins in the x,y plane  */
/*              using object instancing                   */
/* 
 *  PlacePins: set up ten bowling pins using object instancing. We assume
 *    that the pin is centered on the z axis, and separate the rows by 
 *    xseparation. 
 */

#include <math.h>
#include <ri.h>
#include <stdio.h>

RtColor color = {.9,.9,.5};

void
PlacePins(xseparation, yseparation)
RtFloat xseparation, yseparation;
{
    int row, pin;
    RtObjectHandle phandle;

    phandle = RiObjectBegin();
        if (!phandle)                /* If can't create a retained model */
            return;
        BowlingPin();
    RiObjectEnd();

    RiColor(color);

    for (row = 0; row < 4; row++) {                    /* For four rows */
        RiTransformBegin();        /* Independent movement for each row */
            RiTranslate(row*xseparation, row*yseparation/2, 0.0);
            for (pin = 0; pin <= row; pin++) {        /* #pins == row#-1 */
                RiTransformBegin();
                    RiTranslate(0.0, -pin * yseparation, 0.0);
                    RiObjectInstance(phandle);
                RiTransformEnd();
            }
        RiTransformEnd();
    }
}

#include "hcontour.h"

BowlingPin()
{
    SurfOR(points, NPOINTS);
}

/* Listing 4.2  Using hyperboloids to create a surface of revolution */

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
        tmp = pp1; pp1 = pp2; pp2 = tmp;              /* Swap pointers */ 
    } 
} 

Go()                                              /* N E W */
{
    PlacePins(1.2*sin(60.0*3.14159/180.0), 1.2);
}

