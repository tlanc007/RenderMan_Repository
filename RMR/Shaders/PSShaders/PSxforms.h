/************************************************************
 * file: xforms.sl
 * author: Peter Stuart
 * date: 10/12/2002
 * $Id: PSxforms.h,v 1.1 2003/03/07 04:01:09 tal Exp $
 * description: Since transformations are usually done by
 * transforming coordinates, and this is really an inverse
 * operation, it tends to be difficult to remember how to do
 * it. These functions should help.
 ************************************************************/

#include "rmannotes.sl"

/* ---- inverse scale the coordinate --------
 * size: new size of [0,1] bound
 * s: texture coordinate
 *
 * The inverse scale applied to texture coordinates
 * is equivalent to applying a scale to the feature
 */
float xscale(float size, s)
{
  return s / size;
}

/* ---- inverse translate the coordinate --------
 * pos: new position of [0,1] bound
 * s: texture coordinate
 *
 * The inverse translate applied to texture coordinates
 * is equivalent to applying a translation to the feature
 */
float xtranslate(float pos, s)
{
  return s - pos;
}

/* rotate2d()
 *
 * 2D rotation of point (x,y) about origin (ox,oy) by an angle rad.
 * The resulting point is (rx, ry).
 *
 */
void xrotate(float s, t, rad; output float ss, tt)
{
  ss = s * cos(rad) - t * sin(rad);
  tt = s * sin(rad) + t * cos(rad);
}

/* ---- inverse transform the coordinate --------
 * size: new size of [0,1] bound
 * pos: new position of [0,1] bound
 * s: texture coordinate
 *
 * The inverse transformation applied to a coordinate
 * scales and then translates a feature
 */
float xform(float size, pos, s)
{
  return xtranslate(-0.5, xscale(size, xtranslate(pos+0.5, s)));
}

/* ---- inverse transform the coordinate with rotation -------
 * s_size, t_size: new size [0,1]
 * s_pos, t_pos: new position [0,1]
 * rad: rotation angle in radians
 * s, t: texture coordinates
 * ss, tt: returned coordinates
 *
 * The inverse transformation applied to a coordinate
 * scales and then translates a feature. Rotation is also applied
 * and returned in ss and tt.
 */
void xform(float s_size, t_size, s_pos, t_pos;
	   float rad, s, t; output float ss, tt;)
{
  float tmps, tmpt;
  tmps = xscale(s_size, xtranslate(s_pos+0.5, s));
  tmpt = xscale(t_size, xtranslate(t_pos+0.5, t));
  xrotate(tmps, tmpt, rad, ss, tt);
  ss = xtranslate(-0.5, ss);
  tt = xtranslate(-0.5, tt);
}

