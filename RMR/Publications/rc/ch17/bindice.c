/* $Id: bindice.c,v 1.1.1.1 2002/02/10 02:35:42 tal Exp $  (Pixar - RenderMan Division)  $Date: 2002/02/10 02:35:42 $ */
/*
** Copyright (c) 1998 PIXAR.  All rights reserved.  This program or
** documentation contains proprietary confidential information and trade
** secrets of PIXAR.  Reverse engineering of object code is prohibited.
** Use of copyright notice is precautionary and does not imply publication.
**
**                      RESTRICTED RIGHTS NOTICE
**
** Use, duplication, or disclosure by the Government is subject to the
** following restrictions:  For civilian agencies, subparagraphs (a) through
** (d) of the Commercial Computer Software--Restricted Rights clause at
** 52.227-19 of the FAR; and, for units of the Department of Defense, DoD
** Supplement to the FAR, clause 52.227-7013 (c)(1)(ii), Rights in
** Technical Data and Computer Software.
**
** Pixar
** 1001 West Cutting Blvd.
** Richmond, CA  94804
*/
#include <ri.h>
#include "setup.h"

#define WIDTH    40
#define DEPTH    40

static RtColor Color = { 1.0, 1.0, 1.0 };
static RtPoint From = {0.0, 0.0, 0.0}, To = {1.0, 0.0, 0.5};
static RtFloat
    patch1[48] =
      { 0.001556, 0.111148, 0.000000,
        0.001556, 0.111148, 0.000778, 0.000778, 0.111148, 0.001556,
        0.000000, 0.111148, 0.001556, 0.169012, 0.111148, 0.000000,
        0.169012, 0.111148, 0.084506, 0.084506, 0.111148, 0.169012,
        0.000000, 0.111148, 0.169012, 0.303598, 0.217627, 0.000000,
        0.303598, 0.217627, 0.151799, 0.151799, 0.217627, 0.303598,
        0.000000, 0.217627, 0.303598, 0.303598, 0.371075, 0.000000,
        0.303598, 0.371075, 0.151799, 0.151799, 0.371075, 0.303598,
        0.000000, 0.371075, 0.303598 },
    patch2[48] =
      { 0.000000, 0.111148, 0.001556,
       -0.000778, 0.111148, 0.001556, -0.001556, 0.111148, 0.000778,
       -0.001556, 0.111148, 0.000000, 0.000000, 0.111148, 0.169012,
       -0.084506, 0.111148, 0.169012, -0.169012, 0.111148, 0.084506,
       -0.169012, 0.111148, 0.000000, 0.000000, 0.217627, 0.303598,
       -0.151799, 0.217627, 0.303598, -0.303598, 0.217627, 0.151799,
       -0.303598, 0.217627, 0.000000, 0.000000, 0.371075, 0.303598,
       -0.151799, 0.371075, 0.303598, -0.303598, 0.371075, 0.151799,
       -0.303598, 0.371075, 0.000000 },
    patch3[48] =
      {-0.001556, 0.111148, 0.000000,
       -0.001556, 0.111148, -0.000778, -0.000778, 0.111148, -0.001556,
        0.000000, 0.111148, -0.001556, -0.169012, 0.111148, 0.000000,
       -0.169012, 0.111148, -0.084506, -0.084506, 0.111148, -0.169012,
        0.000000, 0.111148, -0.169012, -0.303598, 0.217627, 0.000000,
       -0.303598, 0.217627, -0.151799, -0.151799, 0.217627, -0.303598,
        0.000000, 0.217627, -0.303598, -0.303598, 0.371075, 0.000000,
       -0.303598, 0.371075, -0.151799, -0.151799, 0.371075, -0.303598,
        0.000000, 0.371075, -0.303598 },
    patch4[48] =
      { 0.000000, 0.111148, -0.001556,
        0.000778, 0.111148, -0.001556, 0.001556, 0.111148, -0.000778,
        0.001556, 0.111148, 0.000000, 0.000000, 0.111148, -0.169012,
        0.084506, 0.111148, -0.169012, 0.169012, 0.111148, -0.084506,
        0.169012, 0.111148, 0.000000, 0.000000, 0.217627, -0.303598,
        0.151799, 0.217627, -0.303598, 0.303598, 0.217627, -0.151799,
        0.303598, 0.217627, 0.000000, 0.000000, 0.371075, -0.303598,
        0.151799, 0.371075, -0.303598, 0.303598, 0.371075, -0.151799,
        0.303598, 0.371075, 0.000000 },
    patch5[48] =
      { 0.303598, 0.371075, 0.000000,
        0.303598, 0.371075, 0.151799, 0.151799, 0.371075, 0.303598,
        0.000000, 0.371075, 0.303598, 0.303598, 0.530778, 0.000000,
        0.303598, 0.530778, 0.151799, 0.151799, 0.530778, 0.303598,
        0.000000, 0.530778, 0.303598, 0.170568, 0.640370, 0.000000,
        0.170568, 0.640370, 0.085284, 0.085284, 0.640370, 0.170568,
        0.000000, 0.640370, 0.170568, 0.000000, 0.640370, 0.000000,
        0.000000, 0.640370, 0.000000, 0.000000, 0.640370, 0.000000,
        0.000000, 0.640370, 0.000000 },
    patch6[48] =
      { 0.000000, 0.371075, 0.303598,
       -0.151799, 0.371075, 0.303598, -0.303598, 0.371075, 0.151799,
       -0.303598, 0.371075, 0.000000, 0.000000, 0.530778, 0.303598,
       -0.151799, 0.530778, 0.303598, -0.303598, 0.530778, 0.151799,
       -0.303598, 0.530778, 0.000000, 0.000000, 0.640370, 0.170568,
       -0.085284, 0.640370, 0.170568, -0.170568, 0.640370, 0.085284,
       -0.170568, 0.640370, 0.000000, 0.000000, 0.640370, 0.000000,
        0.000000, 0.640370, 0.000000, 0.000000, 0.640370, 0.000000,
        0.000000, 0.640370, 0.000000 },
    patch7[48] =
      {-0.303598, 0.371075, 0.000000,
       -0.303598, 0.371075, -0.151799, -0.151799, 0.371075, -0.303598,
        0.000000, 0.371075, -0.303598, -0.303598, 0.530778, 0.000000,
       -0.303598, 0.530778, -0.151799, -0.151799, 0.530778, -0.303598,
        0.000000, 0.530778, -0.303598, -0.170568, 0.640370, 0.000000,
       -0.170568, 0.640370, -0.085284, -0.085284, 0.640370, -0.170568,
        0.000000, 0.640370, -0.170568, 0.000000, 0.640370, 0.000000,
        0.000000, 0.640370, 0.000000, 0.000000, 0.640370, 0.000000,
        0.000000, 0.640370, 0.000000 },
    patch8[48] =
      { 0.000000, 0.371075, -0.303598,
        0.151799, 0.371075, -0.303598, 0.303598, 0.371075, -0.151799,
        0.303598, 0.371075, 0.000000, 0.000000, 0.530778, -0.303598,
        0.151799, 0.530778, -0.303598, 0.303598, 0.530778, -0.151799,
        0.303598, 0.530778, 0.000000, 0.000000, 0.640370, -0.170568,
        0.085284, 0.640370, -0.170568, 0.170568, 0.640370, -0.085284,
        0.170568, 0.640370, 0.000000, 0.000000, 0.640370, 0.000000,
        0.000000, 0.640370, 0.000000, 0.000000, 0.640370, 0.000000,
        0.000000, 0.640370, 0.000000 };

