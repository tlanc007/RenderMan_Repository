/***************************************************************************
 * emboss.sl
 *
 * Description:
 *    Emboss (indent) a surface based on a texture map.
 *
 * Parameters:
 *   Km - overall scaling of the displacment.
 *   texturename - the name of the texture file.
 *   dispspace - the name of the coordinate system against which the
 *         displacement amounts are measured.
 *                projected point before texture coordinates are extracted.
 *   truedisp - 1 for true displacement, 0 for bump mapping
 *   sstart, tstart - parameteric (s,t) corner of the texture's position
 *         on the surface.
 *   sscale, tscale - scaling (size) factor for the texture placement.
 *
 * Author: Larry Gritz (lg AT larrygritz DOT com)
 *
 * Reference:
 *   _Advanced RenderMan: Creating CGI for Motion Picture_, 
 *   by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
 *
 ***************************************************************************/


#include "displace.h"


displacement
emboss (string texturename = "";        /* Name of image */
        float  Km          = 1;         /* Max displacement amt */
        string dispspace   = "shader";  /* Space to measure in */
	float  truedisp    = 1;         /* Displace or just bump? */
        float  sstart = 0, sscale = 1;
        float  tstart = 0, tscale = 1;
        float  blur = 0; )
{
    /* Only displace if a filename is provided */
    if (texturename != "") {
        /* Simple scaled and offset s-t mapping */
        float ss = (s - sstart) / sscale;
        float tt = (t - tstart) / tscale;
        /* Amplitude is channel 0 of the texture, indexed by s,t. */
        float amp = float texture (texturename[0], ss, tt, "blur", blur);
        /* Displace inward parallel to the surface normal, 
         * Km*amp units measured in dispspace coordinates.
         */
        N = Displace (normalize(N), dispspace, -Km*amp, truedisp);
    }
}

