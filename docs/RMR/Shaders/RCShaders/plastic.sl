/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.337 */
/* Listing 16.4  Surface shader for a plastic appearance */

/*
 *  plastic(): give the appearance of a plastic surface
 */
surface 
RCPlastic( 
	float	Ks			= .5, 
		Kd			= .5, 
		Ka			=  1, 
		roughness		= .1; 
	color	specularcolor		=  1 )
{
	point Nf = faceforward(normalize(N), I );
	point V = normalize(-I);
	
	Oi = Os;
	Ci = Os * ( Cs * (Ka*ambient() + Kd*diffuse(Nf)) + 
	 	specularcolor * Ks * specular(Nf,V,roughness) );
}
