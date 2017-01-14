/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.337 */
/* Listing 16.4  Surface shader for a plastic appearance */

/*
 *  plastic(): give the appearance of a plastic surface
 */
surface 
plastic ( 
	float	Ks			= .5, 
		Kd			= .5, 
		Ka			=  1, 
		roughness		= .1; 
	color	specularcolor		=  1 )
{
	normal Nf = faceforward(normalize(N), I );
	vector V = normalize(-I);
	
	Oi = Os;
	Ci = Os * ( Cs * (Ka*ambient() + Kd*diffuse(Nf)) + 
	 	specularcolor * Ks * specular(Nf,V,roughness) );
}
