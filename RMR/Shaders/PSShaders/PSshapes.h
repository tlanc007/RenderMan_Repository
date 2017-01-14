/************************************************************
 * file: shapes.sl
 * author: Peter Stuart
 * date: 10/12/2002
 * $Id: PSshapes.h,v 1.1 2003/03/07 04:01:09 tal Exp $
 * description: This file holds some functions to ease shape
 * drawing.
 ************************************************************/

#include "rmannotes.sl"

/* ---- calculate area of triangle ---------
 * p1, p2, p3: vertices of triangle
 * returns area
 *
 * The area is easily calculated by taking the half the cross
 * product of two adjacent vectors of the triangle
 */ 
float tri_area(point p1, p2, p3;)
{
  return length(vector((p2 - p1) ^ (p3 - p1))) / 2;
}

/* ---- calculate barycentric coordinates of triangle ------
 * p1, p2, p3: vertices of triangle
 * pt: point being evaluated
 * fuzz: amount of blurriness
 *
 * This function uses barycentric coordinates to calculate distance
 * to the triangle. It turns out this is not the best interpolation
 * scheme, but it seems to work all right.
 */
float bary_triangle(uniform point p1, p2, p3;
		    float fuzz; point pt)
{
  uniform float area = tri_area(p1, p2, p3);

  float area1, area2, area3;
  area1 = tri_area(pt, p2, p3)/area;
  area2 = tri_area(p1, pt, p3)/area;
  area3 = tri_area(p1, p2, pt)/area;

  return 1 - smoothstep(0, fuzz, area1+area2+area3-1);
}

/* ---- draw rectangle -------
 * left, right, top, bot: rectangle extents
 * s, t: texture coordinates
 */
float draw_rect(float left, right, top, bot, fuzz; float s, t)
{
  return intersection(pulse(left, right, fuzz, s), pulse(top, bot, fuzz, t));

}

/* ---- draw a line -------
 * p1, p2: line end points
 * fuzzz: blurriness
 * half_width: half of the line width
 * s, t: texture coordinates
 */
float draw_line(point p1, p2; float fuzz, half_width, s, t;)
{
  float d = ptlined(p1, p2, point(s,t,0));
  return 1 - smoothstep(half_width - fuzz, half_width, d);
}

/* ---- draw a circle ------
 * center: center point
 * radius: radius of circle
 * fuzz: blurriness
 * s, t: texture coordinates
 */
float draw_circle(point center; float radius, fuzz; float s, t;)
{
  float d = distance(center, point(s,t,0));
  return 1 - smoothstep(radius - fuzz, radius, d);
}

/* ---- draw a cone ------
 * center: center point
 * rad1, rad2: radii of the top and bottom of cone
 * fuzz: blurriness
 * s, t: texture coordinates
 */
float draw_cone(point center; float rad1, rad2, fuzz; float s, t;)
{
  float d = distance(center, point(s,t,0));
  return 1-smoothstep(fuzz, 1-fuzz, (d-rad2)/(rad1-rad2));
}

