/*
 * glow(): a shader for providing a centered "glow" in a sphere
 *
 * From _RC_ Listing 16.26 p. 369
 * Surface mapping object-space coordinates to colors
 */
surface
glow (float attenuation = 2)
{
        float falloff = I.N;  /* Direct incidence has cosine closer to 1. */

        if (falloff < 0) {
                /* Normalize falloff by lengths of I and N */
                falloff = falloff * falloff / (I.I * N.N);
                falloff = pow (falloff, attenuation);
                Ci = Cs * falloff;
                Oi = falloff;
        }
        else
                Oi = 0;
}
