/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.342 */
/* Listing 16.10  Fog volume shader */

/*
 *  fog(): introduce depth-based fog
 */
volume
fog ( 
	float	distance	= 1; 
	color	background	= 0 )
{
	float d = 1 - exp( -length(I)/distance );
	Ci = mix( Ci, background, d );
}

