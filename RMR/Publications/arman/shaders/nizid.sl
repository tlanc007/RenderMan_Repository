/****************************************************************************
 * nizid : General purpose pre-render shader for cartoon rendering.
 *
 *   red   -- ni (Normal dotted with I for silhouette detection.)
 *   green -- z (Depth for silhouette detection and edge classification.)
 *   blue  -- id (Unique region id for feature edge detection.)
 *
 * Uses two region ids. (front, back)
 *
 * Reference:
 *   _Advanced RenderMan: Creating CGI for Motion Picture_, 
 *   by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
 *
 ****************************************************************************/

surface
nizid ( float near = 0.;
	float far = 1.;
	float region_id = 1.;    /* Starting id number for surface. */
	float region_one = 255.; /* Set to 65535 during 16-bpp renders. */
    )
{
    varying float ni;
    varying float zee;
    varying float id;

    ni = N.I;
    ni = (ni * ni)/(N.N * I.I);
    ni = 1. - sqrt(ni);

    zee = 1. - clamp((depth(P) - near)/(far - near), 0., 1.); 

    if (faceforward(N,I) . N >= 0.0) { /* Give front/back different id's */
	id = region_id;
    } else {
	id = region_id + 1.;
    }

    Ci = color "rgb" (ni, zee, id/region_one);
    Oi = 1.0;
}
