/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 55 */
/* Listing 3.1  The structure of a RenderMan program  */

#include <ri.h>
render(nframes)         /* Basic program using the RenderMan Interface */
int nframes;
{
    int frame;

    RiBegin();        /* Options may now be set */
        /* IMAGE OPTION SECTION: See Chapter 8 */
        RiDisplay( ... );
        RiFormat( ... );
        ...
        /* CAMERA OPTION SECTION: See Chapter 8 */
        RiClipping( ... );
        RiDepthOfField( ... );
        RiProjection("perspective", RI_NULL);  /* The current  trans- */
            /* formation is cleared so the camera can be specified.   */
        RiRotate( ... );      /* These transformations address the    */
        RiTranslate( ... );   /* world-to-camera transformation       */
        ... /* controlling placement and orientation of the camera.   */

        for(frame = 1; frame <= nframes; frame++) {
            RiFrameBegin( frame );
                /* FRAME-DEPENDENT OPTION SECTION                           */
                /* Can still set frame-dependent options, camera xforms     */
                RiWorldBegin(); /* SCENE DESCRIPTION SECTION:               */
                    /* The camera xform is now set; options are frozen      */ 
                    /* and rendering may begin. We are in world space.      */
                    RiAttributeBegin(); /* Begin a distinct object          */
                        RiColor( ... );         /* Attributes fit in here   */
                        RiSurface( ... );       /* See Chapter 11           */
                        RiTransformBegin();     /* See Chapter 7            */
                            RiTranslate( ... ); /* Object-positioning       */
                            RiRotate( ... );    /* commands (see Ch. 7)     */
                            ...     
                            RiSphere( ... );    /* See Chapter 4            */
                            RiPolygon( ... );   /* See Chapter 5            */
                            RiPatch( ... );     /* See Chapter 6            */
                        RiTransformEnd();
                    RiAttributeEnd();   /* Restore the parent's attributes. */
                    ...                 /* Other objects, other spaces      */
                RiWorldEnd();   /* The scene is complete. The image is ren- */
                    /* dered and all scene data is discarded. Other scenes  */
                    /* may now be declared with other world blocks.         */
            RiFrameEnd();      /* Options are restored. */
        }
    RiEnd();
}

