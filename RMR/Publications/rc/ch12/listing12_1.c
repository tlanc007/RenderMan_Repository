/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 253 */

/* Listing 12.1  Program fragment for generating Figure 12.4   */

#include <ri.h>
#include <stdio.h>

#define GRID_TEXTURE "grid.tx";

Go()
{
    static RtColor color = { 0.9, 0.9, 0.9};
    static RtPoint corners[] = { { -1,  .3,  1 },
                                 {  1, -.1,  1 },
                                 { -1, -.1, -1 },
                                 {  1,  .3, -1 }
    };
    static struct { RtFloat x, y; } textcoords[] = {
           { 0, 0 }, { 0.5, 0 }, { 0, 0.5 }, { 0.5, 0.5 } 
    };
    char *tmap = GRID_TEXTURE;

    RiDeclare("tmap", "uniform string");
    RiSurface("mytexture", (RtToken)"tmap", (RtPointer)&tmap, RI_NULL);
    RiColor(color);

    RiTransformBegin();
        RiTranslate(-1.3, 0.5, 1.0);
        RiRotate(-50.0, 1.0, 0.0, 0.0);                                
        RiPatch("bilinear", RI_P, (RtPointer) corners, RI_NULL);
    RiTransformEnd();
    
    RiTransformBegin();
        RiTranslate(1.0, 0.5, 1.0);
        RiRotate(-40.0, 1.0, 0.0, 0.0);                                
        RiPatch("bilinear", RI_P, (RtPointer) corners, 
                            RI_ST, (RtPointer) textcoords, RI_NULL);
    RiTransformEnd();
}
