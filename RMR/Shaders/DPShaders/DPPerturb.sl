/* I took wave's lead and renamed perturb to DPPerturb.sl -- tal AT renderman DOT org */

/* 
 * perturb.sl
 *
 * AUTHOR: Darwyn Peachy
 *
 * REFERENCES:
 *    _Texturing and Modeling: A Procedural Approach_, by David S. Ebert, ed.,
 *    F. Kenton Musgrave, Darwyn Peachey, Ken Perlin, and Steven Worley.
 *    Academic Press, 1994.  ISBN 0-12-228760-6.
 *
 * HISTORY:
 *   Sep 29 1995 -- Tal Lancaster
 *      Made example slightly more general by adding the txtFile param.	
 *
 */
 

#include "DPProctext.h"

surface
DPPerturb (string txtFile = "")
{
    point Psh;
    float ss, tt;

	if (txtFile == "")
		/* Nothing to do */
		Ci = Cs;
	else {
    Psh = transform("shader", P) * 0.2;
    ss = s + 0.1 * snoise(Psh);
    tt = t + 0.05 * snoise(Psh+(1.5,6.7,3.4));
    Ci = texture(txtFile, ss, tt);
	}
}
