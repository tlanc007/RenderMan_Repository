/**************************************************************************
 * patterns.h - various "helper" routines for making patterns
 *
 * $Revision: 1.1.1.1 $    $Date: 2002/02/10 02:35:49 $
 *
 **************************************************************************/




/* A 1-D pulse pattern:  return 1 if edge0 <= x <= edge1, otherwise 0 */
float pulse (float edge0, edge1, x)
{
    return step(edge0,x) - step(edge1,x);
}


/* A filtered version of pulse:  this is just an analytic solution to
 * the convolution of pulse, above, with a box filter of a particular
 * width.  Derivation is left to the reader.
 */
float filteredpulse (float edge0, edge1, x, width)
{
    float x0 = x - width*0.5;
    float x1 = x0 + width;
    return max (0, (min(x1,edge1)-max(x0,edge0)) / width);
}




/* basic tiling pattern --
 *   inputs:
 *      x, y                    positions on a 2-D surface
 *      tilewidth, tileheight   dimensions of each tile
 *      rowstagger              how much does each row stagger relative to
 *                                   the previous row
 *      rowstaggervary          how much should rowstagger randomly vary
 *      jaggedfreq, jaggedamp   adds noise to the edge between the tiles
 *   outputs:
 *      row, column             index which tile the sample is in
 *      xtile, ytile            position within this tile (0-1)
 */
void basictile (float x, y;
		uniform float tilewidth, tileheight;
		uniform float rowstagger, rowstaggervary;
		uniform float jaggedfreq, jaggedamp;
		output float column, row;
		output float xtile, ytile;
    )
{
    point PP;
    float scoord = x, tcoord = y;

    if (jaggedamp != 0.0) {
	/* Make the shapes of the bricks vary just a bit */
	PP = point noise (x*jaggedfreq/tilewidth, y*jaggedfreq/tileheight);
	scoord += jaggedamp * xcomp (PP);
	tcoord += jaggedamp * ycomp (PP);
    }

    xtile = scoord / tilewidth;
    ytile = tcoord / tileheight;
    row = floor (ytile);   /* which brick row? */

    /* Shift the columns randomly by row */
    xtile += mod (rowstagger * row, 1);
    xtile += rowstaggervary * (noise (row+0.5) - 0.5);

    column = floor (xtile);
    xtile -= column;
    ytile -= row;
}


