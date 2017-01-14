/*****
* quadsmain.c -- To be used with the listings in Chapter 4 from 
* The RenderMan Companion
*****/
#include <ri.h>
#include <stdio.h>

extern void Go();

main ()
{
	RiBegin (RI_NULL); /* Start Renderer */
		RiDisplay("quadsmain.tiff", RI_FILE, "rgb", RI_NULL);
		RiFormat( 256, 186, -1.0);
		RiProjection ("perspective", RI_NULL);
		RiTranslate (0.0, 0.0, 2.0);

		RiWorldBegin ();
			RiLightSource ("distantlight", RI_NULL);	
			RiAttributeBegin();

				RiSurface ("matte", RI_NULL);
				Go();
			RiAttributeEnd();
		RiWorldEnd();
	RiEnd(); /* Clean up */

}
