/****************************************************************************
 * gcloud - simple "Gardner cloud" shader
 * 
 * Description:
 *   Use spheres as particles for clouds -- this shader will make a nice
 *   fluffy cloud appearance on them.  Fade with angle causes the edges
 *   of the spheres to not be apparent.  Also includes controls for
 *   falloff with distance from the camera and with age of the particle.
 *
 * Parameters:
 *   Kd - the usual meaning
 *   shadingspace - what space the noise is sampled in
 *   freq, octaves, lacunarity, gain - params to the fBm function
 *   edgefalloff - controls falloff at the edge of the sphere
 *   distfalloff, mindistfalloff, maxdistfalloff - controls falloff with
 *           distance from the camera
 *   age - age of the particle (pass on the geometry of each particle)
 *   agefalloff, minagefalloff maxagefalloff - controls fading out of
 *           the particle with age
 *
 * Reference:
 *   _Advanced RenderMan: Creating CGI for Motion Picture_, 
 *   by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
 *
 ****************************************************************************/



#include "noises.h"



surface
gcloud (float Kd = 0.5;
        string shadingspace = "shader";
	/* Controls for turbulence on the sphere */
	float freq = 4, octaves = 3, lacunarity = 2, gain = 0.5;
	/* Falloff control at edge of sphere */
	float edgefalloff = 8;
	/* Falloff controls for distance from camera */
	float distfalloff = 1, mindistfalloff = 100, maxdistfalloff = 200;
	/* Falloff controls for age of particle */
	float age = 0;
	float agefalloff = 2, minagefalloff = 10, maxagefalloff = 20;
    )
{
    point Pshad = freq * transform (shadingspace, P);
    float dPshad = filterwidthp (Pshad);

    if (N.I > 0) {
	/* Back side of sphere... just make transparent */
	Ci = 0;
	Oi = 0;
    } else {  /* Front side: here's where all the action is */

	/* Use fBm for texturing function */
	float opac = fBm (Pshad, dPshad, octaves, lacunarity, gain);
	opac = smoothstep (-1, 1, opac);
	/* Falloff near edge of sphere */
	opac *= pow (abs(normalize(N).normalize(I)), edgefalloff);
	/* Falloff with distance */
	float reldist = smoothstep(mindistfalloff, maxdistfalloff, length(I));
	opac *= pow (1-reldist, distfalloff);
	/* Falloff with age */
	float relage = smoothstep(minagefalloff, maxagefalloff, age);
	opac *= pow (1-relage, agefalloff);

	color Clight = 0;
	illuminance (P) {
	    /* We just use isotropic scattering here, but a more
	     * physically realistic model could be used to favor
	     * front- or back-scattering or any other BSDF.
	     */
	    Clight += Cl;
	}
	Oi = opac * Oi;
	Ci = Kd * Os * Cs * Clight;
    }
}
