/* I took wave's lead and renamed starfield to LGStarfield.sl -- tal@SpamSucks_cs.caltech.edu */

/*  
 * LGStarfield.sl -- Surface shader for a star field.
 *
 * DESCRIPTION:
 *   Makes a star field.  Best when used as a surface shader for the inside
 *   of a large sphere.
 * 
 * PARAMETERS:
 *   frequency          frequency of the stars
 *   intensity          how bright are the stars?
 *   pswidth            how wide is the point spread function?  i.e. larger
 *                      values make "wider" stars, but the look less round.
 *
 * AUTHOR: written by Larry Gritz, 1992
 *
 * HISTORY:
 *      28 Dec 1992 -- written by lg for the "Timbre Trees" video (saucer)
 *      12 Jan 1994 -- recoded by lg in correct shading language.
 *
 * last modified  12 Jan 1994 by Larry Gritz
 */



surface
LGStarfield ( float intensity = 1;
	    float frequency = 1;
	    float pswidth = 0.01)
{
  point PP;
  float val;

  /* Shade in shader space */
  PP = frequency * transform ("shader", P);

  /* Use a noise value, but only keep the "tips" of the blotches */
  val = smoothstep (1-pswidth, 1, noise(PP));

  /* scale it by the intensity and sharpen it by squaring */
  Ci = intensity * val*val;
}
