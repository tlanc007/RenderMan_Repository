/* 
 * Example surface shader illustrating Laurent Charbonnel's zero bias shadow
 * technique for SIGGRAPH 2000 RenderMan course.
 *
 * Tal Lancaster 02/05/00
 * tal AT renderman DOT org
 * Walt Disney Feature Animation
 *
 */
surface SIG2k_zerobias (
  float opacity = 1;
  float orientation = 0;
)
{
  uniform color C = color (1, 1, 1);
  normal Nn = normalize (N);
  uniform float val;
  float O;

  val = (orientation == 0)? 1: 0;

  if (Nn . I <= 0) {
    /* point is front facing */
    O = val;
  }
  else {
    /* backfacing */
    O = 1 - val;
  }
  Oi = O;
  Ci = Oi * C;
}
