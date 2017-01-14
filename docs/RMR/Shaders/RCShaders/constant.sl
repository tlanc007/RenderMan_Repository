/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.334 */
/* Listing 16.1  Constant-color surface shader */

/*
 * constant(): surface shader giving a constant color
 */
surface constant ()
{
	Oi = Os;
	Ci = Os * Cs;
}
