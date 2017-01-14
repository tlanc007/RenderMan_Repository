/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 61 */
/* Listing 4.1  Routine generating quadric surfaces shown in Figure 4.1 */

#include <ri.h>
#include <stdio.h>

void Go()
{   
	ShowQuads();
}

#define OFFSET 1.2

ShowQuads()
{
    RtPoint hyperpt1, hyperpt2;

    RiRotate(-90.0, 1.0, 0.0, 0.0);

    RiTranslate(-OFFSET, 0.0, (OFFSET/2));
    RiSphere(0.5, -0.5, 0.5, 360.0, RI_NULL);         /* Declare a sphere */
            
    RiTranslate(OFFSET, 0.0, 0.0);
    RiTranslate(0.0, 0.0, -0.5);
    RiCone(1.0, 0.5, 360.0, RI_NULL);                 /* Declare a cone */

    RiTranslate(0.0, 0.0, 0.5);
    RiTranslate(OFFSET, 0.0, 0.0);
    RiCylinder(0.5, -0.5, 0.5, 360.0, RI_NULL);       /* Declare cylinder */

    RiTranslate(-(OFFSET*2), 0.0, -OFFSET); 
    hyperpt1[0] = 0.4;
    hyperpt1[1] = -0.4;
    hyperpt1[2] = -0.4;
    hyperpt2[0] = 0.4;
    hyperpt2[1] = 0.4;
    hyperpt2[2] = 0.4;

    /* Declare hyperboloid */
    RiHyperboloid(hyperpt1, hyperpt2, 360.0, RI_NULL); 

    RiTranslate(OFFSET, 0.0, -0.5);
    RiParaboloid(0.5, 0.0, 0.9, 360.0, RI_NULL);      /* Declare paraboloid */

    RiTranslate(OFFSET, 0.0, 0.5);
    RiTorus(.4, .15, 0.0, 360.0, 360.0, RI_NULL);     /* Declare torus */
    
}

