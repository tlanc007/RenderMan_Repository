/* Copyrighted Pixar 1989 */
/* Used with some listings from the RenderMan Companion */ 

#include <ri.h>
#include <stdio.h>
#ifdef HEADER
#include HEADER /* Standard (default) option parameters */
#else
#include "optfile.h"
#endif

RtPoint CameraFrom   = { CAMXPOS, CAMYPOS, CAMZPOS}, 
        CameraTo     = { CAMXDIR, CAMYDIR, CAMZDIR};

main()
{
    RiBegin(RI_NULL); /* As always */

#ifdef CLIPNEAR
        RiClipping(CLIPNEAR, CLIPFAR);
#endif

        /* Output image characteristics */
#ifdef FILENAME
       /* output to given file */
        RiDisplay(FILENAME, RI_FILE, RI_RGB, RI_NULL); 
#else
        RiDisplay("RenderMan", RI_FRAMEBUFFER, RI_RGB, RI_NULL);
#endif
        RiFormat((RtInt) PICXRES, (RtInt) PICYRES, -1.0); /* image resolution */
	RiShadingRate(1.0); 		/* Good quality, use 0.25 for better. */
	RiLightSource("distantlight", RI_NULL);
        /* region of image rendered */
        RiCropWindow(CROPMINX, CROPMAXX, CROPMINY, CROPMAXY);

        /* Nature of the projection to the image plane */
        RiProjection("perspective", RI_NULL);    /* perspective view */

        /* Camera characteristics */
        FrameCamera((float)PICXRES*CAMZOOM, (float)PICXRES, (float)PICYRES);
        
        /* Camera position and orientation */
        CameraTo[0] -= CameraFrom[0];
        CameraTo[1] -= CameraFrom[1];
        CameraTo[2] -= CameraFrom[2];
        PlaceCamera(CameraFrom, CameraTo, CAMROLL);

        /* Now describe the world */
        RiWorldBegin();
            Go();
        RiWorldEnd();
        
    RiEnd();

    return 0;
}
