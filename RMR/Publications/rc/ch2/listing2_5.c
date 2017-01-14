/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 28 */
/* Listing 2.5  Another cube definition */

#include <ri.h>
#include <stdio.h>

/* UnitCube(): Enter a unit cube into the scene */

UnitCube()
{
    static RtPoint square[4] = { 
        {.5,.5,.5}, {-.5,.5,.5}, {-.5,-.5,.5}, {.5,-.5,.5} 
    };

    RiTransformBegin();

        /* far square */
        RiPolygon((RtInt) 4, RI_P, (RtPointer) square, RI_NULL);

        /* right face */
        RiRotate(90.0, 0.0, 1.0, 0.0);
        RiPolygon((RtInt) 4, RI_P, (RtPointer) square, RI_NULL);

        /* near face */
        RiRotate(90.0, 0.0, 1.0, 0.0);
        RiPolygon((RtInt) 4, RI_P, (RtPointer) square, RI_NULL);

        /* left face */
        RiRotate(90.0, 0.0, 1.0, 0.0);
        RiPolygon((RtInt) 4, RI_P, (RtPointer) square, RI_NULL);

    RiTransformEnd();

    RiTransformBegin();

        /* bottom face */
        RiRotate(90.0, 1.0, 0.0, 0.0);    
        RiPolygon((RtInt) 4, RI_P, (RtPointer) square, RI_NULL);

    RiTransformEnd();

    RiTransformBegin();

        /* top face */
        RiRotate(-90.0, 1.0, 0.0, 0.0);    
        RiPolygon((RtInt) 4, RI_P, (RtPointer) square, RI_NULL);

    RiTransformEnd();
}
