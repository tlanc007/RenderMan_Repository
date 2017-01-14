/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.339 */
/* Listing 16.7  Distant light source shader */

/*
 * pointlight(): provide a ligh with position but no orientation
 */
light
pointlight ( float intensity = 1;
	       color lightcolor = 1;
	       point from = point "camera" (0,0,0) ) /* light position */
{
  illuminate (from)
      Cl = intensity * lightcolor / (L . L);
}
