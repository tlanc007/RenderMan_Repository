/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.338 */
/* Listing 16.6  Distant light source shader */

/*
 * distantlight(): provide the behavior of a quasi-solar light source
 */
light
distantlight ( float intensity = 1;
	       color lightcolor = 1;
	       point from = point "camera" (0,0,0);
	       point to = point "camera" (0,0,1); )
{
  solar (to - from, 0.0)
      Cl = intensity * lightcolor;
}
