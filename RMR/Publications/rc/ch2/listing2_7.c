/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 32 */
/* Listing 2.7  A more efficient color cube   */

#include <ri.h>
#include <stdio.h>

/* 
 *   ColorCube(): create a unit color cube from smaller cubes 
 *   Parameters:
 *      n: the number of minicubes on a side
 *      s: a scale factor for each minicube
 */
void
ColorCube(n, s)
int n;
float s;
{
    int x, y, z;
    RtColor color;
    RtObjectHandle cube;

    if(n<=0)
        return;

    cube = RiObjectBegin();
        UnitCube();
    RiObjectEnd();

    RiAttributeBegin();

        RiTranslate(-.5, -.5, -.5 );
        RiScale(1.0/n, 1.0/n, 1.0/n);

        for(x = 0; x < n; x++)
            for(y = 0; y < n; y++)
                for(z = 0; z < n; z++) {
                    color[0] = ((float) x+1) / ((float) n);
                    color[1] = ((float) y+1) / ((float) n);
                    color[2] = ((float) z+1) / ((float) n);

                    RiColor(color);
                    RiTransformBegin();
                        RiTranslate (x+.5, y+.5, z+.5);
                        RiScale(s, s, s);
                        RiObjectInstance(cube);
                    RiTransformEnd();
                }
    RiAttributeEnd();
}

