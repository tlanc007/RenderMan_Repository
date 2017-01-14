/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.352 */
/* Listing 16.16  Displacement shader to dent a surface */

/*
 * dented(): Create a worn surface.
 */
displacement
dented (
	float Km = 1.0)
{
	float size = 1.0,
	      magnitude = 0.0,
		  i;
	point P2;
	
	P2 = transform ("shader", P);
	for (i = 0; i < 6.0; i += 1.0) {
		/* Calculate a simple fractal 1/f noise function */
		magnitude += abs (.5 - noise (P2 * size)) / size;
		size *= 2.0;
	}
	P2 = P - normalize (N) * (magnitude * magnitude * magnitude)* Km;
	N = calculatenormal(P2);
}

