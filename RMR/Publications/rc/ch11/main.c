/* Copyrighted Pixar 1989 */
/* To be used with listing11_1.c from the RenderMan Companion p.220 */

#include <ri.h>
#include <stdio.h>

#ifdef HEADER
#include HEADER
#else
#include "optfile.h" /* Standard (default) option parameters */
#endif

RtPoint CameraFrom   = { CAMXPOS, CAMYPOS, CAMZPOS}, 
        CameraTo     = { CAMXDIR, CAMYDIR, CAMZDIR};

main()
{
    RiBegin(RI_NULL); /* As always */

        /* Output image characteristics */
#ifdef FILENAME
        /* output to given file */
        RiDisplay(FILENAME, RI_FILE, RI_RGBA, RI_NULL);   
#else
	RiDisplay("main.tiff", RI_FILE, RI_RGBA, RI_NULL);
#endif
        RiFormat( (RtInt) PICXRES, (RtInt) PICYRES, -1.0); /* image resolution */
	RiShadingRate(1.0);
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
        Go();
        
    RiEnd();

    return 0;
}
