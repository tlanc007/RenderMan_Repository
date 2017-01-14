/****************************************************************************
 * panorama.sl
 *
 * Procedural lens to capture a panorama around the y-axis
 * from a location in world space.
 *
 * This can mimic both cylindrical (spherical = 0.)
 * and spherical (spherical = 1., ymax == ymin)
 * panoramic lenses.
 *
 * To avoid intersecting the scene, the point P is
 * cast from the axis rather than the surface of
 * the cylinder or sphere.
 *
 * The theta angles select a range of angles around
 * the y-axis which span [0, 1] in s.
 *
 * The fovy angles set the "field of view" in the y-direction.
 * For example, a fovylo = -15; fovyhi = 15 sets a centered
 * field-of-view of 30 degrees.
 *
 * When usendc is set, the parametric coordinates are overridden
 * by screen filling normalized device coordinates, allowing
 * any clip-plane object to look through the lens.
 *
 * Reference:
 *   _Advanced RenderMan: Creating CGI for Motion Picture_, 
 *   by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
 *
 ****************************************************************************/


surface
panorama ( float usendc = 0;
	   float spherical = 0;
	   float thetamin = 0.;
	   float thetamax = 360.;
	   float ymin = 0.;
	   float ymax = 10.;
	   float worldx = 0.;
	   float worldz = 0.;
	   float fovylo = 0;
	   float fovyhi = 0;    )
{
    varying float ss = s;
    varying float tt = t;

    if (usendc != 0.0) {
	varying point P2 = transform("NDC", P);
	ss = xcomp(P2);
	tt = 1. - ycomp(P2);
    }
   
    varying float theta = radians(thetamin + ss * (thetamax - thetamin));

    varying float angley;
    if (spherical != 0.0) {
	angley = radians(fovylo + (fovyhi - fovylo) * tt);
    } else {
	uniform float sfovylo = sin(radians(fovylo));
	uniform float sfovyhi = sin(radians(fovyhi));
	varying float sfovyt = sfovylo + (sfovyhi - sfovylo) * tt;
	angley = asin(sfovyt);
    }
    
    varying float sy = sin(angley);
    varying float cy = cos(angley);
    varying vector It = vector "world" ( cos(theta) * cy, sy, sin(theta) * cy);
    varying point Pt = point "world" ( worldx, ymin + tt * (ymax - ymin), worldz);

    Ci = trace(Pt, It);
    Oi = Os;
    Ci *= Oi;
}

