/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 94 */ 
/* Listing 6.2  Generating a Catmull-Rom bicubic surface from the previous control hull */


#include <ri.h>
#include <stdio.h>

#define X0 -1
#define X1 -.33
#define X2 .33
#define X3 1
#define Y0 -.7
#define Y1 -.1
#define Y2 0.1
#define Y3 0.7
#define Z0 -1
#define Z1 -.33
#define Z2 .33
#define Z3 1

Go()
{
    static RtPoint Patch[16] = {
        { X0, Y0, Z0}, { X1, Y2, Z0}, { X2, Y1, Z0}, { X3, Y3, Z0},
        { X0, Y1, Z1}, { X1, Y2, Z1}, { X2, Y1, Z1}, { X3, Y2, Z1},
        { X0, Y1, Z2}, { X1, Y2, Z2}, { X2, Y1, Z2}, { X3, Y2, Z2},
        { X0, Y0, Z3}, { X1, Y2, Z3}, { X2, Y1, Z3}, { X3, Y3, Z3}};
    DoCatmullRomPatch(Patch);
}

/* Listing 6.2  Generating a Catmull-Rom bicubic surface from */
/*              the previous control hull                     */


DoCatmullRomPatch(patch)
RtPoint patch[4][4];
{
    RiBasis(RiCatmullRomBasis, RI_CATMULLROMSTEP,
            RiCatmullRomBasis, RI_CATMULLROMSTEP);
    RiPatch(RI_BICUBIC, RI_P, (RtPointer) patch, RI_NULL);
}

