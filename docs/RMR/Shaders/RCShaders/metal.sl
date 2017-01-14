/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.336 */
/* Listing 16.3  Surface shader giving a metallic apperance */

/*
 *  metal(): give a surface a metallic appearance
 */
surface
metal (
	float	Ka		= 1, 
		Ks		= 1, 
		roughness	= .25)
{
	point Nf = faceforward(normalize(N), I);
	point V = normalize(-I);
	
	Oi = Os;
	Ci = Os * Cs * ( Ka*ambient() + Ks*specular(Nf,V,roughness) );
}

