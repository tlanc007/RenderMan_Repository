/* Copyrighted Pixar 1989 */
/* Used with the RenderMan Companion chapter 16 */

/* Listing 16a - Routine generating quadric surfaces shown in Figure 4.1 */

#include <ri.h>
#include <math.h>

Go()
{
    RtFloat intensity;
    RtPoint from;

    intensity = 0.2;
    from[0] = 0.0;    from[1] = 2.0;        from[2] = -6.0;

    RiDeclare("intensity", "uniform float");
    RiDeclare("from", "uniform point");
    RiLightSource("ambientlight", 
        (RtToken)"intensity",(RtPointer)&intensity, RI_NULL);

    intensity = 64.0;
    RiLightSource("pointlight", (RtToken)"intensity", (RtPointer)&intensity, 
        (RtToken)"from", (RtPointer)from, RI_NULL);
    ShowQuads();
}

#define OFFSET 1.2

ShowQuads()
{
    static RtColor white = { 0.7, 0.8, 0.9};

    RtFloat Ks, Ka, Kd;
    RtPoint hyperpt1, hyperpt2;

    RiColor(white);
    RiRotate(-90.0, 1.0, 0.0, 0.0);

    RiTranslate(-OFFSET, 0.0, (OFFSET/2));
    RiSurface("show_xyz", RI_NULL);
    RiSphere(0.5, -0.5, 0.5, 360.0, RI_NULL);       /* Declare a sphere */
            
    RiTranslate(OFFSET, 0.0, 0.0);
    RiTranslate(0.0, 0.0, -0.5);

    RiSurface("screen", RI_NULL);
    RiCone(1.0, 0.5, 360.0, RI_NULL);               /* Declare a cone   */

    RiTranslate(0.0, 0.0, 0.5);
    RiTranslate(OFFSET, 0.0, 0.0);
    RiSurface("wood", RI_NULL);
    RiCylinder(0.5, -0.5, 0.5, 360.0, RI_NULL);     /* Declare cylinder */

    RiColor(white);
    RiTranslate(-(OFFSET*2), 0.0, -OFFSET); 
    RiAttributeBegin();
        RiSurface("metal", RI_NULL);
        RiDisplacement("dented", RI_NULL);
        hyperpt1[0] = 0.4;
        hyperpt1[1] = -0.4;
        hyperpt1[2] = -0.4;
        hyperpt2[0] = 0.4;
        hyperpt2[1] = 0.4;
        hyperpt2[2] = 0.4;

        /* Declare hyperboloid */
        RiHyperboloid(hyperpt1, hyperpt2, 360.0, RI_NULL); 
    RiAttributeEnd();

    RiTranslate(OFFSET, 0.0, -0.5);
    Ks = 0.8;
    Ka = 0.5;
    RiSurface("eroded", RI_KS, &Ks, RI_KA, &Ka, RI_NULL);
    RiParaboloid(0.5, 0.0, 0.9, 360.0, RI_NULL);    /* Declare paraboloid */

    RiTranslate(OFFSET, 0.0, 0.5);
    Kd = 1.0;
    Ka = 1.0;
    RiSurface("granite", RI_KD, &Kd, RI_KA, &Ka, RI_NULL);
    RiTorus(.4, .15, 0.0, 360.0, 360.0, RI_NULL);   /* Declare torus */
    
}

