/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.381 */
/* Listing 16.34  Metal shader with optional environment map*/

surface
shiny(
	float	Ka		= .3,
		Ks		= .8,
		roughness	= .05;
	string	mapname = "" )
{
	color ev;
	point D, Nf, NI;

	Nf = faceforward(normalize(N), I);
	NI = normalize(I);

	if( mapname != "" ) {
	    /* compute the environment index direction, D */
	    D = reflect(NI, Nf);
	    /* convert D to environment space. */
	    D = transform("world", point "world" (0,0,0) + D);
	    ev = color environment(mapname, D);
	} else
	    ev = 0;

	Oi = Os;
	Ci = Oi * (Ka * ambient() +
		Ks * (ev + specular(Nf, -NI, roughness)));
}
