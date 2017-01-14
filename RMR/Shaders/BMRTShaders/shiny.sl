/*
 * shiny.sl -- Shiny metal surface, using ray tracing.
 *
 * DESCRIPTION:
 *   Makes a smoothly polished metal, using ray tracing to calculate
 *   reflections of the environment.
 * 
 * PARAMETERS:
 *    Ka, Kd, Ks, roughness, specularcolor - The usual meaning
 *    Kr - coefficient for mirror-like reflections of environment
 *    blur - how blurry are the reflections? (0 = perfectly sharp)
 *    samples - set to higher than 1 for oversampling of blur
 *
 * AUTHOR: written by Larry Gritz, 1991
 *
 * HISTORY:
 *      Aug 1991 -- written by lg in C
 *      25 Jan 1994 -- recoded by lg in correct shading language.
 *
 * last modified 25 Jan 1994 by Larry Gritz
 */


surface
shiny ( float Ka = 1, Kd = 0.5, Ks = 1;
	float Kr = 0.5, roughness = 0.05, blur = 0;
	color specularcolor = 1;
	float samples = 1; )
{
    normal Nf;               /* Forward facing normal vector */
    vector IN;               /* normalized incident vector */
    vector uoffset, voffset; /* Offsets for blur */
    color ev;                /* Color of the reflections */
    vector R, Rdir;          /* Direction to cast the ray */
    uniform float i, j;
    
    /* Construct a forward facing surface normal */
    Nf = faceforward (normalize(N), I);
    IN = normalize (I);
    ev = 0;

    /* Calculate the reflection color */
    if (Kr > 0.001) {
	/* Rdir gets the perfect reflection direction */
	Rdir = normalize (reflect (IN, Nf));
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
	    ev *= Kr / (samples*samples);
	} else {
	    /* No blur, just do a simple trace */
	    ev = Kr * trace (P, Rdir);
	}
    }
    
    /* The rest is like the plastic shader */
    Oi = Os;
    Ci = Os * ( Cs * (Ka*ambient() + Kd*diffuse(Nf)) +
		specularcolor * (ev + Ks*specular(Nf,-IN,roughness)));
}
