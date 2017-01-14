/* Copyrighted Pixar 1989 */
/* Used with the RenderMan Companion chapter 16 */

#include <ri.h>
#include <stdio.h>

#include "point2d.h"

#define BASE      1
#define GLOBE     0 
#define THREAD    1
#define LIGHTS    1
#define FILAMENT  1

#define GLOBEMAXX 1.1875
#define GLOBEMINX .5625
#define GLOBEMAXZ 2.625
#define GLOBEMINZ 0.0
#define THREADRAD 0.5
#define THREADHEIGHT 0.6875
#define JOINHEIGHT 0.0625
#define BASEHEIGHT 0.2
#define BASERADIUS 0.2
#define FILAMENTRAD 0.075

Point2D GlobeMiddle = {GLOBEMAXX, GLOBEMAXZ},
        GlobeBottom = {GLOBEMINX, GLOBEMINZ},
        ScrewBottom = {THREADRAD, GLOBEMINZ-JOINHEIGHT-THREADHEIGHT},
        TipBottom  = {BASERADIUS, GLOBEMINZ-JOINHEIGHT-THREADHEIGHT-BASEHEIGHT};

Point2D GlobeProfile[] = {
    { GLOBEMAXX, GLOBEMAXZ },
    { GLOBEMAXX, GLOBEMAXZ - 1.0 },
    { GLOBEMINX, GLOBEMINZ + 1.0 }, 
    { GLOBEMINX, GLOBEMINZ }
};

RtPoint wall[] = {{-8.0, -2.0,  8.0},
                  { 8.0, -2.0,  8.0},
                  { 6.0, -2.0, -2.5},
                  {-6.0, -2.0, -2.5}};

Go() 
{ 
    LightBulb(); 
}

