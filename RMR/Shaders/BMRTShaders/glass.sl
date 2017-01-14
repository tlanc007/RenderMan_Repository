#ifdef RCSIDS
static char rcsid[] = "$Id: glass.sl,v 1.1.1.1 2002/02/10 02:35:49 tal Exp $";
#endif

/*
 * glass.sl -- Shiny reflective & refractive glass, using ray tracing.
 *
 * DESCRIPTION:
 *   Makes semi-transparent glass, using ray tracing to calculate
 *   reflections and refractions of the environment.
 * 
 * PARAMETERS:
 *    Ka, Kd, Ks, roughness, specularcolor - The usual meaning
 *    Kr - coefficient for mirror-like reflections of environment
 *    Kt - coefficient for refracted transmission
 *    transmitcolor - color of the glass
 *    eta - the coefficient of refraction of the glass
 *    blur - how blurry are the reflections/refractions? (0 = perfectly sharp)
 *    samples - set to higher than 1 for oversampling of blur
 *
 * AUTHOR: written by Larry Gritz, 1991
 *
 * HISTORY:
 *
 * $Revision: 1.1.1.1 $      $Date: 2002/02/10 02:35:49 $
 *
 * $Log: glass.sl,v $
 * Revision 1.1.1.1  2002/02/10 02:35:49  tal
 * RenderMan Repository
 *
 * Revision 1.4.2.2  1998-02-06 14:02:30-08  lg
 * Converted to "modern" SL with appropriate use of vector & normal types
 *
 * Revision 1.4.2.1  1998-01-05 21:05:56-08  lg
 * Improvement to stratify solid angle ray sampling
 *
 * Revision 1.4  1996-03-11 19:04:51-08  lg
 * Don't use Os -- we just want to set the color from the rays
 *
 * Revision 1.3  1996-02-29 10:11:23-08  lg
 * Minor correction and dead code removal
 *
 * Revision 1.2  1996-02-12 17:34:53-08  lg
 * Fixed use of fresnel, chose better default parameters
 *
 * Revision 1.1  1995-12-05 15:05:47-08  lg
 * Initial RCS-protected revision
 *
 * 25 Jan 1994 -- recoded by lg in correct shading language.
 * Aug 1991 -- written by lg in C
 *
 */




surface
glass ( float Ka = 0.2, Kd = 0, Ks = 0.5;
	float Kr = 1, Kt = 1, roughness = 0.05, blur = 0, eta = 1.5;
	color specularcolor = 1, transmitcolor = 1;
	float samples = 1; )
{
    normal Nf;               /* Forward facing normal vector */
    vector IN;               /* normalized incident vector */
    vector Rfldir, Rfrdir;   /* Smooth reflection/refraction directions */
    vector uoffset, voffset; /* Offsets for blur */
    color ev = 0;            /* Color of the environment reflections */
    color cr = 0;            /* Color of the refractions */
    vector R, Rdir;          /* Direction to cast the ray */
    uniform float i, j;
    float kr, kt;

    /* Construct a normalized incident vector */
    IN = normalize (I);

    /* Construct a forward facing surface normal */
    Nf = faceforward (normalize(N), I);

    /* Compute the reflection & refraction directions and amounts */
    fresnel (IN, Nf, (I.N < 0) ? 1.0/eta : eta, kr, kt, Rfldir, Rfrdir);
    kr *= Kr;
    kt *= Kt;

    /* Calculate the reflection color */
    if (kr > 0.001) {
	/* Rdir gets the perfect reflection direction */
	Rdir = normalize (Rfldir);
	if (blur > 0) {
	    /* Construct orthogonal components to Rdir */
	    uoffset = blur * normalize (vector (zcomp(Rdir) - ycomp(Rdir),
						xcomp(Rdir) - zcomp(Rdir),
						ycomp(Rdir) - xcomp(Rdir)));
	    voffset = Rdir ^ uoffset;
	    for (i = 0;  i < samples;  i += 1) {
		for (j = 0;  j < samples;  j += 1) {
		    /* Add a random offset to the smooth reflection vector */
		    R = Rdir +
			((i + float random())/samples - 0.5) * uoffset +
			((j + float random())/samples - 0.5) * voffset;
		    ev += trace (P, normalize(R));
		}
	    }
	    ev *= kr / (samples*samples);
	} else {
	    /* No blur, just do a simple trace */
	    ev = kr * trace (P, Rdir);
	}
    }

    /* Calculate the refraction color */
    if (kt > 0.001) {
	/* Rdir gets the perfect refraction direction */
	Rdir = normalize (Rfrdir);
	if (blur > 0) {
	    /* Construct orthogonal components to Rdir */
	    uoffset = blur * normalize (vector(zcomp(Rfrdir) - ycomp(Rfrdir),
					       xcomp(Rfrdir) - zcomp(Rfrdir),
					       ycomp(Rfrdir) - xcomp(Rfrdir)));
	    voffset = Rfrdir ^ uoffset;
	    for (i = 0;  i < samples;  i += 1) {
		for (j = 0;  j < samples;  j += 1) {
		    /* Add a random offset to the smooth reflection vector */
		    R = Rdir +
			((i + float random())/samples - 0.5) * uoffset +
			((j + float random())/samples - 0.5) * voffset;
		    cr += trace (P, R);
		}
	    }
	    cr *= kt / (samples*samples);
	} else {
	    /* No blur, just do a simple trace */
	    cr = kt * trace (P, Rdir);
	}
    }

    Oi = 1;
    Ci = ( Cs * (Ka*ambient() + Kd*diffuse(Nf)) +
	   specularcolor * (ev + Ks*specular(Nf,-IN,roughness)) +
	   transmitcolor * cr );
}
