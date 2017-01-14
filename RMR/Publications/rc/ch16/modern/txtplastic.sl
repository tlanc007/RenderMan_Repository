/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.374 */
/* Listing 16.29  Plastic surface shader using a texture map*/

/* 
 *  txtplastic(): version of plastic() shader using an optional texture map
 */
surface 
txtplastic( 
	float	Ks		= .5, 
		Kd		= .5, 
		Ka		=  1, 
		roughness	= .1;
	color 	specularcolor = 1;
	string	mapname = "")
{
	normal Nf = faceforward( normalize (N), I );
	vector V = normalize (-I);

	if( mapname != "" )
		Ci = color texture( mapname );						/* Use s and t */
	else
		Ci = Cs;
	Oi = Os;
	Ci = Os * ( Ci * 
		    (Ka*ambient() + Kd*diffuse(Nf)) 
	 	+ specularcolor * Ks * specular(Nf, V,roughness) );
}

