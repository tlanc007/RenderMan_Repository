/* 
 * Mach Tony Kobayashi contant tile texture.
 * Presented SRT 2001.
 * Renamed for RMR tal@SpamSucks_rendreman.org
 */
surface MTK_tile( string tex = ""; ) {
  float dPdsLength
    = length(vtransform("world", Deriv(P,s)));
  float dPdtLength
    = length(vtransform("world", Deriv(P,t)));

  Oi = 0;
  float startS, startT;
  for (startS = 0; startS < 1; startS += .2) 
  for (startT = 0; startT < 1; startT += .2) {
    float ss = (s - startS) * dPdsLength;
    float tt = (t - startT) * dPdtLength;

    if (ss>0 && ss<1 && tt>0 && tt<1) {
      float tileAlpha = texture(tex[3], ss, tt);
      color tileColor = texture(tex, ss, tt);

      Ci += (1 - Oi) * tileAlpha * tileColor;
      Oi += (1 - Oi) * tileAlpha;
    }
  }
}

