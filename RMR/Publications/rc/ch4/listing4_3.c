/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 67 */
/* Listing 4.3   Using RiTorus to create a wavelike pattern */

#include <ri.h>
#include <stdio.h>


/*
 * TorusWave(nwaves, thetamax): create a set of concentric "waves" using
 *  a hemisphere in the middle and a set of nwaves concentric semi-tori. 
 *  The sweep of the waves is given by the parameter thetamax.
 */
void
TorusWave(nwaves, thetamax)
int nwaves;
float thetamax;
{
    float innerrad, outerrad;
    int wave;

    if(nwaves < 1) {
        fprintf(stderr,"Need a positive number of waves\n");
        return;
    }

    /* Divide the net radius 1.0 among the waves and the hemisphere */
    innerrad = 2 / (8.0*nwaves + 2);
    RiRotate(90.0, 1.0, 0.0, 0.0);

    /* Create the downward-opening hemisphere */
    RiSphere(innerrad, -innerrad, 0.0, thetamax, RI_NULL); 

    outerrad = 0;
    for(wave = 1; wave <= nwaves; wave++) {
        /* 
         * Each iteration creates a downward-opening half-torus
         *  and a larger upward-opening half-torus.
         */
        outerrad = outerrad + (innerrad * 2);
        RiTorus(outerrad, innerrad, 0.0, 180.0, thetamax, RI_NULL);
        outerrad = outerrad + (innerrad * 2);
        RiTorus(outerrad, innerrad, 180.0, 360.0, thetamax, RI_NULL);
    }
}

void Go() { TorusWave(4, 250.0); }
