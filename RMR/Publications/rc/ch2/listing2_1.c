/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 18 */
/* Listing 2.1   A minimal program using RenderMan */

#include <ri.h>
#include <stdio.h>

RtPoint Square[4] = { {.5,.5,.5}, {.5,-.5,.5}, {-.5,-.5,.5}, {-.5,.5,.5} 
};

main()
{
    RiBegin(RI_NULL);   /* Start the renderer */
	RiDisplay("listing2_1.tiff", RI_FILE, "rgb", RI_NULL);
	RiFormat((RtInt) 256, (RtInt) 192, -1.0);
	RiShadingRate(1.0);
        RiWorldBegin();
            RiSurface("constant", RI_NULL);
            RiPolygon( (RtInt) 4,        /* Declare the square */    
                RI_P, (RtPointer) Square, RI_NULL);
        RiWorldEnd();
    RiEnd();             /* Clean up */

    return 0;
}