int
main(void)
{
    static RtInt  bucketsize[2] = {12, 12};
    RtInt  jitterflag = 0, gridsize = 32;
    RtFloat intensity = 0.1;

    RiBegin(RI_NULL);        /* Start the renderer */
        /* Rendering options */
    	RiOption("limits", "gridsize", (RtPointer)&gridsize, "bucketsize",
            (RtPointer)bucketsize, RI_NULL);
    	RiHider("hidden", "jitter", (RtPointer)&jitterflag, RI_NULL);
    	RiPixelSamples(1.0, 1.0);
    	RiClipping(.2, 400.0);
	RiDisplay("RenderMan", RI_FRAMEBUFFER, "rgb", RI_NULL);
	RiFormat((RtInt) 512, (RtInt) 384, -1.0);
	RiPixelFilter(RiBoxFilter, 1.0, 1.0);
	RiProjection("perspective", RI_NULL);
	RiShadingRate(4.0);
        SpecialSetup();
        RiTranslate(0.0, 0.0, 2.0);
        RiScale(2.0, 2.0, 2.0);
        RiLightSource("ambientlight", "intensity",
                    (RtPointer)&intensity, RI_NULL);
        RiLightSource("distantlight", "from", (RtPointer)From,
                        "to", (RtPointer)To, RI_NULL);
        RiWorldBegin();
            RiSurface("matte", RI_NULL);
            RiColor(Color);        /* Declare the color */
            RiPatch("bicubic", "P", (RtPointer)patch1, RI_NULL);
            RiPatch("bicubic", "P", (RtPointer)patch2, RI_NULL);
            RiPatch("bicubic", "P", (RtPointer)patch3, RI_NULL);
            RiPatch("bicubic", "P", (RtPointer)patch4, RI_NULL);
            RiPatch("bicubic", "P", (RtPointer)patch5, RI_NULL);
            RiPatch("bicubic", "P", (RtPointer)patch6, RI_NULL);
            RiPatch("bicubic", "P", (RtPointer)patch7, RI_NULL);
            RiPatch("bicubic", "P", (RtPointer)patch8, RI_NULL);
        RiWorldEnd();
    RiEnd();            /* Clean up after the renderer */

    return 0;
}
