/*
 *----- fjs_fisheyelens.sl
 *
 * Description:
 *   A near clip-plane shader that uses raytracing to provide
 *   a simple fisheye lens for the camera.
 *
 * Usage:
 *   User must define a square polygon just beyond the
 *   near clip-plane distance. Generally, this polygon
 *   fills the entire viewing frustrum.
 *
 *   This shader is applied to the polygon and the user
 *   should specify the polygon placement and the maximum
 *   angle of the lens.
 *
 *   The result is a circular lensed image on the square
 *   polygon, with black corners. The angular distribution
 *   is like polar graph paper, with angle increasing
 *   linearly with distance from the center.
 *
 *   Corners of polygon are assumed to be (in camera space):
 *     [ scale,  scale, zdistance]
 *     [-scale,  scale, zdistance]
 *     [-scale, -scale, zdistance]
 *     [ scale, -scale, zdistance]
 *
 *   RIB example:
 *     Clipping 0.099 1000.0
 *     Declare "lens_angle" "uniform float"
 *     Declare "zdistance" "uniform float"
 *     Declare "scale" "uniform float"
 *     Surface "fjs_fisheyelens" "lens_angle" [180] "zdistance" [0.1] "scale" [0.1]
 *     Polygon "P" [0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1]
 *
 * History:
 *   12/17/01 - 1.0 - Cleaned up and documented - Frank Summers,
 *                    summers@SpamSucks_stsci.edu
 *
 */
surface fjs_fisheyelens (float lens_angle = 180.0;
                         float zdistance = 0.1;
                         float scale = 0.1)
{

/* Do not shade near clip-plane polygon more than once
 *
 *   The code below will begin the fisheye raytrace from the
 *   camera. The near clip-plane polygon will then be hit a
 *   second time by those rays.  Checking raylevel ensures
 *   that only rays originally from the camera will be shaded.
 */

  if (raylevel() > 0) {

    Oi = 0.0;
    Ci = color(0,0,0);

/* Otherwise, shade with fisheyelens */

  } else {

/* Transform the point being shaded into camera coordinates */

    varying point Pcam = transform("camera", P);

/* Generate coordinates relative to the center of the polygon */

    varying float ss = 0.5*xcomp(Pcam)/scale;
    varying float tt = 0.5*ycomp(Pcam)/scale;

/* Calculate distance from center of the polygon */

    varying float r = sqrt(ss*ss + tt*tt);

/* If point is outside of polygon filling circle, paint it opaque and black */

    if (r > 0.5) {
      Oi = 1.0;
      Ci = color(0,0,0);

/* Otherwise, calculate ray to trace */

    } else {

/* Angle increases linearly with distance from center */

      varying float polar_angle = radians(lens_angle)*r;

/* Direction is calculated from angle and shade point coordinates */

      varying float z = cos(polar_angle);

      varying float x = sin(polar_angle)*ss/r;
      varying float y = sin(polar_angle)*tt/r;

/* Set trace direction and start point (at camera) */

      varying vector tracedir = vector "camera" (x, y, z);
      varying point startpoint = point "camera" (0, 0, 0);
 
/* Call trace function to perform the raytrace */

      Oi = 1.0;
      Ci = trace(startpoint, tracedir);

    }
  }
}
