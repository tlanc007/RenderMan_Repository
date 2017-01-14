/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 220 */

/* Listing 4.1  Routine generating quadric surfaces shown in Figure 4.1 */

#include <ri.h>
#include <math.h>

#ifndef M_PI
#define M_PI 3.14159265358979
#endif

#define PICXRES 256
#define PICYRES 192

Go()
{
    /* Listing 11.1  Program invoking four basic light sources */

    RtPoint from, to;
    RtFloat intensity, conedeltaangle, coneangle;

    from[0] = 0.0;     from[1] = 0.0;   from[2] = -6.0;
    to[0] = 0.0;       to[1] = 0.0;     to[2] = 6.0;
    intensity = 1.0;
    conedeltaangle = 1.0 * M_PI / 180.0;
    coneangle = 11.0 * M_PI / 180.0;

    RiFormat( (RtInt) PICXRES, (RtInt) PICYRES, -1.0);
    RiFrameBegin( (RtInt) 1);
	RiDisplay("frame.1.tiff", RI_FILE, RI_RGB, RI_NULL);
        RiLightSource("ambientlight", 
                      (RtToken)"intensity",(RtPointer)&intensity, 
                      RI_NULL);
        RiWorldBegin();
            ShowQuads();
        RiWorldEnd();
    RiFrameEnd();

    RiFormat( (RtInt) PICXRES,  (RtInt) PICYRES, -1.0);
    RiFrameBegin( (RtInt) 2);
	RiDisplay("frame.2.tiff", RI_FILE, RI_RGB, RI_NULL);
        RiLightSource("distantlight", 
                      (RtToken)"intensity", (RtPointer)&intensity, 
                      (RtToken)"from",      (RtPointer)from,
                      (RtToken)"to",        (RtPointer)to, RI_NULL);
        RiWorldBegin();
            ShowQuads();
        RiWorldEnd();
    RiFrameEnd();

    intensity = 16.0;

    RiFormat( (RtInt) PICXRES, (RtInt) PICYRES, -1.0);
    RiFrameBegin( (RtInt) 3);
	RiDisplay("frame.3.tiff", RI_FILE, RI_RGB, RI_NULL);
        RiLightSource("pointlight", 
                      (RtToken)"intensity", (RtPointer)&intensity,
                      (RtToken)"from", (RtPointer)from, RI_NULL);
        RiWorldBegin();
            ShowQuads();
        RiWorldEnd();
    RiFrameEnd();
    
    RiFormat( (RtInt) PICXRES, (RtInt) PICYRES, -1.0);
    RiFrameBegin( (RtInt) 4);
	RiDisplay("frame.4.tiff", RI_FILE, RI_RGB, RI_NULL);
        RiLightSource("spotlight", 
            (RtToken)"intensity",      (RtPointer)&intensity,
            (RtToken)"conedeltaangle", (RtPointer)&conedeltaangle,
            (RtToken)"coneangle",      (RtPointer)&coneangle,
            (RtToken)"from",           (RtPointer)from,
            (RtToken)"to",             (RtPointer)to,
            RI_NULL);
        RiWorldBegin();
            ShowQuads();
        RiWorldEnd();
    RiFrameEnd();
    
}
    
#define OFFSET 1.2
    
ShowQuads()
{
    RtFloat ka, kd, ks;
    RtPoint hyperpt1, hyperpt2;

    RiRotate(-90.0, 1.0, 0.0, 0.0);

    RiTranslate(-OFFSET, 0.0, (OFFSET/2));
    ka = 0.3; ks = kd = 0;
    RiSurface("plastic",    
              (RtToken)"Ka",    (RtPointer)&ka,
              (RtToken)"Kd",    (RtPointer)&kd,
              (RtToken)"Ks",    (RtPointer)&ks,
              RI_NULL);
    RiSphere(0.5, -0.5, 0.5, 360.0, RI_NULL);         /* Declare a sphere  */
            
    RiTranslate(OFFSET, 0.0, 0.0);
    RiTranslate(0.0, 0.0, -0.5);
    kd = 1; ka = ks = 0;
    RiSurface("plastic",    
                (RtToken)"Ka",    (RtPointer)&ka,
                (RtToken)"Kd",    (RtPointer)&kd,
                (RtToken)"Ks",    (RtPointer)&ks,
                RI_NULL);
    RiCone(1.0, 0.5, 360.0, RI_NULL);                /* Declare a cone   */

    RiTranslate(0.0, 0.0, 0.5);
    RiTranslate(OFFSET, 0.0, 0.0);
    ks = 0.5; ka = kd = 0; 
    RiSurface("plastic",    
                (RtToken)"Ka",    (RtPointer)&ka,
                (RtToken)"Kd",    (RtPointer)&kd,
                (RtToken)"Ks",    (RtPointer)&ks,
                RI_NULL);
    RiCylinder(0.5, -0.5, 0.5, 360.0, RI_NULL);      /* Declare cylinder */

    RiTranslate(-(OFFSET*2), 0.0, -OFFSET); 
    ka = 0.5;
    ks = 2;
    kd = 0.5;
    RiSurface("plastic",    
                (RtToken)"Ka",    (RtPointer)&ka,
                (RtToken)"Kd",    (RtPointer)&kd,
                (RtToken)"Ks",    (RtPointer)&ks,
                RI_NULL);
    hyperpt1[0] = 0.4;
    hyperpt1[1] = -0.4;
    hyperpt1[2] = -0.4;
    hyperpt2[0] = 0.4;
    hyperpt2[1] = 0.4;
    hyperpt2[2] = 0.4;

    /* Declare hyperboloid */
    RiHyperboloid(hyperpt1, hyperpt2, 360.0, RI_NULL); 

    RiTranslate(OFFSET, 0.0, -0.5);
    RiParaboloid(0.5, 0.0, 0.9, 360.0, RI_NULL);       /* Declare paraboloid */

    RiTranslate(OFFSET, 0.0, 0.5);
    RiTorus(.4, .15, 0.0, 360.0, 360.0, RI_NULL);      /* Declare torus    */
}

