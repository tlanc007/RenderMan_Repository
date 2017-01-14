/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 168 */
/* Listing 8.5 An improved boilerplate viewing program   */

#include <ri.h>
#include <stdio.h>

/* viewbasics.c: file compiling view options into a rendering shell. */

#define DATATYPE RI_RGBA         /* Pixels have RGB and coverage */
#define PICXRES 256.0            /* Horizontal output resolution */
#define PICYRES 192.0            /* Vertical output resolution   */

#define CROPMINX 0.0             /* RiCropWindow() parameters    */
#define CROPMAXX  1.0 
#define CROPMINY  0.0
#define CROPMAXY  1.0 
#define CAMXFROM 0.0             /* Camera position  */
#define CAMYFROM 0.0
#define CAMZFROM 0.0

#define CAMXTO 0.0               /* Camera direction */
#define CAMYTO 0.0
#define CAMZTO 1.0
#define CAMROLL 0.0              /* Camera roll      */

#define CAMZOOM 1.0              /* Camera zoom rate */

RtPoint CameraFrom  = { CAMXFROM, CAMYFROM, CAMZFROM }, 
        CameraTo    = { CAMXTO, CAMYTO, CAMZTO };

main()
{
    RiBegin(RI_NULL);                     /* As always */

        /* Output image characteristics */
#if 0
#ifdef FILENAME                         /* output to file */
        RiDisplay(FILENAME, RI_FILE, RI_RGBA, RI_NULL);
#else                 /*...to frame buffer */
	RiDisplay("boil8_5.tiff", RI_FILE, RI_RGBA, RI_NULL);
#endif

#else
    RiDisplay("ri.tiff", RI_FILE, RI_RGBA, RI_NULL);
#endif /* 0 */
	RiShadingRate(1.0);
        RiFormat((RtInt)PICXRES, (RtInt)PICYRES, -1.0);  /* Image resolution */
        /* Region of image rendered */
        RiCropWindow(CROPMINX, CROPMAXX,
                     CROPMINY, CROPMAXY);
        FrameCamera(PICXRES*CAMZOOM, PICXRES, PICYRES);
        /* Camera position and orientation */
        CameraTo[0] -= CameraFrom[0];
        CameraTo[1] -= CameraFrom[1];
        CameraTo[2] -= CameraFrom[2];
        PlaceCamera(CameraFrom, CameraTo, CAMROLL);
        RiClipping(RI_EPSILON, RI_INFINITY);            /* Clipping planes*/

        /* Now describe the world */
        RiWorldBegin();
                /* ...Your scene here... */
          RiTranslate(0.0, 0.0, 5.0);
          RiTorus(0.75, 0.4, 0.0, 360.0, 360.0, RI_NULL);

        RiWorldEnd();
        
    RiEnd();

    return 0;
}
