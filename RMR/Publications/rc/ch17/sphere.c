/* $Id: sphere.c,v 1.1.1.1 2002/02/10 02:35:43 tal Exp $  (Pixar - RenderMan Division)  $Date: 2002/02/10 02:35:43 $ */
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
static RtPoint From = {0.0, 0.0, 0.0},
               To = {1.0, 0.0, 0.5};

int
main(void)
{
    RtFloat intensity = 0.1;

    RiBegin(RI_NULL);        /* Start the renderer */
	RiDisplay("RenderMan", RI_FRAMEBUFFER, RI_RGB, RI_NULL);
	RiFormat((RtInt) 256, (RtInt) 192, -1.0);
	RiShadingRate(1.0);
        SpecialSetup();
        RiTranslate(0.0, 0.0, 2.0);
        RiScale(0.8, 0.8, 0.8);
        RiLightSource("ambientlight",
                      "intensity", (RtPointer)&intensity, RI_NULL);
        RiLightSource("distantlight",
                      "from", (RtPointer)From,
                      "to", (RtPointer)To, RI_NULL);
        RiWorldBegin();
            RiSurface("matte", RI_NULL);
            RiColor(Color);        /* Declare the color */
            RiRotate(90.0, 1.0, 0.0, 0.0);
            RiSphere(1.0, -1.0, 1.0, 360.0, RI_NULL);
        RiWorldEnd();
    RiEnd();            /* Clean up after the renderer */

    return 0;
}
