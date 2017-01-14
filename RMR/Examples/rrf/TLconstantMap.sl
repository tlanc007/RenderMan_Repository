/* 
 * Takes either a color or a map to give a surface a flat color
 * (pure ambient / no lighting)
 *
 * Tal Lancaster  for RenderMan Repository
 *
 */

surface TLconstantMap (
  float Km = 1;
  string mapname = "";   /* type texture */
  string transmap = "";  /* type texture */
  float flipS = 0;       /* type switch */
  float flipT = 1;       /* type switch */
  float MtorFlip = 1;    /* type switch */
)  
{
    color C;
    color O;

    float ss;
    float tt;

    if (MtorFlip == 1) {
	ss = t;
	tt = s;
    }
    else {
	ss = s;
	tt = t;
    }
    if (flipS == 1)
	ss = 1 - ss;
    if (flipT == 1)
	tt = 1 - tt;
       
    C = (mapname != "")? color texture (mapname, ss, tt): Cs;

    C *= Km;
    O = (transmap != "")? 1 - color texture (transmap, ss, tt): Os;


    Ci = C * O;
    Oi = O;
    Ci = clamp (Ci, color 0, color 1);
    Oi = clamp (Oi, color 0, color 1);

}
