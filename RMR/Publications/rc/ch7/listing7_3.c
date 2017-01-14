/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 131 */ 
/* Listing 7.3  Routine for generating a bowling ball */

#include <math.h>
#include <ri.h>

Go()
{
    BowlingBall();
}

BowlingBall()
{
    static RtColor ballcolor = { 0.2, 0.5, 0.9 };
    static RtColor plugcolor = { 0.1, 0.1, 0.1 };

    RiSolidBegin(RI_DIFFERENCE);

        RiAttributeBegin();
        RiSolidBegin(RI_PRIMITIVE);
            RiColor(ballcolor);
            RiSphere(0.3, -0.3, 0.3, 360.0, RI_NULL);
        RiSolidEnd();
        RiAttributeEnd();

        RiSolidBegin(RI_UNION);
            RiColor(plugcolor);
            RiRotate(170.0, 1.0, 0.0, 0.0);
            BowlingBallPlug();
            RiSolidBegin(RI_UNION);
                RiRotate(30.0, -1.0, 1.0, 0.0);
                BowlingBallPlug();
                RiRotate(30.0, 1.0, 0.0, 0.0);
                BowlingBallPlug();
            RiSolidEnd();
        RiSolidEnd();

    RiSolidEnd();
}

BowlingBallPlug()
{
    RiSolidBegin(RI_UNION);
        SolidCylinder(0.03, -0.3, -0.15);
        RiTranslate(0.0, 0.0, -0.315);
        SolidCone(0.075, 0.045);
    RiSolidEnd();
}

SolidCone(height, radius)
RtFloat height, radius;
{
    RiSolidBegin(RI_PRIMITIVE);
        RiCone(height, radius, 360.0, RI_NULL);
        RiDisk(0.0, radius, 360.0, RI_NULL);
    RiSolidEnd();
}

#include "wedge7_2.c"
