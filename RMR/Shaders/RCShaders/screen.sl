/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.349 */
/* Listing 16.14  Shader outlining an object with metallic wire mesh */

/*
 * screen(): surface shader for giving "wireframe" appearance.  The method
 * is to render the surface opaque within a small distance of a grid in
 * s,t space.  The grid is derived from a modulus function.
 *
 */
 
surface
screen (float Ks = 0.5,
              Kd = 0.5, 
			  Ka = .1, 
			  roughness = 0.1,
              density = 0.25, 
			  frequency = 20;
        color specularcolor = color (1, 1, 1))
{
	varying point Nf = faceforward(normalize (N), I);
	point V = normalize(-I);
	
	if (mod (s * frequency, 1) < density || mod (t * frequency, 1) < density)
		Oi = 1.0;
	else
		Oi = 0.0;

	Ci = Oi * (Cs * (Ka * ambient() + Kd * diffuse(Nf) ) +
	 specularcolor* Ks * specular(Nf, V, roughness));
}
