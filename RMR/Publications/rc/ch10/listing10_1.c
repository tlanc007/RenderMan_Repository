/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 199 */
/* Listing 10.1  Routine specifying geodesic domes with different */
/*               granularities                                    */

#include <ri.h>

main()
{
    static RtColor color = { .2, .4, .6 };

    RiBegin(RI_NULL);            /* Start the renderer     */
	RiDisplay("dome10_1.tiff", RI_FILE, "rgb", RI_NULL);
	RiFormat((RtInt) 256, (RtInt) 192, -1.0);
	RiShadingRate(1.0);

        RiRelativeDetail(0.1);
        RiWorldBegin();

            RiSides( (RtInt) 1);    /* N E W */

            /* Same viewing transformation */
            RiTranslate(0.0, 0.0, 1.5);
            RiRotate(30.0, -1.0, 0.0, 0.0);
            RiRotate(30.0, 0.0, -1.0, 0.0);
                    
            Domes();
        RiWorldEnd();
    
    RiEnd();                    /* Clean up after the renderer */

    return 0;
}

/* 
 *  Domes(): render a geodesic dome divided according to level of detail.
 */
Domes()
{
    RtBound bound;
    bound[0] = bound[2] = bound[4] = -1.0;
    bound[1] = bound[3] = bound[5] =  1.0;

    RiAttributeBegin();/* Push attributes to save level of detail */
        RiDetail(bound);
        RiDetailRange(0.0, 0.0, 10.0, 20.0);
            ColorCube(2, 0.9);
        RiDetailRange(10.0, 20.0, 40.0, 80.0);
            ColorCube(3, 0.9);
        RiDetailRange(40.0, 80.0, 160.0, 320.0);
            ColorCube(4, 0.9);
        RiDetailRange(160.0, 320.0, RI_INFINITY, RI_INFINITY);
            ColorCube(5, 0.9);
    RiAttributeEnd();
}
