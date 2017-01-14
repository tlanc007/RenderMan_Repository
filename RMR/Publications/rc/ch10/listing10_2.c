/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 200 */

/* Listing 10.2  Program to dissolve a crude model into a refined one */
/*
 * The following program fragment generates a series of frames 
 * dissolving from a crude geodesic dome to a more detailed one
 * of the same size.
 */
    ... /* Statements here set up the viewing transform for the dome */
    for (i = 1; i <= NFRAMES; i++) {
        ... /* Statements here initialize a new image */
        RiFrameBegin(i);
            RiRelativeDetail(((float)i)/NFRAMES);
            RiWorldBegin();
                Domes();
            RiWorldEnd();
        RiFrameEnd();
    }
