/*****
* wavemain.c -- To be used with the listing 4.3 in Chapter 4 from 
* The RenderMan Companion
*****/
#include <ri.h>
#include <stdio.h>

extern void Go();

main ()
{
	RiBegin (RI_NULL); /* Start Renderer */
		RiDisplay("wavemain.tiff", RI_FILE, "rgb", RI_NULL);
		RiFormat( 256, 186, -1.0);
		RiProjection ("perspective", RI_NULL);

		RiWorldBegin ();
			RiLightSource ("distantlight", RI_NULL);	
			RiAttributeBegin();
				RiTranslate (0.0, 0.0, 1.5);
				RiRotate (40.0, -1.0, 1.0, 0.0);

				RiSurface ("matte", RI_NULL);
				Go();
			RiAttributeEnd();
		RiWorldEnd();
	RiEnd(); /* Clean up */

}
