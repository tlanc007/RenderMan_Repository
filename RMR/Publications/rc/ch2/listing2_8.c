/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 34 */
/* Listing 2.8  A simple animation  */

#include <ri.h>
#include <stdio.h>

#define NFRAMES 10      /* number of frames in the animation */
#define NCUBES  5       /* # of minicubes on a side of the color cube */
#define FRAMEROT 5.0    /* # of degrees to rotate cube between frames */

main()
{
    RtInt frame;
    float scale;
    char filename[20];
    
    RiBegin(RI_NULL);    /* Start the renderer */

        for (frame = 1; frame <= NFRAMES; frame++) {
            sprintf(filename, "anim.%d.tiff", frame );
            RiFrameBegin(frame);
	        RiLightSource("distantlight", RI_NULL); 

        	/* Viewing transformation */
	        RiProjection("perspective", RI_NULL);
        	RiTranslate(0.0, 0.0, 1.5);
	        RiRotate(40.0, -1.0, 1.0, 0.0);

	RiDisplay(filename, RI_FILE, RI_RGBA, RI_NULL);
		RiFormat((RtInt) 256, (RtInt) 192, -1.0);
		RiShadingRate(1.0);
                RiWorldBegin();

                    RiSides((RtInt) 1);  /* N E W */

                    scale = (float)(NFRAMES-(frame-1)) / (float)NFRAMES; 
                    RiRotate(FRAMEROT*frame, 0.0, 0.0, 1.0);
                    RiSurface("matte", RI_NULL);
                    ColorCube(NCUBES, scale);        /* Define the cube */
                RiWorldEnd();
            RiFrameEnd();
        }

    RiEnd();

    return 0;
}
