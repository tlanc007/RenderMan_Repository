/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p.342 */
/* Listing 16.9  Depth-cue volume shader */

/*
 * depthcue (): darken objects according to their depth.  Mindistance and 
 *	maxdistance cover the range between clipping planes.
 */
volume
depthcue (float mindistance = 0, 
		maxdistance = 1;
	color background = 0)
{
  float d;

  d = clamp ((depth(P) - mindistance) / (maxdistance - mindistance), 0, 1);
  Ci = mix (Ci, background, d);
}
