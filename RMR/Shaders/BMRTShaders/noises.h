/************************************************************************
 * noises.h - various noise-based patterns
 *
 * $Revision: 1.1.1.1 $    $Date: 2002/02/10 02:35:49 $
 *
 ************************************************************************/




/* Signed noise -- the original Perlin kind with range (-1,1) */
#ifndef snoise
#define snoise(p) (2 * (float noise(p)) - 1)
#define snoise2(x,y) (2 * (float noise(x,y)) - 1)
#endif


/* If we know the filter size, we can crudely antialias snoise by fading
 * to its average value at approximately the Nyquist limit.
 */
#define filteredsnoise(p,width) (snoise(p) * (1 - smoothstep (0.2,0.6,width)))



/* Having filteredsnoise leads easily to an antialiased version of fBm. */
float filtered_fBm (point p; float filtwidth;
                    uniform float maxoctaves, lacunarity, gain)
{
    uniform float i;
    uniform float amp = 1;
    varying point pp = p;
    varying float sum = 0, fw = filtwidth;

    for (i = 0;  i < maxoctaves && fw < 1.0;  i += 1) {
	sum += amp * filteredsnoise (pp, fw);
	amp *= gain;  pp *= lacunarity;  fw *= lacunarity;
    }
    return sum;
}


#define filtered_fBm_default(p)  filtered_fBm (p, sqrt(area(p)), 4, 2, 0.5)

