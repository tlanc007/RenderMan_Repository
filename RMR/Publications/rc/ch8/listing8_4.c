/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 154 */ 
/* Listing 8.4   A simple camera specification in terms of a physical camera */
/*               with field of view control. */

/* FrameCamera(): give physical parameters for a camera.
 * Parameters:
 *    focallength: controls the width of the camera's field of view. 
 *    framewidth: the width of the film image
 *    frameheight: the height of the film image*/
#include <ri.h>
#include <math.h>
#define min(a,b) ((a)<(b)?(a):(b))
FrameCamera(focallength, framewidth, frameheight)
float focallength, framewidth, frameheight;
{
    RtFloat fov;
    /* A nonzero focal length is taken to be a "normal" lens */
    if(focallength != 0.0) {
        fov = 2 * atan((min(framewidth,frameheight)*.5)/focallength) *
	      180.0/3.14159;
        RiProjection("perspective", 
            RI_FOV, (RtPointer)&fov, RI_NULL);
    } else 
        RiProjection("orthographic", RI_NULL);    
    RiFrameAspectRatio((RtFloat)(framewidth/frameheight));
}
