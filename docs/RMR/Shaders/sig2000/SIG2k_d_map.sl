/* Simple displacement shader
 *
 * Tal Lancaster  tal AT renderman DOT org
 * 02/25/00
 */

displacement SIG2k_d_map (
  float Km = .1;
  float flipS = 0;
  float flipT = 1;
  string dispMap = "";
)
{
  float mapval;
  float ss, tt;
  point Po;
  normal No;

  ss = (flipS == 0)? s: 1-s;
  tt = (flipT == 0)? t: 1-t;
  
  mapval = (dispMap != "")? float texture (dispMap[0], ss, tt): float 0;

  if (mapval != 0) {
    Po = transform ("object", P);
    No = ntransform ("object", N);
    Po += mapval * Km * No;
    P = transform ("object", "current", Po);
    N = calculatenormal (P);
  }
}
