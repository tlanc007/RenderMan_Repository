/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 25 */
/* NOTE: The main() function has been removed and moved to colormain.c */
/* Listing 2.3   Control over viewer and color */

#include <ri.h>
#include <stdio.h>

#define L -.5       /* For x: left side     */
#define R  .5       /* For x: right side    */
#define D -.5       /* For y: down side     */
#define U  .5       /* For y: upper side    */
#define F  .5       /* For z: far side      */
#define N -.5       /* For z: near side     */

/* UnitCube(): define a cube in the graphics environment */
UnitCube()
{
    static RtPoint Cube[6][4] = {
        { {L,D,F},  {L,D,N},  {R,D,N},  {R,D,F} },   /* Bottom face  */
        { {L,D,F},  {L,U,F},  {L,U,N},  {L,D,N} },   /* Left face    */
        { {R,U,N},  {L,U,N},  {L,U,F},  {R,U,F} },   /* Top  face    */
        { {R,U,N},  {R,U,F},  {R,D,F},  {R,D,N} },   /* Right face   */
        { {R,D,F},  {R,U,F},  {L,U,F},  {L,D,F} },   /* Far face     */
        { {L,U,N},  {R,U,N},  {R,D,N},  {L,D,N} }    /* Near face    */
    };
    int i;
    for( i = 0; i < 6; i++)  /* Declare the cube  */
        RiPolygon( (RtInt) 4, RI_P, (RtPointer) Cube[i], RI_NULL);    
}
