/* Copyrighted Pixar 1989 */
/* Main function (from the RenderMan Companion p.25) for the color cube examples  */

#include <ri.h>
#include <stdio.h>

static RtColor Color = { .2, .4, .6 };
main()
{
    RiBegin(RI_NULL);        /* Start the renderer */
	RiDisplay("cubemain.tiff", RI_FILE, "rgb", RI_NULL);
	RiFormat((RtInt) 256, (RtInt) 192, -1.0);
	RiShadingRate(1.0);
        RiLightSource("distantlight", RI_NULL);
        RiProjection("perspective", RI_NULL);
        RiWorldBegin();
			  RiTranslate(0.0, 0.0, 1.5);
			  RiRotate(40.0, -1.0, 1.0, 0.0);
            RiSurface("matte", RI_NULL);
            RiColor(Color);    /* Declare the color */
            UnitCube();        /* Define the cube */
        RiWorldEnd();
    RiEnd();               /* Clean up after the renderer */

    return 0;
}
