/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.335 */
/* Listing 16.2  Matte surface shader */

/*
 *  matte(): simple diffusely-reflecting surface
 */
surface
matte(
	float	Ka	= 1, 
		Kd	= 1 )
{
	normal Nf = faceforward(normalize(N),I);

	Oi = Os;
	Ci = Os * Cs * ( Ka*ambient() + Kd*diffuse(Nf) ) ;
}
