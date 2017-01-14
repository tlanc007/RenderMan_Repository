/* Copyrighted Pixar 1989 */
/* Code to be used with listing7_1.c from the RC p. 127 */

#include <ri.h>
#include <stdio.h>

#include "hcontour.h"

RtColor color = {.9,.9,.5};
Go() { 
    RiColor(color);
    RiRotate(-90.0, 1.0, 0.0, 0.0);
    SolidSurfOR(points, NPOINTS);
}

#include "listing7_1.c"
