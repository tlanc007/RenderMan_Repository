/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 138 */
/* Listing 8.1   A boilerplate viewing program */

#include <ri.h> 
#include <stdio.h>

main()
{
    RtFloat fov;
    RiBegin(RI_NULL);                

        /* Output image characteristics */
        /* Output to file "ri.pic"  */
	RiDisplay("ri.tiff", RI_FILE, RI_RGBA, RI_NULL);
        RiFormat( (RtInt) 256, (RtInt) 192, -1.0); /* Image resolution */
	RiShadingRate(1.0);		     /* Quality knob	      */
        RiCropWindow(0.0, 1.0, 0.0, 1.0);    /* Rendered subregion    */

        /* Camera characteristics */
        RiScreenWindow(-1.33, 1.33, -1.0, 1.0);
                                             /* Window on image plane */

        /* Nature of the projection to the image plane */
        fov = 90;
        RiProjection("perspective",          /* Perspective view      */
            RI_FOV, (RtPointer)&fov, RI_NULL);

        /* Camera position and orientation */
        RiRotate(0.0, 0.0, 0.0, 1.0);        /* Camera roll           */
        RiRotate(0.0, 0.0, 1.0, 0.0);        /* Camera yaw            */
        RiRotate(0.0, 1.0, 0.0, 0.0);        /* Camera pitch          */
        RiTranslate(0.0, 0.0, 0.0);          /* Camera position       */

        /* Now describe the world */
        RiWorldBegin();
            /* <Scene is described here> */
          RiTranslate(0.0, 0.0, 5.0);
          RiTorus(0.75, 0.4, 0.0, 360.0, 360.0, RI_NULL);
        RiWorldEnd();
    RiEnd();

    return 0;
}
