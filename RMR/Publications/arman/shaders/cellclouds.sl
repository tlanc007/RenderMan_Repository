/****************************************************************************
 * cellclouds - self-shadowing volumetric clouds
 *
 * Params:
 *   Ka, Kd - the usual meaning
 *   radius - object space radius of the sphere in which the volume resides
 *   opacdensity - overall smoke density control as it affects its ability
 *          to block light from behind it.
 *   lightdensity - smoke density control as it affects light scattering
 *          toward the viewer.
 *   shadowdensity - smoke density control as it affects its ability to
 *          shadow iteself.
 *   stepsize - step size for integration
 *   shadstepsize - step size for self-shadowing ray marching
 *   noisefreq - frequency of the noise field that makes the volume
 *
 * Reference:
 *   _Advanced RenderMan: Creating CGI for Motion Picture_, 
 *   by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
 *
 ****************************************************************************/


#include "noises.h"
#include "filterwidth.h"
#include "raysphere.h"


float volumedensity (point Pobj;  float radius, noisefreq, stepsize;
                     output point cellcenter)
{
    float density;
    voronoi_f1_3d (Pobj*noisefreq, 1, density, cellcenter);
    density = 1 - density;
    /* Increase Contrast */
    density = pow(clamp(density,0,1), 7.28);
    /* Fade At Edges Of Sphere */
    density *= 1 - smoothstep (0.8, 1, length(Pobj)/radius);
    return density;
}


color volumecolor (point Pcenter)
{
#pragma nolint
    return color "hsv" (cellnoise(Pcenter), 1, 1);
}


float volumeshadow (point Pobj; vector Lobj;
                    float radius, density, noisefreq, stepsize)
{
    float Oi = 0;
    float Llen = length(Lobj);
    vector Iobj = normalize(Lobj);
    float t0, t1;
    float hits = raysphere (Pobj, Lobj, radius, 1.0e-4, t0, t1);
    float end = (hits > 0) ? t0 : 0;  /* distance to march */
    end = min (end, Llen);
    float d = 0;
    float ss = min (stepsize, end-d);
    point cellcenter;
    float last_dtau = volumedensity (Pobj, radius, noisefreq,
				     stepsize, cellcenter);
    while (d <= end) {
	/* Take a step and get the scattered light and density */
	ss = clamp (ss, 0.005, end-d);
	d += ss;
	float dtau = volumedensity (Pobj + d*Iobj, radius,
				    noisefreq, stepsize, cellcenter);
	float tau = density * ss/2 * (dtau + last_dtau);
	Oi += (1-Oi) * (1 - exp(-tau));
	last_dtau = dtau;
    }
    return Oi;
}


color volumelight (point Pcur, Pobj;
                   float radius, density, noisefreq, stepsize;
                   point cellcenter)
{
    color Lscatter = 0;
    illuminance (Pcur) {
	extern color Cl;
	extern vector L;
	color Cscat = Cl;
	if (density > 0)
	    Cscat *= 1 - volumeshadow (Pobj, vtransform("object",L),
				       radius, density, noisefreq, stepsize);
	Lscatter += Cscat;
    }
    return Lscatter * volumecolor(cellcenter);
}



surface
cellclouds (float Ka = 0.127, Kd = 1;
	    float radius = 10.0;
	    float opacdensity = 1, lightdensity = 1, shadowdensity = 1;
	    float stepsize = 0.1, shadstepsize = 0.5;
	    float noisefreq = 2.0;)
{
    Ci = Oi = 0;
    /* Do not shade the front of the sphere -- only the back! */
    if (N.I > 0) {
	/* Find the segment to trace through.  The far endpoint is simply
	 * P.  The other endpoint can be found by ray tracing against the
	 * sphere (in the opposite direction).
	 */
	point  Pobj = transform ("object", P);
	vector Iobj = normalize (vtransform ("object", I));
	float t0, t1;
	float hits = raysphere (Pobj, -Iobj, radius, 1.0e-4, t0, t1);
	float end = (hits > 0) ? t0 : 0;  /* distance to march */
	point origin = Pobj - t0*Iobj;
	point Worigin = transform ("object", "current", origin);

	/* Integrate forwards from the start point */
	float d = random()*stepsize;
	
	/* Calculate a reasonable step size */
	float ss = min (stepsize, end-d);

	point Psamp = origin + d*Iobj;
	point cellcenter;
	float last_dtau = volumedensity (Psamp, radius, noisefreq,
					 stepsize, cellcenter);
	color last_li = volumelight (transform ("object", "current", Psamp),
				     Psamp, radius, shadowdensity,
				     noisefreq, shadstepsize, cellcenter);
	while (d <= end) {
	    /* Take a step and get the scattered light and density */
	    ss = clamp (ss, 0.005, end-d);
	    d += ss;
	    /* Get the scattered light and density */
	    Psamp = origin + d*Iobj;
	    float dtau = volumedensity (Psamp, radius, noisefreq,
					stepsize, cellcenter);
	    color li = volumelight (transform ("object", "current", Psamp),
				    Psamp, radius, shadowdensity,
				    noisefreq, shadstepsize, cellcenter);
			       
	    float tau = opacdensity * ss/2 * (dtau + last_dtau);
	    color lighttau = lightdensity * ss/2 * (li*dtau + last_li*last_dtau);
	    
	    /* Composite with exponential extinction of background light */
	    Ci += (1-Oi) * lighttau;
	    Oi += (1-Oi) * (1 - exp(-tau));
	    last_dtau = dtau;
	    last_li = li;
	}
    }
}
