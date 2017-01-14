/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 149 */
/* Listing 8.3   A simple camera specification in terms of a physical camera */

#include <ri.h>
#include <stdio.h>

/* FrameCamera(): give physical parameters for a camera.
   Parameters:
    focallength: the "camera's" focal length. 
    framewidth:  the width of the film frame
    frameheight: the height of the film frame
*/
FrameCamera(focallength, framewidth, frameheight)
float focallength, framewidth, frameheight;
{
    RtFloat normwidth, normheight;

    /* Focal length of 0 is taken to be an orthographic projection */
    if (focallength != 0.0) {
        RiProjection("perspective", RI_NULL);
        normwidth = (framewidth*.5)/focallength;
        normheight = (frameheight*.5)/focallength;
    } else {
        RiProjection("orthographic", RI_NULL);
        normwidth = framewidth*.5;
        normheight = frameheight*.5;
    }
    RiScreenWindow(-normwidth, normwidth, -normheight, normheight);
}

