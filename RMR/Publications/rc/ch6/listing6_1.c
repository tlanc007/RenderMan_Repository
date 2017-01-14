/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 89 */ 
/* Listing 6.1  Declaring a single bicubic patch or nine bilinear patches */

#include <ri.h>
#include <stdio.h>

#define PATCH 1

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
    PatchExample(Patch);
}

PatchExample(Patch)
RtPoint Patch[4][4];
{
    RtPoint blpatch[2][2];
    int u, v;
#define MOVE_PT(d, s) {d[0]=s[0]; d[1]=s[1]; d[2]=s[2];}
#ifdef PATCH
    RiPatch(RI_BICUBIC,
        RI_P, (RtPointer) Patch,
        RI_NULL);
#endif
#ifdef HULL
    for (v = 0; v < 3; v++) {
        for (u = 0; u < 3; u++) {
            MOVE_PT(blpatch[0][0], Patch[v][u])
            MOVE_PT(blpatch[0][1], Patch[v][u+1])
            MOVE_PT(blpatch[1][0], Patch[v+1][u])
            MOVE_PT(blpatch[1][1], Patch[v+1][u+1])
            RiPatch(RI_BILINEAR,
                RI_P, (RtPointer) blpatch,
                RI_NULL);
        }
    }
#endif
}
