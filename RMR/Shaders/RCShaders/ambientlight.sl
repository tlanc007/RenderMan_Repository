/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.338 */
/* Listing 16.5  Ambient light source shader */

/*
 * ambientlight(): non-directional ambient light shader
 */
light
ambientlight(
	float intensity = 1;
	color lightcolor = 1)
{
	Cl = intensity * lightcolor;
}