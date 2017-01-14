/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 20 */
/* Listing 2.2   Control over viewer and color */

#include <ri.h>
#include <stdio.h>

RtPoint Square[4] = { {.5,.5,0}, {.5,-.5,0}, {-.5,-.5,0}, {-.5,.5,0} };

static RtColor Color = { .2, .4, .6 };

main()
{
    RiBegin(RI_NULL);   /* Start the renderer     */
	RiDisplay("color2_2.tiff", RI_FILE, "rgb", RI_NULL);
	RiFormat((RtInt) 256, (RtInt) 192, -1.0);
	RiShadingRate(1.0);

        RiLightSource( "distantlight", RI_NULL); 

        RiProjection( "perspective", RI_NULL);
        RiTranslate(0.0, 0.0, 1.0);
        RiRotate(40.0, -1.0, 1.0, 0.0);
                    
        RiWorldBegin();

            RiSurface("matte", RI_NULL);
            RiColor(Color);       /* Declare the color */
            RiPolygon( (RtInt) 4,         /* Declare the square */ 
                RI_P, (RtPointer) Square, RI_NULL);

        RiWorldEnd();
    
    RiEnd();                /* Clean up after the renderer */

    return 0;
}
