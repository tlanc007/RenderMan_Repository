/****************************************************************************
 * hypertexture.sl - self-shadowing solid clouds
 *
 * Parameters:
 *   Ka, Kd, Ks - the usual meaning
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
 *   thresh - threshold value for the solid boundary of the hypertexture
 *
 * Reference:
 *   _Advanced RenderMan: Creating CGI for Motion Picture_, 
 *   by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
 *
 ****************************************************************************/



#include "noises.h"
#include "filterwidth.h"
#include "raysphere.h"


float volumedensity (point Pobj;  float radius, noisefreq, stepsize;)
{
    float density = 0.5 + 0.5 * fBm(Pobj*noisefreq, stepsize*noisefreq,
				    3, 2, 0.6);
    /* Fade At Edges Of Sphere */
    density *= 1 - smoothstep (0.8, 1, length(Pobj)/radius);
    return density;
}


color volumecolor (point Pobj; float stepsize)
{
#pragma nolint 2
    return color (0.5 + 0.5*filteredsnoise(Pobj, stepsize), 0.75,
		  0.5 + 0.5*filteredsnoise(Pobj-10, stepsize));
}


float volumeshadow (point Pobj; vector Lobj;
                    float radius, density, noisefreq, stepsize, thresh)
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
    float last_dtau = volumedensity (Pobj, radius, noisefreq, stepsize);
    last_dtau = smoothstep (thresh, thresh+0.01, last_dtau);
    while (d <= end  &&  Oi < 0.999) {
	/* Take a step and get the scattered light and density */
	ss = clamp (ss, 0.005, end-d);
	d += ss;
	float dtau = volumedensity (Pobj + d*Iobj, radius, noisefreq, stepsize);
	dtau = smoothstep (thresh, thresh+0.01, dtau);
	float tau = density * ss/2 * (dtau + last_dtau);
	Oi += (1-Oi) * (1 - exp(-tau));
	last_dtau = dtau;
    }
    return Oi;
}


normal compute_normal (point P; float den, noisefreq, sphererad, stepsize)
{
    float density (point p) {
	extern float noisefreq, sphererad, stepsize;
	return volumedensity (p, sphererad, noisefreq, stepsize);
    }

    normal norm;
    if (length(P) > sphererad - 0.0051)
	norm = normal P;
    else
	norm = normal (density(P + vector (stepsize/10, 0, 0)) - den, 
		       density(P + vector (0, stepsize/10, 0)) - den, 
		       density(P + vector (0, 0, stepsize/10)) - den );
    return normalize(norm);
}


color volumelight (point Pcur, Pobj;
		   vector Icur;
		   float density_here, Kd, Ks;
                   float radius, density, noisefreq, stepsize, thresh)
{
    normal N = compute_normal (Pobj, density_here,
			       noisefreq, radius, stepsize);
    N = faceforward (ntransform ("object", "current", N), Icur);
    N = normalize(N);
    color Lscatter = 0;
    vector V = -normalize(Icur);
    illuminance (Pcur) {
	extern color Cl;
	extern vector L;
	color Cscat = Cl;
	if (density > 0)
	    Cscat *= 1 - volumeshadow (Pobj, vtransform("object",L), radius,
				       density, noisefreq, stepsize, thresh);
	vector LN = normalize(L);
	vector H = normalize (LN + V);
	Lscatter += Kd * Cscat * max (LN . N, 0)
	            + Ks * Cscat * specularbrdf (LN, N, V, 0.1);
    }
    return Lscatter * volumecolor(Pobj, stepsize);
}



surface
hypertexture (float Ka = 0.127, Kd = 1, Ks = 0.3;
	      float radius = 10.0;
	      float opacdensity = 1, lightdensity = 1, shadowdensity = 1;
	      float stepsize = 0.1, shadstepsize = 0.5;
	      float noisefreq = 2.0;
              float thresh = 0.5;)
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
	float last_dtau = volumedensity (Psamp, radius, noisefreq, stepsize);
	color last_li = volumelight (transform ("object", "current", Psamp),
				     Psamp, I, last_dtau, Kd, Ks, 
				     radius, shadowdensity,
				     noisefreq, shadstepsize, thresh);
	/* Sharpen at boundary */
	last_dtau = smoothstep (thresh, thresh+0.01, last_dtau);

	while (d <= end && (comp(Oi,0)<1 || comp(Oi,1)<1 || comp(Oi,2)<1)) {
	    /* Take a step and get the scattered light and density */
	    ss = clamp (ss, 0.005, end-d);
	    d += ss;
	    /* Get the scattered light and density */
	    Psamp = origin + d*Iobj;
	    float dtau = volumedensity (Psamp, radius, noisefreq, stepsize);
	    color li = 0;
	    if (dtau > thresh) 
		li = volumelight (transform ("object", "current", Psamp),
				  Psamp, I, dtau, Kd, Ks, radius, 
				  shadowdensity, noisefreq, shadstepsize,
				  thresh);
	    dtau = smoothstep (thresh, thresh+0.01, dtau);
			       
	    float tau = opacdensity * ss/2 * (dtau + last_dtau);
	    color lighttau = lightdensity * ss/2 * (li*dtau + last_li*last_dtau);
	    float alpha = 1 - exp(-tau);
	    
	    /* Composite with exponential extinction of background light */
	    Ci += (1-Oi) * lighttau * alpha;
	    Oi += (1-Oi) * alpha;
	    last_dtau = dtau;
	    last_li = li;
	}
    }
}
