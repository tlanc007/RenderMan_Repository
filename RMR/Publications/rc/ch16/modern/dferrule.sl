/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.382 */
/* Listing 16.35  Ferrule displacement shader for a pencil*/

/*
 * dferrule(): Deform the cylinder that models the ferrule of a pencil.
 *  The shader adds four ridges that circumscribe the cylinder and  
 *  many more between the innermost ridges that are parallel to 
 *  the cylinder's axis. The ridges are displaced sine waves.
 *  The ferrule is also slightly flared at the eraser end. 
 */
#define UFREQ 219.911
#define VFREQ 104.72
#define R1MIN .17
#define R1MAX .23
#define R2MIN .31
#define R2MAX .37
#define R3MIN .63
#define R3MAX .69
#define R4MIN .77
#define R4MAX .83
displacement
dferrule(
	float	Km = .005 )
{
	float	magnitude = 0;

	/* Compute the distance the surface should be displaced. */
	if (v <= .02)		 /* the eraser-end flair */
		magnitude = 2*(1 - sin(78.54*v));

	if ((v >= R1MIN) && (v <= R1MAX))			/* first circular ridge */
		magnitude = 3*(1 - cos(VFREQ*(v-R1MIN)));
	else if ((v >= R2MIN) && (v <= R2MAX))		/* second circular ridge */
		magnitude = 3*(1 - cos(VFREQ*(v-R2MIN)));
	else if ((v >.37) && (v < .63))	 			/* the longitudinal ridges */
		magnitude = -sin(UFREQ*u) - 1;
	else if ((v >= R3MIN) && (v <= R3MAX))		/* third circular ridge */
		magnitude = 3*(1 - cos(VFREQ*(v-R3MIN)));
	else if ((v >= R4MIN) && (v <= R4MAX))		/* fourth circular ridge */
		magnitude = 3*(1 - cos(VFREQ*(v-R4MIN)));

	/* Now apply the displacement in the direction of the normal. */
	P += Km * magnitude * normalize(N);

	/* Recalculate the normal. */
	N = calculatenormal(P);
}

