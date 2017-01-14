/***************************************************************************
 * simpletexmap.sl
 *
 * Description:
 *   Simple surface shader, like paintedplastic, but with extra controls
 *   to position and scale the map on the surface.
 *
 * Parameters:
 *   Ka, Kd, Ks, roughness, specularcolor - params for a very simple
 *       plastic-like reflection model.
 *   texturename - the name of the texture to map, or "" for no texture.
 *   sstart, tstart - parameteric (s,t) corner of the texture's position
 *       on the surface.
 *   sscale, tscale - scaling (size) factor for the texture placement.
 *
 * Reference:
 *   _Advanced RenderMan: Creating CGI for Motion Picture_, 
 *   by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
 ***************************************************************************/



surface
simpletexmap ( float Ka=1, Kd=1, Ks=0.5;
               float roughness = 0.1;
               color specularcolor = 1;
               string texturename = "";
               float sstart = 0, sscale = 1;
               float tstart = 0, tscale = 1; )
{
    /* Simple scaled and offset s-t mapping */
    float ss = (s - sstart) / sscale;
    float tt = (t - tstart) / tscale;

    /* Look up texture if a filename was given, otherwise use the
     * default surface color.
     */
    color Ct;
    if (texturename != "") {
        float opac = float texture (texturename[3], ss, tt);
        Ct = color texture (texturename, ss, tt) + (1-opac)*Cs;
    }
    else Ct = Cs;

    /* Simple plastic-like reflection model */
    normal Nf = faceforward(normalize(N),I);
    vector V = -normalize(I);
    Ci = Ct * (Ka*ambient() + Kd*diffuse(Nf))
         + Ks*specularcolor*specular(Nf,V,roughness);
    Oi = Os;  Ci *= Oi;
} 
