/* Copyrighted Pixar 1989 */
/* Used with the RenderMan Companion chapter 16 */


/* Listing 16a - Routine generating quadric surfaces shown in Figure 4.1 */

#include <ri.h>
#include <math.h>

Go()
{
    RtPoint from, to;
    RtFloat intensity;

    from[0] = 0.0;       from[1] = 0.0;       from[2] = -6.0;
    to[0] = 0.0;         to[1] = 0.0;         to[2] = 6.0;
    intensity = 0.2;

    RiLightSource("ambientlight", 
        (RtToken)"intensity",(RtPointer)&intensity, RI_NULL);

    intensity = 1.0;
    RiLightSource("distantlight", (RtToken)"intensity", (RtPointer)&intensity, 
        (RtToken)"from", (RtPointer)from,
        (RtToken)"to",    (RtPointer)to, RI_NULL);
    ShowQuads();
}

#define OFFSET 1.2

ShowQuads()
{
    static RtColor blue = { 0.2, 0.4, 0.8};
    RtPoint hyperpt1, hyperpt2;

    RiColor(blue);
    RiRotate(-90.0, 1.0, 0.0, 0.0);

    RiTranslate(-OFFSET, 0.0, (OFFSET/2));
    RiSurface("constant", RI_NULL);
    RiSphere(0.5, -0.5, 0.5, 360.0, RI_NULL);   /* Declare a sphere */
            
    RiTranslate(OFFSET, 0.0, 0.0);
    RiTranslate(0.0, 0.0, -0.5);
    RiSurface("matte", RI_NULL);
    RiCone(1.0, 0.5, 360.0, RI_NULL);           /* Declare a cone */

    RiTranslate(0.0, 0.0, 0.5);
    RiTranslate(OFFSET, 0.0, 0.0);
    RiSurface("metal", RI_NULL);
    RiCylinder(0.5, -0.5, 0.5, 360.0, RI_NULL); /* Declare cylinder */

    RiTranslate(-(OFFSET*2), 0.0, -OFFSET); 
    RiSurface("plastic", RI_NULL);
    hyperpt1[0] = 0.4;
    hyperpt1[1] = -0.4;
    hyperpt1[2] = -0.4;
    hyperpt2[0] = 0.4;
    hyperpt2[1] = 0.4;
    hyperpt2[2] = 0.4;

    /* Declare hyperboloid */
    RiHyperboloid(hyperpt1, hyperpt2, 360.0, RI_NULL); 

    RiTranslate(OFFSET, 0.0, -0.5);
    RiSurface("show_st", RI_NULL);
    RiParaboloid(0.5, 0.0, 0.9, 360.0, RI_NULL);  /* Declare paraboloid */

    RiTranslate(OFFSET, 0.0, 0.5);
    RiSurface("checker", RI_NULL);
    RiTorus(.4, .15, 0.0, 360.0, 360.0, RI_NULL); /* Declare torus  */
}