#define THETAMAX 360.0
LightBulb()
{
    RtPoint point1, point2, point3;
    RtColor opac, bronze, copper, black, blue;
    RtFloat disp;
    RtFloat Ks, Ka, Kd, Km, frequency, attenuation;
    RtToken RI_KS, RI_KA, RI_KD, RI_KM, RI_FREQ, RI_ATT;

#if LIGHTS
    RtFloat amb_int, point_int, point2_int;
    RtLightHandle light3, light4;
    static RtPoint from = {-3.0, 6.0, 0.0};
    amb_int = 0.5;
    point_int = 14.0;
    point2_int = 14.0;
    RiLightSource("ambientlight", 
                  "intensity", &amb_int, RI_NULL);
    RiLightSource("pointlight", 
                  "intensity", &point_int, RI_NULL);
    RiLightSource("pointlight", 
                  "from", from,
                  "intensity", &point2_int, RI_NULL);
    from[0] = -3.0; from[1] = 3.0; from[2] = -3.0;
    light3 = RiLightSource("pointlight", 
                  "from", from, 
                  "intensity", &point_int, RI_NULL);
    from[0] = 3.0; from[1] = 3.0; from[2] = 0.0;
    point_int = 8.0;
    light4 = RiLightSource("pointlight", 
                  "from", from, 
                  "intensity", &point_int, RI_NULL);
#endif /* LIGHTS */

    copper[0] = 1.0;
    copper[1] = 0.404693; 
    copper[2] = 0.141722;

    bronze[0] = 1.0;
    bronze[1] = 0.63911;
    bronze[2] = 0.290013;

    black[0] = 0.02;
    black[1] = 0.03;
    black[2] = 0.07;

    blue[0] = 0.1;
    blue[1] = 0.5;
    blue[2] = 0.7;

    RiAttributeBegin(); 

    RiAttributeBegin();
        RiSurface("matte", RI_NULL);
        RiColor(black /* blue */);
        RiPolygon( (RtInt) 4, RI_P, wall, RI_NULL);
    RiAttributeEnd();

    /* tip */
#if BASE
    RiAttributeBegin(); 
    RiSurface("plastic", RI_NULL);
    RiDisk(TipBottom.z, TipBottom.x, THETAMAX, RI_NULL);
    RiColor(black);
    RiCylinder(TipBottom.x, TipBottom.z, TipBottom.z + 0.05, THETAMAX, RI_NULL);

    point1[0] = TipBottom.x;
    point1[1] = 0;
    
    point1[2] = TipBottom.z +0.05;

    point2[0] = (ScrewBottom.x+TipBottom.x)/2.0;
    point2[1] = 0;
    point2[2] = (ScrewBottom.z+TipBottom.z+0.05)/2.0;
    RiColor(black);
    RiHyperboloid(point1, point2, THETAMAX, RI_NULL);

    point3[0] = ScrewBottom.x;
    point3[1] = 0;    
    point3[2] = ScrewBottom.z;
    RiColor(copper);
    RiSurface("metal", RI_NULL);
    RiHyperboloid(point2, point3, THETAMAX, RI_NULL);

    RiAttributeEnd(); 
#endif /* BASE */

#if FILAMENT
    RiAttributeBegin();
    RiColor(copper);
    RiSurface("filament", RI_NULL);
    disp = 0.1;
    RiAttribute("bound", "displacement", (RtPointer)&disp, RI_NULL);
    RiDisplacement("droop", RI_NULL);
    RiTranslate(0.0, 0.0, GLOBEMAXZ);
    RiRotate(90.0, 0.0, 1.0, 0.0);
    RiTextureCoordinates(0.0, 0.25, 1.0, 0.25, 0.0, 0.75, 1.0, 0.75);
    RiCylinder(FILAMENTRAD, -GLOBEMINX+0.2, GLOBEMINX-0.2, THETAMAX, RI_NULL);
    RiTextureCoordinates(0.0, 0.75, 1.0, 0.75, 0.0, 1.0, 1.0, 1.0);
    RiTransformBegin();
        RiTranslate(0.0, 0.0, GLOBEMINX-0.2);
        RiCone(0.2, FILAMENTRAD, THETAMAX, RI_NULL);
    RiTransformEnd();
    RiTextureCoordinates(1.0, 0.25, 0.0, 0.25, 1.0, 0.0, 0.0, 0.0);
    RiTransformBegin();
        RiTranslate(0.0, 0.0, -GLOBEMINX+0.2);
        RiRotate(180.0, 1.0, 0.0, 0.0);
        RiCone(0.2, FILAMENTRAD, THETAMAX, RI_NULL);
    RiTransformEnd();
    RiColor(bronze);
    RI_ATT = RiDeclare("attenuation", "uniform float");
    attenuation = 5.0;
    RiSurface("glow", RI_ATT, &attenuation, RI_NULL);
    RiScale(1.6, 1.6, 4.0);
    RiTextureCoordinates(0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0);
    RiSphere(GLOBEMINX/3.0, -GLOBEMINX/3.0, GLOBEMINX/3.0, THETAMAX, RI_NULL);
    RiAttributeEnd();

#endif /* FILAMENT */

    /* cylinder */
#if THREAD
    RiAttributeBegin();
    disp = 0.1;
    RiAttribute("bound", "displacement", (RtPointer)&disp, RI_NULL);
    Km = 0.05;
    frequency = 4.5;
    RI_FREQ = RiDeclare("frequency", "uniform float");
    RI_KM = RiDeclare("Km", "uniform float");
    RiDisplacement("threads", RI_KM, &Km, RI_FREQ, &frequency, RI_NULL);
    RiColor(copper);
    RiSurface("metal", RI_NULL);
    RiCylinder(THREADRAD, GLOBEMINZ-JOINHEIGHT-THREADHEIGHT, 
    GLOBEMINZ-JOINHEIGHT, 360.0, RI_NULL);
    RiAttributeEnd();
#endif /* THREAD */

    /* globe */
#if GLOBE
    opac[0] = 0.07; opac[1] = 0.07; opac[2] = 0.07;
    RiOpacity(opac);
    RI_KA = RiDeclare("Ka", "uniform float");
    RI_KD = RiDeclare("Kd", "uniform float");
    RI_KS = RiDeclare("Ks", "uniform float");
    Ka = 0.1;
    Kd = 0.1;
    Ks = 0.8;
    RiSurface("bulb", RI_KA, &Ka, RI_KD, &Kd, RI_KS, &Ks, RI_NULL);
    RiAttributeBegin(); 
    RiIlluminate(light3, RI_FALSE);
    RiIlluminate(light4, RI_FALSE);
    RiTransformBegin();            /* joining piece to threads */
        RiTranslate(0.0, 0.0, GlobeBottom.z);
        RiColor(black);
        RiTorus(THREADRAD, JOINHEIGHT, 270.0, 360.0, THETAMAX, RI_NULL);
    RiTransformEnd();
    RiColor(black);                   /* body of globe */
    SurfOR(GlobeProfile, 4);
    RiTransformBegin();           /* hemisphere cap on globe */
        RiTranslate(0.0, 0.0, GlobeMiddle.z);
        RiColor(black);
        RiSphere(GlobeMiddle.x, 0.0, GlobeMiddle.x, THETAMAX, RI_NULL);
    RiTransformEnd();
    RiAttributeEnd(); 
#endif /* GLOBE */

    RiAttributeEnd();
}

#include "surfor.c"
