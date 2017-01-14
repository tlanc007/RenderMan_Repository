/* $Id: jitter.c,v 1.1.1.1 2002/02/10 02:35:42 tal Exp $  (Pixar - RenderMan Division)  $Date: 2002/02/10 02:35:42 $ */
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

#define WIDTH    10
#define DEPTH    100

static RtColor Color = { 1, 0, 0 };
static RtPoint From = {0.0, 0.0, 0.0}, To = {0.0, -1.0, 0.0};
static RtFloat patch[12] = {0.0, 0.0, 0.0,  2.0, 0.0, 0.0,
                            0.0, 0.0, 2.0,  2.0, 0.0, 2.0};
int
main(void)
{
    int i, j;

    RiBegin(RI_NULL);        /* Start the renderer */
	RiProjection("perspective", RI_NULL);
	RiDisplay("RenderMan", RI_FRAMEBUFFER, "rgb", RI_NULL);
	RiFormat((RtInt) 256, (RtInt) 192, -1.0);
	RiShadingRate(4.0);
	RiPixelFilter(RiBoxFilter, 1.0, 1.0);
	RiScreenWindow(-0.2,  0.7, -0.5, 0.1);
	RiFrameAspectRatio(256.0/192.0);
        SpecialSetup();
        RiTranslate(0.0, -1.0, 2.5);
        RiRotate(5.0, -1.0, 0.0, 0.0);
        RiScale(0.05, 0.05, 0.05);
        RiLightSource("distantlight", "from", (RtPointer)From,
                      "to", (RtPointer)To, RI_NULL);
        RiWorldBegin();
            RiSurface("matte", RI_NULL);
            RiColor(Color);        /* Declare the color */
            RiTranslate(-0.5*WIDTH, 0.0, 0.0);
            for (j=0; j<DEPTH; j++) {
                for (i=0; i<WIDTH; i++) {
                RiTranslate(2.0, 0.0, 0.0);
                if ((i+j)%2 == 0)
                    RiPatch("bilinear",
                    "P", (RtPointer)patch, RI_NULL);
                }
                RiTranslate(-2.0*WIDTH, 0.0, 2.0);
            }
        RiWorldEnd();
    RiEnd();            /* Clean up after the renderer */

    return 0;
}
