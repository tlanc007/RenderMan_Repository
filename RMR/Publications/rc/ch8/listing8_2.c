/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 142 */
/* Listing 8.2   A simple camera specification */

#include <ri.h> 

void AimZ();

/* 
 * PlaceCamera(): establish a viewpoint, viewing direction and orientation
 *    for a scene. This routine must be called before RiWorldBegin(). 
 *    position: a point giving the camera position
 *    direction: a point giving the camera direction relative to position
 *    roll: an optional rotation of the camera about its direction axis 
 */

PlaceCamera(position, direction, roll)
RtPoint position, direction;
float roll;
{
    RiIdentity();                 /* Initialize the camera transformation */
    RiRotate(-roll, 0.0, 0.0, 1.0);
    AimZ(direction);
    RiTranslate(-position[0], -position[1], -position[2]);
}

/* 
 * AimZ(): rotate the world so the directionvector points in 
 *    positive z by rotating about the y axis, then x. The cosine 
 *    of each rotation is given by components of the normalized 
 *    direction vector. Before the y rotation the direction vector 
 *    might be in negative z, but not afterward.
 */
#define PI 3.14159265359
#include <math.h>
void
AimZ(direction)
RtPoint direction;
{
    double xzlen, yzlen, yrot, xrot;

    if (direction[0]==0 && direction[1]==0 && direction[2]==0)
        return;
    /*
     * The initial rotation about the y axis is given by the projection of
     * the direction vector onto the x,z plane: the x and z components
     * of the direction. 
     */
    xzlen = sqrt(direction[0]*direction[0]+direction[2]*direction[2]);
    if (xzlen == 0)
        yrot = (direction[1] < 0) ? 180 : 0;
    else
        yrot = 180*acos(direction[2]/xzlen)/PI;

    /*
     * The second rotation, about the x axis, is given by the projection on
     * the y,z plane of the y-rotated direction vector: the original y
     * component, and the rotated x,z vector from above. 
    */
    yzlen = sqrt(direction[1]*direction[1]+xzlen*xzlen);
    xrot = 180*acos(xzlen/yzlen)/PI;       /* yzlen should never be 0 */

    if (direction[1] > 0)
        RiRotate(xrot, 1.0, 0.0, 0.0);
    else
        RiRotate(-xrot, 1.0, 0.0, 0.0);
    /* The last rotation declared gets performed first */
    if (direction[0] > 0)
        RiRotate(-yrot, 0.0, 1.0, 0.0);
    else
        RiRotate(yrot, 0.0, 1.0, 0.0);
}
