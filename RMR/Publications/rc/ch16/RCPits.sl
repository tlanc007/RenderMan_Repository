/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.375 */
/* Listing 16.30  Displacement shader using a texture for pits and gouges*/

/* 
 *  pits(): use a texture map to apply pits to a surface 
 */
displacement
RCPits( 
	float Km = 0.03; 
	string marks = "" )
{
	float magnitude;
 
	/* Get the displacement, if any, from the texture map. */
	if(marks != "")
	    magnitude = float texture(marks);	/* Use s, t */
	else
	    magnitude = 0;

/* The texture determines the size of the gouge, scaled by Km. */
	P += -Km * magnitude * normalize(N);
	N = calculatenormal(P);
}
