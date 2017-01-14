/* I took wave's lead and renamed starfield to KMWindywave.sl -- tal AT renderman DOT org */

/*
 * windywave.sl -- displacement shader for water waves modulated by a
 *                 wind field.
 *
 * DESCRIPTION:
 *    Two octaves of noise make waves appropriate for a lake or other large
 *    body of water.  This displacement is modulated by another turbulent
 *    term which accounts for wind variations across the lake.
 *
 * PARAMETERS:
 *    Km - overall amplitude scale for the waves
 *    txtscale - overall frequency scaling for the waves
 *    windfreq - lowest frequency of the wind variations
 *    windamp - amplitude of the wind variation
 *    minwind - minimum wind value
 *
 * ANTIALIASING:
 *    None.
 *
 * AUTHOR:
 *    C language version by F. Kenton Musgrave
 *    Translation to Shading Language by Larry Gritz.
 *
 * REFERENCES:
 *    _Texturing and Modeling: A Procedural Approach_, by David S. Ebert, ed.,
 *    F. Kenton Musgrave, Darwyn Peachey, Ken Perlin, and Steven Worley.
 *    Academic Press, 1994.  ISBN 0-12-228760-6.
 *
 * HISTORY:
 *    ??? - original C language version by Ken Musgrave
 *    Apr 94 - translation to Shading Language by L. Gritz
 *
 * this file last updated 18 Apr 1994
 */


#define snoise(Pt) (2*noise(Pt) - 1)



displacement
KMWindywave (float Km = 0.1;
	   float txtscale = 1;
	   float windfreq = 0.5;
	   float windamp = 1;
	   float minwind = 0.3)
{
  float offset;
  point PP;
  float wind;
  float turb, a, i;

  PP = txtscale * windfreq * transform ("shader", P);

  offset = Km * (snoise(PP) + 0.5 * snoise(2*PP));

  turb = 0;  a = 1;  PP *= 8;
  for (i = 0;  i < 4;  i += 1) {
      turb += abs (a * snoise(PP));
      PP *= 2;
      a /= 2;
    }
  wind = minwind + windamp * turb;

/*  P += wind * offset * normalize(N); */
  N = calculatenormal (P+wind * offset * normalize(N));
}
