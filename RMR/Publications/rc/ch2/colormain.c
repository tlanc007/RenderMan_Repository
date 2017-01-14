/* Copyrighted Pixar 1989 */
/* Modified variant of the Main function (from the RenderMan Companion p.25) for the color cube examples  */

#include <ri.h>
#include <stdio.h>

main()
{
    static RtColor color = { .2, .4, .6 };

    RiBegin(RI_NULL);      /* Start the renderer */
	RiDisplay("colormain.tiff", RI_FILE, "rgb", RI_NULL);
	RiFormat((RtInt) 256, (RtInt) 192, -1.0);
	RiShadingRate(1.0);
	RiLightSource("distantlight", RI_NULL);

        RiWorldBegin();

            RiSides((RtInt) 1);    /* N E W */

            RiTranslate(0.0, 0.0, 1.5);
            RiRotate(30.0, -1.0, 0.0, 0.0);
            RiRotate(30.0, 0.0, -1.0, 0.0);
                    
            RiColor(color);      /* Declare the color */
            ColorCube(4, .8);    /* Define the cube */
        RiWorldEnd();
    
    RiEnd();                /* Clean up after the renderer */

    return 0;
}
